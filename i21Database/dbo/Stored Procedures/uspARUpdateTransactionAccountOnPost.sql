﻿CREATE PROCEDURE [dbo].[uspARUpdateTransactionAccountOnPost]
	@strSessionId		NVARCHAR(50) = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE @LineItemAccounts AS TABLE (
		 [intDetailId]					INT
		,[intAccountId]					INT
		,[intCOGSAccountId]				INT
		,[intSalesAccountId]			INT
		,[intInventoryAccountId]		INT
		,[intServiceChargeAccountId]	INT
		,[intLicenseAccountId]			INT
		,[intMaintenanceAccountId]		INT
	)
	
	--AR ACCOUNT	
	UPDATE ARI
	SET ARI.intAccountId = CASE WHEN [dbo].[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, PID.intProfitCenter) IS NOT NULL AND ISNULL(GL.ysnActive, 0) = 1
								THEN [dbo].[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, PID.intProfitCenter)
								ELSE ARI.intAccountId
							END
	FROM tblARInvoice ARI WITH (NOLOCK)
	INNER JOIN tblARPostInvoiceHeader PID ON ARI.[intInvoiceId] = PID.[intInvoiceId]
	LEFT JOIN tblGLAccount GL ON GL.intAccountId = [dbo].[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, PID.intProfitCenter)
	WHERE PID.strSessionId = @strSessionId

	INSERT INTO @LineItemAccounts (
		  [intDetailId]
		, [intAccountId]
		, [intCOGSAccountId]
		, [intSalesAccountId]
		, [intInventoryAccountId]
		, [intServiceChargeAccountId]
		, [intLicenseAccountId]
		, [intMaintenanceAccountId]
	)
	SELECT [intInvoiceDetailId]
		, [intItemAccountId]
		, [intCOGSAccountId]
		, [intSalesAccountId]
		, [intInventoryAccountId]
		, [intServiceChargeAccountId]
		, [intLicenseAccountId]
		, [intMaintenanceAccountId]
	FROM tblARPostInvoiceDetail
	WHERE strSessionId = @strSessionId

	--INVENTORY
	UPDATE LIA
	SET LIA.[intAccountId]			= IA.[intSalesAccountId]
	  , LIA.[intSalesAccountId]		= CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ARID.[intSalesAccountId] ELSE IA.[intSalesAccountId] END
	  , LIA.[intCOGSAccountId]		= IA.[intCOGSAccountId]
	  , LIA.[intInventoryAccountId]	= IA.[intInventoryAccountId]
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.[intDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN tblARPostInvoiceItemAccount IA ON ARID.[intItemId] = IA.[intItemId]
									   AND ARID.[intCompanyLocationId] = IA.[intLocationId]
	WHERE ARID.[strItemType] NOT IN ('Non-Inventory', 'Service', 'Other Charge', 'Software')
	  AND ARID.strSessionId = @strSessionId

	--NON-INVENTORY, SERVICE, OTHER CHARGE
	UPDATE LIA
	SET LIA.[intAccountId] = (CASE WHEN ARID.[strItemType] = 'Service'
										THEN
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], IA.[intGeneralAccountId]) ELSE IA.[intGeneralAccountId] END)
									WHEN ARID.[strItemType] = 'Non-Inventory'
										THEN
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(IA.[intSalesAccountId], IA.[intGeneralAccountId])) ELSE ISNULL(IA.[intSalesAccountId], IA.[intGeneralAccountId]) END)
									WHEN ARID.[strItemType] = 'Other Charge'
										THEN
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], IA.[intOtherChargeIncomeAccountId]) ELSE IA.[intOtherChargeIncomeAccountId] END)
									ELSE
										(CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END))) 
											ELSE
												ISNULL(ARID.[intConversionAccountId],(CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END)) 
										END)											
								END)
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId	
	INNER JOIN tblARPostInvoiceItemAccount IA ON ARID.[intItemId] = IA.[intItemId]
									   AND ARID.[intCompanyLocationId] = IA.[intLocationId]
	WHERE ARID.[strItemType] IN ('Non-Inventory', 'Service', 'Other Charge')
	  AND ARID.strSessionId = @strSessionId

	UPDATE LIA
	SET LIA.[intSalesAccountId] = LIA.[intAccountId]
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	WHERE ARID.[strItemType] IN ('Non-Inventory', 'Service', 'Other Charge')
	  AND ARID.strSessionId = @strSessionId

	--SOFTWARE (LICENSE)
	UPDATE LIA
	SET LIA.intLicenseAccountId = IST.intGeneralAccountId
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN tblARPostInvoiceItemAccount IST ON ARID.intItemId = IST.intItemId
										AND ARID.[intCompanyLocationId] = IST.[intLocationId]
	WHERE ARID.strMaintenanceType IN ('License/Maintenance', 'License Only')
	  AND ARID.strItemType = 'Software'
	  AND ARID.strSessionId = @strSessionId

	--SOFTWARE (MAINTENANCE AND SAAS)
	UPDATE LIA
	SET LIA.intMaintenanceAccountId = IST.intMaintenanceSalesAccountId
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN tblARPostInvoiceItemAccount IST ON ARID.intItemId = IST.intItemId
										AND ARID.[intCompanyLocationId] = IST.[intLocationId]
	WHERE ARID.strMaintenanceType IN ('License/Maintenance', 'Maintenance Only', 'SaaS')
	  AND ARID.strItemType = 'Software'
	  AND ARID.strSessionId = @strSessionId

	--NULL ACCOUNT IDS
	UPDATE LIA
	SET LIA.intAccountId = CASE WHEN ISNULL(ARID.intItemId, 0) <> 0
								THEN ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)))
								ELSE ISNULL(ARID.intServiceChargeAccountId, ISNULL(ARID.intConversionAccountId, ISNULL(ARID.intSalesAccountId, ARID.[intLocationSalesAccountId])))
						   END
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN tblARPostInvoiceItemAccount IST ON ARID.[intItemId] = IST.[intItemId]
									    AND ARID.intCompanyLocationId = IST.intLocationId
	WHERE ISNULL(LIA.intAccountId, 0) = 0
	  AND ARID.strSessionId = @strSessionId
		
	--NULL SALES ACCOUNT IDS
	UPDATE LIA
	SET LIA.intSalesAccountId = ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN tblARPostInvoiceItemAccount IST ON ARID.[intItemId] = IST.[intItemId]
										AND ARID.intCompanyLocationId = IST.intLocationId
	WHERE ISNULL(LIA.intSalesAccountId, 0) = 0
	  AND ARID.strSessionId = @strSessionId
		
	--UPDATE INVOICE DETAIL ACCOUNTS
	UPDATE ARID
	SET ARID.intAccountId					= LIA.intAccountId
	  , ARID.intCOGSAccountId				= LIA.intCOGSAccountId
	  , ARID.intSalesAccountId				= LIA.intSalesAccountId
	  , ARID.intInventoryAccountId			= LIA.intInventoryAccountId
	  , ARID.intServiceChargeAccountId		= ISNULL(ARID.intServiceChargeAccountId ,LIA.intServiceChargeAccountId)
	  , ARID.intLicenseAccountId			= LIA.intLicenseAccountId
	  , ARID.intMaintenanceAccountId		= LIA.intMaintenanceAccountId
	FROM tblARInvoiceDetail ARID
	INNER JOIN @LineItemAccounts LIA ON ARID.intInvoiceDetailId = LIA.intDetailId

	--UPDATE INVOICE DETAIL ACCOUNTS
	UPDATE ARID
	SET  ARID.intAccountId = (CASE WHEN LIA.[strTransactionType] = 'Debit Memo' 
								   THEN ISNULL(LIA.[intSalesAccountId], ISNULL(LIA.[intConversionAccountId],(CASE WHEN LIA.[intServiceChargeAccountId] IS NOT NULL AND LIA.[intServiceChargeAccountId] <> 0 THEN LIA.[intServiceChargeAccountId] ELSE LIA.[intSalesAccountId] END))) 
                                   ELSE ISNULL(LIA.[intConversionAccountId],(CASE WHEN LIA.[intServiceChargeAccountId] IS NOT NULL AND LIA.[intServiceChargeAccountId] <> 0 THEN LIA.[intServiceChargeAccountId] ELSE LIA.[intSalesAccountId] END)) 
                              END)		
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARPostInvoiceDetail LIA ON ARID.[intInvoiceDetailId] = LIA.[intInvoiceDetailId]
									   AND LIA.[intItemId] IS NULL

	--UPDATE INVOICE TAX DETAIL ACCOUNTS
	UPDATE ARITD
	SET ARITD.intSalesTaxAccountId = ISNULL(dbo.fnGetGLAccountIdFromProfitCenter(ARITD.intSalesTaxAccountId, ARID.intProfitCenter), ARITD.intSalesTaxAccountId)
	FROM tblARInvoiceDetailTax ARITD
	INNER JOIN tblARPostInvoiceDetail ARID ON ARITD.intInvoiceDetailId = ARID.intInvoiceDetailId
	WHERE ARID.strSessionId = @strSessionId

	--UPDATE FINAL
	UPDATE PIH
	SET PIH.intAccountId	= ARI.intAccountId
	FROM tblARPostInvoiceHeader PIH
	INNER JOIN tblARInvoice ARI ON PIH.intInvoiceId = ARI.intInvoiceId
	WHERE PIH.strSessionId = @strSessionId	  

    UPDATE PID
    SET  PID.[intItemAccountId]             = ARID.[intAccountId]
        ,PID.[intSalesAccountId]            = ARID.[intSalesAccountId]
        ,PID.[intServiceChargeAccountId]    = ARID.[intServiceChargeAccountId]
        ,PID.[intLicenseAccountId]          = ARID.[intLicenseAccountId]
        ,PID.[intMaintenanceAccountId]      = ARID.[intMaintenanceAccountId]
    FROM tblARPostInvoiceDetail PID
    INNER JOIN tblARInvoiceDetail ARID ON PID.intInvoiceDetailId = ARID.intInvoiceDetailId
	WHERE PID.strSessionId = @strSessionId
RETURN 0
