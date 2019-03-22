CREATE PROCEDURE [dbo].[uspTRDuplicateTransportLoad]
	@TransportLoadId INT,
	@NewTransportLoadId INT OUTPUT

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

	DECLARE @TransactionNumber NVARCHAR(50)
		, @newLoadHeaderId INT
		, @loadDistributionHeaderId INT
		, @newLoadDistributionHeaderId INT
		, @loadDistributionDetailId INT
		, @newLoadDistributionDetailId INT

	-- Take next starting number
	EXEC uspSMGetStartingNumber	@intStartingNumberId = 54, @strID = @TransactionNumber OUTPUT

	INSERT INTO tblTRLoadHeader(strTransaction
		, dtmLoadDateTime
		, intShipViaId
		, intSellerId
		, intDriverId
		, strTractor
		, strTrailer
		, ysnDiversion
		, strDiversionNumber
		, intStateId
		, intConcurrencyId)
	SELECT @TransactionNumber 
		, dtmLoadDateTime
		, intShipViaId
		, intSellerId
		, intDriverId
		, strTractor
		, strTrailer
		, ysnDiversion
		, strDiversionNumber
		, intStateId
		, 1
	FROM tblTRLoadHeader
	WHERE intLoadHeaderId = @TransportLoadId

	SET @newLoadHeaderId = SCOPE_IDENTITY()

	INSERT INTO tblTRLoadReceipt(intLoadHeaderId
		, strOrigin
		, intTerminalId
		, intSupplyPointId
		, intCompanyLocationId
		, intItemId
		, dblGross
		, dblNet
		, dblUnitCost
		, dblFreightRate
		, dblPurSurcharge
		, ysnFreightInPrice
		, intTaxGroupId
		, strReceiptLine
		, strBillOfLading
		, intConcurrencyId)
	SELECT @newLoadHeaderId
		, strOrigin
		, intTerminalId
		, intSupplyPointId
		, intCompanyLocationId
		, intItemId
		, dblGross
		, dblNet
		, dblUnitCost
		, dblFreightRate
		, dblPurSurcharge
		, ysnFreightInPrice
		, intTaxGroupId
		, strReceiptLine
		, ''
		, 1
	FROM tblTRLoadReceipt
	WHERE intLoadHeaderId = @TransportLoadId

	SELECT intLoadDistributionHeaderId 
		, intLoadHeaderId = @newLoadHeaderId
		, strDestination
		, intEntityCustomerId
		, intShipToLocationId
		, intCompanyLocationId
		, intEntitySalespersonId
		, strPurchaseOrder
		, strComments
		, dtmInvoiceDateTime
	INTO #tmpDistributionHeader
	FROM tblTRLoadDistributionHeader
	WHERE intLoadHeaderId = @TransportLoadId

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpDistributionHeader)
	BEGIN
		
		SELECT TOP 1 @loadDistributionHeaderId = intLoadDistributionHeaderId FROM #tmpDistributionHeader

		INSERT INTO tblTRLoadDistributionHeader(intLoadHeaderId
			, strDestination
			, intEntityCustomerId
			, intShipToLocationId
			, intCompanyLocationId
			, intEntitySalespersonId
			, strPurchaseOrder
			, strComments
			, dtmInvoiceDateTime
			, intConcurrencyId)
		SELECT intLoadHeaderId
			, strDestination
			, intEntityCustomerId
			, intShipToLocationId
			, intCompanyLocationId
			, intEntitySalespersonId
			, strPurchaseOrder
			, strComments
			, dtmInvoiceDateTime
			, 1
		FROM #tmpDistributionHeader
		WHERE intLoadDistributionHeaderId = @loadDistributionHeaderId

		SET @newLoadDistributionHeaderId = SCOPE_IDENTITY()

		SELECT intLoadDistributionDetailId
			, intLoadDistributionHeaderId = @newLoadDistributionHeaderId
			, strReceiptLink
			, intItemId
			, dblUnits
			, dblPrice
			, dblFreightRate
			, dblDistSurcharge
			, ysnFreightInPrice
			, ysnBlendedItem
			, intTaxGroupId
		INTO #tmpDistributionDetail
		FROM tblTRLoadDistributionDetail
		WHERE intLoadDistributionHeaderId = @loadDistributionHeaderId

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDistributionDetail)
		BEGIN

			SELECT TOP 1 @loadDistributionDetailId = intLoadDistributionDetailId FROM #tmpDistributionDetail

			INSERT INTO tblTRLoadDistributionDetail(intLoadDistributionHeaderId
				, strReceiptLink
				, intItemId
				, dblUnits
				, dblPrice
				, dblFreightRate
				, dblDistSurcharge
				, ysnFreightInPrice
				, ysnBlendedItem
				, intTaxGroupId
				, intConcurrencyId)
			SELECT intLoadDistributionHeaderId
				, strReceiptLink
				, intItemId
				, dblUnits
				, dblPrice
				, dblFreightRate
				, dblDistSurcharge
				, ysnFreightInPrice
				, ysnBlendedItem
				, intTaxGroupId
				, 1
			FROM #tmpDistributionDetail
			WHERE intLoadDistributionDetailId = @loadDistributionDetailId

			SET @newLoadDistributionDetailId = SCOPE_IDENTITY()

			INSERT INTO tblTRLoadBlendIngredient(intLoadDistributionDetailId
				, strReceiptLink
				, intSubstituteItemId
				, ysnSubstituteItem
				, intRecipeItemId
				, dblQuantity
				, intConcurrencyId)
			SELECT @newLoadDistributionDetailId
				, strReceiptLink
				, intSubstituteItemId
				, ysnSubstituteItem
				, intRecipeItemId
				, dblQuantity
				, 1
			FROM tblTRLoadBlendIngredient
			WHERE intLoadDistributionDetailId = @loadDistributionDetailId

			DELETE FROM #tmpDistributionDetail WHERE intLoadDistributionDetailId = @loadDistributionDetailId
			
		END

		DROP TABLE #tmpDistributionDetail
		
		DELETE FROM #tmpDistributionHeader WHERE @loadDistributionHeaderId = intLoadDistributionHeaderId

	END

	DROP TABLE #tmpDistributionHeader

	SET @NewTransportLoadId = @newLoadHeaderId
	
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