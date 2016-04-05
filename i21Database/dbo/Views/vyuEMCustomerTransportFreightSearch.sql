﻿CREATE VIEW [dbo].[vyuEMCustomerTransportFreightSearch]
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
			inner join tblEMEntity ent
				on xref.intEntityCustomerId = ent.intEntityId
			left join [tblEMEntityLocation] cus_location
				on cus_location.intEntityId = xref.intEntityCustomerId	
					and cus_location.intEntityLocationId = xref.intEntityLocationId				
			left join tblICCategory category
				on category.intCategoryId = xref.intCategoryId
			left join tblSMShipVia ship_via
				on xref.intShipViaId = ship_via.intEntityShipViaId
