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

  // Loads the proposals on a single event for the event owner (customer).
  // Every proposal on an event carries userId == the event owner, and the
  // Firestore read rule authorises proposals by userId/vendorId — so we MUST
  // query by userId (rule-safe) and filter the event client-side. Querying by
  // eventId alone is rejected with permission-denied.
  Future<void> loadProposalsForEvent(String eventId, {String? ownerUserId}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      Query<Map<String, dynamic>> query = _firestore.collection('proposals');
      if (ownerUserId != null && ownerUserId.isNotEmpty) {
        query = query.where('userId', isEqualTo: ownerUserId);
      } else {
        query = query.where('eventId', isEqualTo: eventId);
      }
      final snapshot = await query.get();

      _proposals = snapshot.docs
          .map((doc) => ProposalModel.fromMap(doc.data(), doc.id))
          .where((p) => p.eventId == eventId)
          .toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      _error = 'Failed to load proposals: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadProposalsForVendor(String vendorUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // A proposal is always stored with vendorId == the vendor's Firebase Auth
      // uid, which is also what the Firestore security rules enforce
      // (request.auth.uid == resource.data.vendorId). Querying by anything else
      // (e.g. the vendors-collection document id) is rejected with
      // permission-denied, so we query by the auth uid only.
      final snapshot = await _firestore
          .collection('proposals')
          .where('vendorId', isEqualTo: vendorUserId)
          .orderBy('createdAt', descending: true)
          .get();

      _proposals = snapshot.docs
          .map((doc) => ProposalModel.fromMap(doc.data(), doc.id))
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
      try {
        // ignore: avoid_print
        print('submitProposalRequest: saving proposal for vendorId=${proposal.vendorId}, eventId=${proposal.eventId}');
      } catch (_) {}
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

      // Reject every other proposal on this event once one is accepted.
      // Query by the event owner's userId (rule-safe) and match the event
      // client-side — a query by eventId alone is rejected by the read rule.
      final ownerId = proposalData['userId'];
      final proposalsSnapshot = await _firestore
          .collection('proposals')
          .where('userId', isEqualTo: ownerId)
          .get();

      for (var doc in proposalsSnapshot.docs) {
        if (doc.id != proposalId && doc.data()['eventId'] == eventId) {
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

  // Vendor asks the customer for more details before quoting. Sets the proposal
  // to `info_requested`, stores the vendor's question, and notifies the customer
  // (userId) so they see it in notifications and on the request.
  Future<String?> vendorRequestMoreInfo(String proposalId, String question) async {
    try {
      final proposalDoc = await _firestore.collection('proposals').doc(proposalId).get();
      final proposalData = proposalDoc.data();

      if (proposalData == null) {
        return 'Proposal not found';
      }

      await _firestore.collection('proposals').doc(proposalId).update({
        'status': 'info_requested',
        'vendorReply': question,
        'respondedAt': FieldValue.serverTimestamp(),
      });

      // Notify the customer (event owner).
      await _firestore.collection('notifications').add({
        'userId': proposalData['userId'],
        'type': 'vendor_info_requested',
        'title': 'Vendor needs more info',
        'message': '${proposalData['vendorName']} asked for more details about ${proposalData['eventName']}: $question',
        'eventId': proposalData['eventId'],
        'proposalId': proposalId,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } catch (e) {
      return 'Failed to request more info: $e';
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
