import 'ride_rating.dart';

enum RatingDirection {
  rateDriver,
  ratePassenger,
}

List<RatingTag> defaultRatingTags(RatingDirection direction) {
  switch (direction) {
    case RatingDirection.rateDriver:
      return const [
        RatingTag.onTime,
        RatingTag.cleanCar,
        RatingTag.smoothDriving,
        RatingTag.safeDriver,
        RatingTag.friendly,
        RatingTag.comfortable,
      ];
    case RatingDirection.ratePassenger:
      return const [
        RatingTag.onTime,
        RatingTag.polite,
        RatingTag.friendly,
        RatingTag.greatConversation,
      ];
  }
}
