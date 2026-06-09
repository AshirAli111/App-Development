# TICKET-03: Real-Time Messaging & Video/Voice Calls

## Type
Feature

## Priority
High

## Status
To Do

## Summary
Connect the existing chat UI to the backend REST API with polling-based real-time messaging, and integrate Jitsi Meet for free video/voice calls between students and tutors. Both features must work across two physical devices for demo purposes.

## Background
- Chat UI already exists (student + tutor conversation screens) but uses hardcoded dummy data
- Backend already has full chat CRUD (`/api/chats/` endpoints with messages collection)
- Video/voice call screens exist as UI mockups with no actual streaming
- Need to bridge frontend ↔ backend for messaging and add real call functionality

## Architecture

### Part A: Real-Time Messaging (Polling-Based)

**Approach:** Poll `GET /api/chats/:id/messages` every 2 seconds. No WebSocket needed — acceptable latency for demo.

#### Backend Changes
1. **No new endpoints needed** — existing chat routes are sufficient:
   - `GET /api/chats/` — list user's chats
   - `POST /api/chats/:id/messages` — send message
   - `GET /api/chats/:id/messages?page=1&limit=50` — fetch messages
   - `PUT /api/chats/:id/read` — mark as read
2. **New endpoint**: `POST /api/chats/start` — create or get existing chat between two users (needed for initiating chat from tutor profile)
3. **Update**: Ensure chat list returns other user's name/avatar for display

#### Flutter Changes
1. **Create `ChatService`** (HTTP client layer):
   - `getChats()` → fetch user's chat list
   - `getMessages(chatId)` → fetch messages for a chat
   - `sendMessage(chatId, text, type)` → send text or session request
   - `startChat(otherUserId)` → initiate new chat
   - `markAsRead(chatId)` → mark messages as read
2. **Update `StudentChatsConversationScreen`**:
   - Replace dummy data with API calls
   - Add `Timer.periodic(2 seconds)` to poll new messages
   - Wire up send button to POST message
   - Handle session request messages
3. **Update `TutorChatConversationScreen`**:
   - Same as student version
4. **Update `StudentMessagesScreen`** and **`TutorChatsScreen`**:
   - Replace hardcoded chat list with API data
   - Poll for new messages/unread counts
5. **Session requests in chat**: Already supported in backend model — wire the existing bottom sheet form to `sendMessage(type: 'session_request')`

### Part B: Video & Voice Calls (Jitsi Meet)

**Approach:** Use `jitsi_meet_flutter_sdk` (v12.1.3) — free, no API keys, uses public `meet.jit.si` server.

#### How It Works
1. When user A initiates a call, generate a unique room name: `tutorgo_<chatId>_<timestamp>`
2. Send a chat message of type `call_invite` with the room name
3. User B's polling picks up the invite → shows incoming call UI
4. Both users join the same Jitsi room → connected with video/audio
5. For voice-only calls, join with `startWithVideoMuted: true`

#### Backend Changes
1. Add `call_invite` and `call_ended` message types to chat model
2. Add `GET /api/chats/:id/active-call` endpoint — returns active call room if one exists (for when user opens chat with pending invite)

#### Flutter Changes
1. **Add dependency**: `jitsi_meet_flutter_sdk: ^12.1.3`
2. **Create `CallService`**:
   - `startVideoCall(chatId, callerName)` → sends invite + joins room
   - `startVoiceCall(chatId, callerName)` → sends invite + joins with video off
   - `joinCall(roomName, userName)` → joins existing room
3. **Update `TutorVideoCallScreen`**:
   - Replace mockup with actual Jitsi join
   - Add call ended callback to send `call_ended` message
4. **Update `TutorVoiceCallScreen`**:
   - Replace mockup with Jitsi join (video muted)
5. **Add `IncomingCallDialog`**:
   - Overlay/dialog shown when polling detects a `call_invite` message
   - Accept → join Jitsi room; Decline → send `call_declined` message
6. **Platform setup**:
   - Android: minSdkVersion 24, add `tools:replace="android:label"`
   - iOS: platform 15.1, add camera/microphone permission descriptions

### Flow Diagrams

#### Messaging Flow
```
Student opens chat list → GET /api/chats/ → display chats
Student taps chat → GET /api/chats/:id/messages → display messages
Student types + sends → POST /api/chats/:id/messages → show sent
Timer polls every 2s → GET /api/chats/:id/messages → append new messages
Tutor's app polls → sees new message → displays it
```

#### Video Call Flow
```
Tutor taps video call icon in chat
  → Generate room: "tutorgo_<chatId>_<ts>"
  → POST message { type: "call_invite", text: roomName }
  → Tutor joins Jitsi room (JitsiMeet.join)

Student's app polls messages → sees call_invite
  → Show IncomingCallDialog
  → Student accepts → joins same Jitsi room
  → Both connected with video/audio

Either hangs up → Jitsi fires conferenceTerminated
  → POST message { type: "call_ended" }
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `jitsi_meet_flutter_sdk` | ^12.1.3 | Video/voice calls via free Jitsi servers |

No other new dependencies needed (`http` already exists for API calls).

## Platform Requirements

| Platform | Requirement |
|----------|-------------|
| Android | minSdkVersion 24, camera/mic permissions |
| iOS | platform 15.1, NSCameraUsageDescription, NSMicrophoneUsageDescription |
| macOS | Not supported by Jitsi (demo on mobile/emulator only) |

## Acceptance Criteria

### Messaging
- [ ] Student can see list of chats fetched from backend (not dummy data)
- [ ] Student can open a chat and see message history from backend
- [ ] Student can send a text message and it appears in the other user's chat within 2 seconds
- [ ] Tutor can see and reply to messages in the same chat
- [ ] Session request can be sent through chat and appears as special UI bubble
- [ ] Unread message count updates on chat list
- [ ] Mark as read works when opening a chat
- [ ] Starting a new chat from tutor profile works

### Video/Voice Calls
- [ ] Tutor can initiate a video call from the chat conversation screen
- [ ] Student sees incoming call notification/dialog
- [ ] Both users connect with actual camera/mic streaming via Jitsi
- [ ] Voice-only call works (video muted on join)
- [ ] Ending call returns both users to the chat
- [ ] Call invite appears as a message in chat history

### General
- [ ] Works on two physical Android devices on same WiFi
- [ ] All existing tests still pass
- [ ] Integration tests added for new chat start and call invite endpoints
- [ ] `docs/knowledge_base.md` updated
- [ ] `docs/backend-api-specification.yaml` updated

## Technical Notes
- Polling interval: 2 seconds (balance between responsiveness and server load)
- Jitsi room names must be unique per call to avoid cross-talk: format `tutorgo_{chatId}_{timestamp}`
- Jitsi public server has no time limits for 1:1 calls
- For demo, both devices must have internet access (Jitsi servers are remote)
- macOS desktop won't support calls (Jitsi iOS/Android only) — test on mobile/emulator
- App binary size will increase ~30-50MB due to Jitsi native SDK
- The polling approach means messages have 0-2 second delay, which is acceptable per user requirement
