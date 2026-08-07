#!/usr/bin/env python3
"""Fail when Flutter UI contains literal user-facing text outside localization.

The scanner intentionally prefers false positives over missed UI copy. Add an
inline ``l10n-ignore: <reason>`` comment only for identifiers, protocol values,
brand names, route names, or other text that must never be translated.

Usage:
    python scripts/audit_localization.py
    python scripts/audit_localization.py lib/features/auth
"""

from __future__ import annotations

import argparse
import re
import sys
from dataclasses import dataclass
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

STRING_RE = re.compile(
    r"(?<![\w])(?P<prefix>[rR]?)(?P<quote>'''|\"\"\"|'|\")(?P<body>.*?)(?P=quote)",
    re.DOTALL,
)

LOCALIZER_RE = re.compile(r"(?<![\w.])tr\s*\(|\.l10n\.text\s*\(")

USER_FACING_HINTS = re.compile(
    r"(?:"
    r"\bText(?:\.rich)?\s*\(|\bTextSpan\s*\(|\bSelectableText\s*\(|"
    r"\bSnackBar\s*\(|\bAlertDialog\s*\(|\bStayzAlert\.show\s*\(|"
    r"\bStayz(?:Empty|Error)View\s*\(|\bAppBar\s*\(|"
    r"\b(?:label|title|subtitle|hint|hintText|helperText|errorText|message|"
    r"tooltip|semanticLabel|semanticsLabel|actionText|primaryLabel|"
    r"secondaryLabel|emptyText|buttonText)\s*:"
    r")",
    re.IGNORECASE,
)

NON_UI_CONTEXT = re.compile(
    r"(?:"
    r"^\s*(?:import|export|part)\s+|"
    r"(?:asset|imageUrl|path|route|baseUrl|endpoint|method|status|role|type|"
    r"id|key|fontFamily|package|scheme|host|currency|paymentPlan|"
    r"paymentMethod|referenceType|mimeType|name)\s*:|"
    r"Navigator\.|AppRoutes\.|RegExp\s*\(|Uri\.|DateFormat\s*\(|"
    r"print\s*\(|debugPrint\s*\(|throw\s+(?:const\s+)?(?:StateError|ArgumentError)"
    r")",
    re.IGNORECASE,
)

PROTOCOL_OR_IDENTIFIER = re.compile(
    r"^(?:"
    r"[A-Z0-9_./:-]+|"
    r"[a-z0-9_]+(?:[-_.][a-z0-9_]+)+|"
    r"https?://\S+|/\S+|assets/\S+|package:\S+|"
    r"[\w.+-]+@[\w.-]+|"
    r"#[0-9A-Fa-f]{3,8}|"
    r"\d+(?:\.\d+)*"
    r")$"
)

INVARIANT_UI_TEXT = {
    "StayZ", "Stay", "Z", "PayOS", "Email", "Check-in", "Check-out",
    "Visa, Mastercard, JCB", "MoMo, ZaloPay, ShopeePay",
    "Internet Banking / QR Code",
    "Tiếng Việt", "English", "Noto Serif JP",
}


@dataclass(frozen=True)
class Finding:
    path: Path
    line: int
    text: str
    context: str


def _balanced_call_end(source: str, open_paren: int) -> int:
    depth = 0
    index = open_paren
    quote: str | None = None
    triple = False
    escaped = False
    while index < len(source):
        char = source[index]
        if quote:
            if escaped:
                escaped = False
            elif char == "\\" and not source[max(0, index - 1) : index] == "r":
                escaped = True
            elif triple and source.startswith(quote * 3, index):
                index += 2
                quote = None
                triple = False
            elif not triple and char == quote:
                quote = None
        elif source.startswith("'''", index) or source.startswith('"""', index):
            quote = char
            triple = True
            index += 2
        elif char in "'\"":
            quote = char
        elif char == "(":
            depth += 1
        elif char == ")":
            depth -= 1
            if depth == 0:
                return index + 1
        index += 1
    return len(source)


