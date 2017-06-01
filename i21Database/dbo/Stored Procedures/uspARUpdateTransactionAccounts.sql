CREATE PROCEDURE [dbo].[uspARUpdateTransactionAccounts]
	@Ids				Id	READONLY
	,@TransactionType	INT	= 1
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

IF ISNULL(@TransactionType, 0) = 1	--Invoice
	BEGIN
	
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
		FROM
			tblARInvoiceDetail ARID WITH (NOLOCK)
		INNER JOIN
			@IdsLocal PID
				ON ARID.[intInvoiceId] = PID.[intId]

		--NOT IN Non-Inventory, Service, Other Charge, Software
		UPDATE LIA
		SET  LIA.intAccountId			= IST.intSalesAccountId
			,LIA.intSalesAccountId		= CASE WHEN ARI.strTransactionType = 'Debit Memo' THEN ARID.intSalesAccountId ELSE IST.intSalesAccountId END
			,LIA.intCOGSAccountId		= IST.intCOGSAccountId
			,LIA.intInventoryAccountId	= IST.intInventoryAccountId
		FROM @LineItemAccounts LIA
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId
						 , intItemId
						 , intSalesAccountId 
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intItemId
						 , strType 
					FROM dbo.tblICItem WITH (NOLOCK)
		) ICI ON ARID.intItemId = ICI.intItemId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN @IdsLocal PID ON ARI.intInvoiceId = PID.intId
		LEFT OUTER JOIN (SELECT intItemId
							  , intLocationId
							  , intSalesAccountId
							  , intCOGSAccountId
							  , intInventoryAccountId
						 FROM dbo.vyuARGetItemAccount WITH (NOLOCK)
		) IST ON ARID.intItemId = IST.intItemId
			 AND ARI.intCompanyLocationId = IST.intLocationId
		WHERE ISNULL(ARID.[intItemId], 0) <> 0
		  AND ICI.strType NOT IN ('Non-Inventory', 'Service', 'Other Charge', 'Software')

		--Non-Inventory, Service, Other Charge
		UPDATE LIA
		SET LIA.[intAccountId] = (CASE WHEN ITEM.[strType] IN ('Non-Inventory','Service')
											THEN
											(CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], GENERAL.[intGeneralAccountId]) ELSE GENERAL.[intGeneralAccountId] END)													
									   WHEN ITEM.[strType] = 'Other Charge'
											THEN
											(CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], OTHERCHARGE.[intOtherChargeIncomeAccountId]) ELSE OTHERCHARGE.[intOtherChargeIncomeAccountId] END)
									   ELSE
											(CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END))) 
												ELSE
													ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END)) 
											END)											
									END)
		FROM @LineItemAccounts LIA
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId
						 , intItemId
						 , intSalesAccountId
						 , intConversionAccountId
						 , intServiceChargeAccountId
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType 
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN @IdsLocal PID ON ARI.intInvoiceId = PID.intId
		LEFT JOIN (SELECT intItemId
						, strType
				   FROM dbo.tblICItem WITH (NOLOCK)
		) ITEM ON ARID.intItemId = ITEM.intItemId
		LEFT JOIN (SELECT intItemId
						, intLocationId
						, intItemLocationId 
				   FROM dbo.tblICItemLocation WITH (NOLOCK)
		) ITEMLOCATION ON ITEMLOCATION.intItemId = ARID.intItemId
					  AND ITEMLOCATION.intLocationId = ARI.intCompanyLocationId
					  AND ITEMLOCATION.intLocationId IS NOT NULL
		OUTER APPLY (SELECT ISNULL(dbo.fnGetItemGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'General'), NULLIF(dbo.fnGetItemBaseGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'General'), 0)) AS intGeneralAccountId) GENERAL
		OUTER APPLY (SELECT ISNULL(dbo.fnGetItemGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'Other Charge Income'), NULLIF(dbo.fnGetItemBaseGLAccount(ARID.intItemId, ITEMLOCATION.intItemLocationId, N'Other Charge Income'), 0)) AS intOtherChargeIncomeAccountId) OTHERCHARGE
		WHERE ISNULL(ARID.intItemId, 0) <> 0
		   OR ITEM.strType IN ('Non-Inventory', 'Service', 'Other Charge')

		--Software License
		UPDATE LIA
		SET LIA.intLicenseAccountId = IST.intGeneralAccountId
		FROM
			@LineItemAccounts LIA
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId
						 , intItemId
						 , intSalesAccountId
						 , intConversionAccountId
						 , intServiceChargeAccountId
						 , strMaintenanceType
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intItemId
						 , strType 
					FROM dbo.tblICItem WITH (NOLOCK)
		) ICI ON ARID.intItemId = ICI.intItemId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId 
		INNER JOIN @IdsLocal PID ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN (SELECT intItemId
							  , intLocationId
							  , intGeneralAccountId
							  , intOtherChargeIncomeAccountId
						 FROM dbo.vyuARGetItemAccount WITH (NOLOCK)
		) IST ON ARID.intItemId = IST.intItemId
			 AND ARI.intCompanyLocationId = IST.intLocationId
		WHERE ARID.strMaintenanceType IN ('License/Maintenance', 'License Only')
		  AND ICI.strType = 'Software'

		--Software Maintenance and SaaS
		UPDATE LIA
		SET LIA.intMaintenanceAccountId = IST.intMaintenanceSalesAccountId
		FROM @LineItemAccounts LIA
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId
						 , intItemId
						 , intSalesAccountId
						 , intConversionAccountId
						 , intServiceChargeAccountId
						 , strMaintenanceType
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intItemId
						 , strType
					FROM dbo.tblICItem  WITH (NOLOCK)
		) ICI ON ARID.intItemId = ICI.intItemId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN @IdsLocal PID ON ARI.intInvoiceId = PID.intId
		LEFT OUTER JOIN (SELECT intItemId
							  , intLocationId
							  , intGeneralAccountId
							  , intOtherChargeIncomeAccountId
							  , intMaintenanceSalesAccountId
						 FROM vyuARGetItemAccount WITH (NOLOCK)
		) IST ON ARID.intItemId = IST.intItemId
			 AND ARI.intCompanyLocationId = IST.intLocationId
		WHERE ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ICI.strType = 'Software'					

		--NULL Account Ids
		UPDATE LIA
		SET LIA.intAccountId	= ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)))
		FROM @LineItemAccounts LIA
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId
						 , intItemId
						 , intSalesAccountId
						 , intConversionAccountId
						 , intServiceChargeAccountId
						 , strMaintenanceType
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN @IdsLocal PID ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN (SELECT intItemId
							  , intLocationId
							  , intGeneralAccountId
							  , intOtherChargeIncomeAccountId
							  , intSalesAccountId
						 FROM dbo.vyuARGetItemAccount WITH (NOLOCK)
		) IST ON ARID.intItemId = IST.intItemId
			 AND ARI.intCompanyLocationId = IST.intLocationId
		WHERE ISNULL(LIA.intAccountId, 0) = 0
		
		--NULL Sales Account Ids
		UPDATE LIA
		SET LIA.intSalesAccountId = ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)
		FROM @LineItemAccounts LIA
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId
						 , intItemId
						 , intSalesAccountId
						 , intConversionAccountId
						 , intServiceChargeAccountId
						 , strMaintenanceType
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN @IdsLocal PID ON ARI.intInvoiceId = PID.intId
		LEFT OUTER JOIN (SELECT intItemId
							  , intLocationId
							  , intGeneralAccountId
							  , intOtherChargeIncomeAccountId
							  , intSalesAccountId
						 FROM dbo.vyuARGetItemAccount WITH (NOLOCK)
		) IST ON ARID.intItemId = IST.intItemId
			 AND ARI.intCompanyLocationId = IST.intLocationId
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
		INNER JOIN (SELECT intInvoiceId
						 , intInvoiceDetailId 
					FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
		) ARID ON ARITD.intInvoiceDetailId = ARID.intInvoiceDetailId
		INNER JOIN (SELECT intInvoiceId
						 , intCompanyLocationId
						 , strTransactionType 
					FROM dbo.tblARInvoice WITH (NOLOCK)
		) ARI ON ARID.intInvoiceId = ARI.intInvoiceId
		INNER JOIN @IdsLocal IDS ON ARI.intInvoiceId = IDS.intId
		LEFT OUTER JOIN (SELECT intCompanyLocationId
							  , intProfitCenter
						 FROM dbo.tblSMCompanyLocation WITH (NOLOCK)
		) SMCL ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
					
	END
