CREATE VIEW [dbo].[vyuEMETExportCustomerSpecialPricing]
	AS 

	select 
		
		patr_no = b.strCustomerNumber, 
		item_no = e.strItemNo,
		patr_price = c.dblPrice

	from tblARCustomerSpecialPrice a
		join tblARCustomer b
			on a.intEntityCustomerId = b.[intEntityId]
		join tblEMEntity z
			on a.intEntityCustomerId = z.intEntityId
		join tblEMEntityLocation d
			on d.intEntityId = b.[intEntityId] and d.ysnDefaultLocation = 1
		left join vyuICGetItemPricing e
			on e.intItemId = a.intItemId
			 and e.intLocationId = d.intWarehouseId 
		Cross apply dbo.fnARGetCustomerPricingDetails(
			a.intItemId,
			b.[intEntityId],
			d.intWarehouseId,
			e.intItemUOMId,
			cast(GetDate() as date),
			1,
			null,
			null,
			null,
			b.intShipToId,
			null,
			'Invoice',
			0,	
		    (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference)
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
			on a.intEntityCustomerId = b.[intEntityId]  and a.intItemId is null 
		join tblEMEntity z
			on a.intEntityCustomerId = z.intEntityId
		join tblEMEntityLocation d
			on d.intEntityId = b.[intEntityId] and d.ysnDefaultLocation = 1
		left join tblICCategory e
			on e.intCategoryId= a.intCategoryId
		left join tblICItem f
			on f.intCategoryId = e.intCategoryId
		left join vyuICGetItemPricing g
			on g.intItemId = f.intItemId
			 and g.intLocationId = d.intWarehouseId
		Cross apply dbo.[fnARGetItemPricingDetails](
			g.intItemId,
			b.[intEntityId],
			d.intWarehouseId,
			g.intItemUOMId,
			(SELECT TOP 1 intDefaultCountryId FROM tblSMCompanyPreference),
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
			null,			
			null,		
			b.intShipToId,
			null,		
			null,		
			null,	
			'Invoice',
			null,
			0		    					
		) c
 
	 WHERE g.strItemNo is not null

