CREATE VIEW [dbo].[vyuEMCustomerSpecialPriceSearch]
	AS 

	select 
		special_price.intEntityCustomerId,
		strCustomerLocation = cus_location.strLocationName,
		special_price.strPriceBasis,
		special_price.strCostToUse,
		strVendorId = vend.strVendorId,
		strItemNo = item.strItemNo,
		strVendorLocationName =  vend_location.strLocationName,
		category.strCategoryCode,
		special_price.strCustomerGroup,
		special_price.dblDeviation,
		special_price.strLineNote,
		special_price.dtmBeginDate,
		special_price.dtmEndDate,
		strVendorRankId =vend_rank.strVendorId,
		strItemRankId = item_rank.strItemNo,
		strVendorRankLocationName = vend_location_rank.strLocationName,
		special_price.strInvoiceType,
		ent.strName,
		ent.strEntityNo

		from tblARCustomerSpecialPrice special_price
		inner join tblEntity ent
			on special_price.intEntityCustomerId = ent.intEntityId
		left join tblEntityLocation cus_location
			on cus_location.intEntityId = special_price.intEntityCustomerId
		left join tblAPVendor vend
			on vend.intEntityVendorId = special_price.intEntityVendorId	
		left join tblAPVendor vend_rank
			on vend_rank.intEntityVendorId = special_price.intRackVendorId
		left join tblICItem item
			on item.intItemId = special_price.intItemId
		left join tblICItem item_rank
			on item_rank.intItemId = special_price.intRackItemId
		left join tblEntityLocation vend_location
			on vend_location.intEntityId = vend.intEntityVendorId
		left join tblEntityLocation vend_location_rank
			on vend_location_rank.intEntityId = vend_rank.intEntityVendorId
		left join tblICCategory category
			on category.intCategoryId = special_price.intCategoryId
