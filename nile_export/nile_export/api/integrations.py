# Copyright (c) 2026, Nile Key Team
# License: MIT

from frappe import _
import frappe
import hashlib
import json


def generate_idempotency_key(data):
	"""Generate idempotency key from request data."""
	data_str = json.dumps(data, sort_keys=True)
	return hashlib.sha256(data_str.encode()).hexdigest()[:32]


@frappe.whitelist()
def log_outbound_request(integration_target=None, endpoint=None, 
	request_type=None, request_payload=None, idempotency_key=None):
	"""Log an outbound integration request."""
	if not integration_target:
		frappe.throw(_("Integration target is required"), frappe.MandatoryError)
	
	log = frappe.get_doc({
		"doctype": "Integration Log",
		"integration_target": integration_target,
		"endpoint": endpoint,
		"request_type": request_type,
		"request_payload": json.dumps(request_payload) if request_payload else None,
		"idempotency_key": idempotency_key or generate_idempotency_key(request_payload),
		"status": "Pending",
		"request_timestamp": frappe.utils.now()
	})
	
	log.insert()
	return {"log_id": log.name, "idempotency_key": log.idempotency_key}


@frappe.whitelist()
def log_inbound_response(log_id=None, response_payload=None, status="Success"):
	"""Log an inbound integration response."""
	if not log_id:
		frappe.throw(_("Log ID is required"), frappe.MandatoryError)
	
	log = frappe.get_doc("Integration Log", log_id)
	log.response_payload = json.dumps(response_payload) if response_payload else None
	log.status = status
	log.response_timestamp = frappe.utils.now()
	log.save()
	
	return {"log_id": log.name, "status": log.status}


@frappe.whitelist()
def retry_failed_request(log_id=None):
	"""Retry a failed integration request."""
	if not log_id:
		frappe.throw(_("Log ID is required"), frappe.MandatoryError)
	
	log = frappe.get_doc("Integration Log", log_id)
	
	if log.status != "Failed":
		frappe.throw(_("Cannot retry non-failed request"), frappe.ValidationError)
	
	log.retry_count = (log.retry_count or 0) + 1
	log.status = "Pending"
	log.save()
	
	return {"log_id": log.name, "retry_count": log.retry_count}