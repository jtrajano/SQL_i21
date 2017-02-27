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
SET @ZeroDecimal = 0.000000	

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
			tblARInvoiceDetail ARID
		INNER JOIN
			@Ids PID
				ON ARID.[intInvoiceId] = PID.[intId]


		UPDATE LIA
		SET
			 LIA.[intAccountId]				= IST.[intSalesAccountId]
			,LIA.[intSalesAccountId]		= CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ARID.[intSalesAccountId] ELSE IST.[intSalesAccountId] END
			,LIA.[intCOGSAccountId]			= IST.[intCOGSAccountId]
			,LIA.[intInventoryAccountId]	= IST.[intInventoryAccountId] 
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblARInvoiceDetail ARID
				ON LIA.[intDetailId] = ARID.[intInvoiceDetailId] 
		INNER JOIN
			tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
		INNER JOIN 
			@Ids PID
				ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON ARID.[intItemId] = IST.[intItemId]
				AND ARI.[intCompanyLocationId] = IST.[intLocationId] 							
		WHERE
			ISNULL(ARID.[intItemId], 0) <> 0
			AND ICI.[strType] NOT IN ('Non-Inventory','Service','Other Charge','Software')


		UPDATE LIA
		SET
			LIA.[intAccountId] = (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = ARID.[intItemId] AND [strType] IN ('Non-Inventory','Service'))) 
										THEN
											(CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId],IST.[intGeneralAccountId]) ELSE IST.[intGeneralAccountId] END)													
										WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = ARID.[intItemId] AND [strType] = 'Other Charge')) 
										THEN
											(CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId],IST.[intOtherChargeIncomeAccountId]) ELSE IST.[intOtherChargeIncomeAccountId] END)
										ELSE
											(CASE WHEN ARI.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END))) 
												ELSE
													ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END)) 
											END)											
									END)
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblARInvoiceDetail ARID
				ON LIA.[intDetailId] = ARID.[intInvoiceDetailId]
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
		INNER JOIN 
			@Ids PID
				ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON ARID.[intItemId] = IST.[intItemId] 
				AND ARI.[intCompanyLocationId] = IST.[intLocationId]					
		WHERE
			ISNULL(ARID.[intItemId], 0) <> 0
			OR (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = ARID.[intItemId] AND [strType] IN ('Non-Inventory','Service','Other Charge')))


		UPDATE LIA
		SET
			LIA.[intLicenseAccountId] = IST.[intGeneralAccountId]
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblARInvoiceDetail ARID
				ON LIA.[intDetailId] = ARID.[intInvoiceDetailId] 
		INNER JOIN
			tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
		INNER JOIN 
			@Ids PID
				ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON ARID.[intItemId] = IST.[intItemId]
				AND ARI.[intCompanyLocationId] = IST.[intLocationId] 
		WHERE
			ARID.[strMaintenanceType] IN ('License/Maintenance', 'License Only')
			AND ICI.[strType] = 'Software'


		UPDATE LIA
		SET
			LIA.[intMaintenanceAccountId] = IST.[intMaintenanceSalesAccountId]
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblARInvoiceDetail ARID
				ON LIA.[intDetailId] = ARID.[intInvoiceDetailId] 
		INNER JOIN
			tblICItem ICI
				ON ARID.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
		INNER JOIN 
			@Ids PID
				ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON ARID.[intItemId] = IST.[intItemId]
				AND ARI.[intCompanyLocationId] = IST.[intLocationId]						
		WHERE
			ARID.[strMaintenanceType] IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
			AND ICI.[strType] = 'Software'					


		UPDATE LIA
		SET
			 LIA.[intAccountId]	= ISNULL(ARID.[intServiceChargeAccountId], ISNULL(ARID.[intConversionAccountId], ISNULL(ARID.intSalesAccountId, IST.[intSalesAccountId])))
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblARInvoiceDetail ARID
				ON LIA.[intDetailId] = ARID.[intInvoiceDetailId] 			
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
		INNER JOIN 
			@Ids PID
				ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON ARID.[intItemId] = IST.[intItemId]
				AND ARI.[intCompanyLocationId] = IST.[intLocationId]							
		WHERE
			ISNULL(LIA.[intAccountId], 0) = 0
			
		UPDATE LIA
		SET
			 LIA.[intSalesAccountId] = ISNULL(ARID.intSalesAccountId, IST.[intSalesAccountId])
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblARInvoiceDetail ARID
				ON LIA.[intDetailId] = ARID.[intInvoiceDetailId] 			
		INNER JOIN
			tblARInvoice ARI
				ON ARID.[intInvoiceId] = ARI.[intInvoiceId] 
		INNER JOIN 
			@Ids PID
				ON ARI.[intInvoiceId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON ARID.[intItemId] = IST.[intItemId]
				AND ARI.[intCompanyLocationId] = IST.[intLocationId]					
		WHERE
			ISNULL(LIA.[intSalesAccountId], 0) = 0			
			
			
		UPDATE ARID
		SET
			ARID.[intAccountId]					= LIA.[intAccountId]
			,ARID.[intCOGSAccountId]			= LIA.[intCOGSAccountId]
			,ARID.[intSalesAccountId]			= LIA.[intSalesAccountId]
			,ARID.[intInventoryAccountId]		= LIA.[intInventoryAccountId]
			,ARID.[intServiceChargeAccountId]	= ISNULL(ARID.[intServiceChargeAccountId] ,LIA.[intServiceChargeAccountId])
			,ARID.[intLicenseAccountId]			= LIA.[intLicenseAccountId]
			,ARID.[intMaintenanceAccountId]		= LIA.[intMaintenanceAccountId]
		FROM 
			tblARInvoiceDetail ARID
		INNER JOIN
			@LineItemAccounts LIA
				ON ARID.[intInvoiceDetailId] = LIA.[intDetailId] 
					
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
			tblSOSalesOrderDetail SOSOD
		INNER JOIN
			@Ids PID
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
			tblSOSalesOrderDetail SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			tblICItem ICI
				ON SOSOD.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@Ids PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
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
			tblSOSalesOrderDetail SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@Ids PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]					
		WHERE
			ISNULL(SOSOD.[intItemId], 0) <> 0
			OR (EXISTS(SELECT NULL FROM tblICItem WHERE [intItemId] = SOSOD.[intItemId] AND [strType] IN ('Non-Inventory','Service','Other Charge')))


		UPDATE LIA
		SET
			LIA.[intLicenseAccountId] = IST.[intGeneralAccountId]
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblSOSalesOrderDetail SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			tblICItem ICI
				ON SOSOD.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@Ids PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
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
			tblSOSalesOrderDetail SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 
		INNER JOIN
			tblICItem ICI
				ON SOSOD.[intItemId] = ICI.[intItemId] 				
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@Ids PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
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
			tblSOSalesOrderDetail SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 	
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@Ids PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]					
		WHERE
			ISNULL(LIA.[intAccountId], 0) = 0

			
		UPDATE LIA
		SET
			 LIA.[intSalesAccountId] = ISNULL(SOSOD.[intSalesAccountId], IST.[intSalesAccountId])
		FROM
			@LineItemAccounts LIA
		INNER JOIN
			tblSOSalesOrderDetail SOSOD
				ON LIA.[intDetailId] = SOSOD.[intSalesOrderDetailId] 	
		INNER JOIN
			tblSOSalesOrder SO
				ON SOSOD.[intSalesOrderId] = SO.[intSalesOrderId]  
		INNER JOIN 
			@Ids PID
				ON SO.[intSalesOrderId] = PID.[intId]
		LEFT OUTER JOIN
			vyuARGetItemAccount IST
				ON SOSOD.[intItemId] = IST.[intItemId] 
				AND SO.[intCompanyLocationId] = IST.[intLocationId]							
		WHERE
			ISNULL(LIA.[intSalesAccountId], 0) = 0			
			
			
		UPDATE SOSOD
		SET
			SOSOD.[intAccountId]					= LIA.[intAccountId]
			,SOSOD.[intCOGSAccountId]			= LIA.[intCOGSAccountId]
			,SOSOD.[intSalesAccountId]			= LIA.[intSalesAccountId]
			,SOSOD.[intInventoryAccountId]		= LIA.[intInventoryAccountId]
			,SOSOD.[intLicenseAccountId]			= LIA.[intLicenseAccountId]
			,SOSOD.[intMaintenanceAccountId]		= LIA.[intMaintenanceAccountId]
		FROM 
			tblSOSalesOrderDetail SOSOD
		INNER JOIN
			@LineItemAccounts LIA
				ON SOSOD.[intSalesOrderDetailId] = LIA.[intDetailId] 	
	
	END
	 
END

GO