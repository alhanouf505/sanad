# سند الساركوما — منصّة توعوية + مكتبة أبحاث (Full-Stack)

منصّة عربية عن سرطان الساركوما، تحوّلت من موقع ثابت (HTML) إلى **تطبيق كامل**:
واجهة + باك-إند **Go (نمط MVC)** + قاعدة بيانات **SQL** + لوحة تحكم أدمن.

```
sanad/
├── frontend/
│   ├── index.html          الواجهة الثابتة (HTML) — تسحب البيانات من الـ API
│   ├── react.html          نسخة React كاملة (مكوّنات + Hooks) — نفس الـ API
│   └── admin.html          لوحة تحكم الأدمن — تسجيل دخول + إدارة المحتوى
├── mobile/                 تطبيق Flutter للموبايل — نفس الـ API (models/services/screens)
└── backend/
    ├── main.go             نقطة التشغيل + تركيب الطبقات + خدمة الواجهة
    ├── seed.json           بيانات البداية (12 بحث + 14 نوع + 3 قصص)
    ├── sanad.db            قاعدة بيانات SQLite (تُنشأ تلقائيًا)
    └── internal/
        ├── config/         الإعدادات
        ├── models/         نماذج الجداول (Model)
        ├── database/       الاتصال + AutoMigrate + Seed
        ├── repository/     الوصول للبيانات (GORM)     ← Repository
        ├── service/        منطق العمل والتحقق          ← Service
        ├── controller/     معالجات HTTP + المصادقة     ← Controller
        ├── middleware/     CORS + سجل الطلبات
        └── routes/         تسجيل المسارات
```

## التشغيل

```powershell
cd C:\Users\AmjadQ\sanad\backend
go run .
```
ثم افتح: **http://localhost:8080**

> قاعدة البيانات تُنشأ وتُملأ تلقائيًا أول مرة من `seed.json`.

**لوحة تحكم الأدمن:** افتح **http://localhost:8080/admin.html** وسجّل الدخول بحساب الأدمن.
منها تعتمد/ترفض القصص، وتضيف/تحذف الأبحاث، وتشاهد الاقتراحات والمشتركين — كلها عبر الـ API نفسه.

## نقاط الـ API

| الطريقة | المسار | الوصف | يحتاج توكن |
|---------|--------|-------|:----------:|
| GET | `/api/papers?region=&topic=&type=&sort=&q=` | مكتبة الأبحاث (بحث + فلترة) | ✗ |
| GET | `/api/types` | أنواع الساركوما (مجمّعة) | ✗ |
| GET | `/api/stories` | القصص المعتمدة | ✗ |
| POST | `/api/stories` | إرسال قصة (تدخل قيد المراجعة) | ✗ |
| POST | `/api/subscribe` | الاشتراك بالبريد | ✗ |
| POST | `/api/papers/suggest` | اقتراح بحث | ✗ |
| POST | `/api/admin/login` | دخول الأدمن → توكن | ✗ |
| GET | `/api/admin/stories/pending` | القصص المنتظرة | ✓ |
| POST | `/api/admin/stories/{id}/approve` | اعتماد قصة | ✓ |
| POST | `/api/admin/papers` | إضافة بحث | ✓ |
| DELETE | `/api/admin/papers/{id}` | حذف بحث | ✓ |
| GET | `/api/admin/suggestions` | الاقتراحات المستلمة | ✓ |
| GET | `/api/admin/subscribers` | قائمة المشتركين | ✓ |

## دخول الأدمن (افتراضي)
- البريد: `admin@sanad.sa`
- كلمة المرور: `admin12345`  ← غيّرها عبر متغيّر البيئة `ADMIN_PASSWORD`

## قاعدة البيانات (العلاقات والفهرسة)
الجداول: `papers`, `sarcoma_types`, `stories`, `subscribers`, `suggestions`, `admins`.
فهارس (indexes) على: `region`, `topic`, `type`, `year`, `status`, والبريد (فريد).

## التحويل إلى PostgreSQL لاحقًا
سطر واحد في `internal/database/database.go`:
```go
// import gorm.io/driver/postgres
gorm.Open(postgres.Open(dsn), &gorm.Config{})
```

## الخطوات القادمة (اختياري)
- ✅ ~~صفحة لوحة تحكم للأدمن (HTML) بدل الـ API المباشر.~~ (تمّت — `frontend/admin.html`)
- ✅ ~~نسخة **React** للواجهة.~~ (تمّت — `frontend/react.html` على `/react.html`)
- ✅ ~~تطبيق **Flutter** يتصل بنفس الـ API.~~ (تمّت — مجلّد `mobile/`)
