# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe


@frappe.whitelist()
def upload_shipment_document(shipment=None, document_type=None, file_url=None):
	"""Upload a document for an export shipment."""
	if not shipment or not document_type:
		frappe.throw(_("Shipment and document type are required"), frappe.MandatoryError)
	
	doc = frappe.get_doc({
		"doctype": "Export Document",
		"export_shipment": shipment,
		"doc_type": document_type,
		"status": "Pending"
	})
	
	doc.insert()
	return {"name": doc.name}


@frappe.whitelist()
def list_documents(shipment=None):
	"""List documents for a shipment."""
	if not shipment:
		frappe.throw(_("Shipment is required"), frappe.MandatoryError)
	
	docs = frappe.get_list("Export Document", 
		filters={"export_shipment": shipment},
		fields=["name", "document_name", "doc_type", "status", "doc_date"])
	return docs