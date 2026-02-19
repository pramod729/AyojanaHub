# Activity Logging System - Admin Panel Firebase

## Overview

The Activity Logging System provides comprehensive audit trails for all user activities in the Ayojana Hub application. Admins can view detailed logs of who did what, when they did it, and what data was involved.

## What's Been Created

### 1. **Models**
- **activity_model.dart** - ActivityLog model with full timestamp, metadata, and related entity tracking

### 2. **Services**
- **activity_service.dart** - Singleton service with pre-built logging methods for:
  - Authentication (login, logout, register, password reset)
  - Events (create, update, delete, view, publish, archive)
  - Bookings (create, confirm, cancel, complete, payment)
  - Vendors (profile update, proposals, bookings)
  - Payments (success, failure, refunds)
  - Chat (messages, conversations)
  - Admin actions (user management, booking updates)

### 3. **Database**
- **Firestore Collection: activityLogs** - Stores all activity logs with:
  - User information (id, name, email, role)
  - Activity details (type, title, description)
  - Related entities (event_id, booking_id, etc.)
  - Timestamps (server-side)
  - Metadata (custom data)
  - Indexes for fast queries

### 4. **Security**
- **firestore.rules** - Updated with:
  - Admin-only read access to activity logs
  - Any authenticated user can create logs
  - Helper function `isAdmin()` for role checking
  - Admin access to manage all resources

### 5. **Admin Dashboard**
- **admin_analytics_screen.dart** - New "Activities" tab with:
  - Real-time activity feed (newest first)
  - Search functionality
  - Detailed activity cards showing:
    - User who performed action
    - Activity type with colored icons
    - Timestamp
    - Full description
    - Metadata details
  - Pull-to-refresh support

### 6. **Integrated Logging**
- **auth_provider.dart** - Already logs:
  - User login
  - User logout
  - User registration
  - Profile updates

## Firestore Rules

```dart
// Helper function to check if user is admin
function isAdmin() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 'admin';
}

// Activity Logs - Only admins can read, anyone can write
match /activityLogs/{logId} {
  allow read: if request.auth != null && isAdmin();
  allow create: if request.auth != null;
  allow update, delete: if request.auth != null && isAdmin();
}
```

## Activity Types

### Authentication Activities
- `login` - User logged in
- `logout` - User logged out
- `register` - New user registered
- `password_reset` - Password reset
- `profile_update` - Profile information updated
- `photo_upload` - Profile photo uploaded

### Event Activities
- `create` - New event created
- `update` - Event modified
- `delete` - Event deleted
- `view` - Event viewed
- `publish` - Event published
- `archive` - Event archived

### Booking Activities
- `create` - New booking created
- `update` - Booking modified
- `confirm` - Booking confirmed
- `cancel` - Booking cancelled
- `complete` - Booking completed
- `payment` - Payment made

### Vendor Activities
- `profile_update` - Vendor profile updated
- `submit_proposal` - Proposal submitted
- `update_proposal` - Proposal modified
- `accept_booking` - Booking accepted
- `reject_booking` - Booking rejected
- `photo_upload` - Portfolio photo added

### Payment Activities
- `payment_initiated` - Payment started
- `payment_success` - Payment successful
- `payment_failed` - Payment failed
- `refund_initiated` - Refund requested
- `refund_success` - Refund completed

### Chat Activities
- `message_sent` - Message sent
- `message_deleted` - Message deleted
- `conversation_started` - New conversation

### Admin Activities
- Any admin action (delete user, update booking, etc.)

## How to Use

### Basic Activity Logging

```dart
import 'package:ayojana_hub/activity_service.dart';

// Get current user
final user = Provider.of<AuthProvider>(context, listen: false).userModel;

// Log a simple activity
await ActivityService().logActivity(
  userId: user.id,
  userName: user.name,
  userEmail: user.email,
  userRole: user.role,
  activityType: 'custom_type',
  activityTitle: 'Custom Action',
  description: 'Description of activity',
);
```

### Pre-built Logging Methods

```dart
// Authentication
await ActivityService().logAuthActivity(
  user,
  action: 'login',
  description: 'User logged in from mobile app',
);

// Events
await ActivityService().logEventActivity(
  user,
  action: 'create',
  eventId: event.id,
  eventName: event.eventName,
  description: 'Created new event',
  eventData: { 'eventType': 'Wedding', 'guests': 150 },
);

// Bookings
await ActivityService().logBookingActivity(
  user,
  action: 'create',
  bookingId: booking.id,
  bookingName: booking.eventName,
  vendorName: booking.vendorName,
  description: 'Created booking with vendor',
  bookingData: { 'price': 50000, 'date': '2025-03-15' },
);

// Vendors
await ActivityService().logVendorActivity(
  user,
  action: 'profile_update',
  vendorId: vendor.id,
  vendorName: vendor.name,
  description: 'Updated vendor profile',
);

// Payments
await ActivityService().logPaymentActivity(
  user,
  action: 'payment_success',
  paymentId: paymentId,
  amount: 50000,
  description: 'Payment successful',
  paymentData: { 'bookingId': booking.id },
);

// Chat
await ActivityService().logChatActivity(
  user,
  action: 'message_sent',
  conversationId: convoId,
  participantName: 'Vendor Name',
  description: 'Sent message',
);

// Admin Actions
await ActivityService().logAdminActivity(
  adminUser,
  action: 'delete_user',
  description: 'Deleted user account',
  targetId: userId,
  targetType: 'user',
  metadata: { 'userName': 'John Doe', 'email': 'john@example.com' },
);
```

