CREATE PROCEDURE [dbo].[uspARUpdateTransactionAccountOnPost]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


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

		
	UPDATE ARI
	SET
		ARI.intAccountId = ISNULL([dbo].[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, PID.intProfitCenter), ARI.intAccountId)
	FROM
		tblARInvoice ARI WITH (NOLOCK)
	INNER JOIN
		#ARPostInvoiceHeader PID 
			ON ARI.[intInvoiceId] = PID.[intInvoiceId]

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
		,[intItemAccountId]
		,[intCOGSAccountId]
		,[intSalesAccountId]
		,[intInventoryAccountId]
		,[intServiceChargeAccountId]
		,[intLicenseAccountId]
		,[intMaintenanceAccountId]
	FROM 
		#ARPostInvoiceDetail

	--NOT IN Non-Inventory, Service, Other Charge, Software
	UPDATE LIA
	SET  LIA.[intAccountId]			= IA.[intSalesAccountId]
		,LIA.[intSalesAccountId]		= CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ARID.[intSalesAccountId] ELSE IA.[intSalesAccountId] END
		,LIA.[intCOGSAccountId]		= IA.[intCOGSAccountId]
		,LIA.[intInventoryAccountId]	= IA.[intInventoryAccountId]
	FROM
		@LineItemAccounts LIA
	INNER JOIN
		#ARPostInvoiceDetail ARID 
			ON LIA.[intDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN
		#ARInvoiceItemAccount IA
			ON ARID.[intItemId] = IA.[intItemId]
			AND ARID.[intCompanyLocationId] = IA.[intLocationId]
	WHERE
        ARID.[strItemType] NOT IN ('Non-Inventory', 'Service', 'Other Charge', 'Software')

	--Non-Inventory, Service, Other Charge
	UPDATE LIA
	SET LIA.[intAccountId] = (CASE WHEN ARID.[strItemType] IN ('Non-Inventory','Service')
										THEN
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], GENERAL.[intGeneralAccountId]) ELSE GENERAL.[intGeneralAccountId] END)													
									WHEN ARID.[strItemType] = 'Other Charge'
										THEN
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], OTHERCHARGE.[intOtherChargeIncomeAccountId]) ELSE OTHERCHARGE.[intOtherChargeIncomeAccountId] END)
									ELSE
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END))) 
											ELSE
												ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END)) 
										END)											
								END)
	FROM 
		@LineItemAccounts LIA
	INNER JOIN 
		#ARPostInvoiceDetail ARID 
			ON LIA.intDetailId = ARID.intInvoiceDetailId
	OUTER APPLY (SELECT ISNULL(dbo.fnGetItemGLAccount(ARID.intItemId, ARID.intItemLocationId, N'General'), NULLIF(dbo.fnGetItemBaseGLAccount(ARID.intItemId, ARID.intItemLocationId, N'General'), 0)) AS intGeneralAccountId) GENERAL
	OUTER APPLY (SELECT ISNULL(dbo.fnGetItemGLAccount(ARID.intItemId, ARID.intItemLocationId, N'Other Charge Income'), NULLIF(dbo.fnGetItemBaseGLAccount(ARID.intItemId, ARID.intItemLocationId, N'Other Charge Income'), 0)) AS intOtherChargeIncomeAccountId) OTHERCHARGE
	WHERE
        ARID.[strItemType] IN ('Non-Inventory', 'Service', 'Other Charge')

	UPDATE LIA
	SET LIA.[intSalesAccountId] = LIA.[intAccountId]
	FROM 
		@LineItemAccounts LIA
	INNER JOIN 
		#ARPostInvoiceDetail ARID 
			ON LIA.intDetailId = ARID.intInvoiceDetailId
	WHERE
        ARID.[strItemType] IN ('Non-Inventory', 'Service', 'Other Charge')

	--Software License
	UPDATE LIA
	SET LIA.intLicenseAccountId = IST.intGeneralAccountId
	FROM 
		@LineItemAccounts LIA
	INNER JOIN
		#ARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN
		#ARInvoiceItemAccount IST 
			ON ARID.intItemId = IST.intItemId
			AND ARID.[intCompanyLocationId] = IST.[intLocationId]
	WHERE
        ARID.strMaintenanceType IN ('License/Maintenance', 'License Only')
        AND ARID.strItemType = 'Software'

	--Software Maintenance and SaaS
	UPDATE LIA
	SET LIA.intMaintenanceAccountId = IST.intMaintenanceSalesAccountId
	FROM
		@LineItemAccounts LIA
	INNER JOIN
		#ARPostInvoiceDetail ARID 
			ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN
		#ARInvoiceItemAccount IST 
			ON ARID.intItemId = IST.intItemId
			AND ARID.[intCompanyLocationId] = IST.[intLocationId]
	WHERE
        ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
		AND ARID.strItemType = 'Software'					

	--NULL Account Ids
	UPDATE LIA
	SET LIA.intAccountId	= CASE WHEN ISNULL(ARID.intItemId, 0) <> 0
									THEN ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)))
									ELSE ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, ARID.[intLocationSalesAccountId])))
								END
	FROM
		@LineItemAccounts LIA
	INNER JOIN
		#ARPostInvoiceDetail ARID
			ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN
		#ARInvoiceItemAccount IST
			ON ARID.[intItemId] = IST.[intItemId]
			AND ARID.intCompanyLocationId = IST.intLocationId
	WHERE
        ISNULL(LIA.intAccountId, 0) = 0
		
	--NULL Sales Account Ids
	UPDATE LIA
	SET LIA.intSalesAccountId = ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)
	FROM
		@LineItemAccounts LIA
	INNER JOIN
		#ARPostInvoiceDetail ARID
			ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN
		#ARInvoiceItemAccount IST
			ON ARID.[intItemId] = IST.[intItemId]
			AND ARID.intCompanyLocationId = IST.intLocationId
	WHERE
        ISNULL(LIA.intSalesAccountId, 0) = 0			
		
	--Update Invoice Detail
	UPDATE ARID
	SET  ARID.intAccountId					= LIA.intAccountId
		,ARID.intCOGSAccountId				= LIA.intCOGSAccountId
		,ARID.intSalesAccountId				= LIA.intSalesAccountId
		,ARID.intInventoryAccountId			= LIA.intInventoryAccountId
		,ARID.intServiceChargeAccountId		= ISNULL(ARID.intServiceChargeAccountId ,LIA.intServiceChargeAccountId)
		,ARID.intLicenseAccountId			= LIA.intLicenseAccountId
		,ARID.intMaintenanceAccountId		= LIA.intMaintenanceAccountId
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
        @LineItemAccounts LIA
			ON ARID.intInvoiceDetailId = LIA.intDetailId

	--Update Invoice Detail
	UPDATE ARID
	SET  ARID.intAccountId = (CASE WHEN LIA.[strTransactionType] = 'Debit Memo' 
								   THEN ISNULL(LIA.[intSalesAccountId], ISNULL(LIA.[intConversionAccountId],(CASE WHEN LIA.[intServiceChargeAccountId] IS NOT NULL AND LIA.[intServiceChargeAccountId] <> 0 THEN LIA.[intServiceChargeAccountId] ELSE LIA.[intSalesAccountId] END))) 
                                   ELSE ISNULL(LIA.[intConversionAccountId],(CASE WHEN LIA.[intServiceChargeAccountId] IS NOT NULL AND LIA.[intServiceChargeAccountId] <> 0 THEN LIA.[intServiceChargeAccountId] ELSE LIA.[intSalesAccountId] END)) 
                              END)		
	FROM
		tblARInvoiceDetail ARID
	INNER JOIN
        #ARPostInvoiceDetail LIA
			ON ARID.[intInvoiceDetailId] = LIA.[intInvoiceDetailId]
			AND LIA.[intItemId] IS NULL


	--Update Invoice Tax Detail
	UPDATE ARITD
	SET ARITD.intSalesTaxAccountId = ISNULL(dbo.fnGetGLAccountIdFromProfitCenter(ARITD.intSalesTaxAccountId, ARID.intProfitCenter), ARITD.intSalesTaxAccountId)
	FROM
		tblARInvoiceDetailTax ARITD
	INNER JOIN
		#ARPostInvoiceDetail ARID
			ON ARITD.intInvoiceDetailId = ARID.intInvoiceDetailId


    UPDATE PID
    SET  PID.[intItemAccountId]             = ARID.[intAccountId]
        ,PID.[intSalesAccountId]            = ARID.[intSalesAccountId]
        ,PID.[intServiceChargeAccountId]    = ARID.[intServiceChargeAccountId]
        ,PID.[intLicenseAccountId]          = ARID.[intLicenseAccountId]
        ,PID.[intMaintenanceAccountId]      = ARID.[intMaintenanceAccountId]
    FROM 
        #ARPostInvoiceDetail PID
    INNER JOIN
        tblARInvoiceDetail ARID
            ON PID.intInvoiceDetailId = ARID.intInvoiceDetailId


RETURN 0
