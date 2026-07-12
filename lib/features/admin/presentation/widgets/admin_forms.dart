import 'package:capstone_mobile/app/theme/app_theme.dart';
import 'package:capstone_mobile/features/admin/models/admin_models.dart';
import 'package:capstone_mobile/shared/i18n/app_locale.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class HotelFormDialog extends StatefulWidget {
  const HotelFormDialog({this.hotel, super.key});
  final AdminHotel? hotel;

  @override
  State<HotelFormDialog> createState() => _HotelFormDialogState();
}

class _HotelFormDialogState extends State<HotelFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _slug;
  late final TextEditingController _address;
  late final TextEditingController _description;
  late final TextEditingController _basePrice;
  late final TextEditingController _imageUrl;
  late final TextEditingController _maxStayDays;
  String _city = 'da-lat';
  String _type = 'hotel';
  bool _preferred = false;
  List<int>? _imageBytes;
  String? _imageFilename;

  @override
  void initState() {
    super.initState();
    final hotel = widget.hotel;
    _title = TextEditingController(text: hotel?.title ?? '');
    _slug = TextEditingController(text: hotel?.slug ?? '');
    _address = TextEditingController(text: hotel?.address ?? '');
    _description = TextEditingController(text: hotel?.description ?? '');
    _basePrice = TextEditingController(
      text: hotel == null ? '' : '${hotel.basePrice.round()}',
    );
    _imageUrl = TextEditingController(text: hotel?.imageUrl ?? '');
    _maxStayDays = TextEditingController(text: '${hotel?.maxStayDays ?? 30}');
    _city = hotel?.city ?? 'da-lat';
    _type = hotel?.type ?? 'hotel';
    _preferred = hotel?.isPreferred ?? false;
  }

  @override
  void dispose() {
    _title.dispose();
    _slug.dispose();
    _address.dispose();
    _description.dispose();
    _basePrice.dispose();
    _imageUrl.dispose();
    _maxStayDays.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      actionsAlignment: MainAxisAlignment.end,
      title: Text(
        widget.hotel == null
            ? tr('Thêm cơ sở lưu trú', 'Add property')
            : tr('Cập nhật cơ sở lưu trú', 'Edit property'),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AdminTextField(
                  controller: _title,
                  label: tr('Tên cơ sở', 'Property name'),
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _slug,
                  label: tr('Đường dẫn (slug)', 'URL slug'),
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _address,
                  label: tr('Địa chỉ', 'Address'),
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _select(tr('Thành phố', 'City'), _city, const [
                        'da-lat',
                        'da-nang',
                        'ha-noi',
                        'ho-chi-minh',
                        'vung-tau',
                      ], (v) => setState(() => _city = v)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _select(
                        tr('Loại hình', 'Property type'),
                        _type,
                        const [
                          'hotel',
                          'resort',
                          'villa',
                          'hostel',
                          'apartment',
                          'business',
                        ],
                        (v) => setState(() => _type = v),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AdminTextField(
                        controller: _basePrice,
                        label: tr('Giá cơ bản', 'Base price'),
                        numeric: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextField(
                        controller: _maxStayDays,
                        label: tr(
                          'Số ngày lưu trú tối đa',
                          'Maximum stay days',
                        ),
                        numeric: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                _ImagePickerField(
                  currentImageUrl: _imageUrl.text,
                  selectedFilename: _imageFilename,
                  onPick: _pickImage,
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _description,
                  label: tr('Mô tả', 'Description'),
                  maxLines: 3,
                ),
                SwitchListTile(
                  value: _preferred,
                  onChanged: (value) => setState(() => _preferred = value),
                  title: Text(tr('Cơ sở được ưu tiên', 'Preferred property')),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Huỷ', 'Cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          style: _adminDialogPrimaryButtonStyle,
          child: Text(tr('Lưu', 'Save')),
        ),
      ],
    );
  }

  Widget _select(
    String label,
    String value,
    List<String> items,
    ValueChanged<String> onChanged,
  ) {
    return DropdownButtonFormField<String>(
      isExpanded: true,
      initialValue: value,
      decoration: _adminInputDecoration(label),
      items: [
        for (final item in items)
          DropdownMenuItem(value: item, child: Text(adminOptionLabel(item))),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      AdminHotelInput(
        title: _title.text.trim(),
        slug: _slug.text.trim(),
        address: _address.text.trim(),
        city: _city,
        type: _type,
        description: _description.text.trim(),
        basePrice: num.tryParse(_basePrice.text.trim()) ?? 0,
        imageUrl: _imageUrl.text.trim(),
        maxStayDays: int.tryParse(_maxStayDays.text.trim()) ?? 30,
        isPreferred: _preferred,
        imageBytes: _imageBytes,
        imageFilename: _imageFilename,
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _pickImageFile();
    if (file == null || !mounted) return;
    setState(() {
      _imageBytes = file.bytes;
      _imageFilename = file.name;
    });
  }
}

class RoomFormDialog extends StatefulWidget {
  const RoomFormDialog({required this.hotels, this.room, super.key});
  final List<AdminHotel> hotels;
  final AdminRoom? room;

  @override
  State<RoomFormDialog> createState() => _RoomFormDialogState();
}

class _RoomFormDialogState extends State<RoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _originalPrice;
  late final TextEditingController _discount;
  late final TextEditingController _capacity;
  late final TextEditingController _quantity;
  late final TextEditingController _bedInfo;
  late final TextEditingController _area;
  late final TextEditingController _view;
  late final TextEditingController _imageUrl;
  late String _propertyId;
  late String _roomType;
  late bool _active;
  List<int>? _imageBytes;
  String? _imageFilename;

  @override
  void initState() {
    super.initState();
    final room = widget.room;
    _propertyId = widget.hotels.any((hotel) => hotel.id == room?.propertyId)
        ? room!.propertyId
        : widget.hotels.first.id;
    _roomType = room?.roomType ?? 'standard_room';
    _active = room?.isActive ?? true;
    _name = TextEditingController(text: room?.name ?? '');
    _description = TextEditingController(text: room?.description ?? '');
    _originalPrice = TextEditingController(
      text: room == null ? '' : '${room.originalPrice.round()}',
    );
    _discount = TextEditingController(
      text: room == null ? '0' : '${room.discountPercent.round()}',
    );
    _capacity = TextEditingController(
      text: room == null ? '2' : '${room.capacity}',
    );
    _quantity = TextEditingController(
      text: room == null ? '1' : '${room.quantity}',
    );
    _bedInfo = TextEditingController(text: room?.bedInfo ?? '1 queen bed');
    _area = TextEditingController(text: room == null ? '25' : '${room.area}');
    _view = TextEditingController(text: room?.view ?? '');
    _imageUrl = TextEditingController(text: room?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _originalPrice.dispose();
    _discount.dispose();
    _capacity.dispose();
    _quantity.dispose();
    _bedInfo.dispose();
    _area.dispose();
    _view.dispose();
    _imageUrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      actionsAlignment: MainAxisAlignment.end,
      title: Text(
        widget.room == null
            ? tr('Thêm phòng', 'Add room')
            : tr('Cập nhật phòng', 'Edit room'),
      ),
      content: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 640),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _propertyId,
                  decoration: _adminInputDecoration(
                    tr('Cơ sở lưu trú', 'Property'),
                  ),
                  items: [
                    for (final hotel in widget.hotels)
                      DropdownMenuItem(
                        value: hotel.id,
                        child: Text(
                          hotel.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => _propertyId = value ?? _propertyId),
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _name,
                  label: tr('Tên phòng', 'Room name'),
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _roomType,
                  decoration: _adminInputDecoration(
                    tr('Loại phòng', 'Room type'),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'standard_room',
                      child: Text(tr('Tiêu chuẩn', 'Standard')),
                    ),
                    DropdownMenuItem(
                      value: 'deluxe_room',
                      child: Text(tr('Cao cấp', 'Deluxe')),
                    ),
                    DropdownMenuItem(
                      value: 'suite',
                      child: Text(tr('Phòng suite', 'Suite')),
                    ),
                  ],
                  onChanged: (value) =>
                      setState(() => _roomType = value ?? _roomType),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AdminTextField(
                        controller: _originalPrice,
                        label: tr('Giá gốc', 'Original price'),
                        numeric: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextField(
                        controller: _discount,
                        label: tr('Giảm giá (%)', 'Discount (%)'),
                        numeric: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: AdminTextField(
                        controller: _capacity,
                        label: tr('Sức chứa', 'Capacity'),
                        numeric: true,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: AdminTextField(
                        controller: _quantity,
                        label: tr('Số lượng', 'Quantity'),
                        numeric: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _bedInfo,
                  label: tr('Thông tin giường', 'Bed information'),
                  requiredField: true,
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _area,
                  label: tr('Diện tích (m²)', 'Area (m²)'),
                  numeric: true,
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _view,
                  label: tr('Hướng nhìn', 'View'),
                ),
                const SizedBox(height: 10),
                _ImagePickerField(
                  currentImageUrl: _imageUrl.text,
                  selectedFilename: _imageFilename,
                  onPick: _pickImage,
                ),
                const SizedBox(height: 10),
                AdminTextField(
                  controller: _description,
                  label: tr('Mô tả', 'Description'),
                  maxLines: 3,
                ),
                SwitchListTile(
                  value: _active,
                  onChanged: (value) => setState(() => _active = value),
                  title: Text(tr('Phòng đang hoạt động', 'Room is active')),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(tr('Huỷ', 'Cancel')),
        ),
        FilledButton(
          onPressed: _submit,
          style: _adminDialogPrimaryButtonStyle,
          child: Text(tr('Lưu', 'Save')),
        ),
      ],
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    Navigator.of(context).pop(
      AdminRoomInput(
        propertyId: _propertyId,
        name: _name.text.trim(),
        roomType: _roomType,
        description: _description.text.trim(),
        originalPrice: num.tryParse(_originalPrice.text.trim()) ?? 0,
        discountPercent: num.tryParse(_discount.text.trim()) ?? 0,
        capacity: int.tryParse(_capacity.text.trim()) ?? 1,
        quantity: int.tryParse(_quantity.text.trim()) ?? 1,
        bedInfo: _bedInfo.text.trim(),
        area: int.tryParse(_area.text.trim()) ?? 0,
        view: _view.text.trim(),
        imageUrl: _imageUrl.text.trim(),
        isActive: _active,
        imageBytes: _imageBytes,
        imageFilename: _imageFilename,
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _pickImageFile();
    if (file == null || !mounted) return;
    setState(() {
      _imageBytes = file.bytes;
      _imageFilename = file.name;
    });
  }
}

class AdminTextField extends StatelessWidget {
  const AdminTextField({
    required this.controller,
    required this.label,
    this.requiredField = false,
    this.numeric = false,
    this.maxLines = 1,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final bool requiredField;
  final bool numeric;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: numeric ? TextInputType.number : TextInputType.text,
      decoration: _adminInputDecoration(label),
      validator: requiredField
          ? (value) => value == null || value.trim().isEmpty
                ? tr('Bắt buộc', 'Required')
                : null
          : null,
    );
  }
}

Future<PlatformFile?> _pickImageFile() async {
  final result = await FilePicker.platform.pickFiles(
    type: FileType.image,
    allowMultiple: false,
    withData: true,
  );
  final file = result?.files.single;
  return file?.bytes == null ? null : file;
}

class _ImagePickerField extends StatelessWidget {
  const _ImagePickerField({
    required this.currentImageUrl,
    required this.selectedFilename,
    required this.onPick,
  });

  final String currentImageUrl;
  final String? selectedFilename;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final filename = selectedFilename;
    final description =
        filename ??
        (currentImageUrl.isNotEmpty
            ? tr('Đang sử dụng ảnh hiện tại', 'Using the current image')
            : tr('Chưa chọn ảnh', 'No image selected'));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD6E1EA)),
      ),
      child: Row(
        children: [
          const Icon(Icons.image_outlined, color: AppTheme.muted, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tr('Ảnh đại diện', 'Main image'),
                  style: const TextStyle(
                    color: AppTheme.ink,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 11),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.folder_open_outlined, size: 17),
            label: Text(tr('Chọn ảnh', 'Choose image')),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UserFormDialog extends StatefulWidget {
  const UserFormDialog({this.user, super.key});
  final AdminUser? user;

  @override
  State<UserFormDialog> createState() => _UserFormDialogState();
}

class _UserFormDialogState extends State<UserFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _phone;
  late final TextEditingController _address;
  late String _gender;
  late String _role;
  List<int>? _imageBytes;
  String? _imageFilename;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _name = TextEditingController(text: user?.fullName ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _password = TextEditingController();
    _phone = TextEditingController(text: user?.phone ?? '');
    _address = TextEditingController(text: user?.address ?? '');
    _gender = user?.gender ?? '';
    _role = user?.role ?? 'user';
  }

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
    actionsAlignment: MainAxisAlignment.end,
    title: Text(
      widget.user == null
          ? tr('Thêm tài khoản', 'Add user')
          : tr('Cập nhật tài khoản', 'Edit user'),
    ),
    content: SizedBox(
      width: 520,
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AdminTextField(
                controller: _name,
                label: tr('Họ và tên', 'Full name'),
                requiredField: true,
              ),
              const SizedBox(height: 10),
              AdminTextField(
                controller: _email,
                label: tr('Email', 'Email'),
                requiredField: widget.user == null,
              ),
              const SizedBox(height: 10),
              AdminTextField(
                controller: _password,
                label: widget.user == null
                    ? tr('Mật khẩu', 'Password')
                    : tr(
                        'Mật khẩu mới (không bắt buộc)',
                        'New password (optional)',
                      ),
                requiredField: widget.user == null,
              ),
              const SizedBox(height: 10),
              AdminTextField(
                controller: _phone,
                label: tr('Số điện thoại', 'Phone number'),
              ),
              const SizedBox(height: 10),
              AdminTextField(
                controller: _address,
                label: tr('Địa chỉ', 'Address'),
              ),
              const SizedBox(height: 10),
              _ImagePickerField(
                currentImageUrl: widget.user?.avatarUrl ?? '',
                selectedFilename: _imageFilename,
                onPick: _pickImage,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _gender,
                      decoration: _adminInputDecoration(
                        tr('Giới tính', 'Gender'),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: '',
                          child: Text(tr('Chưa chọn', 'Not specified')),
                        ),
                        DropdownMenuItem(
                          value: 'male',
                          child: Text(tr('Nam', 'Male')),
                        ),
                        DropdownMenuItem(
                          value: 'female',
                          child: Text(tr('Nữ', 'Female')),
                        ),
                        DropdownMenuItem(
                          value: 'other',
                          child: Text(tr('Khác', 'Other')),
                        ),
                      ],
                      onChanged: (value) => _gender = value ?? '',
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: _role,
                      decoration: _adminInputDecoration(tr('Vai trò', 'Role')),
                      items: [
                        DropdownMenuItem(
                          value: 'user',
                          child: Text(tr('Người dùng', 'User')),
                        ),
                        DropdownMenuItem(
                          value: 'admin',
                          child: Text(tr('Quản trị viên', 'Admin')),
                        ),
                      ],
                      onChanged: (value) => _role = value ?? 'user',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr('Huỷ', 'Cancel')),
      ),
      FilledButton(
        onPressed: _submit,
        style: _adminDialogPrimaryButtonStyle,
        child: Text(tr('Lưu', 'Save')),
      ),
    ],
  );

  void _submit() {
    if (_formKey.currentState?.validate() != true) return;
    if (_password.text.isNotEmpty && _password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Mật khẩu phải có ít nhất 6 ký tự.',
              'Password must contain at least 6 characters.',
            ),
          ),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      AdminUserInput(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
        phone: _phone.text.trim(),
        gender: _gender,
        address: _address.text.trim(),
        role: _role,
        imageBytes: _imageBytes,
        imageFilename: _imageFilename,
      ),
    );
  }

  Future<void> _pickImage() async {
    final file = await _pickImageFile();
    if (file == null || !mounted) return;
    setState(() {
      _imageBytes = file.bytes;
      _imageFilename = file.name;
    });
  }
}

class BookingFormDialog extends StatefulWidget {
  const BookingFormDialog({
    required this.users,
    required this.hotels,
    required this.rooms,
    this.booking,
    super.key,
  });
  final List<AdminUser> users;
  final List<AdminHotel> hotels;
  final List<AdminRoom> rooms;
  final AdminBooking? booking;

  @override
  State<BookingFormDialog> createState() => _BookingFormDialogState();
}

class _BookingFormDialogState extends State<BookingFormDialog> {
  late String _userId;
  late String _propertyId;
  late String _roomId;
  late String _status;
  late DateTime _checkIn;
  late DateTime _checkOut;
  late final TextEditingController _guests;
  late final TextEditingController _roomsCount;
  late final bool _hadMissingReferences;

  @override
  void initState() {
    super.initState();
    final booking = widget.booking;
    final validUser =
        booking != null &&
        widget.users.any((item) => item.id == booking.userId);
    final validProperty =
        booking != null &&
        widget.hotels.any((item) => item.id == booking.propertyId);
    _userId = validUser ? booking.userId : widget.users.first.id;
    _propertyId = validProperty ? booking.propertyId : widget.hotels.first.id;
    final validRooms = widget.rooms
        .where((room) => room.propertyId == _propertyId)
        .toList();
    final validRoom =
        booking != null && validRooms.any((item) => item.id == booking.roomId);
    _roomId = validRoom
        ? booking.roomId
        : (validRooms.isNotEmpty ? validRooms.first.id : '');
    _hadMissingReferences =
        booking != null && (!validUser || !validProperty || !validRoom);
    const statuses = {'pending', 'confirmed', 'completed', 'cancelled'};
    _status = statuses.contains(booking?.status) ? booking!.status : 'pending';
    _checkIn = booking?.checkIn ?? DateTime.now().add(const Duration(days: 1));
    _checkOut =
        booking?.checkOut ?? DateTime.now().add(const Duration(days: 2));
    _guests = TextEditingController(text: '${booking?.guests ?? 1}');
    _roomsCount = TextEditingController(text: '${booking?.roomsCount ?? 1}');
  }

  List<AdminRoom> get _availableRooms =>
      widget.rooms.where((room) => room.propertyId == _propertyId).toList();

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
    actionsAlignment: MainAxisAlignment.end,
    title: Text(
      widget.booking == null
          ? tr('Thêm booking', 'Add booking')
          : tr('Cập nhật booking', 'Edit booking'),
    ),
    content: SizedBox(
      width: 560,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_hadMissingReferences) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF7E6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFF1D392)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 20,
                      color: AppTheme.gold,
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        tr(
                          'Booking này có liên kết dữ liệu cũ đã mất. Hệ thống đã chọn dữ liệu hợp lệ thay thế, vui lòng kiểm tra trước khi lưu.',
                          'This booking contains missing legacy references. Valid replacements were selected; review them before saving.',
                        ),
                        style: const TextStyle(
                          color: AppTheme.ink,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
            ],
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _userId,
              decoration: _adminInputDecoration(tr('Khách hàng', 'Guest')),
              items: widget.users
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        '${item.fullName} - ${item.email}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _userId = value ?? _userId,
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _propertyId,
              decoration: _adminInputDecoration(
                tr('Cơ sở lưu trú', 'Property'),
              ),
              items: widget.hotels
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        item.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => setState(() {
                _propertyId = value ?? _propertyId;
                final rooms = _availableRooms;
                _roomId = rooms.isNotEmpty ? rooms.first.id : '';
              }),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              key: ValueKey(_propertyId),
              initialValue: _availableRooms.any((r) => r.id == _roomId)
                  ? _roomId
                  : null,
              decoration: _adminInputDecoration(tr('Phòng', 'Room')),
              items: _availableRooms
                  .map(
                    (item) => DropdownMenuItem(
                      value: item.id,
                      child: Text(
                        item.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (value) => _roomId = value ?? _roomId,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _DateButton(
                    label: tr('Nhận phòng', 'Check-in'),
                    value: _checkIn,
                    onChanged: (value) => setState(() => _checkIn = value),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _DateButton(
                    label: tr('Trả phòng', 'Check-out'),
                    value: _checkOut,
                    onChanged: (value) => setState(() => _checkOut = value),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: AdminTextField(
                    controller: _guests,
                    label: tr('Số khách', 'Guests'),
                    numeric: true,
                    requiredField: true,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AdminTextField(
                    controller: _roomsCount,
                    label: tr('Số phòng', 'Rooms'),
                    numeric: true,
                    requiredField: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _status,
              decoration: _adminInputDecoration(tr('Trạng thái', 'Status')),
              items: [
                DropdownMenuItem(
                  value: 'pending',
                  child: Text(tr('Chờ xử lý', 'Pending')),
                ),
                DropdownMenuItem(
                  value: 'confirmed',
                  child: Text(tr('Đã xác nhận', 'Confirmed')),
                ),
                DropdownMenuItem(
                  value: 'completed',
                  child: Text(tr('Đã hoàn tất', 'Completed')),
                ),
                DropdownMenuItem(
                  value: 'cancelled',
                  child: Text(tr('Đã huỷ', 'Cancelled')),
                ),
              ],
              onChanged: (value) => _status = value ?? _status,
            ),
          ],
        ),
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr('Huỷ', 'Cancel')),
      ),
      FilledButton(
        onPressed: _submit,
        style: _adminDialogPrimaryButtonStyle,
        child: Text(tr('Lưu thay đổi', 'Save changes')),
      ),
    ],
  );

  void _submit() {
    if (_availableRooms.isEmpty || !_checkOut.isAfter(_checkIn)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tr(
              'Vui lòng chọn phòng và ngày hợp lệ.',
              'Select a valid room and date range.',
            ),
          ),
        ),
      );
      return;
    }
    Navigator.pop(
      context,
      AdminBookingInput(
        userId: _userId,
        propertyId: _propertyId,
        roomId: _roomId,
        checkIn: _checkIn,
        checkOut: _checkOut,
        guests: int.tryParse(_guests.text) ?? 1,
        roomsCount: int.tryParse(_roomsCount.text) ?? 1,
        status: _status,
      ),
    );
  }
}

