# MASTER_ROADMAP.md

## وثيقة المشروع الاستراتيجية والتقنية

**اسم المشروع:** `ile-key-v3`  
**النطاق الحالي:** Frappe / ERPNext  
**الإصدار الحالي المكتشف:** ERPNext `11.1.49`  
**المستودع الرسمي:** `https://github.com/hawadettt2/nile-key-v3.git`  
**الغاية النهائية:** بناء بوابة رقمية احترافية لإدارة وتطوير صادرات شركة مصرية ذات مسؤولية محدودة متخصصة في دعم الصادرات الوطنية عالية الجودة، مع جاهزية للتكامل الرقمي المؤسسي مع الجهات الحكومية واللوجستية والتجارية.

---

## 1. ملخص تنفيذي

مشروع `ile-key-v3` بدأ كنسخة قديمة من ERPNext/Frappe، لكنه موجه استراتيجياً لأن يتحول من مجرد نسخة ERPNext إلى **منصة وطنية رقمية لإدارة الصادرات**. المنصة المستهدفة ليست مجرد نظام داخلي، بل بوابة رقمية متكاملة تربط بين:

- إدارة الشركة والمالكين والمديرين.
- الموردين ومحطات التعبئة والمزارع والمصانع.
- العملاء والمستوردين ووكلاء التصدير.
- الشحنات والمستندات الجمركية واللوجستية.
- متطلبات التصدير والامتثال والجودة.
- التكامل المستقبلي مع الجهات الرسمية والمنصات الرقمية.
- التقارير التنفيذية ولوحات التحكم الوطنية.

أكبر خطر تقني حالي هو أن بيئة التطوير تعمل على جهاز Windows 11 محمي بـ **Deep Freeze**، ما يعني أن أي إعدادات محلية أو قواعد بيانات أو ملفات غير محفوظة ستفقد عند إعادة التشغيل أو انقطاع الكهرباء. لذلك يجب اعتبار البيئة المحلية بيئة مؤقتة فقط، وأن يكون المصدر الحقيقي للاستمرارية هو:

1. مستودع GitHub.
2. نسخ احتياطية خارجية لقواعد البيانات.
3. نسخ احتياطية للملفات الخاصة والعامة.
4. وثائق تشغيل واستعادة داخل المستودع.
5. سكريبتات إعادة بناء البيئة.
6. CI/CD واختبارات آلية.

---

## 2. الوضع الحالي للمشروع

### 2.1 حالة المستودع

تم التحقق من أن المستودع يحتوي على remote رسمي:

```text
origin  https://github.com/hawadettt2/nile-key-v3.git
```

وحالة العمل كانت نظيفة عند إعداد هذه الوثيقة:

```text
git status --short
# لا توجد تغييرات غير محفوظة عند إنشاء الوثيقة
```

### 2.2 طبيعة الكود الحالي

المجلد الحالي هو تطبيق ERPNext/Frappe وليس Bench كاملاً. البنية المتوقعة لتشغيل Frappe محلياً هي:

```text
frappe-bench/
  apps/
    frappe/
    erpnext/
    nile_export/
  sites/
    site_config.json
    nile-key.test/
  env/
  config/
  logs/
```

أما المشروع الحالي فيحتوي أساساً على:

```text
erpnext/
setup.py
requirements.txt
README.md
```

لذلك لا يجب تشغيله مباشرة كأمر `npm` أو `python manage.py`. التشغيل الصحيح يتطلب Bench و Frappe Framework وقاعدة بيانات MariaDB و Redis.

### 2.3 إصدار ERPNext الحالي

تم اكتشاف الإصدار من:

```text
erpnext/__init__.py
```

```python
__version__ = '11.1.49'
```

هذا إصدار قديم جداً مقارنة بإصدارات Frappe/ERPNext الحديثة، ويجب عدم اعتباره أساس إنتاجي طويل المدى دون خطة تحديث أو إعادة بناء.

### 2.4 بيئة Windows و Deep Freeze

