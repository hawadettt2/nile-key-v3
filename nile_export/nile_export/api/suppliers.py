# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe


@frappe.whitelist()
def list_suppliers():
	"""List all active suppliers."""
	suppliers = frappe.get_list("Supplier", filters={"status": "Active"}, fields=["name", "supplier_name", "country"])
	return suppliers


@frappe.whitelist()
def create_supplier(supplier_name=None, country=None, contact_person=None, email=None, phone=None):
	"""Create a new supplier."""
	if not supplier_name:
		frappe.throw(_("Supplier name is required"), frappe.MandatoryError)
	
	supplier = frappe.get_doc({
		"doctype": "Supplier",
		"supplier_name": supplier_name,
		"country": country,
		"contact_person": contact_person,
		"email": email,
		"phone": phone,
		"status": "Active"
	})
	
	supplier.insert()
	return {"name": supplier.name}