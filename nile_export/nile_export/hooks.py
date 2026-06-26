# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from frappe import _

app_title = "Nile Export"
app_name = "nile_export"
app_description = "Digital Export Gateway for Nile Key"
app_publisher = "Nile Key Team"
app_email = "info@nilekey.com"
app_license = "MIT"

doctype_js = {
	"Export Shipment": "public/js/export_shipment.js"
}

fixtures = [
	{"doctype": "DocType", "name": [
		"Export Shipment",
		"Supplier",
		"Importer",
		"Export Document",
		"Shipping Line",
		"ACID Record",
		"Customs Declaration",
		"Supplier Station",
		"Packing Station",
		"RFQ",
		"Quality Inspection",
		"Compliance Check",
		"Integration Log",
		"Shipping Instruction",
		"Certificate Request",
		"Export Task",
		"Shipment Timeline",
		"Government Integration Log",
		"Audit Evidence"
	]},
	{"doctype": "Role", "name": [
		"Nile Export Owner",
		"Nile Export Admin",
		"Export Director",
		"Operations Manager",
		"Compliance Officer",
		"Logistics Officer",
		"Finance Officer",
		"Supplier",
		"Importer",
		"Agent",
		"Auditor",
		"Government Integration Service",
		"Guest"
	]},
	{"doctype": "Workflow", "name": [
		"Export Shipment",
		"Supplier Station",
		"Packing Station"
	]},
	{"doctype": "Custom DocPerm", "name": [
		"Nile Export Owner - Export Shipment",
		"Nile Export Admin - Export Shipment",
		"Export Director - Export Shipment",
		"Operations Manager - Export Shipment",
		"Logistics Officer - Export Shipment",
		"Auditor - Export Shipment",
		"Supplier - Export Shipment",
		"Importer - Export Shipment",
		"Guest - Export Shipment"
	]}
]