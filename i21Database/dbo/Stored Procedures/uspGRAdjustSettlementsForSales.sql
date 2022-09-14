CREATE PROCEDURE [dbo].[uspGRAdjustSettlementsForSales]
(
	@intUserId INT
	,@intItemId INT
	,@AdjustSettlementsStagingTable AdjustSettlementsStagingTable READONLY
	,@intInvoiceId INT OUTPUT
	,@InvoiceIds NVARCHAR(MAX) OUTPUT
)
AS
BEGIN
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @intCurrencyId INT
	--DECLARE @strTransactionType NVARCHAR(25)
	DECLARE @intFreightItemId INT
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @CreatedInvoices NVARCHAR(MAX)

	SELECT @intCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference

	SELECT @intFreightItemId = FR.intItemId
	FROM tblICItem IC
	OUTER APPLY (
		SELECT TOP 1 intItemId
		FROM tblICItem
		WHERE intCommodityId = IC.intCommodityId
			AND strCostType = 'Freight'
	) FR
	WHERE IC.intItemId = @intItemId

	IF @intFreightItemId IS NULL
	BEGIN
		SELECT TOP 1 @intFreightItemId = intItemId FROM tblICItem WHERE intCommodityId IS NULL AND strCostType = 'Freight'
	END

	INSERT INTO @EntriesForInvoice 
	(
		[strTransactionType]
		,[strType]
		,[strSourceTransaction]
		,[intAccountId]
		,[intSalesAccountId]
		,[intSourceId]
		,[strSourceId]
		,[intInvoiceId]
		,[intEntityCustomerId]
		,[intCompanyLocationId]
		,[intCurrencyId]
		,[intTermId]
		,[dtmDate]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intEntityId]
		,[ysnResetDetails]
		,[intItemId]
		,[ysnInventory]
		,[strItemDescription]
		,[intOrderUOMId]
		,[intItemUOMId]	
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblPrice]
		,[ysnRecomputeTax]
	)
	SELECT 
		[strTransactionType]			= CASE WHEN ADJ.dblAdjustmentAmount < 0 THEN 'Credit Memo' ELSE 'Invoice' END
		,[strType]						= 'Standard'
		,[strSourceTransaction]			= 'Direct'
		,[intAccountId]					= CL.intARAccount
		,[intSalesAccountId]			= ADJ.intGLAccountId
		,[intSourceId]					= NULL
		,[strSourceId]					= ''
		,[intInvoiceId]					= NULL
		,[intEntityCustomerId]			= CASE WHEN ADJ.intSplitId IS NULL THEN ADJ.intEntityId ELSE EM.intEntityId END
		,[intCompanyLocationId]			= ADJ.intCompanyLocationId
		,[intCurrencyId]				= @intCurrencyId
		,[intTermId]					= AR.intTermsId
		,[dtmDate]						= dtmAdjustmentDate
		,[ysnTemplate]					= 0
		,[ysnForgiven]					= 0
		,[ysnCalculated]				= 0
		,[ysnSplitted]					= 0
		,[intEntityId]					= ADJ.intEntityId
		,[ysnResetDetails]				= 0
		,[intItemId]					= CASE WHEN ADJ.intAdjustmentTypeId = 2 THEN @intFreightItemId ELSE NULL END
		,[ysnInventory]					= 0
		,[strItemDescription]			= CASE WHEN ADJ.intAdjustmentTypeId = 2 THEN ICF.strDescription ELSE ADJ.strAdjustSettlementNumber END
		,[intOrderUOMId]				= CASE WHEN ADJ.intAdjustmentTypeId = 2 THEN UOM.intItemUOMId ELSE NULL END
		,[intItemUOMId]					= CASE WHEN ADJ.intAdjustmentTypeId = 2 THEN UOM.intItemUOMId ELSE NULL END
		,[dblQtyOrdered]				= CASE 
											WHEN ADJ.intAdjustmentTypeId = 2 THEN
												CASE 
													WHEN ISNULL(ADJ.dblFreightUnits,0) <> 0 AND ADJ.dblFreightSettlement = ADJ.dblAdjustmentAmount THEN ADJ.dblFreightUnits
													ELSE 1
												END
											ELSE 1 --3 
										END
		,[dblQtyShipped]				= CASE 
											WHEN ADJ.intAdjustmentTypeId = 2 THEN
												CASE 
													WHEN ISNULL(ADJ.dblFreightUnits,0) <> 0 AND ADJ.dblFreightSettlement = ADJ.dblAdjustmentAmount THEN ADJ.dblFreightUnits
													ELSE 1
												END
											ELSE 1 --3 
										END
		,[dblPrice]						= CASE WHEN ADJ.intAdjustmentTypeId = 2 THEN
											CASE 
												WHEN ISNULL(ADJ.dblFreightRate,0) <> 0 AND ADJ.dblFreightSettlement = ADJ.dblAdjustmentAmount THEN ABS(ADJ.dblFreightRate)
												ELSE ABS(ADJ.dblAdjustmentAmount)
											END
											ELSE CASE WHEN ADJ.intSplitId IS NULL THEN ABS(ADJ.dblAdjustmentAmount) ELSE (ABS(ADJ.dblAdjustmentAmount) * (ESD.dblSplitPercent / 100)) END 
										END
		,[ysnRecomputeTax]				= 1
	FROM @AdjustSettlementsStagingTable ADJ
	JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = ADJ.intCompanyLocationId
	LEFT JOIN tblARCustomer AR
		ON AR.intEntityId = ADJ.intEntityId
	LEFT JOIN (
		tblICItem ICF
		INNER JOIN tblICItemUOM UOM
			ON UOM.intItemId = ICF.intItemId
				AND UOM.ysnStockUnit = 1
		)
		ON ICF.intItemId = @intFreightItemId
	LEFT JOIN (
		tblEMEntitySplit ES
		INNER JOIN tblEMEntitySplitDetail ESD
			ON ESD.intSplitId = ES.intSplitId
		INNER JOIN tblEMEntity EM
			ON EM.intEntityId = ESD.intEntityId
	) ON ES.intSplitId = ADJ.intSplitId	

		--SELECT '@EntriesForInvoice',intAccountId,intSalesAccountId,* FROM @EntriesForInvoice

	EXEC [dbo].[uspARProcessInvoices] 
		@InvoiceEntries = @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId = @intUserId
		,@GroupingOption = 0
		,@RaiseError = 1
		,@ErrorMessage = @ErrorMessage OUTPUT
		,@CreatedIvoices = @CreatedInvoices OUTPUT
		
	IF @CreatedInvoices IS NOT NULL
	BEGIN
		IF @CreatedInvoices NOT LIKE '%,%'
		BEGIN
			SELECT @intInvoiceId = intID FROM fnGetRowsFromDelimitedValues(@CreatedInvoices)
		END
		ELSE
		BEGIN
			INSERT INTO tblGRAdjustSettlementsSplit
			(
				intAdjustSettlementId
				,intBillId
			)
			SELECT intAdjustSettlementId
				,AR.value
			FROM @AdjustSettlementsStagingTable A
			OUTER APPLY (
				SELECT * FROM dbo.fnCommaSeparatedValueToTable(@CreatedInvoices)
			) AR

			SET @InvoiceIds = @CreatedInvoices
		END
	END

	

	RETURN;
END