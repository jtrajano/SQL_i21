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
SET ANSI_WARNINGS OFF


DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
		,@intInvoiceId AS INT
		,@CreatedInvoices AS NVARCHAR(MAX)
		,@UpdatedInvoices AS NVARCHAR(MAX);

BEGIN TRY
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
				,[intTermId] = (select top 1 intFreightTermId from tblEMEntityLocation where intEntityLocationId = AR.intShipToId)
				,[dtmDate] = GETDATE()
				,[dtmDueDate] = NULL
				,[dtmShipDate] = NULL
				,[intEntitySalespersonId] = NULL
				,[intFreightTermId] = NULL
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
				,[dblQtyOrdered] = SC.dblTicketFees
				,[dblQtyShipped] = SC.dblTicketFees
				,[dblDiscount] = 0
				,[dblPrice] = 0
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

			EXEC [dbo].[uspARProcessInvoices] 
				@InvoiceEntries = @EntriesForInvoice
				,@UserId = @intUserId
				,@GroupingOption = 11
				,@RaiseError = 1
				,@ErrorMessage = @ErrorMessage OUTPUT
				,@CreatedIvoices = @CreatedInvoices OUTPUT
				,@UpdatedIvoices = @UpdatedInvoices OUTPUT
		END
	ELSE
		BEGIN
			SELECT @intInvoiceId = intInvoiceId FROM tblARInvoiceDetail WHERE intTicketId = @intTicketId;
			IF ISNULL(@intInvoiceId, 0) > 0
			BEGIN
				EXEC [dbo].[uspARDeleteInvoice] @intInvoiceId, @intUserId

				EXEC [dbo].[uspSCUpdateStatus] @intTicketId, 1;
				
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