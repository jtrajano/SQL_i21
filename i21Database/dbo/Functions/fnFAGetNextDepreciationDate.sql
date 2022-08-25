CREATE FUNCTION [dbo].[fnFAGetNextDepreciationDate]
(
	@intAssetId INT,
	@intBookId INT = 1,
	@intLedgerId INT = NULL
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
		WHERE intAssetId = A.intAssetId AND intBookId = @intBookId 
			AND (CASE WHEN @intLedgerId IS NOT NULL 
					THEN CASE WHEN (intLedgerId = @intLedgerId) THEN 1 ELSE 0 END
					ELSE 1 END) = 1
		ORDER BY intAssetDepreciationId DESC
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
			@dtmCurrentEndDate DATETIME = NULL

		IF (@strTransaction IN ('Basis Adjustment', 'Depreciation Adjustment') OR @strTransaction IS NULL)
		BEGIN
			-- Get end of the fiscal period where the compare date falls into.
			SELECT TOP 1 @dtmCurrentEndDate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod
			WHERE (CONVERT(DATE, dtmEndDate) = @dtmCompareDate)
			ORDER BY dtmStartDate

			IF(@dtmCurrentEndDate IS NULL) -- Compare date is not the same end date of fiscal period. Get next fiscal year period
				SELECT TOP 1 @dtmDate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod 
				WHERE CONVERT(DATE, dtmEndDate) > @dtmCompareDate ORDER BY dtmStartDate
			ELSE
				SET @dtmDate = @dtmCurrentEndDate
		END
		ELSE
			SELECT TOP 1 @dtmDate = CONVERT(DATE, dtmEndDate) FROM tblGLFiscalYearPeriod -- Get next fiscal year period
			WHERE CONVERT(DATE, dtmEndDate) > @dtmCompareDate ORDER BY dtmStartDate
	END
	ELSE
		SET @dtmDate = @dtmCompareDate

	RETURN @dtmDate
END