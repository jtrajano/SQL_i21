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
		@dtmPlacedInService = CASE WHEN ISNULL(A.ysnImported, 0) = 1 THEN A.dtmCreateAssetPostDate ELSE A.dtmDateInService END, 
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
						CAST((DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @dtmPlacedInService) + 1, 0))) AS DATE)
					END
			ELSE 
				CASE WHEN ISNULL(@intBookId, 1) = 1
					THEN 
						@dtmDepreciationToDate
					ELSE
						CASE WHEN (CAST((DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @dtmDepreciationToDate) + 1, 0))) AS DATE) = @dtmDepreciationToDate) 
							THEN 
								CASE WHEN @strTransaction IN ('Basis Adjustment', 'Depreciation Adjustment')
									THEN @dtmDepreciationToDate
									ELSE DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, (@dtmDepreciationToDate)) + 2, 0))
									END
							ELSE CAST((DATEADD(s, -1, DATEADD(mm, DATEDIFF(m, 0, @dtmDepreciationToDate) + 1, 0))) AS DATE)
						END
					END
		END

	
	IF (ISNULL(@intBookId, 1) = 1)
	BEGIN
		DECLARE
			@dtmCurrentEndate DATETIME

		SELECT TOP 1 @dtmCurrentEndate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod -- If PlacedInService or Adjustment is equal to the fiscal period's end date, next depreciation to date should be same with PlacedInService date
		WHERE 
			CONVERT(DATE, dtmEndDate) = @dtmPlacedInService OR 
			(@strTransaction IN ('Basis Adjustment', 'Depreciation Adjustment') AND CONVERT(DATE, dtmEndDate) = @dtmDepreciationToDate)
			ORDER BY dtmStartDate

		IF (@dtmCurrentEndate IS NOT NULL AND (@ysnDepreciated = 0 OR @strTransaction IN ('Basis Adjustment', 'Depreciation Adjustment')))
			SET @dtmDate = @dtmCurrentEndate
		ELSE
			SELECT TOP 1 @dtmDate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod -- Get next fiscal year period
			WHERE CONVERT(DATE, dtmEndDate) > @dtmCompareDate ORDER BY dtmStartDate
	END
	ELSE
		SET @dtmDate = @dtmCompareDate

	RETURN @dtmDate
END