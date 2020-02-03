CREATE PROCEDURE [dbo].[uspRKGetConsolidatedCoverageEntryDetail]
	@IDs NVARCHAR(MAX)

AS

BEGIN
	DECLARE @intCoverageEntryId INT
	DECLARE @CoverageEntryDetails TABLE (intProductTypeId INT
		, strProductType NVARCHAR(100)
		, intBookId INT
		, strBook NVARCHAR(100)
		, intSubBookId INT
		, strSubBook NVARCHAR(100)
		, dblOpenContract NUMERIC(24, 10)
		, dblInTransit NUMERIC(24, 10)
		, dblStock NUMERIC(24, 10)
		, dblTotalPhysical NUMERIC(24, 10)
		, dblOpenFutures NUMERIC(24, 10)
		, dblTotalPosition NUMERIC(24, 10)
		, dblMonthsCovered NUMERIC(24, 10)
		, dblAveragePrice NUMERIC(24, 10)
		, dblOptionsCovered NUMERIC(24, 10)
		, dblFuturesM2M NUMERIC(24, 10)
		, dblM2MPlus10 NUMERIC(24, 10)
		, dblM2MMinus10 NUMERIC(24, 10))

	SELECT DISTINCT intId = Item Collate Latin1_General_CI_AS
	INTO #tmpIdList
	FROM [dbo].[fnSplitString](@IDs, ',')

	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpIdList)
	BEGIN
		SELECT TOP 1 @intCoverageEntryId = intId FROM #tmpIdList

		INSERT INTO @CoverageEntryDetails
		SELECT intProductTypeId
			, strProductType
			, intBookId
			, strBook
			, intSubBookId
			, strSubBook
			, dblOpenContract
			, dblInTransit
			, dblStock
			, dblTotalPhysical
			, dblOpenFutures
			, dblTotalPosition
			, dblMonthsCovered
			, dblAveragePrice
			, dblOptionsCovered
			, dblFuturesM2M
			, dblM2MPlus10
			, dblM2MMinus10
		FROM vyuRKGetCoverageEntryDetail WHERE intCoverageEntryId = @intCoverageEntryId

		DELETE FROM #tmpIdList WHERE intId = @intCoverageEntryId
	END

	DROP TABLE #tmpIdList

	SELECT intProductTypeId
		, strProductType
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook
		, dblOpenContract = SUM(ISNULL(dblOpenContract, 0))
		, dblInTransit = SUM(ISNULL(dblInTransit, 0))
		, dblStock = SUM(ISNULL(dblStock, 0))
		, dblTotalPhysical = SUM(ISNULL(dblTotalPhysical, 0))
		, dblOpenFutures = SUM(ISNULL(dblOpenFutures, 0))
		, dblTotalPosition = SUM(ISNULL(dblTotalPosition, 0))
		, dblMonthsCovered = SUM(ISNULL(dblMonthsCovered, 0))
		, dblAveragePrice = SUM(ISNULL(dblAveragePrice, 0))
		, dblOptionsCovered = SUM(ISNULL(dblOptionsCovered, 0))
		, dblFuturesM2M = SUM(ISNULL(dblFuturesM2M, 0))
		, dblM2MPlus10 = SUM(ISNULL(dblM2MPlus10, 0))
		, dblM2MMinus10 = SUM(ISNULL(dblM2MMinus10, 0))
	FROM @CoverageEntryDetails
	GROUP BY intProductTypeId
		, strProductType
		, intBookId
		, strBook
		, intSubBookId
		, strSubBook

END