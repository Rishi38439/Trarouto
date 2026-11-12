import '../models/travel_models.dart';

class MockDataService {
  static List<Destination> getDestinations() {
    return [
      Destination(
        id: 'dest-jodhpur',
        name: 'Jodhpur (The Blue City)',
        country: 'India',
        region: 'Rajasthan',
        category: 'popular',
        rating: 4.8,
        reviewCount: 3420,
        imageUrl: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=800&q=80',
        description:
            'Guarded by colossal Mehrangarh Fort, Jodhpur unfolds in an indigo sea of Brahmin dwellings, aromatic spice bazaars, and opulent royal havelis.',
        highlights: ['Mehrangarh Fort', 'Toorji Ka Jhalra Stepwell', 'Umaid Bhawan Palace'],
        topAttractions: ['Mehrangarh Fort (4.9★)', 'Jaswant Thada (4.7★)', 'Toorji Stepwell (4.8★)'],
        localExperiences: ['Sunset rooftop tea overlooking blue city', 'Zip-lining over fort battlements', 'Marwari block printing workshop'],
        recommendedRestaurants: ['Indique at Pal Haveli (Lal Maas)', 'Janta Sweet Home (Mirchi Vada)', 'Stepwell Café (Craft Brews)'],
        averageDailyBudget: 3500,
        currency: '₹',
        bestSeason: 'October to March',
      ),
      Destination(
        id: 'dest-ravello',
        name: 'Ravello & Amalfi Cliffside',
        country: 'Italy',
        region: 'Campania',
        category: 'popular',
        rating: 4.9,
        reviewCount: 4890,
        imageUrl: 'https://images.unsplash.com/photo-1533105079780-92b9be482077?auto=format&fit=crop&w=800&q=80',
        description: 'Perched 365m above the Tyrrhenian Sea, Ravello offers peaceful cliffside terraces, ancient villas, and open-air classical concerts.',
        highlights: ['Villa Cimbrone Infinity Terrace', 'Villa Rufolo Gardens', 'Valle delle Ferriere'],
        topAttractions: ['Villa Cimbrone (4.9★)', 'Villa Rufolo (4.8★)', 'Duomo di Ravello (4.7★)'],
        localExperiences: ['Evening classical quartet concert', 'Lemon grove walk & mozzarella tasting', 'Private wooden boat cruise'],
        recommendedRestaurants: ['Ristorante Salvatore (Seafood)', 'Mimi Pizzeria', 'Babel Wine Bar'],
        averageDailyBudget: 190,
        currency: '€',
        bestSeason: 'April to October',
      ),
      Destination(
        id: 'dest-khimsar',
        name: 'Khimsar Dunes & Oasis',
        country: 'India',
        region: 'Rajasthan',
        category: 'hidden-gem',
        rating: 4.7,
        reviewCount: 920,
        imageUrl: 'https://images.unsplash.com/photo-1509316975850-ff9c5deb0cd9?auto=format&fit=crop&w=800&q=80',
        description: 'An idyllic hidden desert oasis with a pristine natural pond surrounded by 60-foot golden sand dunes and blackbuck sanctuaries.',
        highlights: ['Private eco-dune huts', '16th-century fortress ramparts', 'Blackbuck wildlife reserve'],
        topAttractions: ['Khimsar Dunes Village (4.8★)', 'Khimsar Fort Heritage (4.7★)', 'Panchala Reserve (4.6★)'],
        localExperiences: ['Camel safari on untouched dunes', 'Zero light-pollution stargazing', 'Bishnoi pottery session'],
        recommendedRestaurants: ['Fort Courtyard Restaurant', 'Dune Terrace Lounge'],
        averageDailyBudget: 4200,
        currency: '₹',
        bestSeason: 'November to February',
      ),
      Destination(
        id: 'dest-civita',
        name: 'Civita di Bagnoregio (The Dying Town)',
        country: 'Italy',
        region: 'Lazio',
        category: 'hidden-gem',
        rating: 4.8,
        reviewCount: 1640,
        imageUrl: 'https://images.unsplash.com/photo-1516483638261-f4dbaf036963?auto=format&fit=crop&w=800&q=80',
        description: 'An ethereal medieval hill-town isolated on a pinnacle of volcanic rock, accessible only via a dramatic pedestrian footbridge.',
        highlights: ['300m pedestrian footbridge', 'Etruscan caves', 'Piazza San Donato'],
        topAttractions: ['Porta Santa Maria (4.8★)', 'Landslides Museum (4.5★)', 'San Donato Church (4.7★)'],
        localExperiences: ['Sunrise walk on footbridge', 'Wild boar ragù tasting', 'Valley mist photography'],
        recommendedRestaurants: ['Alma Civita (Cave Dining)', 'L’Arco Forno'],
        averageDailyBudget: 130,
        currency: '€',
        bestSeason: 'April to October',
      ),
    ];
  }

