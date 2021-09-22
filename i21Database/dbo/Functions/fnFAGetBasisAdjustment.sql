CREATE FUNCTION [dbo].[fnFAGetBasisAdjustment]
(
	@intAssetId int,
	@intBookId char(5)
)
RETURNS @tblAdjustment TABLE
(
	intAssetId INT,
	intBookdId INT,
	intCurrencyId INT,
	intFunctionalCurrencyId INT,
	intCurrencyExchangeRateTypeId INT,
	dblRate NUMERIC(18, 6),
	dblAdjustment NUMERIC(18, 6),
	dblFunctionalAdjustment NUMERIC(18, 6),
	dtmDate DATETIME,
	ysnAddToBasis BIT
)
AS
BEGIN
	INSERT INTO @tblAdjustment
	SELECT  
		 BA.intAssetId
		,BA.intBookId
		,BA.intCurrencyId
		,BA.intFunctionalCurrencyId
		,BA.intCurrencyExchangeRateTypeId
		,BA.dblRate
		,SUM(BA.dblAdjustment)
		,SUM(BA.dblFunctionalAdjustment)
		,BA.dtmDate
		,BA.ysnAddToBasis
	FROM tblFABasisAdjustment BA
	OUTER APPLY (
		SELECT MAX(dtmDepreciationToDate) dtmDepreciationToDate
		FROM tblFAFixedAssetDepreciation
		WHERE intAssetId = @intAssetId AND intBookId = @intBookId AND strTransaction = 'Depreciation'
	) Depreciation
	WHERE BA.intAssetId = @intAssetId AND BA.intBookId = @intBookId AND BA.dtmDate BETWEEN Depreciation.dtmDepreciationToDate AND dbo.fnFAGetNextDepreciationDate(@intAssetId, @intBookId)
	GROUP BY
		 BA.intAssetId
		,BA.intBookId
		,BA.intCurrencyId
		,BA.intFunctionalCurrencyId
		,BA.intCurrencyExchangeRateTypeId
		,BA.dblRate
		,BA.dtmDate
		,BA.ysnAddToBasis

	RETURN
END
