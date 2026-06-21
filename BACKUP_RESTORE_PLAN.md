# BACKUP_RESTORE_PLAN.md

## خطة النسخ الاحتياطي والاستعادة لمشروع ile-key-v3

**الهدف:** حماية المشروع من الفقدان الكامل للبيانات بسبب Deep Freeze أو فشل الجهاز أو حذف البيئة المحلية.

**المستودع الرسمي:**

```text
https://github.com/hawadettt2/nile-key-v3.git
```

---

## 1. مبدأ الحماية

مشروع Frappe/ERPNext يتكون من أربعة أصول أساسية:

```text
1. الكود والوثائق
2. قاعدة البيانات
3. الملفات العامة والخاصة
4. إعدادات البيئة والمفاتيح
```

Git يحمي الكود والوثائق فقط. لذلك نحتاج backups منفصلة للبيانات والملفات.

---

## 2. ما الذي يجب حفظه في Git؟

يجب حفظ:

```text
الكود المصدري
الوثائق
hooks
fixtures
custom DocTypes
print formats
workflows
scripts الآمنة
README و roadmap
```

لا يجب حفظ:

```text
.env
site_config.json الحقيقي
كلمات المرور
API keys
SMTP credentials
Supabase keys
Payment keys
database dumps غير مشفرة
private files حساسة
```

---

## 3. ما الذي يجب نسخه احتياطياً خارج Git؟

بعد أي تغيير مهم:

```bash
bench --site <site-name> backup --with-files
```

الناتج يشمل عادة:

```text
database SQL backup
public files archive
private files archive
```

يجب نقل هذه الملفات إلى:

```text
S3 / MinIO
Google Drive مشفر
OneDrive مشفر
قرص خارجي
خادم تطوير بعيد
GitHub Release خاص فقط إذا كانت البيانات مشفرة وغير حساسة
```

---

## 4. جدول backups المقترح

### تطوير يومي

بعد تغيير DocTypes أو Permissions أو Workflows:

```bash
bench --site nile-key.test backup --with-files
```

### قبل أي migration

```bash
bench --site nile-key.test backup --with-files
bench --site nile-key.test export-fixtures
```

### قبل أي upgrade

```bash
bench --site nile-key.test backup --with-files
bench --site nile-key.test export-fixtures
```

### نهاية كل يوم عمل مهم

```bash
bench --site nile-key.test backup --with-files
```

ثم انقل النسخة إلى مكان خارجي غير متأثر بـ Deep Freeze.

---

## 5. تصنيف backups

### 5.1 Development backup

بيانات وهمية أو غير حساسة. يمكن استخدامها محلياً.

### 5.2 Staging backup

بيانات قريبة من الإنتاج، لكنها masked أو غير حساسة قدر الإمكان.

### 5.3 Production backup

بيانات حقيقية. يجب أن تكون:

```text
مشفرة
مخزنة خارجياً
محمية بصلاحيات صارمة
قابلة للاستعادة ومختبرة
```

---

## 6. تشفير backups

قبل رفع أي backup حساس، استخدم ضغطاً مشفراً.

مثال على Linux:

```bash
tar -czf nile-key-files-$(date +%F-%H%M).tar.gz public private
gpg -c nile-key-files-$(date +%F-%H%M).tar.gz
```

ثم احذف الملف غير المشفر:

```bash
shred -u nile-key-files-$(date +%F-%H%M).tar.gz
```

---

## 7. استعادة backup كامل

```bash
cd ~/frappe/nile-key-bench

bench --site nile-key.test \
  --force restore /path/to/database.sql.gz \
  --with-public-files /path/to/public-files.tar \
  --with-private-files /path/to/private-files.tar
```

ثم:

```bash
bench --site nile-key.test migrate
bench --site nile-key.test clear-cache
bench build
bench start
```

---

## 8. استعادة site_config.json

إذا احتجت استعادة `site_config.json`:

```text
sites/nile-key.test/site_config.json
```

تحقق من عدم وجود أسرار مكشوفة، ثم:

```bash
bench --site nile-key.test clear-cache
```

---

## 9. اختبار الاستعادة

يجب اختبار restore دورياً.

### Checklist

```text
[ ] backup موجود خارجياً
[ ] backup قابل للقراءة
[ ] restore على site جديد نجح
[ ] login يعمل
[ ] desk يعمل
[ ] custom DocTypes موجودة
[ ] permissions صحيحة
[ ] الملفات الخاصة موجودة
[ ] الملفات العامة موجودة
[ ] لا توجد أخطاء migration
[ ] لا توجد أسرار داخل Git
```

---

## 10. سياسة الاحتفاظ

مقترح مبدئي:

```text
آخر backup يومي: 14 يوم
backup أسبوعي: 8 أسابيع
backup شهري: 12 شهراً
backup قبل كل release: حتى بعد release التالي
```

---

## 11. استعادة بعد Deep Freeze wipe

1. clone repository:

```bash
git clone https://github.com/hawadettt2/nile-key-v3.git
```

2. اقرأ:

```bash
less RECOVERY_RUNBOOK.md
less MASTER_ROADMAP.md
```

3. جهز WSL/Ubuntu.
4. ثبّت MariaDB و Redis و Bench.
5. أنشئ bench.
6. انسخ repo إلى `apps/erpnext`.
7. أنشئ site.
8. استعد backup.
9. شغّل migrate و build.
10. اختبر login و desk.

---

## 12. قاعدة حاسمة

> لا تعتبر backup ناجحاً إلا إذا تم اختبار restore منه.