  static List<Hotel> getHotels() {
    return [
      Hotel(
        id: 'htl-pal-haveli',
        name: 'Pal Haveli Heritage Mansion',
        location: 'Gulab Sagar, Old City',
        city: 'Jodhpur',
        rating: 4.7,
        reviewCount: 2290,
        pricePerNight: 4800,
        currency: '₹',
        imageUrl: 'https://images.unsplash.com/photo-1582719508461-905c673771fd?auto=format&fit=crop&w=800&q=80',
        facilities: ['Rooftop Fort View Restaurant', 'Antique Courtyard', 'High-Speed Wi-Fi', 'Heritage Concierge'],
        distanceFromAttractions: '400m from Clock Tower Bazaar, 1.1 km from Mehrangarh Ramparts',
        address: 'Near Clock Tower, Sadar Bazar, Jodhpur 342001',
        availableRooms: 5,
        cancellationPolicy: 'Free cancellation up to 24 hours prior to check-in.',
      ),
      Hotel(
        id: 'htl-umaid-bhawan',
        name: 'Taj Umaid Bhawan Palace',
        location: 'Circuit House Road',
        city: 'Jodhpur',
        rating: 4.9,
        reviewCount: 1840,
        pricePerNight: 28500,
        currency: '₹',
        imageUrl: 'https://images.unsplash.com/photo-1566073771259-6a8506099945?auto=format&fit=crop&w=800&q=80',
        facilities: ['Palace Spa & Heated Pool', 'Private Peacock Gardens', 'Royal Butler Service', 'Museum Access'],
        distanceFromAttractions: '1.2 km from Sardar Market, 3.8 km from Mehrangarh',
        address: 'Umaid Bhawan Palace Road, Jodhpur 342006',
        availableRooms: 3,
        cancellationPolicy: 'Free cancellation up to 48 hours prior to check-in.',
      ),
      Hotel(
        id: 'htl-villa-maria',
        name: 'Villa Maria Terrazza Hotel',
        location: 'Via Santa Chiara 2',
        city: 'Ravello, Italy',
        rating: 4.8,
        reviewCount: 1410,
        pricePerNight: 240,
        currency: '€',
        imageUrl: 'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?auto=format&fit=crop&w=800&q=80',
        facilities: ['Panoramic Sea View Terrace', 'Lemon Grove Dining', 'Wine Cellar', 'Valet Transfer'],
        distanceFromAttractions: '300m from Villa Cimbrone, 150m from Piazza Vescovado',
        address: 'Via Santa Chiara 2, 84010 Ravello, Italy',
        availableRooms: 4,
        cancellationPolicy: 'Free cancellation up to 72 hours prior to arrival.',
      ),
    ];
  }

  static List<TransportOption> getTransports() {
    return [
      TransportOption(
        id: 'tr-vb-20977',
        type: 'train',
        provider: 'Vande Bharat Express',
        routeCode: '20977-VB',
        from: 'Home Terminal (NDLS)',
        to: 'Checkpoint A (Jaipur Jn)',
        departureTime: '08:00 AM',
        arrivalTime: '11:45 AM',
        duration: '3h 45m',
        price: 950,
        currency: '₹',
        rating: 4.8,
        seatsAvailable: 42,
      ),
      TransportOption(
        id: 'tr-sf-12988',
        type: 'train',
        provider: 'Intercity Superfast Express',
        routeCode: '12988-SF',
        from: 'Checkpoint A (Jaipur Jn)',
        to: 'Checkpoint B (Ajmer Terminal)',
        departureTime: '12:30 PM',
        arrivalTime: '03:15 PM',
        duration: '2h 45m',
        price: 720,
        currency: '₹',
        rating: 4.6,
        seatsAvailable: 19,
      ),
      TransportOption(
        id: 'tr-ola-prime',
        type: 'ola',
        provider: 'Ola Prime Sedan',
        routeCode: 'OLA-SEDAN',
        from: 'Jodhpur Railway Station',
        to: 'Mehrangarh Fort / Old City',
        departureTime: '3 min ETA',
        arrivalTime: 'Direct Drop',
        duration: '22 mins',
        price: 320,
        currency: '₹',
        rating: 4.8,
        vehicleType: 'Dzire AC',
      ),
      TransportOption(
        id: 'tr-uber-xl',
        type: 'uber',
        provider: 'Uber XL SUV',
        routeCode: 'UBER-XL',
        from: 'Jodhpur Airport (JDH)',
        to: 'Pal Haveli Heritage Stay',
        departureTime: '5 min ETA',
        arrivalTime: 'Direct Drop',
        duration: '25 mins',
        price: 540,
        currency: '₹',
        rating: 4.9,
        vehicleType: 'Innova Crysta 6-Seater',
      ),
    ];
  }

