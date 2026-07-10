# TICKET-01: Implement MongoDB Database Schema & Connection

## Type
Feature

## Priority
High

## Status
Done

## Summary
Design and implement the MongoDB database layer for NextStepLearning using a Dart backend. This includes defining all collection schemas, establishing the MongoDB connection, and structuring data models to support authentication, messaging, scheduling, AI chat history, notifications, and mock payments.

---

## Connection Details

| Field | Value |
|-------|-------|
| Provider | MongoDB Atlas |
| Connection String | `mongodb+srv://ashir111:Ashir111@cluster0.otww29p.mongodb.net/myDatabase?appName=Cluster0` |
| Database Name | `tutorgo_db` |
| Backend | Dart (shelf / dart_frog or custom server) |
| Auth Method | Username + Password (no OAuth, no Firebase) |

---

## Database Schema

### 1. `users` Collection

Single collection for both students and tutors, differentiated by `role` field.

```json
{
  "_id": "ObjectId",
  "role": "student | tutor",
  "email": "String (unique, indexed)",
  "password": "String (hashed - bcrypt/argon2)",
  "fullName": "String",
  "phone": "String",
  "profileImage": "String (base64 encoded PNG)",
  "isActive": "Boolean (default: true)",
  "isVerified": "Boolean (default: false)",
  "createdAt": "DateTime",
  "updatedAt": "DateTime",

  // Student-specific fields (null if tutor)
  "studentProfile": {
    "age": "int",
    "grade": "String",
    "address": "String",
    "selectedCourses": ["String"],
    "dailyGoalMinutes": "int (default: 30)"
  },

  // Tutor-specific fields (null if student)
  "tutorProfile": {
    "experienceYears": "int",
    "qualification": "String",
    "subjects": ["String"],
    "bio": "String",
    "rating": "double (default: 0.0)",
    "totalRatings": "int (default: 0)",
    "pricePerHourPKR": "int",
    "isApproved": "Boolean (default: false)",
    "documents": {
      "cnicFront": "String (base64 PNG)",
      "cnicBack": "String (base64 PNG)",
      "teachingCertificate": "String (base64 PNG)",
      "degree": "String (base64 PNG)"
    }
  }
}
```

**Indexes:**
- `email` — unique
- `role` — standard
- `tutorProfile.subjects` — multikey (for tutor search by subject)
- `tutorProfile.isApproved` — standard

---

### 2. `sessions` Collection

Recurring tutoring sessions between a student and tutor.