المachine يعمل بنظام Windows 11 ومعطّل الاستقرار المحلي بواسطة Deep Freeze. هذا يفرض الآتي:

- لا تعتمد على MariaDB/Redis/Bench مثبتة محلياً كمصدر وحيد.
- لا تعتمد على uncommitted code.
- لا تخزن بيانات مهمة داخل `C:` أو مجلدات ستُمسح.
- لا تضع كلمات مرور أو مفاتيح سرية داخل المستودع.
- اجعل كل شيء قابلاً لإعادة البناء من المستودع + backup خارجي.

### 2.5 حالة MariaDB و Redis المحلية الحالية

تم تثبيت MariaDB Server محلياً على Windows عبر winget، وتم تشغيله يدوياً على منفذ اختباري:

```text
Host: 127.0.0.1
Port: 3307
User: nile-key
```

تم إنشاء مستخدم اختباري:

```text
nile-key@localhost
```

مع صلاحيات كاملة لأغراض التطوير المحلي.

كما تم تثبيت Redis on Windows وتشغيله على:

```text
Port: 6379
```

تحذير مهم: هذه البيئة المحلية تعتبر **قابلة للفقدان** بسبب Deep Freeze، ولا يجب اعتبارها بديلاً عن WSL/Linux أو Docker أو بيئة سحابية مستقرة.

---

## 3. سياسة الاستمرارية وحماية التقدم

### 3.1 القاعدة الذهبية

> أي عمل لا يوجد في GitHub أو backup خارجي موثوق يعتبر غير موجود.

بسبب Deep Freeze، يجب التعامل مع الجهاز المحلي كأنه بيئة مؤقتة فقط.

### 3.2 هل نعتمد على Git فقط؟

Git ضروري، لكنه غير كافٍ وحده.

في مشاريع Frappe/ERPNext، حالة المشروع تتكون من أربعة أجزاء:

1. **الكود**  
   يتم حفظه في Git.

2. **قاعدة البيانات**  
   تحتوي على DocTypes، Users، Roles، Permissions، Settings، بيانات العمل.

3. **الملفات**  
   مثل المرفقات، الصور، ملفات التصدير، المستندات، private files، public files.

4. **إعدادات البيئة**  
   مثل MariaDB، Redis، Bench، Python، Node، environment variables.

Git يحفظ الكود والوثائق فقط. لذلك نحتاج workflow مركب.

---

## 4. resilient Development Workflow المقترح

### 4.1 المستوى الأول: Git-based workflow إلزامي

نعم، يجب الانتقال فوراً إلى Git workflow قوي، لكن ليس Git وحده.

#### قواعد Git اليومية

- اعمل على branches قصيرة وواضحة.
- لا تعمل طويلاً على `main`.
- ادفع إلى GitHub بعد كل تغيير ذي قيمة.
- لا تنتظر نهاية اليوم.
- استخدم commits صغيرة وقابلة للفهم.
- لا تضع كلمات مرور أو مفاتيح في commits.
- لا تضع `.env.local` أو `site_config.json` الحقيقي في Git.

#### نموذج branches مقترح

```text
main              -> نسخة مستقرة ومحمية
develop           -> فرع التطوير الرئيسي
feature/*         -> ميزات جديدة
fix/*             -> إصلاحات
spike/*           -> تجارب تقنية
release/*         -> تجهيز إصدار
hotfix/*          -> إصلاحات عاجلة
```

#### أمثلة commits

```text
feat: add export shipment doctype skeleton
fix: correct shipment status workflow transition
docs: add recovery runbook for Deep Freeze environment
chore: add bench recovery script
```

### 4.2 المستوى الثاني: database backups

بعد أي تغيير مهم في DocTypes أو Permissions أو Workflows أو Site Settings، نفّذ backup فوري.

داخل bench:

```bash
bench --site <site-name> backup --with-files
```

ثم انقل النسخة الاحتياطية إلى مكان غير متأثر بـ Deep Freeze، مثل:

