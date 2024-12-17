oci search resource structured-search `
	--query-text "QUERY instance resources return region, timeMaintenanceRebootDue where timeMaintenanceRebootDue > 'Now' sorted by timeMaintenanceRebootDue desc" `
	--query 'data.items[].{name:"display-name",state:"lifecycle-state",RebootTime:"additional-details"."timeMaintenanceRebootDue", region:"additional-details"."region"}' `
	--region 'syd' `
	| convertFrom-json | sort-object -property name | format-table