class _DateButton extends StatelessWidget {
  const _DateButton({
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () async {
      final date = await showDatePicker(
        context: context,
        initialDate: value,
        firstDate: DateTime(2020),
        lastDate: DateTime(2035),
      );
      if (date != null) onChanged(date);
    },
    child: InputDecorator(
      decoration: _adminInputDecoration(label),
      child: Text('${value.day}/${value.month}/${value.year}'),
    ),
  );
}

class ReviewFormDialog extends StatefulWidget {
  const ReviewFormDialog({required this.review, super.key});
  final AdminReview review;
  @override
  State<ReviewFormDialog> createState() => _ReviewFormDialogState();
}

class _ReviewFormDialogState extends State<ReviewFormDialog> {
  late final TextEditingController _comment;
  late double _rating;
  @override
  void initState() {
    super.initState();
    _comment = TextEditingController(text: widget.review.comment);
    _rating = widget.review.rating.toDouble().clamp(1, 5);
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    insetPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    backgroundColor: Colors.white,
    surfaceTintColor: Colors.white,
    titlePadding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
    contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
    actionsAlignment: MainAxisAlignment.end,
    title: Text(tr('Kiểm duyệt đánh giá', 'Moderate review')),
    content: SizedBox(
      width: 500,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.review.userName} - ${widget.review.hotelTitle}'),
          Slider(
            value: _rating,
            min: 1,
            max: 5,
            divisions: 4,
            label: tr('${_rating.round()} sao', '${_rating.round()} stars'),
            onChanged: (value) => setState(() => _rating = value),
          ),
          AdminTextField(
            controller: _comment,
            label: tr('Nội dung đánh giá', 'Review content'),
            requiredField: true,
            maxLines: 4,
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(tr('Huỷ', 'Cancel')),
      ),
      FilledButton(
        onPressed: () =>
            Navigator.pop(context, (_rating.round(), _comment.text.trim())),
        style: _adminDialogPrimaryButtonStyle,
        child: Text(tr('Lưu', 'Save')),
      ),
    ],
  );
}

InputDecoration _adminInputDecoration(String label) {
  const borderColor = Color(0xFFD6E1EA);
  const focusedColor = AppTheme.primary;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: const BorderSide(color: borderColor),
  );
  return InputDecoration(
    labelText: label,
    isDense: true,
    filled: true,
    fillColor: const Color(0xFFF8FAFC),
    floatingLabelBehavior: FloatingLabelBehavior.auto,
    floatingLabelStyle: const TextStyle(
      color: AppTheme.primaryDark,
      fontSize: 12,
      fontWeight: FontWeight.w700,
    ),
    labelStyle: const TextStyle(color: AppTheme.muted, fontSize: 13),
    contentPadding: const EdgeInsets.fromLTRB(13, 15, 13, 13),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: const BorderSide(color: focusedColor, width: 1.4),
    ),
    errorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppTheme.danger),
    ),
    focusedErrorBorder: border.copyWith(
      borderSide: const BorderSide(color: AppTheme.danger, width: 1.4),
    ),
  );
}

ButtonStyle get _adminDialogPrimaryButtonStyle => FilledButton.styleFrom(
  minimumSize: const Size(112, 42),
  padding: const EdgeInsets.symmetric(horizontal: 18),
  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
);
