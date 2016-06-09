CREATE PROCEDURE [dbo].[uspTRGenerateQuotes]
	 @intCustomerGroupId AS INT,
	 @intCustomerId AS INT,
	 @dtmQuoteDate AS DATETIME,
	 @dtmEffectiveDate AS DATETIME,
	 @ysnConfirm as bit,
	 @ysnVoid as bit,
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
	, strQuoteNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

DECLARE @DataForDetailQuote TABLE(
	intDetailId INT IDENTITY PRIMARY KEY CLUSTERED
    , intQuoteDetailId INT
	, intQuoteHeaderId INT
)

DECLARE @total INT,
        @QuoteHeader INT,
		@strMinQuote NVARCHAR(50),
		@strMaxQuote NVARCHAR(50),
        @QuoteNumber NVARCHAR(50),
        @incval INT;

INSERT INTO @DataForQuote
            (intCustomerId
			,strQuoteNumber)
SELECT intEntityCustomerId
	, NULL
FROM tblARCustomerGroup CG
	JOIN tblARCustomerGroupDetail CD ON CG.intCustomerGroupId = CD.intCustomerGroupId
	JOIN [tblEMEntityLocation] EL ON CD.intEntityId = EL.intEntityId
	RIGHT JOIN vyuTRQuoteSelection QS ON QS.intEntityCustomerId = CD.intEntityId 
		AND QS.intEntityCustomerLocationId = EL.intEntityLocationId
WHERE CD.ysnQuote = 1
	AND QS.ysnQuote = 1
	AND (CG.intCustomerGroupId = @intCustomerGroupId OR ISNULL(@intCustomerGroupId,0) = 0)
	AND (ISNULL(@intCustomerId ,0 ) = 0 OR @intCustomerId = QS.intEntityCustomerId)
GROUP BY QS.intEntityCustomerId

SELECT @total = count(*) FROM @DataForQuote;
SET @incval = 1 

WHILE @incval <= @total 
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
	END;

IF @ysnConfirm = 1 OR @ysnVoid = 1
	BEGIN
		SET @intBegQuoteId = 0;
		SET @intEndQuoteId = 0;
		RETURN;
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
	QS.strQuoteNumber  --[strQuoteNumber]
	, 'UnConfirmed'	--[strQuoteStatus]
	, @dtmQuoteDate	--[dtmQuoteDate]
	, @dtmEffectiveDate	--[dtmQuoteEffectiveDate]
	, QS.intCustomerId	--[intEntityCustomerId]
	, NULL	--[strQuoteComments]
	, NULL	--[strCustomerComments]
	, 1   	--[intConcurrencyId]
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
	QH.intQuoteHeaderId --[intQuoteHeaderId]
	, QD.intItemId --[intItemId]
	, (select SP.intEntityVendorId from vyuTRSupplyPointView SP where QD.intSupplyPointId = SP.intSupplyPointId) --[intTerminalId]
	, QD.intSupplyPointId --[intSupplyPointId]
	, NULL --[dblRackPrice]
	, NULL  --[dblDeveationAmount]
	, NULL --[dblTempAdjustment]
	, NULL --[dblFreightRate]
	, NULL --[dblQuotePrice]
	, NULL --[dblMargin]
	, 1 --[dblQtyOrdered]
	, NULL --[dblExtProfit]
	, NULL --[dblTax]
	, EL.intEntityLocationId --[intShipToLocationId]
	, [dbo].[fnARGetCustomerItemSpecialPriceId]  --[dblDeviationAmount]
	(
		QD.intItemId			--@ItemId
		, QS.intCustomerId 	--@CustomerId
		, NULL --@LocationId
		, ( SELECT TOP 1
				IU.intItemUOMId
			FROM dbo.tblICItemUOM IU
			WHERE IU.intItemId = QD.intItemId AND IU.ysnStockUnit = 1 )		--@ItemUOMId
		,@dtmEffectiveDate				--@TransactionDate
		,1            		--@Quantity
		,(select SP.intEntityVendorId from vyuTRSupplyPointView SP where QD.intSupplyPointId = SP.intSupplyPointId)					--@VendorId
		,QD.intSupplyPointId	--@SupplyPointId
		,NULL					--@LastCost
		,EL.intEntityLocationId 	--@ShipToLocationId
		,NULL					--@VendorLocationId
		,NULL					--@InvoiceType
		) as INTSpecialPriceId
	, 1 --[intConcurrencyId]
FROM @DataForQuote QS
	JOIN tblTRQuoteHeader QH on QS.strQuoteNumber = QH.strQuoteNumber
	JOIN [tblEMEntityLocation] EL on QS.intCustomerId = EL.intEntityId
	JOIN vyuTRQuoteSelection QD on QD.intEntityCustomerId = QS.intCustomerId AND QD.intEntityCustomerLocationId = EL.intEntityLocationId
WHERE QD.ysnQuote = 1

INSERT INTO @DataForDetailQuote
SELECT QD.intQuoteDetailId
	,QH.intQuoteHeaderId
FROM @DataForQuote QT
	JOIN tblTRQuoteHeader QH ON QH.strQuoteNumber = QT.strQuoteNumber
	JOIN tblTRQuoteDetail QD on QH.intQuoteHeaderId = QD.intQuoteHeaderId

DECLARE @detailId INT
	, @intSpecialPriceId INT
	, @dblRackPrice DECIMAL(18, 6)
	, @dblDeviationAmount DECIMAL(18, 6);

SELECT @total = COUNT(*)
FROM @DataForQuote

SET @incval = 1
WHILE @incval <= @total
	BEGIN
		SELECT @QuoteHeader = intQuoteHeaderId
		FROM @DataForQuote QS
			JOIN tblTRQuoteHeader QH ON QS.strQuoteNumber = QH.strQuoteNumber
		WHERE @incval = intId

		WHILE(SELECT TOP 1 intQuoteDetailId FROM @DataForDetailQuote WHERE intQuoteHeaderId = @QuoteHeader) IS NOT NULL
			BEGIN
				SELECT TOP 1 @detailId = intQuoteDetailId
				FROM @DataForDetailQuote
				WHERE intQuoteHeaderId = @QuoteHeader
				
				SELECT @intSpecialPriceId = intSpecialPriceId
				FROM tblTRQuoteDetail
				WHERE intQuoteDetailId = @detailId
				
				UPDATE tblTRQuoteDetail
				SET dblRackPrice = (SELECT rackID = (CASE WHEN SP.strPriceBasis = 'R' THEN [dbo].[fnTRGetRackPrice]    --[dblRackPrice]
		                                                    ( @dtmEffectiveDate
		                                                    , (SELECT intSupplyPointId
																FROM vyuTRSupplyPointView
																WHERE intEntityVendorId = SP.intRackVendorId
																	AND intEntityLocationId = SP.intRackLocationId)
		                                                    , SP.intRackItemId ) 
														WHEN SP.strPriceBasis = 'O' THEN [dbo].[fnTRGetRackPrice]    --[dblRackPrice]
															( @dtmEffectiveDate
															,(select top 1 intSupplyPointId from tblARCustomerRackQuoteVendor where intEntityCustomerLocationId = SP.intCustomerLocationId)
															,SP.intItemId )
														END)
									FROM tblARCustomerSpecialPrice SP
									WHERE SP.intSpecialPriceId = @intSpecialPriceId)
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
	END;

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