CREATE FUNCTION [dbo].[fnFAGetBasisAdjustment]
(
	@intAssetId INT,
	@intBookId INT = 1
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
	ysnAddToBasis BIT,
	strAdjustmentType NVARCHAR(100)
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
		,BA.strAdjustmentType
	FROM tblFABasisAdjustment BA
	OUTER APPLY (
		SELECT TOP 1 dtmDepreciationToDate
		FROM tblFAFixedAssetDepreciation
		WHERE intAssetId = @intAssetId AND intBookId = @intBookId AND strTransaction = 'Depreciation'
		ORDER BY intAssetDepreciationId DESC
	) Depreciation
	WHERE BA.intAssetId = @intAssetId AND BA.intBookId = @intBookId AND BA.dtmDate BETWEEN DATEADD(DAY,1, Depreciation.dtmDepreciationToDate) AND dbo.fnFAGetNextDepreciationDate(@intAssetId, @intBookId, NULL)
	GROUP BY
		 BA.intAssetId
		,BA.intBookId
		,BA.intCurrencyId
		,BA.intFunctionalCurrencyId
		,BA.intCurrencyExchangeRateTypeId
		,BA.dblRate
		,BA.dtmDate
		,BA.ysnAddToBasis
		,BA.strAdjustmentType
	RETURN
END