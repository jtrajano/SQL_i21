CREATE VIEW [dbo].[vyuEMCustomerTransportQuoteSearch]
	AS 

	select 
		quote_header.intEntityCustomerId,
		cus_location.strLocationName,
		supply_point.strSupplyPoint,
		category.strCategoryCode,
		item.strItemNo,
		ent.strName,
		ent.strEntityNo

	from tblARCustomerRackQuoteHeader quote_header
		inner join tblEntity ent
			on quote_header.intEntityCustomerId = ent.intEntityId
		left join tblEntityLocation cus_location
			on cus_location.intEntityId = quote_header.intEntityCustomerId	
		left join tblARCustomerRackQuoteCategory quote_category
			on quote_header.intCustomerRackQuoteHeaderId = quote_category.intCustomerRackQuoteHeaderId
		left join tblARCustomerRackQuoteItem quote_item
			on quote_header.intCustomerRackQuoteHeaderId = quote_item.intCustomerRackQuoteHeaderId
		left join tblARCustomerRackQuoteVendor quote_vendor
			on quote_header.intCustomerRackQuoteHeaderId = quote_vendor.intCustomerRackQuoteHeaderId
		left join tblICItem item
			on item.intItemId = quote_item.intItemId
		left join tblICCategory category
			on category.intCategoryId = quote_category.intCategoryId
		left join vyuTRSupplyPointView supply_point
			on quote_vendor.intSupplyPointId = supply_point.intSupplyPointId
