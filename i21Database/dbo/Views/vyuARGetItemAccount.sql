CREATE VIEW [dbo].[vyuARGetItemAccount]
AS
SELECT     
	I.intItemId, 
	I.strItemNo,
	I.strType,
	IL.intLocationId,
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Cost of Goods'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Cost of Goods')) AS intCOGSAccountId, 	
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Sales Account'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Sales Account')) AS intSalesAccountId, 
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Inventory'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Inventory')) AS intInventoryAccountId, 
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Inventory In-Transit'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Inventory In-Transit')) AS intInventoryInTransitAccountId,
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'General'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'General')) AS intGeneralAccountId,
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Other Charge Income'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Other Charge Income')) AS intOtherChargeIncomeAccountId,
	(CASE WHEN ISNULL((SELECT TOP 1 intServiceChargeAccountId 
					   FROM 
							(SELECT intServiceChargeAccountId FROM tblARCompanyPreference WITH (NOLOCK))  tblARCompanyPreference
						   INNER JOIN 
							(SELECT intAccountId FROM tblGLAccount WITH (NOLOCK)) tblGLAccount ON tblARCompanyPreference.intServiceChargeAccountId = tblGLAccount.intAccountId 
					   WHERE tblARCompanyPreference.intServiceChargeAccountId IS NOT NULL AND tblARCompanyPreference.intServiceChargeAccountId <> 0
					  ),0) = 0
		THEN 
			ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Service Charges'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Service Charges'))
		ELSE
			ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](
					(SELECT TOP 1 intServiceChargeAccountId 
					 FROM 
							(SELECT intServiceChargeAccountId FROM tblARCompanyPreference WITH (NOLOCK)) tblARCompanyPreference
							 INNER JOIN 
							(SELECT intAccountId FROM tblGLAccount WITH (NOLOCK)) tblGLAccount ON tblARCompanyPreference.intServiceChargeAccountId = tblGLAccount.intAccountId
					 WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)
					,SMCL.[intProfitCenter])
					,(SELECT TOP 1 intServiceChargeAccountId 
					  FROM 
							(SELECT intServiceChargeAccountId FROM tblARCompanyPreference WITH (NOLOCK)) tblARCompanyPreference
					  INNER JOIN 
							(SELECT intAccountId FROM tblGLAccount WITH (NOLOCK)) tblGLAccount ON tblARCompanyPreference.intServiceChargeAccountId = tblGLAccount.intAccountId
					  WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)
				)
							
	END) AS intAccountId, 		
	(CASE WHEN ISNULL((SELECT TOP 1 intDiscountAccountId 
	                   FROM 
							(SELECT intDiscountAccountId FROM tblARCompanyPreference WITH (NOLOCK)) tblARCompanyPreference
					   INNER JOIN 
							(SELECT intAccountId FROM tblGLAccount WITH (NOLOCK)) tblGLAccount ON tblARCompanyPreference.intDiscountAccountId = tblGLAccount.intAccountId 
					   WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0),0) = 0
		THEN 
			ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Discount Receivable'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Discount Receivable'))				
		ELSE
			ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](
					 (SELECT TOP 1 intDiscountAccountId 
					  FROM 
							(SELECT intDiscountAccountId FROM tblARCompanyPreference WITH (NOLOCK)) tblARCompanyPreference
					   INNER JOIN 
							(SELECT intAccountId FROM tblGLAccount WITH (NOLOCK)) tblGLAccount ON tblARCompanyPreference.intDiscountAccountId = tblGLAccount.intAccountId
					  WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
					,SMCL.[intProfitCenter])
					,(SELECT TOP 1 intDiscountAccountId 
					  FROM 
							(SELECT intDiscountAccountId FROM tblARCompanyPreference WITH (NOLOCK)) tblARCompanyPreference
					  INNER JOIN 
							(SELECT intAccountId FROM tblGLAccount WITH (NOLOCK)) tblGLAccount ON tblARCompanyPreference.intDiscountAccountId = tblGLAccount.intAccountId 
					  WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
				)			
	END) AS intDiscountAccountId,
	ISNULL(dbo.fnGetItemGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales'), dbo.fnGetItemBaseGLAccount(I.intItemId, IL.intItemLocationId, N'Maintenance Sales')) AS intMaintenanceSalesAccountId
FROM
     (SELECT intItemId, strItemNo, strType FROM dbo.tblICItem WITH (NOLOCK)) AS I 
   LEFT OUTER JOIN
      (SELECT intItemId, intLocationId, intItemLocationId FROM dbo.tblICItemLocation WITH (NOLOCK)) AS IL ON IL.intItemId = I.intItemId AND  IL.intLocationId IS NOT NULL
   LEFT OUTER JOIN 
      (SELECT intCompanyLocationId, [intProfitCenter] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL ON IL.intLocationId = SMCL.intCompanyLocationId
