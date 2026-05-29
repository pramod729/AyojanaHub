import 'package:ayojana_hub/proposal_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProposalProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  List<ProposalModel> _proposals = [];
  bool _isLoading = false;
  String? _error;

  List<ProposalModel> get proposals => _proposals;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProposalsForEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('proposals')
          .where('eventId', isEqualTo: eventId)
          .orderBy('createdAt', descending: true)
          .get();

      _proposals = snapshot.docs
          .map((doc) => ProposalModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load proposals: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProposalsForVendor(String vendorUserId, {String? vendorDocId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final vendorIds = <String>{vendorUserId};
      if (vendorDocId != null && vendorDocId.isNotEmpty && vendorDocId != vendorUserId) {
        vendorIds.add(vendorDocId);
      }

      Query query = _firestore.collection('proposals');
      if (vendorIds.length == 1) {
        query = query.where('vendorId', isEqualTo: vendorUserId);
      } else {
        query = query.where('vendorId', whereIn: vendorIds.toList());
      }

      final snapshot = await query.orderBy('createdAt', descending: true).get();

      _proposals = snapshot.docs
          .map((doc) => ProposalModel.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      _error = 'Failed to load proposals: $e';
      _proposals = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<String?> submitProposal(ProposalModel proposal) async {
    try {
      final proposalRef = await _firestore.collection('proposals').add(proposal.toMap());
      
      await _firestore.collection('events').doc(proposal.eventId).update({
        'proposalCount': FieldValue.increment(1),
      });

      await _firestore.collection('notifications').add({
        'userId': (await _firestore.collection('events').doc(proposal.eventId).get()).data()?['userId'],
        'type': 'new_proposal',
        'title': 'New Proposal Received',
        'message': '${proposal.vendorName} submitted a proposal for ${proposal.eventName}',
        'eventId': proposal.eventId,
        'proposalId': proposalRef.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to submit proposal: $e';
    }
  }

  Future<String?> submitProposalRequest(ProposalModel proposal) async {
    try {
      final proposalRef = await _firestore.collection('proposals').add(proposal.toMap());
      await _firestore.collection('events').doc(proposal.eventId).update({
        'proposalCount': FieldValue.increment(1),
      });

      await _firestore.collection('notifications').add({
        'userId': proposal.vendorId,
        'type': 'proposal_request',
        'title': 'New Proposal Request',
        'message': 'A customer requested a proposal for ${proposal.eventName}',
        'eventId': proposal.eventId,
        'proposalId': proposalRef.id,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to send proposal request: $e';
    }
  }

  Future<String?> replyToProposal(String proposalId, double quotedPrice, String vendorReply) async {
    try {
      final proposalDoc = await _firestore.collection('proposals').doc(proposalId).get();
      final proposalData = proposalDoc.data();

      if (proposalData == null) {
        return 'Proposal not found';
      }

      await _firestore.collection('proposals').doc(proposalId).update({
        'status': 'quoted',
        'proposedPrice': quotedPrice,
        'vendorReply': vendorReply,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': proposalData['userId'],
        'type': 'proposal_reply',
        'title': 'Vendor replied to your request',
        'message': '${proposalData['vendorName']} replied to your proposal request for ${proposalData['eventName']}',
        'eventId': proposalData['eventId'],
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to send proposal reply: $e';
    }
  }

  Future<String?> acceptProposal(String proposalId, String eventId) async {
    try {
      final proposalDoc = await _firestore.collection('proposals').doc(proposalId).get();
      final proposalData = proposalDoc.data();
      
      if (proposalData == null) {
        return 'Proposal not found';
      }

      final eventDoc = await _firestore.collection('events').doc(eventId).get();
      final eventData = eventDoc.data();
      
      if (eventData == null) {
        return 'Event not found';
      }

      final batch = _firestore.batch();

      batch.update(
        _firestore.collection('proposals').doc(proposalId),
        {
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
        },
      );

      final proposalsSnapshot = await _firestore
          .collection('proposals')
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'pending')
          .get();

      for (var doc in proposalsSnapshot.docs) {
        if (doc.id != proposalId) {
          batch.update(doc.reference, {
            'status': 'rejected',
            'respondedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      batch.update(
        _firestore.collection('events').doc(eventId),
        {'status': 'confirmed'},
      );

      final bookingRef = _firestore.collection('bookings').doc();
      batch.set(bookingRef, {
        'eventId': eventId,
        'eventName': proposalData['eventName'],
        'customerId': proposalData['userId'],
        'customerName': eventData['userName'],
        'vendorId': proposalData['vendorId'],
        'vendorName': proposalData['vendorName'],
        'proposalId': proposalId,
        'vendorCategory': proposalData['vendorCategory'],
        'price': proposalData['proposedPrice'],
        'bookingDate': FieldValue.serverTimestamp(),
        'eventDate': eventData['eventDate'],
        'status': 'confirmed',
        'notes': 'Booking created from accepted proposal',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();

      await _firestore.collection('notifications').add({
        'userId': proposalData['vendorId'],
        'type': 'proposal_accepted',
        'title': 'Proposal Accepted!',
        'message': 'Your proposal for ${proposalData['eventName']} has been accepted',
        'eventId': eventId,
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('notifications').add({
        'userId': proposalData['userId'],
        'type': 'booking_confirmed',
        'title': 'Booking Confirmed!',
        'message': 'Your booking with ${proposalData['vendorName']} for ${proposalData['eventName']} is confirmed',
        'eventId': eventId,
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to accept proposal: $e';
    }
  }

  Future<String?> rejectProposal(String proposalId, String? notes) async {
    try {
      await _firestore.collection('proposals').doc(proposalId).update({
        'status': 'rejected',
        'respondedAt': FieldValue.serverTimestamp(),
        'userNotes': notes,
      });

      final proposal = await _firestore.collection('proposals').doc(proposalId).get();
      final proposalData = proposal.data();

      await _firestore.collection('notifications').add({
        'userId': proposalData?['vendorId'],
        'type': 'proposal_rejected',
        'title': 'Proposal Update',
        'message': 'Your proposal for ${proposalData?['eventName']} was not selected',
        'eventId': proposalData?['eventId'],
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to reject proposal: $e';
    }
  }

  Future<int> getProposalCountForEvent(String eventId) async {
    try {
      final snapshot = await _firestore
          .collection('proposals')
          .where('eventId', isEqualTo: eventId)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  Future<bool> hasVendorSubmittedProposal(String eventId, String vendorId) async {
    try {
      final snapshot = await _firestore
          .collection('proposals')
          .where('eventId', isEqualTo: eventId)
          .where('vendorId', isEqualTo: vendorId)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<String?> vendorAcceptOffer(String proposalId) async {
    try {
      final proposalDoc = await _firestore.collection('proposals').doc(proposalId).get();
      final proposalData = proposalDoc.data();

      if (proposalData == null) {
        return 'Proposal not found';
      }

      await _firestore.collection('proposals').doc(proposalId).update({
        'status': 'vendor_accepted',
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to user
      await _firestore.collection('notifications').add({
        'userId': proposalData['userId'],
        'type': 'vendor_accepted_offer',
        'title': 'Offer Accepted!',
        'message': '${proposalData['vendorName']} has accepted your offer for ${proposalData['eventName']}',
        'eventId': proposalData['eventId'],
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to accept offer: $e';
    }
  }

  Future<String?> vendorRejectOffer(String proposalId, String? reason) async {
    try {
      final proposalDoc = await _firestore.collection('proposals').doc(proposalId).get();
      final proposalData = proposalDoc.data();

      if (proposalData == null) {
        return 'Proposal not found';
      }

      await _firestore.collection('proposals').doc(proposalId).update({
        'status': 'vendor_rejected',
        'respondedAt': FieldValue.serverTimestamp(),
        'vendorReply': reason,
      });

      // Send notification to user
      await _firestore.collection('notifications').add({
        'userId': proposalData['userId'],
        'type': 'vendor_rejected_offer',
        'title': 'Offer Update',
        'message': '${proposalData['vendorName']} has declined your offer for ${proposalData['eventName']}',
        'eventId': proposalData['eventId'],
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to reject offer: $e';
    }
  }
}
