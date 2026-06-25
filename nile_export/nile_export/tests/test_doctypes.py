# Copyright (c) 2026, Nile Key Team
# License: MIT

from __future__ import unicode_literals

import frappe
import unittest

test_dependencies = ['Company']


class TestExportShipment(unittest.TestCase):
	def test_create_export_shipment(self):
		"""Test creating a basic export shipment."""
		shipment = frappe.get_doc({
			"doctype": "Export Shipment",
			"shipment_name": "_Test Shipment",
			"status": "Draft",
			"priority": "Medium",
			"description": "Test shipment for unit test"
		}).insert(ignore_permissions=True)
		
		self.assertEqual(shipment.shipment_name, "_Test Shipment")
		self.assertEqual(shipment.status, "Draft")

	def test_shipment_status_transition(self):
		"""Test shipment status field validation."""
		shipment = frappe.get_doc({
			"doctype": "Export Shipment",
			"shipment_name": "_Test Shipment 2",
			"status": "Pending"
		}).insert(ignore_permissions=True)
		
		self.assertEqual(shipment.status, "Pending")

	def test_required_fields(self):
		"""Test that required fields are enforced."""
		shipment = frappe.get_doc({
			"doctype": "Export Shipment"
		})
		
		self.assertRaises(frappe.MandatoryError, shipment.insert)


class TestSupplier(unittest.TestCase):
	def test_create_supplier(self):
		"""Test creating a supplier."""
		supplier = frappe.get_doc({
			"doctype": "Supplier",
			"supplier_name": "_Test Supplier",
			"status": "Active"
		}).insert(ignore_permissions=True)
		
		self.assertEqual(supplier.supplier_name, "_Test Supplier")
		self.assertEqual(supplier.status, "Active")


class TestImporter(unittest.TestCase):
	def test_create_importer(self):
		"""Test creating an importer."""
		importer = frappe.get_doc({
			"doctype": "Importer",
			"importer_name": "_Test Importer",
			"status": "Active"
		}).insert(ignore_permissions=True)
		
		self.assertEqual(importer.importer_name, "_Test Importer")
		self.assertEqual(importer.status, "Active")


class TestExportDocument(unittest.TestCase):
	def test_create_export_document(self):
		"""Test creating an export document."""
		doc = frappe.get_doc({
			"doctype": "Export Document",
			"document_name": "_Test Document",
			"doc_type": "Commercial Invoice"
		}).insert(ignore_permissions=True)
		
		self.assertEqual(doc.document_name, "_Test Document")
		self.assertEqual(doc.doc_type, "Commercial Invoice")


class TestShippingLine(unittest.TestCase):
	def test_create_shipping_line(self):
		"""Test creating a shipping line."""
		line = frappe.get_doc({
			"doctype": "Shipping Line",
			"shipping_line_name": "_Test Shipping Line"
		}).insert(ignore_permissions=True)
		
		self.assertEqual(line.shipping_line_name, "_Test Shipping Line")