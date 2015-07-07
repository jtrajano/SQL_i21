﻿CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
	I.intItemId, 
	I.strItemNo,
	I.strType,
	IL.intLocationId,
	(CASE WHEN ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Service Charges'),0) = 0
		THEN 
			(CASE WHEN CL.intServiceCharges = 0 THEN NULL ELSE CL.intServiceCharges END)
		ELSE
			dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Service Charges')				
	END) AS intAccountId, 
	(CASE WHEN ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Cost of Goods'),0) = 0
		THEN 
			(CASE WHEN CL.intCostofGoodsSold = 0 THEN NULL ELSE CL.intCostofGoodsSold END)
		ELSE
			dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Cost of Goods')				
	END) AS intCOGSAccountId, 	
	(CASE WHEN ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Sales Account'),0) = 0
		THEN 
			(CASE WHEN CL.intSalesAccount = 0 THEN NULL ELSE CL.intSalesAccount END)
		ELSE
			dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Sales Account')				
	END) AS intSalesAccountId, 
	(CASE WHEN ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Inventory'),0) = 0
		THEN 
			(CASE WHEN CL.intInventory = 0 THEN NULL ELSE CL.intInventory END)
		ELSE
			dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Inventory')				
	END) AS intInventoryAccountId, 
	(CASE WHEN ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Discount Receivable'),0) = 0
		THEN 
			(SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
		ELSE
			dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Discount Receivable')				
	END) AS intDiscountAccountId,
	(CASE WHEN ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Inventory In-Transit'),0) = 0
		THEN 
			(CASE WHEN CL.intInventoryInTransit = 0 THEN NULL ELSE CL.intInventoryInTransit END)
		ELSE
			dbo.fnGetItemGLAccount(I.intItemId, IL.intLocationId, N'Inventory In-Transit')				
	END) AS intInventoryInTransitAccountId
FROM         
	dbo.tblICItem AS I 
LEFT OUTER JOIN
	dbo.tblICItemLocation AS IL 
		ON IL.intItemId = I.intItemId
LEFT OUTER JOIN
	dbo.tblSMCompanyLocation CL
		ON IL.intLocationId = CL.intCompanyLocationId
