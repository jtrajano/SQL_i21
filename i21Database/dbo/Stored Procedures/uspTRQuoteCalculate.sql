CREATE PROCEDURE [dbo].[uspTRQuoteCalculate]
	@intQuoteDetailId AS INT,
	@dblQuotePrice AS NUMERIC(18,6),
	@ysnUpdateTax BIT = 0,
	@dblTax AS NUMERIC(18,6) OUT
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

	SET @dblTax = 0

	DECLARE @LineItems LineItemTaxDetailStagingTable,
		@intItemId INT = NULL,
		@intCustomerId INT = NULL,
		@intShipToLocationId INT = NULL,
		@intTaxGroupId INT = NULL,
		@dtmEffectiveDate DATETIME = NULL,
		@intUOMId INT = NULL

	SELECT @intItemId = QD.intItemId
		, @intCustomerId = QH.intEntityCustomerId
		, @intShipToLocationId = QD.intShipToLocationId
		, @intTaxGroupId = QD.intTaxGroupId 
		, @dtmEffectiveDate = QH.dtmQuoteEffectiveDate
	FROM tblTRQuoteDetail QD
	INNER JOIN tblTRQuoteHeader QH ON  QH.intQuoteHeaderId = QD.intQuoteHeaderId
	WHERE intQuoteDetailId = @intQuoteDetailId
	
	SET @intUOMId = [dbo].[fnGetItemStockUOM](@intItemId)

	DECLARE @tblCalculateTax TABLE(intTaxCodeId INT
		, intTaxGroupId INT
		, intTaxClassId INT
		, strTaxableByOtherTaxes NVARCHAR(500)
		, strCalculationMethod NVARCHAR(100)
		, dblRate NUMERIC(18,6)
		, dblBaseRate NUMERIC(18,6)
		, dblTax NUMERIC(18,6)
		, dblAdjustedTax NUMERIC(18,6)
		, intTaxAccountId INT
		, ysnCheckoffTax BIT
		, strTaxCode NVARCHAR(100)
		, ysnTaxExempt BIT)

	 INSERT INTO @tblCalculateTax
	 SELECT intTaxCodeId 
		, intTaxGroupId
		, intTaxClassId
		, strTaxableByOtherTaxes
		, strCalculationMethod
		, dblRate
		, dblBaseRate
		, dblTax = CASE WHEN (ISNULL(dblTax, 0) = 0) THEN 0 ELSE (dblTax / 100000) END
		, dblAdjustedTax = CASE WHEN (ISNULL(dblAdjustedTax, 0) = 0) THEN 0 ELSE (dblAdjustedTax / 100000) END
		, intTaxAccountId
		, ysnCheckoffTax
		, strTaxCode
		, ysnTaxExempt
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
		, @intUOMId	--intItemUOMId
		, NULL  --@CFSiteId
		, 0		--@IsDeliver
		, 0     --@IsCFQuote
		,NULL --@CurrencyId
		,NULL -- @CurrencyExchangeRateTypeId
		,NULL -- @@CurrencyExchangeRate	
	)

	IF (@ysnUpdateTax = 1)
	BEGIN
		UPDATE tblTRQuoteDetailTax 
			SET intTaxClassId = CT.intTaxClassId
			, strTaxableByOtherTaxes = CT.strTaxableByOtherTaxes
			, strCalculationMethod = CT.strCalculationMethod
			, dblRate = CT.dblRate
			, dblTax = CT.dblTax
			, dblAdjustedTax = CT.dblAdjustedTax
			, intTaxAccountId = CT.intTaxAccountId
			, strTaxCode = CT.strTaxCode
		FROM @tblCalculateTax CT
			INNER JOIN tblTRQuoteDetailTax DT ON DT.intTaxCodeId = CT.intTaxCodeId
		WHERE DT.intQuoteDetailId = @intQuoteDetailId
		AND DT.dblTax <> CT.dblTax
	END
	ELSE  
	BEGIN
		SELECT @dblTax = ISNULL(SUM(CT.dblTax), 0) FROM @tblCalculateTax CT
		INNER JOIN tblTRQuoteDetailTax DT ON DT.intTaxCodeId = CT.intTaxCodeId	
		WHERE DT.intQuoteDetailId = @intQuoteDetailId
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
	)
END CATCH
