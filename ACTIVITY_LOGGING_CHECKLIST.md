# Activity Logging Implementation Checklist

This file contains a checklist of all places in your app where activities should be logged to ensure comprehensive activity tracking.

## Authentication & User Management ✓ (Mostly Implemented)

### Registration/Login Flows
- [x] User Registration (Register Screen)
- [x] User Login (Login Screen)
- [x] User Logout (Any Screen with logout)
- [x] Password Reset
- [x] Profile Update
- [x] Profile Photo Upload

**Status**: Check the following files and add `ActivityService().logAuthActivity()` if missing:
- [ ] `lib/register_screen_new.dart` - Log 'register'
- [ ] `lib/login_screen.dart` - Log 'login'
- [ ] `lib/profile_screen.dart` - Log 'profile_update' on save
- [ ] Main logout function - Log 'logout'

---

## Event Management

### Event Creation & Management
- [ ] Create Event
- [ ] Update Event
- [ ] Delete Event
- [ ] View Event Details
- [ ] Publish Event
- [ ] Archive Event

**Implementation Locations**:
- `lib/create_event_screen.dart` - On event creation
- `lib/event_detail_screen.dart` - On update/delete
- `lib/my_events_screen.dart` - On publish/archive

**Code Example**:
```dart
await ActivityService().logEventActivity(
  userModel,
  action: 'create',
  eventId: event.id,
  eventName: event.name,
  description: 'Created event with ${event.guestCount} guests',
  eventData: {
    'eventType': event.eventType,
    'location': event.location,
    'budget': event.budget,
  },
);
```

---

## Booking Management

### Customer Activities
- [ ] Create Booking
- [ ] View Booking Details
- [ ] Cancel Booking
- [ ] Complete Booking Review

**Implementation Locations**:
- `lib/booking_form_screen.dart` - On booking creation
- `lib/booking_detail_screen.dart` - On cancel/complete
- `lib/my_bookings_screen.dart` - On view details

**Code Example**:
```dart
await ActivityService().logBookingActivity(
  userModel,
  action: 'create',
  bookingId: booking.id,
  bookingName: booking.eventName,
  vendorName: booking.vendorName,
  description: 'Booked ${booking.vendorName} for ${booking.eventName}',
  bookingData: {
    'eventDate': booking.eventDate.toString(),
    'guestCount': booking.guestCount,
    'price': booking.price,
  },
);
```

### Vendor Activities
- [ ] Accept Booking
- [ ] Reject Booking
- [ ] Update Booking Status
- [ ] Complete Service

**Implementation Locations**:
- `lib/vendor_bookings_screen.dart` - On accept/reject/update
- `lib/vendor_proposals_screen.dart` - On proposal status change

**Code Example**:
```dart
await ActivityService().logBookingActivity(
  vendorUser,
  action: 'accept',
  bookingId: booking.id,
  bookingName: booking.eventName,
  vendorName: vendorUser.name,
  description: 'Accepted booking for ${booking.eventName}',
);
```

---

## Vendor Operations

### Vendor Profile & Proposals
- [ ] Update Vendor Profile
- [ ] Upload Portfolio Photos
- [ ] Submit Event Proposal
- [ ] Update Proposal Quote
- [ ] Accept Service Request
- [ ] Reject Service Request

**Implementation Locations**:
- `lib/vendor_detail_screen.dart` - On profile update
- `lib/vendor_register_screen.dart` - On registration
- `lib/submit_proposal_screen.dart` - On proposal submission
- `lib/vendor_proposals_screen.dart` - On proposal status change

**Code Example**:
```dart
await ActivityService().logVendorActivity(
  vendorUser,
  action: 'submit_proposal',
  vendorId: vendorUser.id,
  vendorName: vendorUser.name,
  description: 'Submitted proposal for ${eventName}',
  vendorData: {
    'proposalAmount': amount,
    'eventType': eventType,
  },
);
```

---

## Payment Processing

### Payment Activities
- [ ] Payment Initiated
- [ ] Payment Successful
- [ ] Payment Failed
- [ ] Refund Initiated
- [ ] Refund Completed

**Implementation Locations**:
- `lib/payment_screen.dart` - On payment initiation/success/failure
- Payment service methods

**Code Example**:
```dart
await ActivityService().logPaymentActivity(
  userModel,
  action: 'payment_success',
  paymentId: transactionId,
  amount: amount,
  description: 'Payment received for ${bookingName}',
  paymentData: {
    'bookingId': bookingId,
    'paymentMethod': paymentMethod,
    'transactionId': transactionId,
  },
);
```

---

## Chat & Messaging

### Chat Activities
- [ ] Send Message
- [ ] Start Conversation
- [ ] Delete Message
- [ ] View Chat Thread

**Implementation Locations**:
- `lib/chat_screen.dart` - On message send/delete
- `lib/conversations_list_screen.dart` - On conversation start

**Code Example**:
```dart
await ActivityService().logChatActivity(
  userModel,
  action: 'message_sent',
  conversationId: conversationId,
  participantName: recipientName,
  description: 'Sent message to $recipientName about booking',
);
```

---

## Admin Actions

### Admin Management
- [ ] Delete User
- [ ] Update User Role
- [ ] Update Booking Status
- [ ] Delete Booking
- [ ] Delete Event
- [ ] Suspend/Ban User

