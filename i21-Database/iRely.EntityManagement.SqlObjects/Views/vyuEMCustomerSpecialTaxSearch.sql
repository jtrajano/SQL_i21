CREATE VIEW [dbo].[vyuEMCustomerSpecialTaxSearch]
	AS 

	select 
		special_tax.intEntityCustomerId,
		cus_location.strLocationName,
		vend.strVendorId,
		item.strItemNo,
		category.strCategoryCode,
		tax_group.strTaxGroup,
		ent.strName,
		ent.strEntityNo,
		intWarehouseId = isnull(eloc.intWarehouseId, -99)

	from tblARSpecialTax special_tax
		inner join tblEMEntity ent
			on special_tax.intEntityCustomerId = ent.intEntityId
			
		inner join tblEMEntityLocation eloc
			on ent.intEntityId = eloc.intEntityId and eloc.ysnDefaultLocation = 1	
		left join [tblEMEntityLocation] cus_location
			on cus_location.intEntityId = special_tax.intEntityCustomerId
				and special_tax.intEntityCustomerLocationId = cus_location.intEntityLocationId
		left join tblAPVendor vend 
			on vend.[intEntityId] = special_tax.intEntityVendorId
		left join tblICItem item
			on item.intItemId = special_tax.intItemId
		left join tblICCategory category
			on category.intCategoryId = special_tax.intCategoryId
		left join tblSMTaxGroup tax_group
			on tax_group.intTaxGroupId = special_tax.intTaxGroupId