- GitHub Releases خاص.
- S3/MinIO.
- Google Drive/OneDrive مشفر.
- قرص خارجي غير متأثر بـ Deep Freeze.
- خادم تطوير بعيد.

لا ترفع قاعدة بيانات_production_ إلى GitHub بشكل علني. إذا احتجت رفع backup للتطوير، فليكن:

- في private repository.
- أو encrypted archive.
- أو anonymized seed data فقط.

### 4.3 المستوى الثالث: fixtures للملفات القابلة للكود

بدلاً من الاعتماد على قاعدة بيانات محلية فقط، استخدم Frappe fixtures للمكونات التي يجب أن تعيش داخل Git:

- DocTypes مخصصة.
- Custom Fields.
- Property Setters.
- Role Permissions.
- Workflows.
- Print Formats.
- Web Forms.
- translations.
- default settings.

مثال في custom app:

```python
fixtures = [
    "Custom Field",
    "Property Setter",
    "Role",
    "Workflow",
    "Print Format",
]
```

ثم:

```bash
bench --site <site-name> export-fixtures
```

### 4.4 المستوى الرابع: scripts لإعادة بناء البيئة

يجب إضافة مجلد:

```text
scripts/
```

ويحتوي على:

```text
scripts/bootstrap-wsl.sh
scripts/check-windows-env.ps1
scripts/check-env.sh
scripts/install-mariadb-redis.sh
scripts/init-bench.sh
scripts/restore-site.sh
scripts/backup-site.sh
scripts/verify-backup.sh
scripts/run-dev.sh
scripts/sanity-check.sh
```

هذه السكريبتات تجعل الاستعادة بعد مسح الجهاز عملية فنية وليست اعتماداً على الذاكرة.

### 4.5 المستوى الخامس: بيئة غير محلية إن أمكن

الأفضل استراتيجياً هو عدم جعل Windows/Deep Freeze هو بيئة التطوير الأساسية.

الخيارات مرتبة حسب الأفضلية:

1. **Cloud Dev Server**  
   Ubuntu VPS أو GitHub Codespaces أو Remote Container.

2. **Docker Compose / frappe_docker**  
   بيئة قابلة للتكرار وسهلة النقل.

3. **WSL2 على drive غير متأثر بـ Deep Freeze**  
   إن أمكن استثناء مجلد WSL أو القرص من التجميد.

4. **VM خارجية**  
   VirtualBox/VMware على قرص غير متأثر بـ Deep Freeze.

5. **Windows local فقط**  
   أقل خيار أماناً، ويجب استخدامه فقط مع Git + backups متكررة.

---

## 5. بروتوكول الاستعادة بعد فقدان البيئة المحلية

إذا تم مسح الجهاز أو فقدت WSL/MariaDB/Bench، اتبع الآتي:

### 5.1 استعادة الكود

```bash
git clone https://github.com/hawadettt2/nile-key-v3.git
cd nile-key-v3
```

### 5.2 تجهيز Linux

الأفضل:

```bash
Ubuntu 22.04 أو 24.04
Python مناسب لإصدار Frappe المستهدف
Node.js مناسب لإصدار Frappe المستهدف
MariaDB
Redis
Bench
```

### 5.3 استعادة bench

```bash
mkdir -p ~/frappe
cd ~/frappe

bench init \
  --frappe-branch version-11 \
  nile-key-bench

cd nile-key-bench
```

### 5.4 استعادة تطبيق ERPNext المحلي

```bash
rsync -a --delete --exclude='.git' /path/to/nile-key-v3/ apps/erpnext/
bench setup requirements
bench build
```

### 5.5 استعادة قاعدة البيانات

```bash
bench --site <site-name> --force restore /path/to/database.sql.gz \
  --with-public-files /path/to/public-files.tar \
  --with-private-files /path/to/private-files.tar
```

ثم:

```bash
bench --site <site-name> migrate
bench --site <site-name> build
bench --site <site-name> clear-cache
bench start
```

---

