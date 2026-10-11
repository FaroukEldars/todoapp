# 📱 دليل عمل وتكامل الفريق — مشروع To-Do App (DEPI Mini Project)

أهلاً يا شباب! 👋  
الملف ده تم إعداده بواسطة **Person 1 (Core Lead & Integration)** عشان يكون مرجع شامل ومبسط لكل فرد في الفريق.  
فيه شرح واضح لفكرة المشروع، هيكل الكود، ودليل عملي بالكود خطوة بخطوة لكل شخص عشان يشتغل بدون أي تضارب أو صعوبة.

---

## 🏗️ 1. فكرة ومعمارية التطبيق (Application Architecture)

عشان نضمن البساطة والسرعة وسهولة التسليم:
1. **الـ Backend (ASP.NET Core Web API):**
   - مسؤول **فقط عن الـ Authentication** (تسجيل الدخول / إنشاء الحساب / جلب الـ Token واسم المستخدم).
   - لا يتم إرسال أو مزامنة أي تاسكات مع السيرفر.
2. **الـ Local Storage (Hive):**
   - هو المكان الوحيد المسؤول عن **حفظ وإدارة المهام (Tasks)** محلياً على جهاز المستخدم.
   - كل مستخدم بيشوف التاسكات الخاصة بيه فقط عبر الـ `userId`.
3. **الـ State Management (Provider):**
   - عندنا 3 Providers مسجلين في الـ Root (`MultiProvider` في `main.dart`):
     - `UserProvider`: لمعلومات المستخدم الحالي.
     - `TaskProvider`: لإدارة التاسكات (عرض، إضافة، تعديل، حذف).
     - `ThemeProvider`: لتبديل الثيم بين الفاتح والداكن (Light & Dark).
4. **الـ Session Persistence & Auto-Login (FlutterSecureStorage):**
   - يتم حفظ الـ `auth_token` وبيانات الحساب (`userId`, `name`, `email`) تلقائياً في التخزين الآمن عند الـ Login.
   - التطبيق يبدأ من `SplashScreen` لفحص الجلسة تلقائياً: إذا كان المستخدم مسجلاً مسبقاً، يدخل مباشرة على `MainNavigationScreen` وتُحمَّل تاسكاته دون الحاجة لإعادة كتابة الإيميل والباسورد كل مرة.

---

## 📂 2. الهيكل الصارم للمشروع (Project Structure)

كل ملف له مكانه المحدد، برجاء **عدم نقل أو تغيير أسماء الملفات**:

```text
lib/
├── main.dart                                # تهيئة التطبيق والـ Providers (Person 1)
│
├── data/
│   ├── models/
│   │   ├── task_model.dart                  # كائن المهمة (Hive Model)
│   │   └── task_model.g.dart                # كود Hive المولد تلقائياً
│   │
│   └── services/
│       ├── hive_service.dart                # خدمة التخزين المحلي
│       └── auth_service.dart                # خدمة تسجيل الدخول وإنشاء الحساب
│
├── providers/
│   ├── task_provider.dart                   # إدارة حالة التاسكات
│   ├── user_provider.dart                   # إدارة بيانات المستخدم
│   └── theme_provider.dart                  # إدارة الثيم
│
└── features/
    ├── onboarding/
    │   ├── splash_screen.dart               # شاشة البداية (Person 3)
    │   └── welcome_screen.dart              # شاشة الترحيب (Person 3)
    │
    ├── auth/
    │   ├── login_screen.dart                # شاشة تسجيل الدخول
    │   └── register_screen.dart             # شاشة إنشاء حساب جديد
    │
    ├── home/
    │   └── home_screen.dart                 # شاشة الرئيسية (Person 2)
    │
    ├── add_task/
    │   └── add_task_screen.dart             # شاشة إضافة مهمة (Person 3)
    │
    ├── todo/
    │   └── my_tasks_screen.dart             # شاشة المهام النشطة (Person 4)
    │
    ├── completed/
    │   └── completed_tasks_screen.dart      # شاشة المهام المكتملة (Person 5)
    │
    ├── profile/
    │   ├── profile_screen.dart              # شاشة الملف الشخصي (Person 6)
    │   └── user_details_screen.dart         # شاشة تفاصيل المستخدم (Person 6)
    │
    └── navigation/
        └── main_navigation_screen.dart      # شريط التنقل السفلي والدمج (Person 1)
```

---

