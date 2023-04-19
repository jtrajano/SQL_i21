CREATE PROCEDURE [dbo].[uspARUpdateTransactionAccountOnPost]
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
	DECLARE  @OverrideCompanySegment					BIT
			,@OverrideLocationSegment					BIT
			,@OverrideLineOfBusinessSegment				BIT
			,@OverrideARAccountLineOfBusinessSegment	BIT

	SELECT TOP 1
		 @OverrideCompanySegment				= ysnOverrideCompanySegment
		,@OverrideLocationSegment				= ysnOverrideLocationSegment
		,@OverrideLineOfBusinessSegment			= ysnOverrideLineOfBusinessSegment
		,@OverrideARAccountLineOfBusinessSegment= ysnOverrideARAccountLineOfBusinessSegment
	FROM dbo.tblARCompanyPreference WITH (NOLOCK)
	
	--AR ACCOUNT	
	UPDATE ARI
	SET ARI.intAccountId = CASE WHEN @OverrideARAccountLineOfBusinessSegment = 1
								THEN ISNULL(dbo.[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, ISNULL(LOB.intSegmentCodeId, 0)), ARI.intAccountId)
								ELSE ARI.intAccountId
							END
	FROM tblARInvoice ARI WITH (NOLOCK)
	INNER JOIN tblARPostInvoiceHeader PID ON ARI.[intInvoiceId] = PID.[intInvoiceId]
	LEFT JOIN tblGLAccount GL ON GL.intAccountId = [dbo].[fnGetGLAccountIdFromProfitCenter](ARI.intAccountId, PID.intProfitCenter)
	OUTER APPLY (
		SELECT TOP 1 intSegmentCodeId
		FROM tblSMLineOfBusiness
		WHERE intLineOfBusinessId = ISNULL(ARI.intLineOfBusinessId, 0)
	) LOB
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
	SET LIA.[intAccountId]			= OVERRIDESEGMENTSALES.intOverrideAccount
	  , LIA.[intSalesAccountId]		= CASE WHEN @OverrideLineOfBusinessSegment  = 1 
										THEN ISNULL(dbo.[fnGetGLAccountIdFromProfitCenter](OVERRIDESEGMENTSALES.intOverrideAccount, ISNULL(LOB.intSegmentCodeId, 0)), OVERRIDESEGMENTSALES.intOverrideAccount)
										ELSE OVERRIDESEGMENTSALES.intOverrideAccount 
									  END
	  , LIA.[intCOGSAccountId]		= CASE WHEN @OverrideLineOfBusinessSegment  = 1 
										THEN ISNULL(dbo.[fnGetGLAccountIdFromProfitCenter](OVERRIDESEGMENTCOGS.intOverrideAccount, ISNULL(LOB.intSegmentCodeId, 0)), OVERRIDESEGMENTCOGS.intOverrideAccount)
										ELSE OVERRIDESEGMENTCOGS.intOverrideAccount 
									  END
	  , LIA.[intInventoryAccountId]	= OVERRIDESEGMENTINVENTORY.intOverrideAccount
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.[intDetailId] = ARID.[intInvoiceDetailId]
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId
	OUTER APPLY (
		SELECT TOP 1 intSegmentCodeId
		FROM tblSMLineOfBusiness
		WHERE intLineOfBusinessId = ISNULL(ARI.intLineOfBusinessId, 0)
	) LOB
	LEFT OUTER JOIN(
		SELECT 
			 [intItemId]
			,[intLocationId]
			,[intItemLocationId] 
		FROM dbo.tblICItemLocation
	) AS ICIL ON ARID.[intItemId] = ICIL.[intItemId] AND ICIL.[intLocationId] IS NOT NULL
	OUTER APPLY (
		SELECT intOverrideAccount
		FROM dbo.[fnARGetOverrideAccount](
			 ARI.[intAccountId]
			,ARID.[intSalesAccountId]
			,@OverrideCompanySegment
			,@OverrideLocationSegment
			,0
		)
	) OVERRIDESEGMENTSALES
	OUTER APPLY (
		SELECT intOverrideAccount
		FROM dbo.[fnARGetOverrideAccount](
			 ARI.[intAccountId]
			,ARID.[intCOGSAccountId]
			,@OverrideCompanySegment
			,@OverrideLocationSegment
			,0
		)
	) OVERRIDESEGMENTCOGS
	OUTER APPLY (
		SELECT intOverrideAccount
		FROM dbo.[fnARGetOverrideAccount](
			 ARI.[intAccountId]
			,ARID.[intInventoryAccountId]
			,0
			,0
			,0
		)
	) OVERRIDESEGMENTINVENTORY
	WHERE ARID.[strItemType] NOT IN ('Non-Inventory', 'Service', 'Other Charge', 'Software')
	  AND ARID.strSessionId = @strSessionId

	--NON-INVENTORY, SERVICE, OTHER CHARGE
	UPDATE LIA
	SET LIA.[intAccountId] = CASE WHEN @OverrideLineOfBusinessSegment  = 1 
								THEN ISNULL(dbo.[fnGetGLAccountIdFromProfitCenter](OVERRIDESEGMENT.intOverrideAccount , ISNULL(LOB.intSegmentCodeId, 0)), OVERRIDESEGMENT.intOverrideAccount)
								ELSE ISNULL(OVERRIDEFREIGHTLOCATION.[intSalesAccountId], OVERRIDESEGMENT.intOverrideAccount)
							 END
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId AND ARID.strSessionId = @strSessionId
	INNER JOIN tblARPostInvoiceItemAccount IA ON ARID.[intItemId] = IA.[intItemId] AND ARID.[intCompanyLocationId] = IA.[intLocationId] AND IA.strSessionId = @strSessionId
	OUTER APPLY (
		SELECT TOP 1 intSegmentCodeId
		FROM tblSMLineOfBusiness
		WHERE intLineOfBusinessId = ISNULL(ARI.intLineOfBusinessId, 0)
	) LOB
	OUTER APPLY (
		SELECT TOP 1 [intSalesAccountId] = dbo.[fnGetGLAccountIdFromProfitCenter](ISNULL(IA.intOtherChargeIncomeAccountId, ARID.[intSalesAccountId]), ISNULL(SMCL.intProfitCenter, 0))
		FROM tblICFreightOverride ICFO
		INNER JOIN (
			SELECT ARPID2.intItemId
			FROM tblARPostInvoiceDetail ARPID1
			CROSS JOIN tblARPostInvoiceDetail ARPID2
			WHERE ARPID1.intLoadDistributionDetailId = ARID.intLoadDistributionDetailId
			AND ARPID2.intLoadDistributionDetailId = ARID.intLoadDistributionDetailId
			AND ARPID1.intItemId = ARID.intItemId
			AND ARPID1.strSessionId = @strSessionId
			AND ARPID2.strSessionId = @strSessionId
			AND ISNULL(ARPID1.intLoadDistributionDetailId, 0) <> 0
		) ITEMFREIGHT 
		ON ICFO.intItemId = ARID.intItemId
		AND ICFO.intFreightOverrideItemId = ITEMFREIGHT.intItemId
		INNER JOIN tblSMCompanyLocation SMCL ON ICFO.intCompanyLocationId = SMCL.intCompanyLocationId
		GROUP BY ICFO.intItemId, ICFO.intFreightOverrideItemId, ICFO.intCompanyLocationId, SMCL.intProfitCenter
	) OVERRIDEFREIGHTLOCATION
	OUTER APPLY (
		SELECT intOverrideAccount
		FROM dbo.[fnARGetOverrideAccount](
			 ARI.[intAccountId]
			,CASE 
				WHEN ARID.[strItemType] = 'Service' THEN CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], IA.[intGeneralAccountId]) ELSE IA.[intGeneralAccountId] END
				WHEN ARID.[strItemType] = 'Non-Inventory' THEN CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], ISNULL(IA.[intSalesAccountId], IA.[intGeneralAccountId])) ELSE ISNULL(IA.[intSalesAccountId], IA.[intGeneralAccountId]) END
				WHEN ARID.[strItemType] = 'Other Charge' THEN CASE WHEN ARID.[strTransactionType] = 'Debit Memo' THEN ISNULL(ARID.[intSalesAccountId], IA.[intOtherChargeIncomeAccountId]) ELSE IA.[intOtherChargeIncomeAccountId] END
				ELSE ISNULL(ARID.[intConversionAccountId], (CASE WHEN ARID.[intServiceChargeAccountId] IS NOT NULL AND ARID.[intServiceChargeAccountId] <> 0 THEN ARID.[intServiceChargeAccountId] ELSE ARID.[intSalesAccountId] END))
			 END
			,@OverrideCompanySegment
			,@OverrideLocationSegment
			,0
		)
	) OVERRIDESEGMENT
	WHERE ARID.[strItemType] IN ('Non-Inventory', 'Service', 'Other Charge')

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
	  AND IST.strSessionId = @strSessionId

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
	  AND IST.strSessionId = @strSessionId

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
	  AND IST.strSessionId = @strSessionId
		
	--NULL SALES ACCOUNT IDS
	UPDATE LIA
	SET LIA.intSalesAccountId = ISNULL(ARID.intSalesAccountId, IST.intSalesAccountId)
	FROM @LineItemAccounts LIA
	INNER JOIN tblARPostInvoiceDetail ARID ON LIA.intDetailId = ARID.intInvoiceDetailId
	INNER JOIN tblARPostInvoiceItemAccount IST ON ARID.[intItemId] = IST.[intItemId]
										AND ARID.intCompanyLocationId = IST.intLocationId
	WHERE ISNULL(LIA.intSalesAccountId, 0) = 0
	  AND ARID.strSessionId = @strSessionId
	  AND IST.strSessionId = @strSessionId
		
	--UPDATE INVOICE DETAIL ACCOUNTS
	UPDATE ARID
	SET 
		 ARID.intAccountId				= LIA.intAccountId
		,ARID.intCOGSAccountId			= LIA.intCOGSAccountId
		,ARID.intSalesAccountId			= LIA.intSalesAccountId
		,ARID.intInventoryAccountId		= LIA.intInventoryAccountId
		,ARID.intServiceChargeAccountId	= ISNULL(ARID.intServiceChargeAccountId ,LIA.intServiceChargeAccountId)
		,ARID.intLicenseAccountId		= LIA.intLicenseAccountId
		,ARID.intMaintenanceAccountId	= LIA.intMaintenanceAccountId
	FROM tblARInvoiceDetail ARID
	INNER JOIN @LineItemAccounts LIA ON ARID.intInvoiceDetailId = LIA.intDetailId

	--UPDATE INVOICE DETAIL ACCOUNTS
	UPDATE ARID
	SET  ARID.intAccountId = (CASE WHEN LIA.[strTransactionType] = 'Debit Memo' 
								   THEN ISNULL(LIA.[intSalesAccountId], ISNULL(LIA.[intConversionAccountId],(CASE WHEN LIA.[intServiceChargeAccountId] IS NOT NULL AND LIA.[intServiceChargeAccountId] <> 0 THEN LIA.[intServiceChargeAccountId] ELSE LIA.[intSalesAccountId] END))) 
                                   ELSE ISNULL(LIA.[intConversionAccountId],(CASE WHEN LIA.[intServiceChargeAccountId] IS NOT NULL AND LIA.[intServiceChargeAccountId] <> 0 THEN LIA.[intServiceChargeAccountId] ELSE LIA.[intSalesAccountId] END)) 
                              END)		
	FROM tblARInvoiceDetail ARID
	INNER JOIN tblARPostInvoiceDetail LIA ON ARID.[intInvoiceDetailId] = LIA.[intInvoiceDetailId] AND LIA.[intItemId] IS NULL
	WHERE LIA.strSessionId = @strSessionId

	--UPDATE INVOICE TAX DETAIL ACCOUNTS
	UPDATE ARITD
	SET ARITD.intSalesTaxAccountId = OVERRIDESEGMENT.intOverrideAccount
	FROM tblARInvoiceDetailTax ARITD
	INNER JOIN tblARPostInvoiceDetail ARID ON ARITD.intInvoiceDetailId = ARID.intInvoiceDetailId
	OUTER APPLY (
		SELECT intOverrideAccount
		FROM dbo.fnARGetOverrideAccount(ARID.intAccountId, ARITD.intSalesTaxAccountId, @OverrideCompanySegment, @OverrideLocationSegment, 0)
	) OVERRIDESEGMENT
	WHERE ARID.strSessionId = @strSessionId
	  AND (@OverrideCompanySegment = 1 OR @OverrideLocationSegment = 1)
	  AND ARID.strType <> 'Tax Adjustment'

    UPDATE PID
    SET  
		 PID.[intItemAccountId]             = ARID.[intAccountId]
        ,PID.[intSalesAccountId]            = ARID.[intSalesAccountId]
        ,PID.[intServiceChargeAccountId]    = ARID.[intServiceChargeAccountId]
        ,PID.[intLicenseAccountId]          = ARID.[intLicenseAccountId]
        ,PID.[intMaintenanceAccountId]      = ARID.[intMaintenanceAccountId]
    FROM tblARPostInvoiceDetail PID
    INNER JOIN tblARInvoiceDetail ARID WITH (NOLOCK) ON PID.intInvoiceDetailId = ARID.intInvoiceDetailId
	WHERE PID.strSessionId = @strSessionId
RETURN 0
