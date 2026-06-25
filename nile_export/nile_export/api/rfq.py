# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe


@frappe.whitelist()
def create_rfq(importer=None, title=None, description=None, 
	quantity_required=None, target_price=None, currency=None):
	"""Create a new RFQ."""
	if not importer or not title:
		frappe.throw(_("Importer and title are required"), frappe.MandatoryError)
	
	rfq = frappe.get_doc({
		"doctype": "RFQ",
		"importer": importer,
		"title": title,
		"description": description,
		"quantity_required": quantity_required,
		"target_price": target_price,
		"currency": currency,
		"status": "Open"
	})
	
	rfq.insert()
	return {"name": rfq.name}


@frappe.whitelist()
def submit_quotation(rfq=None, supplier=None, price=None, validity_days=None):
	"""Submit quotation for an RFQ."""
	if not rfq or not supplier:
		frappe.throw(_("RFQ and supplier are required"), frappe.MandatoryError)
	
	frappe.get_doc({
		"doctype": "DocType",
		"supplier": supplier,
		"rfq": rfq,
		"price": price
	}).insert()
	
	return {"status": "submitted"}