**Implementation Locations**:
- `lib/admin_provider.dart` - In user/booking/event management methods

**Code Example**:
```dart
await ActivityService().logAdminActivity(
  adminUser,
  action: 'delete_user',
  description: 'Deleted user account',
  targetId: userId,
  targetType: 'user',
  metadata: {
    'userName': userName,
    'userEmail': userEmail,
    'reason': reason,
  },
);
```

---

## Proposal Management

### Event Proposal Activities
- [ ] View Proposals
- [ ] Submit Proposal
- [ ] Accept Proposal
- [ ] Reject Proposal
- [ ] Update Proposal Status

**Implementation Locations**:
- `lib/event_proposals_screen.dart` - On proposal actions
- `lib/vendor_proposals_screen.dart` - On vendor side

**Code Example**:
```dart
await ActivityService().logActivity(
  userId: userId,
  userName: userName,
  userEmail: userEmail,
  userRole: userRole,
  activityType: 'proposal',
  activityTitle: 'Proposal: SUBMIT',
  description: 'Submitted proposal for ${eventName}',
  relatedId: proposalId,
  relatedType: 'proposal',
  metadata: {
    'eventId': eventId,
    'proposalAmount': amount,
  },
);
```

---

## Vendor Search & Discovery

### User Browse Activities
- [ ] View Vendor List
- [ ] View Vendor Details
- [ ] Search Vendors by Category
- [ ] Filter Vendors by Rating

**Implementation Locations** (Optional - only if detailed tracking needed):
- `lib/vendor_list_screen.dart`
- `lib/vendor_detail_screen.dart`
- `lib/vendor_opportunities_screen.dart`

---

## Implementation Priority

### High Priority (Must Implement First)
1. Booking creation/updates
2. Payment processing
3. Vendor proposal submission
4. Event creation/updates
5. Admin user management

### Medium Priority (Important)
1. Chat/messaging
2. Vendor profile updates
3. Booking acceptance/rejection
4. Payment failures
5. Admin deletions

### Low Priority (Nice to Have)
1. View/browse activities
2. Search activities
3. Profile photo uploads
4. Chat message reads
5. Proposal views

---

## Testing Checklist

After implementing activity logging in each section:

### Test Creation
- [ ] Perform action (create/update/delete)
- [ ] Check Firebase 'activityLogs' collection
- [ ] Verify all fields are populated correctly
- [ ] Check timestamp is server-generated
- [ ] Verify metadata contains relevant data

### Test Admin Visibility
- [ ] Log in as admin
- [ ] Go to Activities tab
- [ ] Verify new activity appears at top
- [ ] Test search functionality
- [ ] Test role filter
- [ ] Test activity type filter
- [ ] Test date range filter
- [ ] Click "Details" button
- [ ] Click "Summary" button (for vendor/customer)

### Test Data Integrity
- [ ] Verify userId is correct
- [ ] Verify userName matches actual user
- [ ] Verify userEmail is accurate
- [ ] Verify userRole is correct
- [ ] Verify relatedId points to correct entity
- [ ] Verify metadata contains expected key-value pairs

---

## Code Integration Template

Use this template when adding activity logging to any feature:

```dart
// 1. Import ActivityService
import 'package:ayojana_hub/activity_service.dart';

// 2. In your action handler (create, update, delete, etc.)
Future<void> handleAction() async {
  try {
    // Perform the action
    final result = await performYourAction();
    
    // 3. Log the activity
    await ActivityService().log[ActionType]Activity(
      user, // Pass the UserModel
      action: 'action_name', // create, update, delete, etc.
      [requiredId]: [id], // eventId, bookingId, etc.
      [requiredName]: [name], // eventName, bookingName, etc.
      description: 'Custom description',
      [dataKey]: {
        'metadata_key': 'metadata_value',
      },
    );
    
    // 4. Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Success')),
    );
  } catch (e) {
    // Handle error
    debugPrint('Error: $e');
  }
}
```

---

## Common Issues & Solutions

### Activity Not Appearing in Admin Panel
**Check**:
1. Is `ActivityService().logActivity()` being called?
2. Is the UserModel passed with correct data?
3. Has the admin called `provider.fetchActivityLogs()`?
4. Are there any Firebase permissions issues?

### Missing Metadata
**Check**:
1. Is metadata parameter being passed?
2. Is metadata as Map<String, dynamic>?
3. Are all values serializable to Firestore?

### Incorrect Timestamps
**Check**:
1. Use `FieldValue.serverTimestamp()` in ActivityService
2. Never use `DateTime.now()` for timestamps
3. Ensure device time is synced

---

## References

- [Activity Model](lib/activity_model.dart) - Data structure
- [Activity Service](lib/activity_service.dart) - Logging methods
- [Admin Provider](lib/admin_provider.dart) - Data retrieval & filtering
- [Admin Analytics Screen](lib/admin_analytics_screen.dart) - UI & display
- [Admin Activity Management Guide](ADMIN_ACTIVITY_MANAGEMENT_GUIDE.md) - User guide

---

**Last Updated**: April 11, 2026
**Status**: In Progress - Comprehensive implementation ongoing
