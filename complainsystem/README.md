
# 🎓 Smart Complaint Management System (SCMS)

A role-based Flutter app to streamline complaint handling for the Computer Science (CS) department — from students to Batch Advisors and the HOD.

---

## 🎯 Objective

An efficient complaint lifecycle for CS batches (FA18–FA25):

- 📩 Students submit complaints
- 🧑‍🏫 Batch Advisors resolve or escalate
- 👨‍💼 HOD reviews and closes
- 🛠️ Admin manages users, batches, and complaints via dashboard or CSV

---

## 👥 User Roles & Features

### 🔐 Admin
- One-time signup with SMTP-based credentials
- Add Students, Advisors, HOD (Manual / CSV)
- Manage batches (FA18–FA25)
- View & track complaints
- HTML email delivery of credentials

### 🧑‍🎓 Student
- Login via ID (e.g., BCS-01) and email
- Submit complaints (with dropdowns/media via Drive link)
- Auto-assign to advisor
- Auto-escalate to HOD if 5+ same-title complaints
- Track status & comments

### 👨‍🏫 Batch Advisor
- View complaints from assigned batch
- Actions: Resolve, Comment, Escalate
- Auto-escalation after 24 hours of inaction
- View timeline & history

### 👨‍💼 HOD
- View escalated or mass-submitted complaints
- Actions: Comment, Resolve, Reject
- Priority handling for repeated complaints
- Access full complaint timeline

---

## ⚙️ Functional Overview

- 🔐 **Authentication**: Role-based login for Admin, Student, Advisor, and HOD
- 📈 **Status Flow**: Submitted → In Progress → Escalated → Resolved/Rejected
- 📤 **CSV Import**: Upload, preview, edit, confirm student records
- 🔔 **Notifications**: Real-time (Supabase) + SMTP Email
- 📁 **Media Support**: Complaint media via public Google Drive links

---

## 🛠️ Tech Stack

| Layer      | Technology                    |
|------------|-------------------------------|
| Frontend   | Flutter                       |
| Backend    | Supabase (Auth, Realtime DB)  |
| IDE        | Android Studio                |
| Email      | Gmail SMTP + HTML Templates   |
| Media      | Google Drive (public links)   |
| CSV Import | `csv` / `excel` Flutter plugin|

---

## 📧 Email Highlights

- HTML-based template for user credentials
- Sent via **smtp.gmail.com** with unsubscribe links
- Covers Admin, Advisor, HOD, and Student accounts

---

## 📸 App Screenshots

### 🧾 Login & Signup
<p align="center">
  <img src="https://github.com/user-attachments/assets/348511fe-a716-4731-90d9-651308179d38" width="250"/>
  <img src="https://github.com/user-attachments/assets/3e2e3e3d-7740-47c6-8402-38b2a5d31628" width="250"/>
</p>

---

### 🛡️ Admin Dashboard
<p align="center">
  <img src="https://github.com/user-attachments/assets/31f37548-b565-46cd-8cb4-d38382d441a5" width="250"/>
  <img src="https://github.com/user-attachments/assets/5dd1fa25-51d8-4d72-90de-27a487fb2709" width="250"/>
</p>

#### ➕ Manage Users
<p align="center">
  <img src="https://github.com/user-attachments/assets/23b311c4-eefb-4ce5-a456-2b8e85b59cbc" width="250"/>
  <img src="https://github.com/user-attachments/assets/fb30a458-cbb3-4541-9bdc-b26afa27d32a" width="250"/>
</p>

#### 🗂️ Manage Batches & Complaints
<p align="center">
  <img src="https://github.com/user-attachments/assets/8811c2ca-b208-4d0b-a158-1ae39de1e553" width="250"/>
  <img src="https://github.com/user-attachments/assets/4f7decc8-3bcf-433a-ab21-1a82ff538c4f" width="250"/>
</p>

---

### 🧑‍🎓 Student Dashboard
<p align="center">
  <img src="https://github.com/user-attachments/assets/1f78ba03-178c-4618-b92c-9fda60d9c5e0" width="250"/>
  <img src="https://github.com/user-attachments/assets/54bee88a-5c29-43dd-a121-f944437328f0" width="250"/>
  <img src="https://github.com/user-attachments/assets/75cf5436-bad5-4a3d-9f3b-90fd2776bd6c" width="250"/>
</p>

---

### 👨‍🏫 Batch Advisor Dashboard
<p align="center">
  <img src="https://github.com/user-attachments/assets/bbd18029-6e2f-41dc-bad1-7374ec82fa65" width="250"/>
  <img src="https://github.com/user-attachments/assets/2f501003-abe0-440e-80df-cd069b8e5fc8" width="250"/>
</p>

---

### 👨‍💼 HOD Dashboard
<p align="center">
  <img src="https://github.com/user-attachments/assets/d418cbac-c6a7-4507-9063-9c0781c5e31f" width="250"/>
  <img src="https://github.com/user-attachments/assets/7d45e194-4200-4c25-9a07-979cc4e0fd08" width="250"/>
  <img src="https://github.com/user-attachments/assets/a0f27feb-062d-4597-8253-f817ce146582" width="250"/>
</p>

---

## 📌 Contributing

Pull requests are welcome. For major changes, please open an issue first to discuss what you'd like to change.

---

## © 2025 Smart Complaint Management System

CS Department, Complaint Committee | All Rights Reserved




 


     

    

















