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

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

BEGIN TRY

	DECLARE @DataForQuote TABLE(
		intId INT IDENTITY PRIMARY KEY CLUSTERED
		, intCustomerId INT
		, intCustomerLocationId INT
		, strQuoteNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	)

	DECLARE @DataForDetailQuote TABLE(
		intDetailId INT IDENTITY PRIMARY KEY CLUSTERED
		, intQuoteDetailId INT
		, intQuoteHeaderId INT
	)

	DECLARE @total INT
		, @QuoteHeader INT
		, @strMinQuote NVARCHAR(50)
		, @strMaxQuote NVARCHAR(50)
		, @QuoteNumber NVARCHAR(50)
		, @incval INT

	INSERT INTO @DataForQuote(
		intCustomerId
		, intCustomerLocationId
		, strQuoteNumber)
	SELECT intEntityCustomerId
		, EL.intEntityLocationId
		, NULL
	FROM tblARCustomerGroup CG
	LEFT JOIN tblARCustomerGroupDetail CD ON CG.intCustomerGroupId = CD.intCustomerGroupId
	LEFT JOIN tblEMEntityLocation EL ON CD.intEntityId = EL.intEntityId
	RIGHT JOIN vyuTRQuoteSelection QS ON QS.intEntityCustomerId = CD.intEntityId AND QS.intEntityCustomerLocationId = EL.intEntityLocationId
	WHERE CD.ysnQuote = 1
		AND QS.ysnQuote = 1
		AND (CG.intCustomerGroupId = @intCustomerGroupId OR ISNULL(@intCustomerGroupId, 0) = 0)
		AND (ISNULL(@intCustomerId, 0) = 0 OR @intCustomerId = QS.intEntityCustomerId)
	GROUP BY QS.intEntityCustomerId, EL.intEntityLocationId

	SELECT @total = COUNT(*) FROM @DataForQuote
	SET @incval = 1
	
	WHILE (@incval <= @total)
	BEGIN
		IF @ysnConfirm = 1
		BEGIN
			UPDATE tblTRQuoteHeader
			SET strQuoteStatus = 'Confirmed'
			WHERE intEntityCustomerId = (SELECT TOP 1 intCustomerId FROM @DataForQuote WHERE intId = @incval) AND strQuoteStatus = 'UnConfirmed'
		END
		ELSE
		BEGIN
			IF @ysnVoid = 1
			BEGIN
				UPDATE tblTRQuoteHeader
				SET strQuoteStatus = 'Void'
				WHERE intEntityCustomerId = (SELECT TOP 1 intCustomerId FROM @DataForQuote WHERE intId = @incval) AND strQuoteStatus = 'Confirmed'      
			END
			ELSE
			BEGIN
				EXEC dbo.uspSMGetStartingNumber 56, @QuoteNumber OUTPUT
				UPDATE @DataForQuote
				SET strQuoteNumber = @QuoteNumber
				WHERE @incval = intId
			END
		END
		SET @incval = @incval + 1;
	END
	
	IF ((@ysnConfirm = 1) OR (@ysnVoid = 1))
	BEGIN
		SET @intBegQuoteId = 0
		SET @intEndQuoteId = 0
		RETURN
	END

	INSERT INTO [dbo].[tblTRQuoteHeader] (
		[strQuoteNumber]
		, [strQuoteStatus]
		, [dtmQuoteDate]
		, [dtmQuoteEffectiveDate]
		, [intEntityCustomerId]
		, [strQuoteComments]
		, [strCustomerComments]
		, [intConcurrencyId])
	SELECT
		QS.strQuoteNumber
		, 'UnConfirmed'
		, @dtmQuoteDate	
		, @dtmEffectiveDate	
		, QS.intCustomerId	
		, NULL
		, NULL
		, 1
	FROM @DataForQuote QS

	INSERT INTO [dbo].[tblTRQuoteDetail] (
		[intQuoteHeaderId]
		, [intItemId]
		, [intTerminalId]
		, [intSupplyPointId]
		, [dblRackPrice]
		, [dblDeviationAmount]
		, [dblTempAdjustment]
		, [dblFreightRate]
		, [dblQuotePrice]
		, [dblMargin]
		, [dblQtyOrdered]
		, [dblExtProfit]
		, [dblTax]
		, [intShipToLocationId]
		, [intSpecialPriceId]
		, [intConcurrencyId])
	SELECT
		QH.intQuoteHeaderId
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
	FROM @DataForQuote QS
	LEFT JOIN tblTRQuoteHeader QH ON QS.strQuoteNumber = QH.strQuoteNumber
	LEFT JOIN tblEMEntityLocation EL ON QS.intCustomerId = EL.intEntityId
	LEFT JOIN vyuTRQuoteSelection QD ON QD.intEntityCustomerId = QS.intCustomerId AND QD.intEntityCustomerLocationId = EL.intEntityLocationId
	LEFT JOIN vyuTRSupplyPointView SP ON QD.intSupplyPointId = SP.intSupplyPointId
	CROSS APPLY(
		SELECT TOP 1 intSpecialPriceId FROM tblARCustomerSpecialPrice ARPrice
		WHERE ARPrice.intItemId = QD.intItemId AND ARPrice.intEntityCustomerId = QS.intCustomerId AND ARPrice.intCustomerLocationId = QS.intCustomerLocationId
			AND (
				(ARPrice.strPriceBasis = 'O' AND ARPrice.intEntityVendorId = SP.intEntityVendorId AND ARPrice.intEntityLocationId = SP.intEntityLocationId)
				OR
				(ARPrice.strPriceBasis = 'R' AND ARPrice.intRackVendorId = SP.intEntityVendorId AND ARPrice.intRackLocationId = SP.intEntityLocationId)
			)) SpecialPrice
	WHERE QD.ysnQuote = 1

	INSERT INTO @DataForDetailQuote
	SELECT QD.intQuoteDetailId
		,QH.intQuoteHeaderId
	FROM @DataForQuote QT
	LEFT JOIN tblTRQuoteHeader QH ON QH.strQuoteNumber = QT.strQuoteNumber
	LEFT JOIN tblTRQuoteDetail QD on QH.intQuoteHeaderId = QD.intQuoteHeaderId
	
	DECLARE @detailId INT
		, @intSpecialPriceId INT
		, @dblRackPrice DECIMAL(18, 6)
		, @dblDeviationAmount DECIMAL(18, 6);

	SELECT @total = COUNT(*) FROM @DataForQuote
	SET @incval = 1

	WHILE (@incval <= @total)
	BEGIN
		SELECT @QuoteHeader = intQuoteHeaderId
		FROM @DataForQuote QS
		LEFT JOIN tblTRQuoteHeader QH ON QS.strQuoteNumber = QH.strQuoteNumber
		WHERE @incval = intId

		WHILE ((SELECT TOP 1 intQuoteDetailId FROM @DataForDetailQuote WHERE intQuoteHeaderId = @QuoteHeader) IS NOT NULL)
		BEGIN
			SELECT TOP 1 @detailId = intQuoteDetailId
			FROM @DataForDetailQuote
			WHERE intQuoteHeaderId = @QuoteHeader
			
			SELECT @intSpecialPriceId = intSpecialPriceId
			FROM tblTRQuoteDetail
			WHERE intQuoteDetailId = @detailId
						
			UPDATE tblTRQuoteDetail
			SET dblRackPrice = ISNULL((SELECT ISNULL((CASE WHEN SP.strPriceBasis = 'O' THEN [dbo].[fnTRGetRackPrice]    -- Update Using Origin Rack
														( @dtmEffectiveDate
														, (SELECT intSupplyPointId FROM vyuTRSupplyPointView WHERE intEntityVendorId = SP.intEntityVendorId AND intEntityLocationId = SP.intEntityLocationId)
														, SP.intItemId )
													WHEN SP.strPriceBasis = 'R' THEN [dbo].[fnTRGetRackPrice]    -- Update using Fixed Rack
														( @dtmEffectiveDate
														, (SELECT intSupplyPointId FROM vyuTRSupplyPointView WHERE intEntityVendorId = SP.intRackVendorId AND intEntityLocationId = SP.intRackLocationId)
														, SP.intRackItemId )
													END), dblRackPrice)
								FROM tblARCustomerSpecialPrice SP
								WHERE SP.intSpecialPriceId = @intSpecialPriceId), dblRackPrice)
			WHERE intQuoteDetailId = @detailId
			
			UPDATE tblTRQuoteDetail 
			SET dblDeviationAmount = (SELECT TOP 1 SP.dblDeviation FROM tblARCustomerSpecialPrice SP WHERE SP.intSpecialPriceId = @intSpecialPriceId)
			WHERE intQuoteDetailId = @detailId

			SELECT @dblDeviationAmount = dblDeviationAmount
				, @dblRackPrice=dblRackPrice
			FROM tblTRQuoteDetail
			WHERE intQuoteDetailId = @detailId
				
			UPDATE tblTRQuoteDetail
			SET dblQuotePrice = @dblDeviationAmount + @dblRackPrice
				, dblMargin = @dblDeviationAmount
			WHERE intQuoteDetailId = @detailId
				
			DELETE FROM @DataForDetailQuote WHERE intQuoteDetailId = @detailId
		END
		
		SET @incval = @incval + 1;
	END

	SELECT @strMinQuote = MIN(strQuoteNumber)
		, @strMaxQuote = MAX(strQuoteNumber)
	FROM @DataForQuote

	SELECT @intBegQuoteId = intQuoteHeaderId FROM tblTRQuoteHeader WHERE @strMinQuote = strQuoteNumber
	SELECT @intEndQuoteId = intQuoteHeaderId FROM tblTRQuoteHeader WHERE @strMaxQuote = strQuoteNumber

	IF @intBegQuoteId IS NULL
	BEGIN
		SET @intBegQuoteId = 0
	END
	IF @intEndQuoteId IS NULL
	BEGIN
		SET @intEndQuoteId = 0
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