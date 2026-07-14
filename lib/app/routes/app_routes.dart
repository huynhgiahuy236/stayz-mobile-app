import 'package:capstone_mobile/features/admin/presentation/pages/admin_dashboard_page.dart';
import 'package:capstone_mobile/features/admin/presentation/pages/admin_check_in_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/auth_gate_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/otp_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/booking_schedule_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/payment_checkout_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/payment_qr_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/room_selection_real_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/cancel_booking_result_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/cancelled_booking_detail_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/booking_checkin_qr_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/cancelled_bookings_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/completed_booking_detail_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/completed_bookings_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/my_bookings_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/review_page.dart';
import 'package:capstone_mobile/features/booking_management/presentation/pages/upcoming_booking_detail_page.dart';
import 'package:capstone_mobile/features/detail/presentation/pages/hotel_info_form_page.dart';
import 'package:capstone_mobile/features/detail/presentation/pages/room_detail_page.dart';
import 'package:capstone_mobile/features/detail/presentation/pages/room_type_detail_page.dart';
import 'package:capstone_mobile/features/favorites/presentation/pages/favorites_page.dart';
import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:capstone_mobile/features/home/presentation/pages/notifications_page.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_intro_page.dart';
import 'package:capstone_mobile/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:capstone_mobile/features/profile/presentation/pages/help_center_page.dart';
import 'package:capstone_mobile/features/profile/presentation/pages/payment_methods_page.dart';
import 'package:capstone_mobile/features/profile/presentation/pages/profile_form_page.dart';
import 'package:capstone_mobile/features/profile/presentation/pages/settings_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/empty_search_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/filter_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/offline_error_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const admin = '/admin';
  static const adminCheckIn = '/admin/check-in';
  static const authGate = '/auth-gate';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const notifications = '/notifications';
  static const search = '/search';
  static const filter = '/filter';
  static const emptySearch = '/empty-search';
  static const offlineError = '/offline-error';
  static const hotelDetail = '/hotel-detail';
  static const roomDetail = '/room-detail';
  static const hotelInfoForm = '/hotel-info-form';
  static const roomSelection = '/room-selection';
  static const bookingSchedule = '/booking-schedule';
  static const paymentCheckout = '/payment-checkout';
  static const paymentQr = '/payment-qr';
  static const bookingConfirmation = '/booking-confirmation';
  static const myBookings = '/my-bookings';
  static const upcomingBookingDetail = '/upcoming-booking-detail';
  static const completedBookings = '/completed-bookings';
  static const completedBookingDetail = '/completed-booking-detail';
  static const cancelledBookings = '/cancelled-bookings';
  static const cancelledBookingDetail = '/cancelled-booking-detail';
  static const bookingCheckInQr = '/booking-check-in-qr';
  static const cancelBookingResult = '/cancel-booking-result';
  static const review = '/review';
  static const favorites = '/favorites';
  static const settings = '/settings';
  static const profileForm = '/profile-form';
  static const editProfile = '/edit-profile';
  static const helpCenter = '/help-center';
  static const paymentMethods = '/payment-methods';

  static Map<String, WidgetBuilder> get routes => {
    authGate: (_) => const AuthGatePage(),
    admin: (_) => const AdminDashboardPage(),
    adminCheckIn: (_) => const AdminCheckInPage(),
    home: (_) => const HomePage(),
    onboarding: (_) => const OnboardingIntroPage(),
    login: (_) => const LoginPage(),
    register: (_) => const RegisterPage(),
    forgotPassword: (_) => const ForgotPasswordPage(),
    otp: (_) => const OtpPage(),
    resetPassword: (_) => const ResetPasswordPage(),
    notifications: (_) => const NotificationsPage(),
    search: (_) => const SearchPage(),
    filter: (_) => const FilterPage(),
    emptySearch: (_) => const EmptySearchPage(),
    offlineError: (_) => const OfflineErrorPage(),
    hotelDetail: (_) => const RoomDetailPage(),
    roomDetail: (_) => const RoomTypeDetailPage(),
    hotelInfoForm: (_) => const HotelInfoFormPage(),
    roomSelection: (_) => const RealRoomSelectionPage(),
    bookingSchedule: (_) => const BookingSchedulePage(),
    paymentCheckout: (_) => const PaymentCheckoutPage(),
    paymentQr: (_) => const PaymentQrPage(),
    bookingConfirmation: (_) => const BookingConfirmationPage(),
    myBookings: (_) => const MyBookingsPage(),
    upcomingBookingDetail: (_) => const UpcomingBookingDetailPage(),
    completedBookings: (_) => const CompletedBookingsPage(),
    completedBookingDetail: (_) => const CompletedBookingDetailPage(),
    cancelledBookings: (_) => const CancelledBookingsPage(),
    cancelledBookingDetail: (_) => const CancelledBookingDetailPage(),
    bookingCheckInQr: (_) => const BookingCheckInQrPage(),
    cancelBookingResult: (_) => const CancelBookingResultPage(),
    review: (_) => const ReviewPage(),
    favorites: (_) => const FavoritesPage(),
    settings: (_) => const SettingsPage(),
    profileForm: (_) => const ProfileFormPage(),
    editProfile: (_) => const EditProfilePage(),
    helpCenter: (_) => const HelpCenterPage(),
    paymentMethods: (_) => const PaymentMethodsPage(),
  };
}
