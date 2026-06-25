# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe


@frappe.whitelist()
def create_check(shipment=None, compliance_type=None, compliance_officer=None):
	"""Create a compliance check for a shipment."""
	if not shipment or not compliance_type:
		frappe.throw(_("Shipment and compliance type are required"), frappe.MandatoryError)
	
	check = frappe.get_doc({
		"doctype": "Compliance Check",
		"export_shipment": shipment,
		"compliance_type": compliance_type,
		"compliance_officer": compliance_officer,
		"status": "Pending"
	})
	
	check.insert()
	return {"name": check.name}


@frappe.whitelist()
def update_result(check_id=None, status=None, result_details=None):
	"""Update compliance check result."""
	if not check_id:
		frappe.throw(_("Check ID is required"), frappe.MandatoryError)
	
	check = frappe.get_doc("Compliance Check", check_id)
	check.status = status or check.status
	if result_details:
		check.result_details = result_details
	check.save()
	
	return {"name": check.name, "status": check.status}