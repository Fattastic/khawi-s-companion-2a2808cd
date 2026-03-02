// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appName => 'خاوي';

  @override
  String get appNameEn => 'Khawi';

  @override
  String get splashTagline => 'شارك الطريق، وخفّف الزحمة عليك وعلينا.';

  @override
  String get onboardingSlide1Title => 'شارك الطريق، وخفّف الزحمة عليك وعلينا.';

  @override
  String get onboardingSlide2Title => 'كل كيلو وله نقاط.. والجوائز تنتظرك';

  @override
  String get onboardingSlide3Title => 'وقت الذروة؟ نقاطك تدبّل!';

  @override
  String get onboardingSlide4Title => 'بدون عمولة.. والمجتمع كسبان';

  @override
  String get onboardingZeroCommissionDescription =>
      'ما نأخذ نسبة مثل غيرنا؛ التطبيق عليك خفيف، والاشتراك بس إذا ودّك تحوّل نقاطك لمكافآت تسوّي مزاج.';

  @override
  String get onboardingCarOwnerTitle => 'عندك سيارة؟';

  @override
  String get onboardingSubscriptionTitle => 'حوّل نقاطك لمكافآت مع Khawi+';

  @override
  String get onboardingSubscriptionDescription =>
      'المشاوير مجانية دايمًا. اشترك إذا ودّك نقاطك تصير قهوة وبنزين وهدايا.';

  @override
  String get oneRiyalADay => 'بريال باليوم.. والباقي علينا';

  @override
  String get billedMonthly => '(يحسب 30 ريال شهرياً)';

  @override
  String get next => 'التالي';

  @override
  String get getStarted => 'يلا نبدأ السالفة!';

  @override
  String get skip => 'تخطي';

  @override
  String get retry => 'حاول مرة ثانية';

  @override
  String get seeAll => 'شوف الكل';

  @override
  String get offerNewRide => 'اعرض مشوارك وخلك كفو';

  @override
  String get todaySummary => 'ملخص يومك السريع';

  @override
  String get quickActions => 'أوامرك';

  @override
  String get map => 'الخريطة';

  @override
  String get findRide => 'لقّي لك مشوار';

  @override
  String get whereAreYouGoing => 'وين الوجهة يا بطل؟';

  @override
  String get xpLedger => 'سجل النقاط';

  @override
  String get xpLedgerHistory => 'سجل النقاط';

  @override
  String get xpLedgerRecentActivity => 'النشاط الأخير';

  @override
  String get xpLedgerNoActivityYet =>
      'لسّه ما عندك نشاط.. أول مشوار وبتشوف الفرق!';

  @override
  String get xpLedgerEarnXpHint => 'امش مشوارين وخل النقاط تشتغل!';

  @override
  String get redeemableXpLabel => 'نقاطك الجاهزة للاستبدال';

  @override
  String get somethingWentWrong => 'حدث خطأ';

  @override
  String get khawiPlusRequired => 'الميزة هذي تحتاج Khawi+';

  @override
  String get khawiPlusMonthlyPrice => '30 ر.س/شهر';

  @override
  String xpLedgerUpsellBody(String price) {
    return 'اشترك في Khawi+ ($price) وخَلّ نقاطك تتحوّل لمكافآت على المزاج.';
  }

  @override
  String get redeemXp => 'استبدال XP';

  @override
  String get promoCodes => 'أكواد';

  @override
  String get subscribeToKhawiPlusToRedeem => 'اشترك في Khawi+ وخلّها تضبط';

  @override
  String xpLedgerMultiplierActive(String multiplier) {
    return 'مضاعف XP $multiplier× مفعل';
  }

  @override
  String xpLedgerMultiplierShort(String multiplier) {
    return '$multiplier× XP';
  }

  @override
  String xpLedgerApproxValue(String value) {
    return 'القيمة التقريبية ~ $value';
  }

  @override
  String get errorLoadingHistory => 'تعذر تحميل السجل';

  @override
  String get errorLoadingTransactions => 'تعذر تحميل المعاملات';

  @override
  String get hello => 'هلا!';

  @override
  String homeGreetingWithName(Object name) {
    return 'هلا $name! جاهز نخفف الزحمة؟';
  }

  @override
  String get communityXp => 'نقاط مجتمع خاوي';

  @override
  String get aiOptimizedRoute => 'مسارك المضبوط بالذكاء';

  @override
  String get startRoute => 'يلا حرّك';

  @override
  String get stop => 'وقفة';

  @override
  String get pickup => 'ركوب';

  @override
  String get dropoff => 'نزول';

  @override
  String activePassengersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count راكب نشط',
      many: '$count راكباً نشطاً',
      few: '$count ركاب نشطين',
      two: 'راكبان نشطان',
      one: 'راكب واحد نشط',
      zero: 'لا يوجد ركاب نشطين',
    );
    return '$_temp0';
  }

  @override
  String get rideStatusAccepted => 'تم القبول.. أمورك تمام';

  @override
  String get optimizing => 'نضبط لك المسار.. لحظة بس';

  @override
  String get bundleStopsAi => 'رتب الوقفات (AI)';

  @override
  String get passengerRequest => 'طلب خوي جديد';

  @override
  String matchScore(Object percent) {
    return 'نسبة التوافق: $percent%';
  }

  @override
  String get rides => 'المشاوير';

  @override
  String get rating => 'التقييم';

  @override
  String get languageArabic => 'العربية';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingSlide2Description =>
      'XP وشارات وتحديات أسبوعية.. ومكافآت تسوّي ابتسامة.';

  @override
  String get onboardingSlide3Description =>
      'حوافز ذكية تخفف الزحمة وتقلل الانبعاثات.';

  @override
  String get noRequestsRightNow => 'الهدوء جميل.. ما فيه طلبات حاليًا';

  @override
  String get stayOnlineForRequests => 'خلك أونلاين، وأول طلب يطب عليك هنا.';

  @override
  String get youAreOnline => 'أنت متصل';

  @override
  String get youAreOffline => 'أنت غير متصل';

  @override
  String get planner => 'مخططك الذكي';

  @override
  String get instantQr => 'QR على السريع';

  @override
  String get queue => 'الطابور';

  @override
  String get regular => 'الرحلات المعتادة';

  @override
  String get couldNotLoadSummary => 'ما قدرنا نجيب الملخص الآن';

  @override
  String get checkConnectionAndTryAgain => 'شيك على النت وحاول مرة ثانية.';

  @override
  String get noInternetConnection => 'ما في إنترنت';

  @override
  String get loginTitle => 'دخولك علينا.. أو حساب جديد';

  @override
  String get loginSubtitle => 'حيّاك في خاوي، خلنا نبدأ بخطوتين.';

  @override
  String get phoneNumber => 'رقم الجوال';

  @override
  String get continueAction => 'كمّل';

  @override
  String get phoneInvalidError => 'يرجى إدخال رقم جوال صحيح';

  @override
  String get otpChangePhoneTooltip => 'تغيير رقم الهاتف';

  @override
  String get otpChangeNumberTitle => 'تغيير الرقم';

  @override
  String get otpVerificationTitle => 'التحقق';

  @override
  String get otpVerificationSubtitle =>
      'أدخل رمز التحقق المكون من 6 أرقام الذي أرسلناه إلى جوالك';

  @override
  String get otpCodeLabel => 'رمز التحقق';

  @override
  String get otpVerifyCta => 'تحقق';

  @override
  String get otpInvalidCodeError => 'يرجى إدخال رمز التحقق المكون من 6 أرقام';

  @override
  String get emailAuthTitleLogin => 'تسجيل الدخول بالبريد';

  @override
  String get emailAuthTitleSignup => 'إنشاء حساب';

  @override
  String get emailAuthSubtitle => 'استخدم بريدك الإلكتروني وكلمة المرور';

  @override
  String get emailLabel => 'البريد الإلكتروني';

  @override
  String get passwordLabel => 'كلمة المرور';

  @override
  String get emailInvalidError => 'يرجى إدخال بريد إلكتروني صحيح';

  @override
  String passwordTooShortError(String min) {
    return 'كلمة المرور يجب أن تكون $min أحرف على الأقل';
  }

  @override
  String get checkEmailToConfirmAccount =>
      'تحقق من بريدك الإلكتروني لتأكيد حسابك.';

  @override
  String get signIn => 'تسجيل الدخول';

  @override
  String get signUp => 'إنشاء حساب';

  @override
  String get alreadyHaveAccountSignIn => 'لديك حساب؟ سجّل دخول';

  @override
  String get noAccountCreateOne => 'ما عندك حساب؟ أنشئ واحد';

  @override
  String get errorTitle => 'خطأ';

  @override
  String get ok => 'حسناً';

  @override
  String get liveTripTitle => 'الرحلة المباشرة';

  @override
  String liveTripRiskLabel(String percent) {
    return 'مستوى الخطر: $percent%';
  }

  @override
  String get liveTripCriticalAlertTitle => 'تنبيه أمان خطير';

  @override
  String get liveTripSafetyWarningTitle => 'تحذير أمان';

  @override
  String liveTripUnusualActivityMessage(String flags) {
    return 'تم رصد نشاط غير معتاد في الرحلة ($flags). تم إشعار فريق الدعم.';
  }

  @override
  String get liveTripSosSent => 'تم إرسال الاستغاثة. تم إشعار جهات الاتصال.';

  @override
  String liveTripSosFailed(String error) {
    return 'فشل إرسال الاستغاثة: $error';
  }

  @override
  String get liveTripSosCta => 'استغاثة - مساعدة طارئة';

  @override
  String get liveTripSending => 'جار الإرسال...';

  @override
  String get or => 'أو';

  @override
  String get continueWithGoogle => 'كمّل مع Google';

  @override
  String get continueWithApple => 'كمّل مع Apple';

  @override
  String get loginWithAbsher => 'دخول عبر أبشر (للكباتن)';

  @override
  String get byContinuingYouAgree => 'إذا كملت، فأنت موافق على';

  @override
  String get termsOfService => 'شروط الخدمة';

  @override
  String get and => 'و';

  @override
  String get privacyPolicy => 'سياسة الخصوصية';

  @override
  String get verificationTitle => 'خطوة عشان أماننا كلنا';

  @override
  String get verificationDescription =>
      'سلامتك تهمنا. توثيق الحساب يخلي مجتمعنا آمن وموثوق. للكباتن، لازم التوثيق عن طريق أبشر.';

  @override
  String get verificationButton => 'تمام، كمّل';

  @override
  String get driverVerificationAppBarTitle => 'التحقق من السائق';

  @override
  String get driverVerificationNotNow => 'لاحقا';

  @override
  String get driverVerificationHeader => 'التحقق من هوية السائق وملكية المركبة';

  @override
  String get driverVerificationBody =>
      'لضمان سلامة جميع المستخدمين، نحتاج للتحقق من هويتك وملكية مركبتك.';

  @override
  String get driverVerificationIdentityTitle => 'التحقق من الهوية';

  @override
  String get driverVerificationIdentitySubtitle =>
      'عبر النفاذ الوطني الموحد (نفاذ)';

  @override
  String get driverVerificationVehicleTitle => 'التحقق من ملكية المركبة';

  @override
  String get driverVerificationVehicleSubtitle =>
      'تأكيد ملكية المركبة عبر الأنظمة الرسمية أو المستندات';

  @override
  String get driverVerificationStatusVerified => 'تم التحقق';

  @override
  String get driverVerificationStatusApproved => 'معتمد';

  @override
  String get driverVerificationStatusPending => 'قيد المراجعة';

  @override
  String get driverVerificationStatusNotVerified => 'غير مكتمل';

  @override
  String get driverVerificationActionVerifyWithNafath => 'التحقق عبر نفاذ';

  @override
  String get driverVerificationActionVerifyVehicle => 'التحقق من المركبة';

  @override
  String get driverVerificationContinue => 'المتابعة إلى لوحة السائق';

  @override
  String get driverVerificationPendingNotice =>
      'مستنداتك قيد المراجعة. سيتم إشعارك عند اكتمال التحقق. خلال هذه المدة، يمكنك استخدام خاوي كراكب.';

  @override
  String get driverVerificationVehicleDetailsTitle => 'بيانات المركبة';

  @override
  String get driverVerificationPlateLabel => 'رقم اللوحة';

  @override
  String get driverVerificationPlateHint => 'مثال: أ ب ت 1234';

  @override
  String get driverVerificationModelLabel => 'موديل المركبة';

  @override
  String get driverVerificationModelHint => 'مثال: تويوتا كامري 2023';

  @override
  String get driverVerificationVehicleLaterNote =>
      'سيتم طلب صورة الاستمارة ولقطة للتحقق لاحقا.';

  @override
  String get driverVerificationSubmitForReview => 'إرسال للمراجعة';

  @override
  String get driverVerificationFillVehicleFieldsError =>
      'يرجى تعبئة جميع بيانات المركبة';

  @override
  String get driverVerificationDataDisclosureTitle => 'إفصاح البيانات';

  @override
  String get driverVerificationDisclosureIdentity =>
      'سيتم التحقق من هويتك الوطنية عبر نفاذ.';

  @override
  String get driverVerificationDisclosureVehicle =>
      'سيتم التحقق من ملكية المركبة عبر الأنظمة الرسمية أو المستندات المقدمة.';

  @override
  String get driverVerificationDisclosurePurpose =>
      'الغرض: ضمان سلامة وثقة جميع المستخدمين.';

  @override
  String get driverVerificationDisclosureRetention =>
      'يتم الاحتفاظ بالبيانات وفقا لسياسة الخصوصية الخاصة بنا.';

  @override
  String get driverVerificationConsentCheckbox =>
      'أوافق على التحقق من بياناتي للأغراض المذكورة أعلاه';

  @override
  String get driverVerificationConsentNeeded =>
      'يرجى الموافقة على إفصاح البيانات أولا';

  @override
  String get driverVerificationVerificationFailed => 'فشل التحقق';

  @override
  String get roleSelectionTitle => 'حياك الله في خاوي!';

  @override
  String get safetyDisclaimerTitle => 'السلامة والقوانين';

  @override
  String get safetyDisclaimerBody =>
      'اذا ضغطت \"موافق\"، يعني تتعهد بالتالي:\n\n• تلتزم بأنظمة المرور وتعليماتنا.\n• تربط حزام الأمان طول الطريق.\n• ممنوع التحرش أو أي تصرف يضايق.\n• تحترم الخصوصية ولا تصور أحد بدون إذنه.\n• في مشاوير الأطفال: المسؤول ينتبه لهم زين.\n• لا سمح الله، في الطوارئ كلم العمليات.';

  @override
  String get safetyDisclaimerAgree => 'موافق';

  @override
  String get safetyDisclaimerDecline => 'ما أوافق';

  @override
  String get subscriptionTagline =>
      'الاستخدام مجاني، والاشتراك يخلي نقاطك تسوى أكثر.';

  @override
  String get iAmADriver => 'كابتن';

  @override
  String get driverDescription => 'بشارك طريقي وأكسب';

  @override
  String get iAmAPassenger => 'خوي (راكب)';

  @override
  String get passengerDescription => 'أبي مشوار على الطريق وبجوّ رايق';

  @override
  String get roleJuniorTitle => 'خاوي جونيور';

  @override
  String get roleJuniorDescription => 'مشاوير آمنة لعيالك';

  @override
  String get homeGreeting => 'يا هلا يا خوي!';

  @override
  String get homeTitle => 'جاهز لمشوار يسهّل يومك؟';

  @override
  String get searchForARide => 'دوّر لك مشوار';

  @override
  String get kmShared => 'كم شاركت';

  @override
  String get co2Saved => 'كم وفّرنا CO₂';

  @override
  String get points => 'نقاط';

  @override
  String get peakHoursActive => 'وقت الذروة شغّال! 3x XP';

  @override
  String get smartMatchAI => 'توافق ذكي سريع';

  @override
  String get routeOverlap => 'تطابق المسار';

  @override
  String get from => 'من';

  @override
  String get to => 'إلى';

  @override
  String get now => 'الحين';

  @override
  String get leaveAsap => 'تحرّك الحين';

  @override
  String get change => 'تغيير';

  @override
  String get filters => 'فلترة';

  @override
  String get womenOnly => 'سيدات فقط';

  @override
  String get kidsAllowed => 'مسموح بالأطفال';

  @override
  String get sameNeighborhood => 'نفس الحي';

  @override
  String get noRideSelected => 'ما اخترت مشوار للحين.';

  @override
  String get back => 'رجوع';

  @override
  String get eta => 'وصول';

  @override
  String get projectedXp => 'النقاط اللي بتكسبها';

  @override
  String get peakHours => 'وقت ذروة!';

  @override
  String get xp => 'XP';

  @override
  String get rideNow => 'احجز الحين';

  @override
  String get noCurrentRide => 'ما عندك مشوار حالياً.. يمديك تبدأ واحد.';

  @override
  String get backToHome => 'رجوع للرئيسية';

  @override
  String get arrivingAt => 'الوصول';

  @override
  String get endTripForDemo => 'إنهاء (تجريبي)';

  @override
  String get noCompletedRide => 'ما فيه مشاوير مكتملة.';

  @override
  String get rideCompleted => 'تم المشوار!';

  @override
  String postRideEarningsMessage(String xp) {
    return 'كسبت $xp نقطة في هذا المشوار. شكرًا لاختيارك خاوي!';
  }

  @override
  String get rateYourRide => 'قيّم رحلتك';

  @override
  String get ratingThanks => 'شكرًا لتقييمك!';

  @override
  String get driverLabel => 'السائق';

  @override
  String get youEarned => 'كسبت';

  @override
  String rateDriver(Object name) {
    return 'قيم $name';
  }

  @override
  String get done => 'تم';

  @override
  String get navHome => 'الرئيسية';

  @override
  String get navActivity => 'نشاطي';

  @override
  String get navHub => 'المركز';

  @override
  String get navTracking => 'التتبع';

  @override
  String get rewardDetails => 'تفاصيل المكافأة';

  @override
  String get instantTripQrTitle => 'رمز الرحلة الفوري';

  @override
  String get juniorTrackRuns => 'تتبع الرحلات';

  @override
  String get familyDriverTitle => 'سائق العائلة';

  @override
  String get newRegularRouteTitle => 'مسار اعتيادي جديد';

  @override
  String get navMore => 'المزيد';

  @override
  String get navRewards => 'المكافآت';

  @override
  String get navProfile => 'حسابي';

  @override
  String get activityLog => 'سجل النشاط';

  @override
  String get tripHistory => 'سجل المشاوير';

  @override
  String get pointsHistory => 'سجل النقاط';

  @override
  String tripWith(Object name) {
    return 'مشوار مع $name';
  }

  @override
  String get redeemedCoffee => 'استبدلت قهوة';

  @override
  String get friendReferralBonus => 'مكافأة دعوة صديق';

  @override
  String get driverRewards => 'مكافآت الكباتن';

  @override
  String get rewardsAndLeaderboard => 'المكافآت والصدارة';

  @override
  String get yourLevel => 'مستواك';

  @override
  String get availableRewards => 'وش تقدر تاخذ';

  @override
  String get rewards => 'جوائز';

  @override
  String get leaderboard => 'المتصدرين';

  @override
  String get you => 'أنت';

  @override
  String get editProfile => 'تعديل الملف';

  @override
  String get notifications => 'تنبيهات';

  @override
  String get darkMode => 'الوضع الليلي';

  @override
  String get language => 'اللغة';

  @override
  String get morePremiumSection => 'خاوي+';

  @override
  String get moreAccountSettings => 'إعدادات الحساب';

  @override
  String get morePersonalInformation => 'المعلومات الشخصية';

  @override
  String get moreSwitchRole => 'تغيير الدور';

  @override
  String get moreXpLedgerPassengerOnly => 'سجل النقاط متاح للركاب فقط.';

  @override
  String get moreGeneral => 'عام';

  @override
  String get moreHelpCenter => 'مركز المساعدة';

  @override
  String get moreInviteFriends => 'دعوة أصدقاء';

  @override
  String get moreAboutKhawi => 'حول خاوي';

  @override
  String get moreUpgradeToPremium => 'اشترك في خاوي+';

  @override
  String get morePremiumSubtitle => 'افتح المكافآت ومضاعف نقاط 1.5x';

  @override
  String get moreComingSoon => 'قريباً';

  @override
  String get referralTitle => 'ادع خويك واكسب 300 نقطة!';

  @override
  String get referralDescription =>
      'عط خويك الكود، واول ما يخلص اول مشوار بتجيك المكافأة.';

  @override
  String get shareNow => 'انشر الكود';

  @override
  String get logout => 'تسجيل خروج';

  @override
  String get dashboard => 'لوحتي';

  @override
  String get welcomeCaptain => 'حياك يا كابتن!';

  @override
  String get kmThisWeek => 'كم هالأسبوع';

  @override
  String get totalPoints => 'مجموع النقاط';

  @override
  String get totalCo2Saved => 'توفير CO₂';

  @override
  String get smartTips => 'نصائح ذكية';

  @override
  String get peakAlertTitle => 'انتبه، زحمة!';

  @override
  String get peakAlertDescription =>
      'شكل طريق الملك فهد بيزحم بعد نص ساعة. استعد عشان تدبل نقاطك 3 مرات!';

  @override
  String get passengerRequests => 'طلبات الأخوياء';

  @override
  String newRequestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count طلب جديد',
      many: '$count طلبًا جديدًا',
      few: '$count طلبات جديدة',
      two: 'طلبان جديدان',
      one: 'طلب واحد جديد',
      zero: 'لا توجد طلبات',
    );
    return '$_temp0';
  }

  @override
  String get waitingForApproval => 'ينتظرون موافقتك';

  @override
  String get navDashboard => 'لوحتي';

  @override
  String get match => 'مطابقة';

  @override
  String get accept => 'قبول';

  @override
  String get decline => 'رفض';

  @override
  String get currentPassenger => 'خويك الحالي';

  @override
  String get destination => 'الوجهة';

  @override
  String get endTrip => 'إنهاء';

  @override
  String get upgradeToKhawiPlus => 'رقّ حسابك لـ +Khawi';

  @override
  String get subscribeToKhawiPlus => 'اشترك في +Khawi';

  @override
  String get premiumTitle => 'مزايا حصرية لك';

  @override
  String get premiumSubtitle => 'وش بتستفيد؟';

  @override
  String get featureZeroCommissionTitle => 'صفر عمولة. دخلك لك 100%.';

  @override
  String get featureZeroCommissionDescription =>
      'ما ناخذ 20-25% زي غيرنا. رسم اشتراك بسيط (30 ريال) وكل دخلك في جيبك.';

  @override
  String get feature15xXpTitle => 'نقاطك تزيد مرة ونص';

  @override
  String get feature15xXpDescription => 'تجمع نقاط أسرع مع كل مشوار.';

  @override
  String get featurePriorityMatchingTitle => 'أولوية في الطلبات';

  @override
  String get featurePriorityMatchingDescription =>
      'تجيك أفضل الطلبات اللي تناسب طريقك قبل غيرك.';

  @override
  String get featureMonthlyRewardsTitle => 'بدل نقاطك بفلوس وهدايا';

  @override
  String get featureMonthlyRewardsDescription =>
      'الاستخدام بلاش، بس عشان تبدل النقاط بقهوة وبنزين، لازم تكون مشترك.';

  @override
  String get featurePremiumBadgeTitle => 'شارة +Khawi المميزة';

  @override
  String get featurePremiumBadgeDescription => 'تميز بالشارة الذهبية في ملفك.';

  @override
  String get sar => 'ريال';

  @override
  String get monthly => 'بالشهر';

  @override
  String get subscribeNow => 'اشترك الحين';

  @override
  String get myBadges => 'شاراتي';

  @override
  String get zeroAccidents => 'سواقة نظيفة';

  @override
  String get communityHero => 'بطل المجتمع';

  @override
  String get weeklyChallenges => 'تحديات الأسبوع';

  @override
  String get earnBonusXp => 'دبّل نقاطك!';

  @override
  String get challenges => 'التحديات';

  @override
  String get challengeComplete5Rides => 'خلص 5 مشاوير هالأسبوع';

  @override
  String get challengeShare100km => 'شارك طريقك لمسافة 100 كم';

  @override
  String get challengePeakHourMaster => 'خلص 3 مشاوير وقت الذروة';

  @override
  String get xpBreakdown => 'تفاصيل النقاط';

  @override
  String get basePoints => 'نقاط المشوار';

  @override
  String get peakHourBonus => 'بوناس الذروة';

  @override
  String get peakHourBonusExclamation => 'بوناس الذروة!';

  @override
  String get passengerBonusDriver => 'بوناس الركاب';

  @override
  String get passengerBonusPassenger => 'بوناس المجموعة';

  @override
  String get synergyBonus => 'بوناس الدوام';

  @override
  String get premiumBonus => 'بوناس اشتراكك';

  @override
  String get ratingBonus => 'بوناس التقييم';

  @override
  String get parentBonus => 'بوناس الأهل';

  @override
  String get captain => 'كابتن';

  @override
  String captainWithName(String name) {
    return 'الكابتن $name';
  }

  @override
  String get newDriver => 'كابتن جديد';

  @override
  String incentiveActiveInArea(String area, String multiplier) {
    return 'شغال في $area: تدبيل ${multiplier}x.';
  }

  @override
  String otherActiveZones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count منطقة نشطة أخرى',
      many: '+$count منطقة نشطة أخرى',
      few: '+$count مناطق نشطة أخرى',
      two: '+منطقتان نشطتان أخرى',
      one: '+منطقة نشطة أخرى',
    );
    return '$_temp0';
  }

  @override
  String stopLabelLine(String type, String label) {
    return '$type: $label';
  }

  @override
  String passengerWithId(String id) {
    return 'الخوي $id';
  }

  @override
  String get total => 'المجموع';

  @override
  String get numberOfPassengers => 'عدد الركاب';

  @override
  String get setPassengerCapacity => 'كم تبي تشيل؟';

  @override
  String get seats => 'مقاعد';

  @override
  String get redeemableXp => 'نقاط يمديك تبدلها';

  @override
  String get lockedXp => 'نقاط معلقة';

  @override
  String unlockYourXp(Object points) {
    return 'عندك $points نقطة تنتظرك!';
  }

  @override
  String get upgradeToUnlock => 'اشترك وفعلها الحين';

  @override
  String get referralProgram => 'برنامج الدعوات';

  @override
  String get yourReferralCode => 'كودك الخاص';

  @override
  String get tapToCopy => 'اضغط للنسخ';

  @override
  String get shareYourCode => 'عطهم كودك';

  @override
  String get referralStatus => 'مين دعيت؟';

  @override
  String get invited => 'دعوته';

  @override
  String get completed => 'خلص أول مشوار';

  @override
  String get notificationSettings => 'اعدادات التنبيهات';

  @override
  String get pushNotifications => 'التنبيهات';

  @override
  String get allowNotifications => 'تفعيل التنبيهات';

  @override
  String get rideRequests => 'طلبات المشاوير';

  @override
  String get xpGains => 'نقط جتني';

  @override
  String get peakHourAlerts => 'تنبيهات الزحمة';

  @override
  String get appUpdates => 'تحديثات التطبيق';

  @override
  String get open => 'فتح';

  @override
  String get chooseYourRoleTitle => 'وش دورك؟';

  @override
  String get roleSelectionWelcomeTitle => 'هلا بك! كيف تبي تستخدم خاوي؟';

  @override
  String get roleSelectionSubtitle => 'يمديك تغير دورك بعدين من الملف الشخصي.';

  @override
  String get shareYourRegularRoute => 'شارك طريقك اليومي';

  @override
  String get instantRideSheetDescription =>
      'امسح الباركود واركب، أو سو لك باركود';

  @override
  String get scanQr => 'امسح QR';

  @override
  String get createQr => 'سوي QR';

  @override
  String get joinRide => 'اركب مع كابتن';

  @override
  String get shareRide => 'وصل أحد معك';

  @override
  String get rulesConsentText => 'ترا اذا كملت، يعني موافق تلتزم بهالقواعد.';

  @override
  String get iAgreeContinue => 'موافق ونكمل';

  @override
  String errorWithMessage(String message) {
    return 'خطأ: $message';
  }

  @override
  String get khawiPremium => 'خاوي+';

  @override
  String get acceptInstantRides => 'استقبل فوري';

  @override
  String get acceptInstantRidesDescription =>
      'استقبل طلبات من ناس حولك يبون مشوار الحين.';

  @override
  String get goOnline => 'اتصل الآن';

  @override
  String get howItWorks => 'كيف الطريقة؟';

  @override
  String get instantRideStep1 => 'خلك متصل عشان تجيك الطلبات.';

  @override
  String get instantRideStep2 => 'عندك 30 ثانية لجمال عيونك تقبل الطلب.';

  @override
  String get instantRideStep3 => 'اتبع الخريطة لموقع خويك.';

  @override
  String get confirmSchedule => 'تأكيد الجدول';

  @override
  String get suggestedRoutes => 'مسارات مقترحة';

  @override
  String get optimalStartTime => 'أفضل وقت تحرك';

  @override
  String optimalStartTimeDescription(String time, String percent) {
    return 'اطلع الساعة $time وتفادى الزحمة ودبّل نقاطك $percent%.';
  }

  @override
  String get highDemandAreas => 'مناطق شابة نار';

  @override
  String highDemandAreasDescription(int count, String area, String multiplier) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count راكب بالقرب من $area',
      many: '$count راكباً بالقرب من $area',
      few: '$count ركاب بالقرب من $area',
      two: 'راكبان بالقرب من $area',
      one: 'راكب واحد بالقرب من $area',
      zero: 'لا يوجد ركاب بالقرب من $area',
    );
    return '$_temp0. مضاعف +${multiplier}x مفعل.';
  }

  @override
  String get homeToOffice => 'من البيت للدوام';

  @override
  String get universityRun => 'مشوار الجامعة';

  @override
  String get highMatchProbability => 'احتمالية تلقى أحد عالية';

  @override
  String get mediumTraffic => 'زحمة خفيفة';

  @override
  String get aiRoutePlanner => 'مخطط الرحلات الذكي';

  @override
  String get aiRoutePlannerTitle => 'المخطط الذكي';

  @override
  String get aiRoutePlannerDescription => 'خطط يومك بذكاء';

  @override
  String get planYourCommute => 'خطط مشوارك اليومي';

  @override
  String get workLocation => 'مقر العمل';

  @override
  String get homeLocation => 'موقع البيت';

  @override
  String get analyzeMyRoute => 'شف لي حل للمسار';

  @override
  String get aiAnalysis => 'الذكاء الاصطناعي يفكر...';

  @override
  String get aiPlanTitle => 'خطتك الذكية';

  @override
  String get aiPlanDescription =>
      'شفنا مسارك، وهذي نصايح عشان تزيد نقاطك وتفتك من الزحمة:';

  @override
  String get optimalDeparture => 'أحسن وقت تمشي';

  @override
  String get highDemandZones => 'مناطق زحمة وطلب';

  @override
  String get keepRidingToNextReward => 'كمل مشاوير عشان توصل للمكافأة الجاية!';

  @override
  String earnXPForRide(Object points) {
    return 'اركب واكسب $points نقطة لكل مشوار!';
  }

  @override
  String get rideWith => 'خاوِه';

  @override
  String get cancel => 'كنسل';

  @override
  String get yes => 'ايه';

  @override
  String get no => 'لا';

  @override
  String get passengerEncouragementTitle => 'تفكر تسوق؟';

  @override
  String get passengerEncouragementBody =>
      'ترا بما عندك سيارة، يمديك تكسب دبل النقاط كسائق في هالمشوار!';

  @override
  String get viewDriverBenefits => 'وش يستفيد الكابتن؟';

  @override
  String get myRegularTrips => 'مشاويري الثابتة';

  @override
  String get manageRegularTrips => 'رتب مشاويرك اليومية واكسب نقاط بانتظام';

  @override
  String get noRegularTrips => 'ما حطيت مشاوير ثابتة لسا.';

  @override
  String get addNewRoute => 'ضيف مسار جديد';

  @override
  String get setRegularRoute => 'ضبط مسار ثابت';

  @override
  String get routeDetails => 'تفاصيل الطريق';

  @override
  String get travelDays => 'الأيام';

  @override
  String get travelTime => 'الوقت';

  @override
  String get saveRoute => 'حفظ';

  @override
  String get haveACode => 'عندك كود؟';

  @override
  String get redeemItHere => 'حطه هنا وهات النقاط!';

  @override
  String get redeemCode => 'تفعيل الكود';

  @override
  String get enterYourCode => 'حط كود الهدية هنا';

  @override
  String get codePlaceholder => 'مثال: RAMADAN2024';

  @override
  String get redeem => 'فعل';

  @override
  String get codeRedeemedSuccess => 'تفعل الكود يا وحش!';

  @override
  String youReceivedPoints(Object points) {
    return 'جاك $points نقطة!';
  }

  @override
  String get redeemReward => 'استبدال';

  @override
  String get confirmRedemption => 'متأكد تبي تستبدل؟';

  @override
  String get notEnoughPoints => 'نقاطك ما تكفي';

  @override
  String get redemptionSuccessful => 'تم الاستبدال! عليك بالعافية.';

  @override
  String get yourVoucherCode => 'هذا كود الخصم:';

  @override
  String get cost => 'التكلفة';

  @override
  String get khawiJuniorTitle => 'خاوي جونيور';

  @override
  String get khawiJuniorDescription => 'مشاوير آمنة لعيالك.';

  @override
  String get khawiJuniorWelcome => 'هلا فيك بخاوي جونيور';

  @override
  String get khawiJuniorDisclaimer =>
      'هالخدمة قايمة على الثقة. احنا نوفر المنصة، بس المسؤولية الأولى على الأهل والكباتن. تكفون انتبهوا واستخدموها صح.';

  @override
  String get safetyFirst => 'السلامة أول شي';

  @override
  String get parentSafetyInstruction1 =>
      'شيك على هوية الكابتن وسيارتة قبل يركب طفلك.';

  @override
  String get parentSafetyInstruction2 =>
      'تواصل مع الكابتن وتأكد من تفاصيل المشوار.';

  @override
  String get parentSafetyInstruction3 => 'تابع المشوار لايف وشاركه مع الأهل.';

  @override
  String get parentSafetyInstruction4 => 'علم طفلك كيف ينتبه لنفسه وهو راكب.';

  @override
  String get guardianDriverSafetyInstruction1 =>
      'سواقتك الهادية والنظامية هي أهم شي.';

  @override
  String get guardianDriverSafetyInstruction2 =>
      'تأكد ان كراسي الأطفال موجودة ومربوطة صح.';

  @override
  String get guardianDriverSafetyInstruction3 =>
      'لا تمشي لين تتأكد من هوية الطفل ووين رايح.';

  @override
  String get guardianDriverSafetyInstruction4 => 'خلك على تواصل مع الأهل دايم.';

  @override
  String get iUnderstandAndAgree => 'فهمت وموافق';

  @override
  String get chooseYourRole => 'وش دورك في خاوي جونيور؟';

  @override
  String get imAParent => 'أنا ولي أمر';

  @override
  String get imAParentDescription => 'أبي أرتب مشوار لطفلي.';

  @override
  String get imAGuardianDriver => 'سائقة (أم)';

  @override
  String get imAGuardianDriverDescription => 'بوصل عيالي ويمديني أوصل غيرهم.';

  @override
  String get imAFamilyDriver => 'سائق خاص';

  @override
  String get imAFamilyDriverDescription => 'عندي دعوة من ولي أمر.';

  @override
  String get noDriverInviteMessage => 'ما عندك ملف. خل المعزب يدعوك أول.';

  @override
  String get guardianDriverIneligible =>
      'عذراً، هالميزة بس للأمهات المسجلات كسائقات عشان الأمان.';

  @override
  String get juniorHubParentTitle => 'مشاوير العيال';

  @override
  String get juniorHubDriverTitle => 'كاربول العيال';

  @override
  String get currentTrip => 'المشوار الحالي';

  @override
  String get trackRide => 'تتبع المشوار';

  @override
  String get myChildren => 'عيالي';

  @override
  String get addChild => 'إضافة طفل';

  @override
  String get scheduleNewRide => 'حجز مشوار جديد';

  @override
  String get enRouteToSchool => 'رايحين للمدرسة';

  @override
  String get arrivedAtSchool => 'وصلوا للمدرسة';

  @override
  String get enRouteHome => 'راجعين للبيت';

  @override
  String get arrivedHome => 'وصلوا البيت';

  @override
  String notificationArrivedAtSchool(Object name) {
    return 'وصل $name للمدرسة بالسلامة! جاك 50 نقطة يا بطل!';
  }

  @override
  String notificationArrivedHome(Object name) {
    return 'قرت عينك! وصل $name للبيت. 50 نقطة مكافأة لك!';
  }

  @override
  String get yourChild => 'طفلك';

  @override
  String get incomingRequests => 'طلبات الدخول';

  @override
  String get manageYourRoute => 'إدارة المسار';

  @override
  String get guardianDriverNotice =>
      'ملاحظة: ما يمديك تقبلين إلا أطفال من نفس مدرسة عيالك.';

  @override
  String get kidsRideHubEncouragement =>
      'كل مشوار تشاركينه هو فزعة ومساهمة حلوة!';

  @override
  String kidsRewardsTitle(Object name) {
    return 'مكافآت $name';
  }

  @override
  String get kidsRewardEncouragement => 'كفو! بدل نقاطك بهدايا تونس.';

  @override
  String get rewardToyCar => 'سيارة لعبة';

  @override
  String get rewardIceCream => 'آيس كريم';

  @override
  String get rewardBookVoucher => 'قسيمة مكتبة';

  @override
  String get kidsRedeemReward => 'استبدال الهدية';

  @override
  String get kidsRedemptionSuccessful => 'يا سلام! جتك الهدية.';

  @override
  String get scheduleRideComingSoon => 'الحجوزات جاية قريب!';

  @override
  String get trackingRideTitle => 'وينهم الحين؟';

  @override
  String get driver => 'الكابتن';

  @override
  String get myDriver => 'سائقي الخاص';

  @override
  String get addYourDriver => 'أضف سائقك';

  @override
  String get driverDetailsPrompt => 'حط بيانات السائق عشان تتبع مشاويره.';

  @override
  String get addDriverScreenTitle => 'إضافة السائق';

  @override
  String get driverName => 'اسم السائق';

  @override
  String get driverPhone => 'جوال السائق';

  @override
  String get saveDriver => 'حفظ';

  @override
  String get appointedDriverDashboardTitle => 'لوحة السائق الخاص';

  @override
  String get yourTotalPoints => 'نقاطك';

  @override
  String get currentTripFor => 'مشوار لـ';

  @override
  String get guardianDriverPointsNotice =>
      'تذكير: وأنتم بالسيارة، كلكم تكسبون نقاط سوا!';

  @override
  String get manageMyDriver => 'إدارة السائق';

  @override
  String get inviteYourDriver => 'اعزم سائقك';

  @override
  String get inviteDriverPrompt => 'سوي ملف لسائقك عشان يجمع نقاط وتتابعه.';

  @override
  String get sendInvitation => 'أرسل الدعوة';

  @override
  String get todaysSchedule => 'جدول اليوم';

  @override
  String get startTrip => 'ابدأ';

  @override
  String get callParent => 'كلم الأهل';

  @override
  String get tripToSchool => 'مشوار المدرسة';

  @override
  String get tripHome => 'الرجعة للبيت';

  @override
  String get switchToDriverView => 'واجهة السائق (تجربة)';

  @override
  String get switchToParentView => 'واجهة ولي الأمر';

  @override
  String get startInstantTrip => 'ابدأ مشوار فوري';

  @override
  String get instantTripDescription => 'للمشاوير السريعة مع الربع';

  @override
  String get scanToJoin => 'امسح واركب';

  @override
  String get instantTripTitle => 'مشوار فوري';

  @override
  String get showQrToPassengers => 'ورهم الكود عشان يركبون معك:';

  @override
  String get passengersJoined => 'اللي ركبوا';

  @override
  String get startTheTrip => 'توكلنا على الله';

  @override
  String get scanInstructions => 'امسح كود الكابتن واركب علطول';

  @override
  String get simulatedScan => 'تجربة المسح';

  @override
  String get whereTo => 'وين رايحين؟';

  @override
  String get smartMatchTitle => 'توصيل ذكي';

  @override
  String get instantRide => 'فوري';

  @override
  String get scheduleTrip => 'حجز';

  @override
  String get findingMatch => 'ندور لك خوي...';

  @override
  String get receivingRequests => 'نستقبل الطلبات...';

  @override
  String get goOnlineToEarn => 'اتصل وابدأ جمع النقاط';

  @override
  String get todaysEarnings => 'صيد اليوم (XP)';

  @override
  String get ridesToday => 'مشاوير اليوم';

  @override
  String get juniorHubTitle => 'مركز الصغار';

  @override
  String get safeStatus => 'وضعك بالسليم!';

  @override
  String get rideInProgress => 'المشوار شغال';

  @override
  String get noActiveRide => 'ما فيه مشوار الحين';

  @override
  String get requestRide => 'اطلب مشوار';

  @override
  String get playGames => 'لعب';

  @override
  String get yourRewards => 'هداياك';

  @override
  String get simulateRide => 'تخيل مشوار مدرسة';

  @override
  String get safetyRulesTitle => 'أهم شي السلامة!';

  @override
  String get safetyDescription => 'خلك ذيب وانتبه لهالقواعد:';

  @override
  String get safetyRule1 => 'الحزام، ثم الحزام';

  @override
  String get safetyRule2 => 'لا تسولف مع غرباء';

  @override
  String get safetyRule3 => 'كلم أهلك لو حسيت بشي غلط';

  @override
  String get iUnderstand => 'فهمت يا كابتن';

  @override
  String get profileTitle => 'ملفي';

  @override
  String get helpSupport => 'المساعدة';

  @override
  String get xpLedgerTitle => 'سجل النقاط';

  @override
  String get currentBalance => 'رصيدك';

  @override
  String get addFunds => 'شحن';

  @override
  String get rewardsTitle => 'المكافآت';

  @override
  String get yourXP => 'نقاطك';

  @override
  String get redeemRewards => 'استبدال';

  @override
  String get sundayShort => 'ح';

  @override
  String get mondayShort => 'ن';

  @override
  String get tuesdayShort => 'ث';

  @override
  String get wednesdayShort => 'ر';

  @override
  String get thursdayShort => 'خ';

  @override
  String get kidsCarpoolTitle => 'توصيل الصغار';

  @override
  String get myCircles => 'قروباتي';

  @override
  String get findPools => 'دور قروب';

  @override
  String get createCircle => 'سوي قروب';

  @override
  String get noCirclesJoined => 'ما دخلت قروب لسا';

  @override
  String get members => 'الأعضاء';

  @override
  String get viewDetails => 'التفاصيل';

  @override
  String get searchNearbyPools => 'شوف القروبات اللي حولك';

  @override
  String get enterSchoolOrClub => 'اسم المدرسة أو النادي';

  @override
  String get invitationSent => 'أرسلنا الدعوة!';

  @override
  String get fillAllFields => 'عب كل الخانات لاهنت';

  @override
  String get continueText => 'كمل';

  @override
  String get driverRoleRequiredTitle => 'لازم تكون كابتن';

  @override
  String get driverRoleRequiredMessage =>
      'عشان تسوي باركود، لازم تكون كابتن موثق. حول دورك لـ \"كابتن\" وكمل.';

  @override
  String get passengerConductTitle => 'قوانين الركاب';

  @override
  String get driverConductTitle => 'قوانين الكباتن';

  @override
  String get juniorSafetyTitle => 'قوانين خاوي جونيور';

  @override
  String get passengerRule1 => 'خلك على الوقت ومحترم.';

  @override
  String get passengerRule2 => 'تأكد من كل شي قبل تركب.';

  @override
  String get zeroToleranceRule => 'ما عندنا تفاهم مع قلة الأدب أو التحرش.';

  @override
  String get driverRule1 => 'هذي فزعة مجتمعية (توصيلة مو تاكسي).';

  @override
  String get driverRule2 => 'نظام المرور خط أحمر.';

  @override
  String get juniorRule1 => 'سلامة العيال أهم شي.';

  @override
  String get juniorRule2 => 'بس الأهل والسواقين المعتمدين يشاركون.';

  @override
  String get juniorRule3 => 'بنشغل التتبع عشان نتطمن عليكم.';

  @override
  String get verificationScreenTitle => 'توثيق الهوية';

  @override
  String get verifyWithNafath => 'وثق عبر نفاذ';

  @override
  String get verificationRationale =>
      'عشان نضمن أن الكل ثقة، لازم توثيق الهوية.';

  @override
  String get connectWithNafath => 'ربط مع نفاذ';

  @override
  String get processing => 'لحظات...';

  @override
  String get sessionMissing => 'سجل دخول مرة ثانية لاهنت.';

  @override
  String verificationUpdateFailed(Object error) {
    return 'ما ضبط التوثيق: $error';
  }

  @override
  String get communities => 'المجتمعات';

  @override
  String get myCommunities => 'مجتمعاتي';

  @override
  String get discoverCommunities => 'اكتشف';

  @override
  String get noCommunities => 'ما دخلت مجتمع لسا';

  @override
  String get joinCommunityHint => 'ادخل تبويبة اكتشف ولقّ مجتمعك';

  @override
  String get searchCommunities => 'ابحث عن مجتمع...';

  @override
  String get communityType => 'نوع المجتمع';

  @override
  String get communityNameEn => 'اسم المجتمع (إنجليزي)';

  @override
  String get communityNameAr => 'اسم المجتمع (عربي)';

  @override
  String get createCommunity => 'سوّي مجتمع';

  @override
  String get leaveCommunity => 'اطلع';

  @override
  String get joinCommunity => 'ادخل';

  @override
  String get activeRides => 'مشاوير نشطة';

  @override
  String get verified => 'موثّق';

  @override
  String get communityRideBoard => 'لوحة المشاوير';

  @override
  String get noRidesYet => 'ما فيه مشاوير لسا';

  @override
  String get moreSocial => 'اجتماعي';

  @override
  String get eventRides => 'مشاوير الفعاليات';

  @override
  String get searchEvents => 'ابحث عن فعالية...';

  @override
  String get all => 'الكل';

  @override
  String get featuredEvents => 'فعاليات مميزة';

  @override
  String get upcomingEvents => 'فعاليات قادمة';

  @override
  String get noUpcomingEvents => 'ما فيه فعاليات قادمة';

  @override
  String get interested => 'مهتم';

  @override
  String get ridesAvailable => 'مشاوير';

  @override
  String get expected => 'متوقع';

  @override
  String get going => 'رايح';

  @override
  String get goingTo => 'رايحين';

  @override
  String get returning => 'راجعين';

  @override
  String get beFirstToOfferRide => 'كن أول من يعرض مشوار! 🚗';

  @override
  String get errorGeneric => 'حدث خطأ، حاول مرة ثانية';

  @override
  String get description => 'الوصف';

  @override
  String get required => 'مطلوب';

  @override
  String get continueAs => 'متابعة كـ';

  @override
  String get passengerHeroTitle => 'إلى وين مشوارنا؟';

  @override
  String get passengerHeroSubtitle => 'وصول سريع، كباتن موثوقين، ومشاوير أسهل.';

  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء الخير';

  @override
  String get statusQuickPickup => 'وصول سريع';

  @override
  String get statusTrustedRides => 'كباتن ثقة';

  @override
  String get quickDestHome => 'البيت';

  @override
  String get quickDestWork => 'الدوام';

  @override
  String get quickDestSchool => 'المدرسة';

  @override
  String get quickDestAirport => 'المطار';

  @override
  String get demandNormal =>
      'الطلب طبيعي في منطقتك. الوقت المتوقع للوصول 3-6 دقائق.';

  @override
  String get demandStatusStable => 'مستقر';

  @override
  String get driversNearby => 'عدة كباتن موثوقين قريبين منك الآن.';

  @override
  String get driversNearbyFastLane => 'مسار سريع';

  @override
  String get shortcutSavedPlaces => 'أماكن محفوظة';

  @override
  String get shortcutSavedPlacesSubtitle => 'بضغطة زر';

  @override
  String get shortcutRepeatLastTrip => 'إعادة آخر مشوار';

  @override
  String get shortcutRepeatLastTripSubtitle => 'حجز سريع';

  @override
  String get shortcutFamilyRide => 'مشوار عائلي';

  @override
  String get shortcutFamilyRideSubtitle => 'شارك تفاصيل الرحلة';

  @override
  String get recentPlaceTileKingFahad => 'طريق الملك فهد';

  @override
  String get recentPlaceTileKingFahadSubtitle => 'آخر مشوار - قبل 9 دقائق';

  @override
  String get recentPlaceTileBusinessGate => 'بوابة الأعمال';

  @override
  String get recentPlaceTileBusinessGateSubtitle => 'وجهة متكررة';

  @override
  String get recentPlaceTileParkMall => 'الرياض بارك مول';

  @override
  String get recentPlaceTileParkMallSubtitle => 'رائج في هذا الوقت';

  @override
  String get serviceTierSaver => 'خاوي توفير';

  @override
  String get serviceTierSaverEta => '3-5 دقائق';

  @override
  String get serviceTierSaverHint => 'أفضل سعر';

  @override
  String get serviceTierComfort => 'خاوي راحة';

  @override
  String get serviceTierComfortEta => '5-8 دقائق';

  @override
  String get serviceTierComfortHint => 'مشوار هادئ';

  @override
  String get serviceTierWomenPlus => 'سيدات+';

  @override
  String get serviceTierWomenPlusEta => '4-7 دقائق';

  @override
  String get serviceTierWomenPlusHint => 'المطابقة المفضلة';

  @override
  String get serviceTierRecommended => 'موصى به';

  @override
  String get etaPickupTitle => 'وقت الوصول المتوقع';

  @override
  String get etaPickupValue => '4 دقائق';

  @override
  String get routeReliabilityTitle => 'موثوقية الطريق';

  @override
  String get routeReliabilityValue => 'عالية';

  @override
  String get safetyScoreTitle => 'تقييم الأمان';

  @override
  String get safetyScoreValue => 'A+';

  @override
  String get routePreviewPickup => 'وصلني من موقعي';

  @override
  String get routePreviewDropoff => 'أحدد الوجهة لاحقاً';

  @override
  String get rideNowLabel => 'أحجز الآن';

  @override
  String get rideLaterLabel => 'لاحقاً';

  @override
  String get rideNowHint =>
      'الحجز الآن يوفر أسرع وقت وصول وأفضل تسعيرة في منطقتك.';

  @override
  String get prefNoConversation => 'بدون سوالف';

  @override
  String get prefCoolAC => 'مكيف بارد';

  @override
  String get prefWomenOnly => 'للسيدات فقط';

  @override
  String get prefExtraLuggage => 'عفش زيادة';

  @override
  String get confidenceTrustedDriverTitle => 'كباتن موثوقين';

  @override
  String get confidenceTrustedDriverSubtitle =>
      'فقط الكباتن المعتمدين يمكنهم قبول مشاويرك.';

  @override
  String get confidenceLiveRoutingTitle => 'تتبع الرحلة مباشر';

  @override
  String get confidenceLiveRoutingSubtitle =>
      'تتبع حالة رحلتك من الركوب حتى الوصول.';

  @override
  String get confidenceFastSupportTitle => 'وصول سريع للدعم';

  @override
  String get confidenceFastSupportSubtitle =>
      'تواصل مع الدعم الفني بسرعة من أي رحلة نشطة.';

  @override
  String get weeklyChallengesTitle => 'تحديات الأسبوع';

  @override
  String get challengeRiyadhExplorer => 'مستكشف الرياض';

  @override
  String get challengeRiyadhExplorerDesc =>
      'أكمل 5 مشاوير داخل الرياض هذا الأسبوع';

  @override
  String get challengeRiyadhExplorerXp => '200 نقطة';

  @override
  String get challengeEcoPioneer => 'رائد البيئة';

  @override
  String get challengeEcoPioneerDesc =>
      'وفّر 10 كجم من انبعاثات الكربون عبر مشاركة مشاويرك';

  @override
  String get challengeEcoPioneerXp => '500 نقطة';

  @override
  String get challengeSafetyFirst => 'السلامة أولاً';

  @override
  String get challengeSafetyFirstDesc => 'حافظ على تقييم 5 نجوم لـ 10 رحلات';

  @override
  String get challengeSafetyFirstXp => '1000 نقطة';

  @override
  String challengePercentComplete(int percent) {
    return '$percent% مكتمل';
  }

  @override
  String get eventRamadanBonus => 'مكافأة مشاوير رمضان';

  @override
  String get eventRamadanBonusDesc => 'ضعف النقاط لكل رحلات وقت الإفطار';

  @override
  String get eventRamadanBonusStart => 'تبدأ بعد يومين';

  @override
  String get juniorIntroTitle => 'خاوي جونيور';

  @override
  String get juniorIntroSubtitle => 'مشاوير آمنة لراحة بالك';

  @override
  String get juniorSafetyPoint => 'فقط كباتن موثوقين (أولياء أمور)';

  @override
  String get juniorFamilyPoint => 'أضف السائق الخاص بعائلتك';

  @override
  String get juniorTrackingPoint => 'تتبع لايف';

  @override
  String get juniorContinue => 'كمل';

  @override
  String get juniorNotParent => 'لست ولي أمر؟';

  @override
  String get juniorRoleTitle => 'اختر دورك';

  @override
  String get juniorRoleGuardian => 'ولي أمر';

  @override
  String get juniorRoleGuardianDesc => 'إدارة مشاوير أبنائك';

  @override
  String get juniorRoleDriver => 'سائق العائلة';

  @override
  String get juniorRoleDriverDesc => 'تمت دعوتك للقيادة';

  @override
  String get juniorDashboardTitle => 'لوحة جونيور';

  @override
  String get juniorAddKid => 'إضافة طفل';

  @override
  String get juniorMyKids => 'أطفالي';

  @override
  String get juniorNoKids => 'لم تتم إضافة أطفال بعد.';

  @override
  String get juniorActiveRuns => 'المشاوير الحالية';

  @override
  String get juniorFeatureInProgress => 'الميزة قيد التطوير';

  @override
  String get juniorNoActiveRuns => 'لا توجد رحلات نشطة';

  @override
  String get juniorCreateRunWithHub =>
      'أنشئ رحلة من المركز وشارك كود الدعوة مع السائق';

  @override
  String get juniorGoToHub => 'انتقل للمركز';
}
