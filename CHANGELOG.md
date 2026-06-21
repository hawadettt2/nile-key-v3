# CHANGELOG.md

## سجل تغييرات مشروع ile-key-v3

هذا السجل يوثق التغييرات المهمة في المشروع، خاصة التحول من نسخة ERPNext v11 legacy إلى منصة تصدير رقمية مؤسسية.

---

## [Unreleased]

### Added

- `MASTER_ROADMAP.md` كوثيقة استراتيجية وتقنية واستمرارية.
- `RECOVERY_RUNBOOK.md` كدليل عملي لاستعادة البيئة بعد أي مسح محلي.
- `ARCHITECTURE_DECISIONS.md` لتسجيل القرارات المعمارية.
- `BACKUP_RESTORE_PLAN.md` لتحديد سياسة النسخ والاستعادة.
- `SECURITY_POLICY.md` لتحديد سياسة الأمان.
- `DEVELOPMENT_SETUP.md` لتوثيق إعداد بيئة التطوير.
- `API_CONTRACTS.md` لتوثيق عقود APIs المستقبلية.
- روابط الوثائق الرسمية داخل `README.md`.

### Changed

- تم تعزيز README ليعكس توجه المشروع كبوابة رقمية للصادرات.
- تم توثيق قيود Deep Freeze كمخاطر تشغيلية أساسية.

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
