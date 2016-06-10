﻿CREATE VIEW [dbo].[vyuETCustomerSpecialPricing]
	AS 

	select 
		
		patr_no = b.strCustomerNumber, 
		item_no = e.strItemNo,
		patr_price = c.dblPrice

	from tblARCustomerSpecialPrice a
		join tblARCustomer b
			on a.intEntityCustomerId = b.intEntityCustomerId
		join tblEMEntity z
			on a.intEntityCustomerId = z.intEntityId
		join tblEMEntityLocation d
			on d.intEntityId = b.intEntityCustomerId and d.ysnDefaultLocation = 1
		left join vyuICGetItemPricing e
			on e.intItemId = a.intItemId
			 and e.intLocationId = d.intWarehouseId 
		Cross apply dbo.fnARGetCustomerPricingDetails(
			a.intItemId,
			b.intEntityCustomerId,
			d.intWarehouseId,
			e.intItemUOMId,
			cast(GetDate() as date),
			1,
			null,
			null,
			null,
			b.intShipToId,
			null,
			'Standard'			
		) c
	where a.intItemId is not null and a.intItemId > 0
	
	union all


	select 
		DISTINCT
		
		patr_no = b.strCustomerNumber,
		item_no = g.strItemNo,
		patr_price = c.dblPrice

	from tblARCustomerSpecialPrice a
		join tblARCustomer b
			on a.intEntityCustomerId = b.intEntityCustomerId  and a.intItemId is null 
		join tblEMEntity z
			on a.intEntityCustomerId = z.intEntityId
		join tblEMEntityLocation d
			on d.intEntityId = b.intEntityCustomerId and d.ysnDefaultLocation = 1
		left join tblICCategory e
			on e.intCategoryId= a.intCategoryId
		left join tblICItem f
			on f.intCategoryId = e.intCategoryId
		left join vyuICGetItemPricing g
			on g.intItemId = f.intItemId
			 and g.intLocationId = d.intWarehouseId
		Cross apply dbo.[fnARGetItemPricingDetails](
			g.intItemId,
			b.intEntityCustomerId,
			d.intWarehouseId,
			g.intItemUOMId,
			cast(GetDate() as date),
			1,
			null,		
			null,		
			null,		
			null,			
			null,		
			null,     
			null,		
			null,	
			null,				
			null,			
			null,		
			b.intShipToId,
			null,		
			null,		
			null,	
			'Standard',
			null				
		) c
 
	 WHERE g.strItemNo is not null

