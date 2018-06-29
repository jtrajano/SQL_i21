CREATE VIEW [dbo].[vyuEMCustomerTransportQuoteSearch]
	AS 

	select 
		quote_header.intEntityCustomerId,
		cus_location.strLocationName,
		supply_point.strSupplyPoint,
		strCategoryCode = dbo.fnEMGetCustomerTransportQuoteCategory(quote_header.intCustomerRackQuoteHeaderId),
		strItemNo = dbo.fnEMGetCustomerTransportQuoteItem(quote_header.intCustomerRackQuoteHeaderId),
		ent.strName,
		ent.strEntityNo,
		intWarehouseId = isnull(eloc.intWarehouseId, -99)

	from tblARCustomerRackQuoteHeader quote_header
		inner join tblEMEntity ent
			on quote_header.intEntityCustomerId = ent.intEntityId
		inner join tblEMEntityLocation eloc
			on ent.intEntityId = eloc.intEntityId and eloc.ysnDefaultLocation = 1		
		--left join tblARCustomerRackQuoteCategory quote_category
		--	on quote_header.intCustomerRackQuoteHeaderId = quote_category.intCustomerRackQuoteHeaderId		
		--left join tblARCustomerRackQuoteItem quote_item
		--	on quote_header.intCustomerRackQuoteHeaderId = quote_item.intCustomerRackQuoteHeaderId
		left join tblARCustomerRackQuoteVendor quote_vendor
			on quote_header.intCustomerRackQuoteHeaderId = quote_vendor.intCustomerRackQuoteHeaderId
		left join [tblEMEntityLocation] cus_location
			on cus_location.intEntityId = quote_header.intEntityCustomerId
				and cus_location.intEntityLocationId = quote_vendor.intEntityCustomerLocationId
		--left join tblICItem item
		--	on item.intItemId = quote_item.intItemId
		--left join tblICCategory category
		--	on category.intCategoryId = quote_category.intCategoryId
		left join vyuTRSupplyPointView supply_point
			on quote_vendor.intSupplyPointId = supply_point.intSupplyPointId
