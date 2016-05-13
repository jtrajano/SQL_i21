CREATE PROCEDURE [dbo].[uspTRLoadProcessToInvoice]
	 @intLoadHeaderId AS INT
	, @intUserId AS INT	
	, @ysnRecap AS BIT
	, @ysnPostOrUnPost AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(MAX)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @CreatedInvoices NVARCHAR(MAX)
DECLARE @UpdatedInvoices NVARCHAR(MAX)

BEGIN TRY

	DECLARE @UserEntityId INT
	SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @intUserId), @intUserId)

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

	BEGIN TRANSACTION

	INSERT INTO @EntriesForInvoice(
		 [strSourceTransaction]
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
		,[strDeliverPickup]
		,[strComments]
		,[intShipToLocationId]
		,[intBillToLocationId]
		,[ysnTemplate]
		,[ysnForgiven]
		,[ysnCalculated]
		,[ysnSplitted]
		,[intPaymentId]
		,[intSplitId]
		,[intDistributionHeaderId]
		,[strActualCostId]
		,[intShipmentId]
		,[intTransactionId]
		,[intEntityId]
		,[ysnResetDetails]
		,[ysnPost]
		,[intInvoiceDetailId]
		,[intItemId]
		,[ysnInventory]
		,[strItemDescription]
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
		,[ysnClearDetailTaxes]					
		,[intTempDetailIdForTaxes]
	)
	SELECT
		 [strSourceTransaction]					= 'Transport Load'
		,[intSourceId]							= DH.intLoadDistributionHeaderId
		,[strSourceId]							= TL.strTransaction
		,[intInvoiceId]							= DH.intInvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= DH.intEntityCustomerId
		,[intCompanyLocationId]					= DH.intCompanyLocationId
		,[intCurrencyId]						= 1
		,[intTermId]							= EL.intTermsId
		,[dtmDate]								= TL.dtmLoadDateTime
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= TL.dtmLoadDateTime
		,[intEntitySalespersonId]				= DH.intEntitySalespersonId
		,[intFreightTermId]						= NULL 
		,[intShipViaId]							= ISNULL(TL.intShipViaId, EL.intShipViaId) 
		,[intPaymentMethodId]					= 0
		,[strInvoiceOriginId]					= ''
		,[strPONumber]							= DH.strPurchaseOrder
		,[strBOLNumber]							= NULL
		,[strDeliverPickup]						= 'Deliver'
		,[strComments]							= (CASE WHEN TR.intSupplyPointId IS NULL AND TL.intLoadId IS NULL THEN RTRIM(DH.strComments)
														WHEN TR.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NULL THEN 'Origin:' + RTRIM(ee.strSupplyPoint) + ' ' + RTRIM(DH.strComments)
														WHEN TR.intSupplyPointId IS NULL AND TL.intLoadId IS NOT NULL THEN 'Load #:' + RTRIM(LG.strExternalLoadNumber) + ' ' + RTRIM(DH.strComments)
														WHEN TR.intSupplyPointId IS NOT NULL AND TL.intLoadId IS NOT NULL THEN 'Origin:' + RTRIM(ee.strSupplyPoint)  + ' Load #:' + RTRIM(LG.strExternalLoadNumber) + ' ' + RTRIM(DH.strComments)
													END)
		,[intShipToLocationId]					= DH.intShipToLocationId
		,[intBillToLocationId]					= ISNULL(Customer.intBillToId, EL.intEntityLocationId)
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0  --0 OS
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[intDistributionHeaderId]				= DH.intLoadDistributionHeaderId
		,[strActualCostId]						= (CASE WHEN (TR.strOrigin) = 'Terminal' AND (DH.strDestination) = 'Customer'
														THEN (TL.strTransaction)
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Customer' AND (TR.intCompanyLocationId) = (DH.intCompanyLocationId)
														THEN NULL
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Customer' AND (TR.intCompanyLocationId) != (DH.intCompanyLocationId)
														THEN (TL.strTransaction)
													WHEN (TR.strOrigin) = 'Location' AND (DH.strDestination) = 'Location'
														THEN NULL
													END)
		,[intShipmentId]						= NULL
		,[intTransactionId]						= NULL
		,[intEntityId]							= @UserEntityId
		,[ysnResetDetails]						= 1
		,[ysnPost]								= CASE WHEN (@ysnPostOrUnPost = 0) THEN NULL ELSE @ysnPostOrUnPost END
		,[intInvoiceDetailId]					= NULL
		,[intItemId]							= DD.intItemId
		,[ysnInventory]							= 1
		,[strItemDescription]					= Item.strDescription
		,[intItemUOMId]							= Item.intIssueUOMId
		,[dblQtyOrdered]						= DD.dblUnits
		,[dblQtyShipped]						= DD.dblUnits
		,[dblDiscount]							= 0
		,[dblPrice]								= DD.dblPrice
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= ''
		,[strFrequency]							= ''
		,[dtmMaintenanceDate]					= NULL
		,[dblMaintenanceAmount]					= NULL
		,[dblLicenseAmount]						= NULL
		,[intTaxGroupId]						= DD.intTaxGroupId
		,[ysnRecomputeTax]						= 1
		,[intSCInvoiceId]						= NULL
		,[strSCInvoiceNumber]					= ''
		,[intInventoryShipmentItemId]			= NULL
		,[strShipmentNumber]					= ''
		,[intSalesOrderDetailId]				= NULL
		,[strSalesOrderNumber]					= ''
		,[intContractHeaderId]					= (SELECT TOP 1 intContractHeaderId FROM vyuCTContractDetailView CT WHERE CT.intContractDetailId = DD.intContractDetailId) 
		,[intContractDetailId]					= DD.intContractDetailId
		,[intShipmentPurchaseSalesContractId]	= NULL
		,[intTicketId]							= NULL
		,[intTicketHoursWorkedId]				= NULL
		,[intSiteId]							= NULL
		,[strBillingBy]							= ''
		,[dblPercentFull]						= NULL
		,[dblNewMeterReading]					= NULL
		,[dblPreviousMeterReading]				= NULL
		,[dblConversionFactor]					= NULL
		,[intPerformerId]						= NULL
		,[ysnLeaseBilling]						= NULL
		,[ysnVirtualMeterReading]				= NULL
		,[ysnClearDetailTaxes]					= 1
		,[intTempDetailIdForTaxes]				= NULL
	FROM tblTRLoadHeader TL
			LEFT JOIN tblTRLoadDistributionHeader DH ON DH.intLoadHeaderId = TL.intLoadHeaderId
			LEFT JOIN tblARCustomer Customer ON Customer.intEntityCustomerId = DH.intEntityCustomerId
			LEFT JOIN tblEntityLocation EL ON EL.intEntityLocationId = DH.intShipToLocationId
			LEFT JOIN tblTRLoadDistributionDetail DD ON DD.intLoadDistributionHeaderId = DH.intLoadDistributionHeaderId
			LEFT JOIN vyuICGetItemLocation Item ON Item.intItemId = DD.intItemId AND Item.intLocationId = DH.intCompanyLocationId
			LEFT JOIN tblLGLoad LG ON LG.intLoadId = TL.intLoadId
			LEFT JOIN vyuICGetItemStock IC ON IC.intItemId = DD.intItemId AND IC.intLocationId = DH.intCompanyLocationId
			LEFT JOIN tblTRLoadReceipt TR ON TR.intLoadHeaderId = TL.intLoadHeaderId AND TR.strReceiptLine IN (
					SELECT Item 
					FROM dbo.fnTRSplit(DD.strReceiptLink,','))
					LEFT JOIN ( 
							SELECT DISTINCT intLoadDistributionDetailId
								, STUFF(( SELECT DISTINCT ', ' + CD.strSupplyPoint
											FROM dbo.vyuTRLinkedReceipts CD
											WHERE CD.intLoadHeaderId = CH.intLoadHeaderId
												AND CD.intLoadDistributionDetailId = CH.intLoadDistributionDetailId
											FOR XML PATH('')), 1, 2, '') strSupplyPoint
							FROM vyuTRLinkedReceipts CH) ee 
						ON ee.intLoadDistributionDetailId = DD.intLoadDistributionDetailId
		WHERE TL.intLoadHeaderId = @intLoadHeaderId
			AND DH.strDestination = 'Customer'

	EXEC [dbo].[uspARProcessInvoices]
			 @InvoiceEntries	= @EntriesForInvoice
			,@UserId			= @intUserId
			,@GroupingOption	= 11
			,@RaiseError		= 1
			,@ErrorMessage		= @ErrorMessage OUTPUT
			,@CreatedIvoices	= @CreatedInvoices OUTPUT
			,@UpdatedIvoices	= @UpdatedInvoices OUTPUT

	IF (@ErrorMessage IS NULL)
	BEGIN
		COMMIT TRANSACTION
	END
	ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END

	DECLARE @strReceiptLink NVARCHAR(100),
		@strBOL NVARCHAR(50),
		@InvoiceId INT

	IF (@CreatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		
		SELECT Item INTO #tmpCreated FROM [fnSplitStringWithTrim](@CreatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpCreated)
		BEGIN
			SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpCreated

			UPDATE tblTRLoadDistributionHeader 
			SET intInvoiceId = @InvoiceId
			WHERE intLoadHeaderId = @intLoadHeaderId
				AND strDestination = 'Customer'

			UPDATE tblTRLoadHeader 
			SET ysnPosted = @ysnPostOrUnPost
			WHERE intLoadHeaderId = @intLoadHeaderId

			SET @strReceiptLink = (SELECT dbo.fnTRConcatString('', @intLoadHeaderId, ',', 'strReceiptLink'))
			SET @strBOL = (SELECT dbo.fnTRConcatString(@strReceiptLink, @intLoadHeaderId, ',', 'strBillOfLading'))
		
			UPDATE tblARInvoice
			SET strBOLNumber = @strBOL
			WHERE intInvoiceId = @InvoiceId

			DELETE FROM #tmpCreated WHERE CAST(Item AS INT) = @InvoiceId
		END
	END

	IF (@UpdatedInvoices IS NOT NULL AND @ErrorMessage IS NULL)
	BEGIN
		SELECT Item INTO #tmpUpdated FROM [fnSplitStringWithTrim](@UpdatedInvoices,',')
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUpdated)
		BEGIN
			SELECT TOP 1 @InvoiceId = CAST(Item AS INT) FROM #tmpUpdated

			UPDATE tblTRLoadHeader 
			SET ysnPosted = @ysnPostOrUnPost
			WHERE intLoadHeaderId = @intLoadHeaderId

			SET @strReceiptLink = (SELECT dbo.fnTRConcatString('', @intLoadHeaderId, ',', 'strReceiptLink'))
			SET @strBOL = (SELECT dbo.fnTRConcatString(@strReceiptLink, @intLoadHeaderId, ',', 'strBillOfLading'))
		
			UPDATE tblARInvoice
			SET strBOLNumber = @strBOL
			WHERE intInvoiceId = @InvoiceId

			DELETE FROM #tmpUpdated WHERE CAST(Item AS INT) = @InvoiceId
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