def _localized_ranges(source: str) -> list[tuple[int, int]]:
    ranges: list[tuple[int, int]] = []
    for match in LOCALIZER_RE.finditer(source):
        open_paren = source.find("(", match.start(), match.end())
        ranges.append((match.start(), _balanced_call_end(source, open_paren)))
    return ranges


def _inside(position: int, ranges: list[tuple[int, int]]) -> bool:
    return any(start <= position < end for start, end in ranges)


def _looks_like_words(value: str) -> bool:
    compact = re.sub(r"\s+", " ", value).strip()
    literal_text = re.sub(r"\$\{[^}]*\}|\$[A-Za-z_]\w*", "", compact)
    literal_text = re.sub(r"\\[nrt]", "", literal_text)
    return bool(re.search(r"[A-Za-z\u00c0-\u024f\u1e00-\u1eff]", literal_text)) and not bool(
        PROTOCOL_OR_IDENTIFIER.fullmatch(compact)
    )


def scan_file(path: Path) -> list[Finding]:
    source = path.read_text(encoding="utf-8")
    localized = _localized_ranges(source)
    lines = source.splitlines()
    findings: list[Finding] = []

    for match in STRING_RE.finditer(source):
        if _inside(match.start(), localized):
            continue
        value = match.group("body").strip()
        if value.startswith((")),", "),", "];")):
            continue
        if value in INVARIANT_UI_TEXT:
            continue
        if not _looks_like_words(value):
            continue

        line = source.count("\n", 0, match.start()) + 1
        line_text = lines[line - 1] if line <= len(lines) else ""
        previous_line = lines[line - 2] if line > 1 else ""
        if line_text.lstrip().startswith("//"):
            continue
        if "tr(" in line_text or ".l10n.text(" in line_text:
            continue
        if re.search(r"\b(?:enabled|active|onSelected|onTap)\s*:", line_text):
            continue
        if "l10n-ignore:" in line_text or "l10n-ignore:" in previous_line:
            continue

        prefix = source[max(0, match.start() - 60) : match.start()]
        if re.search(r"(?:\w+|\])\s*\[\s*$", prefix):
            continue

        # Keep the neighborhood narrow so nearby widgets cannot taint JSON
        # keys, enum values, routes, and protocol identifiers as visible copy.
        context = "\n".join(lines[max(0, line - 3) : line])
        if NON_UI_CONTEXT.search(line_text) and not USER_FACING_HINTS.search(context):
            continue
        if not USER_FACING_HINTS.search(context):
            continue

        findings.append(
            Finding(
                path=path,
                line=line,
                text=re.sub(r"\s+", " ", value)[:100],
                context=line_text.strip()[:140],
            )
        )
    return findings


def dart_files(targets: list[str]) -> list[Path]:
    roots = [ROOT / target for target in targets] if targets else [ROOT / "lib"]
    files: list[Path] = []
    for root in roots:
        if root.is_file() and root.suffix == ".dart":
            files.append(root)
        elif root.exists():
            files.extend(root.rglob("*.dart"))
    return sorted(set(files))


def scan_taxonomy(path: Path) -> list[Finding]:
    """Taxonomy literals are valid only when every term has an English label."""
    findings: list[Finding] = []
    for line_number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
        if "StayzTerm(" not in line or not re.search(r"label:\s*['\"]", line):
            continue
        if "enLabel:" in line:
            continue
        findings.append(Finding(path, line_number, "StayzTerm missing enLabel", line.strip()[:140]))
    return findings


def main() -> int:
    if hasattr(sys.stdout, "reconfigure"):
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("targets", nargs="*", help="Files/directories relative to repo root")
    args = parser.parse_args()

    findings: list[Finding] = []
    for path in dart_files(args.targets):
        if path.name == "stayz_taxonomy.dart":
            findings.extend(scan_taxonomy(path))
        else:
            findings.extend(scan_file(path))
    for finding in findings:
        relative = finding.path.relative_to(ROOT)
        print(f"{relative}:{finding.line}: unlocalized UI text: {finding.text!r}")
        print(f"    {finding.context}")

    if findings:
        print(f"\nFAILED: {len(findings)} possible unlocalized UI string(s).")
        return 1
    print("OK: no unlocalized user-facing Dart string literals found.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
