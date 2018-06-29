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
		ent.strEntityNo,
		intWarehouseId = isnull(eloc.intWarehouseId, -99)

		from tblARCustomerSpecialPrice special_price
		inner join tblEMEntity ent
			on special_price.intEntityCustomerId = ent.intEntityId			
		inner join tblEMEntityLocation eloc
			on ent.intEntityId = eloc.intEntityId and eloc.ysnDefaultLocation = 1	
		left join [tblEMEntityLocation] cus_location
			on cus_location.intEntityId = special_price.intEntityCustomerId
				and special_price.intCustomerLocationId = cus_location.intEntityLocationId
		left join tblAPVendor vend
			on vend.[intEntityId] = special_price.intEntityVendorId	
		left join tblAPVendor vend_rank
			on vend_rank.[intEntityId] = special_price.intRackVendorId
		left join tblICItem item
			on item.intItemId = special_price.intItemId
		left join tblICItem item_rank
			on item_rank.intItemId = special_price.intRackItemId
		left join [tblEMEntityLocation] vend_location
			on vend_location.intEntityId = vend.[intEntityId]
				and vend_location.intEntityLocationId = special_price.intEntityLocationId
		left join [tblEMEntityLocation] vend_location_rank
			on vend_location_rank.intEntityId = vend_rank.[intEntityId]
				and vend_location_rank.intEntityLocationId = special_price.intRackLocationId
		left join tblICCategory category
			on category.intCategoryId = special_price.intCategoryId