## 6. الرؤية المعمارية المستقبلية

### 6.1 الهدف الاستراتيجي

تحويل المشروع من نسخة ERPNext قديمة إلى **Digital Export Gateway** لشركة مصرية LLC متخصصة في دعم الصادرات الوطنية.

المنصة يجب أن تكون:

- موثوقة.
- قابلة للتدقيق.
- آمنة.
- قابلة للتكامل مع الجهات الرسمية.
- قابلة للتوسع.
- قابلة للتشغيل كمنصة مؤسسية.
- مصممة حسب هوية وطنية احترافية.

### 6.2 المبدأ المعماري

لا تعدّل ERPNext core مباشرة في النظام النهائي.

البنية المستهدفة:

```text
ERPNext/Frappe Core
  -> المحاسبة، المخزون، المشتريات، المبيعات، CRM، HR إن لزم

Custom App: nile_export
  -> إدارة التصدير، الشحنات، المستندات، الامتثال، RFQ، الموردين، العملاء

Public Portal: Next.js
  -> واجهة عامة، بوابة موردين/عملاء، landing page، خدمات رقمية

Integration Layer
  -> APIs، webhooks، message queue، سجل تدقيق، تكاملات خارجية

Data Platform
  -> تقارير، مؤشرات أداء، لوحات تنفيذية، أرشيف مستندات
```

### 6.3 لماذا custom app؟

لأن تعديل ERPNext مباشرة يسبب:

- صعوبة الترقية.
- تعارضات عند تحديث Frappe.
- فقدان التعديلات.
- صعوبة التدقيق.
- ضعف الفصل بين core و business logic.

لذلك يجب نقل أي تخصيص إلى app منفصل باسم مقترح:

```text
nile_export
```

---

## 7. خارطة الطريق الاستراتيجية

### المرحلة 0: تثبيت الاستمرارية والحوكمة

**الهدف:** منع فقدان العمل وضمان استعادة فورية.

#### المخرجات

- مستودع GitHub منظم.
- فروع واضحة.
- `MASTER_ROADMAP.md`.
- `RECOVERY_RUNBOOK.md`.
- `ARCHITECTURE_DECISIONS.md`.
- `.gitignore` محكم.
- سياسة عدم تخزين الأسرار.
- backup schedule.
- environment bootstrap scripts.

#### الأولوية

عالية جداً.

#### معايير القبول

- يمكن استعادة الكود من GitHub.
- يمكن إعادة بناء bench من الوثائق.
- يمكن استعادة site من backup.
- لا توجد أسرار داخل Git.
- كل تغيير مهم له commit و push.

---

### المرحلة 1: تثبيت البنية الأساسية الحديثة

**الهدف:** نقل التطوير من Windows المحلي غير المستقر إلى بيئة Linux قابلة للتكرار.

#### الخيارات التقنية

```text
Ubuntu 22.04/24.04
Frappe Bench
MariaDB
Redis
Node.js
Python
wkhtmltopdf
Nginx
Supervisor/systemd
```

#### المخرجات

- bench محلي أو Docker-based.
- site اختباري.
- backups آلية.
- scripts تشغيل واستعادة.

#### معايير القبول

- `bench start` يعمل.
- site جديد يتم إنشاؤه.
- backup/restore مجرب.
- Redis يعمل.
- MariaDB يعمل.
- الأصول الأمامية تُبنى دون أخطاء.

---

### المرحلة 2: فصل التخصيصات عن ERPNext core

**الهدف:** إيقاف التعديل المباشر على ERPNext.

#### الإجراءات

- مراجعة `erpnext/hooks.py`.
- استخراج hooks المخصصة.
- استخراج web pages.
- استخراج print formats.
- استخراج reports.
- استخراج DocTypes/Custom Fields.
- نقلها إلى app مخصص.

#### المخرجات

```text
apps/nile_export/
  hooks.py
  nile_export/
  fixtures/
  public/
  templates/
```

#### معايير القبول

