CREATE VIEW [dbo].[vyuMBILExportCustomerSpecialPricing]
 AS   
	SELECT   
	ROW_NUMBER() OVER(ORDER BY strCustomerNumber) AS intCustomerPricingId  
	,b.strCustomerNumber
	,ICItems.strItemNo
	,ISNULL(c.dblPrice ,0) as dblPrice
	,c.strPricing  COLLATE Latin1_General_CI_AS AS strPricing
	  
	from tblARCustomerSpecialPrice a  
	join tblARCustomer b  
	on a.intEntityCustomerId = b.[intEntityId]  
	join tblEMEntity z  
	on a.intEntityCustomerId = z.intEntityId  
	join tblEMEntityLocation d  
	on d.intEntityId = b.[intEntityId] and d.ysnDefaultLocation = 1  
	  
	INNER JOIN  vyuICGetItemStock ICItems 
			ON (a.intCategoryId = ICItems.intCategoryId
				AND ICItems.intLocationId = d.intWarehouseId 
				AND a.intItemId IS NULL)   
			OR (a.intItemId = ICItems.intItemId
				AND ICItems.intLocationId = d.intWarehouseId
				AND a.intItemId IS NOT NULL)   
	--INNER JOIN (SELECT DISTINCT intItemId FROM [vyuETExportItem]) ETItems ON ICItems.intItemId = ETItems.intItemId
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

			