## 👥 3. دليل المهام لكل شخص بالكود (Cheat Sheet)

### 👤 Person 2 — شاشة الرئيسية (Home UI)
* **الملف الخاص بك:** `lib/features/home/home_screen.dart`
* **المسؤوليات:**
  1. عرض التحية واسم المستخدم ومقولة اليوم.
  2. عرض كارت نسبة إنجاز المهام (Progress Overview).
  3. عرض نظرة سريعة على المهام ذات الأولوية العالية (High-Priority Tasks).
  4. زر تبديل الثيم (Dark/Light).
  5. زر الانتقال لشاشة إضافة مهمة (`AddTaskScreen`).

* **الكود اللي هتستخدمه:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../providers/user_provider.dart';
  import '../../providers/task_provider.dart';
  import '../../providers/theme_provider.dart';
  import '../add_task/add_task_screen.dart';

  // 1. قراءة اسم المستخدم ومقولة اليوم:
  final userName = context.watch<UserProvider>().name;
  final quote = context.watch<UserProvider>().quote;

  // 2. قراءة التاسكات المهمة ونسبة الإنجاز:
  final highPriorityTasks = context.watch<TaskProvider>().highPriorityTasks;
  final progress = context.watch<TaskProvider>().progressRatio; // قيمة من 0.0 إلى 1.0
  final completedCount = context.watch<TaskProvider>().completedTasksCount;
  final totalCount = context.watch<TaskProvider>().totalTasksCount;

  // 3. تبديل الثيم (Dark / Light):
  IconButton(
    icon: Icon(context.watch<ThemeProvider>().isDarkMode ? Icons.light_mode : Icons.dark_mode),
    onPressed: () => context.read<ThemeProvider>().toggleTheme(),
  );

  // 4. الانتقال لشاشة إضافة مهمة:
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => const AddTaskScreen()),
  );
  ```

---

### 👤 Person 3 — شاشات Onboarding وإضافة مهمة (Add Task)
* **الملفات الخاصة بك:**
  - `lib/features/onboarding/splash_screen.dart`
  - `lib/features/onboarding/welcome_screen.dart`
  - `lib/features/add_task/add_task_screen.dart`
* **المسؤوليات:**
  1. **تصميم الـ Splash Screen (`splash_screen.dart`):** تم بالفعل كتابة منطق الـ **Auto-Login** والتحقق من التوكين بداخلها؛ دورك التركيز على تحسين الواجهة والأنيميشن الخاص بها دون مسح دالة التحقق `_checkAuthStatus()`.
  2. تصميم الـ Welcome Screen (`welcome_screen.dart`).
  3. تصميم شاشة `AddTaskScreen` (حقل العنوان، حقل الوصف، تبديل High Priority، زر الحفظ).

* **الكود اللي هتستخدمه لإضافة مهمة:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../data/models/task_model.dart';
  import '../../providers/task_provider.dart';
  import '../../providers/user_provider.dart';

  void saveNewTask({
    required BuildContext context,
    required String title,
    required String description,
    required bool isHighPriority,
  }) async {
    // جلب معرف المستخدم الحالي:
    final userId = context.read<UserProvider>().userId?.toString() ?? '';

    // إنشاء كائن المهمة (الـ id سيتولد تلقائياً إذا تركته فارغاً):
    final newTask = TaskModel(
      id: '', 
      title: title,
      description: description,
      isHighPriority: isHighPriority,
      isCompleted: false,
      createdAt: DateTime.now(),
      userId: userId,
    );

    // الحفظ في Hive وتحديث الواجهة فوراً:
    await context.read<TaskProvider>().addTask(newTask);

    // العودة للشاشة السابقة:
    Navigator.of(context).pop();
  }
  ```

---

### 👤 Person 4 — شاشة المهام النشطة (My Tasks)
* **الملف الخاص بك:** `lib/features/todo/my_tasks_screen.dart`
* **المسؤوليات:**
  1. عرض قائمة المهام غير المكتملة فقط (`activeTasks`).
  2. إمكانية تحديد المهمة كمكتملة عبر Checkbox أو زر.
  3. إمكانية حذف المهمة (Dismissible أو زر Delete).
  4. عرض شاشة فارغة (Empty State) لو مفيش تاسكات نشطة.