- لا توجد تعديلات جوهرية مباشرة على ERPNext core.
- custom app قابل للتثبيت على site جديد.
- fixtures قابلة للتصدير والاستيراد.

---

### المرحلة 3: تحديث Frappe/ERPNext

**الهدف:** الخروج من ERPNext v11 إلى إصدار مستقر مدعوم.

#### الخيار الموصى به

بناء بيئة Frappe/ERPNext v16 جديدة ونقل البيانات والتخصيصات إليها.

#### بديل أقل مخاطرة

الترقية المتدرجة:

```text
v11 -> v12 -> v13 -> v14 -> v15 -> v16
```

لكن هذا يتطلب staging clone واختبارات مكثفة.

#### المخرجات

- site حديث.
- custom app متوافق.
- migrations مجربة.
- assets مبنية.
- permissions معاد ضبطها.

#### معايير القبول

- لا أخطاء migration حرجة.
- login يعمل.
- desk يعمل.
- custom DocTypes تعمل.
- reports الأساسية تعمل.
- backups تعمل.

---

### المرحلة 4: تصميم نموذج بيانات التصدير

**الهدف:** بناء قلب النظام كمنصة تصدير وليس مجرد ERP.

#### DocTypes مقترحة

```text
Export Shipment
Shipment Document
ACID Record
Customs Declaration
Supplier Station
Packing Station
Importer
RFQ
Export Quotation
Quality Inspection
Compliance Check
Logistics Provider
Shipping Instruction
Certificate Request
Export Task
Shipment Timeline
Government Integration Log
Audit Evidence
```

#### الحقول الأساسية

كل DocType يجب أن يحتوي على:

- owner.
- company.
- status.
- workflow_state.
- assigned_to.
- priority.
- due_date.
- linked documents.
- attachments.
- audit trail.
- permissions واضحة.

#### معايير القبول

- يمكن إنشاء شحنة تصدير من البداية إلى النهاية.
- يمكن ربط الشحنة بالمورد والعميل والمستندات.
- يمكن تتبع الحالة.
- يمكن تصدير تقرير تنفيذي.

---

### المرحلة 5: نظام الصلاحيات والهوية

**الهدف:** بناء RBAC احترافي مناسب لشركة مؤسسية.

#### أدوار مقترحة

```text
Nile Export Owner
Nile Export Admin
Export Director
Operations Manager
Compliance Officer
Logistics Officer
Finance Officer
Supplier
Importer
Agent
Auditor
Government Integration Service
Guest
```

#### القواعد

- كل صلاحية يجب أن تكون server-side.
- لا تعتمد على إخفاء UI فقط.
- كل إجراء حساس يسجل audit log.
- المستخدم لا يرى إلا البيانات المصرح بها.
- يوجد دور مراجعة مستقل.

#### معايير القبول

- Supplier يرى بياناته فقط.
- Importer يرى طلباته وشحناته فقط.
- Auditor يقرأ ولا يعدل.
- Admin يدير المستخدمين دون كسر الصلاحيات.
- Owner لديه رؤية تنفيذية كاملة.

---

### المرحلة 6: البوابة الرقمية العامة والخاصة

**الهدف:** بناء واجهة راقية تعكس هوية الشركة ككيان تصديري وطني محترم.

#### المكونات

```text
Landing Page
Company Profile
Export Services
Supplier Onboarding
Importer Portal
RFQ Submission
Shipment Tracking
Document Upload
Compliance Status
Contact & Support
```

#### التقنيات المقترحة

```text
Next.js App Router
TypeScript strict
Tailwind CSS
Radix UI
Zod
React Hook Form
Frappe API
```

#### معايير القبول

- الصفحة الرئيسية مستقلة عن ERPNext login.
- الواجهة تدعم العربية والإنجليزية.
- التصميم متجاوب.
- النماذج مؤمنة ومصادَق عليها.
- لا توجد مفاتيح سرية في المتصفح.

---

### المرحلة 7: التكامل مع الجهات والمنصات

