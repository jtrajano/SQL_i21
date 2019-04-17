CREATE VIEW [dbo].[vyuEMETExportCustomerSpecialPricing]
 AS   
	SELECT   
	patr_no = b.strCustomerNumber,   
	item_no = CAST(ICItems.strItemNo AS VARCHAR(15)),  
	patr_price = c.dblPrice  
	,c.strPricing  COLLATE Latin1_General_CI_AS AS strPricing
	  
	from tblARCustomerSpecialPrice a  
	join tblARCustomer b  
	on a.intEntityCustomerId = b.[intEntityId]  
	join tblEMEntity z  
	on a.intEntityCustomerId = z.intEntityId  
	join tblEMEntityLocation d  
	on d.intEntityId = b.[intEntityId] and d.ysnDefaultLocation = 1  
	  
	INNER JOIN  vyuICGetItemStock ICItems ON a.intCategoryId = ICItems.intCategoryId
				AND ICItems.intLocationId = d.intWarehouseId   
	INNER JOIN vyuICETExportItem ETItems ON ICItems.intItemId = ETItems.intItemId
	CROSS APPLY dbo.[fnARGetItemPricingDetails](  
			ICItems.intItemId,  
			b.[intEntityId],  
			d.intWarehouseId,  
			ICItems.intStockUOMId,  
			(SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference),  
			cast(GetDate() as date),  
			1,  
			null,    
			null,    
			null,    
			null,     
			null,    
			null,       
			null,    
			1,
			null,  
			null,   
			null,      
			null,     
			null,    
			b.intShipToId,  
			null,    
			null,    
			null,   
			NULL,  
			null,  
			0,  
			1.000000,  
			null,
			0  
			) c  
	WHERE a.intItemId IS null AND a.intCategoryId IS NOT NULL
	   
	UNION 
	  
	 SELECT   
	  --DISTINCT  
	  patr_no = b.strCustomerNumber,  
	  item_no = g.strItemNo,  
	  patr_price = c.dblPrice  
	  ,c.strPricing
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
	   (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference),  
	   cast(GetDate() as date),  
	   1,  
	   null,    
	   null,    
	   null,    
	   null,     
	   null,    
	   null,       
	   null,    
	   1,--null,  
	   null,  
	   null,   
	   null,      
	   null,     
	   null,    
	   b.intShipToId,  
	   null,    
	   null,    
	   null,   
	   NULL,  
	   null,  
	   0,  
	   1.000000,  
	   null,
	   0  
	  ) c  
	   
	  WHERE g.strItemNo IS NOT NULL

