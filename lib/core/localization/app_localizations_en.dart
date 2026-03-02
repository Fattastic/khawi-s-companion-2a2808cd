// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Khawi';

  @override
  String get appNameEn => 'Khawi';

  @override
  String get splashTagline => 'Khawi! And reduce traffic, for you and for us.';

  @override
  String get onboardingSlide1Title => 'Share the road and reduce traffic.';

  @override
  String get onboardingSlide2Title => 'Earn points for every kilometer.';

  @override
  String get onboardingSlide3Title => 'Multiply your points during peak hours!';

  @override
  String get onboardingSlide4Title => 'Zero Commission. 100% Community.';

  @override
  String get onboardingZeroCommissionDescription =>
      'We charge 0% commission. Usage is free, subscription is only for rewards.';

  @override
  String get onboardingCarOwnerTitle => 'Do you own a car?';

  @override
  String get onboardingSubscriptionTitle =>
      'Turn Points into Rewards with Khawi+';

  @override
  String get onboardingSubscriptionDescription =>
      'Finding rides is always free. Subscribe to turn your XP into coffee, fuel, and more.';

  @override
  String get oneRiyalADay => 'For just 1 Riyal a day';

  @override
  String get billedMonthly => '(Billed as 30 SAR monthly)';

  @override
  String get next => 'Next';

  @override
  String get getStarted => 'Get Started!';

  @override
  String get skip => 'Skip';

  @override
  String get retry => 'Retry';

  @override
  String get seeAll => 'See all';

  @override
  String get offerNewRide => 'Offer New Ride';

  @override
  String get todaySummary => 'Today';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get map => 'Map';

  @override
  String get findRide => 'Find a ride';

  @override
  String get whereAreYouGoing => 'Where are you going today?';

  @override
  String get xpLedger => 'XP Ledger';

  @override
  String get xpLedgerHistory => 'XP History';

  @override
  String get xpLedgerRecentActivity => 'Recent Activity';

  @override
  String get xpLedgerNoActivityYet => 'No XP activity yet';

  @override
  String get xpLedgerEarnXpHint => 'Complete rides to earn XP!';

  @override
  String get redeemableXpLabel => 'REDEEMABLE XP';

  @override
  String get somethingWentWrong => 'Something went wrong';

  @override
  String get khawiPlusRequired => 'Khawi+ Required';

  @override
  String get khawiPlusMonthlyPrice => '30 SAR/month';

  @override
  String xpLedgerUpsellBody(String price) {
    return 'Subscribe to Khawi+ ($price) to redeem your XP for real rewards.';
  }

  @override
  String get redeemXp => 'Redeem XP';

  @override
  String get promoCodes => 'Promo Codes';

  @override
  String get subscribeToKhawiPlusToRedeem => 'Subscribe to Khawi+ to Redeem';

  @override
  String xpLedgerMultiplierActive(String multiplier) {
    return '${multiplier}x XP Multiplier Active';
  }

  @override
  String xpLedgerMultiplierShort(String multiplier) {
    return '${multiplier}x XP';
  }

  @override
  String xpLedgerApproxValue(String value) {
    return 'Approx value ~ $value';
  }

  @override
  String get errorLoadingHistory => 'Error loading history';

  @override
  String get errorLoadingTransactions => 'Error loading transactions';

  @override
  String get hello => 'Hello!';

  @override
  String homeGreetingWithName(Object name) {
    return 'Good morning, $name!';
  }

  @override
  String get communityXp => 'Community XP';

  @override
  String get aiOptimizedRoute => 'AI Optimized Route';

  @override
  String get startRoute => 'Start Route';

  @override
  String get stop => 'Stop';

  @override
  String get pickup => 'Pickup';

  @override
  String get dropoff => 'Dropoff';

  @override
  String activePassengersCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active passengers',
      many: '$count active passengers',
      few: '$count active passengers',
      one: '1 active passenger',
      zero: 'No active passengers',
    );
    return '$_temp0';
  }

  @override
  String get rideStatusAccepted => 'Status: Accepted';

  @override
  String get optimizing => 'Optimizing...';

  @override
  String get bundleStopsAi => 'Bundle Stops (AI)';

  @override
  String get passengerRequest => 'Passenger Request';

  @override
  String matchScore(Object percent) {
    return 'Match Score: $percent%';
  }

  @override
  String get rides => 'Rides';

  @override
  String get rating => 'Rating';

  @override
  String get languageArabic => 'Arabic';

  @override
  String get languageEnglish => 'English';

  @override
  String get onboardingSlide2Description =>
      'XP, badges, weekly challenges… and real rewards.';

  @override
  String get onboardingSlide3Description =>
      'Incentives that reduce congestion and emissions.';

  @override
  String get noRequestsRightNow => 'No requests right now';

  @override
  String get stayOnlineForRequests =>
      'Stay online and new requests will appear here.';

  @override
  String get youAreOnline => 'You are Online';

  @override
  String get youAreOffline => 'You are Offline';

  @override
  String get planner => 'Planner';

  @override
  String get instantQr => 'Instant QR';

  @override
  String get queue => 'Queue';

  @override
  String get regular => 'Regular';

  @override
  String get couldNotLoadSummary => 'Couldn\'t load your summary';

  @override
  String get checkConnectionAndTryAgain =>
      'Check your connection and try again.';

  @override
  String get noInternetConnection => 'No internet connection';

  @override
  String get loginTitle => 'Login or Create Account';

  @override
  String get loginSubtitle => 'Welcome to Khawi! Let\'s begin.';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get continueAction => 'Continue';

  @override
  String get phoneInvalidError => 'Please enter a valid phone number';

  @override
  String get otpChangePhoneTooltip => 'Change phone number';

  @override
  String get otpChangeNumberTitle => 'Change Number';

  @override
  String get otpVerificationTitle => 'Verification';

  @override
  String get otpVerificationSubtitle =>
      'Enter the 6-digit code we sent to your phone';

  @override
  String get otpCodeLabel => 'Verification Code';

  @override
  String get otpVerifyCta => 'Verify';

  @override
  String get otpInvalidCodeError => 'Please enter the 6-digit code';

  @override
  String get emailAuthTitleLogin => 'Email Login';

  @override
  String get emailAuthTitleSignup => 'Create Account';

  @override
  String get emailAuthSubtitle => 'Use your email and password';

  @override
  String get emailLabel => 'Email';

  @override
  String get passwordLabel => 'Password';

  @override
  String get emailInvalidError => 'Please enter a valid email';

  @override
  String passwordTooShortError(String min) {
    return 'Password must be at least $min characters';
  }

  @override
  String get checkEmailToConfirmAccount =>
      'Check your email to confirm your account.';

  @override
  String get signIn => 'Sign in';

  @override
  String get signUp => 'Sign up';

  @override
  String get alreadyHaveAccountSignIn => 'Already have an account? Sign in';

  @override
  String get noAccountCreateOne => 'No account? Create one';

  @override
  String get errorTitle => 'Error';

  @override
  String get ok => 'OK';

  @override
  String get liveTripTitle => 'Live Trip';

  @override
  String liveTripRiskLabel(String percent) {
    return 'Risk: $percent%';
  }

  @override
  String get liveTripCriticalAlertTitle => 'CRITICAL SAFETY ALERT';

  @override
  String get liveTripSafetyWarningTitle => 'Safety Warning';

  @override
  String liveTripUnusualActivityMessage(String flags) {
    return 'Our system has detected unusual trip activity ($flags). Support has been notified.';
  }

  @override
  String get liveTripSosSent => 'SOS sent! Emergency contacts notified.';

  @override
  String liveTripSosFailed(String error) {
    return 'SOS failed: $error';
  }

  @override
  String get liveTripSosCta => 'SOS - EMERGENCY HELP';

  @override
  String get liveTripSending => 'Sending...';

  @override
  String get or => 'OR';

  @override
  String get continueWithGoogle => 'Continue with Google';

  @override
  String get continueWithApple => 'Continue with Apple';

  @override
  String get loginWithAbsher => 'Login with Absher (for drivers)';

  @override
  String get byContinuingYouAgree => 'By continuing, you agree to our';

  @override
  String get termsOfService => 'Terms of Service';

  @override
  String get and => 'and';

  @override
  String get privacyPolicy => 'Privacy Policy';

  @override
  String get verificationTitle => 'A Step Towards a Safe Community';

  @override
  String get verificationDescription =>
      'We care about your safety. Account verification helps us build a trustworthy community for everyone. For drivers, verification via Absher is required.';

  @override
  String get verificationButton => 'Got it, let\'s continue';

  @override
  String get driverVerificationAppBarTitle => 'Driver Verification';

  @override
  String get driverVerificationNotNow => 'Not now';

  @override
  String get driverVerificationHeader =>
      'Driver Identity & Vehicle Verification';

  @override
  String get driverVerificationBody =>
      'To ensure safety for all users, we need to verify your identity and vehicle ownership.';

  @override
  String get driverVerificationIdentityTitle => 'Identity Verification';

  @override
  String get driverVerificationIdentitySubtitle =>
      'Via National Unified Access (Nafath)';

  @override
  String get driverVerificationVehicleTitle => 'Vehicle Ownership Verification';

  @override
  String get driverVerificationVehicleSubtitle =>
      'Confirm vehicle ownership via official systems or documents';

  @override
  String get driverVerificationStatusVerified => 'Verified';

  @override
  String get driverVerificationStatusApproved => 'Approved';

  @override
  String get driverVerificationStatusPending => 'Pending review';

  @override
  String get driverVerificationStatusNotVerified => 'Not verified';

  @override
  String get driverVerificationActionVerifyWithNafath => 'Verify with Nafath';

  @override
  String get driverVerificationActionVerifyVehicle => 'Verify Vehicle';

  @override
  String get driverVerificationContinue => 'Continue to Driver Dashboard';

  @override
  String get driverVerificationPendingNotice =>
      'Your documents are under review. You will be notified when verification is complete. In the meantime, you can use Khawi as a passenger.';

  @override
  String get driverVerificationVehicleDetailsTitle => 'Vehicle Details';

  @override
  String get driverVerificationPlateLabel => 'Plate Number';

  @override
  String get driverVerificationPlateHint => 'e.g. ABC 1234';

  @override
  String get driverVerificationModelLabel => 'Vehicle Model';

  @override
  String get driverVerificationModelHint => 'e.g. Toyota Camry 2023';

  @override
  String get driverVerificationVehicleLaterNote =>
      'Istimara photo and selfie verification will be requested later.';

  @override
  String get driverVerificationSubmitForReview => 'Submit for Review';

  @override
  String get driverVerificationFillVehicleFieldsError =>
      'Please fill in all vehicle fields';

  @override
  String get driverVerificationDataDisclosureTitle => 'Data Disclosure';

  @override
  String get driverVerificationDisclosureIdentity =>
      'Your national identity will be verified via Nafath.';

  @override
  String get driverVerificationDisclosureVehicle =>
      'Vehicle ownership will be checked via official systems or submitted documents.';

  @override
  String get driverVerificationDisclosurePurpose =>
      'Purpose: Ensuring safety and trust for all users.';

  @override
  String get driverVerificationDisclosureRetention =>
      'Data is retained per our privacy policy.';

  @override
  String get driverVerificationConsentCheckbox =>
      'I consent to my data being verified for the purposes above';

  @override
  String get driverVerificationConsentNeeded =>
      'Please accept the data disclosure first';

  @override
  String get driverVerificationVerificationFailed => 'Verification failed';

  @override
  String get roleSelectionTitle => 'Welcome to Khawi!';

  @override
  String get safetyDisclaimerTitle => 'Safety & Rules';

  @override
  String get safetyDisclaimerBody =>
      'By tapping “I Agree”, you confirm you will follow these safety rules:\n\n• Follow local laws and the app’s instructions.\n• Always wear a seatbelt.\n• No harassment, abuse, or unsafe behavior.\n• Respect privacy — do not record others without consent.\n• For kids rides: the responsible adult must ensure safe seating and supervision.\n• In emergencies, contact local authorities.';

  @override
  String get safetyDisclaimerAgree => 'I Agree';

  @override
  String get safetyDisclaimerDecline => 'I Do Not Agree';

  @override
  String get subscriptionTagline =>
      'Usage is free. Subscription converts Points.';

  @override
  String get iAmADriver => 'Driver';

  @override
  String get driverDescription => 'Sharing my usual route';

  @override
  String get iAmAPassenger => 'Passenger';

  @override
  String get passengerDescription => 'Joining a driver\'s route';

  @override
  String get roleJuniorTitle => 'Khawi Junior';

  @override
  String get roleJuniorDescription => 'Safe and trusted rides for your kids.';

  @override
  String get homeGreeting => 'Good morning!';

  @override
  String get homeTitle => 'Ready for your ride?';

  @override
  String get searchForARide => 'Search for a ride';

  @override
  String get kmShared => 'Km Shared';

  @override
  String get co2Saved => 'CO₂ Saved';

  @override
  String get points => 'Points';

  @override
  String get peakHoursActive => '3x XP Peak Hours!';

  @override
  String get smartMatchAI => 'SmartMatch AI';

  @override
  String get routeOverlap => 'Route Overlap';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get now => 'Now';

  @override
  String get leaveAsap => 'Leave as soon as possible';

  @override
  String get change => 'Change';

  @override
  String get filters => 'Filters';

  @override
  String get womenOnly => 'Women Only';

  @override
  String get kidsAllowed => 'Kids Allowed';

  @override
  String get sameNeighborhood => 'Same Neighborhood';

  @override
  String get noRideSelected => 'No ride selected.';

  @override
  String get back => 'Back';

  @override
  String get eta => 'Arrival';

  @override
  String get projectedXp => 'Projected Points';

  @override
  String get peakHours => 'Peak hours!';

  @override
  String get xp => 'XP';

  @override
  String get rideNow => 'Ride Now';

  @override
  String get noCurrentRide => 'No current ride.';

  @override
  String get backToHome => 'Back to Home';

  @override
  String get arrivingAt => 'Arriving at';

  @override
  String get endTripForDemo => 'End Trip (for demo)';

  @override
  String get noCompletedRide => 'No completed ride.';

  @override
  String get rideCompleted => 'Ride Completed!';

  @override
  String postRideEarningsMessage(String xp) {
    return 'You earned $xp XP for this journey. Thank you for choosing Khawi!';
  }

  @override
  String get rateYourRide => 'Rate your ride';

  @override
  String get ratingThanks => 'Thanks for your rating!';

  @override
  String get driverLabel => 'Driver';

  @override
  String get youEarned => 'You earned';

  @override
  String rateDriver(Object name) {
    return 'Rate $name';
  }

  @override
  String get done => 'Done';

  @override
  String get navHome => 'Home';

  @override
  String get navActivity => 'Activity';

  @override
  String get navHub => 'Hub';

  @override
  String get navTracking => 'Tracking';

  @override
  String get rewardDetails => 'Reward Details';

  @override
  String get instantTripQrTitle => 'Instant Trip QR';

  @override
  String get juniorTrackRuns => 'Track runs';

  @override
  String get familyDriverTitle => 'Family Driver';

  @override
  String get newRegularRouteTitle => 'New Regular Route';

  @override
  String get navMore => 'More';

  @override
  String get navRewards => 'Rewards';

  @override
  String get navProfile => 'Profile';

  @override
  String get activityLog => 'Activity Log';

  @override
  String get tripHistory => 'Trip History';

  @override
  String get pointsHistory => 'Points History';

  @override
  String tripWith(Object name) {
    return 'Trip with $name';
  }

  @override
  String get redeemedCoffee => 'Redeemed Coffee';

  @override
  String get friendReferralBonus => 'Friend Referral Bonus';

  @override
  String get driverRewards => 'Driver Rewards';

  @override
  String get rewardsAndLeaderboard => 'Rewards & Leaderboard';

  @override
  String get yourLevel => 'Your Level';

  @override
  String get availableRewards => 'Available Rewards';

  @override
  String get rewards => 'Rewards';

  @override
  String get leaderboard => 'Leaderboard';

  @override
  String get you => 'You';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get notifications => 'Notifications';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get morePremiumSection => 'Khawi+';

  @override
  String get moreAccountSettings => 'Account Settings';

  @override
  String get morePersonalInformation => 'Personal Information';

  @override
  String get moreSwitchRole => 'Switch Role';

  @override
  String get moreXpLedgerPassengerOnly =>
      'XP Ledger is available for passengers only.';

  @override
  String get moreGeneral => 'General';

  @override
  String get moreHelpCenter => 'Help Center';

  @override
  String get moreInviteFriends => 'Invite Friends';

  @override
  String get moreAboutKhawi => 'About Khawi';

  @override
  String get moreUpgradeToPremium => 'Upgrade to Khawi+';

  @override
  String get morePremiumSubtitle => 'Unlock rewards and 1.5x XP multiplier.';

  @override
  String get moreComingSoon => 'Coming soon';

  @override
  String get referralTitle => 'Invite a friend, earn 300 XP!';

  @override
  String get referralDescription =>
      'Share your referral code and get a bonus when your friend completes their first ride.';

  @override
  String get shareNow => 'Share Now';

  @override
  String get logout => 'Logout';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get welcomeCaptain => 'Welcome, Captain!';

  @override
  String get kmThisWeek => 'Km this week';

  @override
  String get totalPoints => 'Total Points';

  @override
  String get totalCo2Saved => 'Total CO₂ Saved';

  @override
  String get smartTips => 'Smart Tips';

  @override
  String get peakAlertTitle => 'Peak Alert!';

  @override
  String get peakAlertDescription =>
      'High demand is expected on King Fahd Rd in 30 mins. Get ready to earn 3x points!';

  @override
  String get passengerRequests => 'Passenger Requests';

  @override
  String newRequestsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count new requests',
      many: '$count new requests',
      few: '$count new requests',
      two: '2 new requests',
      one: '1 new request',
      zero: 'No new requests',
    );
    return '$_temp0';
  }

  @override
  String get waitingForApproval => 'Waiting for your approval';

  @override
  String get navDashboard => 'Dashboard';

  @override
  String get match => 'Match';

  @override
  String get accept => 'Accept';

  @override
  String get decline => 'Decline';

  @override
  String get currentPassenger => 'Current Passenger';

  @override
  String get destination => 'Destination';

  @override
  String get endTrip => 'End Trip';

  @override
  String get upgradeToKhawiPlus => 'Upgrade to Khawi+';

  @override
  String get subscribeToKhawiPlus => 'Subscribe to Khawi+';

  @override
  String get premiumTitle => 'Unlock Exclusive Benefits';

  @override
  String get premiumSubtitle => 'What will you benefit?';

  @override
  String get featureZeroCommissionTitle => 'Zero Commission. 100% Yours.';

  @override
  String get featureZeroCommissionDescription =>
      'We don\'t take 20-25% cuts. We charge a flat fee (30 SAR/mo) so you keep 100% of your earnings.';

  @override
  String get feature15xXpTitle => '1.5x Extra XP';

  @override
  String get feature15xXpDescription =>
      'Earn points faster on every trip you share.';

  @override
  String get featurePriorityMatchingTitle => 'Priority Matching';

  @override
  String get featurePriorityMatchingDescription =>
      'Get the best passenger requests that fit your route first.';

  @override
  String get featureMonthlyRewardsTitle => 'Convert Points to Rewards';

  @override
  String get featureMonthlyRewardsDescription =>
      'Usage is free, but converting points to rewards (coffee, fuel) requires a subscription.';

  @override
  String get featurePremiumBadgeTitle => 'Premium Khawi+ Badge';

  @override
  String get featurePremiumBadgeDescription =>
      'Proudly display your golden badge on your profile.';

  @override
  String get sar => 'SAR';

  @override
  String get monthly => 'monthly';

  @override
  String get subscribeNow => 'Subscribe Now';

  @override
  String get myBadges => 'My Badges';

  @override
  String get zeroAccidents => 'Zero Accidents';

  @override
  String get communityHero => 'Community Hero';

  @override
  String get weeklyChallenges => 'Weekly Challenges';

  @override
  String get earnBonusXp => 'Earn bonus XP!';

  @override
  String get challenges => 'Challenges';

  @override
  String get challengeComplete5Rides => 'Complete 5 rides this week';

  @override
  String get challengeShare100km => 'Share a ride for 100 km';

  @override
  String get challengePeakHourMaster => 'Complete 3 rides during peak hours';

  @override
  String get xpBreakdown => 'XP Breakdown';

  @override
  String get basePoints => 'Base Points';

  @override
  String get peakHourBonus => 'Peak Hour Bonus';

  @override
  String get peakHourBonusExclamation => 'Peak Hour Bonus!';

  @override
  String get passengerBonusDriver => 'Passenger Bonus';

  @override
  String get passengerBonusPassenger => 'Group Bonus';

  @override
  String get synergyBonus => 'Synergy Bonus';

  @override
  String get premiumBonus => 'Khawi+ Bonus';

  @override
  String get ratingBonus => 'Rating Bonus';

  @override
  String get parentBonus => 'Parent Bonus';

  @override
  String get captain => 'Captain';

  @override
  String captainWithName(String name) {
    return 'Captain $name';
  }

  @override
  String get newDriver => 'New Driver';

  @override
  String incentiveActiveInArea(String area, String multiplier) {
    return 'Active in $area: ${multiplier}x XP Multiplier.';
  }

  @override
  String otherActiveZones(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '+$count other active zones',
      many: '+$count other active zones',
      few: '+$count other active zones',
      one: '+1 other active zone',
    );
    return '$_temp0';
  }

  @override
  String stopLabelLine(String type, String label) {
    return '$type: $label';
  }

  @override
  String passengerWithId(String id) {
    return 'Passenger $id';
  }

  @override
  String get total => 'Total';

  @override
  String get numberOfPassengers => 'Number of Passengers';

  @override
  String get setPassengerCapacity => 'Set Passenger Capacity';

  @override
  String get seats => 'Seats';

  @override
  String get redeemableXp => 'Redeemable XP';

  @override
  String get lockedXp => 'Locked XP';

  @override
  String unlockYourXp(Object points) {
    return 'You have $points locked XP!';
  }

  @override
  String get upgradeToUnlock => 'Upgrade to Khawi+ to use them';

  @override
  String get referralProgram => 'Referral Program';

  @override
  String get yourReferralCode => 'Your Referral Code';

  @override
  String get tapToCopy => 'Tap to copy';

  @override
  String get shareYourCode => 'Share Your Code';

  @override
  String get referralStatus => 'Referral Status';

  @override
  String get invited => 'Invited';

  @override
  String get completed => 'Completed 1st Ride';

  @override
  String get notificationSettings => 'Notification Settings';

  @override
  String get pushNotifications => 'Push Notifications';

  @override
  String get allowNotifications => 'Allow Notifications';

  @override
  String get rideRequests => 'Ride Requests';

  @override
  String get xpGains => 'XP Gains';

  @override
  String get peakHourAlerts => 'Peak Hour Alerts';

  @override
  String get appUpdates => 'App Updates';

  @override
  String get open => 'Open';

  @override
  String get chooseYourRoleTitle => 'Choose your role';

  @override
  String get roleSelectionWelcomeTitle =>
      'Welcome! Choose how you want to use Khawi';

  @override
  String get roleSelectionSubtitle =>
      'You can change your role later from your profile.';

  @override
  String get shareYourRegularRoute => 'Share your regular route';

  @override
  String get instantRideSheetDescription =>
      'Scan a QR to join, or create your own code';

  @override
  String get scanQr => 'Scan QR';

  @override
  String get createQr => 'Create QR';

  @override
  String get joinRide => 'Join a ride';

  @override
  String get shareRide => 'Share your ride';

  @override
  String get rulesConsentText =>
      'By continuing, you agree to follow these rules.';

  @override
  String get iAgreeContinue => 'I Agree & Continue';

  @override
  String errorWithMessage(String message) {
    return 'Error: $message';
  }

  @override
  String get khawiPremium => 'KHAWI PREMIUM';

  @override
  String get acceptInstantRides => 'Accept Instant Rides';

  @override
  String get acceptInstantRidesDescription =>
      'Receive requests from passengers near you who need a ride right now.';

  @override
  String get goOnline => 'Go Online';

  @override
  String get howItWorks => 'How it works';

  @override
  String get instantRideStep1 => 'Go online to start receiving requests.';

  @override
  String get instantRideStep2 => 'You have 30 seconds to accept a request.';

  @override
  String get instantRideStep3 => 'Follow the map to the passenger\'s location.';

  @override
  String get confirmSchedule => 'Confirm Schedule';

  @override
  String get suggestedRoutes => 'Suggested Routes';

  @override
  String get optimalStartTime => 'Optimal Start Time';

  @override
  String optimalStartTimeDescription(String time, String percent) {
    return 'Leave at $time to avoid congestion and earn $percent% more XP.';
  }

  @override
  String get highDemandAreas => 'High Demand Areas';

  @override
  String highDemandAreasDescription(int count, String area, String multiplier) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count active passengers near $area',
      many: '$count active passengers near $area',
      few: '$count active passengers near $area',
      one: '1 active passenger near $area',
      zero: 'No passengers near $area',
    );
    return '$_temp0. +${multiplier}x Multiplier active.';
  }

  @override
  String get homeToOffice => 'Home to Office';

  @override
  String get universityRun => 'University Run';

  @override
  String get highMatchProbability => 'High Match Probability';

  @override
  String get mediumTraffic => 'Medium Traffic';

  @override
  String get aiRoutePlanner => 'AI Route Planner';

  @override
  String get aiRoutePlannerTitle => 'AI Route Planner';

  @override
  String get aiRoutePlannerDescription =>
      'Plan your daily commute intelligently';

  @override
  String get planYourCommute => 'Plan Your Daily Commute';

  @override
  String get workLocation => 'Work Location';

  @override
  String get homeLocation => 'Home Location';

  @override
  String get analyzeMyRoute => 'Analyze My Route';

  @override
  String get aiAnalysis => 'AI Analysis...';

  @override
  String get aiPlanTitle => 'Your Smart Commute Plan';

  @override
  String get aiPlanDescription =>
      'Based on your route, here are some tips to maximize XP and reduce traffic:';

  @override
  String get optimalDeparture => 'Optimal Departure Time';

  @override
  String get highDemandZones => 'High-Demand Zones';

  @override
  String get keepRidingToNextReward => 'Keep riding to get to the next reward!';

  @override
  String earnXPForRide(Object points) {
    return 'Ride and earn $points points for every ride!';
  }

  @override
  String get rideWith => 'Ride with him';

  @override
  String get cancel => 'Cancel';

  @override
  String get yes => 'Yes';

  @override
  String get no => 'No';

  @override
  String get passengerEncouragementTitle => 'Thinking of Driving?';

  @override
  String get passengerEncouragementBody =>
      'Since you own a car, you could earn 2x the XP as a driver on this route!';

  @override
  String get viewDriverBenefits => 'View Driver Benefits';

  @override
  String get myRegularTrips => 'My Regular Trips';

  @override
  String get manageRegularTrips =>
      'Manage your daily trips and earn points regularly';

  @override
  String get noRegularTrips => 'You have not set up any regular trips yet.';

  @override
  String get addNewRoute => 'Add New Route';

  @override
  String get setRegularRoute => 'Set Regular Route';

  @override
  String get routeDetails => 'Route Details';

  @override
  String get travelDays => 'Travel Days';

  @override
  String get travelTime => 'Travel Time';

  @override
  String get saveRoute => 'Save Route';

  @override
  String get haveACode => 'Have a Code?';

  @override
  String get redeemItHere => 'Redeem it here for XP!';

  @override
  String get redeemCode => 'Redeem Code';

  @override
  String get enterYourCode => 'Enter your gift or promo code';

  @override
  String get codePlaceholder => 'e.g., RAMADAN2024';

  @override
  String get redeem => 'Redeem';

  @override
  String get codeRedeemedSuccess => 'Code redeemed successfully!';

  @override
  String youReceivedPoints(Object points) {
    return 'You received $points XP!';
  }

  @override
  String get redeemReward => 'Redeem Reward';

  @override
  String get confirmRedemption => 'Confirm Redemption';

  @override
  String get notEnoughPoints => 'Not enough points';

  @override
  String get redemptionSuccessful => 'Redemption Successful!';

  @override
  String get yourVoucherCode => 'Your Voucher Code:';

  @override
  String get cost => 'Cost';

  @override
  String get khawiJuniorTitle => 'Khawi Junior';

  @override
  String get khawiJuniorDescription => 'Safe and trusted rides for your kids.';

  @override
  String get khawiJuniorWelcome => 'Welcome to Khawi Junior';

  @override
  String get khawiJuniorDisclaimer => 'A safe and fun way for kids to travel.';

  @override
  String get safetyFirst => 'Safety First';

  @override
  String get parentSafetyInstruction1 =>
      'Always verify the driver\'s identity and car details before the trip.';

  @override
  String get parentSafetyInstruction2 =>
      'Communicate with the driver to confirm pickup and drop-off details.';

  @override
  String get parentSafetyInstruction3 =>
      'Use the live trip tracking feature and share it with family members.';

  @override
  String get parentSafetyInstruction4 =>
      'Teach your child the basics of safety when riding with others.';

  @override
  String get guardianDriverSafetyInstruction1 =>
      'Adhering to traffic laws and safe driving is your top priority.';

  @override
  String get guardianDriverSafetyInstruction2 =>
      'Ensure you have appropriate and properly installed child seats.';

  @override
  String get guardianDriverSafetyInstruction3 =>
      'Do not start the trip until you confirm the child\'s identity and destination.';

  @override
  String get guardianDriverSafetyInstruction4 =>
      'Maintain clear communication with parents before, during, and after the trip.';

  @override
  String get iUnderstandAndAgree => 'I Understand and Agree';

  @override
  String get chooseYourRole => 'Choose Your Role in Khawi Junior';

  @override
  String get imAParent => 'I\'m a Parent';

  @override
  String get imAParentDescription => 'I want to arrange a ride for my child.';

  @override
  String get imAGuardianDriver => 'I\'m a Guardian Driver';

  @override
  String get imAGuardianDriverDescription =>
      'I\'ll drive my child and can carpool with others.';

  @override
  String get imAFamilyDriver => 'I\'m a Family Driver';

  @override
  String get imAFamilyDriverDescription => 'I was invited by a parent.';

  @override
  String get noDriverInviteMessage =>
      'No driver profile found. A parent must invite you first.';

  @override
  String get guardianDriverIneligible =>
      'To ensure maximum safety, this feature is exclusively available to registered female drivers who are also parents.';

  @override
  String get juniorHubParentTitle => 'Your Kids\' Rides';

  @override
  String get juniorHubDriverTitle => 'Your Carpool';

  @override
  String get currentTrip => 'Current Trip';

  @override
  String get trackRide => 'Track Ride';

  @override
  String get myChildren => 'My Children';

  @override
  String get addChild => 'Add Child';

  @override
  String get scheduleNewRide => 'Schedule New Ride';

  @override
  String get enRouteToSchool => 'En Route to School';

  @override
  String get arrivedAtSchool => 'Arrived at School';

  @override
  String get enRouteHome => 'En Route Home';

  @override
  String get arrivedHome => 'Arrived Home';

  @override
  String notificationArrivedAtSchool(Object name) {
    return '$name has arrived safely at school! You earned 50 XP for being a hero!';
  }

  @override
  String notificationArrivedHome(Object name) {
    return 'Welcome back! $name has arrived home. +50 XP for your bravery!';
  }

  @override
  String get yourChild => 'Your Child';

  @override
  String get incomingRequests => 'Incoming Requests';

  @override
  String get manageYourRoute => 'Manage Your Route';

  @override
  String get guardianDriverNotice =>
      'Note: You can only accept children from the same school as your child.';

  @override
  String get kidsRideHubEncouragement =>
      'Every shared ride is a new adventure and a great contribution to our community!';

  @override
  String kidsRewardsTitle(Object name) {
    return '$name\'s Rewards';
  }

  @override
  String get kidsRewardEncouragement =>
      'Great job! Exchange your points for fun gifts.';

  @override
  String get rewardToyCar => 'Toy Car';

  @override
  String get rewardIceCream => 'Ice Cream Treat';

  @override
  String get rewardBookVoucher => 'Book Voucher';

  @override
  String get kidsRedeemReward => 'Redeem Reward';

  @override
  String get kidsRedemptionSuccessful => 'Redemption Successful!';

  @override
  String get scheduleRideComingSoon =>
      'Ride scheduling isn\'t available in this build.';

  @override
  String get trackingRideTitle => 'Track Ride';

  @override
  String get driver => 'Driver';

  @override
  String get myDriver => 'My Driver';

  @override
  String get addYourDriver => 'Add Your Driver';

  @override
  String get driverDetailsPrompt =>
      'Add your personal driver\'s details for trip tracking.';

  @override
  String get addDriverScreenTitle => 'Add My Driver';

  @override
  String get driverName => 'Driver Name';

  @override
  String get driverPhone => 'Driver Phone';

  @override
  String get saveDriver => 'Save Driver';

  @override
  String get appointedDriverDashboardTitle => 'Family Driver Dashboard';

  @override
  String get yourTotalPoints => 'Your Total Points';

  @override
  String get currentTripFor => 'Current Trip For';

  @override
  String get guardianDriverPointsNotice =>
      'Reminder: When you drive, both you and your child earn points together!';

  @override
  String get manageMyDriver => 'Manage My Driver';

  @override
  String get inviteYourDriver => 'Invite Your Driver';

  @override
  String get inviteDriverPrompt => 'Invite a trusted driver for your kids';

  @override
  String get sendInvitation => 'Send Invitation';

  @override
  String get todaysSchedule => 'Today\'s Schedule';

  @override
  String get startTrip => 'Start Trip';

  @override
  String get callParent => 'Call Parent';

  @override
  String get tripToSchool => 'Trip to School';

  @override
  String get tripHome => 'Trip Home';

  @override
  String get switchToDriverView => 'Switch to Driver View (Demo)';

  @override
  String get switchToParentView => 'Switch to Parent View';

  @override
  String get startInstantTrip => 'Start Instant Trip';

  @override
  String get instantTripDescription => 'For spontaneous rides with friends';

  @override
  String get scanToJoin => 'Scan to Join';

  @override
  String get instantTripTitle => 'Instant Trip';

  @override
  String get showQrToPassengers => 'Show this code to passengers to join:';

  @override
  String get passengersJoined => 'Passengers Joined';

  @override
  String get startTheTrip => 'Start The Trip';

  @override
  String get scanInstructions => 'Scan the driver\'s QR code to join instantly';

  @override
  String get simulatedScan => 'Simulate Scan';

  @override
  String get whereTo => 'Where to?';

  @override
  String get smartMatchTitle => 'SmartMatch';

  @override
  String get instantRide => 'Instant Ride';

  @override
  String get scheduleTrip => 'Schedule Trip';

  @override
  String get findingMatch => 'Finding your match...';

  @override
  String get receivingRequests => 'Receiving ride requests...';

  @override
  String get goOnlineToEarn => 'Go online to start earning XP';

  @override
  String get todaysEarnings => 'Today\'s XP';

  @override
  String get ridesToday => 'Rides Today';

  @override
  String get juniorHubTitle => 'Junior Hub';

  @override
  String get safeStatus => 'You are safe!';

  @override
  String get rideInProgress => 'Ride in progress to school';

  @override
  String get noActiveRide => 'No active ride right now';

  @override
  String get requestRide => 'Request Ride';

  @override
  String get playGames => 'Play Games';

  @override
  String get yourRewards => 'Your Rewards';

  @override
  String get simulateRide => 'Simulate School Ride';

  @override
  String get safetyRulesTitle => 'Safety First!';

  @override
  String get safetyDescription =>
      'Remember these rules to stay safe and earn bonus XP!';

  @override
  String get safetyRule1 => 'Always wear your seatbelt';

  @override
  String get safetyRule2 => 'Don\'t talk to strangers';

  @override
  String get safetyRule3 => 'Call parents if unsure';

  @override
  String get iUnderstand => 'I Understand';

  @override
  String get profileTitle => 'Profile';

  @override
  String get helpSupport => 'Help & Support';

  @override
  String get xpLedgerTitle => 'XP Ledger';

  @override
  String get currentBalance => 'Current Balance';

  @override
  String get addFunds => 'Add Funds';

  @override
  String get rewardsTitle => 'Rewards';

  @override
  String get yourXP => 'Your XP';

  @override
  String get redeemRewards => 'Redeem Rewards';

  @override
  String get sundayShort => 'S';

  @override
  String get mondayShort => 'M';

  @override
  String get tuesdayShort => 'T';

  @override
  String get wednesdayShort => 'W';

  @override
  String get thursdayShort => 'Th';

  @override
  String get kidsCarpoolTitle => 'Kids Carpool';

  @override
  String get myCircles => 'My Circles';

  @override
  String get findPools => 'Find Pools';

  @override
  String get createCircle => 'Create Circle';

  @override
  String get noCirclesJoined => 'No carpools joined yet';

  @override
  String get members => 'Members';

  @override
  String get viewDetails => 'View Details';

  @override
  String get searchNearbyPools => 'Search for nearby carpools';

  @override
  String get enterSchoolOrClub => 'Enter School or Club Name';

  @override
  String get invitationSent => 'Invitation Sent!';

  @override
  String get fillAllFields => 'Please fill all fields';

  @override
  String get continueText => 'Continue';

  @override
  String get driverRoleRequiredTitle => 'Driver Role Required';

  @override
  String get driverRoleRequiredMessage =>
      'To create a ride QR code, you must be a verified driver. Select the \"Driver\" role to continue.';

  @override
  String get passengerConductTitle => 'Passenger Code of Conduct';

  @override
  String get driverConductTitle => 'Driver Code of Conduct';

  @override
  String get juniorSafetyTitle => 'Khawi Junior Safety Rules';

  @override
  String get passengerRule1 => 'Arrive on time and be respectful.';

  @override
  String get passengerRule2 => 'Always verify the ride details before joining.';

  @override
  String get zeroToleranceRule =>
      'Zero tolerance for harassment or unsafe behavior.';

  @override
  String get driverRule1 => 'This is a community ride-share (non-paid).';

  @override
  String get driverRule2 => 'Follow traffic laws and keep safety first.';

  @override
  String get juniorRule1 => 'Safety comes first for every trip.';

  @override
  String get juniorRule2 =>
      'Only approved guardians/family drivers should participate.';

  @override
  String get juniorRule3 => 'Live tracking may be enabled for safety.';

  @override
  String get verificationScreenTitle => 'Identity Verification';

  @override
  String get verifyWithNafath => 'Verify with Nafath';

  @override
  String get verificationRationale =>
      'To build a trusted community, we require identity verification via Nafath/Absher.';

  @override
  String get connectWithNafath => 'Connect with Nafath';

  @override
  String get processing => 'Processing...';

  @override
  String get sessionMissing => 'Session missing. Please sign in again.';

  @override
  String verificationUpdateFailed(Object error) {
    return 'Verification update failed: $error';
  }

  @override
  String get communities => 'Communities';

  @override
  String get myCommunities => 'My Communities';

  @override
  String get discoverCommunities => 'Discover';

  @override
  String get noCommunities => 'You haven\'t joined any communities yet';

  @override
  String get joinCommunityHint => 'Head to Discover and find your community';

  @override
  String get searchCommunities => 'Search communities...';

  @override
  String get communityType => 'Community Type';

  @override
  String get communityNameEn => 'Community Name (English)';

  @override
  String get communityNameAr => 'Community Name (Arabic)';

  @override
  String get createCommunity => 'Create Community';

  @override
  String get leaveCommunity => 'Leave';

  @override
  String get joinCommunity => 'Join';

  @override
  String get activeRides => 'Active Rides';

  @override
  String get verified => 'Verified';

  @override
  String get communityRideBoard => 'Ride Board';

  @override
  String get noRidesYet => 'No rides yet';

  @override
  String get moreSocial => 'Social';

  @override
  String get eventRides => 'Event Rides';

  @override
  String get searchEvents => 'Search events...';

  @override
  String get all => 'All';

  @override
  String get featuredEvents => 'Featured Events';

  @override
  String get upcomingEvents => 'Upcoming Events';

  @override
  String get noUpcomingEvents => 'No upcoming events';

  @override
  String get interested => 'Interested';

  @override
  String get ridesAvailable => 'Rides';

  @override
  String get expected => 'Expected';

  @override
  String get going => 'Going';

  @override
  String get goingTo => 'Going To';

  @override
  String get returning => 'Returning';

  @override
  String get beFirstToOfferRide => 'Be the first to offer a ride! 🚗';

  @override
  String get errorGeneric => 'Something went wrong, please try again';

  @override
  String get description => 'Description';

  @override
  String get required => 'Required';

  @override
  String get continueAs => 'Continue as';

  @override
  String get passengerHeroTitle => 'Where are we going?';

  @override
  String get passengerHeroSubtitle =>
      'Fast pickup, trusted drivers, and smoother rides.';

  @override
  String get goodMorning => 'Good morning';

  @override
  String get goodAfternoon => 'Good afternoon';

  @override
  String get goodEvening => 'Good evening';

  @override
  String get statusQuickPickup => 'Quick pickup';

  @override
  String get statusTrustedRides => 'Trusted rides';

  @override
  String get quickDestHome => 'Home';

  @override
  String get quickDestWork => 'Work';

  @override
  String get quickDestSchool => 'School';

  @override
  String get quickDestAirport => 'Airport';

  @override
  String get demandNormal =>
      'Demand is normal in your area. Expected pickup 3-6 min.';

  @override
  String get demandStatusStable => 'Stable';

  @override
  String get driversNearby => 'Multiple verified drivers are nearby right now.';

  @override
  String get driversNearbyFastLane => 'Fast lane';

  @override
  String get shortcutSavedPlaces => 'Saved places';

  @override
  String get shortcutSavedPlacesSubtitle => 'One-tap route';

  @override
  String get shortcutRepeatLastTrip => 'Repeat last trip';

  @override
  String get shortcutRepeatLastTripSubtitle => 'Fast checkout';

  @override
  String get shortcutFamilyRide => 'Family ride';

  @override
  String get shortcutFamilyRideSubtitle => 'Share trip details';

  @override
  String get recentPlaceTileKingFahad => 'King Fahad Road';

  @override
  String get recentPlaceTileKingFahadSubtitle => 'Last ride - 9 min ago';

  @override
  String get recentPlaceTileBusinessGate => 'Riyadh Business Gate';

  @override
  String get recentPlaceTileBusinessGateSubtitle => 'Frequent destination';

  @override
  String get recentPlaceTileParkMall => 'Riyadh Park Mall';

  @override
  String get recentPlaceTileParkMallSubtitle => 'Popular at this time';

  @override
  String get serviceTierSaver => 'Khawi Saver';

  @override
  String get serviceTierSaverEta => '3-5 min';

  @override
  String get serviceTierSaverHint => 'Best value';

  @override
  String get serviceTierComfort => 'Khawi Comfort';

  @override
  String get serviceTierComfortEta => '5-8 min';

  @override
  String get serviceTierComfortHint => 'Quiet ride';

  @override
  String get serviceTierWomenPlus => 'Women+';

  @override
  String get serviceTierWomenPlusEta => '4-7 min';

  @override
  String get serviceTierWomenPlusHint => 'Preferred match';

  @override
  String get serviceTierRecommended => 'Recommended';

  @override
  String get etaPickupTitle => 'Pickup ETA';

  @override
  String get etaPickupValue => '4 min';

  @override
  String get routeReliabilityTitle => 'Route reliability';

  @override
  String get routeReliabilityValue => 'High';

  @override
  String get safetyScoreTitle => 'Safety score';

  @override
  String get safetyScoreValue => 'A+';

  @override
  String get routePreviewPickup => 'Pickup nearby';

  @override
  String get routePreviewDropoff => 'Drop-off to be confirmed';

  @override
  String get rideNowLabel => 'Ride now';

  @override
  String get rideLaterLabel => 'Later';

  @override
  String get rideNowHint =>
      'Ride now is optimized for faster pickup and value pricing in your zone.';

  @override
  String get prefNoConversation => 'No conversation';

  @override
  String get prefCoolAC => 'Cool AC';

  @override
  String get prefWomenOnly => 'Women-only';

  @override
  String get prefExtraLuggage => 'Extra luggage';

  @override
  String get confidenceTrustedDriverTitle => 'Trusted Driver Verification';

  @override
  String get confidenceTrustedDriverSubtitle =>
      'Only verified drivers can accept your rides.';

  @override
  String get confidenceLiveRoutingTitle => 'Live Route Tracking';

  @override
  String get confidenceLiveRoutingSubtitle =>
      'Track your trip status from pickup to drop-off.';

  @override
  String get confidenceFastSupportTitle => 'Fast Support Access';

  @override
  String get confidenceFastSupportSubtitle =>
      'Reach support quickly from any active trip.';

  @override
  String get weeklyChallengesTitle => 'Weekly Challenges';

  @override
  String get challengeRiyadhExplorer => 'Riyadh Explorer';

  @override
  String get challengeRiyadhExplorerDesc =>
      'Complete 5 rides within Riyadh this week';

  @override
  String get challengeRiyadhExplorerXp => '200 XP';

  @override
  String get challengeEcoPioneer => 'Eco Pioneer';

  @override
  String get challengeEcoPioneerDesc => 'Save 10kg of CO2 by carpooling';

  @override
  String get challengeEcoPioneerXp => '500 XP';

  @override
  String get challengeSafetyFirst => 'Safety First';

  @override
  String get challengeSafetyFirstDesc =>
      'Maintain a 5-star rating for 10 trips';

  @override
  String get challengeSafetyFirstXp => '1000 XP';

  @override
  String challengePercentComplete(int percent) {
    return '$percent% Complete';
  }

  @override
  String get eventRamadanBonus => 'Ramadan Commute Bonus';

  @override
  String get eventRamadanBonusDesc => 'Double XP for all sunset rides';

  @override
  String get eventRamadanBonusStart => 'Starts in 2 days';

  @override
  String get juniorIntroTitle => 'Khawi Junior';

  @override
  String get juniorIntroSubtitle => 'Safe rides for your peace of mind';

  @override
  String get juniorSafetyPoint => 'Guardian Drivers only';

  @override
  String get juniorFamilyPoint => 'Appoint trusted Family Drivers';

  @override
  String get juniorTrackingPoint => 'Live Tracking';

  @override
  String get juniorContinue => 'Continue';

  @override
  String get juniorNotParent => 'Not a Parent?';

  @override
  String get juniorRoleTitle => 'Choose Your Role';

  @override
  String get juniorRoleGuardian => 'Guardian / Parent';

  @override
  String get juniorRoleGuardianDesc =>
      'Manage your kids\' rides and connections';

  @override
  String get juniorRoleDriver => 'Family Driver';

  @override
  String get juniorRoleDriverDesc => 'You have been invited to drive';

  @override
  String get juniorDashboardTitle => 'Junior Dashboard';

  @override
  String get juniorAddKid => 'Add Kid';

  @override
  String get juniorMyKids => 'My Kids';

  @override
  String get juniorNoKids => 'No kids added yet.';

  @override
  String get juniorActiveRuns => 'Active Runs';

  @override
  String get juniorFeatureInProgress => 'Feature In Progress';

  @override
  String get juniorNoActiveRuns => 'No active runs';

  @override
  String get juniorCreateRunWithHub =>
      'Create one from the Hub, then share an invite code with your Family Driver.';

  @override
  String get juniorGoToHub => 'Go to Hub';
}
