CREATE PROCEDURE [dbo].[uspARUpdateTransactionAccounts]
     @Ids               Id                          READONLY
    ,@ItemAccounts      [dbo].[InvoiceItemAccount]  Readonly
    ,@TransactionType   INT	= 1
						
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

IF ISNULL(@TransactionType, 0) = 1	--Invoice
	BEGIN
		IF(OBJECT_ID('tempdb..#INVOICES') IS NOT NULL)
		BEGIN
			DROP TABLE #INVOICES
		END

		SELECT ARI.intInvoiceId
			 , ARI.intCompanyLocationId
			 , ARI.strTransactionType
		INTO #INVOICES
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN @IdsLocal PID ON ARI.intInvoiceId = PID.intId

		IF(OBJECT_ID('tempdb..#INVOICEDETAIL') IS NOT NULL)
		BEGIN
			DROP TABLE #INVOICEDETAILS
		END	
		
		SELECT ARI.intInvoiceId
			 , ARID.intInvoiceDetailId
			 , ARID.intAccountId
			 , ARID.intCOGSAccountId			 
			 , ARID.intSalesAccountId
			 , ARID.intInventoryAccountId
			 , ARID.intServiceChargeAccountId
			 , ARID.intLicenseAccountId
			 , ARID.intMaintenanceAccountId
			 , ARID.intConversionAccountId
			 , ARID.intItemId
			 , ARID.strMaintenanceType
			 , ARI.intCompanyLocationId
			 , ARI.strTransactionType
		INTO #INVOICEDETAILS
		FROM dbo.tblARInvoiceDetail ARID WITH (NOLOCK)
		INNER JOIN @IdsLocal PID ON ARID.intInvoiceId = PID.intId
		INNER JOIN #INVOICES ARI ON ARID.intInvoiceId = ARI.intInvoiceId		
		
		UPDATE ARI SET ARI.intAccountId = ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, SMCL.intProfitCenter), ARI.intAccountId)
		FROM dbo.tblARInvoice ARI WITH (NOLOCK)
		INNER JOIN @IdsLocal PID ON ARI.intInvoiceId = PID.intId
		INNER JOIN #COMPANYLOCATIONS SMCL ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId

		INSERT INTO @LineItemAccounts(
			 [intDetailId]
			,[intAccountId]
			,[intCOGSAccountId]
			,[intSalesAccountId]
			,[intInventoryAccountId]
			,[intServiceChargeAccountId]
			,[intLicenseAccountId]
			,[intMaintenanceAccountId]
		)
		SELECT
			 [intInvoiceDetailId]
			,[intAccountId]
			,[intCOGSAccountId]
			,[intSalesAccountId]
			,[intInventoryAccountId]
			,[intServiceChargeAccountId]
			,[intLicenseAccountId]
			,[intMaintenanceAccountId]
		FROM #INVOICEDETAILS

		--NOT IN Non-Inventory, Service, Other Charge, Software
		UPDATE LIA
		SET  LIA.intAccountId			= IST.intSalesAccountId
			,LIA.intSalesAccountId		= CASE WHEN ARID.strTransactionType = 'Debit Memo' THEN ARID.intSalesAccountId ELSE IST.intSalesAccountId END
			,LIA.intCOGSAccountId		= IST.intCOGSAccountId
			,LIA.intInventoryAccountId	= IST.intInventoryAccountId
		FROM @LineItemAccounts LIA
		INNER JOIN #INVOICEDETAILS ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN #ITEMS ICI ON ARID.intItemId = ICI.intItemId
		OUTER APPLY (
			SELECT TOP 1 intSalesAccountId
					   , intCOGSAccountId
					   , intInventoryAccountId
			FROM @ItemAccounts IST 
			WHERE IST.intItemId = ARID.intItemId
			  AND IST.intLocationId = ARID.intCompanyLocationId
		) IST
		WHERE ISNULL(ARID.[intItemId], 0) <> 0
		  AND ICI.strType NOT IN ('Non-Inventory', 'Service', 'Other Charge', 'Software')

		--Non-Inventory, Service, Other Charge
		UPDATE LIA
		SET LIA.[intAccountId] = (CASE WHEN ITEM.[strType] IN ('Non-Inventory','Service')
											THEN
											(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], GENERAL.[intGeneralAccountId]) ELSE GENERAL.[intGeneralAccountId] END)													
									   WHEN ITEM.[strType] = 'Other Charge'
											THEN
											(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], OTHERCHARGE.[intOtherChargeIncomeAccountId]) ELSE OTHERCHARGE.[intOtherChargeIncomeAccountId] END)
									   ELSE
											(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END))) 
												ELSE
													ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END)) 
											END)											
									END)
		FROM @LineItemAccounts LIA
		INNER JOIN #INVOICEDETAILS ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		LEFT JOIN #ITEMS ITEM ON ARID.intItemId = ITEM.intItemId
		LEFT JOIN #ITEMLOCATION ITEMLOCATION ON ITEMLOCATION.intItemId = ARID.intItemId
											AND ITEMLOCATION.intLocationId = ARID.intCompanyLocationId
											AND ITEMLOCATION.intLocationId IS NOT NULL
		OUTER APPLY (SELECT ISNULL(dbo.fnGetItemGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'General'), NULLIF(dbo.fnGetItemBaseGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'General'), 0)) AS intGeneralAccountId) GENERAL
		OUTER APPLY (SELECT ISNULL(dbo.fnGetItemGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'Other Charge Income'), NULLIF(dbo.fnGetItemBaseGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'Other Charge Income'), 0)) AS intOtherChargeIncomeAccountId) OTHERCHARGE
		WHERE ISNULL(ARID.intItemId, 0) <> 0
		   OR ITEM.strType IN ('Non-Inventory', 'Service', 'Other Charge')

		--Software License
		UPDATE LIA
		SET LIA.intLicenseAccountId = IST.intGeneralAccountId
		FROM @LineItemAccounts LIA
		INNER JOIN #INVOICEDETAILS ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN #ITEMS ICI ON ARID.intItemId = ICI.intItemId
		OUTER APPLY (
			SELECT TOP 1 intGeneralAccountId
			FROM @ItemAccounts IST 
			WHERE IST.intItemId = ARID.intItemId
			  AND IST.intLocationId = ARID.intCompanyLocationId
		) IST
		WHERE ARID.strMaintenanceType IN ('License/Maintenance', 'License Only')
		  AND ICI.strType = 'Software'

		--Software Maintenance and SaaS
		UPDATE LIA
		SET LIA.intMaintenanceAccountId = IST.intMaintenanceSalesAccountId
		FROM @LineItemAccounts LIA
		INNER JOIN #INVOICEDETAILS ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN #ITEMS ICI ON ARID.intItemId = ICI.intItemId
		OUTER APPLY (
			SELECT TOP 1 intMaintenanceSalesAccountId
			FROM @ItemAccounts IST 
			WHERE IST.intItemId = ARID.intItemId
			  AND IST.intLocationId = ARID.intCompanyLocationId
		) IST
		WHERE ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ICI.strType = 'Software'					

		--NULL Account Ids
		UPDATE LIA
		SET LIA.intAccountId	= CASE WHEN ISNULL(ARID.intItemId, 0) <> 0
									   THEN ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)))
									   ELSE ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, CL.intSalesAccount)))
								  END
		FROM @LineItemAccounts LIA
		INNER JOIN #INVOICEDETAILS ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN #INVOICES ARI ON ARID.intInvoiceId = ARID.intInvoiceId
		INNER JOIN #COMPANYLOCATIONS CL ON ARI.intCompanyLocationId = CL.intCompanyLocationId
		OUTER APPLY (
			SELECT TOP 1 intSalesAccountId
			FROM @ItemAccounts IST 
			WHERE IST.intItemId = ARID.intItemId
			  AND IST.intLocationId = ARID.intCompanyLocationId
		) IST
		WHERE ISNULL(LIA.intAccountId, 0) = 0
		
		--NULL Sales Account Ids
		UPDATE LIA
		SET LIA.intSalesAccountId = ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)
		FROM @LineItemAccounts LIA
		INNER JOIN #INVOICEDETAILS ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		OUTER APPLY (
			SELECT TOP 1 intSalesAccountId
			FROM @ItemAccounts IST 
			WHERE IST.intItemId = ARID.intItemId
			  AND IST.intLocationId = ARID.intCompanyLocationId
		) IST
		WHERE ISNULL(LIA.intSalesAccountId, 0) = 0			
		
		--Update Invoice Detail
		UPDATE ARID
		SET  ARID.intAccountId					= LIA.intAccountId
			,ARID.intCOGSAccountId				= LIA.intCOGSAccountId
			,ARID.intSalesAccountId				= LIA.intSalesAccountId
			,ARID.intInventoryAccountId			= LIA.intInventoryAccountId
			,ARID.intServiceChargeAccountId		= ISNULL(ARID.intServiceChargeAccountId ,LIA.intServiceChargeAccountId)
			,ARID.intLicenseAccountId			= LIA.intLicenseAccountId
			,ARID.intMaintenanceAccountId		= LIA.intMaintenanceAccountId
		FROM tblARInvoiceDetail ARID
		INNER JOIN @LineItemAccounts LIA ON ARID.intInvoiceDetailId = LIA.intDetailId

		--Update Invoice Tax Detail
		UPDATE ARITD
		SET ARITD.intSalesTaxAccountId = ISNULL(dbo.fnGetGLAccountIdFromProfitCenter(ARITD.intSalesTaxAccountId, SMCL.intProfitCenter), ARITD.intSalesTaxAccountId)
		FROM tblARInvoiceDetailTax ARITD
		INNER JOIN #INVOICEDETAILS ARID ON ARITD.intInvoiceDetailId = ARID.intInvoiceDetailId
		LEFT OUTER JOIN #COMPANYLOCATIONS SMCL ON ARID.intCompanyLocationId = SMCL.intCompanyLocationId
					
	END
ELSE
	BEGIN
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
	 
END

GO