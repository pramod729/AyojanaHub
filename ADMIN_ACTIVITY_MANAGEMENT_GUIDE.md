# Admin Activity Management Guide

## Overview
The admin dashboard now has comprehensive activity tracking and management for both vendors and customers. The admin can monitor all actions performed by users and vendors in real-time through the enhanced **Activities** tab.

---

## Features

### 1. **Complete Activity Tracking**
All user and vendor activities are automatically logged including:
- **Authentication**: Login, logout, registration, password reset, profile updates
- **Events**: Create, update, delete, publish, archive events
- **Bookings**: Create, update, confirm, cancel, complete, and payment activities
- **Vendors**: Profile updates, proposal submissions, booking acceptances/rejections
- **Payments**: Payment initiated, successful, failed, refunds
- **Chat**: Message sent, conversation started, messages deleted
- **Admin Actions**: User management, role changes, booking status updates

### 2. **Advanced Filtering**
The Activities tab allows filtering by:
- **Role**: View activities from Vendors or Customers
- **Activity Type**: Filter by specific action types (authentication, event, booking, etc.)
- **Date Range**: Select custom date ranges to view historical activities
- **Search**: Full-text search across activity titles, descriptions, and user names

### 3. **Activity Analytics**
Quick stats displayed at the top of Activities tab:
- Total Vendor Activities
- Total Customer Activities

### 4. **Detailed Activity Views**
Click "Details" on any activity to view:
- Complete activity information
- Metadata about related entities
- Timestamps with precise timestamps
- Related IDs and types

### 5. **User Summaries**
Click "Summary" next to vendor or customer activities to view:
- Total number of activities
- Number of different activity types
- Last activity timestamp
- Recent activity list

---

## How to Use the Activities Tab

### Step 1: Access the Activities Tab
1. Log in as an admin
2. Navigate to "Admin Dashboard"
3. Click on the "**Activities**" tab (last tab)

### Step 2: View All Activities
By default, all recent activities are displayed in a chronological list (newest first).

### Step 3: Filter Activities

#### By User Role:
1. Click the "**Role: All**" chip
2. Select either:
   - **All** (default - shows all users)
   - **Vendor** (shows only vendor activities)
   - **Customer** (shows only customer activities)

#### By Activity Type:
1. Click the "**Type: All**" chip
2. Select from available types:
   - **All** (default)
   - **Authentication** (logins, registrations)
   - **Event** (event management)
   - **Booking** (booking operations)
   - **Payment** (payment transactions)
   - **Vendor** (vendor-specific actions)
   - **Chat** (messaging)
   - **Admin** (admin operations)

#### By Date Range:
1. Click the "**Date: All**" chip
2. Select start and end dates
3. Activities will be filtered to show only those within the selected range

#### By Text Search:
1. Type in the search box
2. Search across:
   - Activity titles
   - Activity descriptions
   - User names
   - Email addresses

### Step 4: Clear Filters
Click the "**Clear**" button to reset all filters at once.

---

## Activity Card Information

Each activity card displays:

| Field | Description |
|-------|-------------|
| **Icon & Title** | Activity type with descriptive title |
| **Description** | Details about what was done |
| **User Name** | Person who performed the action |
| **User Email** | Email of the person |
| **Timestamp** | Exact date and time of activity |
| **Role Badge** | VENDOR or CUSTOMER badge |
| **Details** | Additional metadata if available |

### Action Buttons:
- **Details**: View full activity information in a dialog
- **Summary**: For vendor/customer activities, view their activity summary

---

## Understanding Activity Types

### Authentication Activities
Logged when users:
- Sign up (register)
- Log in
- Log out
- Reset password
- Update profile
- Upload profile photo

**Example**: "Auth: LOGIN" - User logged in

### Event Activities
Logged when users:
- Create events
- Update events
- Delete events
- Publish events
- Archive events

**Example**: "Event: CREATE" - Created new event "Wedding 2024"

### Booking Activities
Logged when:
- Customers create bookings
- Vendors accept/reject bookings
- Booking status is updated
- Booking is completed/cancelled
- Payment is processed

**Example**: "Booking: CREATE" - Created booking "Royal Wedding - Catering"

### Vendor Activities
Logged when:
- Vendor profiles are updated
- Proposals are submitted
- Vendor portfolio photos are uploaded
- Vendors accept/reject bookings

**Example**: "Vendor: SUBMIT_PROPOSAL" - Submitted proposal for Event ID

### Payment Activities
Logged for:
- Payment initiations
- Successful payments
- Failed payments
- Refunds initiated/completed

**Example**: "Payment: PAYMENT_SUCCESS" - ₹50,000.00

### Chat Activities
Logged for:
- Messages sent
- Conversations started
- Messages deleted

