CREATE PROCEDURE [dbo].[uspARUpdateTransactionAccounts]
     @Ids               Id                          READONLY
    ,@ItemAccounts      [dbo].[InvoiceItemAccount]  Readonly
						
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal DECIMAL(18,6)
DECLARE @IdsLocal AS Id

SET @ZeroDecimal = 0.000000	

INSERT INTO @IdsLocal
SELECT * FROM @Ids

DECLARE @LineItemAccounts AS TABLE(
	 [intDetailId]					INT
	,[intAccountId]					INT
	,[intCOGSAccountId]				INT
	,[intSalesAccountId]			INT
	,[intInventoryAccountId]		INT
	,[intServiceChargeAccountId]	INT
	,[intLicenseAccountId]			INT
	,[intMaintenanceAccountId]		INT
)

IF(OBJECT_ID('tempdb..#ITEMS') IS NOT NULL)
BEGIN
	DROP TABLE #ITEMS
END

SELECT intItemId
	 , strType
INTO #ITEMS
FROM dbo.tblICItem WITH (NOLOCK)

IF(OBJECT_ID('tempdb..#ITEMLOCATION') IS NOT NULL)
BEGIN
	DROP TABLE #ITEMLOCATION
END

SELECT intItemId
	 , intLocationId
	 , intItemLocationId
INTO #ITEMLOCATION
FROM dbo.tblICItemLocation WITH (NOLOCK)

IF(OBJECT_ID('tempdb..#COMPANYLOCATIONS') IS NOT NULL)
BEGIN
	DROP TABLE #COMPANYLOCATIONS
END

SELECT intCompanyLocationId
	 , intProfitCenter
	 , intSalesAccount
INTO #COMPANYLOCATIONS
FROM dbo.tblSMCompanyLocation WITH (NOLOCK)

IF(OBJECT_ID('tempdb..#ORDERDETAILS') IS NOT NULL)
BEGIN
	DROP TABLE #ORDERDETAILS
END

SELECT SOD.intSalesOrderId
		, SOD.intSalesOrderDetailId
		, SOD.intAccountId
		, SOD.intCOGSAccountId
		, SOD.intSalesAccountId
		, SOD.intInventoryAccountId
		, SOD.intLicenseAccountId
		, SOD.intMaintenanceAccountId
		, SO.intCompanyLocationId
		, SOD.intItemId
		, SOD.strMaintenanceType			 
INTO #ORDERDETAILS
FROM dbo.tblSOSalesOrderDetail SOD WITH(NOLOCK)
INNER JOIN @IdsLocal PID ON SOD.intSalesOrderId = PID.intId
INNER JOIN (
	SELECT intSalesOrderId
			, intCompanyLocationId
	FROM dbo.tblSOSalesOrder WITH (NOLOCK)
) SO ON SOD.intSalesOrderId = SO.intSalesOrderId

INSERT INTO @LineItemAccounts(
		[intDetailId]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intLicenseAccountId]
	,[intMaintenanceAccountId]
)
SELECT
		[intSalesOrderDetailId]
	,[intAccountId]
	,[intCOGSAccountId]
	,[intSalesAccountId]
	,[intInventoryAccountId]
	,[intLicenseAccountId]
	,[intMaintenanceAccountId]
FROM #ORDERDETAILS

UPDATE LIA
SET LIA.[intAccountId]			= IST.[intSalesAccountId]
	, LIA.[intSalesAccountId]		= IST.[intSalesAccountId]
	, LIA.[intCOGSAccountId]		= IST.[intCOGSAccountId]
	, LIA.[intInventoryAccountId]	= IST.[intInventoryAccountId] 
FROM @LineItemAccounts LIA
INNER JOIN #ORDERDETAILS SOD ON LIA.intDetailId = SOD.intSalesOrderDetailId
INNER JOIN #ITEMS ICI ON SOD.intItemId = ICI.intItemId
OUTER APPLY (
	SELECT TOP 1 intSalesAccountId
				, intCOGSAccountId
				, intInventoryAccountId
	FROM vyuARGetItemAccount IST 
	WHERE IST.intItemId = SOD.intItemId
		AND IST.intLocationId = SOD.intCompanyLocationId
) IST							
WHERE ISNULL(SOD.[intItemId], 0) <> 0
	AND ICI.[strType] NOT IN ('Non-Inventory','Service','Other Charge','Software')

UPDATE LIA
SET LIA.[intAccountId] = (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = SOD.[intItemId] AND [strType] IN ('Non-Inventory','Service'))) 
								THEN
									IST.[intGeneralAccountId]													
								WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = SOD.[intItemId] AND [strType] = 'Other Charge')) 
								THEN
									IST.[intOtherChargeIncomeAccountId]
								ELSE
									ISNULL(SOD.[intSalesAccountId], IST.[intSalesAccountId])
							END)
