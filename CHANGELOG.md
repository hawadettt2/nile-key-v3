# CHANGELOG.md

## سجل تغييرات مشروع ile-key-v3

هذا السجل يوثق التغييرات المهمة في المشروع، خاصة التحول من نسخة ERPNext v11 legacy إلى منصة تصدير رقمية مؤسسية.

---

## [Unreleased]

### Added

- `MASTER_ROADMAP.md` كوثيقة استراتيجية وتقمية واستمرارية.
- `RECOVERY_RUNBOOK.md` كدليل عملي لاستعادة البيئة بعد أي مسح محلي.
- `ARCHITECTURE_DECISIONS.md` لتسجيل القرارات المعمارية.
- `BACKUP_RESTORE_PLAN.md` لتحديد سياسة النسخ والاستعادة.
- `SECURITY_POLICY.md` لتحديد سياسة الأمان.
- `DEVELOPMENT_SETUP.md` لتوثيق إعداد بيئة التطوير.
- `API_CONTRACTS.md` لتوثيق عقود APIs المستقبلية.
- روابط الوثائق الرسمية داخل `README.md`.
- `scripts/check-windows-env.ps1` لفحص WSL2 والافتراضية و MariaDB/Redis على Windows host.
- `scripts/verify-backup.sh` للتحقق من ملفات backup قبل الاعتماد عليها.
- `scripts/install-mariadb-redis.sh` و `scripts/init-bench.sh` و `scripts/sanity-check.sh` لاستكمال workflow استعادة bench.
- `nile_export/` تطبيق مخصص كامل بـ 19 DocTypes.
- `ACID Record`, `Customs Declaration`, `Supplier Station`, `Packing Station` DocTypes.
- `RFQ`, `Quality Inspection`, `Compliance Check` DocTypes.
- `Integration Log`, `Shipping Instruction`, `Certificate Request` DocTypes.
- `Export Task`, `Shipment Timeline`, `Government Integration Log`, `Audit Evidence` DocTypes.
- RBAC Roles (13 أدور) في fixtures/role.json.
- Export Shipment, Supplier Station, Packing Station Workflows (3 workflows).
- GitHub Actions CI workflow للتحقق من النحو.

### Changed

- تم تعزيز README ليعكس توجه المشروع كبوابة رقمية للصادرات.
- تم تحديث `DEVELOPMENT_SETUP.md` و `RECOVERY_RUNBOOK.md` بفحص Windows/WSL قبل تشغيل Frappe.
- تم تحديث `BACKUP_RESTORE_PLAN.md` بخطوة التحقق من backup.
- تم تحديث `MASTER_ROADMAP.md` بقائمة scripts التشغيلية الكاملة.
- تم توسيع `.gitignore` لحماية `site_config.json` و `sites/` و `logs/` و backups و `.env`.
- تم استعادة وتحسين بنية nile_export بعد إعادة الهيكلة.

### Security

- تم توثيق منع تخزين الأسرار داخل Git.
- تم توثيق ضرورة backups مشفرة وخارجية.
- تم توثيق ضرورة RBAC و audit logging.

---

## [2026-06-22]

### Added

- Commit `a6eca64418`: `docs: add Nile Key strategic master roadmap`
- Commit `47c89c8f60`: `docs: add practical recovery runbook`
- Commit `5b556557c1`: `docs: add architecture backup and security governance`

### Notes

- تم رفع الوثائق الأساسية إلى GitHub لحماية المشروع من فقدان البيئة المحلية بسبب Deep Freeze.
