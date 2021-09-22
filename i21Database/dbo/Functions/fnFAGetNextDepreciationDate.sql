CREATE FUNCTION [dbo].[fnFAGetNextDepreciationDate]
(
	@intAssetId INT,
	@intBookId INT = 1
)
RETURNS DATETIME
AS
BEGIN
	DECLARE 
		@dtmDate DATETIME,
		@dtmPlacedInService DATETIME,
		@dtmDepreciationToDate DATETIME,
		@dtmCompareDate DATETIME,
		@strTransaction NVARCHAR(100),
		@ysnDepreciated BIT

	SELECT 
		@dtmDepreciationToDate = Depreciation.dtmDepreciationToDate,
		@dtmPlacedInService = A.dtmDateInService, 
		@strTransaction = Depreciation.strTransaction,
		@ysnDepreciated = CASE WHEN (Depreciation.strTransaction = 'Place in service' OR Depreciation.strTransaction IS NULL) THEN 0 ELSE 1 END
	FROM tblFAFixedAsset A
	OUTER APPLY (
		SELECT TOP 1 dtmDepreciationToDate, strTransaction FROM tblFAFixedAssetDepreciation
		WHERE intAssetId = A.intAssetId AND intBookId = @intBookId ORDER BY intAssetDepreciationId DESC
	) Depreciation

	WHERE A.intAssetId = @intAssetId

	SET @dtmCompareDate = 
		CASE WHEN @ysnDepreciated = 0 
			THEN 
				CASE WHEN ISNULL(@intBookId, 1) = 1
					THEN 
						@dtmPlacedInService
					ELSE
						EOMONTH(@dtmPlacedInService)
					END
			ELSE 
				CASE WHEN ISNULL(@intBookId, 1) = 1
					THEN 
						@dtmDepreciationToDate
					ELSE
						CASE WHEN (EOMONTH(@dtmDepreciationToDate) = @dtmDepreciationToDate) 
							THEN
								CASE WHEN @strTransaction = 'Adjustment'
									THEN @dtmDepreciationToDate
									ELSE DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (@dtmDepreciationToDate)) + 2, 0))
									END
							ELSE EOMONTH(@dtmDepreciationToDate)
						END
					END
		END

	
	IF (ISNULL(@intBookId, 1) = 1)
	BEGIN
		DECLARE
			@dtmCurrentEndate DATETIME

		SELECT TOP 1 @dtmCurrentEndate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod -- If PlacedInService is equal to the fiscal period end date, next depreciation to date should be same with PlacedInService date
		WHERE CONVERT(DATE, dtmEndDate) = @dtmPlacedInService ORDER BY dtmStartDate

		IF (@ysnDepreciated = 0 AND @dtmCurrentEndate IS NOT NULL)
			SET @dtmDate = @dtmCurrentEndate
		ELSE
			SELECT TOP 1 @dtmDate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod -- Get next fiscal year period
			WHERE CONVERT(DATE, dtmEndDate) > @dtmCompareDate ORDER BY dtmStartDate
	END
	ELSE
		SET @dtmDate = @dtmCompareDate

	RETURN @dtmDate
END