FROM @LineItemAccounts LIA
INNER JOIN #ORDERDETAILS  SOD ON LIA.[intDetailId] = SOD.[intSalesOrderDetailId] 
OUTER APPLY (
	SELECT TOP 1 intGeneralAccountId
				, intOtherChargeIncomeAccountId
				, intSalesAccountId
	FROM vyuARGetItemAccount IST 
	WHERE IST.intItemId = SOD.intItemId
		AND IST.intLocationId = SOD.intCompanyLocationId
) IST					
WHERE ISNULL(SOD.[intItemId], 0) <> 0
	OR (EXISTS(SELECT NULL FROM tblICItem WITH (NOLOCK) WHERE [intItemId] = SOD.[intItemId] AND [strType] IN ('Non-Inventory','Service','Other Charge')))
			
UPDATE LIA
SET LIA.[intLicenseAccountId] = IST.[intGeneralAccountId]
FROM @LineItemAccounts LIA
INNER JOIN #ORDERDETAILS SOD ON LIA.[intDetailId] = SOD.[intSalesOrderDetailId] 
INNER JOIN #ITEMS ICI ON SOD.[intItemId] = ICI.[intItemId] 				
OUTER APPLY (
	SELECT TOP 1 intGeneralAccountId
	FROM vyuARGetItemAccount IST 
	WHERE IST.intItemId = SOD.intItemId
		AND IST.intLocationId = SOD.intCompanyLocationId
) IST	
WHERE SOD.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
	AND ICI.[strType] = 'Software'
		  
UPDATE LIA
SET LIA.[intMaintenanceAccountId] = IST.[intMaintenanceSalesAccountId]
FROM @LineItemAccounts LIA
INNER JOIN #ORDERDETAILS SOD ON LIA.[intDetailId] = SOD.[intSalesOrderDetailId] 
INNER JOIN #ITEMS ICI ON SOD.[intItemId] = ICI.[intItemId] 				
OUTER APPLY (
	SELECT TOP 1 intMaintenanceSalesAccountId
	FROM vyuARGetItemAccount IST 
	WHERE IST.intItemId = SOD.intItemId
		AND IST.intLocationId = SOD.intCompanyLocationId
) IST
WHERE SOD.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
	AND ICI.[strType] = 'Software'					
		  
UPDATE LIA
SET LIA.[intAccountId]	= ISNULL(SOD.[intSalesAccountId], IST.[intSalesAccountId])
FROM @LineItemAccounts LIA
INNER JOIN #ORDERDETAILS SOD ON LIA.[intDetailId] = SOD.[intSalesOrderDetailId] 	
OUTER APPLY (
	SELECT TOP 1 intSalesAccountId
	FROM vyuARGetItemAccount IST 
	WHERE IST.intItemId = SOD.intItemId
		AND IST.intLocationId = SOD.intCompanyLocationId
) IST
LEFT OUTER JOIN #COMPANYLOCATIONS SMCL ON SOD.intCompanyLocationId = SMCL.intCompanyLocationId
WHERE ISNULL(LIA.[intAccountId], 0) = 0
			
UPDATE LIA
SET LIA.[intSalesAccountId] = ISNULL(SOD.[intSalesAccountId], IST.[intSalesAccountId])
FROM @LineItemAccounts LIA		
INNER JOIN #ORDERDETAILS SOD ON LIA.[intDetailId] = SOD.[intSalesOrderDetailId] 	
OUTER APPLY (
	SELECT TOP 1 intSalesAccountId
	FROM vyuARGetItemAccount IST 
	WHERE IST.intItemId = SOD.intItemId
		AND IST.intLocationId = SOD.intCompanyLocationId
) IST
LEFT OUTER JOIN #COMPANYLOCATIONS SMCL ON SOD.intCompanyLocationId = SMCL.intCompanyLocationId
WHERE ISNULL(LIA.[intSalesAccountId], 0) = 0			
			
UPDATE SOD
SET  SOD.[intAccountId]					= LIA.[intAccountId]
	,SOD.[intCOGSAccountId]				= LIA.[intCOGSAccountId]
	,SOD.[intSalesAccountId]			= LIA.[intSalesAccountId]
	,SOD.[intInventoryAccountId]		= LIA.[intInventoryAccountId]
	,SOD.[intLicenseAccountId]			= LIA.[intLicenseAccountId]
	,SOD.[intMaintenanceAccountId]		= LIA.[intMaintenanceAccountId]
FROM tblSOSalesOrderDetail SOD
INNER JOIN @LineItemAccounts LIA ON SOD.[intSalesOrderDetailId] = LIA.[intDetailId] 	
				
UPDATE SODT
SET SODT.[intSalesTaxAccountId] = ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](SODT.[intSalesTaxAccountId], SMCL.[intProfitCenter]), SODT.[intSalesTaxAccountId])
FROM tblSOSalesOrderDetailTax SODT
INNER JOIN #ORDERDETAILS SOD ON SODT.[intSalesOrderDetailId] = SOD.[intSalesOrderDetailId]
LEFT OUTER JOIN #COMPANYLOCATIONS SMCL ON SOD.intCompanyLocationId = SMCL.intCompanyLocationId
	 
END

GO