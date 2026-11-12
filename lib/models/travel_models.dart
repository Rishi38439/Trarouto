// AeroNova AI Travel Agent - Data Models

class Activity {
  final String id;
  final String time;
  final String title;
  final String location;
  final String description;
  final String category;
  final int cost;
  final String duration;
  final String bookingStatus;

  Activity({
    required this.id,
    required this.time,
    required this.title,
    required this.location,
    required this.description,
    required this.category,
    required this.cost,
    required this.duration,
    this.bookingStatus = 'included',
  });
}

class DayPlan {
  final int dayNumber;
  final String date;
  final String title;
  final String theme;
  final String description;
  final List<Activity> activities;
  final String breakfast;
  final String lunch;
  final String dinner;

  DayPlan({
    required this.dayNumber,
    required this.date,
    required this.title,
    required this.theme,
    required this.description,
    required this.activities,
    required this.breakfast,
    required this.lunch,
    required this.dinner,
  });
}

class Itinerary {
  final String id;
  final String title;
  final String destination;
  final String startLocation;
  final String startDate;
  final String endDate;
  final int durationDays;
  final int durationNights;
  final int travellers;
  final String budgetTier;
  final List<String> tags;
  final String summary;
  final String heroImage;
  final List<DayPlan> days;
  final int estimatedTotalCost;
  final String currency;
  final String createdAt;
  bool isSavedOffline;

  Itinerary({
    required this.id,
    required this.title,
    required this.destination,
    required this.startLocation,
    required this.startDate,
    required this.endDate,
    required this.durationDays,
    required this.durationNights,
    required this.travellers,
    required this.budgetTier,
    required this.tags,
    required this.summary,
    required this.heroImage,
    required this.days,
    required this.estimatedTotalCost,
    required this.currency,
    required this.createdAt,
    this.isSavedOffline = false,
  });
}

class Destination {
  final String id;
  final String name;
  final String country;
  final String region;
  final String category; // 'popular' | 'hidden-gem'
  final double rating;
  final int reviewCount;
  final String imageUrl;
  final String description;
  final List<String> highlights;
  final List<String> topAttractions;
  final List<String> localExperiences;
  final List<String> recommendedRestaurants;
  final int averageDailyBudget;
  final String currency;
  final String bestSeason;

  Destination({
    required this.id,
    required this.name,
    required this.country,
    required this.region,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.imageUrl,
    required this.description,
    required this.highlights,
    required this.topAttractions,
    required this.localExperiences,
    required this.recommendedRestaurants,
    required this.averageDailyBudget,
    required this.currency,
    required this.bestSeason,
  });
}

class Hotel {
  final String id;
  final String name;
  final String location;
  final String city;
  final double rating;
  final int reviewCount;
  final int pricePerNight;
  final String currency;
  final String imageUrl;
  final List<String> facilities;
  final String distanceFromAttractions;
  final String address;
  final int availableRooms;
  final String cancellationPolicy;

  Hotel({
    required this.id,
    required this.name,
    required this.location,
    required this.city,
    required this.rating,
    required this.reviewCount,
    required this.pricePerNight,
    required this.currency,
    required this.imageUrl,
    required this.facilities,
    required this.distanceFromAttractions,
    required this.address,
    required this.availableRooms,
    required this.cancellationPolicy,
  });
}

class TransportOption {
  final String id;
  final String type; // 'flight' | 'train' | 'ola' | 'uber' | 'intercity-cab'
  final String provider;
  final String routeCode;
  final String from;
  final String to;
  final String departureTime;
  final String arrivalTime;
  final String duration;
  final int price;
  final String currency;
  final double rating;
  final int? seatsAvailable;
  final String? vehicleType;
  final String status;

  TransportOption({
    required this.id,
    required this.type,
    required this.provider,
    required this.routeCode,
    required this.from,
    required this.to,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.currency,
    required this.rating,
    this.seatsAvailable,
    this.vehicleType,
    this.status = 'on-time',
  });
}

class BookingItem {
  final String id;
  final String type; // 'flight' | 'train' | 'hotel' | 'cab' | 'activity'
  final String title;
  final String provider;
  final String referenceNumber;
  final String destination;
  final int price;
  final String currency;
  final String status;
  final String voucherNumber;
  final Map<String, String> details;
  bool isOfflineAvailable;

  BookingItem({
    required this.id,
    required this.type,
    required this.title,
    required this.provider,
    required this.referenceNumber,
    required this.destination,
    required this.price,
    required this.currency,
    required this.status,
    required this.voucherNumber,
    required this.details,
    this.isOfflineAvailable = true,
  });
}

/* SMART ROUTE RECOVERY MODELS */

class JourneyLeg {
  final String id;
  final String from;
  final String to;
  final String mode; // 'train' | 'express-cab' | 'flight' | 'volvo-bus'
  final String provider;
  final String serviceNumber;
  final String departureTime;
  final String arrivalTime;
  final int durationMinutes;
  final int cost;
  String bookingStatus;
  final int bufferMinutesAfter;

