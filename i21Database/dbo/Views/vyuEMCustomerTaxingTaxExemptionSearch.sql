CREATE VIEW [dbo].[vyuEMCustomerTaxingTaxExemptionSearch]
	AS
	
	select 
		tax_exemption.intCustomerTaxingTaxExceptionId,
		tax_exemption.intEntityCustomerId,
		cus_location.strLocationName,
		item.strItemNo,
		category.strCategoryCode,
		tax_code.strTaxCode,
		tax_class.strTaxClass,
		tax_exemption.strException,
		tax_exemption.strExceptionReason,
		tax_exemption.dtmStartDate,
		tax_exemption.dtmEndDate,
		tax_exemption.strState,
		tax_exemption.dblPartialTax,		
		ent.strName,
		ent.strEntityNo,
		intWarehouseId = isnull(eloc.intWarehouseId, -99),
		strCardNumber = cf.strCardNumber,
		strCardDescription = cf.strCardDescription,
		strVehicleNumber =  vf.strVehicleNumber,
		strVehicleDescription = vf.strVehicleDescription 

	from tblARCustomerTaxingTaxException tax_exemption
		inner join tblEMEntity ent
				on tax_exemption.intEntityCustomerId = ent.intEntityId
		inner join tblEMEntityLocation eloc
			on ent.intEntityId = eloc.intEntityId and eloc.ysnDefaultLocation = 1
		left join [tblEMEntityLocation] cus_location
			on cus_location.intEntityId = tax_exemption.intEntityCustomerId	
				and cus_location.intEntityLocationId = tax_exemption.intEntityCustomerLocationId
		left join tblICItem item
			on item.intItemId = tax_exemption.intItemId
		left join tblICCategory category
			on category.intCategoryId = tax_exemption.intCategoryId
		left join tblSMTaxCode tax_code
			on tax_code.intTaxCodeId = tax_exemption.intTaxCodeId
		left join tblSMTaxClass tax_class
			on tax_class.intTaxClassId = tax_exemption.intTaxClassId
		left join tblCFCard cf
			on tax_exemption.intCardId = cf.intCardId
		left join tblCFVehicle vf
			on tax_exemption.intVehicleId = vf.intVehicleId

		
