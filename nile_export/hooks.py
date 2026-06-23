# -*- coding: utf-8 -*-
from __future__ import unicode_literals

from frappe import _

app_include_js = "/assets/nile_export/js/nile_export.js"
app_include_css = "/assets/nile_export/css/nile_export.css"

doctype_js = {
	"Item": "public/js/item.js",
	"Customer": "public/js/customer.js"
}

fixtures = [
	{"doctype": "DocType", "name": ["Export Shipment", "Supplier", "Importer", "Export Document", "Shipping Line"]}
]