**الهدف:** جعل المنصة جاهزة للتكامل الرقمي مع الجهات الرسمية واللوجستية.

#### مجالات التكامل

- بيانات الشحنات.
- المستندات الجمركية.
- ACID / Nafeza-like workflows.
- شهادات المنشأ.
- الفواتير.
- بيانات الموردين.
- التتبع اللوجستي.
- إشعارات الحالة.

#### مبادئ التكامل

- API Gateway.
- Webhooks.
- Idempotency keys.
- Retry policy.
- Signed requests.
- Audit logs.
- Encryption in transit.
- Clear error taxonomy.
- Sandbox mode.

#### معايير القبول

- يوجد integration log لكل طلب.
- يمكن إعادة المحاولة بأمان.
- يمكن تتبع كل مستند مرتبط بتكامل.
- لا يوجد فقدان بيانات عند فشل التكامل.
- يوجد وضع اختبار sandbox.

---

### المرحلة 8: الأمن والامتثال والتدقيق

**الهدف:** بناء منصة جديرة بالثقة المؤسسية.

#### متطلبات أمنية

- HTTPS.
- CSRF protection.
- Rate limiting.
- Strong password policy.
- MFA للمستخدمين الإداريين.
- Audit logs غير قابلة للتعديل عملياً.
- Backups مشفرة.
- Secrets manager.
- Principle of least privilege.
- Data retention policy.
- Access review دوري.

#### أدوات مقترحة

```text
pip-audit
safety
npm audit
gitleaks
trivy
OWASP ZAP
```

#### معايير القبول

- لا أسرار في Git.
- لا صلاحيات زائدة.
- audit log يغطي العمليات الحساسة.
- backup restore مجرب.
- اختبار اختراق أساسي ناجح.

---

### المرحلة 9: الاختبارات والجودة

**الهدف:** تقليل الاعتماد على الاختبار اليدوي.

#### أنواع الاختبارات

```text
Unit tests
Server API tests
DocType permission tests
Workflow tests
UI tests
E2E tests
Backup restore tests
Integration sandbox tests
```

#### أدوات مقترحة

```text
Frappe test runner
Playwright
pytest
GitHub Actions
```

#### معايير القبول

- CI ينفذ type/build/tests.
- لا يتم دمج كود يكسر tests.
- كل feature لها اختبار أو مبرر واضح لعدم وجود اختبار.

---

### المرحلة 10: النشر والإنتاج

**الهدف:** تشغيل المنصة كخدمة مؤسسية مستقرة.

#### البيئة الإنتاجية

```text
Ubuntu LTS أو Debian stable
Frappe/ERPNext stable
MariaDB stable
Redis/Valkey
Nginx
Supervisor/systemd أو Docker Compose
Automated backups
Monitoring
Centralized logs
SSL
```

#### النشر

- staging أولاً.
- production بعد قبول المستخدم.
- blue/green أو maintenance window.
- rollback plan.
- database snapshot قبل النشر.

#### معايير القبول

- يمكن استعادة الإنتاج من backup.
- monitoring يعمل.
- logs مركزية.
- SSL يعمل.
- الأداء مقبول.
- خطة طوارئ موثقة.

---

## 8. خطة النشر التفصيلية

### 8.1 Staging

```text
الغرض: اختبار شامل قبل الإنتاج
المستخدمون: فريق داخلي فقط
البيانات: بيانات وهمية أو نسخة masked
```

### 8.2 UAT

```text
الغرض: قبول المستخدم
المستخدمون: المالك، المدير، مديرو العمليات
المخرجات: قائمة ملاحظات واعتماد رسمي
```

### 8.3 Production

```text
الغرض: تشغيل حقيقي
المستخدمون: الشركة والموردون والعملاء المصرح لهم
المخرجات: منصة تشغيلية
```

---

## 9. معايير الجودة المعمارية

### 9.1 الكود

- لا تعديل مباشر على core إلا للضرورة القصوى.
- business logic داخل custom app.
- validation على server-side.
- APIs مؤمنة.
- commits صغيرة.
- code review قبل الدمج.