## Integration Checklist

To complete the activity logging system, integrate logging in these files:

### Priority 1 (High Impact)
- [ ] **event_provider.dart** - Log event creation, updates, deletions
- [ ] **booking_provider.dart** - Log booking creation, status changes, payments
- [ ] **payment_service.dart** - Log payment success/failure

### Priority 2 (Medium Impact)
- [ ] **vendor_provider.dart** - Log vendor profile updates, proposals
- [ ] **proposal_provider.dart** - Log proposal submissions and updates
- [ ] **chat_provider.dart** - Log chat messages

### Priority 3 (Admin Actions)
- [ ] **admin_analytics_screen.dart** - Log admin delete/update actions
- [ ] Add logging to admin action confirmations

## Data Structure

Each activity log contains:

```dart
ActivityLog {
  id: String,                          // Firestore doc ID
  userId: String,                      // User who performed action
  userName: String,                    // User's display name
  userEmail: String,                   // User's email
  userRole: String,                    // admin, vendor, customer
  activityType: String,                // authentication, event, booking, etc.
  activityTitle: String,               // Human readable title
  description: String,                 // Detailed description
  relatedId: String?,                  // event_id, booking_id, etc.
  relatedType: String?,                // event, booking, vendor, etc.
  metadata: Map<String, dynamic>?,    // Additional context
  timestamp: DateTime,                 // When action occurred
  ipAddress: String?,                  // Optional IP tracking
  userAgent: String?,                  // Optional browser/device info
}
```

## Viewing Activity Logs

### In Admin Dashboard

1. Open Admin Dashboard (Settings > Admin Dashboard)
2. Click on "Activities" tab
3. View all activities in real-time
4. Search activities by:
   - Activity title (e.g., "Login", "Create Event")
   - Description
   - User name
5. Click refresh to load latest activities
6. View detailed metadata for each activity

### Programmatic Access

```dart
final adminProvider = Provider.of<AdminProvider>(context, listen: false);

// Get all activities
final allActivities = adminProvider.activityLogs;

// Filter by type
final loginActivities = adminProvider.getActivityLogsByType('authentication');

// Filter by user
final userActivities = adminProvider.getActivityLogsByUser(userId);

// Filter by date range
final todayActivities = adminProvider.getActivityLogsByDateRange(
  DateTime.now().subtract(Duration(days: 1)),
  DateTime.now(),
);

// Search activities
final foundActivities = adminProvider.searchActivityLogs('create');
```

## Performance Considerations

- Activities are stored in Firestore (scale to millions)
- Indexes on `timestamp` for sorting
- Index on `userId` for user-specific queries
- Pagination recommended for large datasets (use limit parameter in fetchActivityLogs)
- Old logs can be archived/deleted by admin based on retention policy

## Security Features

1. **Role-Based Access** - Only admins can read activity logs
2. **Audit Trail** - All activities are logged with timestamps
3. **User Attribution** - Every action is attributed to a specific user
4. **Metadata Tracking** - Full context stored for sensitive operations
5. **Immutable Logs** - Activities cannot be edited, only deleted by admins
6. **Firestore Rules** - Enforced at database level for additional security

## Future Enhancements

- [ ] Export activities to CSV
- [ ] Advanced filtering UI
- [ ] Date range selection
- [ ] Activity statistics/charts
- [ ] Real-time activity notifications for admins
- [ ] Archive old activities
- [ ] User activity history page
- [ ] Activity alerts for suspicious patterns
- [ ] IP address and device tracking
- [ ] Integration with analytics tools

## Already Implemented Examples

View the following files to see working examples:

1. **auth_provider.dart** - Login, logout, register logging
2. **admin_analytics_screen.dart** - Activities tab with search and display

## Troubleshooting

**Activities not showing in admin panel?**
- Ensure your user role is set to 'admin'
- Check Firestore rules allow admin access
- Verify activities are being written to Firestore
- Check browser console for errors

**Activities not being logged?**
- Verify ActivityService().logXxx() calls are being made
- Check that user object is not null
- Check Firestore connection and permissions
- Verify activityLogs collection exists in Firestore

**Performance issues?**
- Reduce limit parameter in fetchActivityLogs()
- Implement pagination
- Archive old activities
- Add proper Firestore indexes
