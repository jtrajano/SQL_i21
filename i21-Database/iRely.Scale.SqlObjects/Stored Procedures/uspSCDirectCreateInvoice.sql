CREATE PROCEDURE [dbo].[uspSCDirectCreateInvoice]
	@intTicketId INT,
	@intEntityId INT,
	@intLocationId INT,
	@intUserId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;
DECLARE @InventoryReceiptId AS INT; 
DECLARE @ErrMsg NVARCHAR(MAX);
DECLARE @ItemsToIncreaseInTransitDirect AS InTransitTableType
		,@invoiceIntegrationStagingTable AS InvoiceIntegrationStagingTable
		,@success INT
		,@intFreightTermId INT
		,@intShipToId INT
		,@CreatedInvoices NVARCHAR(MAX)
		,@UpdatedInvoices NVARCHAR(MAX)
		,@successfulCount INT
		,@invalidCount INT
		,@batchIdUsed NVARCHAR(100)
		,@recapId INT
		,@recCount INT
		,@invoiceId INT

BEGIN TRY
	--FOR LINE ITEM
	INSERT INTO @invoiceIntegrationStagingTable (
		[strTransactionType]
		,[strType]
		,[strSourceTransaction]
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
		,[strItemDescription]
		,[intOrderUOMId]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[intTaxGroupId]
		,[ysnRecomputeTax]
		,[intContractDetailId]
		,[intTicketId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]		
	)
	SELECT 
		[strTransactionType] = 'Invoice'
		,[strType] = 'Standard'
		,[strSourceTransaction] = 'Ticket Management'
		,[intSourceId] = SC.intTicketId
		,[strSourceId] = ''
		,[intInvoiceId] = NULL --NULL Value will create new invoice
		,[intEntityCustomerId] = @intEntityId
		,[intCompanyLocationId] = SC.intProcessingLocationId
		,[intCurrencyId] = SC.intCurrencyId
		,[intTermId] = EM.intTermsId
		,[dtmDate] = SC.dtmTicketDateTime
		,[ysnTemplate] = 0
		,[ysnForgiven] = 0
		,[ysnCalculated] = 0
		,[ysnSplitted] = 0
		,[intEntityId] = @intUserId
		,[ysnResetDetails] = 0
		,[intItemId] = SC.intItemId
		,[strItemDescription] = ICI.strItemNo
		,[intOrderUOMId]= NULL
		,[intItemUOMId] = NULL
		,[dblQtyOrdered] = SC.dblNetUnits
		,[dblQtyShipped] = SC.dblNetUnits
		,[dblDiscount] = 0
		,[dblPrice] = SC.dblUnitPrice + dblUnitBasis
		,[ysnRefreshPrice] = 0
		,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
		,[ysnRecomputeTax] = 1
		,[intContractDetailId] = SC.intContractId
		,[intTicketId] = SC.intTicketId
		,[intDestinationGradeId] = SC.intGradeId
		,[intDestinationWeightId] = SC.intWeightId
		FROM tblSCTicket SC
		LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
		LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
		LEFT JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId		
		WHERE SC.intTicketId = @intTicketId

	--FOR FREIGHT CHARGES
	INSERT INTO @invoiceIntegrationStagingTable (
		[strTransactionType]
		,[strType]
		,[strSourceTransaction]
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
		,[strItemDescription]
		,[intOrderUOMId]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[intTaxGroupId]
		,[ysnRecomputeTax]
		,[intContractDetailId]
		,[intTicketId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]		
	)
	SELECT 
		[strTransactionType] = 'Invoice'
		,[strType] = 'Standard'
		,[strSourceTransaction] = 'Ticket Management'
		,[intSourceId] = SC.intTicketId
		,[strSourceId] = ''
		,[intInvoiceId] = NULL --NULL Value will create new invoice
		,[intEntityCustomerId] = @intEntityId
		,[intCompanyLocationId] = SC.intProcessingLocationId
		,[intCurrencyId] = SC.intCurrencyId
		,[intTermId] = EM.intTermsId
		,[dtmDate] = SC.dtmTicketDateTime
		,[ysnTemplate] = 0
		,[ysnForgiven] = 0
		,[ysnCalculated] = 0
		,[ysnSplitted] = 0
		,[intEntityId] = @intUserId
		,[ysnResetDetails] = 0
		,[intItemId] = ICI.intItemId
		,[strItemDescription] = ICI.strItemNo
		,[intOrderUOMId]= NULL
		,[intItemUOMId] = NULL
		,[dblQtyOrdered] = SC.dblNetUnits
		,[dblQtyShipped] = SC.dblNetUnits
		,[dblDiscount] = 0
		,[dblPrice] = SC.dblFreightRate
		,[ysnRefreshPrice] = 0
		,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
		,[ysnRecomputeTax] = 1
		,[intContractDetailId] = SC.intContractId
		,[intTicketId] = SC.intTicketId
		,[intDestinationGradeId] = SC.intGradeId
		,[intDestinationWeightId] = SC.intWeightId
		FROM tblSCTicket SC
		INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
		LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
		LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
		LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intFreightItemId		
		WHERE SC.intTicketId = @intTicketId AND SC.dblFreightRate != 0

	--FOR FEE CHARGES
	INSERT INTO @invoiceIntegrationStagingTable (
		[strTransactionType]
		,[strType]
		,[strSourceTransaction]
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
		,[strItemDescription]
		,[intOrderUOMId]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[intTaxGroupId]
		,[ysnRecomputeTax]
		,[intContractDetailId]
		,[intTicketId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]		
	)
	SELECT 
		[strTransactionType] = 'Invoice'
		,[strType] = 'Standard'
		,[strSourceTransaction] = 'Ticket Management'
		,[intSourceId] = SC.intTicketId
		,[strSourceId] = ''
		,[intInvoiceId] = NULL --NULL Value will create new invoice
		,[intEntityCustomerId] = @intEntityId
		,[intCompanyLocationId] = SC.intProcessingLocationId
		,[intCurrencyId] = SC.intCurrencyId
		,[intTermId] = EM.intTermsId
		,[dtmDate] = SC.dtmTicketDateTime
		,[ysnTemplate] = 0
		,[ysnForgiven] = 0
		,[ysnCalculated] = 0
		,[ysnSplitted] = 0
		,[intEntityId] = @intUserId
		,[ysnResetDetails] = 0
		,[intItemId] = ICI.intItemId
		,[strItemDescription] = ICI.strItemNo
		,[intOrderUOMId]= NULL
		,[intItemUOMId] = NULL
		,[dblQtyOrdered] = SC.dblNetUnits
		,[dblQtyShipped] = SC.dblNetUnits
		,[dblDiscount] = 0
		,[dblPrice] = SC.dblFreightRate
		,[ysnRefreshPrice] = 0
		,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
		,[ysnRecomputeTax] = 1
		,[intContractDetailId] = SC.intContractId
		,[intTicketId] = SC.intTicketId
		,[intDestinationGradeId] = SC.intGradeId
		,[intDestinationWeightId] = SC.intWeightId
		FROM tblSCTicket SC
		INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
		LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
		LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
		LEFT JOIN tblICItem ICI ON ICI.intItemId = SCS.intDefaultFeeItemId		
		WHERE SC.intTicketId = @intTicketId AND SC.dblTicketFees != 0

	--FOR DISCOUNT
	INSERT INTO @invoiceIntegrationStagingTable (
		[strTransactionType]
		,[strType]
		,[strSourceTransaction]
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
		,[strItemDescription]
		,[intOrderUOMId]
		,[intItemUOMId]
		,[dblQtyOrdered]
		,[dblQtyShipped]
		,[dblDiscount]
		,[dblPrice]
		,[ysnRefreshPrice]
		,[intTaxGroupId]
		,[ysnRecomputeTax]
		,[intContractDetailId]
		,[intTicketId]
		,[intDestinationGradeId]
		,[intDestinationWeightId]		
	)
	SELECT 
		[strTransactionType] = 'Invoice'
		,[strType] = 'Standard'
		,[strSourceTransaction] = 'Ticket Management'
		,[intSourceId] = SC.intTicketId
		,[strSourceId] = ''
		,[intInvoiceId] = NULL --NULL Value will create new invoice
		,[intEntityCustomerId] = @intEntityId
		,[intCompanyLocationId] = SC.intProcessingLocationId
		,[intCurrencyId] = SC.intCurrencyId
		,[intTermId] = EM.intTermsId
		,[dtmDate] = SC.dtmTicketDateTime
		,[ysnTemplate] = 0
		,[ysnForgiven] = 0
		,[ysnCalculated] = 0
		,[ysnSplitted] = 0
		,[intEntityId] = @intUserId
		,[ysnResetDetails] = 0
		,[intItemId] = ICI.intItemId
		,[strItemDescription] = ICI.strItemNo
		,[intOrderUOMId]= NULL
		,[intItemUOMId] =  CASE
								WHEN ISNULL(UM.intUnitMeasureId,0) = 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, SC.intItemUOMIdTo)
								WHEN ISNULL(UM.intUnitMeasureId,0) > 0 THEN dbo.fnGetMatchingItemUOMId(GR.intItemId, UM.intItemUOMId)
							END
		,[dblQtyOrdered] = CASE
							WHEN ICI.strCostMethod = 'Per Unit' THEN SC.dblNetUnits
							WHEN ICI.strCostMethod = 'Amount' THEN 1
						END
		,[dblQtyShipped] = CASE
							WHEN ICI.strCostMethod = 'Per Unit' THEN SC.dblNetUnits
							WHEN ICI.strCostMethod = 'Amount' THEN 1
						END
		,[dblDiscount] = 0
		,[dblPrice] = CASE
						WHEN ICI.strCostMethod = 'Per Unit' THEN QM.dblDiscountAmount
						WHEN ICI.strCostMethod = 'Amount' THEN 
						CASE 
							WHEN QM.dblDiscountAmount < 0 THEN (dbo.fnSCCalculateDiscount(SC.intTicketId,QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId) * -1)
							WHEN QM.dblDiscountAmount > 0 THEN dbo.fnSCCalculateDiscount(SC.intTicketId, QM.intTicketDiscountId, SC.dblNetUnits, GR.intUnitMeasureId)
						END
					END
		,[ysnRefreshPrice] = 0
		,[intTaxGroupId] = dbo.fnGetTaxGroupIdForVendor(@intEntityId,SC.intProcessingLocationId,ICI.intItemId,EM.intEntityLocationId,EM.intFreightTermId)
		,[ysnRecomputeTax] = 1
		,[intContractDetailId] = SC.intContractId
		,[intTicketId] = SC.intTicketId
		,[intDestinationGradeId] = SC.intGradeId
		,[intDestinationWeightId] = SC.intWeightId
		FROM tblSCTicket SC
		INNER JOIN tblQMTicketDiscount QM ON QM.intTicketId = SC.intTicketId
		LEFT JOIN tblGRDiscountScheduleCode GR ON QM.intDiscountScheduleCodeId = GR.intDiscountScheduleCodeId
		LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
		LEFT JOIN tblEMEntityLocation EM ON EM.intEntityId = AR.intEntityId AND EM.intEntityLocationId = AR.intShipToId
		LEFT JOIN tblICItem ICI ON ICI.intItemId = GR.intItemId		
		LEFT JOIN tblICItemUOM UM ON UM.intItemId = GR.intItemId AND UM.intUnitMeasureId = GR.intUnitMeasureId
		WHERE SC.intTicketId = @intTicketId

	SELECT @recCount = COUNT(*) FROM @invoiceIntegrationStagingTable;
	IF ISNULL(@recCount,0) > 0
	BEGIN
		EXEC [dbo].[uspARProcessInvoices] 
			@InvoiceEntries = @invoiceIntegrationStagingTable
			,@UserId = @intUserId
			,@GroupingOption = 11
			,@RaiseError = 1
			,@ErrorMessage = @ErrorMessage OUTPUT
			,@CreatedIvoices = @CreatedInvoices OUTPUT
			,@UpdatedIvoices = @UpdatedInvoices OUTPUT

		EXEC [dbo].[uspARPostInvoice]
			@batchId			= NULL,
			@post				= 1,
			@recap				= 0,
			@param				= @CreatedInvoices,
			@userId				= @intUserId,
			@beginDate			= NULL,
			@endDate			= NULL,
			@beginTransaction	= NULL,
			@endTransaction		= NULL,
			@exclude			= NULL,
			@successfulCount	= @successfulCount OUTPUT,
			@invalidCount		= @invalidCount OUTPUT,
			@success			= @success OUTPUT,
			@batchIdUsed		= @batchIdUsed OUTPUT,
			@recapId			= @recapId OUTPUT,
			@transType			= N'all',
			@accrueLicense		= 0,
			@raiseError			= 1
	END
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH