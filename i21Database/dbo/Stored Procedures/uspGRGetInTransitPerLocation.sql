CREATE PROCEDURE [dbo].[uspGRGetInTransitPerLocation] 
	@dtmDate DATE = NULL
	,@intCommodityId INT = NULL
	,@intItemId INT = NULL
	,@intLocationId INT = NULL
	,@Locations Id READONLY
AS

BEGIN
	SELECT intCompanyLocationId = intId
	INTO #LicensedLocation
	FROM @Locations

	IF (SELECT COUNT(*) FROM #LicensedLocation) = 0
	BEGIN
		INSERT INTO #LicensedLocation
		SELECT @intLocationId
	END
	
	DECLARE @intCommodityUnitMeasureId AS INT
		,@intCommodityStockUOMId INT
	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		,@intCommodityStockUOMId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnStockUnit = 1
			
	;WITH N1 (N) AS (SELECT 1 FROM (VALUES (1), (1), (1), (1), (1), (1), (1), (1), (1), (1)) n (N)),
	N2 (N) AS (SELECT 1 FROM N1 AS N1 CROSS JOIN N1 AS N2),
	N3 (N) AS (SELECT 1 FROM N2 AS N1 CROSS JOIN N2 AS N2),
	Dates AS
	(	SELECT TOP (DATEDIFF(DAY,  DATEADD(day,-2,@dtmDate), @dtmDate))
				Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY N), DATEADD(day,-2,@dtmDate))
		FROM N3
	)
	SELECT Date
	INTO #tempDateRange
	FROM Dates AS d

	SELECT Date
	INTO #tempDateRange2
	FROM #tempDateRange AS d
	WHERE Date = @dtmDate

	SELECT *
	INTO #InTransitDateRange
	FROM (
		SELECT
			dtmDate = InTran.dtmTransactionDate
			,strTransactionNumber
			,dblInTransitQty = SUM(CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
								THEN CASE WHEN uomTo.dblUnitQty <> 0 
									THEN CAST((ISNULL((InTran.dblTotal), 0) * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
									ELSE NULL
									END
								ELSE ISNULL((InTran.dblTotal), 0)
								END)
			,intLocationId
			,strLocationName
		FROM dbo.fnRKGetBucketInTransit(@dtmDate,@intCommodityId,NULL) InTran
		LEFT JOIN tblICCommodityUnitMeasure uomFrom
			ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
		LEFT JOIN tblICCommodityUnitMeasure uomTo
			ON uomTo.intCommodityUnitMeasureId = @intCommodityUnitMeasureId
		WHERE InTran.strBucketType = 'Sales In-Transit'
			AND InTran.intItemId = ISNULL(@intItemId, InTran.intItemId)
			AND (InTran.intLocationId = ISNULL(@intLocationId,InTran.intLocationId)
			OR InTran.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation))
		GROUP BY InTran.dtmTransactionDate
			,strTransactionNumber
			,intLocationId
			,strLocationName
	) A
	WHERE dblInTransitQty <> 0

		--select '#InTransitDateRange',* from #InTransitDateRange order by dtmDate
			
	DECLARE @tblBalanceInvByDate AS TABLE
	(
		dtmDate DATE NULL
		,intLocationId INT
		,strLocationName NVARCHAR(500) COLLATE Latin1_General_CI_AS
		,dblBeginningSalesInTransit DECIMAL(18,6)
		,dblSalesInTransit DECIMAL(18,6)
	)

	DECLARE @date DATE
		, @dblSalesInTransitAsOf DECIMAL(18,6)
	
	--BEGINNING
	WHILE EXISTS(SELECT TOP 1 1 FROM #tempDateRange)
	BEGIN
		SELECT TOP 1 @date = Date FROM #tempDateRange
		
		INSERT INTO @tblBalanceInvByDate
		(
			dtmDate
			,intLocationId
			,strLocationName
			,dblBeginningSalesInTransit			
		)
		SELECT @date
			,intLocationId
			,strLocationName
			,SUM(dblInTransitQty)
		FROM #InTransitDateRange WHERE dtmDate <= @date
		GROUP BY intLocationId
			,strLocationName

		DELETE #tempDateRange WHERE Date = @date
	END

	--CURRENT
	DECLARE @intLocId INT
	WHILE EXISTS(SELECT TOP 1 1 FROM #tempDateRange2)
	BEGIN
		SELECT TOP 1 @date = Date FROM #tempDateRange2

		SELECT @intLocId = MIN(intCompanyLocationId) FROM #LicensedLocation

		WHILE ISNULL(@intLocId,0) > 0
		BEGIN
			SET @dblSalesInTransitAsOf = NULL

			--TOTAL INVENTORY SHIPMENT FOR THE DAY
			SELECT @dblSalesInTransitAsOf = SUM(ISNULL(InTran.dblInTransitQty, 0))
			FROM #InTransitDateRange InTran
			OUTER APPLY (
				SELECT TOP 1 ysnIsUnposted
				FROM tblICInventoryTransaction 
				WHERE strTransactionId = InTran.strTransactionNumber
					AND ysnIsUnposted = 0
			) IT
			WHERE InTran.dtmDate = @date
				AND InTran.dblInTransitQty > 0
				AND IT.ysnIsUnposted IS NOT NULL
				AND intLocationId = @intLocId

			UPDATE @tblBalanceInvByDate
			SET dblBeginningSalesInTransit = @dblSalesInTransitAsOf
			WHERE dtmDate = @date
				AND intLocationId = @intLocId

			--SELECT '@tblBalanceInvByDate1',* FROM @tblBalanceInvByDate

			--TOTAL INVOICE FOR THE DAY
			SELECT @dblSalesInTransitAsOf = SUM(ISNULL(InTran.dblInTransitQty, 0))
			FROM #InTransitDateRange InTran
			OUTER APPLY (
				SELECT TOP 1 ysnIsUnposted
				FROM tblICInventoryTransaction 
				WHERE strTransactionId = InTran.strTransactionNumber
					AND ysnIsUnposted = 0
			) IT
			WHERE InTran.dtmDate = @date
				AND InTran.dblInTransitQty < 0
				AND IT.ysnIsUnposted IS NOT NULL
				AND intLocationId = @intLocId

			UPDATE @tblBalanceInvByDate
			SET dblSalesInTransit = @dblSalesInTransitAsOf
			WHERE dtmDate = @date
				AND intLocationId = @intLocId

			SELECT @intLocId = MIN(intCompanyLocationId) FROM #LicensedLocation WHERE intCompanyLocationId > @intLocId
		END		
		
		DELETE #tempDateRange2 WHERE Date = @date
	END

	SELECT * FROM @tblBalanceInvByDate

	DROP TABLE #LicensedLocation
END