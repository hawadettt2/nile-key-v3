# خطة تنفيذ مشروع Nile Key v3 - بوابة الصادرات الرقمية

## ملخص المشروع
- **الاسم:** Nile Key v3
- **الغرض:** بوابة رقمية لإدارة الصادرات المصرية
- **الحالة الحالية:** الكود جاهز، البيئة مغلقة بـ Deep Freeze (الآن مزيلة)

---

## 1. المكونات المكتملة (مُحققة في الكود)

| المكون | الحالة | الأدلة |
|--------|--------|--------|
| 19 نوع بيانات (DocTypes) | ✅ مُصلح | إزالة `"custom": 1`، module = `nile_export` |
| أدوار RBAC (13 دور) | ✅ جاهز | `nile_export/fixtures/role.json` |
| سير العمل (3 سير) | ✅ جاهز | `nile_export/fixtures/workflow.json` |
| نقاط API (7 نقطة) | ✅ جاهز | `nile_export/api/*.py` |
| اختبارات الوحدة | ✅ جاهز | `nile_export/tests/test_doctypes.py` |
| البوابة (Next.js) | ✅ مسكن | `portal/src/app/` |
| CI/CD | ✅ جاهز | `.github/workflows/ci.yml` |
| سكريبتات النسخ الاحتياطي | ✅ جاهز | `scripts/*.sh` |

---

## 2. المشكلات التي يجب حلها

### 2.1 مشكلة تسجيل الموديول
- **الخطأ:** `get_module_name('Export Shipment', 'nile_export')` يعيد `nile_export.nile_export.doctype...`
- **السبب:** مسار التثبيت مُدمج مرتين
- **الحل:** التأكد من هيكل المجلد صحيح: `apps/nile_export/nile_export/doctype/`

### 2.2 مشكلة تثبيت التطبيق
- **الخطأ:** `ModuleNotFoundError: No module named 'nile_export'`
- **السبب:** الحزمة غير مثبتة في البيئة
- **الحل:** تثبيت الحزمة عبر `pip install -e .` أو نقل الملفات يدوياً

---

## 3. خطة التنفيذ (بترتيب)

### المرحلة 0: إعداد البيئة (الآن متاحة)
**الخيار أ:** Docker (إذا كان يعمل)
```powershell
docker-compose -f pwd.yml up -d
docker exec -it backend bash
cd /home/frappe/frappe-bench
bench --site frontend install-app nile_export
bench --site frontend export-fixtures
bench --site frontend migrate
```

**الخيار ب:** WSL2 (بديل)
```bash
# تثبيت Ubuntu 22.04 عبر WSL
wsl --install -d Ubuntu-22.04
# تنفيذ سكربتات التثبيت في Ubuntu
```

### المرحلة 1: التحقق من الوظائف
- [ ] جميع 19 نوع بيانات مرئية في واجهة المكتب
- [ ] سيرة عمل "Export Shipment" تعمل (Draft → Pending → Shipped → Delivered)
- [ ] الأدوار تمنع الcesso غير المصرح به

### المرحلة 2: اختبار الوحدة
```bash
bench --site frontend run-tests --app nile_export
```

### المرحلة 3: البوابة العامة
- بناء الموقع: `cd portal && npm install && npm run build`
- اختبار الاتصال بالواجهات API

### المرحلة 4: النشر الإنتاجي
- إعداد النسخ الاحتياطيات الآلية
- تكوين المراقبة
- تثبيت SSL

---

## 4. قائمة التحقق اليومية

قبل كل commit:
1. `git status`
2. `git add . && git commit -m "..."`
3. `git push origin master`
4. نسخة احتياطية لقاعدة البيانات (إن وجدت تغييرات)

---

## 5. ملاحظة مهمة

**Deep Freeze الآن مزيل** - يمكن البدء مباشرة. البيئة آمنة للتطوير المستمر.