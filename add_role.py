import frappe
frappe.get_doc("User", "admin").add_roles("nile_export_app_role")
print("Role added successfully")