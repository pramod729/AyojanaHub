import 'package:ayojana_hub/package_model.dart';
import 'package:ayojana_hub/vendor_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class VendorProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<VendorModel> _vendors = [];
  List<PackageModel> _packages = [];
  bool _isLoading = false;
  String? _error;

  List<VendorModel> get vendors => _vendors;
  List<PackageModel> get packages => _packages;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Sample vendor data with Nepali vendors
  static const List<Map<String, dynamic>> _sampleVendors = [
    // Catering Vendors
    {
      'name': 'Nepali Rahar Catering',
      'category': 'Catering',
      'description': 'Traditional Nepali cuisine with modern fusion options for all occasions',
      'phone': '+977-1-4123456',
      'email': 'info@nepaliraharcatering.com',
      'location': 'Kathmandu, Nepal',
      'services': ['Traditional Nepali', 'Dal Bhat Variety', 'Momo Station', 'International Cuisine'],
      'rating': 4.8,
      'reviewCount': 245,
      'profileImage': 'https://images.unsplash.com/photo-1504674900436-f9e6a96b0bed?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1495107212441-7e3b0d9e5a92?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Bhoomte Ko Khana',
      'category': 'Catering',
      'description': 'Authentic Nepali home-style catering with fresh local ingredients',
      'phone': '+977-1-4234567',
      'email': 'contact@bhoomtekkhana.com',
      'location': 'Lalitpur, Nepal',
      'services': ['Newari Cuisine', 'Vegetarian Specials', 'Catering Packages', 'Corporate Events'],
      'rating': 4.7,
      'reviewCount': 189,
      'profileImage': 'https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Muna\'s Kitchen & Catering',
      'category': 'Catering',
      'description': 'Premium catering with Nepali, Newari, and International cuisines',
      'phone': '+977-1-4345678',
      'email': 'muna@munaskitchen.com',
      'location': 'Bhaktapur, Nepal',
      'services': ['Wedding Catering', 'Birthday Parties', 'Festival Special', 'Desserts & Beverages'],
      'rating': 4.9,
      'reviewCount': 312,
      'profileImage': 'https://images.unsplash.com/photo-1495193911906-77f3b0fbb9c0?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1540189549336-e6e99c3679fe?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1565958011703-44f9829ba187?w=400&h=300&fit=crop'],
    },
    
    // Photography Vendors
    {
      'name': 'Shutter Moments Nepal',
      'category': 'Photography',
      'description': 'Professional wedding and event photography with cinematic videography',
      'phone': '+977-1-4456789',
      'email': 'hello@shuttermomentsnepal.com',
      'location': 'Kathmandu, Nepal',
      'services': ['Wedding Photography', 'Candid Shots', 'Drone Coverage', '4K Video'],
      'rating': 4.9,
      'reviewCount': 412,
      'profileImage': 'https://images.unsplash.com/photo-1540575467063-178dd50d49da?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1511885642898-4c92249e20b6?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1516846573675-af19a809c37e?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Golden Frame Photography',
      'category': 'Photography',
      'description': 'Capturing your special moments with artistic vision and technical excellence',
      'phone': '+977-1-4567890',
      'email': 'booking@goldenframephoto.com',
      'location': 'Patan, Nepal',
      'services': ['Pre-wedding Shoots', 'Portrait Photography', 'Event Coverage', 'Album Design'],
      'rating': 4.8,
      'reviewCount': 356,
      'profileImage': 'https://images.unsplash.com/photo-1502726299822-6f3ee3078bbd?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1556531313-3b1502ddf3cb?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1519225421980-715cb0215aed?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Lens & Light Studios',
      'category': 'Photography',
      'description': 'Creative photography studio specializing in weddings and celebrations',
      'phone': '+977-1-4678901',
      'email': 'studio@lensandlight.com',
      'location': 'Thamel, Kathmandu, Nepal',
      'services': ['Studio Shoots', 'Outdoor Photography', 'Post Processing', 'Digital Delivery'],
      'rating': 4.7,
      'reviewCount': 278,
      'profileImage': 'https://images.unsplash.com/photo-1600298881974-6be191ceeda1?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1611285299253-b3a94e3ef5a9?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1611180626919-fca9d6e53e8d?w=400&h=300&fit=crop'],
    },
    
    // DJ & Music Vendors
    {
      'name': 'DJ Rabi Entertainment',
      'category': 'DJ & Music',
      'description': 'Professional DJ services with latest equipment and music collection',
      'phone': '+977-1-4789012',
      'email': 'rabi@djrabientertainment.com',
      'location': 'Kathmandu, Nepal',
      'services': ['DJ Service', 'Sound System', 'Lighting Design', 'Mixing & Mastering'],
      'rating': 4.8,
      'reviewCount': 367,
      'profileImage': 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1511379938547-c1f69b13d835?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1470225620780-dba8ba36b745?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Beats Nepal DJ Service',
      'category': 'DJ & Music',
      'description': 'High-energy DJ service with premium sound and lighting for all events',
      'phone': '+977-1-4890123',
      'email': 'beats@beatsnepaldjservice.com',
      'location': 'Lalitpur, Nepal',
      'services': ['Club DJ', 'Wedding DJ', 'Live Band Setup', 'Event MC'],
      'rating': 4.7,
      'reviewCount': 298,
      'profileImage': 'https://images.unsplash.com/photo-1487180144351-b8472da7d491?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Sound Wave Productions',
      'category': 'DJ & Music',
      'description': 'Complete audio-visual solutions for events with experienced DJ and technicians',
      'phone': '+977-1-4901234',
      'email': 'contact@soundwaveproductions.com',
      'location': 'Bhaktapur, Nepal',
      'services': ['Professional DJ', 'Audio Equipment Rental', 'Stage Sound', 'Recording'],
      'rating': 4.9,
      'reviewCount': 445,
      'profileImage': 'https://images.unsplash.com/photo-1520523839897-bd0b52dbb7ef?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1533900298318-6b8da08a523e?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=400&h=300&fit=crop'],
    },
    
    // Decoration Vendors
    {
      'name': 'Phool Ra Pani Decorations',
      'category': 'Decoration',
      'description': 'Elegant flower and theme-based decorations for weddings and events',
      'phone': '+977-1-5012345',
      'email': 'design@phoolrapani.com',
      'location': 'Kathmandu, Nepal',
      'services': ['Flower Arrangements', 'Stage Setup', 'Thematic Decor', 'LED Lighting'],
      'rating': 4.8,
      'reviewCount': 389,
      'profileImage': 'https://images.unsplash.com/photo-1519167534503-46acee16dc86?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1505142468610-359e7d316be0?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1464207687429-7505649dae38?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Rainbow Event Decorators',
      'category': 'Decoration',
      'description': 'Creative and colorful event decoration with modern design aesthetics',
      'phone': '+977-1-5123456',
      'email': 'colorful@rainboweventdecorators.com',
      'location': 'Patan, Nepal',
      'services': ['Floral Setup', 'Balloon Decoration', 'Fabric Draping', 'Entrance Gate Design'],
      'rating': 4.7,
      'reviewCount': 324,
      'profileImage': 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1469927160573-aa64003bc560?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Celebration Decor Nepal',
      'category': 'Decoration',
      'description': 'Professional event decoration team for weddings, parties, and corporate events',
      'phone': '+977-1-5234567',
      'email': 'celebrate@celebrationdecor.com',
      'location': 'Thamel, Kathmandu, Nepal',
      'services': ['Complete Venue Setup', 'Custom Props', 'Lighting Installation', 'Dismantling'],
      'rating': 4.9,
      'reviewCount': 512,
      'profileImage': 'https://images.unsplash.com/photo-1516509301663-68947b1b538f?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?w=400&h=300&fit=crop'],
    },
    
    // Venue Vendors
    {
      'name': 'Dhulikhel Heritage Palace',
      'category': 'Venue',
      'description': 'Luxurious banquet hall with modern amenities and traditional aesthetics',
      'phone': '+977-1-5345678',
      'email': 'events@dhulikhelpalace.com',
      'location': 'Dhulikhel, Nepal',
      'services': ['Indoor Hall', 'Outdoor Lawn', 'Catering Facility', 'Event Management'],
      'rating': 4.9,
      'reviewCount': 578,
      'profileImage': 'https://images.unsplash.com/photo-1519671482749-fd09be7ccebf?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1511632765486-a01980e01a18?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1465146072230-91cabc968266?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Kathmandu Grand Hotel & Venue',
      'category': 'Venue',
      'description': 'Premium venue with complete hospitality services for large gatherings',
      'phone': '+977-1-5456789',
      'email': 'venue@ktmgrand.com',
      'location': 'Kathmandu, Nepal',
      'services': ['Banquet Halls', 'Garden Space', 'Accommodation', 'Full Catering'],
      'rating': 4.8,
      'reviewCount': 645,
      'profileImage': 'https://images.unsplash.com/photo-1509042239860-f550ce710b93?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1519167534503-46acee16dc86?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Panauti River View Resort',
      'category': 'Venue',
      'description': 'Scenic riverside venue with natural beauty and modern event facilities',
      'phone': '+977-1-5567890',
      'email': 'booking@panautiriverview.com',
      'location': 'Panauti, Nepal',
      'services': ['Riverside Venue', 'Indoor Banquet', 'Adventure Activities', 'Resort Rooms'],
      'rating': 4.7,
      'reviewCount': 489,
      'profileImage': 'https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1500375592092-40eb897053a2?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1520763185298-1b434c919abe?w=400&h=300&fit=crop'],
    },
    
    // Event Planning Vendors
    {
      'name': 'Prem Events Nepal',
      'category': 'Planning',
      'description': 'Complete event planning and execution with personalized service approach',
      'phone': '+977-1-5678901',
      'email': 'plan@premeventnepal.com',
      'location': 'Kathmandu, Nepal',
      'services': ['Full Planning', 'Vendor Management', 'Day Coordination', 'Budget Planning'],
      'rating': 4.9,
      'reviewCount': 634,
      'profileImage': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1519167534503-46acee16dc86?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Creative Events Management',
      'category': 'Planning',
      'description': 'Innovative event planning with creative concepts and flawless execution',
      'phone': '+977-1-5789012',
      'email': 'creative@creativeventsmanagement.com',
      'location': 'Lalitpur, Nepal',
      'services': ['Concept Development', 'Vendor Coordination', 'Timeline Management', 'Post-Event'],
      'rating': 4.8,
      'reviewCount': 567,
      'profileImage': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1519167534503-46acee16dc86?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=400&h=300&fit=crop'],
    },
    {
      'name': 'Shubha Shagun Events',
      'category': 'Planning',
      'description': 'Professional event planning specializing in weddings and celebrations',
      'phone': '+977-1-5890123',
      'email': 'hello@shubhashagun.com',
      'location': 'Bhaktapur, Nepal',
      'services': ['Wedding Planning', 'Theme Coordination', 'Budget Management', 'Vendor Network'],
      'rating': 4.9,
      'reviewCount': 701,
      'profileImage': 'https://images.unsplash.com/photo-1552664730-d307ca884978?w=400&h=400&fit=crop',
      'portfolioImages': ['https://images.unsplash.com/photo-1519167534503-46acee16dc86?w=400&h=300&fit=crop', 'https://images.unsplash.com/photo-1523580494863-6f3031224c94?w=400&h=300&fit=crop'],
    },
  ];

  Future<void> _initializeSampleVendors() async {
    try {
      final snapshot = await _firestore.collection('vendors').limit(1).get();
      
      // If no vendors exist, add sample vendors
      if (snapshot.docs.isEmpty) {
        for (var vendor in _sampleVendors) {
          await _firestore.collection('vendors').add(vendor);
        }
      }
    } catch (e) {
      // Error initializing sample vendors
    }
  }

  Future<void> loadVendors({String? category, bool forceRefresh = false}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Initialize sample vendors if collection is empty (only on first load)
      if (!forceRefresh) {
        await _initializeSampleVendors();
      }

      Query query = _firestore.collection('vendors');
      
      if (category != null && category.isNotEmpty) {
        query = query.where('category', isEqualTo: category);
      }

      final snapshot = await query.get();
      _vendors = snapshot.docs
          .map((doc) => VendorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load vendors: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> refreshVendors({String? category}) async {
    await loadVendors(category: category, forceRefresh: true);
  }

  Future<void> loadVendorPackages(String vendorId) async {
    try {
      final snapshot = await _firestore
          .collection('packages')
          .where('vendorId', isEqualTo: vendorId)
          .get();

      _packages = snapshot.docs
          .map((doc) => PackageModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      // Error loading packages
    }
  }

  Future<String?> createVendor(VendorModel vendor) async {
    try {
      await _firestore.collection('vendors').add({
        'name': vendor.name,
        'category': vendor.category,
        'description': vendor.description,
        'phone': vendor.phone,
        'email': vendor.email,
        'location': vendor.location,
        'services': vendor.services,
        'rating': vendor.rating,
        'reviewCount': vendor.reviewCount,
        'profileImage': vendor.profileImage,
        'portfolioImages': vendor.portfolioImages,
      });
      
      // Refresh vendor list
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to register vendor: $e';
    }
  }

  Future<String?> createVendorFromRegistration({
    required String userId,
    required String businessName,
    required String category,
    required String description,
    required String phone,
    required String email,
    required String location,
    required List<String> services,
  }) async {
    try {
      // Create vendor document with userId reference
      await _firestore.collection('vendors').add({
        'userId': userId,
        'name': businessName,
        'category': category,
        'description': description,
        'phone': phone,
        'email': email,
        'location': location,
        'services': services,
        'rating': 5.0,
        'reviewCount': 0,
        'profileImage': null,
        'portfolioImages': [],
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      
      // Refresh vendor list
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to create vendor profile: $e';
    }
  }

  Future<VendorModel?> getVendorByUserId(String userId) async {
    try {
      final doc = await _firestore
          .collection('vendors')
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (doc.docs.isNotEmpty) {
        return VendorModel.fromMap(doc.docs.first.data(), doc.docs.first.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<VendorModel?> getVendorById(String vendorId) async {
    try {
      final doc = await _firestore.collection('vendors').doc(vendorId).get();
      if (doc.exists) {
        return VendorModel.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<String?> updateVendor(VendorModel vendor) async {
    try {
      await _firestore.collection('vendors').doc(vendor.id).update(vendor.toMap());
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to update vendor: $e';
    }
  }

  Future<String?> updateVendorProfileFromUser({
    required String userId,
    required String businessName,
    required String category,
    required String description,
    required String phone,
    required String email,
    required String location,
    required List<String> services,
  }) async {
    try {
      // First check if vendor document exists
      final existingVendor = await getVendorByUserId(userId);

      if (existingVendor != null) {
        // Update existing vendor
        await _firestore
            .collection('vendors')
            .doc(existingVendor.id)
            .update({
          'name': businessName,
          'category': category,
          'description': description,
          'phone': phone,
          'email': email,
          'location': location,
          'services': services,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Create new vendor document for the user
        await _firestore.collection('vendors').add({
          'userId': userId,
          'name': businessName,
          'category': category,
          'description': description,
          'phone': phone,
          'email': email,
          'location': location,
          'services': services,
          'rating': 5.0,
          'reviewCount': 0,
          'profileImage': null,
          'portfolioImages': [],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // Refresh vendor list
      await loadVendors();
      return null;
    } catch (e) {
      return 'Failed to update vendor profile: $e';
    }
  }

  Future<String?> deleteVendor(String vendorId) async {
    try {
      await _firestore.collection('vendors').doc(vendorId).delete();
      await loadVendors();
      return null;
    } catch (e) {

      return 'Failed to delete vendor: $e';
    }
  }

  Future<String?> uploadVendorPortfolioImage(
    String vendorId,
    String imageUrl,
  ) async {
    try {
      final vendor = _vendors.firstWhere((v) => v.id == vendorId);
      final updatedImages = [...vendor.portfolioImages, imageUrl];

      await _firestore
          .collection('vendors')
          .doc(vendorId)
          .update({
        'portfolioImages': updatedImages,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      await loadVendors();
      return null;
    } catch (e) {
      print('Error uploading portfolio image: $e');
      return 'Failed to upload image: $e';
    }
  }
}

