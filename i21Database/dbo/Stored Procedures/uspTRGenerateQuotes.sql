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

			SELECT QD.intQuoteDetailId
				, QD.intQuoteHeaderId
			INTO #tmpQuoteDetail
			FROM tblTRQuoteDetail QD
			WHERE intQuoteHeaderId = @QuoteId
	
			DECLARE @QuoteDetailId INT
				, @ItemId INT
				, @LocationId INT
				, @TaxGroupId INT
				, @TransactionDate DATETIME
				, @Amount NUMERIC(18,6)
				, @Price NUMERIC(18,6)
				, @IsReversal BIT
				, @LineItems LineItemTaxDetailStagingTable
				, @TaxTotal NUMERIC(18,6)
				, @PriceType NVARCHAR(20)
			
			WHILE EXISTS (SELECT TOP 1 1 FROM #tmpQuoteDetail)
			BEGIN
				SELECT TOP 1 @QuoteDetailId = intQuoteDetailId FROM #tmpQuoteDetail
				
				UPDATE tblTRQuoteDetail
				SET dblRackPrice = ISNULL(tblPatch.dblRackPrice, tblTRQuoteDetail.dblRackPrice)
					, dblDeviationAmount = ISNULL(tblPatch.dblDeviation, 0.000000)
					, dblFreightRate = 0
					, dblQuotePrice = ISNULL(tblPatch.dblDeviation, 0.000000) + ISNULL(tblPatch.dblRackPrice, tblTRQuoteDetail.dblRackPrice)
					, dblMargin = ISNULL(tblPatch.dblDeviation, 0.000000)
					, dblTempAdjustment = 0.000000
					, dblQtyOrdered = 0
					, dblExtProfit = 0
					, dblTax = 0
				FROM (
					SELECT SP.intSpecialPriceId
						, SP.dblDeviation
						, dblRackPrice = (CASE WHEN SP.strPriceBasis = 'O' THEN [dbo].[fnTRGetRackPrice] (@dtmEffectiveDate, OriginRack.intSupplyPointId, SP.intItemId)
											WHEN SP.strPriceBasis = 'R' THEN [dbo].[fnTRGetRackPrice] (@dtmEffectiveDate, FixedRack.intSupplyPointId, SP.intRackItemId) END)
					FROM tblARCustomerSpecialPrice SP
					LEFT JOIN vyuTRSupplyPointView OriginRack ON OriginRack.intEntityVendorId = SP.intEntityVendorId
						AND OriginRack.intEntityLocationId = SP.intEntityLocationId
					LEFT JOIN vyuTRSupplyPointView FixedRack ON FixedRack.intEntityVendorId = SP.intRackVendorId
						AND FixedRack.intEntityLocationId = SP.intRackLocationId
				) tblPatch 
				WHERE tblPatch.intSpecialPriceId = tblTRQuoteDetail.intSpecialPriceId
					AND tblTRQuoteDetail.intQuoteDetailId = @QuoteDetailId

				SELECT TOP 1 @ItemId = intItemId
				, @LocationId = intShipToLocationId
				, @TaxGroupId = intTaxGroupId
				, @Amount = dblQuotePrice
				, @Price = dblQuotePrice
				FROM tblTRQuoteDetail
				WHERE intQuoteDetailId = @QuoteDetailId

				SELECT *
				INTO #tmpTaxes
				FROM dbo.fnConstructLineItemTaxDetail (
					1
					, @Amount
					, @LineItems
					, 0
					, @ItemId
					, @CustomerId
					, @LocationId
					, @TaxGroupId
					, @Price
					, @dtmEffectiveDate
					, NULL
					, 1
					, NULL
					, NULL
					, NULL
					, NULL
				)

				SELECT @TaxTotal = ISNULL(SUM(ISNULL(dblTax, 0)), 0)
				FROM #tmpTaxes

				UPDATE tblTRQuoteDetail
				SET dblTax = @TaxTotal
				WHERE intQuoteDetailId = @QuoteDetailId

				DELETE FROM #tmpQuoteDetail WHERE intQuoteDetailId = @QuoteDetailId

				DROP TABLE #tmpTaxes
			END
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