CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
	 [intItemId]						= I.[intItemId]
	,[strItemNo]						= I.strItemNo
	,[strType]							= I.[strType]
	,[intLocationId]					= IL.[intLocationId]
	,[intCOGSAccountId]					= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Cost of Goods'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Cost of Goods'), 0)), SMCL.[intProfitCenter]), ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Cost of Goods'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Cost of Goods'), 0)))
	,[intSalesAccountId]				= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](dbo.fnARGetItemGLAccount(I.[intItemId], IL.[intItemLocationId]), SMCL.intProfitCenter), dbo.fnARGetItemGLAccount(I.[intItemId], IL.[intItemLocationId]))
	,[intInventoryAccountId]			= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory'), 0)), SMCL.[intProfitCenter]), ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory'), 0)))
	,[intInventoryInTransitAccountId]	= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory In-Transit'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory In-Transit'), 0)), SMCL.[intProfitCenter]), ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory In-Transit'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Inventory In-Transit'), 0)))
	,[intGeneralAccountId]				= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'General'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'General'), 0)), SMCL.[intProfitCenter]), ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'General'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'General'), 0)))
	,[intOtherChargeIncomeAccountId]	= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Other Charge Income'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Other Charge Income'), 0)), SMCL.[intProfitCenter]), ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Other Charge Income'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Other Charge Income'), 0)))
	,[intAccountId]						= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](
																							ISNULL((SELECT TOP 1 ARCP.[intServiceChargeAccountId] FROM tblARCompanyPreference ARCP WITH (NOLOCK) INNER JOIN (SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK) WHERE [ysnActive] = 1) GLA ON ARCP.[intServiceChargeAccountId] = GLA.[intAccountId])
																									,ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Service Charges'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Service Charges'), 0))
																							), SMCL.[intProfitCenter])
												, ISNULL((SELECT TOP 1 ARCP.[intServiceChargeAccountId] FROM tblARCompanyPreference ARCP WITH (NOLOCK) INNER JOIN (SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK) WHERE [ysnActive] = 1) GLA ON ARCP.[intServiceChargeAccountId] = GLA.[intAccountId])
														,ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Service Charges'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Service Charges'), 0))
												))
	,[intDiscountAccountId]				= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](
																							ISNULL((SELECT TOP 1 ARCP.[intDiscountAccountId] FROM tblARCompanyPreference ARCP WITH (NOLOCK) INNER JOIN (SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK) WHERE [ysnActive] = 1) GLA ON ARCP.[intDiscountAccountId] = GLA.[intAccountId])
																									,ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Discount Receivable'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Discount Receivable'), 0))
																							), SMCL.[intProfitCenter])
												, ISNULL((SELECT TOP 1 ARCP.[intDiscountAccountId] FROM tblARCompanyPreference ARCP WITH (NOLOCK) INNER JOIN (SELECT [intAccountId] FROM tblGLAccount WITH (NOLOCK) WHERE [ysnActive] = 1) GLA ON ARCP.[intDiscountAccountId] = GLA.[intAccountId])
														,ISNULL(dbo.fnGetItemGLAccount(I.[intItemId], IL.[intItemLocationId], N'Discount Receivable'), NULLIF(dbo.fnGetItemBaseGLAccount(I.[intItemId], IL.[intItemLocationId], N'Discount Receivable'), 0))
												))
	,[intMaintenanceSalesAccountId]		= ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales'), NULLIF(dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales'), 0)), SMCL.[intProfitCenter]), ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales'), NULLIF(dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales'), 0)))
FROM
	(SELECT [intItemId], [strItemNo], [strType] FROM dbo.tblICItem WITH (NOLOCK)) AS I 
LEFT OUTER JOIN
    (SELECT [intItemId], [intLocationId], [intItemLocationId] FROM dbo.tblICItemLocation WITH (NOLOCK)) AS IL 
		ON IL.[intItemId] = I.[intItemId] 
		AND IL.[intLocationId] IS NOT NULL
LEFT OUTER JOIN 
    (SELECT [intCompanyLocationId], [intProfitCenter] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL 
		ON IL.[intLocationId] = SMCL.[intCompanyLocationId]
