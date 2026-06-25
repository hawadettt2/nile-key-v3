# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe


@frappe.whitelist()
def list_importers():
	"""List all active importers."""
	importers = frappe.get_list("Importer", filters={"status": "Active"}, 
		fields=["name", "importer_name", "country", "company_registration"])
	return importers


@frappe.whitelist()
def create_importer(importer_name=None, country=None, company_registration=None, 
	contact_person=None, email=None, phone=None, address=None):
	"""Create a new importer."""
	if not importer_name:
		frappe.throw(_("Importer name is required"), frappe.MandatoryError)
	
	importer = frappe.get_doc({
		"doctype": "Importer",
		"importer_name": importer_name,
		"country": country,
		"company_registration": company_registration,
		"contact_person": contact_person,
		"email": email,
		"phone": phone,
		"address": address,
		"status": "Active"
	})
	
	importer.insert()
	return {"name": importer.name}