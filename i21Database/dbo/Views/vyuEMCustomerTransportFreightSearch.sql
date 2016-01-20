CREATE VIEW [dbo].[vyuEMCustomerTransportFreightSearch]
	AS

	select 	

		xref.intEntityCustomerId,
		cus_location.strLocationName,	
		xref.strZipCode,
		category.strCategoryCode,
		xref.ysnFreightOnly,
		xref.strFreightType,
		ship_via.strShipVia,
		xref.dblFreightAmount,
		xref.dblFreightRate,
		xref.dblFreightMiles,
		xref.ysnFreightInPrice,
		xref.dblMinimumUnits,
		ent.strName,
		ent.strEntityNo

		from tblARCustomerFreightXRef xref
			inner join tblEntity ent
				on xref.intEntityCustomerId = ent.intEntityId
			left join tblEntityLocation cus_location
				on cus_location.intEntityId = xref.intEntityCustomerId					
			left join tblICCategory category
				on category.intCategoryId = xref.intCategoryId
			left join tblSMShipVia ship_via
				on xref.intShipViaId = ship_via.intEntityShipViaId