### 9.2 البيانات

- backup دوري.
- restore مجرب.
- لا حذف نهائي دون صلاحية.
- سجل تدقيق للعمليات الحساسة.
- تصنيف بيانات واضح.

### 9.3 الواجهة

- RTL/LTR.
- Responsive.
- Accessibility أساسية.
- رسائل خطأ واضحة.
- لا exposed secrets.

### 9.4 التشغيل

- scripts تشغيل موحدة.
- logs واضحة.
- monitoring.
- incident runbook.
- disaster recovery plan.

---

## 10. بروتوكول التوثيق المستمر

يجب الحفاظ على الوثائق التالية داخل المستودع:

```text
MASTER_ROADMAP.md
RECOVERY_RUNBOOK.md
ARCHITECTURE_DECISIONS.md
SECURITY_POLICY.md
BACKUP_RESTORE_PLAN.md
DEVELOPMENT_SETUP.md
API_CONTRACTS.md
CHANGELOG.md
```

### 10.1 متى يتم تحديث الوثائق؟

يجب تحديث الوثائق عند:

- إضافة DocType جديد.
- تغيير workflow.
- تغيير permissions.
- إضافة integration.
- تغيير طريقة deployment.
- تغيير بنية البيانات.
- اكتشاف قرار معماري مهم.

### 10.2 قاعدة مهمة

> لا تكتمل المهمة إلا إذا تم تحديث الكود والوثائق معاً.

---

## 11. مخاطر المشروع وخطة التخفيف

| الخطر | التأثير | التخفيف |
|---|---:|---|
| Deep Freeze يمسح البيئة | فقدان كامل للبيانات المحلية | Git + backups خارجية + scripts |
| ERPNext v11 قديم | صعوبة أمنية وتقنية | خطة ترقية أو إعادة بناء على v16 |
| تعديل ERPNext core مباشرة | تعقيد الترقية | custom app |
| فقدان قاعدة البيانات | توقف العمل | backup --with-files دوري |
| أسرار داخل Git | خطر أمني كبير | .gitignore + secrets manager |
| عدم وجود tests | أخطاء غير مكتشفة | CI + unit/e2e tests |
| تكاملات حكومية بدون sandbox | فشل تشغيلي | integration log + retry + sandbox |
| صلاحيات ضعيفة | تسرب بيانات | RBAC + audit + least privilege |

---

## 12. قرارات معمارية مبدئية

### ADR-001: عدم الاعتماد على Windows local كمصدر وحيد

**الحالة:** مقبول  
**السبب:** Deep Freeze يجعل البيئة المحلية غير مستقرة.  
**القرار:** Git + backups خارجية + بيئة Linux/Docker/Cloud.

### ADR-002: عدم تعديل ERPNext core مباشرة

**الحالة:** مقبول  
**السبب:** حماية قابلية الترقية.  
**القرار:** نقل التخصيصات إلى custom app.

### ADR-003: استخدام Frappe/ERPNext حديث للنظام النهائي

**الحالة:** مقبول مبدئياً  
**السبب:** ERPNext v11 غير مناسب كمنصة طويلة المدى.  
**القرار:** التوجه إلى Frappe/ERPNext v16 أو أحدث إصدار مستقر مدعوم عند البدء الفعلي.

### ADR-004: الصفحة الرئيسية المستقلة

**الحالة:** مقبول  
**السبب:** بوابة الشركة يجب أن تكون مستقلة عن واجهة ERPNext login.  
**القرار:** استخدام صفحة Frappe web مستقلة أو Next.js منفصل، مع ربط واضح إلى `/desk`.

---

## 13. تعريف مراحل التسليم

### MVP 1: استعادة واستقرار

```text
- بيئة تطوير قابلة لإعادة البناء
- Git workflow
- backups
- site Frappe يعمل
- custom app skeleton
```

### MVP 2: إدارة التصدير الأساسية