* **الكود اللي هتستخدمه:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../providers/task_provider.dart';

  // 1. مراقبة المهام النشطة:
  final activeTasks = context.watch<TaskProvider>().activeTasks;

  if (activeTasks.isEmpty) {
    return const Center(child: Text('No active tasks! Enjoy your day 🎉'));
  }

  // 2. تحديد المهمة كمكتملة:
  context.read<TaskProvider>().toggleTask(task);

  // 3. حذف مهمة:
  context.read<TaskProvider>().deleteTask(task.id);
  ```

---

### 👤 Person 5 — شاشة المهام المكتملة (Completed Tasks)
* **الملف الخاص بك:** `lib/features/completed/completed_tasks_screen.dart`
* **المسؤوليات:**
  1. عرض المهام المكتملة فقط (`completedTasks`).
  2. إمكانية التراجع عن إكمال المهمة وإعادتها للنشطة (Undo / Uncheck).
  3. إمكانية حذف المهمة.
  4. عرض شاشة فارغة (Empty State) لو مفيش مهام مكتملة.

* **الكود اللي هتستخدمه:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../providers/task_provider.dart';

  // 1. مراقبة المهام المكتملة:
  final completedTasks = context.watch<TaskProvider>().completedTasks;

  if (completedTasks.isEmpty) {
    return const Center(child: Text('No completed tasks yet. Keep going! 💪'));
  }

  // 2. التراجع عن إكمال المهمة:
  context.read<TaskProvider>().toggleTask(task);

  // 3. حذف مهمة:
  context.read<TaskProvider>().deleteTask(task.id);
  ```

---

### 👤 Person 6 — شاشة الملف الشخصي وتفاصيل المستخدم (Profile)
* **الملفات الخاصة بك:**
  - `lib/features/profile/profile_screen.dart`
  - `lib/features/profile/user_details_screen.dart`
* **المسؤوليات:**
  1. عرض بيانات المستخدم (الاسم، البريد الإلكتروني، مقولة اليوم، الصورة إن وجدت).
  2. تعديل اسم المستخدم والمقولة.
  3. زر تبديل الثيم (Dark/Light).
  4. تسجيل الخروج (Logout) والعودة لشاشة الـ Login.

* **الكود اللي هتستخدمه:**
  ```dart
  import 'package:flutter/material.dart';
  import 'package:provider/provider.dart';
  import '../../providers/user_provider.dart';
  import '../../providers/task_provider.dart';
  import '../../providers/theme_provider.dart';
  import '../../data/services/auth_service.dart';
  import '../auth/login_screen.dart';

  // 1. قراءة بيانات المستخدم:
  final userProvider = context.watch<UserProvider>();
  final name = userProvider.name;
  final email = userProvider.email;
  final quote = userProvider.quote;

  // 2. تحديث الاسم أو المقولة:
  context.read<UserProvider>().updateName('الاسم الجديد');
  context.read<UserProvider>().updateQuote('المقولة الجديدة');

  // 3. تبديل الثيم:
  context.read<ThemeProvider>().toggleTheme();

  // 4. تسجيل الخروج السليم (Logout Flow):
  void logout(BuildContext context) async {
    // أ. تنظيف بيانات المستخدم الحالي من الذاكرة:
    context.read<UserProvider>().clearUser();

    // ب. تنظيف التاسكات من الذاكرة لضمان الخصوصية:
    context.read<TaskProvider>().clearTasks();

    // ج. مسح الـ JWT Token وبيانات المستخدم المحفوظة من الـ Secure Storage:
    await AuthService().logout();

    // د. العودة لشاشة تسجيل الدخول:
    if (!context.mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }
  ```

---

## 🚀 4. نصائح مهمة للتعامل مع Git وتفادي الـ Conflicts

1. **لا تعدل على ملفات زملائك:**
   - كل شخص يشتغل فقط داخل الملفات المخصصة له في مجلد الـ `features/`.
   - ملف `main.dart` وملف `main_navigation_screen.dart` خاصين بـ Person 1 فقط.
2. **استخدم Branch خاص بيك:**
   - اعمل Branch جديد لكل ميزة: `git checkout -b feature/home-ui`
   - بعد الانتهاء اعمل `git push` واعمل Pull Request.
3. **قبل ما تبدأ شغل يومياً:**
   - اعمل `git pull origin main` عشان تاخد آخر تحديثات المشروع.
4. **تأكد دائماً أن الكود يعمل:**
   - شغل الأمر: `flutter analyze lib`
   - تأكد إنه يطبع: `No issues found!`.

---

