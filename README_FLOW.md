````markdown
# Gym Management SaaS

## Overview

Gym Management SaaS is a multi-tenant cloud-based platform designed for:

- Gyms
- Fitness clubs
- Yoga studios
- Personal trainers

The platform automates gym operations including:

- Member management
- Attendance tracking
- Membership handling
- Workout & diet management
- Payment processing
- Notifications
- Analytics & reporting

The system includes:

1. One Unified Mobile App
2. One Unified Web Dashboard

All modules and screens are permissioned by role (RBAC). No separate role-specific applications.

---

# Tech Stack

## Frontend
- Flutter (Single Mobile Application)
- React / Next.js (Single Web Dashboard)

## Backend
- Node.js
- Express.js / NestJS

## Database
- MongoDB / PostgreSQL

## Authentication
- JWT Authentication
- Email OTP Verification

## Payment Gateway
- Razorpay

## Notifications
- Firebase Push Notifications
- Email Notifications
- WhatsApp / SMS Integration

---

# Multi-Tenant Architecture

Each gym operates independently within the same SaaS platform.

Every primary table/collection contains:

```text
gym_id
````

## Benefits

* Data isolation
* Independent subscriptions
* Secure access control
* Better scalability

---

# User Roles

## 1. Super Admin

* Manage gyms
* Manage subscriptions
* SaaS analytics
* Suspend gyms
* Revenue tracking

## 2. Gym Owner

* Manage members
* Manage trainers
* Manage plans
* View reports
* Handle payments

## 3. Trainer

* Assign workouts
* Create diet plans
* Track member progress
* Manage sessions

## 4. Member

* View workouts
* View diet plans
* Track attendance
* View membership details

## 5. Receptionist

* Member check-ins
* Attendance support
* Payment support
* Member assistance

---

# Authentication Flow

## Registration Flow

```text
Gym Owner Creates User (Member/Trainer)
→ Invitation Sent (Email/Phone)
→ User Sets Password (First Login Setup)
→ User Completes Profile Details
→ Login Success
```

### Features

* Self-registration is disabled for Member and Trainer
* Only Gym Owner can create Member and Trainer users from frontend admin panel
* Role is fixed at creation and cannot be switched by Member/Trainer
* First-login password setup required
* Profile completion required after password setup
* Secure password hashing

## Role Lock Rules

* All users use the same application surfaces; access is role-driven
* Member and Trainer cannot change their role after account creation
* Role updates are restricted to authorized owner/admin flows only

---

## Login Flow

```text
Login
→ Validate Credentials
→ Generate JWT Token
→ Access Dashboard
```

### Supported Methods

* Email & Password
* Invitation-based first login setup

---

## Forgot Password Flow

```text
Forgot Password
→ Send OTP to Email
→ Verify OTP
→ Reset Password
→ Login Again
```

### Security Features

* OTP expiration validation
* Rate limiting
* Encrypted passwords
* JWT-based authentication

---

# Payment Flow

## Important Business Rule

Users can purchase membership/subscription plans only on the Web Platform.

Mobile applications will:

* Show active subscriptions
* Show membership details
* Show expiry information

Mobile applications will NOT support:

* Buying plans
* Subscription checkout
* Direct payments

---

## Payment Workflow

```text
Plan Selection (Web)
→ Razorpay Payment
→ Payment Verification
→ Membership Activation
→ Invoice Generation
→ Notification Sent
```

### Features

* Razorpay integration
* Invoice generation
* Payment history
* Membership renewals

---

# Core Modules

## Dashboard Module

* Revenue analytics
* Attendance reports
* Membership growth
* Expired plans
* Renewals tracking

---

## Member Management

* Add/Edit/Delete members
* Freeze memberships
* Renew plans
* Upload member image
* Generate QR codes

---

## Attendance Module

### Supported Methods

* QR Code
* RFID
* Manual Check-in

### Attendance Workflow

```text
Member Check-In
→ Membership Validation
→ Mark Attendance
→ Save Timestamp
→ Update Analytics
```

---

## Membership Plans

* Monthly
* Quarterly
* Annual
* Personal Training

---

## Trainer Module

* Workout assignments
* Diet management
* Member progress tracking
* Class scheduling

---

## Workout Module

* Exercise management
* Sets & reps
* Duration tracking
* Weekly progress analytics

---

## Diet Module

* Meal planning
* Calories tracking
* Protein tracking
* Water intake monitoring

---

## Notification Module

### Notification Types

* Push Notifications
* Email
* WhatsApp
* SMS

### Use Cases

* Membership expiry reminders
* Payment reminders
* Workout reminders
* Gym announcements

---

# API Structure

## Authentication APIs

```http
POST /owners/users/create
POST /auth/invitation/verify
POST /auth/set-password
POST /auth/complete-profile
POST /auth/login
POST /auth/forgot-password
POST /auth/verify-forgot-otp
POST /auth/reset-password
```

---

## Member APIs

```http
GET /members
POST /members
PUT /members/:id
DELETE /members/:id
```

---

## Attendance APIs

```http
POST /attendance/checkin
GET /attendance
```

---

## Payment APIs

```http
POST /payments/create
POST /payments/verify
GET /payments/history
```

---

# Database Collections / Tables

```text
gyms
users
members
trainers
memberships
payments
attendance
workouts
diet_plans
subscriptions
notifications
```

---

# Security Requirements

* JWT Authentication
* HTTPS
* Password Hashing
* Role-Based Access Control
* Row-Level Security
* Rate Limiting
* OTP Expiration Validation

---

# Responsive Design

## Mobile

* Bottom navigation
* Floating action buttons

## Tablet

* Side navigation

## Desktop

* Sidebar + Topbar
* Multi-column dashboards

---

# Environment Variables

```env
PORT=

DATABASE_URL=

JWT_SECRET=
JWT_EXPIRE=

EMAIL_SERVICE=
EMAIL_USER=
EMAIL_PASSWORD=

RAZORPAY_KEY_ID=
RAZORPAY_KEY_SECRET=

FIREBASE_SERVER_KEY=
```

---

# Future Enhancements

* AI Trainer
* Smartwatch Integration
* Face Recognition Attendance
* Community Features
* Leaderboards
* Ecommerce Store

---

# Project Goals

* Simplify gym operations
* Improve member engagement
* Automate attendance & payments
* Provide scalable SaaS architecture
* Deliver modern fitness management tools

```
```
