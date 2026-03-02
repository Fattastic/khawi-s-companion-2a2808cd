import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en')
  ];

  /// No description provided for @appName.
  ///
  /// In ar, this message translates to:
  /// **'خاوي'**
  String get appName;

  /// No description provided for @appNameEn.
  ///
  /// In ar, this message translates to:
  /// **'Khawi'**
  String get appNameEn;

  /// No description provided for @splashTagline.
  ///
  /// In ar, this message translates to:
  /// **'شارك الطريق، وخفّف الزحمة عليك وعلينا.'**
  String get splashTagline;

  /// No description provided for @onboardingSlide1Title.
  ///
  /// In ar, this message translates to:
  /// **'شارك الطريق، وخفّف الزحمة عليك وعلينا.'**
  String get onboardingSlide1Title;

  /// No description provided for @onboardingSlide2Title.
  ///
  /// In ar, this message translates to:
  /// **'كل كيلو وله نقاط.. والجوائز تنتظرك'**
  String get onboardingSlide2Title;

  /// No description provided for @onboardingSlide3Title.
  ///
  /// In ar, this message translates to:
  /// **'وقت الذروة؟ نقاطك تدبّل!'**
  String get onboardingSlide3Title;

  /// No description provided for @onboardingSlide4Title.
  ///
  /// In ar, this message translates to:
  /// **'بدون عمولة.. والمجتمع كسبان'**
  String get onboardingSlide4Title;

  /// No description provided for @onboardingZeroCommissionDescription.
  ///
  /// In ar, this message translates to:
  /// **'ما نأخذ نسبة مثل غيرنا؛ التطبيق عليك خفيف، والاشتراك بس إذا ودّك تحوّل نقاطك لمكافآت تسوّي مزاج.'**
  String get onboardingZeroCommissionDescription;

  /// No description provided for @onboardingCarOwnerTitle.
  ///
  /// In ar, this message translates to:
  /// **'عندك سيارة؟'**
  String get onboardingCarOwnerTitle;

  /// No description provided for @onboardingSubscriptionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حوّل نقاطك لمكافآت مع Khawi+'**
  String get onboardingSubscriptionTitle;

  /// No description provided for @onboardingSubscriptionDescription.
  ///
  /// In ar, this message translates to:
  /// **'المشاوير مجانية دايمًا. اشترك إذا ودّك نقاطك تصير قهوة وبنزين وهدايا.'**
  String get onboardingSubscriptionDescription;

  /// No description provided for @oneRiyalADay.
  ///
  /// In ar, this message translates to:
  /// **'بريال باليوم.. والباقي علينا'**
  String get oneRiyalADay;

  /// No description provided for @billedMonthly.
  ///
  /// In ar, this message translates to:
  /// **'(يحسب 30 ريال شهرياً)'**
  String get billedMonthly;

  /// No description provided for @next.
  ///
  /// In ar, this message translates to:
  /// **'التالي'**
  String get next;

  /// No description provided for @getStarted.
  ///
  /// In ar, this message translates to:
  /// **'يلا نبدأ السالفة!'**
  String get getStarted;

  /// No description provided for @skip.
  ///
  /// In ar, this message translates to:
  /// **'تخطي'**
  String get skip;

  /// No description provided for @retry.
  ///
  /// In ar, this message translates to:
  /// **'حاول مرة ثانية'**
  String get retry;

  /// No description provided for @seeAll.
  ///
  /// In ar, this message translates to:
  /// **'شوف الكل'**
  String get seeAll;

  /// No description provided for @offerNewRide.
  ///
  /// In ar, this message translates to:
  /// **'اعرض مشوارك وخلك كفو'**
  String get offerNewRide;

  /// No description provided for @todaySummary.
  ///
  /// In ar, this message translates to:
  /// **'ملخص يومك السريع'**
  String get todaySummary;

  /// No description provided for @quickActions.
  ///
  /// In ar, this message translates to:
  /// **'أوامرك'**
  String get quickActions;

  /// No description provided for @map.
  ///
  /// In ar, this message translates to:
  /// **'الخريطة'**
  String get map;

  /// No description provided for @findRide.
  ///
  /// In ar, this message translates to:
  /// **'لقّي لك مشوار'**
  String get findRide;

  /// No description provided for @whereAreYouGoing.
  ///
  /// In ar, this message translates to:
  /// **'وين الوجهة يا بطل؟'**
  String get whereAreYouGoing;

  /// No description provided for @xpLedger.
  ///
  /// In ar, this message translates to:
  /// **'سجل النقاط'**
  String get xpLedger;

  /// No description provided for @xpLedgerHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل النقاط'**
  String get xpLedgerHistory;

  /// No description provided for @xpLedgerRecentActivity.
  ///
  /// In ar, this message translates to:
  /// **'النشاط الأخير'**
  String get xpLedgerRecentActivity;

  /// No description provided for @xpLedgerNoActivityYet.
  ///
  /// In ar, this message translates to:
  /// **'لسّه ما عندك نشاط.. أول مشوار وبتشوف الفرق!'**
  String get xpLedgerNoActivityYet;

  /// No description provided for @xpLedgerEarnXpHint.
  ///
  /// In ar, this message translates to:
  /// **'امش مشوارين وخل النقاط تشتغل!'**
  String get xpLedgerEarnXpHint;

  /// No description provided for @redeemableXpLabel.
  ///
  /// In ar, this message translates to:
  /// **'نقاطك الجاهزة للاستبدال'**
  String get redeemableXpLabel;

  /// No description provided for @somethingWentWrong.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ'**
  String get somethingWentWrong;

  /// No description provided for @khawiPlusRequired.
  ///
  /// In ar, this message translates to:
  /// **'الميزة هذي تحتاج Khawi+'**
  String get khawiPlusRequired;

  /// No description provided for @khawiPlusMonthlyPrice.
  ///
  /// In ar, this message translates to:
  /// **'30 ر.س/شهر'**
  String get khawiPlusMonthlyPrice;

  /// Upsell text shown on the XP ledger screen for non-subscribers.
  ///
  /// In ar, this message translates to:
  /// **'اشترك في Khawi+ ({price}) وخَلّ نقاطك تتحوّل لمكافآت على المزاج.'**
  String xpLedgerUpsellBody(String price);

  /// No description provided for @redeemXp.
  ///
  /// In ar, this message translates to:
  /// **'استبدال XP'**
  String get redeemXp;

  /// No description provided for @promoCodes.
  ///
  /// In ar, this message translates to:
  /// **'أكواد'**
  String get promoCodes;

  /// No description provided for @subscribeToKhawiPlusToRedeem.
  ///
  /// In ar, this message translates to:
  /// **'اشترك في Khawi+ وخلّها تضبط'**
  String get subscribeToKhawiPlusToRedeem;

  /// Label for active XP multiplier for premium users.
  ///
  /// In ar, this message translates to:
  /// **'مضاعف XP {multiplier}× مفعل'**
  String xpLedgerMultiplierActive(String multiplier);

  /// Short label for XP multiplier (for example, in quick benefit chips).
  ///
  /// In ar, this message translates to:
  /// **'{multiplier}× XP'**
  String xpLedgerMultiplierShort(String multiplier);

  /// Approximate redemption value for XP amount.
  ///
  /// In ar, this message translates to:
  /// **'القيمة التقريبية ~ {value}'**
  String xpLedgerApproxValue(String value);

  /// No description provided for @errorLoadingHistory.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل السجل'**
  String get errorLoadingHistory;

  /// No description provided for @errorLoadingTransactions.
  ///
  /// In ar, this message translates to:
  /// **'تعذر تحميل المعاملات'**
  String get errorLoadingTransactions;

  /// No description provided for @hello.
  ///
  /// In ar, this message translates to:
  /// **'هلا!'**
  String get hello;

  /// No description provided for @homeGreetingWithName.
  ///
  /// In ar, this message translates to:
  /// **'هلا {name}! جاهز نخفف الزحمة؟'**
  String homeGreetingWithName(Object name);

  /// No description provided for @communityXp.
  ///
  /// In ar, this message translates to:
  /// **'نقاط مجتمع خاوي'**
  String get communityXp;

  /// No description provided for @aiOptimizedRoute.
  ///
  /// In ar, this message translates to:
  /// **'مسارك المضبوط بالذكاء'**
  String get aiOptimizedRoute;

  /// No description provided for @startRoute.
  ///
  /// In ar, this message translates to:
  /// **'يلا حرّك'**
  String get startRoute;

  /// No description provided for @stop.
  ///
  /// In ar, this message translates to:
  /// **'وقفة'**
  String get stop;

  /// No description provided for @pickup.
  ///
  /// In ar, this message translates to:
  /// **'ركوب'**
  String get pickup;

  /// No description provided for @dropoff.
  ///
  /// In ar, this message translates to:
  /// **'نزول'**
  String get dropoff;

  /// No description provided for @activePassengersCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا يوجد ركاب نشطين} =1{راكب واحد نشط} =2{راكبان نشطان} few{{count} ركاب نشطين} many{{count} راكباً نشطاً} other{{count} راكب نشط}}'**
  String activePassengersCount(int count);

  /// No description provided for @rideStatusAccepted.
  ///
  /// In ar, this message translates to:
  /// **'تم القبول.. أمورك تمام'**
  String get rideStatusAccepted;

  /// No description provided for @optimizing.
  ///
  /// In ar, this message translates to:
  /// **'نضبط لك المسار.. لحظة بس'**
  String get optimizing;

  /// No description provided for @bundleStopsAi.
  ///
  /// In ar, this message translates to:
  /// **'رتب الوقفات (AI)'**
  String get bundleStopsAi;

  /// No description provided for @passengerRequest.
  ///
  /// In ar, this message translates to:
  /// **'طلب خوي جديد'**
  String get passengerRequest;

  /// No description provided for @matchScore.
  ///
  /// In ar, this message translates to:
  /// **'نسبة التوافق: {percent}%'**
  String matchScore(Object percent);

  /// No description provided for @rides.
  ///
  /// In ar, this message translates to:
  /// **'المشاوير'**
  String get rides;

  /// No description provided for @rating.
  ///
  /// In ar, this message translates to:
  /// **'التقييم'**
  String get rating;

  /// No description provided for @languageArabic.
  ///
  /// In ar, this message translates to:
  /// **'العربية'**
  String get languageArabic;

  /// No description provided for @languageEnglish.
  ///
  /// In ar, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @onboardingSlide2Description.
  ///
  /// In ar, this message translates to:
  /// **'XP وشارات وتحديات أسبوعية.. ومكافآت تسوّي ابتسامة.'**
  String get onboardingSlide2Description;

  /// No description provided for @onboardingSlide3Description.
  ///
  /// In ar, this message translates to:
  /// **'حوافز ذكية تخفف الزحمة وتقلل الانبعاثات.'**
  String get onboardingSlide3Description;

  /// No description provided for @noRequestsRightNow.
  ///
  /// In ar, this message translates to:
  /// **'الهدوء جميل.. ما فيه طلبات حاليًا'**
  String get noRequestsRightNow;

  /// No description provided for @stayOnlineForRequests.
  ///
  /// In ar, this message translates to:
  /// **'خلك أونلاين، وأول طلب يطب عليك هنا.'**
  String get stayOnlineForRequests;

  /// No description provided for @youAreOnline.
  ///
  /// In ar, this message translates to:
  /// **'أنت متصل'**
  String get youAreOnline;

  /// No description provided for @youAreOffline.
  ///
  /// In ar, this message translates to:
  /// **'أنت غير متصل'**
  String get youAreOffline;

  /// No description provided for @planner.
  ///
  /// In ar, this message translates to:
  /// **'مخططك الذكي'**
  String get planner;

  /// No description provided for @instantQr.
  ///
  /// In ar, this message translates to:
  /// **'QR على السريع'**
  String get instantQr;

  /// No description provided for @queue.
  ///
  /// In ar, this message translates to:
  /// **'الطابور'**
  String get queue;

  /// No description provided for @regular.
  ///
  /// In ar, this message translates to:
  /// **'الرحلات المعتادة'**
  String get regular;

  /// No description provided for @couldNotLoadSummary.
  ///
  /// In ar, this message translates to:
  /// **'ما قدرنا نجيب الملخص الآن'**
  String get couldNotLoadSummary;

  /// No description provided for @checkConnectionAndTryAgain.
  ///
  /// In ar, this message translates to:
  /// **'شيك على النت وحاول مرة ثانية.'**
  String get checkConnectionAndTryAgain;

  /// No description provided for @noInternetConnection.
  ///
  /// In ar, this message translates to:
  /// **'ما في إنترنت'**
  String get noInternetConnection;

  /// No description provided for @loginTitle.
  ///
  /// In ar, this message translates to:
  /// **'دخولك علينا.. أو حساب جديد'**
  String get loginTitle;

  /// No description provided for @loginSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حيّاك في خاوي، خلنا نبدأ بخطوتين.'**
  String get loginSubtitle;

  /// No description provided for @phoneNumber.
  ///
  /// In ar, this message translates to:
  /// **'رقم الجوال'**
  String get phoneNumber;

  /// No description provided for @continueAction.
  ///
  /// In ar, this message translates to:
  /// **'كمّل'**
  String get continueAction;

  /// No description provided for @phoneInvalidError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رقم جوال صحيح'**
  String get phoneInvalidError;

  /// No description provided for @otpChangePhoneTooltip.
  ///
  /// In ar, this message translates to:
  /// **'تغيير رقم الهاتف'**
  String get otpChangePhoneTooltip;

  /// No description provided for @otpChangeNumberTitle.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الرقم'**
  String get otpChangeNumberTitle;

  /// No description provided for @otpVerificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق'**
  String get otpVerificationTitle;

  /// No description provided for @otpVerificationSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'أدخل رمز التحقق المكون من 6 أرقام الذي أرسلناه إلى جوالك'**
  String get otpVerificationSubtitle;

  /// No description provided for @otpCodeLabel.
  ///
  /// In ar, this message translates to:
  /// **'رمز التحقق'**
  String get otpCodeLabel;

  /// No description provided for @otpVerifyCta.
  ///
  /// In ar, this message translates to:
  /// **'تحقق'**
  String get otpVerifyCta;

  /// No description provided for @otpInvalidCodeError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال رمز التحقق المكون من 6 أرقام'**
  String get otpInvalidCodeError;

  /// No description provided for @emailAuthTitleLogin.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول بالبريد'**
  String get emailAuthTitleLogin;

  /// No description provided for @emailAuthTitleSignup.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get emailAuthTitleSignup;

  /// No description provided for @emailAuthSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'استخدم بريدك الإلكتروني وكلمة المرور'**
  String get emailAuthSubtitle;

  /// No description provided for @emailLabel.
  ///
  /// In ar, this message translates to:
  /// **'البريد الإلكتروني'**
  String get emailLabel;

  /// No description provided for @passwordLabel.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور'**
  String get passwordLabel;

  /// No description provided for @emailInvalidError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى إدخال بريد إلكتروني صحيح'**
  String get emailInvalidError;

  /// No description provided for @passwordTooShortError.
  ///
  /// In ar, this message translates to:
  /// **'كلمة المرور يجب أن تكون {min} أحرف على الأقل'**
  String passwordTooShortError(String min);

  /// No description provided for @checkEmailToConfirmAccount.
  ///
  /// In ar, this message translates to:
  /// **'تحقق من بريدك الإلكتروني لتأكيد حسابك.'**
  String get checkEmailToConfirmAccount;

  /// No description provided for @signIn.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل الدخول'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In ar, this message translates to:
  /// **'إنشاء حساب'**
  String get signUp;

  /// No description provided for @alreadyHaveAccountSignIn.
  ///
  /// In ar, this message translates to:
  /// **'لديك حساب؟ سجّل دخول'**
  String get alreadyHaveAccountSignIn;

  /// No description provided for @noAccountCreateOne.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك حساب؟ أنشئ واحد'**
  String get noAccountCreateOne;

  /// No description provided for @errorTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطأ'**
  String get errorTitle;

  /// No description provided for @ok.
  ///
  /// In ar, this message translates to:
  /// **'حسناً'**
  String get ok;

  /// No description provided for @liveTripTitle.
  ///
  /// In ar, this message translates to:
  /// **'الرحلة المباشرة'**
  String get liveTripTitle;

  /// No description provided for @liveTripRiskLabel.
  ///
  /// In ar, this message translates to:
  /// **'مستوى الخطر: {percent}%'**
  String liveTripRiskLabel(String percent);

  /// No description provided for @liveTripCriticalAlertTitle.
  ///
  /// In ar, this message translates to:
  /// **'تنبيه أمان خطير'**
  String get liveTripCriticalAlertTitle;

  /// No description provided for @liveTripSafetyWarningTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحذير أمان'**
  String get liveTripSafetyWarningTitle;

  /// No description provided for @liveTripUnusualActivityMessage.
  ///
  /// In ar, this message translates to:
  /// **'تم رصد نشاط غير معتاد في الرحلة ({flags}). تم إشعار فريق الدعم.'**
  String liveTripUnusualActivityMessage(String flags);

  /// No description provided for @liveTripSosSent.
  ///
  /// In ar, this message translates to:
  /// **'تم إرسال الاستغاثة. تم إشعار جهات الاتصال.'**
  String get liveTripSosSent;

  /// No description provided for @liveTripSosFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل إرسال الاستغاثة: {error}'**
  String liveTripSosFailed(String error);

  /// No description provided for @liveTripSosCta.
  ///
  /// In ar, this message translates to:
  /// **'استغاثة - مساعدة طارئة'**
  String get liveTripSosCta;

  /// No description provided for @liveTripSending.
  ///
  /// In ar, this message translates to:
  /// **'جار الإرسال...'**
  String get liveTripSending;

  /// No description provided for @or.
  ///
  /// In ar, this message translates to:
  /// **'أو'**
  String get or;

  /// No description provided for @continueWithGoogle.
  ///
  /// In ar, this message translates to:
  /// **'كمّل مع Google'**
  String get continueWithGoogle;

  /// No description provided for @continueWithApple.
  ///
  /// In ar, this message translates to:
  /// **'كمّل مع Apple'**
  String get continueWithApple;

  /// No description provided for @loginWithAbsher.
  ///
  /// In ar, this message translates to:
  /// **'دخول عبر أبشر (للكباتن)'**
  String get loginWithAbsher;

  /// No description provided for @byContinuingYouAgree.
  ///
  /// In ar, this message translates to:
  /// **'إذا كملت، فأنت موافق على'**
  String get byContinuingYouAgree;

  /// No description provided for @termsOfService.
  ///
  /// In ar, this message translates to:
  /// **'شروط الخدمة'**
  String get termsOfService;

  /// No description provided for @and.
  ///
  /// In ar, this message translates to:
  /// **'و'**
  String get and;

  /// No description provided for @privacyPolicy.
  ///
  /// In ar, this message translates to:
  /// **'سياسة الخصوصية'**
  String get privacyPolicy;

  /// No description provided for @verificationTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطوة عشان أماننا كلنا'**
  String get verificationTitle;

  /// No description provided for @verificationDescription.
  ///
  /// In ar, this message translates to:
  /// **'سلامتك تهمنا. توثيق الحساب يخلي مجتمعنا آمن وموثوق. للكباتن، لازم التوثيق عن طريق أبشر.'**
  String get verificationDescription;

  /// No description provided for @verificationButton.
  ///
  /// In ar, this message translates to:
  /// **'تمام، كمّل'**
  String get verificationButton;

  /// No description provided for @driverVerificationAppBarTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من السائق'**
  String get driverVerificationAppBarTitle;

  /// No description provided for @driverVerificationNotNow.
  ///
  /// In ar, this message translates to:
  /// **'لاحقا'**
  String get driverVerificationNotNow;

  /// No description provided for @driverVerificationHeader.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من هوية السائق وملكية المركبة'**
  String get driverVerificationHeader;

  /// No description provided for @driverVerificationBody.
  ///
  /// In ar, this message translates to:
  /// **'لضمان سلامة جميع المستخدمين، نحتاج للتحقق من هويتك وملكية مركبتك.'**
  String get driverVerificationBody;

  /// No description provided for @driverVerificationIdentityTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من الهوية'**
  String get driverVerificationIdentityTitle;

  /// No description provided for @driverVerificationIdentitySubtitle.
  ///
  /// In ar, this message translates to:
  /// **'عبر النفاذ الوطني الموحد (نفاذ)'**
  String get driverVerificationIdentitySubtitle;

  /// No description provided for @driverVerificationVehicleTitle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من ملكية المركبة'**
  String get driverVerificationVehicleTitle;

  /// No description provided for @driverVerificationVehicleSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد ملكية المركبة عبر الأنظمة الرسمية أو المستندات'**
  String get driverVerificationVehicleSubtitle;

  /// No description provided for @driverVerificationStatusVerified.
  ///
  /// In ar, this message translates to:
  /// **'تم التحقق'**
  String get driverVerificationStatusVerified;

  /// No description provided for @driverVerificationStatusApproved.
  ///
  /// In ar, this message translates to:
  /// **'معتمد'**
  String get driverVerificationStatusApproved;

  /// No description provided for @driverVerificationStatusPending.
  ///
  /// In ar, this message translates to:
  /// **'قيد المراجعة'**
  String get driverVerificationStatusPending;

  /// No description provided for @driverVerificationStatusNotVerified.
  ///
  /// In ar, this message translates to:
  /// **'غير مكتمل'**
  String get driverVerificationStatusNotVerified;

  /// No description provided for @driverVerificationActionVerifyWithNafath.
  ///
  /// In ar, this message translates to:
  /// **'التحقق عبر نفاذ'**
  String get driverVerificationActionVerifyWithNafath;

  /// No description provided for @driverVerificationActionVerifyVehicle.
  ///
  /// In ar, this message translates to:
  /// **'التحقق من المركبة'**
  String get driverVerificationActionVerifyVehicle;

  /// No description provided for @driverVerificationContinue.
  ///
  /// In ar, this message translates to:
  /// **'المتابعة إلى لوحة السائق'**
  String get driverVerificationContinue;

  /// No description provided for @driverVerificationPendingNotice.
  ///
  /// In ar, this message translates to:
  /// **'مستنداتك قيد المراجعة. سيتم إشعارك عند اكتمال التحقق. خلال هذه المدة، يمكنك استخدام خاوي كراكب.'**
  String get driverVerificationPendingNotice;

  /// No description provided for @driverVerificationVehicleDetailsTitle.
  ///
  /// In ar, this message translates to:
  /// **'بيانات المركبة'**
  String get driverVerificationVehicleDetailsTitle;

  /// No description provided for @driverVerificationPlateLabel.
  ///
  /// In ar, this message translates to:
  /// **'رقم اللوحة'**
  String get driverVerificationPlateLabel;

  /// No description provided for @driverVerificationPlateHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: أ ب ت 1234'**
  String get driverVerificationPlateHint;

  /// No description provided for @driverVerificationModelLabel.
  ///
  /// In ar, this message translates to:
  /// **'موديل المركبة'**
  String get driverVerificationModelLabel;

  /// No description provided for @driverVerificationModelHint.
  ///
  /// In ar, this message translates to:
  /// **'مثال: تويوتا كامري 2023'**
  String get driverVerificationModelHint;

  /// No description provided for @driverVerificationVehicleLaterNote.
  ///
  /// In ar, this message translates to:
  /// **'سيتم طلب صورة الاستمارة ولقطة للتحقق لاحقا.'**
  String get driverVerificationVehicleLaterNote;

  /// No description provided for @driverVerificationSubmitForReview.
  ///
  /// In ar, this message translates to:
  /// **'إرسال للمراجعة'**
  String get driverVerificationSubmitForReview;

  /// No description provided for @driverVerificationFillVehicleFieldsError.
  ///
  /// In ar, this message translates to:
  /// **'يرجى تعبئة جميع بيانات المركبة'**
  String get driverVerificationFillVehicleFieldsError;

  /// No description provided for @driverVerificationDataDisclosureTitle.
  ///
  /// In ar, this message translates to:
  /// **'إفصاح البيانات'**
  String get driverVerificationDataDisclosureTitle;

  /// No description provided for @driverVerificationDisclosureIdentity.
  ///
  /// In ar, this message translates to:
  /// **'سيتم التحقق من هويتك الوطنية عبر نفاذ.'**
  String get driverVerificationDisclosureIdentity;

  /// No description provided for @driverVerificationDisclosureVehicle.
  ///
  /// In ar, this message translates to:
  /// **'سيتم التحقق من ملكية المركبة عبر الأنظمة الرسمية أو المستندات المقدمة.'**
  String get driverVerificationDisclosureVehicle;

  /// No description provided for @driverVerificationDisclosurePurpose.
  ///
  /// In ar, this message translates to:
  /// **'الغرض: ضمان سلامة وثقة جميع المستخدمين.'**
  String get driverVerificationDisclosurePurpose;

  /// No description provided for @driverVerificationDisclosureRetention.
  ///
  /// In ar, this message translates to:
  /// **'يتم الاحتفاظ بالبيانات وفقا لسياسة الخصوصية الخاصة بنا.'**
  String get driverVerificationDisclosureRetention;

  /// No description provided for @driverVerificationConsentCheckbox.
  ///
  /// In ar, this message translates to:
  /// **'أوافق على التحقق من بياناتي للأغراض المذكورة أعلاه'**
  String get driverVerificationConsentCheckbox;

  /// No description provided for @driverVerificationConsentNeeded.
  ///
  /// In ar, this message translates to:
  /// **'يرجى الموافقة على إفصاح البيانات أولا'**
  String get driverVerificationConsentNeeded;

  /// No description provided for @driverVerificationVerificationFailed.
  ///
  /// In ar, this message translates to:
  /// **'فشل التحقق'**
  String get driverVerificationVerificationFailed;

  /// No description provided for @roleSelectionTitle.
  ///
  /// In ar, this message translates to:
  /// **'حياك الله في خاوي!'**
  String get roleSelectionTitle;

  /// No description provided for @safetyDisclaimerTitle.
  ///
  /// In ar, this message translates to:
  /// **'السلامة والقوانين'**
  String get safetyDisclaimerTitle;

  /// No description provided for @safetyDisclaimerBody.
  ///
  /// In ar, this message translates to:
  /// **'اذا ضغطت \"موافق\"، يعني تتعهد بالتالي:\n\n• تلتزم بأنظمة المرور وتعليماتنا.\n• تربط حزام الأمان طول الطريق.\n• ممنوع التحرش أو أي تصرف يضايق.\n• تحترم الخصوصية ولا تصور أحد بدون إذنه.\n• في مشاوير الأطفال: المسؤول ينتبه لهم زين.\n• لا سمح الله، في الطوارئ كلم العمليات.'**
  String get safetyDisclaimerBody;

  /// No description provided for @safetyDisclaimerAgree.
  ///
  /// In ar, this message translates to:
  /// **'موافق'**
  String get safetyDisclaimerAgree;

  /// No description provided for @safetyDisclaimerDecline.
  ///
  /// In ar, this message translates to:
  /// **'ما أوافق'**
  String get safetyDisclaimerDecline;

  /// No description provided for @subscriptionTagline.
  ///
  /// In ar, this message translates to:
  /// **'الاستخدام مجاني، والاشتراك يخلي نقاطك تسوى أكثر.'**
  String get subscriptionTagline;

  /// No description provided for @iAmADriver.
  ///
  /// In ar, this message translates to:
  /// **'كابتن'**
  String get iAmADriver;

  /// No description provided for @driverDescription.
  ///
  /// In ar, this message translates to:
  /// **'بشارك طريقي وأكسب'**
  String get driverDescription;

  /// No description provided for @iAmAPassenger.
  ///
  /// In ar, this message translates to:
  /// **'خوي (راكب)'**
  String get iAmAPassenger;

  /// No description provided for @passengerDescription.
  ///
  /// In ar, this message translates to:
  /// **'أبي مشوار على الطريق وبجوّ رايق'**
  String get passengerDescription;

  /// No description provided for @roleJuniorTitle.
  ///
  /// In ar, this message translates to:
  /// **'خاوي جونيور'**
  String get roleJuniorTitle;

  /// No description provided for @roleJuniorDescription.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير آمنة لعيالك'**
  String get roleJuniorDescription;

  /// No description provided for @homeGreeting.
  ///
  /// In ar, this message translates to:
  /// **'يا هلا يا خوي!'**
  String get homeGreeting;

  /// No description provided for @homeTitle.
  ///
  /// In ar, this message translates to:
  /// **'جاهز لمشوار يسهّل يومك؟'**
  String get homeTitle;

  /// No description provided for @searchForARide.
  ///
  /// In ar, this message translates to:
  /// **'دوّر لك مشوار'**
  String get searchForARide;

  /// No description provided for @kmShared.
  ///
  /// In ar, this message translates to:
  /// **'كم شاركت'**
  String get kmShared;

  /// No description provided for @co2Saved.
  ///
  /// In ar, this message translates to:
  /// **'كم وفّرنا CO₂'**
  String get co2Saved;

  /// No description provided for @points.
  ///
  /// In ar, this message translates to:
  /// **'نقاط'**
  String get points;

  /// No description provided for @peakHoursActive.
  ///
  /// In ar, this message translates to:
  /// **'وقت الذروة شغّال! 3x XP'**
  String get peakHoursActive;

  /// No description provided for @smartMatchAI.
  ///
  /// In ar, this message translates to:
  /// **'توافق ذكي سريع'**
  String get smartMatchAI;

  /// No description provided for @routeOverlap.
  ///
  /// In ar, this message translates to:
  /// **'تطابق المسار'**
  String get routeOverlap;

  /// No description provided for @from.
  ///
  /// In ar, this message translates to:
  /// **'من'**
  String get from;

  /// No description provided for @to.
  ///
  /// In ar, this message translates to:
  /// **'إلى'**
  String get to;

  /// No description provided for @now.
  ///
  /// In ar, this message translates to:
  /// **'الحين'**
  String get now;

  /// No description provided for @leaveAsap.
  ///
  /// In ar, this message translates to:
  /// **'تحرّك الحين'**
  String get leaveAsap;

  /// No description provided for @change.
  ///
  /// In ar, this message translates to:
  /// **'تغيير'**
  String get change;

  /// No description provided for @filters.
  ///
  /// In ar, this message translates to:
  /// **'فلترة'**
  String get filters;

  /// No description provided for @womenOnly.
  ///
  /// In ar, this message translates to:
  /// **'سيدات فقط'**
  String get womenOnly;

  /// No description provided for @kidsAllowed.
  ///
  /// In ar, this message translates to:
  /// **'مسموح بالأطفال'**
  String get kidsAllowed;

  /// No description provided for @sameNeighborhood.
  ///
  /// In ar, this message translates to:
  /// **'نفس الحي'**
  String get sameNeighborhood;

  /// No description provided for @noRideSelected.
  ///
  /// In ar, this message translates to:
  /// **'ما اخترت مشوار للحين.'**
  String get noRideSelected;

  /// No description provided for @back.
  ///
  /// In ar, this message translates to:
  /// **'رجوع'**
  String get back;

  /// No description provided for @eta.
  ///
  /// In ar, this message translates to:
  /// **'وصول'**
  String get eta;

  /// No description provided for @projectedXp.
  ///
  /// In ar, this message translates to:
  /// **'النقاط اللي بتكسبها'**
  String get projectedXp;

  /// No description provided for @peakHours.
  ///
  /// In ar, this message translates to:
  /// **'وقت ذروة!'**
  String get peakHours;

  /// No description provided for @xp.
  ///
  /// In ar, this message translates to:
  /// **'XP'**
  String get xp;

  /// No description provided for @rideNow.
  ///
  /// In ar, this message translates to:
  /// **'احجز الحين'**
  String get rideNow;

  /// No description provided for @noCurrentRide.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك مشوار حالياً.. يمديك تبدأ واحد.'**
  String get noCurrentRide;

  /// No description provided for @backToHome.
  ///
  /// In ar, this message translates to:
  /// **'رجوع للرئيسية'**
  String get backToHome;

  /// No description provided for @arrivingAt.
  ///
  /// In ar, this message translates to:
  /// **'الوصول'**
  String get arrivingAt;

  /// No description provided for @endTripForDemo.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء (تجريبي)'**
  String get endTripForDemo;

  /// No description provided for @noCompletedRide.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه مشاوير مكتملة.'**
  String get noCompletedRide;

  /// No description provided for @rideCompleted.
  ///
  /// In ar, this message translates to:
  /// **'تم المشوار!'**
  String get rideCompleted;

  /// No description provided for @postRideEarningsMessage.
  ///
  /// In ar, this message translates to:
  /// **'كسبت {xp} نقطة في هذا المشوار. شكرًا لاختيارك خاوي!'**
  String postRideEarningsMessage(String xp);

  /// No description provided for @rateYourRide.
  ///
  /// In ar, this message translates to:
  /// **'قيّم رحلتك'**
  String get rateYourRide;

  /// No description provided for @ratingThanks.
  ///
  /// In ar, this message translates to:
  /// **'شكرًا لتقييمك!'**
  String get ratingThanks;

  /// No description provided for @driverLabel.
  ///
  /// In ar, this message translates to:
  /// **'السائق'**
  String get driverLabel;

  /// No description provided for @youEarned.
  ///
  /// In ar, this message translates to:
  /// **'كسبت'**
  String get youEarned;

  /// No description provided for @rateDriver.
  ///
  /// In ar, this message translates to:
  /// **'قيم {name}'**
  String rateDriver(Object name);

  /// No description provided for @done.
  ///
  /// In ar, this message translates to:
  /// **'تم'**
  String get done;

  /// No description provided for @navHome.
  ///
  /// In ar, this message translates to:
  /// **'الرئيسية'**
  String get navHome;

  /// No description provided for @navActivity.
  ///
  /// In ar, this message translates to:
  /// **'نشاطي'**
  String get navActivity;

  /// No description provided for @navHub.
  ///
  /// In ar, this message translates to:
  /// **'المركز'**
  String get navHub;

  /// No description provided for @navTracking.
  ///
  /// In ar, this message translates to:
  /// **'التتبع'**
  String get navTracking;

  /// No description provided for @rewardDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل المكافأة'**
  String get rewardDetails;

  /// No description provided for @instantTripQrTitle.
  ///
  /// In ar, this message translates to:
  /// **'رمز الرحلة الفوري'**
  String get instantTripQrTitle;

  /// No description provided for @juniorTrackRuns.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الرحلات'**
  String get juniorTrackRuns;

  /// No description provided for @familyDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'سائق العائلة'**
  String get familyDriverTitle;

  /// No description provided for @newRegularRouteTitle.
  ///
  /// In ar, this message translates to:
  /// **'مسار اعتيادي جديد'**
  String get newRegularRouteTitle;

  /// No description provided for @navMore.
  ///
  /// In ar, this message translates to:
  /// **'المزيد'**
  String get navMore;

  /// No description provided for @navRewards.
  ///
  /// In ar, this message translates to:
  /// **'المكافآت'**
  String get navRewards;

  /// No description provided for @navProfile.
  ///
  /// In ar, this message translates to:
  /// **'حسابي'**
  String get navProfile;

  /// No description provided for @activityLog.
  ///
  /// In ar, this message translates to:
  /// **'سجل النشاط'**
  String get activityLog;

  /// No description provided for @tripHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل المشاوير'**
  String get tripHistory;

  /// No description provided for @pointsHistory.
  ///
  /// In ar, this message translates to:
  /// **'سجل النقاط'**
  String get pointsHistory;

  /// No description provided for @tripWith.
  ///
  /// In ar, this message translates to:
  /// **'مشوار مع {name}'**
  String tripWith(Object name);

  /// No description provided for @redeemedCoffee.
  ///
  /// In ar, this message translates to:
  /// **'استبدلت قهوة'**
  String get redeemedCoffee;

  /// No description provided for @friendReferralBonus.
  ///
  /// In ar, this message translates to:
  /// **'مكافأة دعوة صديق'**
  String get friendReferralBonus;

  /// No description provided for @driverRewards.
  ///
  /// In ar, this message translates to:
  /// **'مكافآت الكباتن'**
  String get driverRewards;

  /// No description provided for @rewardsAndLeaderboard.
  ///
  /// In ar, this message translates to:
  /// **'المكافآت والصدارة'**
  String get rewardsAndLeaderboard;

  /// No description provided for @yourLevel.
  ///
  /// In ar, this message translates to:
  /// **'مستواك'**
  String get yourLevel;

  /// No description provided for @availableRewards.
  ///
  /// In ar, this message translates to:
  /// **'وش تقدر تاخذ'**
  String get availableRewards;

  /// No description provided for @rewards.
  ///
  /// In ar, this message translates to:
  /// **'جوائز'**
  String get rewards;

  /// No description provided for @leaderboard.
  ///
  /// In ar, this message translates to:
  /// **'المتصدرين'**
  String get leaderboard;

  /// No description provided for @you.
  ///
  /// In ar, this message translates to:
  /// **'أنت'**
  String get you;

  /// No description provided for @editProfile.
  ///
  /// In ar, this message translates to:
  /// **'تعديل الملف'**
  String get editProfile;

  /// No description provided for @notifications.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات'**
  String get notifications;

  /// No description provided for @darkMode.
  ///
  /// In ar, this message translates to:
  /// **'الوضع الليلي'**
  String get darkMode;

  /// No description provided for @language.
  ///
  /// In ar, this message translates to:
  /// **'اللغة'**
  String get language;

  /// No description provided for @morePremiumSection.
  ///
  /// In ar, this message translates to:
  /// **'خاوي+'**
  String get morePremiumSection;

  /// No description provided for @moreAccountSettings.
  ///
  /// In ar, this message translates to:
  /// **'إعدادات الحساب'**
  String get moreAccountSettings;

  /// No description provided for @morePersonalInformation.
  ///
  /// In ar, this message translates to:
  /// **'المعلومات الشخصية'**
  String get morePersonalInformation;

  /// No description provided for @moreSwitchRole.
  ///
  /// In ar, this message translates to:
  /// **'تغيير الدور'**
  String get moreSwitchRole;

  /// No description provided for @moreXpLedgerPassengerOnly.
  ///
  /// In ar, this message translates to:
  /// **'سجل النقاط متاح للركاب فقط.'**
  String get moreXpLedgerPassengerOnly;

  /// No description provided for @moreGeneral.
  ///
  /// In ar, this message translates to:
  /// **'عام'**
  String get moreGeneral;

  /// No description provided for @moreHelpCenter.
  ///
  /// In ar, this message translates to:
  /// **'مركز المساعدة'**
  String get moreHelpCenter;

  /// No description provided for @moreInviteFriends.
  ///
  /// In ar, this message translates to:
  /// **'دعوة أصدقاء'**
  String get moreInviteFriends;

  /// No description provided for @moreAboutKhawi.
  ///
  /// In ar, this message translates to:
  /// **'حول خاوي'**
  String get moreAboutKhawi;

  /// No description provided for @moreUpgradeToPremium.
  ///
  /// In ar, this message translates to:
  /// **'اشترك في خاوي+'**
  String get moreUpgradeToPremium;

  /// No description provided for @morePremiumSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'افتح المكافآت ومضاعف نقاط 1.5x'**
  String get morePremiumSubtitle;

  /// No description provided for @moreComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'قريباً'**
  String get moreComingSoon;

  /// No description provided for @referralTitle.
  ///
  /// In ar, this message translates to:
  /// **'ادع خويك واكسب 300 نقطة!'**
  String get referralTitle;

  /// No description provided for @referralDescription.
  ///
  /// In ar, this message translates to:
  /// **'عط خويك الكود، واول ما يخلص اول مشوار بتجيك المكافأة.'**
  String get referralDescription;

  /// No description provided for @shareNow.
  ///
  /// In ar, this message translates to:
  /// **'انشر الكود'**
  String get shareNow;

  /// No description provided for @logout.
  ///
  /// In ar, this message translates to:
  /// **'تسجيل خروج'**
  String get logout;

  /// No description provided for @dashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحتي'**
  String get dashboard;

  /// No description provided for @welcomeCaptain.
  ///
  /// In ar, this message translates to:
  /// **'حياك يا كابتن!'**
  String get welcomeCaptain;

  /// No description provided for @kmThisWeek.
  ///
  /// In ar, this message translates to:
  /// **'كم هالأسبوع'**
  String get kmThisWeek;

  /// No description provided for @totalPoints.
  ///
  /// In ar, this message translates to:
  /// **'مجموع النقاط'**
  String get totalPoints;

  /// No description provided for @totalCo2Saved.
  ///
  /// In ar, this message translates to:
  /// **'توفير CO₂'**
  String get totalCo2Saved;

  /// No description provided for @smartTips.
  ///
  /// In ar, this message translates to:
  /// **'نصائح ذكية'**
  String get smartTips;

  /// No description provided for @peakAlertTitle.
  ///
  /// In ar, this message translates to:
  /// **'انتبه، زحمة!'**
  String get peakAlertTitle;

  /// No description provided for @peakAlertDescription.
  ///
  /// In ar, this message translates to:
  /// **'شكل طريق الملك فهد بيزحم بعد نص ساعة. استعد عشان تدبل نقاطك 3 مرات!'**
  String get peakAlertDescription;

  /// No description provided for @passengerRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الأخوياء'**
  String get passengerRequests;

  /// No description provided for @newRequestsCount.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا توجد طلبات} =1{طلب واحد جديد} =2{طلبان جديدان} few{{count} طلبات جديدة} many{{count} طلبًا جديدًا} other{{count} طلب جديد}}'**
  String newRequestsCount(int count);

  /// No description provided for @waitingForApproval.
  ///
  /// In ar, this message translates to:
  /// **'ينتظرون موافقتك'**
  String get waitingForApproval;

  /// No description provided for @navDashboard.
  ///
  /// In ar, this message translates to:
  /// **'لوحتي'**
  String get navDashboard;

  /// No description provided for @match.
  ///
  /// In ar, this message translates to:
  /// **'مطابقة'**
  String get match;

  /// No description provided for @accept.
  ///
  /// In ar, this message translates to:
  /// **'قبول'**
  String get accept;

  /// No description provided for @decline.
  ///
  /// In ar, this message translates to:
  /// **'رفض'**
  String get decline;

  /// No description provided for @currentPassenger.
  ///
  /// In ar, this message translates to:
  /// **'خويك الحالي'**
  String get currentPassenger;

  /// No description provided for @destination.
  ///
  /// In ar, this message translates to:
  /// **'الوجهة'**
  String get destination;

  /// No description provided for @endTrip.
  ///
  /// In ar, this message translates to:
  /// **'إنهاء'**
  String get endTrip;

  /// No description provided for @upgradeToKhawiPlus.
  ///
  /// In ar, this message translates to:
  /// **'رقّ حسابك لـ +Khawi'**
  String get upgradeToKhawiPlus;

  /// No description provided for @subscribeToKhawiPlus.
  ///
  /// In ar, this message translates to:
  /// **'اشترك في +Khawi'**
  String get subscribeToKhawiPlus;

  /// No description provided for @premiumTitle.
  ///
  /// In ar, this message translates to:
  /// **'مزايا حصرية لك'**
  String get premiumTitle;

  /// No description provided for @premiumSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وش بتستفيد؟'**
  String get premiumSubtitle;

  /// No description provided for @featureZeroCommissionTitle.
  ///
  /// In ar, this message translates to:
  /// **'صفر عمولة. دخلك لك 100%.'**
  String get featureZeroCommissionTitle;

  /// No description provided for @featureZeroCommissionDescription.
  ///
  /// In ar, this message translates to:
  /// **'ما ناخذ 20-25% زي غيرنا. رسم اشتراك بسيط (30 ريال) وكل دخلك في جيبك.'**
  String get featureZeroCommissionDescription;

  /// No description provided for @feature15xXpTitle.
  ///
  /// In ar, this message translates to:
  /// **'نقاطك تزيد مرة ونص'**
  String get feature15xXpTitle;

  /// No description provided for @feature15xXpDescription.
  ///
  /// In ar, this message translates to:
  /// **'تجمع نقاط أسرع مع كل مشوار.'**
  String get feature15xXpDescription;

  /// No description provided for @featurePriorityMatchingTitle.
  ///
  /// In ar, this message translates to:
  /// **'أولوية في الطلبات'**
  String get featurePriorityMatchingTitle;

  /// No description provided for @featurePriorityMatchingDescription.
  ///
  /// In ar, this message translates to:
  /// **'تجيك أفضل الطلبات اللي تناسب طريقك قبل غيرك.'**
  String get featurePriorityMatchingDescription;

  /// No description provided for @featureMonthlyRewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'بدل نقاطك بفلوس وهدايا'**
  String get featureMonthlyRewardsTitle;

  /// No description provided for @featureMonthlyRewardsDescription.
  ///
  /// In ar, this message translates to:
  /// **'الاستخدام بلاش، بس عشان تبدل النقاط بقهوة وبنزين، لازم تكون مشترك.'**
  String get featureMonthlyRewardsDescription;

  /// No description provided for @featurePremiumBadgeTitle.
  ///
  /// In ar, this message translates to:
  /// **'شارة +Khawi المميزة'**
  String get featurePremiumBadgeTitle;

  /// No description provided for @featurePremiumBadgeDescription.
  ///
  /// In ar, this message translates to:
  /// **'تميز بالشارة الذهبية في ملفك.'**
  String get featurePremiumBadgeDescription;

  /// No description provided for @sar.
  ///
  /// In ar, this message translates to:
  /// **'ريال'**
  String get sar;

  /// No description provided for @monthly.
  ///
  /// In ar, this message translates to:
  /// **'بالشهر'**
  String get monthly;

  /// No description provided for @subscribeNow.
  ///
  /// In ar, this message translates to:
  /// **'اشترك الحين'**
  String get subscribeNow;

  /// No description provided for @myBadges.
  ///
  /// In ar, this message translates to:
  /// **'شاراتي'**
  String get myBadges;

  /// No description provided for @zeroAccidents.
  ///
  /// In ar, this message translates to:
  /// **'سواقة نظيفة'**
  String get zeroAccidents;

  /// No description provided for @communityHero.
  ///
  /// In ar, this message translates to:
  /// **'بطل المجتمع'**
  String get communityHero;

  /// No description provided for @weeklyChallenges.
  ///
  /// In ar, this message translates to:
  /// **'تحديات الأسبوع'**
  String get weeklyChallenges;

  /// No description provided for @earnBonusXp.
  ///
  /// In ar, this message translates to:
  /// **'دبّل نقاطك!'**
  String get earnBonusXp;

  /// No description provided for @challenges.
  ///
  /// In ar, this message translates to:
  /// **'التحديات'**
  String get challenges;

  /// No description provided for @challengeComplete5Rides.
  ///
  /// In ar, this message translates to:
  /// **'خلص 5 مشاوير هالأسبوع'**
  String get challengeComplete5Rides;

  /// No description provided for @challengeShare100km.
  ///
  /// In ar, this message translates to:
  /// **'شارك طريقك لمسافة 100 كم'**
  String get challengeShare100km;

  /// No description provided for @challengePeakHourMaster.
  ///
  /// In ar, this message translates to:
  /// **'خلص 3 مشاوير وقت الذروة'**
  String get challengePeakHourMaster;

  /// No description provided for @xpBreakdown.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل النقاط'**
  String get xpBreakdown;

  /// No description provided for @basePoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاط المشوار'**
  String get basePoints;

  /// No description provided for @peakHourBonus.
  ///
  /// In ar, this message translates to:
  /// **'بوناس الذروة'**
  String get peakHourBonus;

  /// No description provided for @peakHourBonusExclamation.
  ///
  /// In ar, this message translates to:
  /// **'بوناس الذروة!'**
  String get peakHourBonusExclamation;

  /// No description provided for @passengerBonusDriver.
  ///
  /// In ar, this message translates to:
  /// **'بوناس الركاب'**
  String get passengerBonusDriver;

  /// No description provided for @passengerBonusPassenger.
  ///
  /// In ar, this message translates to:
  /// **'بوناس المجموعة'**
  String get passengerBonusPassenger;

  /// No description provided for @synergyBonus.
  ///
  /// In ar, this message translates to:
  /// **'بوناس الدوام'**
  String get synergyBonus;

  /// No description provided for @premiumBonus.
  ///
  /// In ar, this message translates to:
  /// **'بوناس اشتراكك'**
  String get premiumBonus;

  /// No description provided for @ratingBonus.
  ///
  /// In ar, this message translates to:
  /// **'بوناس التقييم'**
  String get ratingBonus;

  /// No description provided for @parentBonus.
  ///
  /// In ar, this message translates to:
  /// **'بوناس الأهل'**
  String get parentBonus;

  /// No description provided for @captain.
  ///
  /// In ar, this message translates to:
  /// **'كابتن'**
  String get captain;

  /// No description provided for @captainWithName.
  ///
  /// In ar, this message translates to:
  /// **'الكابتن {name}'**
  String captainWithName(String name);

  /// No description provided for @newDriver.
  ///
  /// In ar, this message translates to:
  /// **'كابتن جديد'**
  String get newDriver;

  /// No description provided for @incentiveActiveInArea.
  ///
  /// In ar, this message translates to:
  /// **'شغال في {area}: تدبيل {multiplier}x.'**
  String incentiveActiveInArea(String area, String multiplier);

  /// No description provided for @otherActiveZones.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =1{+منطقة نشطة أخرى} =2{+منطقتان نشطتان أخرى} few{+{count} مناطق نشطة أخرى} many{+{count} منطقة نشطة أخرى} other{+{count} منطقة نشطة أخرى}}'**
  String otherActiveZones(int count);

  /// No description provided for @stopLabelLine.
  ///
  /// In ar, this message translates to:
  /// **'{type}: {label}'**
  String stopLabelLine(String type, String label);

  /// No description provided for @passengerWithId.
  ///
  /// In ar, this message translates to:
  /// **'الخوي {id}'**
  String passengerWithId(String id);

  /// No description provided for @total.
  ///
  /// In ar, this message translates to:
  /// **'المجموع'**
  String get total;

  /// No description provided for @numberOfPassengers.
  ///
  /// In ar, this message translates to:
  /// **'عدد الركاب'**
  String get numberOfPassengers;

  /// No description provided for @setPassengerCapacity.
  ///
  /// In ar, this message translates to:
  /// **'كم تبي تشيل؟'**
  String get setPassengerCapacity;

  /// No description provided for @seats.
  ///
  /// In ar, this message translates to:
  /// **'مقاعد'**
  String get seats;

  /// No description provided for @redeemableXp.
  ///
  /// In ar, this message translates to:
  /// **'نقاط يمديك تبدلها'**
  String get redeemableXp;

  /// No description provided for @lockedXp.
  ///
  /// In ar, this message translates to:
  /// **'نقاط معلقة'**
  String get lockedXp;

  /// No description provided for @unlockYourXp.
  ///
  /// In ar, this message translates to:
  /// **'عندك {points} نقطة تنتظرك!'**
  String unlockYourXp(Object points);

  /// No description provided for @upgradeToUnlock.
  ///
  /// In ar, this message translates to:
  /// **'اشترك وفعلها الحين'**
  String get upgradeToUnlock;

  /// No description provided for @referralProgram.
  ///
  /// In ar, this message translates to:
  /// **'برنامج الدعوات'**
  String get referralProgram;

  /// No description provided for @yourReferralCode.
  ///
  /// In ar, this message translates to:
  /// **'كودك الخاص'**
  String get yourReferralCode;

  /// No description provided for @tapToCopy.
  ///
  /// In ar, this message translates to:
  /// **'اضغط للنسخ'**
  String get tapToCopy;

  /// No description provided for @shareYourCode.
  ///
  /// In ar, this message translates to:
  /// **'عطهم كودك'**
  String get shareYourCode;

  /// No description provided for @referralStatus.
  ///
  /// In ar, this message translates to:
  /// **'مين دعيت؟'**
  String get referralStatus;

  /// No description provided for @invited.
  ///
  /// In ar, this message translates to:
  /// **'دعوته'**
  String get invited;

  /// No description provided for @completed.
  ///
  /// In ar, this message translates to:
  /// **'خلص أول مشوار'**
  String get completed;

  /// No description provided for @notificationSettings.
  ///
  /// In ar, this message translates to:
  /// **'اعدادات التنبيهات'**
  String get notificationSettings;

  /// No description provided for @pushNotifications.
  ///
  /// In ar, this message translates to:
  /// **'التنبيهات'**
  String get pushNotifications;

  /// No description provided for @allowNotifications.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل التنبيهات'**
  String get allowNotifications;

  /// No description provided for @rideRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات المشاوير'**
  String get rideRequests;

  /// No description provided for @xpGains.
  ///
  /// In ar, this message translates to:
  /// **'نقط جتني'**
  String get xpGains;

  /// No description provided for @peakHourAlerts.
  ///
  /// In ar, this message translates to:
  /// **'تنبيهات الزحمة'**
  String get peakHourAlerts;

  /// No description provided for @appUpdates.
  ///
  /// In ar, this message translates to:
  /// **'تحديثات التطبيق'**
  String get appUpdates;

  /// No description provided for @open.
  ///
  /// In ar, this message translates to:
  /// **'فتح'**
  String get open;

  /// No description provided for @chooseYourRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'وش دورك؟'**
  String get chooseYourRoleTitle;

  /// No description provided for @roleSelectionWelcomeTitle.
  ///
  /// In ar, this message translates to:
  /// **'هلا بك! كيف تبي تستخدم خاوي؟'**
  String get roleSelectionWelcomeTitle;

  /// No description provided for @roleSelectionSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'يمديك تغير دورك بعدين من الملف الشخصي.'**
  String get roleSelectionSubtitle;

  /// No description provided for @shareYourRegularRoute.
  ///
  /// In ar, this message translates to:
  /// **'شارك طريقك اليومي'**
  String get shareYourRegularRoute;

  /// No description provided for @instantRideSheetDescription.
  ///
  /// In ar, this message translates to:
  /// **'امسح الباركود واركب، أو سو لك باركود'**
  String get instantRideSheetDescription;

  /// No description provided for @scanQr.
  ///
  /// In ar, this message translates to:
  /// **'امسح QR'**
  String get scanQr;

  /// No description provided for @createQr.
  ///
  /// In ar, this message translates to:
  /// **'سوي QR'**
  String get createQr;

  /// No description provided for @joinRide.
  ///
  /// In ar, this message translates to:
  /// **'اركب مع كابتن'**
  String get joinRide;

  /// No description provided for @shareRide.
  ///
  /// In ar, this message translates to:
  /// **'وصل أحد معك'**
  String get shareRide;

  /// No description provided for @rulesConsentText.
  ///
  /// In ar, this message translates to:
  /// **'ترا اذا كملت، يعني موافق تلتزم بهالقواعد.'**
  String get rulesConsentText;

  /// No description provided for @iAgreeContinue.
  ///
  /// In ar, this message translates to:
  /// **'موافق ونكمل'**
  String get iAgreeContinue;

  /// No description provided for @errorWithMessage.
  ///
  /// In ar, this message translates to:
  /// **'خطأ: {message}'**
  String errorWithMessage(String message);

  /// No description provided for @khawiPremium.
  ///
  /// In ar, this message translates to:
  /// **'خاوي+'**
  String get khawiPremium;

  /// No description provided for @acceptInstantRides.
  ///
  /// In ar, this message translates to:
  /// **'استقبل فوري'**
  String get acceptInstantRides;

  /// No description provided for @acceptInstantRidesDescription.
  ///
  /// In ar, this message translates to:
  /// **'استقبل طلبات من ناس حولك يبون مشوار الحين.'**
  String get acceptInstantRidesDescription;

  /// No description provided for @goOnline.
  ///
  /// In ar, this message translates to:
  /// **'اتصل الآن'**
  String get goOnline;

  /// No description provided for @howItWorks.
  ///
  /// In ar, this message translates to:
  /// **'كيف الطريقة؟'**
  String get howItWorks;

  /// No description provided for @instantRideStep1.
  ///
  /// In ar, this message translates to:
  /// **'خلك متصل عشان تجيك الطلبات.'**
  String get instantRideStep1;

  /// No description provided for @instantRideStep2.
  ///
  /// In ar, this message translates to:
  /// **'عندك 30 ثانية لجمال عيونك تقبل الطلب.'**
  String get instantRideStep2;

  /// No description provided for @instantRideStep3.
  ///
  /// In ar, this message translates to:
  /// **'اتبع الخريطة لموقع خويك.'**
  String get instantRideStep3;

  /// No description provided for @confirmSchedule.
  ///
  /// In ar, this message translates to:
  /// **'تأكيد الجدول'**
  String get confirmSchedule;

  /// No description provided for @suggestedRoutes.
  ///
  /// In ar, this message translates to:
  /// **'مسارات مقترحة'**
  String get suggestedRoutes;

  /// No description provided for @optimalStartTime.
  ///
  /// In ar, this message translates to:
  /// **'أفضل وقت تحرك'**
  String get optimalStartTime;

  /// No description provided for @optimalStartTimeDescription.
  ///
  /// In ar, this message translates to:
  /// **'اطلع الساعة {time} وتفادى الزحمة ودبّل نقاطك {percent}%.'**
  String optimalStartTimeDescription(String time, String percent);

  /// No description provided for @highDemandAreas.
  ///
  /// In ar, this message translates to:
  /// **'مناطق شابة نار'**
  String get highDemandAreas;

  /// No description provided for @highDemandAreasDescription.
  ///
  /// In ar, this message translates to:
  /// **'{count, plural, =0{لا يوجد ركاب بالقرب من {area}} =1{راكب واحد بالقرب من {area}} =2{راكبان بالقرب من {area}} few{{count} ركاب بالقرب من {area}} many{{count} راكباً بالقرب من {area}} other{{count} راكب بالقرب من {area}}}. مضاعف +{multiplier}x مفعل.'**
  String highDemandAreasDescription(int count, String area, String multiplier);

  /// No description provided for @homeToOffice.
  ///
  /// In ar, this message translates to:
  /// **'من البيت للدوام'**
  String get homeToOffice;

  /// No description provided for @universityRun.
  ///
  /// In ar, this message translates to:
  /// **'مشوار الجامعة'**
  String get universityRun;

  /// No description provided for @highMatchProbability.
  ///
  /// In ar, this message translates to:
  /// **'احتمالية تلقى أحد عالية'**
  String get highMatchProbability;

  /// No description provided for @mediumTraffic.
  ///
  /// In ar, this message translates to:
  /// **'زحمة خفيفة'**
  String get mediumTraffic;

  /// No description provided for @aiRoutePlanner.
  ///
  /// In ar, this message translates to:
  /// **'مخطط الرحلات الذكي'**
  String get aiRoutePlanner;

  /// No description provided for @aiRoutePlannerTitle.
  ///
  /// In ar, this message translates to:
  /// **'المخطط الذكي'**
  String get aiRoutePlannerTitle;

  /// No description provided for @aiRoutePlannerDescription.
  ///
  /// In ar, this message translates to:
  /// **'خطط يومك بذكاء'**
  String get aiRoutePlannerDescription;

  /// No description provided for @planYourCommute.
  ///
  /// In ar, this message translates to:
  /// **'خطط مشوارك اليومي'**
  String get planYourCommute;

  /// No description provided for @workLocation.
  ///
  /// In ar, this message translates to:
  /// **'مقر العمل'**
  String get workLocation;

  /// No description provided for @homeLocation.
  ///
  /// In ar, this message translates to:
  /// **'موقع البيت'**
  String get homeLocation;

  /// No description provided for @analyzeMyRoute.
  ///
  /// In ar, this message translates to:
  /// **'شف لي حل للمسار'**
  String get analyzeMyRoute;

  /// No description provided for @aiAnalysis.
  ///
  /// In ar, this message translates to:
  /// **'الذكاء الاصطناعي يفكر...'**
  String get aiAnalysis;

  /// No description provided for @aiPlanTitle.
  ///
  /// In ar, this message translates to:
  /// **'خطتك الذكية'**
  String get aiPlanTitle;

  /// No description provided for @aiPlanDescription.
  ///
  /// In ar, this message translates to:
  /// **'شفنا مسارك، وهذي نصايح عشان تزيد نقاطك وتفتك من الزحمة:'**
  String get aiPlanDescription;

  /// No description provided for @optimalDeparture.
  ///
  /// In ar, this message translates to:
  /// **'أحسن وقت تمشي'**
  String get optimalDeparture;

  /// No description provided for @highDemandZones.
  ///
  /// In ar, this message translates to:
  /// **'مناطق زحمة وطلب'**
  String get highDemandZones;

  /// No description provided for @keepRidingToNextReward.
  ///
  /// In ar, this message translates to:
  /// **'كمل مشاوير عشان توصل للمكافأة الجاية!'**
  String get keepRidingToNextReward;

  /// No description provided for @earnXPForRide.
  ///
  /// In ar, this message translates to:
  /// **'اركب واكسب {points} نقطة لكل مشوار!'**
  String earnXPForRide(Object points);

  /// No description provided for @rideWith.
  ///
  /// In ar, this message translates to:
  /// **'خاوِه'**
  String get rideWith;

  /// No description provided for @cancel.
  ///
  /// In ar, this message translates to:
  /// **'كنسل'**
  String get cancel;

  /// No description provided for @yes.
  ///
  /// In ar, this message translates to:
  /// **'ايه'**
  String get yes;

  /// No description provided for @no.
  ///
  /// In ar, this message translates to:
  /// **'لا'**
  String get no;

  /// No description provided for @passengerEncouragementTitle.
  ///
  /// In ar, this message translates to:
  /// **'تفكر تسوق؟'**
  String get passengerEncouragementTitle;

  /// No description provided for @passengerEncouragementBody.
  ///
  /// In ar, this message translates to:
  /// **'ترا بما عندك سيارة، يمديك تكسب دبل النقاط كسائق في هالمشوار!'**
  String get passengerEncouragementBody;

  /// No description provided for @viewDriverBenefits.
  ///
  /// In ar, this message translates to:
  /// **'وش يستفيد الكابتن؟'**
  String get viewDriverBenefits;

  /// No description provided for @myRegularTrips.
  ///
  /// In ar, this message translates to:
  /// **'مشاويري الثابتة'**
  String get myRegularTrips;

  /// No description provided for @manageRegularTrips.
  ///
  /// In ar, this message translates to:
  /// **'رتب مشاويرك اليومية واكسب نقاط بانتظام'**
  String get manageRegularTrips;

  /// No description provided for @noRegularTrips.
  ///
  /// In ar, this message translates to:
  /// **'ما حطيت مشاوير ثابتة لسا.'**
  String get noRegularTrips;

  /// No description provided for @addNewRoute.
  ///
  /// In ar, this message translates to:
  /// **'ضيف مسار جديد'**
  String get addNewRoute;

  /// No description provided for @setRegularRoute.
  ///
  /// In ar, this message translates to:
  /// **'ضبط مسار ثابت'**
  String get setRegularRoute;

  /// No description provided for @routeDetails.
  ///
  /// In ar, this message translates to:
  /// **'تفاصيل الطريق'**
  String get routeDetails;

  /// No description provided for @travelDays.
  ///
  /// In ar, this message translates to:
  /// **'الأيام'**
  String get travelDays;

  /// No description provided for @travelTime.
  ///
  /// In ar, this message translates to:
  /// **'الوقت'**
  String get travelTime;

  /// No description provided for @saveRoute.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveRoute;

  /// No description provided for @haveACode.
  ///
  /// In ar, this message translates to:
  /// **'عندك كود؟'**
  String get haveACode;

  /// No description provided for @redeemItHere.
  ///
  /// In ar, this message translates to:
  /// **'حطه هنا وهات النقاط!'**
  String get redeemItHere;

  /// No description provided for @redeemCode.
  ///
  /// In ar, this message translates to:
  /// **'تفعيل الكود'**
  String get redeemCode;

  /// No description provided for @enterYourCode.
  ///
  /// In ar, this message translates to:
  /// **'حط كود الهدية هنا'**
  String get enterYourCode;

  /// No description provided for @codePlaceholder.
  ///
  /// In ar, this message translates to:
  /// **'مثال: RAMADAN2024'**
  String get codePlaceholder;

  /// No description provided for @redeem.
  ///
  /// In ar, this message translates to:
  /// **'فعل'**
  String get redeem;

  /// No description provided for @codeRedeemedSuccess.
  ///
  /// In ar, this message translates to:
  /// **'تفعل الكود يا وحش!'**
  String get codeRedeemedSuccess;

  /// No description provided for @youReceivedPoints.
  ///
  /// In ar, this message translates to:
  /// **'جاك {points} نقطة!'**
  String youReceivedPoints(Object points);

  /// No description provided for @redeemReward.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get redeemReward;

  /// No description provided for @confirmRedemption.
  ///
  /// In ar, this message translates to:
  /// **'متأكد تبي تستبدل؟'**
  String get confirmRedemption;

  /// No description provided for @notEnoughPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاطك ما تكفي'**
  String get notEnoughPoints;

  /// No description provided for @redemptionSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'تم الاستبدال! عليك بالعافية.'**
  String get redemptionSuccessful;

  /// No description provided for @yourVoucherCode.
  ///
  /// In ar, this message translates to:
  /// **'هذا كود الخصم:'**
  String get yourVoucherCode;

  /// No description provided for @cost.
  ///
  /// In ar, this message translates to:
  /// **'التكلفة'**
  String get cost;

  /// No description provided for @khawiJuniorTitle.
  ///
  /// In ar, this message translates to:
  /// **'خاوي جونيور'**
  String get khawiJuniorTitle;

  /// No description provided for @khawiJuniorDescription.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير آمنة لعيالك.'**
  String get khawiJuniorDescription;

  /// No description provided for @khawiJuniorWelcome.
  ///
  /// In ar, this message translates to:
  /// **'هلا فيك بخاوي جونيور'**
  String get khawiJuniorWelcome;

  /// No description provided for @khawiJuniorDisclaimer.
  ///
  /// In ar, this message translates to:
  /// **'هالخدمة قايمة على الثقة. احنا نوفر المنصة، بس المسؤولية الأولى على الأهل والكباتن. تكفون انتبهوا واستخدموها صح.'**
  String get khawiJuniorDisclaimer;

  /// No description provided for @safetyFirst.
  ///
  /// In ar, this message translates to:
  /// **'السلامة أول شي'**
  String get safetyFirst;

  /// No description provided for @parentSafetyInstruction1.
  ///
  /// In ar, this message translates to:
  /// **'شيك على هوية الكابتن وسيارتة قبل يركب طفلك.'**
  String get parentSafetyInstruction1;

  /// No description provided for @parentSafetyInstruction2.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الكابتن وتأكد من تفاصيل المشوار.'**
  String get parentSafetyInstruction2;

  /// No description provided for @parentSafetyInstruction3.
  ///
  /// In ar, this message translates to:
  /// **'تابع المشوار لايف وشاركه مع الأهل.'**
  String get parentSafetyInstruction3;

  /// No description provided for @parentSafetyInstruction4.
  ///
  /// In ar, this message translates to:
  /// **'علم طفلك كيف ينتبه لنفسه وهو راكب.'**
  String get parentSafetyInstruction4;

  /// No description provided for @guardianDriverSafetyInstruction1.
  ///
  /// In ar, this message translates to:
  /// **'سواقتك الهادية والنظامية هي أهم شي.'**
  String get guardianDriverSafetyInstruction1;

  /// No description provided for @guardianDriverSafetyInstruction2.
  ///
  /// In ar, this message translates to:
  /// **'تأكد ان كراسي الأطفال موجودة ومربوطة صح.'**
  String get guardianDriverSafetyInstruction2;

  /// No description provided for @guardianDriverSafetyInstruction3.
  ///
  /// In ar, this message translates to:
  /// **'لا تمشي لين تتأكد من هوية الطفل ووين رايح.'**
  String get guardianDriverSafetyInstruction3;

  /// No description provided for @guardianDriverSafetyInstruction4.
  ///
  /// In ar, this message translates to:
  /// **'خلك على تواصل مع الأهل دايم.'**
  String get guardianDriverSafetyInstruction4;

  /// No description provided for @iUnderstandAndAgree.
  ///
  /// In ar, this message translates to:
  /// **'فهمت وموافق'**
  String get iUnderstandAndAgree;

  /// No description provided for @chooseYourRole.
  ///
  /// In ar, this message translates to:
  /// **'وش دورك في خاوي جونيور؟'**
  String get chooseYourRole;

  /// No description provided for @imAParent.
  ///
  /// In ar, this message translates to:
  /// **'أنا ولي أمر'**
  String get imAParent;

  /// No description provided for @imAParentDescription.
  ///
  /// In ar, this message translates to:
  /// **'أبي أرتب مشوار لطفلي.'**
  String get imAParentDescription;

  /// No description provided for @imAGuardianDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائقة (أم)'**
  String get imAGuardianDriver;

  /// No description provided for @imAGuardianDriverDescription.
  ///
  /// In ar, this message translates to:
  /// **'بوصل عيالي ويمديني أوصل غيرهم.'**
  String get imAGuardianDriverDescription;

  /// No description provided for @imAFamilyDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائق خاص'**
  String get imAFamilyDriver;

  /// No description provided for @imAFamilyDriverDescription.
  ///
  /// In ar, this message translates to:
  /// **'عندي دعوة من ولي أمر.'**
  String get imAFamilyDriverDescription;

  /// No description provided for @noDriverInviteMessage.
  ///
  /// In ar, this message translates to:
  /// **'ما عندك ملف. خل المعزب يدعوك أول.'**
  String get noDriverInviteMessage;

  /// No description provided for @guardianDriverIneligible.
  ///
  /// In ar, this message translates to:
  /// **'عذراً، هالميزة بس للأمهات المسجلات كسائقات عشان الأمان.'**
  String get guardianDriverIneligible;

  /// No description provided for @juniorHubParentTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير العيال'**
  String get juniorHubParentTitle;

  /// No description provided for @juniorHubDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'كاربول العيال'**
  String get juniorHubDriverTitle;

  /// No description provided for @currentTrip.
  ///
  /// In ar, this message translates to:
  /// **'المشوار الحالي'**
  String get currentTrip;

  /// No description provided for @trackRide.
  ///
  /// In ar, this message translates to:
  /// **'تتبع المشوار'**
  String get trackRide;

  /// No description provided for @myChildren.
  ///
  /// In ar, this message translates to:
  /// **'عيالي'**
  String get myChildren;

  /// No description provided for @addChild.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طفل'**
  String get addChild;

  /// No description provided for @scheduleNewRide.
  ///
  /// In ar, this message translates to:
  /// **'حجز مشوار جديد'**
  String get scheduleNewRide;

  /// No description provided for @enRouteToSchool.
  ///
  /// In ar, this message translates to:
  /// **'رايحين للمدرسة'**
  String get enRouteToSchool;

  /// No description provided for @arrivedAtSchool.
  ///
  /// In ar, this message translates to:
  /// **'وصلوا للمدرسة'**
  String get arrivedAtSchool;

  /// No description provided for @enRouteHome.
  ///
  /// In ar, this message translates to:
  /// **'راجعين للبيت'**
  String get enRouteHome;

  /// No description provided for @arrivedHome.
  ///
  /// In ar, this message translates to:
  /// **'وصلوا البيت'**
  String get arrivedHome;

  /// No description provided for @notificationArrivedAtSchool.
  ///
  /// In ar, this message translates to:
  /// **'وصل {name} للمدرسة بالسلامة! جاك 50 نقطة يا بطل!'**
  String notificationArrivedAtSchool(Object name);

  /// No description provided for @notificationArrivedHome.
  ///
  /// In ar, this message translates to:
  /// **'قرت عينك! وصل {name} للبيت. 50 نقطة مكافأة لك!'**
  String notificationArrivedHome(Object name);

  /// No description provided for @yourChild.
  ///
  /// In ar, this message translates to:
  /// **'طفلك'**
  String get yourChild;

  /// No description provided for @incomingRequests.
  ///
  /// In ar, this message translates to:
  /// **'طلبات الدخول'**
  String get incomingRequests;

  /// No description provided for @manageYourRoute.
  ///
  /// In ar, this message translates to:
  /// **'إدارة المسار'**
  String get manageYourRoute;

  /// No description provided for @guardianDriverNotice.
  ///
  /// In ar, this message translates to:
  /// **'ملاحظة: ما يمديك تقبلين إلا أطفال من نفس مدرسة عيالك.'**
  String get guardianDriverNotice;

  /// No description provided for @kidsRideHubEncouragement.
  ///
  /// In ar, this message translates to:
  /// **'كل مشوار تشاركينه هو فزعة ومساهمة حلوة!'**
  String get kidsRideHubEncouragement;

  /// No description provided for @kidsRewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'مكافآت {name}'**
  String kidsRewardsTitle(Object name);

  /// No description provided for @kidsRewardEncouragement.
  ///
  /// In ar, this message translates to:
  /// **'كفو! بدل نقاطك بهدايا تونس.'**
  String get kidsRewardEncouragement;

  /// No description provided for @rewardToyCar.
  ///
  /// In ar, this message translates to:
  /// **'سيارة لعبة'**
  String get rewardToyCar;

  /// No description provided for @rewardIceCream.
  ///
  /// In ar, this message translates to:
  /// **'آيس كريم'**
  String get rewardIceCream;

  /// No description provided for @rewardBookVoucher.
  ///
  /// In ar, this message translates to:
  /// **'قسيمة مكتبة'**
  String get rewardBookVoucher;

  /// No description provided for @kidsRedeemReward.
  ///
  /// In ar, this message translates to:
  /// **'استبدال الهدية'**
  String get kidsRedeemReward;

  /// No description provided for @kidsRedemptionSuccessful.
  ///
  /// In ar, this message translates to:
  /// **'يا سلام! جتك الهدية.'**
  String get kidsRedemptionSuccessful;

  /// No description provided for @scheduleRideComingSoon.
  ///
  /// In ar, this message translates to:
  /// **'الحجوزات جاية قريب!'**
  String get scheduleRideComingSoon;

  /// No description provided for @trackingRideTitle.
  ///
  /// In ar, this message translates to:
  /// **'وينهم الحين؟'**
  String get trackingRideTitle;

  /// No description provided for @driver.
  ///
  /// In ar, this message translates to:
  /// **'الكابتن'**
  String get driver;

  /// No description provided for @myDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائقي الخاص'**
  String get myDriver;

  /// No description provided for @addYourDriver.
  ///
  /// In ar, this message translates to:
  /// **'أضف سائقك'**
  String get addYourDriver;

  /// No description provided for @driverDetailsPrompt.
  ///
  /// In ar, this message translates to:
  /// **'حط بيانات السائق عشان تتبع مشاويره.'**
  String get driverDetailsPrompt;

  /// No description provided for @addDriverScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'إضافة السائق'**
  String get addDriverScreenTitle;

  /// No description provided for @driverName.
  ///
  /// In ar, this message translates to:
  /// **'اسم السائق'**
  String get driverName;

  /// No description provided for @driverPhone.
  ///
  /// In ar, this message translates to:
  /// **'جوال السائق'**
  String get driverPhone;

  /// No description provided for @saveDriver.
  ///
  /// In ar, this message translates to:
  /// **'حفظ'**
  String get saveDriver;

  /// No description provided for @appointedDriverDashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة السائق الخاص'**
  String get appointedDriverDashboardTitle;

  /// No description provided for @yourTotalPoints.
  ///
  /// In ar, this message translates to:
  /// **'نقاطك'**
  String get yourTotalPoints;

  /// No description provided for @currentTripFor.
  ///
  /// In ar, this message translates to:
  /// **'مشوار لـ'**
  String get currentTripFor;

  /// No description provided for @guardianDriverPointsNotice.
  ///
  /// In ar, this message translates to:
  /// **'تذكير: وأنتم بالسيارة، كلكم تكسبون نقاط سوا!'**
  String get guardianDriverPointsNotice;

  /// No description provided for @manageMyDriver.
  ///
  /// In ar, this message translates to:
  /// **'إدارة السائق'**
  String get manageMyDriver;

  /// No description provided for @inviteYourDriver.
  ///
  /// In ar, this message translates to:
  /// **'اعزم سائقك'**
  String get inviteYourDriver;

  /// No description provided for @inviteDriverPrompt.
  ///
  /// In ar, this message translates to:
  /// **'سوي ملف لسائقك عشان يجمع نقاط وتتابعه.'**
  String get inviteDriverPrompt;

  /// No description provided for @sendInvitation.
  ///
  /// In ar, this message translates to:
  /// **'أرسل الدعوة'**
  String get sendInvitation;

  /// No description provided for @todaysSchedule.
  ///
  /// In ar, this message translates to:
  /// **'جدول اليوم'**
  String get todaysSchedule;

  /// No description provided for @startTrip.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ'**
  String get startTrip;

  /// No description provided for @callParent.
  ///
  /// In ar, this message translates to:
  /// **'كلم الأهل'**
  String get callParent;

  /// No description provided for @tripToSchool.
  ///
  /// In ar, this message translates to:
  /// **'مشوار المدرسة'**
  String get tripToSchool;

  /// No description provided for @tripHome.
  ///
  /// In ar, this message translates to:
  /// **'الرجعة للبيت'**
  String get tripHome;

  /// No description provided for @switchToDriverView.
  ///
  /// In ar, this message translates to:
  /// **'واجهة السائق (تجربة)'**
  String get switchToDriverView;

  /// No description provided for @switchToParentView.
  ///
  /// In ar, this message translates to:
  /// **'واجهة ولي الأمر'**
  String get switchToParentView;

  /// No description provided for @startInstantTrip.
  ///
  /// In ar, this message translates to:
  /// **'ابدأ مشوار فوري'**
  String get startInstantTrip;

  /// No description provided for @instantTripDescription.
  ///
  /// In ar, this message translates to:
  /// **'للمشاوير السريعة مع الربع'**
  String get instantTripDescription;

  /// No description provided for @scanToJoin.
  ///
  /// In ar, this message translates to:
  /// **'امسح واركب'**
  String get scanToJoin;

  /// No description provided for @instantTripTitle.
  ///
  /// In ar, this message translates to:
  /// **'مشوار فوري'**
  String get instantTripTitle;

  /// No description provided for @showQrToPassengers.
  ///
  /// In ar, this message translates to:
  /// **'ورهم الكود عشان يركبون معك:'**
  String get showQrToPassengers;

  /// No description provided for @passengersJoined.
  ///
  /// In ar, this message translates to:
  /// **'اللي ركبوا'**
  String get passengersJoined;

  /// No description provided for @startTheTrip.
  ///
  /// In ar, this message translates to:
  /// **'توكلنا على الله'**
  String get startTheTrip;

  /// No description provided for @scanInstructions.
  ///
  /// In ar, this message translates to:
  /// **'امسح كود الكابتن واركب علطول'**
  String get scanInstructions;

  /// No description provided for @simulatedScan.
  ///
  /// In ar, this message translates to:
  /// **'تجربة المسح'**
  String get simulatedScan;

  /// No description provided for @whereTo.
  ///
  /// In ar, this message translates to:
  /// **'وين رايحين؟'**
  String get whereTo;

  /// No description provided for @smartMatchTitle.
  ///
  /// In ar, this message translates to:
  /// **'توصيل ذكي'**
  String get smartMatchTitle;

  /// No description provided for @instantRide.
  ///
  /// In ar, this message translates to:
  /// **'فوري'**
  String get instantRide;

  /// No description provided for @scheduleTrip.
  ///
  /// In ar, this message translates to:
  /// **'حجز'**
  String get scheduleTrip;

  /// No description provided for @findingMatch.
  ///
  /// In ar, this message translates to:
  /// **'ندور لك خوي...'**
  String get findingMatch;

  /// No description provided for @receivingRequests.
  ///
  /// In ar, this message translates to:
  /// **'نستقبل الطلبات...'**
  String get receivingRequests;

  /// No description provided for @goOnlineToEarn.
  ///
  /// In ar, this message translates to:
  /// **'اتصل وابدأ جمع النقاط'**
  String get goOnlineToEarn;

  /// No description provided for @todaysEarnings.
  ///
  /// In ar, this message translates to:
  /// **'صيد اليوم (XP)'**
  String get todaysEarnings;

  /// No description provided for @ridesToday.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير اليوم'**
  String get ridesToday;

  /// No description provided for @juniorHubTitle.
  ///
  /// In ar, this message translates to:
  /// **'مركز الصغار'**
  String get juniorHubTitle;

  /// No description provided for @safeStatus.
  ///
  /// In ar, this message translates to:
  /// **'وضعك بالسليم!'**
  String get safeStatus;

  /// No description provided for @rideInProgress.
  ///
  /// In ar, this message translates to:
  /// **'المشوار شغال'**
  String get rideInProgress;

  /// No description provided for @noActiveRide.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه مشوار الحين'**
  String get noActiveRide;

  /// No description provided for @requestRide.
  ///
  /// In ar, this message translates to:
  /// **'اطلب مشوار'**
  String get requestRide;

  /// No description provided for @playGames.
  ///
  /// In ar, this message translates to:
  /// **'لعب'**
  String get playGames;

  /// No description provided for @yourRewards.
  ///
  /// In ar, this message translates to:
  /// **'هداياك'**
  String get yourRewards;

  /// No description provided for @simulateRide.
  ///
  /// In ar, this message translates to:
  /// **'تخيل مشوار مدرسة'**
  String get simulateRide;

  /// No description provided for @safetyRulesTitle.
  ///
  /// In ar, this message translates to:
  /// **'أهم شي السلامة!'**
  String get safetyRulesTitle;

  /// No description provided for @safetyDescription.
  ///
  /// In ar, this message translates to:
  /// **'خلك ذيب وانتبه لهالقواعد:'**
  String get safetyDescription;

  /// No description provided for @safetyRule1.
  ///
  /// In ar, this message translates to:
  /// **'الحزام، ثم الحزام'**
  String get safetyRule1;

  /// No description provided for @safetyRule2.
  ///
  /// In ar, this message translates to:
  /// **'لا تسولف مع غرباء'**
  String get safetyRule2;

  /// No description provided for @safetyRule3.
  ///
  /// In ar, this message translates to:
  /// **'كلم أهلك لو حسيت بشي غلط'**
  String get safetyRule3;

  /// No description provided for @iUnderstand.
  ///
  /// In ar, this message translates to:
  /// **'فهمت يا كابتن'**
  String get iUnderstand;

  /// No description provided for @profileTitle.
  ///
  /// In ar, this message translates to:
  /// **'ملفي'**
  String get profileTitle;

  /// No description provided for @helpSupport.
  ///
  /// In ar, this message translates to:
  /// **'المساعدة'**
  String get helpSupport;

  /// No description provided for @xpLedgerTitle.
  ///
  /// In ar, this message translates to:
  /// **'سجل النقاط'**
  String get xpLedgerTitle;

  /// No description provided for @currentBalance.
  ///
  /// In ar, this message translates to:
  /// **'رصيدك'**
  String get currentBalance;

  /// No description provided for @addFunds.
  ///
  /// In ar, this message translates to:
  /// **'شحن'**
  String get addFunds;

  /// No description provided for @rewardsTitle.
  ///
  /// In ar, this message translates to:
  /// **'المكافآت'**
  String get rewardsTitle;

  /// No description provided for @yourXP.
  ///
  /// In ar, this message translates to:
  /// **'نقاطك'**
  String get yourXP;

  /// No description provided for @redeemRewards.
  ///
  /// In ar, this message translates to:
  /// **'استبدال'**
  String get redeemRewards;

  /// No description provided for @sundayShort.
  ///
  /// In ar, this message translates to:
  /// **'ح'**
  String get sundayShort;

  /// No description provided for @mondayShort.
  ///
  /// In ar, this message translates to:
  /// **'ن'**
  String get mondayShort;

  /// No description provided for @tuesdayShort.
  ///
  /// In ar, this message translates to:
  /// **'ث'**
  String get tuesdayShort;

  /// No description provided for @wednesdayShort.
  ///
  /// In ar, this message translates to:
  /// **'ر'**
  String get wednesdayShort;

  /// No description provided for @thursdayShort.
  ///
  /// In ar, this message translates to:
  /// **'خ'**
  String get thursdayShort;

  /// No description provided for @kidsCarpoolTitle.
  ///
  /// In ar, this message translates to:
  /// **'توصيل الصغار'**
  String get kidsCarpoolTitle;

  /// No description provided for @myCircles.
  ///
  /// In ar, this message translates to:
  /// **'قروباتي'**
  String get myCircles;

  /// No description provided for @findPools.
  ///
  /// In ar, this message translates to:
  /// **'دور قروب'**
  String get findPools;

  /// No description provided for @createCircle.
  ///
  /// In ar, this message translates to:
  /// **'سوي قروب'**
  String get createCircle;

  /// No description provided for @noCirclesJoined.
  ///
  /// In ar, this message translates to:
  /// **'ما دخلت قروب لسا'**
  String get noCirclesJoined;

  /// No description provided for @members.
  ///
  /// In ar, this message translates to:
  /// **'الأعضاء'**
  String get members;

  /// No description provided for @viewDetails.
  ///
  /// In ar, this message translates to:
  /// **'التفاصيل'**
  String get viewDetails;

  /// No description provided for @searchNearbyPools.
  ///
  /// In ar, this message translates to:
  /// **'شوف القروبات اللي حولك'**
  String get searchNearbyPools;

  /// No description provided for @enterSchoolOrClub.
  ///
  /// In ar, this message translates to:
  /// **'اسم المدرسة أو النادي'**
  String get enterSchoolOrClub;

  /// No description provided for @invitationSent.
  ///
  /// In ar, this message translates to:
  /// **'أرسلنا الدعوة!'**
  String get invitationSent;

  /// No description provided for @fillAllFields.
  ///
  /// In ar, this message translates to:
  /// **'عب كل الخانات لاهنت'**
  String get fillAllFields;

  /// No description provided for @continueText.
  ///
  /// In ar, this message translates to:
  /// **'كمل'**
  String get continueText;

  /// No description provided for @driverRoleRequiredTitle.
  ///
  /// In ar, this message translates to:
  /// **'لازم تكون كابتن'**
  String get driverRoleRequiredTitle;

  /// No description provided for @driverRoleRequiredMessage.
  ///
  /// In ar, this message translates to:
  /// **'عشان تسوي باركود، لازم تكون كابتن موثق. حول دورك لـ \"كابتن\" وكمل.'**
  String get driverRoleRequiredMessage;

  /// No description provided for @passengerConductTitle.
  ///
  /// In ar, this message translates to:
  /// **'قوانين الركاب'**
  String get passengerConductTitle;

  /// No description provided for @driverConductTitle.
  ///
  /// In ar, this message translates to:
  /// **'قوانين الكباتن'**
  String get driverConductTitle;

  /// No description provided for @juniorSafetyTitle.
  ///
  /// In ar, this message translates to:
  /// **'قوانين خاوي جونيور'**
  String get juniorSafetyTitle;

  /// No description provided for @passengerRule1.
  ///
  /// In ar, this message translates to:
  /// **'خلك على الوقت ومحترم.'**
  String get passengerRule1;

  /// No description provided for @passengerRule2.
  ///
  /// In ar, this message translates to:
  /// **'تأكد من كل شي قبل تركب.'**
  String get passengerRule2;

  /// No description provided for @zeroToleranceRule.
  ///
  /// In ar, this message translates to:
  /// **'ما عندنا تفاهم مع قلة الأدب أو التحرش.'**
  String get zeroToleranceRule;

  /// No description provided for @driverRule1.
  ///
  /// In ar, this message translates to:
  /// **'هذي فزعة مجتمعية (توصيلة مو تاكسي).'**
  String get driverRule1;

  /// No description provided for @driverRule2.
  ///
  /// In ar, this message translates to:
  /// **'نظام المرور خط أحمر.'**
  String get driverRule2;

  /// No description provided for @juniorRule1.
  ///
  /// In ar, this message translates to:
  /// **'سلامة العيال أهم شي.'**
  String get juniorRule1;

  /// No description provided for @juniorRule2.
  ///
  /// In ar, this message translates to:
  /// **'بس الأهل والسواقين المعتمدين يشاركون.'**
  String get juniorRule2;

  /// No description provided for @juniorRule3.
  ///
  /// In ar, this message translates to:
  /// **'بنشغل التتبع عشان نتطمن عليكم.'**
  String get juniorRule3;

  /// No description provided for @verificationScreenTitle.
  ///
  /// In ar, this message translates to:
  /// **'توثيق الهوية'**
  String get verificationScreenTitle;

  /// No description provided for @verifyWithNafath.
  ///
  /// In ar, this message translates to:
  /// **'وثق عبر نفاذ'**
  String get verifyWithNafath;

  /// No description provided for @verificationRationale.
  ///
  /// In ar, this message translates to:
  /// **'عشان نضمن أن الكل ثقة، لازم توثيق الهوية.'**
  String get verificationRationale;

  /// No description provided for @connectWithNafath.
  ///
  /// In ar, this message translates to:
  /// **'ربط مع نفاذ'**
  String get connectWithNafath;

  /// No description provided for @processing.
  ///
  /// In ar, this message translates to:
  /// **'لحظات...'**
  String get processing;

  /// No description provided for @sessionMissing.
  ///
  /// In ar, this message translates to:
  /// **'سجل دخول مرة ثانية لاهنت.'**
  String get sessionMissing;

  /// No description provided for @verificationUpdateFailed.
  ///
  /// In ar, this message translates to:
  /// **'ما ضبط التوثيق: {error}'**
  String verificationUpdateFailed(Object error);

  /// No description provided for @communities.
  ///
  /// In ar, this message translates to:
  /// **'المجتمعات'**
  String get communities;

  /// No description provided for @myCommunities.
  ///
  /// In ar, this message translates to:
  /// **'مجتمعاتي'**
  String get myCommunities;

  /// No description provided for @discoverCommunities.
  ///
  /// In ar, this message translates to:
  /// **'اكتشف'**
  String get discoverCommunities;

  /// No description provided for @noCommunities.
  ///
  /// In ar, this message translates to:
  /// **'ما دخلت مجتمع لسا'**
  String get noCommunities;

  /// No description provided for @joinCommunityHint.
  ///
  /// In ar, this message translates to:
  /// **'ادخل تبويبة اكتشف ولقّ مجتمعك'**
  String get joinCommunityHint;

  /// No description provided for @searchCommunities.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن مجتمع...'**
  String get searchCommunities;

  /// No description provided for @communityType.
  ///
  /// In ar, this message translates to:
  /// **'نوع المجتمع'**
  String get communityType;

  /// No description provided for @communityNameEn.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجتمع (إنجليزي)'**
  String get communityNameEn;

  /// No description provided for @communityNameAr.
  ///
  /// In ar, this message translates to:
  /// **'اسم المجتمع (عربي)'**
  String get communityNameAr;

  /// No description provided for @createCommunity.
  ///
  /// In ar, this message translates to:
  /// **'سوّي مجتمع'**
  String get createCommunity;

  /// No description provided for @leaveCommunity.
  ///
  /// In ar, this message translates to:
  /// **'اطلع'**
  String get leaveCommunity;

  /// No description provided for @joinCommunity.
  ///
  /// In ar, this message translates to:
  /// **'ادخل'**
  String get joinCommunity;

  /// No description provided for @activeRides.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير نشطة'**
  String get activeRides;

  /// No description provided for @verified.
  ///
  /// In ar, this message translates to:
  /// **'موثّق'**
  String get verified;

  /// No description provided for @communityRideBoard.
  ///
  /// In ar, this message translates to:
  /// **'لوحة المشاوير'**
  String get communityRideBoard;

  /// No description provided for @noRidesYet.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه مشاوير لسا'**
  String get noRidesYet;

  /// No description provided for @moreSocial.
  ///
  /// In ar, this message translates to:
  /// **'اجتماعي'**
  String get moreSocial;

  /// No description provided for @eventRides.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير الفعاليات'**
  String get eventRides;

  /// No description provided for @searchEvents.
  ///
  /// In ar, this message translates to:
  /// **'ابحث عن فعالية...'**
  String get searchEvents;

  /// No description provided for @all.
  ///
  /// In ar, this message translates to:
  /// **'الكل'**
  String get all;

  /// No description provided for @featuredEvents.
  ///
  /// In ar, this message translates to:
  /// **'فعاليات مميزة'**
  String get featuredEvents;

  /// No description provided for @upcomingEvents.
  ///
  /// In ar, this message translates to:
  /// **'فعاليات قادمة'**
  String get upcomingEvents;

  /// No description provided for @noUpcomingEvents.
  ///
  /// In ar, this message translates to:
  /// **'ما فيه فعاليات قادمة'**
  String get noUpcomingEvents;

  /// No description provided for @interested.
  ///
  /// In ar, this message translates to:
  /// **'مهتم'**
  String get interested;

  /// No description provided for @ridesAvailable.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير'**
  String get ridesAvailable;

  /// No description provided for @expected.
  ///
  /// In ar, this message translates to:
  /// **'متوقع'**
  String get expected;

  /// No description provided for @going.
  ///
  /// In ar, this message translates to:
  /// **'رايح'**
  String get going;

  /// No description provided for @goingTo.
  ///
  /// In ar, this message translates to:
  /// **'رايحين'**
  String get goingTo;

  /// No description provided for @returning.
  ///
  /// In ar, this message translates to:
  /// **'راجعين'**
  String get returning;

  /// No description provided for @beFirstToOfferRide.
  ///
  /// In ar, this message translates to:
  /// **'كن أول من يعرض مشوار! 🚗'**
  String get beFirstToOfferRide;

  /// No description provided for @errorGeneric.
  ///
  /// In ar, this message translates to:
  /// **'حدث خطأ، حاول مرة ثانية'**
  String get errorGeneric;

  /// No description provided for @description.
  ///
  /// In ar, this message translates to:
  /// **'الوصف'**
  String get description;

  /// No description provided for @required.
  ///
  /// In ar, this message translates to:
  /// **'مطلوب'**
  String get required;

  /// No description provided for @continueAs.
  ///
  /// In ar, this message translates to:
  /// **'متابعة كـ'**
  String get continueAs;

  /// No description provided for @passengerHeroTitle.
  ///
  /// In ar, this message translates to:
  /// **'إلى وين مشوارنا؟'**
  String get passengerHeroTitle;

  /// No description provided for @passengerHeroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع، كباتن موثوقين، ومشاوير أسهل.'**
  String get passengerHeroSubtitle;

  /// No description provided for @goodMorning.
  ///
  /// In ar, this message translates to:
  /// **'صباح الخير'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In ar, this message translates to:
  /// **'مساء الخير'**
  String get goodEvening;

  /// No description provided for @statusQuickPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع'**
  String get statusQuickPickup;

  /// No description provided for @statusTrustedRides.
  ///
  /// In ar, this message translates to:
  /// **'كباتن ثقة'**
  String get statusTrustedRides;

  /// No description provided for @quickDestHome.
  ///
  /// In ar, this message translates to:
  /// **'البيت'**
  String get quickDestHome;

  /// No description provided for @quickDestWork.
  ///
  /// In ar, this message translates to:
  /// **'الدوام'**
  String get quickDestWork;

  /// No description provided for @quickDestSchool.
  ///
  /// In ar, this message translates to:
  /// **'المدرسة'**
  String get quickDestSchool;

  /// No description provided for @quickDestAirport.
  ///
  /// In ar, this message translates to:
  /// **'المطار'**
  String get quickDestAirport;

  /// No description provided for @demandNormal.
  ///
  /// In ar, this message translates to:
  /// **'الطلب طبيعي في منطقتك. الوقت المتوقع للوصول 3-6 دقائق.'**
  String get demandNormal;

  /// No description provided for @demandStatusStable.
  ///
  /// In ar, this message translates to:
  /// **'مستقر'**
  String get demandStatusStable;

  /// No description provided for @driversNearby.
  ///
  /// In ar, this message translates to:
  /// **'عدة كباتن موثوقين قريبين منك الآن.'**
  String get driversNearby;

  /// No description provided for @driversNearbyFastLane.
  ///
  /// In ar, this message translates to:
  /// **'مسار سريع'**
  String get driversNearbyFastLane;

  /// No description provided for @shortcutSavedPlaces.
  ///
  /// In ar, this message translates to:
  /// **'أماكن محفوظة'**
  String get shortcutSavedPlaces;

  /// No description provided for @shortcutSavedPlacesSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'بضغطة زر'**
  String get shortcutSavedPlacesSubtitle;

  /// No description provided for @shortcutRepeatLastTrip.
  ///
  /// In ar, this message translates to:
  /// **'إعادة آخر مشوار'**
  String get shortcutRepeatLastTrip;

  /// No description provided for @shortcutRepeatLastTripSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'حجز سريع'**
  String get shortcutRepeatLastTripSubtitle;

  /// No description provided for @shortcutFamilyRide.
  ///
  /// In ar, this message translates to:
  /// **'مشوار عائلي'**
  String get shortcutFamilyRide;

  /// No description provided for @shortcutFamilyRideSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'شارك تفاصيل الرحلة'**
  String get shortcutFamilyRideSubtitle;

  /// No description provided for @recentPlaceTileKingFahad.
  ///
  /// In ar, this message translates to:
  /// **'طريق الملك فهد'**
  String get recentPlaceTileKingFahad;

  /// No description provided for @recentPlaceTileKingFahadSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'آخر مشوار - قبل 9 دقائق'**
  String get recentPlaceTileKingFahadSubtitle;

  /// No description provided for @recentPlaceTileBusinessGate.
  ///
  /// In ar, this message translates to:
  /// **'بوابة الأعمال'**
  String get recentPlaceTileBusinessGate;

  /// No description provided for @recentPlaceTileBusinessGateSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'وجهة متكررة'**
  String get recentPlaceTileBusinessGateSubtitle;

  /// No description provided for @recentPlaceTileParkMall.
  ///
  /// In ar, this message translates to:
  /// **'الرياض بارك مول'**
  String get recentPlaceTileParkMall;

  /// No description provided for @recentPlaceTileParkMallSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'رائج في هذا الوقت'**
  String get recentPlaceTileParkMallSubtitle;

  /// No description provided for @serviceTierSaver.
  ///
  /// In ar, this message translates to:
  /// **'خاوي توفير'**
  String get serviceTierSaver;

  /// No description provided for @serviceTierSaverEta.
  ///
  /// In ar, this message translates to:
  /// **'3-5 دقائق'**
  String get serviceTierSaverEta;

  /// No description provided for @serviceTierSaverHint.
  ///
  /// In ar, this message translates to:
  /// **'أفضل سعر'**
  String get serviceTierSaverHint;

  /// No description provided for @serviceTierComfort.
  ///
  /// In ar, this message translates to:
  /// **'خاوي راحة'**
  String get serviceTierComfort;

  /// No description provided for @serviceTierComfortEta.
  ///
  /// In ar, this message translates to:
  /// **'5-8 دقائق'**
  String get serviceTierComfortEta;

  /// No description provided for @serviceTierComfortHint.
  ///
  /// In ar, this message translates to:
  /// **'مشوار هادئ'**
  String get serviceTierComfortHint;

  /// No description provided for @serviceTierWomenPlus.
  ///
  /// In ar, this message translates to:
  /// **'سيدات+'**
  String get serviceTierWomenPlus;

  /// No description provided for @serviceTierWomenPlusEta.
  ///
  /// In ar, this message translates to:
  /// **'4-7 دقائق'**
  String get serviceTierWomenPlusEta;

  /// No description provided for @serviceTierWomenPlusHint.
  ///
  /// In ar, this message translates to:
  /// **'المطابقة المفضلة'**
  String get serviceTierWomenPlusHint;

  /// No description provided for @serviceTierRecommended.
  ///
  /// In ar, this message translates to:
  /// **'موصى به'**
  String get serviceTierRecommended;

  /// No description provided for @etaPickupTitle.
  ///
  /// In ar, this message translates to:
  /// **'وقت الوصول المتوقع'**
  String get etaPickupTitle;

  /// No description provided for @etaPickupValue.
  ///
  /// In ar, this message translates to:
  /// **'4 دقائق'**
  String get etaPickupValue;

  /// No description provided for @routeReliabilityTitle.
  ///
  /// In ar, this message translates to:
  /// **'موثوقية الطريق'**
  String get routeReliabilityTitle;

  /// No description provided for @routeReliabilityValue.
  ///
  /// In ar, this message translates to:
  /// **'عالية'**
  String get routeReliabilityValue;

  /// No description provided for @safetyScoreTitle.
  ///
  /// In ar, this message translates to:
  /// **'تقييم الأمان'**
  String get safetyScoreTitle;

  /// No description provided for @safetyScoreValue.
  ///
  /// In ar, this message translates to:
  /// **'A+'**
  String get safetyScoreValue;

  /// No description provided for @routePreviewPickup.
  ///
  /// In ar, this message translates to:
  /// **'وصلني من موقعي'**
  String get routePreviewPickup;

  /// No description provided for @routePreviewDropoff.
  ///
  /// In ar, this message translates to:
  /// **'أحدد الوجهة لاحقاً'**
  String get routePreviewDropoff;

  /// No description provided for @rideNowLabel.
  ///
  /// In ar, this message translates to:
  /// **'أحجز الآن'**
  String get rideNowLabel;

  /// No description provided for @rideLaterLabel.
  ///
  /// In ar, this message translates to:
  /// **'لاحقاً'**
  String get rideLaterLabel;

  /// No description provided for @rideNowHint.
  ///
  /// In ar, this message translates to:
  /// **'الحجز الآن يوفر أسرع وقت وصول وأفضل تسعيرة في منطقتك.'**
  String get rideNowHint;

  /// No description provided for @prefNoConversation.
  ///
  /// In ar, this message translates to:
  /// **'بدون سوالف'**
  String get prefNoConversation;

  /// No description provided for @prefCoolAC.
  ///
  /// In ar, this message translates to:
  /// **'مكيف بارد'**
  String get prefCoolAC;

  /// No description provided for @prefWomenOnly.
  ///
  /// In ar, this message translates to:
  /// **'للسيدات فقط'**
  String get prefWomenOnly;

  /// No description provided for @prefExtraLuggage.
  ///
  /// In ar, this message translates to:
  /// **'عفش زيادة'**
  String get prefExtraLuggage;

  /// No description provided for @confidenceTrustedDriverTitle.
  ///
  /// In ar, this message translates to:
  /// **'كباتن موثوقين'**
  String get confidenceTrustedDriverTitle;

  /// No description provided for @confidenceTrustedDriverSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'فقط الكباتن المعتمدين يمكنهم قبول مشاويرك.'**
  String get confidenceTrustedDriverSubtitle;

  /// No description provided for @confidenceLiveRoutingTitle.
  ///
  /// In ar, this message translates to:
  /// **'تتبع الرحلة مباشر'**
  String get confidenceLiveRoutingTitle;

  /// No description provided for @confidenceLiveRoutingSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تتبع حالة رحلتك من الركوب حتى الوصول.'**
  String get confidenceLiveRoutingSubtitle;

  /// No description provided for @confidenceFastSupportTitle.
  ///
  /// In ar, this message translates to:
  /// **'وصول سريع للدعم'**
  String get confidenceFastSupportTitle;

  /// No description provided for @confidenceFastSupportSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'تواصل مع الدعم الفني بسرعة من أي رحلة نشطة.'**
  String get confidenceFastSupportSubtitle;

  /// No description provided for @weeklyChallengesTitle.
  ///
  /// In ar, this message translates to:
  /// **'تحديات الأسبوع'**
  String get weeklyChallengesTitle;

  /// No description provided for @challengeRiyadhExplorer.
  ///
  /// In ar, this message translates to:
  /// **'مستكشف الرياض'**
  String get challengeRiyadhExplorer;

  /// No description provided for @challengeRiyadhExplorerDesc.
  ///
  /// In ar, this message translates to:
  /// **'أكمل 5 مشاوير داخل الرياض هذا الأسبوع'**
  String get challengeRiyadhExplorerDesc;

  /// No description provided for @challengeRiyadhExplorerXp.
  ///
  /// In ar, this message translates to:
  /// **'200 نقطة'**
  String get challengeRiyadhExplorerXp;

  /// No description provided for @challengeEcoPioneer.
  ///
  /// In ar, this message translates to:
  /// **'رائد البيئة'**
  String get challengeEcoPioneer;

  /// No description provided for @challengeEcoPioneerDesc.
  ///
  /// In ar, this message translates to:
  /// **'وفّر 10 كجم من انبعاثات الكربون عبر مشاركة مشاويرك'**
  String get challengeEcoPioneerDesc;

  /// No description provided for @challengeEcoPioneerXp.
  ///
  /// In ar, this message translates to:
  /// **'500 نقطة'**
  String get challengeEcoPioneerXp;

  /// No description provided for @challengeSafetyFirst.
  ///
  /// In ar, this message translates to:
  /// **'السلامة أولاً'**
  String get challengeSafetyFirst;

  /// No description provided for @challengeSafetyFirstDesc.
  ///
  /// In ar, this message translates to:
  /// **'حافظ على تقييم 5 نجوم لـ 10 رحلات'**
  String get challengeSafetyFirstDesc;

  /// No description provided for @challengeSafetyFirstXp.
  ///
  /// In ar, this message translates to:
  /// **'1000 نقطة'**
  String get challengeSafetyFirstXp;

  /// No description provided for @challengePercentComplete.
  ///
  /// In ar, this message translates to:
  /// **'{percent}% مكتمل'**
  String challengePercentComplete(int percent);

  /// No description provided for @eventRamadanBonus.
  ///
  /// In ar, this message translates to:
  /// **'مكافأة مشاوير رمضان'**
  String get eventRamadanBonus;

  /// No description provided for @eventRamadanBonusDesc.
  ///
  /// In ar, this message translates to:
  /// **'ضعف النقاط لكل رحلات وقت الإفطار'**
  String get eventRamadanBonusDesc;

  /// No description provided for @eventRamadanBonusStart.
  ///
  /// In ar, this message translates to:
  /// **'تبدأ بعد يومين'**
  String get eventRamadanBonusStart;

  /// No description provided for @juniorIntroTitle.
  ///
  /// In ar, this message translates to:
  /// **'خاوي جونيور'**
  String get juniorIntroTitle;

  /// No description provided for @juniorIntroSubtitle.
  ///
  /// In ar, this message translates to:
  /// **'مشاوير آمنة لراحة بالك'**
  String get juniorIntroSubtitle;

  /// No description provided for @juniorSafetyPoint.
  ///
  /// In ar, this message translates to:
  /// **'فقط كباتن موثوقين (أولياء أمور)'**
  String get juniorSafetyPoint;

  /// No description provided for @juniorFamilyPoint.
  ///
  /// In ar, this message translates to:
  /// **'أضف السائق الخاص بعائلتك'**
  String get juniorFamilyPoint;

  /// No description provided for @juniorTrackingPoint.
  ///
  /// In ar, this message translates to:
  /// **'تتبع لايف'**
  String get juniorTrackingPoint;

  /// No description provided for @juniorContinue.
  ///
  /// In ar, this message translates to:
  /// **'كمل'**
  String get juniorContinue;

  /// No description provided for @juniorNotParent.
  ///
  /// In ar, this message translates to:
  /// **'لست ولي أمر؟'**
  String get juniorNotParent;

  /// No description provided for @juniorRoleTitle.
  ///
  /// In ar, this message translates to:
  /// **'اختر دورك'**
  String get juniorRoleTitle;

  /// No description provided for @juniorRoleGuardian.
  ///
  /// In ar, this message translates to:
  /// **'ولي أمر'**
  String get juniorRoleGuardian;

  /// No description provided for @juniorRoleGuardianDesc.
  ///
  /// In ar, this message translates to:
  /// **'إدارة مشاوير أبنائك'**
  String get juniorRoleGuardianDesc;

  /// No description provided for @juniorRoleDriver.
  ///
  /// In ar, this message translates to:
  /// **'سائق العائلة'**
  String get juniorRoleDriver;

  /// No description provided for @juniorRoleDriverDesc.
  ///
  /// In ar, this message translates to:
  /// **'تمت دعوتك للقيادة'**
  String get juniorRoleDriverDesc;

  /// No description provided for @juniorDashboardTitle.
  ///
  /// In ar, this message translates to:
  /// **'لوحة جونيور'**
  String get juniorDashboardTitle;

  /// No description provided for @juniorAddKid.
  ///
  /// In ar, this message translates to:
  /// **'إضافة طفل'**
  String get juniorAddKid;

  /// No description provided for @juniorMyKids.
  ///
  /// In ar, this message translates to:
  /// **'أطفالي'**
  String get juniorMyKids;

  /// No description provided for @juniorNoKids.
  ///
  /// In ar, this message translates to:
  /// **'لم تتم إضافة أطفال بعد.'**
  String get juniorNoKids;

  /// No description provided for @juniorActiveRuns.
  ///
  /// In ar, this message translates to:
  /// **'المشاوير الحالية'**
  String get juniorActiveRuns;

  /// No description provided for @juniorFeatureInProgress.
  ///
  /// In ar, this message translates to:
  /// **'الميزة قيد التطوير'**
  String get juniorFeatureInProgress;

  /// No description provided for @juniorNoActiveRuns.
  ///
  /// In ar, this message translates to:
  /// **'لا توجد رحلات نشطة'**
  String get juniorNoActiveRuns;

  /// No description provided for @juniorCreateRunWithHub.
  ///
  /// In ar, this message translates to:
  /// **'أنشئ رحلة من المركز وشارك كود الدعوة مع السائق'**
  String get juniorCreateRunWithHub;

  /// No description provided for @juniorGoToHub.
  ///
  /// In ar, this message translates to:
  /// **'انتقل للمركز'**
  String get juniorGoToHub;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
