# SECURITY_POLICY.md

## سياسة الأمان لمشروع ile-key-v3

**الهدف:** حماية الكود والبيانات والهوية الرقمية لمنصة Nile Key أثناء التطوير والنشر.

---

## 1. المبادئ الأساسية

```text
Least privilege
No secrets in Git
Encrypted backups
Audit sensitive actions
Server-side validation
Secure defaults
Staging before production
```

---

## 2. الأسرار والمفاتيح

يمنع تخزين الآتي داخل Git:

```text
.env
site_config.json الحقيقي
كلمات مرور
API keys
SMTP credentials
Payment credentials
Supabase service keys
Private SSH keys
Database dumps غير مشفرة
```

استخدم:

```text
environment variables
secrets manager
encrypted local files
CI/CD secrets
```

---

## 3. كلمات المرور

يجب أن تكون كلمات المرور:

```text
طويلة
فريدة
غير مستخدمة في أي مكان آخر
مخزنة في password manager
```

لا تشارك كلمات المرور عبر chat أو email غير مشفر.

---

## 4. صلاحيات المستخدمين

يجب تطبيق الصلاحيات على مستوى:

```text
DocType
Role
Workflow
API
Server script
File access
```

لا تعتمد على إخفاء الأزرار فقط في الواجهة.

---

## 5. Audit logging

يجب تسجيل العمليات الحساسة مثل:

```text
تغيير الصلاحيات
تصدير بيانات
رفع مستندات
تعديل shipment status
إنشاء تكامل خارجي
فشل webhook
تغيير كلمة مرور
تعطيل مستخدم
```

---

## 6. Backups

يجب أن تكون backups:

```text
مشفرة
خارجية
قابلة للاستعادة
مختبرة دورياً
محمية من الوصول العام
```

---

## 7. APIs

كل API يجب أن:

```text
يتحقق من الصلاحية
يصادق المدخلات
يسجل العملية الحساسة
لا يرجع بيانات زائدة
يتعامل مع الأخطاء بشكل آمن
```

---

## 8. Frontend

في Next.js أو أي واجهة عامة:

```text
لا تضع service role keys في المتصفح
لا تضع كلمات مرور
استخدم API routes للخلفية
فعّل validation
استخدم HTTPS
```

---

## 9. Production

قبل الإنتاج يجب توفر:

```text
HTTPS
monitoring
centralized logs
automated backups
restore test
rate limiting
admin MFA إن أمكن
security audit أساسي
```

---

## 10. الاستجابة للحوادث

عند الاشتباه في تسرب سر:

```text
1. عطل السر فوراً
2. بدّل كلمة المرور أو key
3. راجع logs
4. وثق الحادث
5. حدّث security policy إذا لزم
```

---

## 11. مراجع

- [MASTER_ROADMAP.md](MASTER_ROADMAP.md)
- [BACKUP_RESTORE_PLAN.md](BACKUP_RESTORE_PLAN.md)
- [RECOVERY_RUNBOOK.md](RECOVERY_RUNBOOK.md)
