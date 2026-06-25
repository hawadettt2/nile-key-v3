# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe


@frappe.whitelist()
def create_shipment(customer=None, shipment_type=None, destination_country=None, products=None):
	"""Create a new export shipment."""
	if not customer:
		frappe.throw(_("Customer is required"), frappe.MandatoryError)
	
	shipment = frappe.get_doc({
		"doctype": "Export Shipment",
		"shipment_name": f"EXP-SHIP-{frappe.generate_hash('Auto', 5)}",
		"importer": customer,
		"status": "Draft"
	})
	
	shipment.insert(ignore_permissions=False)
	return {"name": shipment.name, "status": shipment.status}


@frappe.whitelist()
def update_status(shipment=None, status=None, note=None):
	"""Update shipment status."""
	if not shipment or not status:
		frappe.throw(_("Shipment and status are required"), frappe.MandatoryError)
	
	doc = frappe.get_doc("Export Shipment", shipment)
	doc.status = status
	if note:
		doc.add_comment("Comment", note)
	doc.save()
	
	return {"name": doc.name, "status": doc.status}