```text
- Shipments
- Suppliers
- Importers
- RFQ
- Documents
- Basic permissions
```

### MVP 3: الامتثال والمستندات

```text
- Compliance checks
- Document lifecycle
- Audit trail
- Export workflow
```

### MVP 4: البوابة الرقمية

```text
- Public landing
- Supplier portal
- Importer portal
- Shipment tracking
```

### MVP 5: التكاملات

```text
- Integration API
- Webhooks
- Government integration logs
- Retry mechanism
```

### MVP 6: الإنتاج

```text
- Production deployment
- Monitoring
- Backups
- Security hardening
- UAT sign-off
```

---

## 14. أوامر تشغيلية أساسية

### Git

```bash
git status
git add .
git commit -m "type: message"
git push origin <branch>
```

### Frappe backup

```bash
bench --site <site-name> backup --with-files
```

### Frappe restore

```bash
bench --site <site-name> --force restore database.sql.gz \
  --with-public-files public-files.tar \
  --with-private-files private-files.tar
```

### Migration

```bash
bench --site <site-name> migrate
bench --site <site-name> clear-cache
bench build
```

### Export fixtures

```bash
bench --site <site-name> export-fixtures
```

### Development server

```bash
bench start
```

---

## 15. قائمة تحقق يومية للمطور

قبل إنهاء يوم العمل:

```text
[ ] git status نظيف أو التغييرات المهمة committed
[ ] git push تم للفرع الحالي
[ ] backup قاعدة بيانات تم إذا وجدت تغييرات في DocTypes/Settings
[ ] fixtures تم تصديرها إذا تغيرت إعدادات قابلة للكود
[ ] لا توجد أسرار في الملفات الجديدة
[ ] الوثائق تم تحديثها إذا تغير قرار معماري
[ ] ملاحظات الغد مكتوبة في CHANGELOG أو task tracker
```

---

## 16. قائمة تحقق أسبوعية للإدارة التقنية

```text
[ ] مراجعة open branches
[ ] مراجعة security audit
[ ] مراجعة backups وقابلية الاستعادة
[ ] مراجعة performance
[ ] تحديث roadmap
[ ] مراجعة pending integrations
[ ] مراجعة permissions
[ ] مراجعة documentation drift
```

---

## 17. الحالة الحالية المختصرة

```text
Project: nile-key-v3 (Nile Export)
Type: Frappe/ERPNext custom application
Current ERPNext version: 11.1.49
Target: Frappe/ERPNext v16.23.1
Remote: https://github.com/hawadettt2/nile-key-v3.git
Local OS: Windows 11
Critical constraint: Deep Freeze wipes local state
Source of truth: GitHub (all work committed)
Completed milestones:
  - Foundation: hooks.py, pyproject.toml, 19 DocTypes
  - RBAC: 13 roles with 3 workflows
  - Integration Layer: 7 API endpoints
  - CI/CD: GitHub Actions workflow
Pending milestones:
  - Bench environment setup (Docker/WSL required)
  - Production deployment
```

---

## 18. الخلاصة التنفيذية

المشروع لديه فرصة للتحول إلى منصة رقمية مؤسسية راقية لإدارة الصادرات، لكنه يحتاج أولاً إلى ضبط الاستمرارية والبنية التقنية. بسبب Deep Freeze، لا يجوز الاعتماد على البيئة المحلية. يجب أن يصبح GitHub + backups الخارجية + scripts الاستعادة هي مصدر الحقيقة.

الاتجاه المعماري الصحيح هو:

```text
Frappe/ERPNext حديث
+ custom app باسم nile_export
+ بوابة Next.js مستقلة
+ backups آلية
+ RBAC قوي
+ audit logs
+ integration layer
+ production-ready deployment
```

بهذا يتحول المشروع من نسخة ERPNext قديمة إلى منصة تصدير رقمية مستقرة، قابلة للتدقيق، وقابلة للنمو، وجديرة بتمثيل شركة وطنية طموحة في مجال الصادرات.
