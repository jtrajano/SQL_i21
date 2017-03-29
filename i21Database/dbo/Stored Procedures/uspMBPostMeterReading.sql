CREATE PROCEDURE [dbo].[uspMBPostMeterReading]
	 @TransactionId		INT
	,@UserId			INT	
	,@Post				BIT	= NULL
	,@Recap				BIT	= NULL
	,@InvoiceId			INT	= NULL
	,@ErrorMessage		NVARCHAR(MAX) OUTPUT
	,@CreatedInvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedInvoices	NVARCHAR(MAX)  = NULL OUTPUT
AS
	
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	DECLARE @UserEntityId INT
	SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserId), @UserId)

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

	BEGIN TRANSACTION

	INSERT INTO @EntriesForInvoice(
		[strType]
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
		,[intLoadDistributionHeaderId]
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
		,[intMeterReadingId]
	)
	SELECT
		[strType]								= 'Meter Billing'
		,[strSourceTransaction]					= 'Meter Billing'
		,[intSourceId]							= MRDetail.intMeterReadingId
		,[strSourceId]							= MRDetail.strTransactionId
		,[intInvoiceId]							= @InvoiceId --NULL Value will create new invoice
		,[intEntityCustomerId]					= MRDetail.intEntityCustomerId
		,[intCompanyLocationId]					= MRDetail.intCompanyLocationId
		,[intCurrencyId]						= 1
		,[intTermId]							= MADetail.intTermId
		,[dtmDate]								= MRDetail.dtmTransaction
		,[dtmDueDate]							= NULL
		,[dtmShipDate]							= MRDetail.dtmTransaction
		,[intEntitySalespersonId]				= Customer.intSalespersonId
		,[intFreightTermId]						= NULL 
		,[intShipViaId]							= NULL 
		,[intPaymentMethodId]					= NULL
		,[strInvoiceOriginId]					= ''
		,[strPONumber]							= NULL
		,[strBOLNumber]							= ''
		,[strDeliverPickup]						= 'Pickup'
		,[strComments]							= MRDetail.strInvoiceComment
		,[intShipToLocationId]					= MRDetail.intEntityLocationId
		,[intBillToLocationId]					= NULL
		,[ysnTemplate]							= 0
		,[ysnForgiven]							= 0
		,[ysnCalculated]						= 0  --0 OS
		,[ysnSplitted]							= 0
		,[intPaymentId]							= NULL
		,[intSplitId]							= NULL
		,[intLoadDistributionHeaderId]			= NULL
		,[strActualCostId]						= ''
		,[intShipmentId]						= NULL
		,[intTransactionId]						= NULL
		,[intEntityId]							= @UserEntityId
		,[ysnResetDetails]						= 0
		,[ysnPost]								= @Post
	
		,[intInvoiceDetailId]					= NULL
		,[intItemId]							= MRDetail.intItemId
		,[ysnInventory]							= 1
		,[strItemDescription]					= MRDetail.strItemDescription
		,[intItemUOMId]							= MRDetail.intItemUOMId
		,[dblQtyOrdered]						= 0
		,[dblQtyShipped]						= SUM(MRDetail.dblQuantitySold)
		,[dblDiscount]							= 0
		,[dblPrice]								= MIN(MRDetail.dblNetPrice)
		,[ysnRefreshPrice]						= 0
		,[strMaintenanceType]					= ''
		,[strFrequency]							= ''
		,[dtmMaintenanceDate]					= NULL
		,[dblMaintenanceAmount]					= NULL
		,[dblLicenseAmount]						= NULL
		,[intTaxGroupId]						= EntityLocation.intTaxGroupId
		,[ysnRecomputeTax]						= 1
		,[intSCInvoiceId]						= NULL
		,[strSCInvoiceNumber]					= ''
		,[intInventoryShipmentItemId]			= NULL
		,[strShipmentNumber]					= ''
		,[intSalesOrderDetailId]				= NULL
		,[strSalesOrderNumber]					= ''
		,[intContractHeaderId]					= NULL
		,[intContractDetailId]					= NULL
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
		,[intTempDetailIdForTaxes]				= @TransactionId
		,[intMeterReadingId]					= @TransactionId
	FROM vyuMBGetMeterReadingDetail MRDetail
	LEFT JOIN vyuMBGetMeterAccountDetail MADetail ON MADetail.intMeterAccountDetailId = MRDetail.intMeterAccountDetailId
	LEFT JOIN vyuARCustomer Customer ON Customer.[intEntityId] = MRDetail.intEntityCustomerId
	LEFT JOIN tblEMEntityLocation EntityLocation ON EntityLocation.intEntityLocationId = MRDetail.intEntityLocationId AND MRDetail.intEntityCustomerId = EntityLocation.intEntityId
	WHERE MRDetail.intMeterReadingId = @TransactionId
	GROUP BY MRDetail.intMeterReadingId
		, MRDetail.strTransactionId
		, MRDetail.intEntityCustomerId
		, MRDetail.intEntityLocationId
		, MRDetail.intCompanyLocationId
		, MRDetail.intItemId
		, MRDetail.strItemDescription
		, MRDetail.intItemUOMId
		, MADetail.intTermId
		, MRDetail.dtmTransaction
		, Customer.intSalespersonId
		, MRDetail.strInvoiceComment
		, EntityLocation.intTaxGroupId

	EXEC [dbo].[uspARProcessInvoices]
		@InvoiceEntries	= @EntriesForInvoice
		,@UserId			= @UserId
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

	IF (@ErrorMessage IS NULL)
	BEGIN

		IF (@CreatedInvoices IS NOT NULL)
		BEGIN
			UPDATE tblMBMeterReading 
			SET intInvoiceId = @CreatedInvoices
			WHERE intMeterReadingId = @TransactionId
		END	

		UPDATE tblMBMeterReading
		SET ysnPosted = @Post
			, dtmPostedDate = GETDATE()
		WHERE intMeterReadingId = @TransactionId

		IF (@Post = 1)
		BEGIN
			UPDATE tblMBMeterAccountDetail
			SET tblMBMeterAccountDetail.dblLastMeterReading = MRDetail.dblCurrentReading
				, tblMBMeterAccountDetail.dblLastTotalSalesDollar = MRDetail.dblCurrentDollars
			FROM tblMBMeterAccountDetail MADetail
			LEFT JOIN tblMBMeterReadingDetail MRDetail ON MRDetail.intMeterAccountDetailId = MADetail.intMeterAccountDetailId
			WHERE MRDetail.intMeterReadingId = @TransactionId
		END
		ELSE IF (@Post = 0)
		BEGIN
			DECLARE @transactionDate DATETIME
				, @meterAccountId INT
			SELECT @transactionDate = dtmTransaction
				, @meterAccountId = intMeterAccountId
			FROM tblMBMeterReading
			WHERE intMeterReadingId = @TransactionId

			UPDATE tblMBMeterAccountDetail
			SET dblLastMeterReading = 0
				, dblLastTotalSalesDollar = 0

			UPDATE tblMBMeterAccountDetail
			SET tblMBMeterAccountDetail.dblLastMeterReading = ISNULL(MRDetail.dblCurrentReading, 0)
				, tblMBMeterAccountDetail.dblLastTotalSalesDollar = ISNULL(MRDetail.dblCurrentDollars, 0)
			FROM (
				SELECT TOP 100 PERCENT * FROM vyuMBGetMeterReadingDetail
				WHERE intMeterAccountId = @meterAccountId
					AND dtmTransaction < @transactionDate
					AND ysnPosted = 1
				ORDER BY dtmTransaction DESC
				) MRDetail
			WHERE MRDetail.intMeterAccountDetailId = tblMBMeterAccountDetail.intMeterAccountDetailId
		END
	END
END