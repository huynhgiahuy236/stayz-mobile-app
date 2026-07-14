import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:flutter/material.dart';
import 'package:capstone_mobile/shared/widgets/stayz_brand_logo.dart';

enum AdminSection {
  overview,
  bookings,
  hotels,
  rooms,
  users,
  reviews,
  payments,
}

extension AdminSectionInfo on AdminSection {
  String get label => switch (this) {
    AdminSection.overview => tr('Tổng quan', 'Overview'),
    AdminSection.bookings => tr('Booking', 'Bookings'),
    AdminSection.hotels => tr('Cơ sở lưu trú', 'Properties'),
    AdminSection.rooms => tr('Phòng', 'Rooms'),
    AdminSection.users => tr('Tài khoản', 'Users'),
    AdminSection.reviews => tr('Đánh giá', 'Reviews'),
    AdminSection.payments => tr('Thanh toán', 'Payments'),
  };

  String get title => switch (this) {
    AdminSection.overview => tr('Tổng quan vận hành', 'Operations overview'),
    AdminSection.bookings => tr('Quản lý booking', 'Booking management'),
    AdminSection.hotels => tr('Quản lý cơ sở lưu trú', 'Property management'),
    AdminSection.rooms => tr('Quản lý phòng', 'Room management'),
    AdminSection.users => tr('Quản lý tài khoản', 'User management'),
    AdminSection.reviews => tr('Kiểm duyệt đánh giá', 'Review moderation'),
    AdminSection.payments => tr('Giao dịch PayOS', 'PayOS transactions'),
  };

  String get subtitle => switch (this) {
    AdminSection.overview => tr(
      'Theo dõi nhanh tình hình kinh doanh hôm nay',
      'A quick view of today\'s business',
    ),
    AdminSection.bookings => tr(
      'Theo dõi lịch ở và trạng thái đơn',
      'Track stays and booking statuses',
    ),
    AdminSection.hotels => tr(
      'Thông tin và hình ảnh các cơ sở',
      'Property information and media',
    ),
    AdminSection.rooms => tr(
      'Giá, tồn phòng và trạng thái bán',
      'Pricing, inventory and availability',
    ),
    AdminSection.users => tr(
      'Hồ sơ và phân quyền người dùng',
      'Profiles and access roles',
    ),
    AdminSection.reviews => tr(
      'Kiểm soát chất lượng nội dung đánh giá',
      'Moderate guest review quality',
    ),
    AdminSection.payments => tr(
      'Đối soát giao dịch thanh toán',
      'Reconcile payment transactions',
    ),
  };

  IconData get icon => switch (this) {
    AdminSection.overview => Icons.grid_view_rounded,
    AdminSection.bookings => Icons.calendar_today_rounded,
    AdminSection.hotels => Icons.domain_rounded,
    AdminSection.rooms => Icons.bed_outlined,
    AdminSection.users => Icons.group_outlined,
    AdminSection.reviews => Icons.rate_review_outlined,
    AdminSection.payments => Icons.account_balance_wallet_outlined,
  };
}

class AdminSideNav extends StatelessWidget {
  const AdminSideNav({
    required this.selected,
    required this.onSelect,
    required this.onHome,
    super.key,
  });
  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;
  final VoidCallback onHome;