```json
{
  "_id": "ObjectId",
  "studentId": "ObjectId (ref: users)",
  "tutorId": "ObjectId (ref: users)",
  "subject": "String",
  "recurrence": {
    "dayOfWeek": "int (1=Mon, 7=Sun)",
    "startTime": "String (HH:mm)",
    "endTime": "String (HH:mm)",
    "startDate": "DateTime",
    "endDate": "DateTime | null (null = ongoing)"
  },
  "status": "active | paused | cancelled | completed",
  "pricePerSessionPKR": "int",
  "notes": "String",
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**Indexes:**
- `studentId` — standard
- `tutorId` — standard
- `recurrence.dayOfWeek` — standard
- `status` — standard

---

### 3. `session_instances` Collection

Individual occurrences of a recurring session (for tracking attendance, rescheduling).

```json
{
  "_id": "ObjectId",
  "sessionId": "ObjectId (ref: sessions)",
  "studentId": "ObjectId (ref: users)",
  "tutorId": "ObjectId (ref: users)",
  "scheduledDate": "DateTime",
  "startTime": "String (HH:mm)",
  "endTime": "String (HH:mm)",
  "status": "scheduled | completed | cancelled | missed",
  "rating": "int | null (1-5, given by student)",
  "feedback": "String | null",
  "createdAt": "DateTime"
}
```

**Indexes:**
- `sessionId` — standard
- `tutorId + scheduledDate` — compound
- `studentId + scheduledDate` — compound

---

### 4. `chats` Collection

Chat rooms between a student and tutor.

```json
{
  "_id": "ObjectId",
  "participants": ["ObjectId (ref: users)", "ObjectId (ref: users)"],
  "lastMessage": {
    "text": "String",
    "senderId": "ObjectId",
    "timestamp": "DateTime"
  },
  "unreadCount": {
    "<userId>": "int"
  },
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**Indexes:**
- `participants` — multikey
- `updatedAt` — descending (for sorting recent chats)

---

### 5. `messages` Collection

Individual messages within a chat.

```json
{
  "_id": "ObjectId",
  "chatId": "ObjectId (ref: chats)",
  "senderId": "ObjectId (ref: users)",
  "text": "String",
  "type": "text | session_request | session_response",
  "sessionRequest": {
    "subject": "String",
    "dayOfWeek": "int",
    "startTime": "String",
    "endTime": "String",
    "pricePerSessionPKR": "int",
    "status": "pending | accepted | rejected"
  },
  "status": "sent | delivered | seen",
  "createdAt": "DateTime"
}
```

**Indexes:**
- `chatId + createdAt` — compound (for paginated message fetch)
- `senderId` — standard

---

### 6. `ai_conversations` Collection

AI tutor chat history per user.

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users)",
  "role": "student | tutor",
  "title": "String (auto-generated from first message)",
  "messages": [
    {
      "text": "String",
      "isUser": "Boolean",
      "timestamp": "DateTime"
    }
  ],
  "createdAt": "DateTime",
  "updatedAt": "DateTime"
}
```

**Indexes:**
- `userId` — standard
- `updatedAt` — descending

---

### 7. `notifications` Collection

Persistent notifications with scheduler support.

```json
{
  "_id": "ObjectId",
  "userId": "ObjectId (ref: users)",
  "title": "String",
  "body": "String",
  "type": "session_reminder | message | session_request | payment | system",
  "referenceId": "ObjectId | null (points to related session/chat/payment)",
  "isRead": "Boolean (default: false)",
  "scheduledFor": "DateTime (when to show the notification)",
  "createdAt": "DateTime"
}
```

**Indexes:**
- `userId + isRead` — compound
- `userId + scheduledFor` — compound (for scheduler queries)
- `scheduledFor` — standard (TTL or scheduler pick-up)

---

### 8. `payments` Collection

Mock payment records (no real gateway, tracks session payments in PKR).

```json
{
  "_id": "ObjectId",
  "studentId": "ObjectId (ref: users)",
  "tutorId": "ObjectId (ref: users)",
  "sessionInstanceId": "ObjectId (ref: session_instances)",
  "amountPKR": "int",
  "status": "pending | completed | refunded",
  "method": "cash | bank_transfer | easypaisa | jazzcash",
  "transactionDate": "DateTime",
  "createdAt": "DateTime"
}
```

**Indexes:**
- `studentId` — standard
- `tutorId` — standard
- `status` — standard

---

## Technical Requirements

### Dart Backend Stack

| Component | Choice |
|-----------|--------|
| Runtime | Dart |
| HTTP Server | `shelf` + `shelf_router` or `dart_frog` |
| MongoDB Driver | `mongo_dart` package |
| Password Hashing | `dbcrypt` or `pointycastle` |
| JWT Auth | `dart_jsonwebtoken` |
| File Encoding | Base64 (PNG images stored as strings) |

### API Endpoints (High Level)

| Group | Endpoints |
|-------|-----------|
| Auth | `POST /auth/register`, `POST /auth/login`, `POST /auth/refresh` |
| Users | `GET /users/me`, `PUT /users/me`, `GET /tutors`, `GET /tutors/:id` |
| Sessions | `POST /sessions`, `GET /sessions`, `PUT /sessions/:id`, `DELETE /sessions/:id` |
| Session Instances | `GET /sessions/:id/instances`, `PUT /session-instances/:id` |
| Chats | `GET /chats`, `GET /chats/:id/messages`, `POST /chats/:id/messages` |
| AI Chat | `GET /ai/conversations`, `POST /ai/conversations`, `POST /ai/conversations/:id/message` |
| Notifications | `GET /notifications`, `PUT /notifications/:id/read`, `PUT /notifications/read-all` |
| Payments | `GET /payments`, `POST /payments` |

### Authentication Flow

1. User registers with email + password
2. Password is hashed (bcrypt) before storing
3. Login returns JWT access token (short-lived) + refresh token (long-lived)
4. All protected routes require `Authorization: Bearer <token>` header
5. Refresh token endpoint issues new access token

### Notification Scheduler

- Background isolate or cron job runs every minute
- Queries `notifications` where `scheduledFor <= now` and `isRead == false`
- Pushes to connected clients (WebSocket or polling)
- Session reminders auto-created 30 minutes before `session_instances.scheduledDate`

---

## Acceptance Criteria

- [ ] MongoDB connection established from Dart backend using the provided connection string
- [ ] All 8 collections created with proper indexes
- [ ] User registration and login working with hashed passwords and JWT
- [ ] CRUD operations for all collections via REST API
- [ ] Base64 image encoding/decoding working for tutor documents
- [ ] Recurring session generation logic creates `session_instances` based on `sessions.recurrence`
- [ ] Chat messages persist and retrieve in chronological order
- [ ] AI conversation history saves per user
- [ ] Notifications stored and queryable by schedule time
- [ ] Mock payments save with PKR amounts
- [ ] All amounts stored in Pakistani Rupees (PKR) as integers

---

## Notes

- No Firebase integration — MongoDB is the sole data store
- No OAuth — username/password auth only
- No real payment gateway — mock flow with status tracking
- Document images (CNIC, certificates) stored as base64 strings directly in MongoDB (max ~16MB per document limit applies)
- Currency is PKR (Pakistani Rupees), stored as integers (no decimals)
