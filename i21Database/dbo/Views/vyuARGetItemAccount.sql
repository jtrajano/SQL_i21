﻿CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
	I.intItemId, 
	I.strItemNo,
	I.strType,
	IL.intLocationId,
	dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Cost of Goods') AS intCOGSAccountId, 	
	dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Sales Account') AS intSalesAccountId, 
	dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Inventory') AS intInventoryAccountId, 
	dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Inventory In-Transit') AS intInventoryInTransitAccountId,
	dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'General') AS intGeneralAccountId,
	dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Other Charge Income') AS intOtherChargeIncomeAccountId,
	(CASE WHEN ISNULL((SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0),0) = 0
		THEN 
			dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Service Charges')
		ELSE
			(SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)				
	END) AS intAccountId, 		
	(CASE WHEN ISNULL((SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0),0) = 0
		THEN 
			dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Discount Receivable')				
		ELSE
			(SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
	END) AS intDiscountAccountId,
	dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales') AS intMaintenanceSalesAccountId
FROM         
	dbo.tblICItem AS I 
LEFT OUTER JOIN
	dbo.tblICItemLocation AS IL 
		ON IL.intItemId = I.intItemId
		AND IL.intLocationId IS NOT NULL 