**Example**: "Chat: MESSAGE_SENT" - Sent message with Customer Name

---

## Admin Dashboard Statistics

### Dashboard Tab Overview:
- **Total Users**: All registered customers
- **Total Vendors**: All vendors
- **Total Bookings**: All bookings in system
- **Total Events**: All created events
- **Completed Bookings**: Percentage of completed bookings
- **Total Revenue**: Revenue from completed bookings
- **Avg Revenue/Booking**: Average booking value

---

## Best Practices for Admin Management

### 1. **Daily Activity Review**
- Check the Activities tab daily
- Filter by date range to see today's activities
- Look for unusual patterns or problematic activities

### 2. **Monitor Vendor Performance**
- Click "Summary" on vendor activities
- Review their recent actions
- Check their booking acceptance rate
- Monitor response times

### 3. **Track Customer Behavior**
- Monitor customer activity patterns
- Identify most active customers
- Track booking completion rates
- Identify potential issues early

### 4. **Investigate Issues**
- Use detailed filters to find specific activities
- Review full activity details
- Check metadata for additional context
- Cross-reference with other users' activities

### 5. **Manage Problematic Users**
- If user behavior is suspicious or problematic:
  1. Review their complete activity history (Summary)
  2. Go to Users/Vendors tab
  3. Update their role or delete their account if needed
  4. Activity logs will be preserved for records

---

## Integration Points - Where Activities Are Logged

### Authentication (activity_service.dart)
- User registration
- Login/logout
- Password reset
- Profile updates

### Bookings
**Required Integration**: When implementing booking features, call:
```dart
await ActivityService().logBookingActivity(
  user,
  action: 'create',  // or 'update', 'confirm', 'cancel', 'complete', 'payment'
  bookingId: bookingId,
  bookingName: bookingName,
  vendorName: vendorName,
  description: 'Optional custom description',
  bookingData: {'key': 'value'} // Optional metadata
);
```

### Events
**Required Integration**: When implementing event features, call:
```dart
await ActivityService().logEventActivity(
  user,
  action: 'create',  // or 'update', 'delete', 'view', 'publish', 'archive'
  eventId: eventId,
  eventName: eventName,
  description: 'Optional description',
  eventData: {'key': 'value'} // Optional metadata
);
```

### Vendor Operations
**Required Integration**: When vendors perform actions, call:
```dart
await ActivityService().logVendorActivity(
  user,
  action: 'profile_update',  // or 'submit_proposal', 'update_proposal', 'accept_booking', etc.
  vendorId: vendorId,
  vendorName: vendorName,
  description: 'Optional description',
  vendorData: {'key': 'value'} // Optional metadata
);
```

### Payments
**Required Integration**: When processing payments, call:
```dart
await ActivityService().logPaymentActivity(
  user,
  action: 'payment_success',  // or other payment actions
  paymentId: paymentId,
  amount: amount,
  description: 'Payment description',
  paymentData: {'transaction_id': transactionId} // Optional metadata
);
```

---

## Key AdminProvider Methods

For custom functionality, the AdminProvider provides:

```dart
// Get activities by filters
provider.getVendorActivities()
provider.getCustomerActivities()
provider.getActivityLogsByType('booking')
provider.getActivitiesByDateRange(startDate, endDate)
provider.getRecentActivities(hoursAgo: 24)

// Get statistics
provider.getActivityStatsByType()
provider.getActivityStatsByRole()
provider.getTopActiveUsers(limit: 10)
provider.countActivitiesByType('booking')
provider.countActivitiesByRole('vendor')

// Get user-specific summaries
provider.getVendorActivitySummary(vendorId)
provider.getCustomerActivitySummary(customerId)
```

---

## Troubleshooting

### Activities Not Showing
1. Ensure `provider.fetchActivityLogs()` is called on admin screen load
2. Check that `ActivityService().logActivity()` is being called in user actions
3. Verify Firebase Firestore has 'activityLogs' collection created

### Missing Activity Types
1. Check the action names match: 'create', 'update', 'delete', etc.
2. Ensure ActivityService methods are imported and called
3. Verify user object passed has correct role and data

### Filters Not Working
1. Clear all filters and try one at a time
2. Ensure date range picker provides valid dates
3. Check that FilterChip selections are registered in state

---

## Summary

The enhanced Admin Activity Management system provides complete visibility into all vendor and customer actions within your platform. Use these powerful filtering and analytics capabilities to:
- Monitor platform health
- Identify potential issues
- Manage user behavior
- Track business metrics
- Make data-driven decisions

For questions or additional features, reference the [ACTIVITY_LOGGING_GUIDE.dart](ACTIVITY_LOGGING_GUIDE.dart) for technical implementation details.
