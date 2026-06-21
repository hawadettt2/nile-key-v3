# API_CONTRACTS.md

## عقود APIs المقترحة لمنصة Nile Key Export Gateway

هذه الوثيقة تحدد الشكل المستهدف لـ APIs النظام. الهدف هو توحيد التكامل بين Frappe/ERPNext، custom app، والبوابة الرقمية.

---

## 1. المبادئ

كل API يجب أن:

```text
يتحقق من الصلاحية
يصادق المدخلات
يسجل العملية الحساسة
يرجع أخطاء واضحة
يدعم idempotency عند الحاجة
لا يرجع بيانات أكثر من المطلوب
```

---

## 2. Naming convention

```text
/api/method/nile_export.api.<domain>.<action>
```

مثال:

```text
/api/method/nile_export.api.shipments.create_shipment
```

---

## 3. Export Shipments

### Create shipment

```http
POST /api/method/nile_export.api.shipments.create_shipment
```

Request:

```json
{
  "customer": "Importer Name",
  "shipment_type": "Sea",
  "destination_country": "Saudi Arabia",
  "products": []
}
```

Response:

```json
{
  "message": {
    "name": "EXP-SHIP-00001",
    "status": "Draft"
  }
}
```

### Update status

```http
POST /api/method/nile_export.api.shipments.update_status
```

Request:

```json
{
  "shipment": "EXP-SHIP-00001",
  "status": "In Progress",
  "note": "Documents under review"
}
```

---

## 4. Suppliers

### List suppliers

```http
GET /api/method/nile_export.api.suppliers.list_suppliers
```

Response:

```json
{
  "message": [
    {
      "name": "Supplier A",
      "city": "Ismailia",
      "status": "Active"
    }
  ]
}
```

### Create supplier

```http
POST /api/method/nile_export.api.suppliers.create_supplier
```

---

## 5. Importers

### Create importer

```http
POST /api/method/nile_export.api.importers.create_importer
```

### List importers

```http
GET /api/method/nile_export.api.importers.list_importers
```

---

## 6. RFQ

### Create RFQ

```http
POST /api/method/nile_export.api.rfq.create_rfq
```

### Submit supplier quotation

```http
POST /api/method/nile_export.api.rfq.submit_quotation
```

---

## 7. Documents

### Upload shipment document

```http
POST /api/method/nile_export.api.documents.upload_shipment_document
```

Request:

```json
{
  "shipment": "EXP-SHIP-00001",
  "document_type": "Packing List",
  "file_url": "/private/files/file.pdf"
}
```

### List documents

```http
GET /api/method/nile_export.api.documents.list_documents?shipment=EXP-SHIP-00001
```

---

## 8. Compliance

### Create compliance check

```http
POST /api/method/nile_export.api.compliance.create_check
```

### Update compliance result

```http
POST /api/method/nile_export.api.compliance.update_result
```

---

## 9. Government integrations

### Log outbound request

```http
POST /api/method/nile_export.api.integrations.log_outbound_request
```

### Log inbound response

```http
POST /api/method/nile_export.api.integrations.log_inbound_response
```

### Retry failed integration

```http
POST /api/method/nile_export.api.integrations.retry_failed_request
```

---

## 10. Error format

```json
{
  "exc_type": "ValidationError",
  "exc": "Required field missing: customer",
  "_server_messages": "[]"
}
```

---

## 11. Security requirements

```text
No anonymous write APIs
No secrets in frontend
Validate every input
Log sensitive operations
Use role checks
Use rate limiting for public endpoints
```
