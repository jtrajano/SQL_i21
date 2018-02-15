CREATE PROCEDURE [dbo].[uspTRGenerateQuotes]
	 @intCustomerGroupId AS INT,
	 @intCustomerId AS INT,
	 @dtmQuoteDate AS DATETIME,
	 @dtmEffectiveDate AS DATETIME,
	 @ysnConfirm AS BIT,
	 @ysnVoid AS BIT,
	 @intBegQuoteId INT OUTPUT,
	 @intEndQuoteId INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	SELECT intCustomerId = intEntityCustomerId
		, strQuoteNumber = NULL
	INTO #tmpQuotes
	FROM tblARCustomerGroup CG
	LEFT JOIN tblARCustomerGroupDetail CD ON CG.intCustomerGroupId = CD.intCustomerGroupId
	LEFT JOIN tblEMEntityLocation EL ON CD.intEntityId = EL.intEntityId
	RIGHT JOIN vyuTRQuoteSelection QS ON QS.intEntityCustomerId = CD.intEntityId AND QS.intEntityCustomerLocationId = EL.intEntityLocationId
	WHERE CD.ysnQuote = 1
		AND QS.ysnQuote = 1
		AND (CG.intCustomerGroupId = @intCustomerGroupId OR ISNULL(@intCustomerGroupId, 0) = 0)
		AND (ISNULL(@intCustomerId, 0) = 0 OR @intCustomerId = QS.intEntityCustomerId)
	GROUP BY QS.intEntityCustomerId

	IF ((@ysnConfirm = 1) OR (@ysnVoid = 1))
	BEGIN
		IF @ysnConfirm = 1
		BEGIN
			UPDATE tblTRQuoteHeader
			SET strQuoteStatus = 'Confirmed'
			WHERE intEntityCustomerId IN (SELECT intCustomerId FROM #tmpQuotes) AND strQuoteStatus = 'UnConfirmed'
		END
		ELSE IF @ysnVoid = 1
		BEGIN
			UPDATE tblTRQuoteHeader
			SET strQuoteStatus = 'Void'
			WHERE intEntityCustomerId IN (SELECT intCustomerId FROM #tmpQuotes) AND strQuoteStatus = 'Confirmed'      
		END

		SET @intBegQuoteId = 0
		SET @intEndQuoteId = 0
	END
	ELSE
	BEGIN
		DECLARE @CustomerId INT
			, @QuoteNumber NVARCHAR(50)
			, @QuoteId INT
			, @MinQuote NVARCHAR(50)
			, @MaxQuote NVARCHAR(50)

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpQuotes)
		BEGIN
			SELECT TOP 1 @CustomerId = intCustomerId FROM #tmpQuotes

			EXEC dbo.uspSMGetStartingNumber 56, @QuoteNumber OUTPUT

			INSERT INTO tblTRQuoteHeader (strQuoteNumber
				, strQuoteStatus
				, dtmQuoteDate
				, dtmQuoteEffectiveDate
				, intEntityCustomerId
				, strQuoteComments
				, strCustomerComments
				, intConcurrencyId)
			VALUES (@QuoteNumber
				, 'UnConfirmed'
				, @dtmQuoteDate	
				, @dtmEffectiveDate	
				, @CustomerId
				, NULL
				, NULL
				, 1)

			IF (ISNULL(@MinQuote, '') = '')
			BEGIN
				SET @MinQuote = @QuoteNumber
			END
			SET @MaxQuote = @QuoteNumber
			SET @QuoteId = SCOPE_IDENTITY()

			INSERT INTO tblTRQuoteDetail (intQuoteHeaderId
				, intItemId
				, intTerminalId
				, intSupplyPointId
				, dblRackPrice
				, dblDeviationAmount
				, dblTempAdjustment
				, dblFreightRate
				, dblQuotePrice
				, dblMargin
				, dblQtyOrdered
				, dblExtProfit
				, dblTax
				, intShipToLocationId
				, intSpecialPriceId
				, intConcurrencyId
				, intShipViaId
				, intTaxGroupId)
			SELECT @QuoteId
				, QD.intItemId
				, SP.intEntityVendorId
				, QD.intSupplyPointId
				, NULL
				, NULL
				, NULL
				, NULL
				, NULL
				, NULL
				, 1
				, NULL
				, NULL
				, EL.intEntityLocationId
				, SpecialPrice.intSpecialPriceId
				, 1
				, EL.intShipViaId
				, EL.intTaxGroupId
			FROM tblEMEntityLocation EL
			LEFT JOIN vyuTRQuoteSelection QD ON QD.intEntityCustomerId = @CustomerId
				AND QD.intEntityCustomerLocationId = EL.intEntityLocationId
			LEFT JOIN vyuTRSupplyPointView SP ON QD.intSupplyPointId = SP.intSupplyPointId
			CROSS APPLY(
				SELECT TOP 1 intSpecialPriceId
				FROM tblARCustomerSpecialPrice ARPrice
				WHERE ARPrice.intItemId = QD.intItemId
					AND ARPrice.intEntityCustomerId = @CustomerId
					AND ARPrice.intCustomerLocationId = EL.intEntityLocationId
					AND ((ARPrice.strPriceBasis = 'O'
							AND ARPrice.intEntityVendorId = SP.intEntityVendorId
							AND ARPrice.intEntityLocationId = SP.intEntityLocationId)
						OR (ARPrice.strPriceBasis = 'R'
							AND ARPrice.intRackVendorId = SP.intEntityVendorId
							AND ARPrice.intRackLocationId = SP.intEntityLocationId)
					)) SpecialPrice
			WHERE QD.ysnQuote = 1
				AND EL.intEntityId = @CustomerId

			SELECT QD.*
				, SP.strZipCode
			INTO #tmpQuoteDetail
			FROM tblTRQuoteDetail QD
			LEFT JOIN vyuTRSupplyPointView SP ON SP.intSupplyPointId = QD.intSupplyPointId
			WHERE intQuoteHeaderId = @QuoteId
	
			DECLARE @LineItems LineItemTaxDetailStagingTable
				, @QuoteDetailId INT
				, @QuoteHeaderId INT
				, @ItemId INT
				, @TerminalId INT
				, @SupplyPointId INT
				, @ShipViaId INT
				, @TaxGroupId INT
				, @ShipToLocationId INT
				, @SpecialPriceId INT
				, @RackPrice NUMERIC(18,6) = 0
				, @DeviationAmount NUMERIC(18,6) = 0
				, @FreightRate NUMERIC(18,6) = 0
				, @SurchargeRate NUMERIC(18,6) = 0
				, @QuotePrice NUMERIC(18,6) = 0
				, @Margin NUMERIC(18,6) = 0
				, @QtyOrdered NUMERIC(18,6) = 0
				, @ExtProfit NUMERIC(18,6) = 0
				, @Tax NUMERIC(18,6) = 0
				, @ZipCode NVARCHAR(20)		
			
			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpQuoteDetail)
			BEGIN
				SELECT TOP 1 @QuoteDetailId = intQuoteDetailId
					, @QuoteHeaderId = intQuoteHeaderId
					, @ItemId = intItemId
					, @TerminalId = intTerminalId
					, @SupplyPointId = intSupplyPointId
					, @ShipViaId = intShipViaId
					, @TaxGroupId = intTaxGroupId
					, @ShipToLocationId = intShipToLocationId
					, @SpecialPriceId = intSpecialPriceId
					, @RackPrice = dblRackPrice
					, @DeviationAmount = dblDeviationAmount
					, @FreightRate = dblFreightRate
					, @QuotePrice = dblQuotePrice
					, @Margin = dblMargin
					, @QtyOrdered = dblQtyOrdered
					, @ExtProfit = dblExtProfit
					, @Tax = dblTax
					, @ZipCode = strZipCode
				FROM #tmpQuoteDetail
				
				SELECT @RackPrice = ISNULL(tblPatch.dblRackPrice, ISNULL(tblTRQuoteDetail.dblRackPrice, 0.000000))
					, @DeviationAmount = ISNULL(tblPatch.dblDeviation, 0.000000)
				FROM tblTRQuoteDetail
				LEFT JOIN (
					SELECT SP.intSpecialPriceId
						, SP.dblDeviation
						, dblRackPrice = (CASE WHEN SP.strPriceBasis = 'O' THEN [dbo].[fnTRGetRackPrice] (@dtmEffectiveDate, OriginRack.intSupplyPointId, SP.intItemId)
											WHEN SP.strPriceBasis = 'R' THEN [dbo].[fnTRGetRackPrice] (@dtmEffectiveDate, FixedRack.intSupplyPointId, SP.intRackItemId) END)
					FROM tblARCustomerSpecialPrice SP
					LEFT JOIN vyuTRSupplyPointView OriginRack ON OriginRack.intEntityVendorId = SP.intEntityVendorId
						AND OriginRack.intEntityLocationId = SP.intEntityLocationId
					LEFT JOIN vyuTRSupplyPointView FixedRack ON FixedRack.intEntityVendorId = SP.intRackVendorId
						AND FixedRack.intEntityLocationId = SP.intRackLocationId
				) tblPatch ON tblPatch.intSpecialPriceId = tblTRQuoteDetail.intSpecialPriceId
				WHERE tblTRQuoteDetail.intQuoteDetailId = @QuoteDetailId

				EXEC uspTRGetCustomerFreight @intEntityCustomerId = @CustomerId,
					 @intItemId = @ItemId,
					 @strZipCode = @ZipCode,
					 @intShipViaId = @ShipViaId,
					 @intShipToId = @ShipToLocationId,
					 @dblReceiptGallons = @QtyOrdered,
					 @dblInvoiceGallons = @QtyOrdered,
					 @dtmReceiptDate = @dtmEffectiveDate,
					 @dtmInvoiceDate = @dtmEffectiveDate,
					 @ysnToBulkPlant = 0,
					 @dblInvoiceFreightRate = @FreightRate OUTPUT,
					 @dblReceiptFreightRate = NULL,
					 @dblReceiptSurchargeRate = NULL,
					 @dblInvoiceSurchargeRate = @SurchargeRate OUTPUT,
					 @ysnFreightInPrice = NULL,
					 @ysnFreightOnly = NULL

				SET @QuotePrice = @RackPrice + @DeviationAmount + @FreightRate
				SET @Margin = @QuotePrice - @RackPrice
				SET @ExtProfit = @QtyOrdered * @Margin

				SELECT intTaxGroupId
					, intTaxCodeId
					, intTaxClassId
					, strTaxableByOtherTaxes
					, strCalculationMethod
					, dblRate
					, dblExemptionPercent
					, dblTax = CASE WHEN (ISNULL(dblTax, 0) = 0) THEN 0 ELSE (dblTax / 100000) END
					, dblAdjustedTax = CASE WHEN (ISNULL(dblAdjustedTax, 0) = 0) THEN 0 ELSE (dblAdjustedTax / 100000) END
					, intTaxAccountId
					, ysnCheckoffTax
					, strTaxCode
					, ysnTaxExempt
					, ysnInvalidSetup
					, strNotes
				INTO #tmpTaxes
				FROM dbo.fnConstructLineItemTaxDetail (
					100000
					, @QuotePrice
					, @LineItems
					, 0
					, @ItemId
					, @CustomerId
					, @ShipToLocationId
					, @TaxGroupId
					, @QuotePrice
					, @dtmEffectiveDate
					, NULL
					, 1
					, NULL
					, NULL
					, NULL
					, NULL
					, 0
					, 0
					, NULL	--intItemUOMId
					, NULL  --@CFSiteId
					, 0		--@IsDeliver
				)

				INSERT INTO tblTRQuoteDetailTax(
					intQuoteDetailId
					, intTaxGroupId
					, intTaxCodeId
					, intTaxClassId
					, strTaxableByOtherTaxes
					, strCalculationMethod
					, dblRate
					, dblTax
					, dblAdjustedTax
					, intTaxAccountId
					, ysnTaxAdjusted
					, ysnSeparateOnInvoice
					, ysnCheckoffTax
					, strTaxCode
				)
				SELECT 
					@QuoteDetailId
					, intTaxGroupId
					, intTaxCodeId
					, intTaxClassId
					, strTaxableByOtherTaxes
					, strCalculationMethod
					, dblRate
					, dblTax
					, dblAdjustedTax
					, intTaxAccountId
					, 0
					, 0
					, ysnCheckoffTax
					, strTaxCode
				FROM #tmpTaxes
				WHERE ISNULL(dblAdjustedTax, 0) <> 0

				SELECT @Tax = ISNULL(SUM(ISNULL(dblTax, 0)), 0)
				FROM #tmpTaxes

				UPDATE tblTRQuoteDetail
				SET dblRackPrice = @RackPrice 
					, dblDeviationAmount = @DeviationAmount
					, dblTempAdjustment = 0.000000
					, dblFreightRate = ISNULL(@FreightRate, 0.000000)
					, dblQuotePrice = @QuotePrice
					, dblMargin = @Margin
					, dblQtyOrdered = @QtyOrdered
					, dblExtProfit = @ExtProfit
					, dblTax = @Tax
				WHERE intQuoteDetailId = @QuoteDetailId

				DELETE FROM #tmpQuoteDetail WHERE intQuoteDetailId = @QuoteDetailId

				DROP TABLE #tmpTaxes
			END

			DROP TABLE #tmpQuoteDetail

			DELETE FROM #tmpQuotes WHERE intCustomerId = @CustomerId
		END

		SELECT @intBegQuoteId = intQuoteHeaderId FROM tblTRQuoteHeader WHERE @MinQuote = strQuoteNumber
		SELECT @intEndQuoteId = intQuoteHeaderId FROM tblTRQuoteHeader WHERE @MaxQuote = strQuoteNumber

		IF @intBegQuoteId IS NULL
		BEGIN
			SET @intBegQuoteId = 0
		END
		IF @intEndQuoteId IS NULL
		BEGIN
			SET @intEndQuoteId = 0
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