  static List<BookingItem> getInitialBookings() {
    return [
      BookingItem(
        id: 'bk-vb-01',
        type: 'train',
        title: 'Vande Bharat Express (Home → Checkpoint A)',
        provider: 'Indian Railways',
        referenceNumber: 'PNR-8492048192',
        destination: 'Checkpoint A (Jaipur)',
        price: 950,
        currency: '₹',
        status: 'confirmed',
        voucherNumber: 'VOUCHER-IR-99182',
        details: {'Coach': 'C4', 'Seat': '24 (Window)', 'Class': 'AC Chair Car'},
      ),
      BookingItem(
        id: 'bk-hotel-01',
        type: 'hotel',
        title: 'Pal Haveli Heritage Suite (2 Nights)',
        provider: 'Pal Haveli Heritage Hotel',
        referenceNumber: 'CONF-PH-772189',
        destination: 'Jodhpur Old City',
        price: 9600,
        currency: '₹',
        status: 'confirmed',
        voucherNumber: 'VOUCHER-HTL-48102',
        details: {'Room': 'Courtyard Suite', 'Guests': '2 Adults', 'Meal': 'Breakfast Included'},
      ),
      BookingItem(
        id: 'bk-act-01',
        type: 'activity',
        title: 'Private Sunset Walk & Mehrangarh Audio Tour',
        provider: 'Rajasthan Heritage Guild',
        referenceNumber: 'TKT-MHR-3381',
        destination: 'Mehrangarh Fortress',
        price: 1400,
        currency: '₹',
        status: 'confirmed',
        voucherNumber: 'VOUCHER-ACT-10294',
        details: {'Guide': 'Historian Escort', 'Inclusions': 'Fort Elevator + Evening Chai'},
      ),
    ];
  }

  static List<EmergencyContact> getEmergencyContacts() {
    return [
      EmergencyContact(
        id: 'em-1',
        category: 'hospital',
        name: 'AIIMS Jodhpur Trauma Center',
        phone: '+91 291 2740741',
        address: 'Basni Phase-2, Jodhpur',
        distance: '3.4 km from center',
        openHours: '24/7 Level 1 Trauma',
      ),
      EmergencyContact(
        id: 'em-2',
        category: 'hospital',
        name: 'Mahatma Gandhi Emergency Hospital',
        phone: '+91 291 2627001',
        address: 'Jalori Gate, Old City, Jodhpur',
        distance: '1.1 km from market',
        openHours: '24/7 Emergency Ward',
      ),
      EmergencyContact(
        id: 'em-3',
        category: 'police',
        name: 'Jodhpur Tourist Police Station',
        phone: '+91 291 2544256',
        address: 'Near High Court Road, Jodhpur',
        distance: '800 m from station',
        openHours: '24/7 Dedicated Assistance',
      ),
      EmergencyContact(
        id: 'em-4',
        category: 'hotel',
        name: 'Pal Haveli Duty Manager (24x7)',
        phone: '+91 291 2638344',
        address: 'Clock Tower, Jodhpur',
        distance: 'Stay Location',
        openHours: '24 Hours Resident Desk',
      ),
    ];
  }

