CREATE PROCEDURE [dbo].[uspMBRecalculateMeterReading]
	@TransactionId INT
AS

BEGIN

	SELECT *
	INTO #tmpMeterReading
	FROM vyuMBGetMeterReadingDetail
	WHERE intMeterReadingId = @TransactionId

	DECLARE @MeterReadingDetailId INT
		, @ItemId INT
		, @CustomerId INT	
		, @LocationId INT
		, @TaxGroupId INT
		, @TransactionDate DATETIME
		, @Amount NUMERIC(18,6)
		, @Price NUMERIC(18,6)
		, @IsReversal BIT
		, @LineItems LineItemTaxDetailStagingTable
		, @TaxTotal NUMERIC(18,6)
		, @PriceType NVARCHAR(20)
		, @ItemUOMId INT

	WHILE EXISTS ( SELECT TOP 1 1 FROM #tmpMeterReading)
	BEGIN

		SELECT TOP 1 @MeterReadingDetailId = intMeterReadingDetailId 
			, @ItemId = intItemId
			, @CustomerId = intEntityCustomerId
			, @LocationId = intCompanyLocationId
			, @TransactionDate = dtmTransaction
			, @TaxGroupId = intTaxGroupId
			, @Amount = (CASE WHEN strPriceType = 'Gross' THEN ISNULL(dblGrossPrice, 0)
							ELSE ISNULL(dblNetPrice, 0) END)
			, @Price = (CASE WHEN strPriceType = 'Gross' THEN ISNULL(dblGrossPrice, 0)
							ELSE ISNULL(dblNetPrice, 0) END)
			, @IsReversal = (CASE WHEN strPriceType = 'Gross' THEN 1
							ELSE 0 END)
			, @PriceType = strPriceType
			, @ItemUOMId = intItemUOMId 
		FROM #tmpMeterReading

		SELECT dblAdjustedTax, ysnTaxExempt
		INTO #tmpTaxes
		FROM dbo.fnConstructLineItemTaxDetail (
			1
			, @Amount
			, @LineItems
			, @IsReversal
			, @ItemId
			, @CustomerId
			, @LocationId
			, @TaxGroupId
			, @Price
			, @TransactionDate
			, NULL
			, 1
			, 0			--@IncludeInvalidCodes
			, NULL
			, NULL
			, NULL
			, NULL
			, 0
			, 0
			, @ItemUOMId
			,NULL   --@CFSiteId
			,0		--@IsDeliver
			,0      --@IsCFQuote
			,NULL --@CurrencyId
			,NULL -- @CurrencyExchangeRateTypeId
			,NULL -- @@CurrencyExchangeRate	
		)

		SELECT @TaxTotal = ISNULL(SUM(ISNULL(dblAdjustedTax, 0)), 0)
		FROM #tmpTaxes 
		WHERE ysnTaxExempt = 0

		IF (@PriceType = 'Gross')
		BEGIN
			UPDATE tblMBMeterReadingDetail
			SET dblNetPrice = @Amount - @TaxTotal
			WHERE intMeterReadingDetailId = @MeterReadingDetailId
		END
		ELSE
		BEGIN
			UPDATE tblMBMeterReadingDetail
			SET dblGrossPrice = @Price + @TaxTotal
			WHERE intMeterReadingDetailId = @MeterReadingDetailId
		END

		DROP TABLE #tmpTaxes

		DELETE FROM #tmpMeterReading WHERE intMeterReadingDetailId = @MeterReadingDetailId

	END

	DROP TABLE #tmpMeterReading

END