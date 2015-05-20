CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
	I.intItemId, 
	I.strItemNo,
	I.strType,
	IL.intLocationId,
	(CASE WHEN ISNULL(dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Service Charges'),0) = 0
		THEN 
			(CASE WHEN CL.intServiceCharges = 0 THEN NULL ELSE CL.intServiceCharges END)
		ELSE
			dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Service Charges')				
	END) AS intAccountId, 
	(CASE WHEN ISNULL(dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Cost of Goods'),0) = 0
		THEN 
			(CASE WHEN CL.intCostofGoodsSold = 0 THEN NULL ELSE CL.intCostofGoodsSold END)
		ELSE
			dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Cost of Goods')				
	END) AS intCOGSAccountId, 	
	(CASE WHEN ISNULL(dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Sales Account'),0) = 0
		THEN 
			(CASE WHEN CL.intSalesAccount = 0 THEN NULL ELSE CL.intSalesAccount END)
		ELSE
			dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Sales Account')				
	END) AS intSalesAccountId, 
	(CASE WHEN ISNULL(dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Inventory'),0) = 0
		THEN 
			(CASE WHEN CL.intInventory = 0 THEN NULL ELSE CL.intInventory END)
		ELSE
			dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intLocationId, N'Inventory')				
	END) AS intInventoryAccountId
FROM         
	dbo.tblICItem AS I 
LEFT OUTER JOIN
	dbo.tblICItemLocation AS IL 
		ON IL.intItemId = I.intItemId
LEFT OUTER JOIN
	dbo.tblSMCompanyLocation CL
		ON IL.intLocationId = CL.intCompanyLocationId 