  static List<TravelPhrase> getPhrases(String lang) {
    if (lang == 'it') {
      return [
        TravelPhrase(id: 'it-1', category: 'Greetings', language: 'it', english: 'Hello / Good day', translated: 'Buongiorno', phonetic: 'bwon-JOR-noh'),
        TravelPhrase(id: 'it-2', category: 'Greetings', language: 'it', english: 'Please & Thank you', translated: 'Per favore e Grazie', phonetic: 'pehr fah-VOH-reh eh GRAHT-syeh'),
        TravelPhrase(id: 'it-3', category: 'Directions', language: 'it', english: 'Where is the train station?', translated: 'Dov\'è la stazione ferroviaria?', phonetic: 'doh-VEH lah staht-SYOH-neh?'),
        TravelPhrase(id: 'it-4', category: 'Dining', language: 'it', english: 'A table for two, please', translated: 'Un tavolo per due, per favore', phonetic: 'oon TAH-voh-loh pehr DOO-eh'),
        TravelPhrase(id: 'it-5', category: 'Dining', language: 'it', english: 'The bill, please', translated: 'Il conto, per favore', phonetic: 'eel KOHN-toh, pehr fah-VOH-reh'),
        TravelPhrase(id: 'it-6', category: 'Emergency', language: 'it', english: 'Help me, please!', translated: 'Aiuto, per favore!', phonetic: 'ah-YOO-toh, pehr fah-VOH-reh!'),
        TravelPhrase(id: 'it-7', category: 'Emergency', language: 'it', english: 'I need a doctor', translated: 'Ho bisogno di un medico', phonetic: 'oh bee-ZOHN-yoh dee oon MEH-dee-koh'),
      ];
    } else {
      return [
        TravelPhrase(id: 'hi-1', category: 'Greetings', language: 'hi', english: 'Hello / Greetings', translated: 'नमस्ते (Namaste)', phonetic: 'Nah-mas-tay'),
        TravelPhrase(id: 'hi-2', category: 'Greetings', language: 'hi', english: 'Thank you very much', translated: 'बहुत धन्यवाद (Bahut Dhanyavaad)', phonetic: 'Buh-hoot Dhun-yuh-vaad'),
        TravelPhrase(id: 'hi-3', category: 'Directions', language: 'hi', english: 'Where is the Fort / Station?', translated: 'किला / स्टेशन कहाँ है? (Kila kahan hai?)', phonetic: 'Kee-lah / Stay-shun kuh-haan hai?'),
        TravelPhrase(id: 'hi-4', category: 'Dining', language: 'hi', english: 'Please make it less spicy', translated: 'कृपया मिर्च कम रखें (Kripya mirch kam rakhein)', phonetic: 'Krip-yah mirch kum rukh-ain'),
        TravelPhrase(id: 'hi-5', category: 'Dining', language: 'hi', english: 'Please bring the bill', translated: 'कृपया बिल ले आइए (Kripya bill le aaiye)', phonetic: 'Krip-yah bill lay aai-yay'),
        TravelPhrase(id: 'hi-6', category: 'Emergency', language: 'hi', english: 'I need urgent medical help', translated: 'मुझे डॉक्टर की ज़रूरत है (Mujhe doctor ki zaroorat hai)', phonetic: 'Moo-jhay doctor kee zuh-roo-rut hai'),
      ];
    }
  }

  static ScamCheckAssessment assessScam(String text, String method) {
    int score = 20;
    final lower = '$text $method'.toLowerCase();
    final indicators = <ScamRiskIndicator>[];
    final recommendations = <String>[];

    if (lower.contains('crypto') || lower.contains('wire transfer') || lower.contains('western union') || lower.contains('whatsapp only')) {
      score += 45;
      indicators.add(ScamRiskIndicator(
        label: 'Irreversible Payment Channel',
        type: 'danger',
        description: 'Demands cryptocurrency, Western Union wire, or unverified peer-to-peer transfers with zero chargeback protections.',
      ));
      recommendations.add('Never wire cash or transfer cryptocurrency. Use verified credit card processors with buyer protection.');
    }

    if (lower.contains('urgent') || lower.contains('within 2 hours') || lower.contains('expires today') || lower.contains('50% discount')) {
      score += 25;
      indicators.add(ScamRiskIndicator(
        label: 'High-Pressure Urgency Tactics',
        type: 'danger',
        description: 'Imposes extreme artificial deadlines to bypass rational due-diligence.',
      ));
      recommendations.add('Legitimate hotels honor standard reservation holds; never rush under high pressure.');
    }

    if (lower.contains('.xyz') || lower.contains('.top') || lower.contains('no registered office')) {
      score += 15;
      indicators.add(ScamRiskIndicator(
        label: 'Unverified Entity / TLD',
        type: 'warning',
        description: 'Domain uses throwaway TLD or operates without verifiable physical registration credentials.',
      ));
      recommendations.add('Cross-check business registration on official state tourism registries.');
    }

    if (indicators.isEmpty) {
      score = 10;
      indicators.add(ScamRiskIndicator(
        label: 'Standard Booking Disclosures Present',
        type: 'safe',
        description: 'Appears consistent with normal commercial listing practices.',
      ));
      recommendations.add('Confirm check-in policy and save reservation voucher offline.');
    }

    final finalScore = score.clamp(5, 99);
    final riskLevel = finalScore >= 70
        ? 'critical'
        : finalScore >= 45
            ? 'high'
            : finalScore >= 25
                ? 'moderate'
                : 'low';

    return ScamCheckAssessment(
      riskScore: finalScore,
      riskLevel: riskLevel,
      verdict: finalScore >= 60
          ? 'CRITICAL RISK: Multiple red flags detected correlating strongly with phantom listing and advance-fee wire fraud.'
          : finalScore >= 35
              ? 'MODERATE RISK: Some irregularities detected. Exercise caution and verify credentials.'
              : 'LOW RISK: Standard commercial parameters observed.',
      indicators: indicators,
      recommendations: recommendations,
      disclaimer: 'DISCLAIMER: Automated heuristic assessment based on keyword patterns. Not a legal fraud determination. Always verify independently.',
      evaluatedAt: 'Just Now',
    );
  }

