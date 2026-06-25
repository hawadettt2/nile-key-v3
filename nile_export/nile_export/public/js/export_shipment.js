frappe.ui.form.on('Export Shipment', {
	refresh: function(frm) {
		// Set workflow state based on status
		if (frm.doc.status) {
			frm.set_df_property('workflow_state', 'hidden', false);
		}
	},
	
	onload: function(frm) {
		// Set default values
		if (!frm.doc.company) {
			frappe.call({
				method: "frappe.client.get_value",
				args: {
					doctype: "Company",
					fieldname: "name"
				},
				callback: function(r) {
					if (r.message) {
						frm.set_value('company', r.message.name);
					}
				}
			});
		}
	}
});