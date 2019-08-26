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

DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT
DECLARE @ErrorNumber INT

BEGIN TRY

	BEGIN TRANSACTION

	--DECLARE @UserEntityId INT
	DECLARE @DefaultCurrency INT

	--SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId), @UserId)
	SELECT @DefaultCurrency = ISNULL(intDefaultCurrencyId, 1) FROM tblSMCompanyPreference

	EXEC [dbo].[uspMBPostMeterReadingValidation]
		@intMeterReadingId = @TransactionId
		,@Post = @Post

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

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
		,[ysnUseOriginIdAsInvoiceNumber]
		,[strInvoiceOriginId]
	)
	EXECUTE [dbo].[uspMBCreateInvoice] 
		@intMeterReadingId = @TransactionId
		,@intUserEntityId  = @UserId 
		,@intCurrency = @DefaultCurrency
		,@Post = @Post
		,@intInvoiceId = @InvoiceId

	
	IF (ISNULL(@ErrorMessage, '')  = '')
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
			-- UPDATE METER READING
			UPDATE tblMBMeterReadingDetail SET tblMBMeterReadingDetail.dblLastReading = AD.dblLastMeterReading
			FROM tblMBMeterReadingDetail RD
			INNER JOIN tblMBMeterReading MR ON RD.intMeterReadingId = MR.intMeterReadingId
			INNER JOIN tblMBMeterAccountDetail AD ON AD.intMeterAccountDetailId = RD.intMeterAccountDetailId
			WHERE RD.intMeterReadingId = @TransactionId
			AND RD.dblLastReading < AD.dblLastMeterReading

			-- UPDATE METER ACCOUNT DETAIL
			UPDATE tblMBMeterAccountDetail SET tblMBMeterAccountDetail.dblLastMeterReading = CASE WHEN MRDetail.dblCurrentReading > MADetail.dblLastMeterReading THEN  MRDetail.dblCurrentReading ELSE MADetail.dblLastMeterReading END
				, tblMBMeterAccountDetail.dblLastTotalSalesDollar = CASE WHEN MRDetail.dblCurrentDollars > MADetail.dblLastTotalSalesDollar THEN MRDetail.dblCurrentDollars ELSE MADetail.dblLastTotalSalesDollar END
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

			DECLARE @CursorTran AS CURSOR

			SET @CursorTran = CURSOR FOR
			SELECT A.intMeterAccountDetailId
			FROM tblMBMeterAccountDetail A
			WHERE A.intMeterAccountId = @meterAccountId

			DECLARE @intMeterAccountDetailId INT = NULL

			OPEN @CursorTran
			FETCH NEXT FROM @CursorTran INTO @intMeterAccountDetailId
        	WHILE @@FETCH_STATUS = 0
			BEGIN
				DECLARE @dblCurrentReading NUMERIC(18,6) = NULL,
					@dblCurrentDollar NUMERIC(18,6) = NULL

				SELECT TOP 1 @dblCurrentReading = MRD.dblCurrentReading, @dblCurrentDollar = MRD.dblCurrentDollars FROM tblMBMeterReadingDetail MRD
				INNER JOIN tblMBMeterReading MR ON MR.intMeterReadingId = MRD.intMeterReadingId
			 	WHERE MRD.intMeterAccountDetailId = @intMeterAccountDetailId
				AND MR.dtmTransaction <= @transactionDate
				AND MR.intMeterReadingId < @TransactionId
				ORDER BY MR.intMeterReadingId DESC

				UPDATE tblMBMeterAccountDetail SET dblLastMeterReading = ISNULL(@dblCurrentReading, 0), dblLastTotalSalesDollar = ISNULL(@dblCurrentDollar, 0)
				WHERE intMeterAccountDetailId = @intMeterAccountDetailId

				FETCH NEXT FROM @CursorTran INTO @intMeterAccountDetailId
			END
			CLOSE @CursorTran
			DEALLOCATE @CursorTran

			-- DELETE INVOICE WHEN ALL LINE ITEMS ARE ZERO QTY
			IF NOT EXISTS(SELECT TOP 1 1 FROM @EntriesForInvoice)
			BEGIN			
				UPDATE tblMBMeterReading SET intInvoiceId = NULL WHERE intMeterReadingId = @TransactionId
				EXEC [dbo].[uspARDeleteInvoice] 
					@InvoiceId = @InvoiceId,
					@UserId = @UserId
			END
		
		END

		IF(@@TRANCOUNT > 0)
		BEGIN
			COMMIT TRANSACTION
		END

	END
	ELSE
	BEGIN
		RAISERROR(@ErrorMessage,16, 1)
	END

END TRY
BEGIN CATCH
		
	IF(@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION
	END
	
	SET @ErrorMessage = ERROR_MESSAGE()
		--SET @ErrorMessage = ERROR_MESSAGE()
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorState = ERROR_STATE()
	SET @ErrorNumber   = ERROR_NUMBER()
		
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState ,@ErrorNumber)
END CATCH