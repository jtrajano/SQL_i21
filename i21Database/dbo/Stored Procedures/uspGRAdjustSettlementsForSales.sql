CREATE PROCEDURE [dbo].[uspGRAdjustSettlementsForSales]
(
	@intUserId INT
	,@intItemId INT
	,@intAdjustmentTypeId INT
	,@ysnTransferSettlement BIT
	,@AdjustSettlementsStagingTable AdjustSettlementsStagingTable READONLY
	,@intInvoiceId INT OUTPUT
)
AS
BEGIN
	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable
	DECLARE @intCurrencyId INT
	DECLARE @strTransactionType NVARCHAR(25)
	DECLARE @intFreightItemId INT
	DECLARE @ErrorMessage NVARCHAR(MAX)
	DECLARE @CreatedInvoices NVARCHAR(MAX)

	SELECT @intCurrencyId = intDefaultCurrencyId FROM tblSMCompanyPreference
	
	SET @strTransactionType = CASE 
								WHEN @intAdjustmentTypeId = 2 OR (@intAdjustmentTypeId = 3 AND @ysnTransferSettlement = 0) THEN 'Invoice'
								ELSE 'Credit Memo'
							END

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
		[strTransactionType]			= @strTransactionType
		,[strType]						= 'Standard'
		,[strSourceTransaction]			= 'Direct'
		,[intAccountId]					= intGLAccountId
		,[intSourceId]					= NULL
		,[strSourceId]					= ''
		,[intInvoiceId]					= NULL
		,[intEntityCustomerId]			= ADJ.intEntityId
		,[intCompanyLocationId]			= intCompanyLocationId
		,[intCurrencyId]				= @intCurrencyId
		,[intTermId]					= AR.intTermsId
		,[dtmDate]						= dtmAdjustmentDate
		,[ysnTemplate]					= 0
		,[ysnForgiven]					= 0
		,[ysnCalculated]				= 0
		,[ysnSplitted]					= 0
		,[intEntityId]					= ADJ.intEntityId
		,[ysnResetDetails]				= 0
		,[intItemId]					= CASE WHEN @intAdjustmentTypeId = 2 THEN @intFreightItemId ELSE NULL END
		,[ysnInventory]					= 0
		,[strItemDescription]			= CASE WHEN @intAdjustmentTypeId = 2 THEN ICF.strDescription ELSE ADJ.strAdjustSettlementNumber END
		,[intOrderUOMId]				= CASE WHEN @intAdjustmentTypeId = 2 THEN UOM.intItemUOMId ELSE NULL END
		,[intItemUOMId]					= CASE WHEN @intAdjustmentTypeId = 2 THEN UOM.intItemUOMId ELSE NULL END
		,[dblQtyOrdered]				= CASE WHEN @intAdjustmentTypeId = 2 THEN ADJ.dblFreightUnits ELSE 1 END
		,[dblQtyShipped]				= CASE WHEN @intAdjustmentTypeId = 2 THEN ADJ.dblFreightUnits ELSE 1 END
		,[dblPrice]						= CASE WHEN @intAdjustmentTypeId = 2 THEN ADJ.dblFreightRate ELSE ABS(dblAdjustmentAmount) END
		,[ysnRecomputeTax]				= 1
	FROM @AdjustSettlementsStagingTable ADJ
	LEFT JOIN tblARCustomer AR
		ON AR.intEntityId = ADJ.intEntityId
	LEFT JOIN (
		tblICItem ICF
		INNER JOIN tblICItemUOM UOM
			ON UOM.intItemId = ICF.intItemId
				AND UOM.ysnStockUnit = 1
		)
		ON ICF.intItemId = @intFreightItemId

		--SELECT '@EntriesForInvoice',* FROM @EntriesForInvoice

	EXEC [dbo].[uspARProcessInvoices] 
		@InvoiceEntries = @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId = @intUserId
		,@GroupingOption = 0
		,@RaiseError = 1
		,@ErrorMessage = @ErrorMessage OUTPUT
		,@CreatedIvoices = @CreatedInvoices OUTPUT

	SELECT @intInvoiceId = intID FROM fnGetRowsFromDelimitedValues(@CreatedInvoices)

	RETURN;
END