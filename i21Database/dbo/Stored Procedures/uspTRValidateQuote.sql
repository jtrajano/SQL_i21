CREATE PROCEDURE [dbo].[uspTRValidateQuote]
	@intQuoteHeaderId INT,
	@ysnValid BIT = 1 OUTPUT	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN

	SET @ysnValid = 1

	DECLARE @LineItems LineItemTaxDetailStagingTable
		,@intItemId INT = NULL
		,@intCustomerId INT = NULL
		,@intTaxGroupId INT = NULL
		,@intShipToLocationId INT = NULL
		,@intSpecialPriceId INT = NULL
		,@dtmEffectiveDate DATETIME = NULL
		,@intItemUOMId INT = NULL 

	DECLARE @tmpQuoteTaxDetail TABLE(intTaxCodeId INT NULL, dblTax NUMERIC(18,6) NULL, strType NVARCHAR(10) NULL)

	SELECT  @dtmEffectiveDate = dtmQuoteEffectiveDate, @intCustomerId = intEntityCustomerId
	FROM tblTRQuoteHeader 
	WHERE intQuoteHeaderId = @intQuoteHeaderId		

	DECLARE @CursorQuoteDetail CURSOR
	SET @CursorQuoteDetail = CURSOR FOR
	SELECT  QD.intItemId
		, EL.intEntityLocationId
		, SpecialPrice.intSpecialPriceId
		, EL.intTaxGroupId
	FROM tblEMEntityLocation EL
	LEFT JOIN vyuTRQuoteSelection QD ON QD.intEntityCustomerId = @intCustomerId
		AND QD.intEntityCustomerLocationId = EL.intEntityLocationId
	LEFT JOIN vyuTRSupplyPointView SP ON QD.intSupplyPointId = SP.intSupplyPointId
	CROSS APPLY(
		SELECT TOP 1 intSpecialPriceId
		FROM tblARCustomerSpecialPrice ARPrice
		WHERE ARPrice.intItemId = QD.intItemId
			AND ARPrice.intEntityCustomerId = @intCustomerId
			AND ARPrice.intCustomerLocationId = EL.intEntityLocationId
			AND ((ARPrice.strPriceBasis = 'O'
					AND ARPrice.intEntityVendorId = SP.intEntityVendorId
					AND ARPrice.intEntityLocationId = SP.intEntityLocationId)
			OR (ARPrice.strPriceBasis = 'R'
					AND ARPrice.intRackVendorId = SP.intEntityVendorId
					AND ARPrice.intRackLocationId = SP.intEntityLocationId)
	)) SpecialPrice
	WHERE QD.ysnQuote = 1
	AND EL.intEntityId = @intCustomerId

	OPEN @CursorQuoteDetail
    FETCH NEXT FROM @CursorQuoteDetail INTO @intItemId, @intShipToLocationId, @intSpecialPriceId, @intTaxGroupId
    WHILE @@FETCH_STATUS = 0
    BEGIN

		SET @intItemUOMId = [dbo].[fnGetItemStockUOM](@intItemId)

		DECLARE @dblQuotePrice NUMERIC(18,6) = NULL

		INSERT INTO @tmpQuoteTaxDetail 
		SELECT DT.intTaxCodeId
			,DT.dblTax 
			,'SETUP' strType
		FROM tblTRQuoteDetailTax DT
		INNER JOIN tblTRQuoteDetail QD ON QD.intQuoteDetailId = DT.intQuoteDetailId
		WHERE QD.intQuoteHeaderId = @intQuoteHeaderId
		AND QD.intItemId = @intItemId
		AND QD.intShipToLocationId = @intShipToLocationId
		AND QD.intSpecialPriceId = @intSpecialPriceId
		AND QD.intTaxGroupId = @intTaxGroupId


		SELECT @dblQuotePrice = QD.dblQuotePrice
		FROM tblTRQuoteDetailTax DT
		INNER JOIN tblTRQuoteDetail QD ON QD.intQuoteDetailId = DT.intQuoteDetailId
		WHERE QD.intQuoteHeaderId = @intQuoteHeaderId
		AND QD.intItemId = @intItemId
		AND QD.intShipToLocationId = @intShipToLocationId
		AND QD.intSpecialPriceId = @intSpecialPriceId
		AND QD.intTaxGroupId = @intTaxGroupId
		
		INSERT INTO @tmpQuoteTaxDetail 
		SELECT intTaxCodeId
			,dblTax = CASE WHEN (ISNULL(dblTax, 0) = 0) THEN 0 ELSE (dblTax / 100000) END
			,'QUOTE' strType
		FROM dbo.fnConstructLineItemTaxDetail (
			100000
			, @dblQuotePrice
			, @LineItems
			, 0
			, @intItemId
			, @intCustomerId
			, @intShipToLocationId
			, @intTaxGroupId
			, @dblQuotePrice
			, @dtmEffectiveDate
			, NULL
			, 1
			, 1			--@IncludeInvalidCodes
			, NULL
			, NULL
			, NULL
			, NULL
			, 0
			, 0
			, @intItemUOMId	--intItemUOMId
			, NULL  --@CFSiteId
			, 0		--@IsDeliver
			, 0     --@IsCFQuote
			,NULL --@CurrencyId
			,NULL -- @CurrencyExchangeRateTypeId
			,NULL -- @@CurrencyExchangeRate	
		)

		--CHECK IF HAS DIFFERENT TAX CODE
		IF EXISTS(SELECT COUNT(intTaxCodeId), intTaxCodeId FROM @tmpQuoteTaxDetail
		GROUP BY intTaxCodeId
		HAVING COUNT(intTaxCodeId) < 2)
		BEGIN
			RAISERROR('Quote cannot be Confirmed because Customer Location''s current Tax Group has changed since this Quote was created',16,1)
			SET @ysnValid = 0
			RETURN
		END
		ELSE IF ((SELECT SUM(dblTax) FROM @tmpQuoteTaxDetail WHERE strType = 'QUOTE') <> (SELECT SUM(dblTax) FROM @tmpQuoteTaxDetail WHERE strType = 'SETUP'))
		BEGIN
			RAISERROR('Quote cannot be Confirmed because Customer Location''s current Tax Group has changed since this Quote was created',16,1)
			SET @ysnValid = 0
			RETURN
		END

		FETCH NEXT FROM @CursorQuoteDetail INTO @intItemId, @intShipToLocationId, @intSpecialPriceId, @intTaxGroupId
	END
	CLOSE @CursorQuoteDetail
    DEALLOCATE @CursorQuoteDetail

END