  JourneyLeg({
    required this.id,
    required this.from,
    required this.to,
    required this.mode,
    required this.provider,
    required this.serviceNumber,
    required this.departureTime,
    required this.arrivalTime,
    required this.durationMinutes,
    required this.cost,
    required this.bookingStatus,
    required this.bufferMinutesAfter,
  });

  JourneyLeg clone() {
    return JourneyLeg(
      id: id,
      from: from,
      to: to,
      mode: mode,
      provider: provider,
      serviceNumber: serviceNumber,
      departureTime: departureTime,
      arrivalTime: arrivalTime,
      durationMinutes: durationMinutes,
      cost: cost,
      bookingStatus: bookingStatus,
      bufferMinutesAfter: bufferMinutesAfter,
    );
  }
}

class RoutePossibility {
  final String id;
  String name;
  String pathDescription;
  final List<String> checkpoints;
  final List<JourneyLeg> legs;
  final String departureTime;
  String estimatedArrivalTime;
  final int totalDurationMinutes;
  final int totalWaitingMinutes;
  int totalCost;
  bool isPrimary;
  bool isFeasible;
  String? feasibilityReason;
  String? feasibilityRisk;
  String? recommendedAction;

  RoutePossibility({
    required this.id,
    required this.name,
    required this.pathDescription,
    required this.checkpoints,
    required this.legs,
    required this.departureTime,
    required this.estimatedArrivalTime,
    required this.totalDurationMinutes,
    required this.totalWaitingMinutes,
    required this.totalCost,
    required this.isPrimary,
    required this.isFeasible,
    this.feasibilityReason,
    this.feasibilityRisk,
    this.recommendedAction,
  });

  RoutePossibility clone() {
    return RoutePossibility(
      id: id,
      name: name,
      pathDescription: pathDescription,
      checkpoints: List.from(checkpoints),
      legs: legs.map((l) => l.clone()).toList(),
      departureTime: departureTime,
      estimatedArrivalTime: estimatedArrivalTime,
      totalDurationMinutes: totalDurationMinutes,
      totalWaitingMinutes: totalWaitingMinutes,
      totalCost: totalCost,
      isPrimary: isPrimary,
      isFeasible: isFeasible,
      feasibilityReason: feasibilityReason,
      feasibilityRisk: feasibilityRisk,
      recommendedAction: recommendedAction,
    );
  }
}

class CheckpointStatus {
  final String id;
  final String name;
  final String code;
  final int sequence;
  final String scheduledArrival;
  final String scheduledDeparture;
  String? actualArrival;
  int delayMinutes;
  final int minTransferTimeMinutes;
  String status;
  final String notes;

  CheckpointStatus({
    required this.id,
    required this.name,
    required this.code,
    required this.sequence,
    required this.scheduledArrival,
    required this.scheduledDeparture,
    this.actualArrival,
    this.delayMinutes = 0,
    required this.minTransferTimeMinutes,
    required this.status,
    required this.notes,
  });

  CheckpointStatus clone() {
    return CheckpointStatus(
      id: id,
      name: name,
      code: code,
      sequence: sequence,
      scheduledArrival: scheduledArrival,
      scheduledDeparture: scheduledDeparture,
      actualArrival: actualArrival,
      delayMinutes: delayMinutes,
      minTransferTimeMinutes: minTransferTimeMinutes,
      status: status,
      notes: notes,
    );
  }
}

class EmergencyContact {
  final String id;
  final String category; // 'hospital' | 'police' | 'hotel' | 'helpline'
  final String name;
  final String phone;
  final String address;
  final String distance;
  final String openHours;
  final bool is24x7;

  EmergencyContact({
    required this.id,
    required this.category,
    required this.name,
    required this.phone,
    required this.address,
    required this.distance,
    required this.openHours,
    this.is24x7 = true,
  });
}

class TravelPhrase {
  final String id;
  final String category;
  final String language;
  final String english;
  final String translated;
  final String phonetic;

  TravelPhrase({
    required this.id,
    required this.category,
    required this.language,
    required this.english,
    required this.translated,
    required this.phonetic,
  });
}

class ScamRiskIndicator {
  final String label;
  final String type; // 'danger' | 'warning' | 'safe'
  final String description;

  ScamRiskIndicator({
    required this.label,
    required this.type,
    required this.description,
  });
}

class ScamCheckAssessment {
  final int riskScore;
  final String riskLevel; // 'low' | 'moderate' | 'high' | 'critical'
  final String verdict;
  final List<ScamRiskIndicator> indicators;
  final List<String> recommendations;
  final String disclaimer;
  final String evaluatedAt;

  ScamCheckAssessment({
    required this.riskScore,
    required this.riskLevel,
    required this.verdict,
    required this.indicators,
    required this.recommendations,
    required this.disclaimer,
    required this.evaluatedAt,
  });
}