ELSE
	BEGIN

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
		FROM
			tblSOSalesOrderDetail SOSOD WITH(NOLOCK)
		INNER JOIN
			@IdsLocal PID
				ON SOSOD.[intSalesOrderId] = PID.[intId]

		UPDATE LIA
		SET
			 LIA.[intAccountId]				= IST.[intSalesAccountId]
			,LIA.[intSalesAccountId]		= IST.[intSalesAccountId]
			,LIA.[intCOGSAccountId]			= IST.[intCOGSAccountId]
			,LIA.[intInventoryAccountId]	= IST.[intInventoryAccountId] 
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId], [intItemId] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			(SELECT [intItemId], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON SOSOD.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder  WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@IdsLocal PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intInventoryAccountId], [intSalesAccountId], [intCOGSAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId] 							
		WHERE
			ISNULL(SOSOD.[intItemId], 0) <> 0
			AND ICI.[strType] NOT IN ('Non-Inventory','Service','Other Charge','Software')


		UPDATE LIA
		SET
			LIA.[intAccountId] = (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = SOSOD.[intItemId] AND [strType] IN ('Non-Inventory','Service'))) 
										THEN
											IST.[intGeneralAccountId]													
										WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = SOSOD.[intItemId] AND [strType] = 'Other Charge')) 
										THEN
											IST.[intOtherChargeIncomeAccountId]
										ELSE
											ISNULL(SOSOD.[intSalesAccountId], IST.[intSalesAccountId])
									END)
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId], [intItemId], [intSalesAccountId] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder  WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@IdsLocal PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intOtherChargeIncomeAccountId], [intSalesAccountId], [intGeneralAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]					
		WHERE
			ISNULL(SOSOD.[intItemId], 0) <> 0
			OR (EXISTS(SELECT NULL FROM tblICItem WITH (NOLOCK) WHERE [intItemId] = SOSOD.[intItemId] AND [strType] IN ('Non-Inventory','Service','Other Charge')))


		UPDATE LIA
		SET
			LIA.[intLicenseAccountId] = IST.[intGeneralAccountId]
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId], [intItemId], [intSalesAccountId], [strMaintenanceType] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			(SELECT [intItemId], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON SOSOD.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder  WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@IdsLocal PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intOtherChargeIncomeAccountId], [intSalesAccountId], [intGeneralAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId] 
		WHERE
			SOSOD.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
			AND ICI.[strType] = 'Software'


		UPDATE LIA
		SET
			LIA.[intMaintenanceAccountId] = IST.[intMaintenanceSalesAccountId]
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId], [intItemId], [intSalesAccountId], [strMaintenanceType] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			(SELECT [intItemId], [strType] FROM tblICItem WITH (NOLOCK)) ICI
				ON SOSOD.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder  WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@IdsLocal PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intOtherChargeIncomeAccountId], [intSalesAccountId], [intMaintenanceSalesAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]						
		WHERE
			SOSOD.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ICI.[strType] = 'Software'					


		UPDATE LIA
		SET
			 LIA.[intAccountId]	= ISNULL(SOSOD.[intSalesAccountId], IST.[intSalesAccountId])
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId], [intItemId], [intSalesAccountId], [strMaintenanceType] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 	
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder  WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@IdsLocal PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intOtherChargeIncomeAccountId], [intSalesAccountId], [intMaintenanceSalesAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]				
		LEFT OUTER JOIN
			(SELECT [intCompanyLocationId], [intProfitCenter] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON SO.[intCompanyLocationId] = SMCL.[intCompanyLocationId]	
		WHERE
			ISNULL(LIA.[intAccountId], 0) = 0

			
		UPDATE LIA
		SET
			 LIA.[intSalesAccountId] = ISNULL(SOSOD.[intSalesAccountId], IST.[intSalesAccountId])
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId], [intItemId], [intSalesAccountId], [strMaintenanceType] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 	
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder  WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@IdsLocal PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			(SELECT [intItemId], [intLocationId], [intOtherChargeIncomeAccountId], [intSalesAccountId], [intMaintenanceSalesAccountId] FROM vyuARGetItemAccount WITH (NOLOCK)) IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]	
		LEFT OUTER JOIN
			(SELECT [intCompanyLocationId], [intProfitCenter] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON SO.[intCompanyLocationId] = SMCL.[intCompanyLocationId]	
		WHERE
			ISNULL(LIA.[intSalesAccountId], 0) = 0			
			
			
		UPDATE SOSOD
		SET
			SOSOD.[intAccountId]					= LIA.[intAccountId]
			,SOSOD.[intCOGSAccountId]				= LIA.[intCOGSAccountId]
			,SOSOD.[intSalesAccountId]				= LIA.[intSalesAccountId]
			,SOSOD.[intInventoryAccountId]			= LIA.[intInventoryAccountId]
			,SOSOD.[intLicenseAccountId]			= LIA.[intLicenseAccountId]
			,SOSOD.[intMaintenanceAccountId]		= LIA.[intMaintenanceAccountId]
		FROM 
			(SELECT [intSalesOrderDetailId], [intAccountId], [intCOGSAccountId], [intSalesAccountId], [intInventoryAccountId], [intLicenseAccountId],  [intMaintenanceAccountId] FROM tblSOSalesOrderDetail WITH (NOLOCK)) SOSOD
		INNER JOIN
			@LineItemAccounts LIA
				ON SOSOD.[intSalesOrderDetailId] = LIA.[intDetailId] 	
				
		UPDATE SOSODT
		SET
			SOSODT.[intSalesTaxAccountId] = ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](SOSODT.[intSalesTaxAccountId], SMCL.[intProfitCenter]), SOSODT.[intSalesTaxAccountId])
		FROM
			(SELECT [intSalesTaxAccountId], [intSalesOrderDetailId] FROM tblSOSalesOrderDetailTax WITH (NOLOCK)) SOSODT
		INNER JOIN
			(SELECT [intSalesOrderId], [intSalesOrderDetailId] FROM tblSOSalesOrderDetail) SOSOD
				ON SOSODT.[intSalesOrderDetailId] = SOSOD.[intSalesOrderDetailId]
		INNER JOIN
			(SELECT [intSalesOrderId], [intCompanyLocationId] FROM tblSOSalesOrder WITH (NOLOCK)) SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]
		INNER JOIN
			@IdsLocal IDS
				ON SO.[intSalesOrderId] = IDS.[intId]
		LEFT OUTER JOIN
			(SELECT [intCompanyLocationId], [intProfitCenter] FROM tblSMCompanyLocation WITH (NOLOCK)) SMCL
				ON SO.[intCompanyLocationId] = SMCL.[intCompanyLocationId]	
	END
	 
END

GO
