import 'package:capstone_mobile/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/otp_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/register_page.dart';
import 'package:capstone_mobile/features/auth/presentation/pages/reset_password_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/booking_confirmation_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/booking_schedule_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/payment_checkout_page.dart';
import 'package:capstone_mobile/features/booking/presentation/pages/room_selection_page.dart';
import 'package:capstone_mobile/features/detail/presentation/pages/hotel_info_form_page.dart';
import 'package:capstone_mobile/features/detail/presentation/pages/room_detail_page.dart';
import 'package:capstone_mobile/features/home/presentation/pages/home_page.dart';
import 'package:capstone_mobile/features/home/presentation/pages/hotel_list_page.dart';
import 'package:capstone_mobile/features/home/presentation/pages/notifications_page.dart';
import 'package:capstone_mobile/features/onboarding/presentation/pages/onboarding_intro_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/empty_search_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/filter_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/offline_error_page.dart';
import 'package:capstone_mobile/features/search/presentation/pages/search_page.dart';
import 'package:flutter/material.dart';

class AppRoutes {
  const AppRoutes._();

  static const home = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const otp = '/otp';
  static const resetPassword = '/reset-password';
  static const hotelList = '/hotel-list';
  static const notifications = '/notifications';
  static const search = '/search';
  static const filter = '/filter';
  static const emptySearch = '/empty-search';
  static const offlineError = '/offline-error';
  static const roomDetail = '/room-detail';
  static const hotelInfoForm = '/hotel-info-form';
  static const roomSelection = '/room-selection';
  static const bookingSchedule = '/booking-schedule';
  static const paymentCheckout = '/payment-checkout';
  static const bookingConfirmation = '/booking-confirmation';

  static Map<String, WidgetBuilder> get routes => {
        home: (_) => const HomePage(),
        onboarding: (_) => const OnboardingIntroPage(),
        login: (_) => const LoginPage(),
        register: (_) => const RegisterPage(),
        forgotPassword: (_) => const ForgotPasswordPage(),
        otp: (_) => const OtpPage(),
        resetPassword: (_) => const ResetPasswordPage(),
        hotelList: (_) => const HotelListPage(),
        notifications: (_) => const NotificationsPage(),
        search: (_) => const SearchPage(),
        filter: (_) => const FilterPage(),
        emptySearch: (_) => const EmptySearchPage(),
        offlineError: (_) => const OfflineErrorPage(),
        roomDetail: (_) => const RoomDetailPage(),
        hotelInfoForm: (_) => const HotelInfoFormPage(),
        roomSelection: (_) => const RoomSelectionPage(),
        bookingSchedule: (_) => const BookingSchedulePage(),
        paymentCheckout: (_) => const PaymentCheckoutPage(),
        bookingConfirmation: (_) => const BookingConfirmationPage(),
      };
}
