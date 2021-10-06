CREATE PROCEDURE [dbo].[uspSCProcessMemoToInvoice]
	@intTicketId AS INT
	,@intEntityId AS INT
	,@intUserId AS INT
	,@ysnPost AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON


DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		,@intInvoiceId AS INT
		,@CreatedInvoices AS NVARCHAR(MAX)
		,@UpdatedInvoices AS NVARCHAR(MAX);


DECLARE @successfulCount INT
DECLARE @invalidCount INT
DECLARE @success BIT
DECLARE @batchIdUsed NVARCHAR(40)
DECLARE @recapId NVARCHAR(250)
DECLARE @intExistingInvoiceId INT

DECLARE @UNDISTRIBUTE_NOT_ALLOWED NVARCHAR(100)
DECLARE @NeedCreditMemoMessage NVARCHAR(200)
DECLARE @strTicketNumber NVARCHAR(50)
DECLARE @strInvoiceNumber NVARCHAR(50)
DECLARE @ysnTicketInvoiceHasCM BIT
DECLARE @intInvoiceDetailId INT
DECLARE @EntityCustomerId INT
DECLARE @NewInvoiceId INT

SET @EntityCustomerId = @intEntityId

SET @UNDISTRIBUTE_NOT_ALLOWED = 'Un-distribute ticket with posted invoice is not allowed.'

