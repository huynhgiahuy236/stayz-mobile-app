const flows = {
  booking: [
    ["01", "Home / Search", "Chọn khách sạn"],
    ["02", "Hotel detail", "Xem phòng, review"],
    ["03", "Room selection", "Kiểm tra availability"],
    ["04", "Booking schedule", "Ngày, khách, số phòng"],
    ["05", "Checkout", "Chọn cọc 30% / full"],
    ["06", "PayOS QR", "Poll mỗi 3 giây"],
    ["07", "Confirmation", "Webhook đã xác nhận"],
    ["08", "My bookings", "Chi tiết / check-in QR"]
  ],
  auth: [
    ["01", "Auth gate", "Đã xem onboarding?"],
    ["02", "Session check", "Token + user"],
    ["03", "Login / Register", "Password, OTP, Google"],
    ["04", "Secure storage", "Lưu session"],
    ["05", "Home", "Xóa route stack cũ"]
  ],
  admin: [
    ["01", "Admin gate", "Kiểm tra role"],
    ["02", "Dashboard", "Tải 6 nguồn song song"],
    ["03", "Operations", "CRUD / moderation"],
    ["04", "Check-in scan", "Mã hex 8 ký tự"],
    ["05", "Attendance", "checked_in / no_show"],
    ["06", "Auto settle", "completed / cancelled"]
  ]
};

const rules = [
  {domain:"Booking", text:"Giá, số đêm, sức chứa và tồn phòng được backend tính lại; Redlock chống hai request giữ cùng phòng.", status:"guarded"},
  {domain:"Booking", text:"Guest chỉ được tự hủy; không thể tự confirm, complete hoặc đưa confirmed về pending.", status:"guarded"},
  {domain:"Payment", text:"Chỉ webhook PayOS đã verify và khớp số tiền mới chuyển Payment=PAID, Booking=confirmed.", status:"guarded"},
  {domain:"Payment", text:"Hoàn tiền hiện ghi nhận processing=manual; cần workflow đối soát production.", status:"watch"},
  {domain:"Search", text:"Debounce 1 giây giảm request nhưng chưa có request cancellation để loại response cũ.", status:"watch"},
  {domain:"Review", text:"Một review trên mỗi user + booking; rating 1–5; ownership kiểm tra ở service.", status:"guarded"},
  {domain:"Admin", text:"Client có AdminAccessGate; backend tiếp tục bắt JWT và role admin.", status:"guarded"},
  {domain:"Lifecycle", text:"Tự settle booking quá checkout hiện chạy khi service được gọi; nên có scheduled worker.", status:"watch"},
  {domain:"Notification", text:"Tạo notification theo booking/payment event; hỗ trợ read, read-all và delete.", status:"guarded"},
  {domain:"Cache", text:"Property mutation xóa cache list/featured/city/slug có liên quan.", status:"guarded"}
];

const flowCanvas = document.querySelector("#flowCanvas");
const ruleList = document.querySelector("#ruleList");
let activeFilter = "all";

function renderFlow(name) {
  flowCanvas.innerHTML = flows[name].map(([index, title, note]) =>
    `<article class="flow-step"><span>STEP ${index}</span><strong>${title}</strong><small>${note}</small></article>`
  ).join("");
}

function renderRules() {
  const query = document.querySelector("#ruleSearch").value.trim().toLowerCase();
  const visible = rules.filter(rule =>
    (activeFilter === "all" || rule.status === activeFilter) &&
    `${rule.domain} ${rule.text}`.toLowerCase().includes(query)
  );
  ruleList.innerHTML = visible.length ? visible.map(rule => `
    <article class="rule">
      <div class="rule-domain">${rule.domain}</div>
      <p>${rule.text}</p>
      <span class="badge ${rule.status}">${rule.status === "guarded" ? "Đã bảo vệ" : "Cần theo dõi"}</span>
    </article>`).join("") : `<p>Không có nghiệp vụ phù hợp bộ lọc.</p>`;
}

document.querySelectorAll(".tab").forEach(button => button.addEventListener("click", () => {
  document.querySelectorAll(".tab").forEach(tab => {
    tab.classList.toggle("active", tab === button);
    tab.setAttribute("aria-selected", tab === button ? "true" : "false");
  });
  renderFlow(button.dataset.flow);
}));

document.querySelectorAll(".filter").forEach(button => button.addEventListener("click", () => {
  activeFilter = button.dataset.filter;
  document.querySelectorAll(".filter").forEach(filter => filter.classList.toggle("active", filter === button));
  renderRules();
}));

document.querySelector("#ruleSearch").addEventListener("input", renderRules);
document.querySelector("#themeToggle").addEventListener("click", () => {
  const root = document.documentElement;
  const dark = root.dataset.theme !== "dark";
  root.dataset.theme = dark ? "dark" : "light";
  localStorage.setItem("stayz-project-theme", root.dataset.theme);
});

const menuToggle = document.querySelector("#menuToggle");
const sidebar = document.querySelector("#sidebar");
menuToggle.addEventListener("click", () => {
  const open = sidebar.classList.toggle("open");
  menuToggle.setAttribute("aria-expanded", String(open));
});
document.querySelectorAll(".nav-link").forEach(link => link.addEventListener("click", () => {
  sidebar.classList.remove("open");
  menuToggle.setAttribute("aria-expanded", "false");
}));

const observer = new IntersectionObserver(entries => {
  entries.forEach(entry => {
    if (!entry.isIntersecting) return;
    document.querySelectorAll(".nav-link").forEach(link =>
      link.classList.toggle("active", link.getAttribute("href") === `#${entry.target.id}`)
    );
  });
}, {rootMargin:"-25% 0px -65% 0px"});
document.querySelectorAll("main section[id]").forEach(section => observer.observe(section));

document.documentElement.dataset.theme =
  localStorage.getItem("stayz-project-theme") ||
  (matchMedia("(prefers-color-scheme: dark)").matches ? "dark" : "light");
renderFlow("booking");
renderRules();
