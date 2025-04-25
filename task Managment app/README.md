Project Scope: Todo App
**Project Overview**
The Todo App is a Flutter-based mobile application designed to help users manage tasks efficiently through a clean, intuitive interface inspired by a Figma design. It allows users to organize tasks into categories (e.g., “Personal,” “Work”), set due dates, mark tasks as complete, and receive local notifications for upcoming tasks. The app uses a SQLite database (sqflite) for persistent storage and supports Android devices, with a focus on delivering a modern, visually appealing user experience.
**Objectives**
Task Management:
              Enable users to create, edit, delete, and complete tasks within categories. Support task attributes like title, description, due date, repetition (daily, weekly, monthly), and completion status.
Category Organization:
              Allow users to create and manage categories to group tasks (e.g., “Personal,” “Work”). Display categories on the home page with customizable icons and colors.
Notifications:
              Provide local notifications for tasks due today or in the future, with support for one-time and repeating tasks. Allow 
 notifications to navigate to the relevant category’s task list when tapped.
User-Friendly Interface:
              Implement a modern UI based on a Figma design, with gradient backgrounds (blue, green, white) and consistent typography.
Ensure responsiveness across different Android screen sizes.
Data Persistence:
             Store tasks and categories in a SQLite database for offline access. Initialize a default “Personal” category with a sample task for new users.
Performance and Reliability:
             Optimize for smooth performance, avoiding issues like infinite loops or frame skips. Handle errors gracefully (e.g., database failures, invalid inputs).

**Functionality**
Based on our conversations and the provided code (main.dart, task_provider.dart, add_category_screen.dart, etc.), the app’s core functionality includes:

**Home Page (main.dart):**
Displays a list of categories via the Tasks widget.
Features an AppBar with a user avatar and greeting (“Hi, User!”), a GoPremium widget (placeholder for premium features), and a “Tasks” title.
Includes a BottomNavigationBar with “Home” and “Person” tabs (Person tab is a placeholder).
Provides a FloatingActionButton to navigate to AddCategoryScreen.
Uses a gradient background (blue, green, white) and updated color scheme (Colors.blue.shade700, Colors.blue.shade900).

**Category Management (add_category_screen.dart, task_provider.dart):**
Users can add categories with a title, icon (from a predefined list), and colors (default: blue background, white icon).
Categories are stored as Task objects in the database, with an empty desc list for tasks.
A default “Personal” category is created on first launch with a sample task for testing notifications.

**Task Management (task_list_screen.dart, category_tasks.dart):**
Users can view tasks in a category, filtered by “Today’s Tasks” (due today, including repeating tasks) and “Future Tasks” (due later, including repeating tasks).
Tasks can be added, edited, deleted, or marked as complete via AddTaskScreen and EditTaskScreen (assumed implemented).

**Tasks include:**
Title, description, due date, completion status, repetition (none, daily, weekly, monthly), and creation timestamp.
Repeating tasks support weekly days (e.g., Monday, Wednesday) or monthly dates (e.g., 15th).
Non-repeated tasks due today appear only in “Today’s Tasks”; future non-repeated tasks appear in “Future Tasks” until their due date.
**Notifications (notification_service.dart, task_provider.dart):**
Local notifications are scheduled for tasks due today or in the future using flutter_local_notifications.
Notifications include task title, description, and a payload to navigate to the category’s task list.
Supports one-time and repeating tasks (daily, weekly, monthly).
Notifications are canceled when tasks are completed or deleted.
A sample task in the “Personal” category triggers a notification 2 minutes after app launch for testing.

**Database (database_service.dart):**
Uses sqflite to store categories and tasks in a tasks table.
Each category is a Task object with fields: id, iconData, title, bgColor, iconColor, btnColor, dueDate, desc (JSON-encoded list of task details).
Supports CRUD operations: insert, update, delete, and query tasks.

**State Management (task_provider.dart):**
Uses provider for state management, with TaskProvider handling task and category data.
Loads tasks from the database on app start, initializes a default category if none exist, and schedules notifications.
Prevents infinite loops with a _hasLoaded flag.
Filters tasks for “Today’s Tasks” and “Future Tasks” based on due dates and repetition.

**UI Design:**
Home page: Gradient background (blue, green, white), dark blue AppBar, gradient FloatingActionButton.
Add Category Screen: Gradient background, modern form with icon picker, gradient button with scale animation.
Consistent typography (textTheme.titleLarge with Colors.blue.shade900) and rounded card designs (cardTheme).


For Video OPen the Below LINK :https://drive.google.com/drive/folders/1rd69MhA_8puOFG_TqE9XXt72maa47Psn?usp=sharing

![WhatsApp Image 2025-04-21 at 22 55 13_71bf6c4d](https://github.com/user-attachments/assets/40f86aa1-c7b8-4215-971d-b40069b3d5dc)
![WhatsApp Image 2025-04-21 at 22 55 10_085049e4](https://github.com/user-attachments/assets/c4dcc2ad-a03e-422c-87a2-5845c7350eb2)
![WhatsApp Image 2025-04-21 at 22 55 10_e791ffa6](https://github.com/user-attachments/assets/fc2e4796-dcb8-49eb-8b64-4775f6638e97)
![WhatsApp Image 2025-04-21 at 22 55 11_06517820](https://github.com/user-attachments/assets/9271efef-57e3-4e91-be03-26378ec8af91)
![WhatsApp Image 2025-04-21 at 22 55 12_9ffd58a2](https://github.com/user-attachment![WhatsApp Image 2025-04-21 at![WhatsApp Image 2025-04-21 at 22 55 13_b7db86f2](https://github.com/user-attachments/assets/807d748f-893c-49e3-8519-5859ba734920)
 22 55 12_7444eb58](https://github.com/user-attachments/assets/eec10c06-77a2-461c-a492-870f1d4055ba)
s/assets/27591cd1-4eab-4bd9-9d5e-9d10fbb089dd)
