CREATE VIEW [dbo].[vyuMBILExportCustomerTaxExemption]  
AS  


SELECT * FROM 
	(
		SELECT TE.*							
		FROM
			tblARCustomerTaxingTaxException TE
		LEFT OUTER JOIN
			tblSMTaxCode TC
				ON TE.[intTaxCodeId] = TC.[intTaxCodeId]
		LEFT OUTER JOIN
			[tblEMEntityLocation] EL	
				ON TE.[intEntityCustomerLocationId] = EL.[intEntityLocationId]
		LEFT OUTER JOIN
			tblSMTaxClass TCL
				ON TE.[intTaxClassId] = TCL.[intTaxClassId]
		LEFT OUTER JOIN
			tblICItem  IC
				ON TE.[intItemId] = IC.[intItemId]
		LEFT OUTER JOIN
			tblICCategory ICC
				ON TE.[intCategoryId] = ICC.[intCategoryId]
		LEFT OUTER JOIN
			tblCFCard CFC
				ON TE.[intCardId] = CFC.[intCardId]
		LEFT OUTER JOIN
			tblCFVehicle CFV
				ON TE.[intVehicleId] = CFV.[intVehicleId] 		
	) tblCustomer