  @override
  Widget build(BuildContext context) => Container(
    width: 240,
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(right: BorderSide(color: AppTheme.line)),
    ),
    child: Column(
      children: [
        Material(
          color: Colors.white,
          child: SizedBox(
            height: 76,
            child: InkWell(
              onTap: onHome,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppTheme.line)),
                ),
                child: Row(
                  children: [
                    const _BrandMark(),
                    const SizedBox(width: 11),
                    const Expanded(
                      child: Text(
                        'StayZ',
                        style: TextStyle(
                          color: AppTheme.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: AppTheme.primary,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Icon(
                      Icons.arrow_outward_rounded,
                      size: 14,
                      color: AppTheme.muted,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 6, 10, 8),
                child: Text(
                  tr('ĐIỀU HƯỚNG', 'NAVIGATION'),
                  style: const TextStyle(
                    color: AppTheme.muted,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0,
                  ),
                ),
              ),
              for (final section in AdminSection.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Material(
                    color: selected == section
                        ? AppTheme.primarySoft
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => onSelect(section),
                      child: SizedBox(
                        height: 48,
                        child: Row(
                          children: [
                            const SizedBox(width: 14),
                            Icon(
                              section.icon,
                              size: 20,
                              color: selected == section
                                  ? AppTheme.primary
                                  : AppTheme.muted,
                            ),
                            const SizedBox(width: 11),
                            Expanded(
                              child: Text(
                                section.label,
                                style: TextStyle(
                                  color: selected == section
                                      ? AppTheme.primaryDark
                                      : AppTheme.ink,
                                  fontSize: 13,
                                  fontWeight: selected == section
                                      ? FontWeight.w800
                                      : FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primarySoft.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.line),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shield_outlined,
                  size: 20,
                  color: AppTheme.success,
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    tr('Phiên quản trị an toàn', 'Secure admin session'),
                    style: const TextStyle(
                      color: AppTheme.ink,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

class _BrandMark extends StatelessWidget {
  const _BrandMark();
  @override
  Widget build(BuildContext context) =>
      const StayZBrandLogo(size: 36, borderRadius: 12);
}

class AdminHeader extends StatelessWidget {
  const AdminHeader({
    required this.section,
    required this.searchController,
    required this.onRefresh,
    required this.onLogout,
    required this.onHome,
    this.onAdd,
    super.key,
  });
  final AdminSection section;
  final TextEditingController searchController;
  final VoidCallback onRefresh;
  final VoidCallback onLogout;
  final VoidCallback onHome;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 820;
    final title = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppTheme.ink,
            fontWeight: FontWeight.w900,
          ).copyWith(fontSize: wide ? 22 : 18),
        ),
        if (wide) ...[
          const SizedBox(height: 3),
          Text(
            section.subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppTheme.muted,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
    final search = SizedBox(
      height: 48,
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: tr('Tìm kiếm trong mục này', 'Search this section'),
          prefixIcon: const Icon(Icons.search_rounded, size: 20),
          suffixIcon: searchController.text.isEmpty
              ? null
              : IconButton(
                  onPressed: searchController.clear,
                  icon: const Icon(Icons.close_rounded, size: 18),
                  tooltip: tr('Xoá từ khoá', 'Clear search'),
                ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 8,
          ),
        ),
      ),
    );
    final addButton = onAdd == null
        ? null
        : SizedBox(
            height: 48,
            child: FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(tr('Thêm mới', 'Add new')),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 48),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          );
    final controls = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _HeaderIcon(
          icon: Icons.arrow_back_rounded,
          tooltip: tr('Quay lại trang Tôi', 'Back to profile'),
          onPressed: onHome,
        ),
        const SizedBox(width: 6),
        _LanguageButton(),
        if (wide) ...[
          const SizedBox(width: 6),
          _HeaderIcon(
            icon: Icons.refresh_rounded,
            tooltip: tr('Làm mới', 'Refresh'),
            onPressed: onRefresh,
          ),
        ],
        const SizedBox(width: 6),
        _HeaderIcon(
          icon: Icons.logout_rounded,
          tooltip: tr('Đăng xuất', 'Sign out'),
          onPressed: onLogout,
        ),
      ],
    );

    return Container(
      padding: EdgeInsets.fromLTRB(wide ? 24 : 16, 18, wide ? 24 : 16, 14),
      color: AppTheme.surface,
      child: Column(
        children: [
          Row(
            children: [
              if (!wide) ...[
                Tooltip(
                  message: tr('Về trang chủ', 'Go to home'),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      onTap: onHome,
                      borderRadius: BorderRadius.circular(12),
                      child: const _BrandMark(),
                    ),
                  ),
                ),
                const SizedBox(width: 9),
              ],
              Expanded(child: title),
              const SizedBox(width: 12),
              if (wide && section != AdminSection.overview)
                SizedBox(width: 300, child: search),
              if (wide && section != AdminSection.overview)
                const SizedBox(width: 10),
              if (wide && addButton != null) ...[
                addButton,
                const SizedBox(width: 8),
              ],
              controls,
            ],
          ),
          if (!wide && section != AdminSection.overview) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: search),
                if (addButton != null) ...[const SizedBox(width: 8), addButton],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: 48,
    height: 48,
    child: IconButton(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      tooltip: tooltip,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: AppTheme.ink,
        side: const BorderSide(color: AppTheme.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class _LanguageButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: AppLocale.instance,
    builder: (context, _) => Tooltip(
      message: tr('Đổi ngôn ngữ', 'Change language'),
      child: Container(
        height: 48,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _LanguageOption(
              // l10n-ignore: ISO language code with its universally recognized flag.
              label: '${AppLocale.flagFor(AppLanguage.vi)} VI',
              selected: AppLocale.instance.language == AppLanguage.vi,
              onTap: () => AppLocale.instance.setLanguage(AppLanguage.vi),
            ),
            _LanguageOption(
              // l10n-ignore: ISO language code with its universally recognized flag.
              label: '${AppLocale.flagFor(AppLanguage.en)} EN',
              selected: AppLocale.instance.language == AppLanguage.en,
              onTap: () => AppLocale.instance.setLanguage(AppLanguage.en),
            ),
          ],
        ),
      ),
    ),
  );
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 36,
    height: 40,
    child: TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: const Size(36, 40),
        backgroundColor: selected ? AppTheme.primary : Colors.transparent,
        foregroundColor: selected ? Colors.white : AppTheme.muted,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900),
      ),
    ),
  );
}

class AdminTopTabs extends StatelessWidget {
  const AdminTopTabs({
    required this.selected,
    required this.onSelect,
    super.key,
  });
  final AdminSection selected;
  final ValueChanged<AdminSection> onSelect;
  @override
  Widget build(BuildContext context) => Container(
    color: AppTheme.surface,
    padding: const EdgeInsets.fromLTRB(16, 2, 16, 12),
    child: DropdownButtonFormField<AdminSection>(
      initialValue: selected,
      isExpanded: true,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      ),
      items: AdminSection.values
          .map(
            (section) => DropdownMenuItem(
              value: section,
              child: Row(
                children: [
                  Icon(section.icon, size: 20, color: AppTheme.primary),
                  const SizedBox(width: 12),
                  Text(
                    section.label,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          )
          .toList(),
      onChanged: (section) {
        if (section != null) onSelect(section);
      },
    ),
  );
}

class AdminEmptyState extends StatelessWidget {
  const AdminEmptyState({
    required this.icon,
    required this.title,
    this.actionLabel,
    this.onAction,
    super.key,
  });
  final IconData icon;
  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 56),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppTheme.line),
    ),
    child: Column(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: const Color(0xFFF0F5F9),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 25, color: AppTheme.muted),
        ),
        const SizedBox(height: 13),
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.ink,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (actionLabel != null && onAction != null) ...[
          const SizedBox(height: 14),
          SizedBox(
            height: 38,
            child: FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_rounded, size: 17),
              label: Text(actionLabel!),
              style: FilledButton.styleFrom(
                minimumSize: const Size(0, 38),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );
}
