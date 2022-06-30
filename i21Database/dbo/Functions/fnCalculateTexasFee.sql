CREATE FUNCTION [dbo].[fnCalculateTexasFee](
	  @intTaxCodeId AS INT
	, @dtmTransDate AS DATETIME	
	, @dblTotalGals DECIMAL(18, 6) = 0
	, @dblTotalGasGals DECIMAL(18, 6) = 0
)
RETURNS DECIMAL (18, 6)
AS
BEGIN
	DECLARE @dtmEffectiveDate AS DATETIME
	DECLARE @intTaxCodeRateId AS INT
	DECLARE @dblFeeAmountOut AS NUMERIC(18, 6) = 0 
	DECLARE @tblTaxCodeLoadingFee TABLE(intTaxCodeRateLoadingFeeId INT
		, dblTotalGalsFrom DECIMAL(18, 6)
		, dblTotalGalsTo DECIMAL(18, 6)
		, dblTotalGasGalFrom DECIMAL(18, 6)
		, dblTotalGasGalTo DECIMAL(18, 6)
		, dblIncrementalGals DECIMAL(18, 6)
		, dblIncrementalAmount DECIMAL(18, 6)
		, dblFeeAmount NUMERIC(18, 6))
	

	-- SELECT EFFECTIVE DATE
	SELECT TOP 1 @dtmEffectiveDate = TCR.dtmEffectiveDate, @intTaxCodeRateId = TCR.intTaxCodeRateId 
	FROM tblSMTaxCode TC
		INNER JOIN tblSMTaxCodeRate TCR ON TC.intTaxCodeId = TCR.intTaxCodeId
		INNER JOIN tblSMTaxCodeRateLoadingFee TLF ON TCR.intTaxCodeRateId = TLF.intTaxCodeRateId
	WHERE TC.intTaxCodeId = @intTaxCodeId 
		AND TCR.dtmEffectiveDate <= @dtmTransDate
	ORDER BY TCR.dtmEffectiveDate DESC


	--TODO:: IF (no record found, return error)
	INSERT INTO @tblTaxCodeLoadingFee
	SELECT TLF.intTaxCodeRateLoadingFeeId
		, TLF.dblTotalGalsFrom
		, TLF.dblTotalGalsTo
		, TLF.dblGasolineGalsFrom
		, TLF.dblGasolineGalsTo
		, TLF.dblIncrementalGals
		, TLF.dblIncrementalAmount
		, TLF.dblFeeAmount
	FROM tblSMTaxCodeRate TCR
		INNER JOIN tblSMTaxCodeRateLoadingFee TLF ON TCR.intTaxCodeRateId = TLF.intTaxCodeRateId
	WHERE TCR.dtmEffectiveDate = @dtmEffectiveDate
		AND TLF.intTaxCodeRateId = @intTaxCodeRateId
		AND @dblTotalGals BETWEEN dblTotalGalsFrom AND dblTotalGalsTo



	DECLARE @totalGalsFrom  DECIMAL(18, 6) = 0
	DECLARE @incrementalGals DECIMAL(18, 6) = 0
	DECLARE @incrementalFeeAmount DECIMAL(18, 6) = 0
	DECLARE @feeAmount DECIMAL(18, 6) = 0

	IF((SELECT COUNT(intTaxCodeRateLoadingFeeId) FROM @tblTaxCodeLoadingFee) = 1)
	BEGIN
		IF(ISNULL((SELECT TOP 1 dblIncrementalGals FROM @tblTaxCodeLoadingFee), 0) > 0)
		BEGIN
			SELECT TOP 1 @incrementalGals = dblIncrementalGals
				, @incrementalFeeAmount = dblIncrementalAmount 
				, @totalGalsFrom = dblTotalGalsFrom
				, @feeAmount = dblFeeAmount
			FROM @tblTaxCodeLoadingFee

			SET @dblFeeAmountOut = ISNULL(@feeAmount, 0) + dbo.[fnGetIncrementalAmount](@dblTotalGals, @totalGalsFrom, @incrementalGals, @incrementalFeeAmount)
		END
		ELSE
		BEGIN
			SELECT TOP 1 @dblFeeAmountOut = ISNULL(dblFeeAmount, 0) FROM @tblTaxCodeLoadingFee
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @incrementalGals = dblIncrementalGals
			, @incrementalFeeAmount = dblIncrementalAmount 
			, @totalGalsFrom = dblTotalGalsFrom
			, @feeAmount = dblFeeAmount
		FROM @tblTaxCodeLoadingFee
		WHERE (@dblTotalGasGals BETWEEN ISNULL(dblTotalGasGalFrom, 0) AND ISNULL(dblTotalGasGalTo, 0))

		IF(ISNULL(@incrementalGals, 0) > 0)
		BEGIN
			SET @dblFeeAmountOut = ISNULL(@feeAmount, 0) + dbo.[fnGetIncrementalAmount](@dblTotalGals, @totalGalsFrom, @incrementalGals, @incrementalFeeAmount)
		END
		ELSE
		BEGIN
			SET @dblFeeAmountOut = @feeAmount
		END
	END

RETURN @dblFeeAmountOut

END