  static Itinerary getDefaultItinerary() {
    return Itinerary(
      id: 'itin-jodhpur-signature',
      title: '5-Day Jodhpur Royal Citadel & Marwar Odyssey',
      destination: 'Jodhpur, Rajasthan, India',
      startLocation: 'Home Terminal',
      startDate: '2026-11-20',
      endDate: '2026-11-24',
      durationDays: 5,
      durationNights: 4,
      travellers: 2,
      budgetTier: 'moderate',
      tags: ['MODERATE', 'TRAIN & HERITAGE', 'HISTORICAL', 'FOOD'],
      summary: 'A curated journey through the Blue City, Mehrangarh fortress battlements, Toorji stepwells, and royal desert camps.',
      heroImage: 'https://images.unsplash.com/photo-1599661046827-dacff0c0f09a?auto=format&fit=crop&w=1200&q=80',
      currency: '₹',
      estimatedTotalCost: 24500,
      createdAt: 'Nov 12, 2026',
      isSavedOffline: true,
      days: [
        DayPlan(
          dayNumber: 1,
          date: 'Day 1 (Nov 20)',
          title: 'Arrival & First Glimpses of Jodhpur',
          theme: 'Arrival & Heritage Haven',
          description: 'Check in to Pal Haveli, explore blue-hued Brahmin quarters, and enjoy sunset tea overlooking Mehrangarh.',
          breakfast: 'Vande Bharat on-board breakfast',
          lunch: 'Mirchi Vada & Mawa Kachori at Janta Sweets',
          dinner: 'Rooftop Lal Maas at Indique, Pal Haveli',
          activities: [
            Activity(
              id: 'act-1-1',
              time: '08:00 AM',
              title: 'Departure via Vande Bharat Express',
              location: 'Home Terminal',
              description: 'Begin multimodal journey across North-Western rail corridor toward Checkpoint A.',
              category: 'transit',
              cost: 950,
              duration: '3h 45m',
            ),
            Activity(
              id: 'act-1-2',
              time: '08:30 PM',
              title: 'Hotel Check-in & Rooftop Fort View',
              location: 'Pal Haveli, Clock Tower',
              description: 'Check into heritage suite and watch illuminated battlements from terrace.',
              category: 'relaxation',
              cost: 0,
              duration: '2 hrs',
            ),
          ],
        ),
        DayPlan(
          dayNumber: 2,
          date: 'Day 2 (Nov 21)',
          title: 'Mehrangarh Fortress Ramparts & Stepwell',
          theme: 'Royal Forts & Architecture',
          description: 'Private tour of Mehrangarh Fort, Jaswant Thada marble cenotaphs, and coffee beside Toorji stepwell.',
          breakfast: 'Poori bhaji at Pal Haveli courtyard',
          lunch: 'Artisan sandwiches at Stepwell Café',
          dinner: 'Royal Rajasthani Thali at Gypsy',
          activities: [
            Activity(
              id: 'act-2-1',
              time: '09:30 AM',
              title: 'Mehrangarh Fortress Ramparts Walk',
              location: 'Mehrangarh Fort',
              description: 'Explore palanquins, weaponry gallery, and cannon battlements with Rajput historian.',
              category: 'historical',
              cost: 650,
              duration: '3.5 hrs',
            ),
            Activity(
              id: 'act-2-2',
              time: '04:30 PM',
              title: 'Toorji Ka Jhalra Stepwell & Spice Tasting',
              location: 'Sadar Bazar',
              description: '18th-century geometric red sandstone stepwell exploration followed by spice sampling.',
              category: 'culture',
              cost: 200,
              duration: '2 hrs',
            ),
          ],
        ),
      ],
    );
  }
}