BEGIN TRY

	SELECT TOP 1
		@strTicketNumber = strTicketNumber
	FROM tblSCTicket
	WHERE intTicketId = @intTicketId

	IF @ysnPost = 1
		BEGIN



			INSERT INTO @EntriesForInvoice
			(
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
				,[dtmDueDate]
				,[dtmShipDate]
				,[intEntitySalespersonId]
				,[intFreightTermId]
				,[intShipViaId]
				,[intPaymentMethodId]
				,[strInvoiceOriginId]
				,[strPONumber]
				,[strBOLNumber]
				,[strComments]
				,[intShipToLocationId]
				,[intBillToLocationId]
				,[ysnTemplate]
				,[ysnForgiven]
				,[ysnCalculated]
				,[ysnSplitted]
				,[intPaymentId]
				,[intSplitId]					
				,[strActualCostId]
				,[intEntityId]
				,[ysnResetDetails]
				,[ysnPost]
				,[intInvoiceDetailId]
				,[intItemId]
				,[ysnInventory]
				,[strItemDescription]
				,[intOrderUOMId]
				,[intItemUOMId]
				,[dblQtyOrdered]
				,[dblQtyShipped]
				,[dblDiscount]
				,[dblPrice]
				,[ysnRefreshPrice]
				,[strMaintenanceType]
				,[strFrequency]
				,[dtmMaintenanceDate]
				,[dblMaintenanceAmount]
				,[dblLicenseAmount]
				,[intTaxGroupId]
				,[ysnRecomputeTax]
				,[intSCInvoiceId]
				,[strSCInvoiceNumber]
				,[intInventoryShipmentItemId]
				,[strShipmentNumber]
				,[intSalesOrderDetailId]
				,[strSalesOrderNumber]
				,[intContractHeaderId]
				,[intContractDetailId]
				,[intShipmentPurchaseSalesContractId]
				,[intTicketId]
				,[intTicketHoursWorkedId]
				,[intSiteId]
				,[strBillingBy]
				,[dblPercentFull]
				,[dblNewMeterReading]
				,[dblPreviousMeterReading]
				,[dblConversionFactor]
				,[intPerformerId]
				,[ysnLeaseBilling]
				,[ysnVirtualMeterReading]
				,[intCustomerStorageId]
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
				,[intTermId] = NULL
				,[dtmDate] = GETDATE()
				,[dtmDueDate] = NULL
				,[dtmShipDate] = NULL
				,[intEntitySalespersonId] = NULL
				,[intFreightTermId] = (select top 1 intFreightTermId from tblEMEntityLocation where intEntityLocationId = AR.intShipToId)
				,[intShipViaId] = NULL
				,[intPaymentMethodId] = NULL
				,[strInvoiceOriginId] = NULL --''
				,[strPONumber] = NULL --''
				,[strBOLNumber] = NULL --''
				,[strComments] = NULL --''
				,[intShipToLocationId] = NULL
				,[intBillToLocationId] = NULL
				,[ysnTemplate] = 0
				,[ysnForgiven] = 0
				,[ysnCalculated] = 0
				,[ysnSplitted] = 0
				,[intPaymentId] = NULL
				,[intSplitId] = NULL					
				,[strActualCostId] = NULL --''
				,[intEntityId] = @intUserId
				,[ysnResetDetails] = 0
				,[ysnPost] = NULL
				,[intInvoiceDetailId] = NULL
				,[intItemId] = SCS.intDefaultFeeItemId
				,[ysnInventory] = 0
				,[strItemDescription] = ICFee.strItemNo
				,[intOrderUOMId]= NULL
				,[intItemUOMId] = NULL
				,[dblQtyOrdered] = 1
				,[dblQtyShipped] = 1
				,[dblDiscount] = 0
				,[dblPrice] = SC.dblTicketFees
				,[ysnRefreshPrice] = 0
				,[strMaintenanceType] = ''
				,[strFrequency] = ''
				,[dtmMaintenanceDate] = NULL
				,[dblMaintenanceAmount] = NULL
				,[dblLicenseAmount] = NULL
				,[intTaxGroupId] = NULL
				,[ysnRecomputeTax] = 1
				,[intSCInvoiceId] = NULL
				,[strSCInvoiceNumber] = ''
				,[intInventoryShipmentItemId] = NULL
				,[strShipmentNumber] = ''
				,[intSalesOrderDetailId] = NULL
				,[strSalesOrderNumber] = ''
				,[intContractHeaderId] = NULL
				,[intContractDetailId] = NULL
				,[intShipmentPurchaseSalesContractId] = NULL
				,[intTicketId] = SC.intTicketId
				,[intTicketHoursWorkedId] = NULL
				,[intSiteId] = NULL
				,[strBillingBy] = ''
				,[dblPercentFull] = NULL
				,[dblNewMeterReading] = NULL
				,[dblPreviousMeterReading] = NULL
				,[dblConversionFactor] = NULL
				,[intPerformerId] = NULL
				,[ysnLeaseBilling] = NULL
				,[ysnVirtualMeterReading] = NULL
				,[intCustomerStorageId]=NULL
				FROM tblSCTicket SC
				INNER JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId
				LEFT JOIN tblARCustomer AR ON AR.intEntityId = SC.intEntityId
				LEFT JOIN tblICItem ICFee ON ICFee.intItemId = SCS.intDefaultFeeItemId		
				WHERE SC.intTicketId = @intTicketId



			--GET EXISTING INVOICE FOR BATCH SCALE
			DECLARE @intContractShipToLocationId	INT

			SELECT TOP 1 @intContractShipToLocationId = CD.intShipToId
			FROM @EntriesForInvoice IE
			INNER JOIN tblCTContractDetail CD ON IE.intContractDetailId = CD.intContractDetailId
			WHERE CD.intContractDetailId IS NOT NULL
			AND CD.intShipToId IS NOT NULL

			SELECT @intExistingInvoiceId = dbo.fnARGetInvoiceForBatch(@EntityCustomerId, @intContractShipToLocationId)

			--CREATE INVOICE IF THERE's NONE
			IF ISNULL(@intExistingInvoiceId, 0) = 0
				BEGIN
					EXEC [dbo].[uspARProcessInvoices]
						@InvoiceEntries = @EntriesForInvoice
						,@UserId = @intUserId
						,@GroupingOption = 11
						,@RaiseError = 1
						,@ErrorMessage = @ErrorMessage OUTPUT
						,@CreatedIvoices = @CreatedInvoices OUTPUT
						,@UpdatedIvoices = @UpdatedInvoices OUTPUT


					SELECT TOP 1 @NewInvoiceId = intInvoiceId FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@CreatedInvoices))
				END
			ELSE
				--INSERT TO EXISTING INVOICE
			BEGIN
				DECLARE @tblInvoiceDetailEntries	InvoiceStagingTable

				INSERT INTO @tblInvoiceDetailEntries (
					intInvoiceDetailId
					, strSourceTransaction
					, intSourceId
					, strSourceId
					, intEntityCustomerId
					, intCompanyLocationId
					, dtmDate
					, strDocumentNumber
					, strShipmentNumber
					, intEntityId
					, intInvoiceId
					, intItemId
					, strItemDescription
					, strPricing
					, intOrderUOMId
					, dblQtyOrdered
					, intItemUOMId
					, intPriceUOMId
					, dblQtyShipped
					, dblPrice
					, dblUnitPrice
					, dblContractPriceUOMQty
					, intItemWeightUOMId
					, intContractDetailId
					, intContractHeaderId
					, intTicketId
					, intTaxGroupId
					, dblCurrencyExchangeRate
					, strAddonDetailKey
					, ysnAddonParent
					, intInventoryShipmentItemId
					, intInventoryShipmentChargeId
					, intStorageLocationId
					, intSubLocationId
					, intCompanyLocationSubLocationId
				)
				SELECT intInvoiceDetailId				= NULL
					, strSourceTransaction				= EI.strSourceTransaction
					, intSourceId						= EI.intSourceId
					, strSourceId						= EI.strSourceId
					, intEntityCustomerId				= EI.intEntityCustomerId
					, intCompanyLocationId				= EI.intCompanyLocationId
					, dtmDate							= EI.dtmDate
					, strDocumentNumber					= EI.strSourceId
					, strShipmentNumber					= EI.strShipmentNumber
					, intEntityId						= EI.intEntityId
					, intInvoiceId						= @intExistingInvoiceId
					, intItemId							= EI.intItemId
					, strItemDescription				= EI.strItemDescription
					, strPricing						= NULL
					, intOrderUOMId						= EI.intOrderUOMId
					, dblQtyOrdered						= EI.dblQtyOrdered
					, intItemUOMId						= EI.intItemUOMId
					, intPriceUOMId						= EI.intPriceUOMId
					, dblQtyShipped						= EI.dblQtyShipped
					, dblPrice							= EI.dblPrice
					, dblUnitPrice						= EI.dblUnitPrice
					, dblContractPriceUOMQty			= EI.dblContractPriceUOMQty
					, intItemWeightUOMId				= EI.intItemWeightUOMId
					, intContractDetailId				= EI.intContractDetailId
					, intContractHeaderId				= EI.intContractHeaderId
					, intTicketId						= EI.intTicketId
					, intTaxGroupId						= EI.intTaxGroupId
					, dblCurrencyExchangeRate			= EI.dblCurrencyExchangeRate
					, strAddonDetailKey					= EI.strAddonDetailKey
					, ysnAddonParent					= EI.ysnAddonParent
					, intInventoryShipmentItemId		= EI.intInventoryShipmentItemId
					, intInventoryShipmentChargeId		= EI.intInventoryShipmentChargeId
					, intStorageLocationId				= EI.intStorageLocationId
					, intSubLocationId					= EI.intSubLocationId
					, intCompanyLocationSubLocationId	= EI.intSubLocationId
				FROM @EntriesForInvoice EI

				EXEC dbo.uspARAddItemToInvoices @InvoiceEntries		= @tblInvoiceDetailEntries
											, @IntegrationLogId	= NULL
											, @UserId				= @intUserId

				EXEC dbo.uspARUpdateInvoiceIntegrations @intExistingInvoiceId, 0, @intUserId
				EXEC dbo.uspARReComputeInvoiceTaxes @intExistingInvoiceId
			END
		END
	ELSE
		BEGIN
			SELECT @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intTicketId = @intTicketId;

			SET @ysnTicketInvoiceHasCM = 1

			--Check if a credit Memo exists
			IF EXISTS(
					SELECT TOP 1 1
					FROM tblARInvoice C
					LEFT JOIN tblARInvoiceDetail A
						ON A.intInvoiceId = C.intInvoiceId
							AND C.strTransactionType = 'Credit Memo'
					LEFT JOIN tblARInvoiceDetail B
						ON A.intInvoiceDetailId = B.intOriginalInvoiceDetailId
					WHERE A.intTicketId = @intTicketId
						AND C.intInvoiceId = @intInvoiceId
						AND B.intInvoiceDetailId IS NULL
						AND A.intInvoiceDetailId IS NOT NULL
				)
			BEGIN
				SET @ysnTicketInvoiceHasCM = 0
			END

			IF ISNULL(@intInvoiceId, 0) > 0
			BEGIN
				IF(SELECT TOP 1 ysnPosted FROM tblARInvoice WHERE intInvoiceId = @intInvoiceId) = 1
				BEGIN

					if (exists ( select top 1 1 from tblGRCompanyPreference where ysnDoNotAllowUndistributePostedInvoice = 1 ))
					begin
						RAISERROR(@UNDISTRIBUTE_NOT_ALLOWED, 11, 1);
						RETURN;
					end


					IF @ysnTicketInvoiceHasCM = 0
					BEGIN
						SELECT TOP 1
							@strInvoiceNumber = strInvoiceNumber
						FROM tblARInvoice
						WHERE intInvoiceId = @intInvoiceId

						SET @NeedCreditMemoMessage = 'Please create a credit memo for invoice ' + @strInvoiceNumber + ' with this ticket number ' + @strTicketNumber +'.'
						RAISERROR(@NeedCreditMemoMessage, 11, 1);
						RETURN;
					END
					-- EXEC [dbo].[uspARPostInvoice]
					-- 	@batchId			= NULL,
					-- 	@post				= 0,
					-- 	@recap				= 0,
					-- 	@param				= @intInvoiceId,
					-- 	@userId				= @intUserId,
					-- 	@beginDate			= NULL,
					-- 	@endDate			= NULL,
					-- 	@beginTransaction	= NULL,
					-- 	@endTransaction		= NULL,
					-- 	@exclude			= NULL,
					-- 	@successfulCount	= @successfulCount OUTPUT,
					-- 	@invalidCount		= @invalidCount OUTPUT,
					-- 	@success			= @success OUTPUT,
					-- 	@batchIdUsed		= @batchIdUsed OUTPUT,
					-- 	@recapId			= @recapId OUTPUT,
					-- 	@transType			= N'all',
					-- 	@accrueLicense		= 0,
					-- 	@raiseError			= 1

				END

				---Check if there are other tickets on the invoice
				IF (SELECT COUNT(DISTINCT intTicketId)
					FROM tblARInvoiceDetail
					WHERE intInvoiceId = @intInvoiceId) > 1
				BEGIN
					SELECT TOP 1
						@intInvoiceDetailId = intInvoiceDetailId
					FROM tblARInvoiceDetail
					WHERE intInvoiceId = @intInvoiceId

					--update invoice
					EXEC uspARDeleteInvoice @intInvoiceId, @intUserId, @intInvoiceDetailId
					EXEC dbo.uspARUpdateInvoiceIntegrations @intInvoiceId, 0, @intUserId
					EXEC dbo.uspARReComputeInvoiceTaxes @intInvoiceId
				END
				ELSE
				BEGIN
					EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId
				END

				EXEC [dbo].[uspSCUpdateTicketStatus] @intTicketId, 1;
				
				EXEC dbo.uspSMAuditLog 
					@keyValue			= @intTicketId						-- Primary Key Value of the Ticket. 
					,@screenName		= 'Grain.view.Scale'				-- Screen Namespace
					,@entityId			= @intUserId						-- Entity Id.
					,@actionType		= 'Updated'							-- Action Type
					,@changeDescription	= 'Ticket Status'					-- Description
					,@fromValue			= 'Completed'						-- Previous Value
					,@toValue			= 'Reopened'						-- New Value
					,@details			= '';
			END
			
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
GO