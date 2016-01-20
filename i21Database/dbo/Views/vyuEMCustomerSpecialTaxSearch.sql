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
		ent.strEntityNo

	from tblARSpecialTax special_tax
		inner join tblEntity ent
			on special_tax.intEntityCustomerId = ent.intEntityId
		left join tblEntityLocation cus_location
			on cus_location.intEntityId = special_tax.intEntityCustomerId
		left join tblAPVendor vend 
			on vend.intEntityVendorId = special_tax.intEntityVendorId
		left join tblICItem item
			on item.intItemId = special_tax.intItemId
		left join tblICCategory category
			on category.intCategoryId = special_tax.intCategoryId
		left join tblSMTaxGroup tax_group
			on tax_group.intTaxGroupId = special_tax.intTaxGroupId
