CREATE PROCEDURE [dbo].[uspRKGetInHouse] 
	  @dtmFromTransactionDate DATE = NULL
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = NULL
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL 

AS

BEGIN
	SELECT intCompanyLocationId
	INTO #LicensedLocation
	FROM tblSMCompanyLocation
	WHERE isnull(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 
										WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE isnull(ysnLicensed, 0) END
	
	DECLARE @intCommodityUnitMeasureId AS INT
		, @intCommodityStockUOMId INT
	
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
		, @intCommodityStockUOMId = intUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnStockUnit = 1

	SELECT * 
	INTO #tmpDelayedPricing
	FROM dbo.fnRKGetBucketDelayedPricing(@dtmToTransactionDate,@intCommodityId,NULL)
	
	CREATE NONCLUSTERED INDEX IX_tmpDelayedPricing_intTransactionRecordId
	ON #tmpDelayedPricing (intTransactionRecordId);
	
	DECLARE @tblResult TABLE (Id INT IDENTITY
		, dtmDate DATE
		, dblTotal NUMERIC(18,6)
		, strTransactionType NVARCHAR(100)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(50)
		, strOwnership NVARCHAR(20))

	SELECT * 
	INTO #tmpInHouseResult
	FROM @tblResult

	--=============================
	-- Company Owned
	--=============================
	INSERT INTO #tmpInHouseResult (dtmDate
		, dblTotal
		, strTransactionType
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strOwnership)
	SELECT
		  dtmDate = CONVERT(DATE, dtmTransactionDate) -- CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110)
		-- RM-4507: dblTotal = Replaced fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
		, dblTotal = CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
							THEN CASE WHEN uomTo.dblUnitQty <> 0 
								THEN CAST((dblTotal * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
								ELSE NULL
								END
							ELSE dblTotal
							END
		, strTransactionType
		, strTransactionId  = strTransactionNumber
		, intTransactionId = intTransactionRecordHeaderId
		, CASE WHEN (SELECT TOP 1 1 FROM tblGRSettleContract WHERE intSettleStorageId = CompOwn.intTransactionRecordId) = 1 THEN 'CNT'
			WHEN (SELECT TOP 1 1 FROM #tmpDelayedPricing WHERE intTransactionRecordId = CompOwn.intTransactionRecordHeaderId) = 1 THEN 'DP'
			WHEN CompOwn.intContractHeaderId IS NOT NULL 
				THEN ISNULL(
			     (SELECT TOP 1 strDistributionOption FROM tblSCTicket WHERE intTicketId = CompOwn.intTicketId and intContractId = CompOwn.intContractDetailId),
				 (SELECT TOP 1 'CNT' FROM tblSCTicketContractUsed WHERE intTicketId = CompOwn.intTicketId and intContractDetailId = CompOwn.intContractDetailId) )
			WHEN CompOwn.strTransactionType = 'Inventory Adjustment' THEN 'ADJ'
			WHEN CompOwn.strTransactionType IN ('Inventory Receipt','Inventory Shipment') AND CompOwn.intContractHeaderId IS NULL AND CompOwn.intTicketId IS NULL THEN ''
			ELSE ST.strStorageTypeCode END
		,strOwnership = 'Company Owned'
	FROM dbo.fnRKGetBucketCompanyOwned(@dtmToTransactionDate,@intCommodityId,NULL) CompOwn
	LEFT JOIN tblGRStorageType ST ON ST.strStorageTypeDescription = CompOwn.strDistributionType
	LEFT JOIN tblICCommodityUnitMeasure uomFrom
		ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
	LEFT JOIN tblICCommodityUnitMeasure uomTo
		ON uomTo.intCommodityUnitMeasureId = @intCommodityUnitMeasureId
	WHERE CompOwn.intItemId = ISNULL(@intItemId, CompOwn.intItemId)
		AND CompOwn.intLocationId = ISNULL(@intLocationId, CompOwn.intLocationId)
		AND CompOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)
	
	DROP TABLE #tmpDelayedPricing

	--=============================
	-- Customer Owned
	--=============================
	INSERT INTO #tmpInHouseResult (dtmDate
		, dblTotal
		, strTransactionType
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strOwnership)
	SELECT
		dtmDate = CONVERT(DATE, dtmTransactionDate) -- CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110)
		-- RM-4507: dblTotal = Replaced fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
		, dblTotal = CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
							THEN CASE WHEN uomTo.dblUnitQty <> 0 
								THEN CAST((dblTotal * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
								ELSE NULL
								END
							ELSE dblTotal
							END
		, strTransactionType
		, strTransactionId  = strTransactionNumber
		, intTransactionId = intTransactionRecordId
		, ST.strStorageTypeCode
		,strOwnership = 'Customer Owned'
	FROM dbo.fnRKGetBucketCustomerOwned(@dtmToTransactionDate,@intCommodityId,NULL) CusOwn
	LEFT JOIN tblGRStorageType ST ON ST.strStorageTypeDescription = CusOwn.strDistributionType
	LEFT JOIN tblICCommodityUnitMeasure uomFrom
		ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
	LEFT JOIN tblICCommodityUnitMeasure uomTo
		ON uomTo.intCommodityUnitMeasureId = @intCommodityUnitMeasureId
	WHERE ISNULL(CusOwn.strStorageType, '') <> 'ITR' AND CusOwn.intTypeId IN (1, 3, 4, 5, 8, 9)
		AND CusOwn.intItemId = ISNULL(@intItemId, CusOwn.intItemId)
		AND CusOwn.intLocationId = ISNULL(@intLocationId, CusOwn.intLocationId)
		AND CusOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	--=============================
	-- On Hold
	--=============================
	INSERT INTO #tmpInHouseResult (dtmDate
		, dblTotal
		, strTransactionType
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strOwnership)
	SELECT dtmDate = CONVERT(DATE, dtmTransactionDate)--CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmTransactionDate, 110), 110)
		-- RM-4507: dblTotal = Replaced fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
		, dblTotal = CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
							THEN CASE WHEN uomTo.dblUnitQty <> 0 
								THEN CAST((dblTotal * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
								ELSE NULL
								END
							ELSE dblTotal
							END
		, 'On Hold' 
		, strTicketNumber = strTransactionNumber
		, intTicketId = intTransactionRecordId
		, 'HLD'
		, 'HOLD'
	FROM dbo.fnRKGetBucketOnHold(@dtmToTransactionDate,@intCommodityId, NULL) OnHold
	LEFT JOIN tblICCommodityUnitMeasure uomFrom
		ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
	LEFT JOIN tblICCommodityUnitMeasure uomTo
		ON uomTo.intCommodityUnitMeasureId = @intCommodityUnitMeasureId
	WHERE OnHold.intItemId = ISNULL(@intItemId, OnHold.intItemId)
		AND OnHold.intLocationId = ISNULL(@intLocationId, OnHold.intLocationId)
		AND OnHold.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation)

	CREATE NONCLUSTERED INDEX IX_tmpInHouseResult_strTransactionType
	ON #tmpInHouseResult (strTransactionType)
			
	DECLARE @tblResultInventory TABLE (Id INT IDENTITY
		, dtmDate DATE
		, dblInvIn NUMERIC(18,6)
		, dblInvOut NUMERIC(18,6)
		, dblAdjustments NUMERIC(18,6)
		, dblInventoryCount NUMERIC(18,6)
		, dblSalesInTransit NUMERIC(18,6)
		, dblBalanceInv NUMERIC(18,6)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(50)
		, strTransactionType NVARCHAR(100)
		, strOwnership NVARCHAR(20))
			
	;WITH N1 (N) AS (SELECT 1 FROM (VALUES (1), (1), (1), (1), (1), (1), (1), (1), (1), (1)) n (N)),
	N2 (N) AS (SELECT 1 FROM N1 AS N1 CROSS JOIN N1 AS N2),
	N3 (N) AS (SELECT 1 FROM N2 AS N1 CROSS JOIN N2 AS N2),
	Dates AS
	(	SELECT TOP (DATEDIFF(DAY,  DATEADD(day,-1,@dtmFromTransactionDate), @dtmToTransactionDate))
				Date = DATEADD(DAY, ROW_NUMBER() OVER(ORDER BY N), DATEADD(day,-1,@dtmFromTransactionDate))
		FROM N3
	)
	SELECT Date
	INTO #tempDateRange
	FROM Dates AS d

	SELECT dtmDate = InTran.dtmTransactionDate 
		-- RM-4507: dblInTransitQty = Replaced fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId , @intCommodityUnitMeasureId, ISNULL((InTran.dblTotal), 0))
		, dblInTransitQty = CASE WHEN ISNULL(uomFrom.dblUnitQty, 0) <> uomTo.dblUnitQty 
							THEN CASE WHEN uomTo.dblUnitQty <> 0 
								THEN CAST((ISNULL((InTran.dblTotal), 0) * uomFrom.dblUnitQty) AS NUMERIC(38,20)) / uomTo.dblUnitQty
								ELSE NULL
								END
							ELSE ISNULL((InTran.dblTotal), 0)
							END
	INTO #InTransitDateRange
	FROM dbo.fnRKGetBucketInTransit(@dtmToTransactionDate,@intCommodityId,NULL) InTran
	LEFT JOIN tblICCommodityUnitMeasure uomFrom
		ON uomFrom.intCommodityUnitMeasureId = intOrigUOMId
	LEFT JOIN tblICCommodityUnitMeasure uomTo
		ON uomTo.intCommodityUnitMeasureId = @intCommodityUnitMeasureId
	WHERE InTran.strBucketType = 'Sales In-Transit'
		AND InTran.intItemId = ISNULL(@intItemId, InTran.intItemId)
		AND InTran.intLocationId = ISNULL(@intLocationId, InTran.intLocationId ) 
		AND InTran.intLocationId  IN (SELECT intCompanyLocationId FROM #LicensedLocation)
			
	DECLARE @tblBalanceInvByDate AS TABLE (dtmDate DATE NULL
		, dblBalanceInv NUMERIC(18,6)
		, dblBalanceCompanyOwned NUMERIC(18,6)
		, dblBalanceCustomerOwned NUMERIC(18,6)
		, dblSalesInTransit NUMERIC(18,6))

	DECLARE @date DATE
		, @dblSalesInTransitAsOf NUMERIC(18,6)
		, @dblBalanceCompanyOwned NUMERIC(18,6)
		, @dblBalanceCustomerOwned NUMERIC(18,6)
			
	WHILE EXISTS(SELECT TOP 1 1 FROM #tempDateRange)
	BEGIN
		SELECT TOP 1 @date = Date FROM #tempDateRange
				
		INSERT INTO @tblBalanceInvByDate(dtmDate
			, dblBalanceInv)
		SELECT @date
			, SUM(dblTotal)
		FROM #tmpInHouseResult WHERE dtmDate <= @date --CONVERT(DATETIME, CONVERT(NVARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
		
		SELECT @dblBalanceCompanyOwned = SUM(dblTotal)
		FROM #tmpInHouseResult 
		WHERE dtmDate <= @date --CONVERT(DATETIME, CONVERT(NVARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
		AND strOwnership = 'Company Owned'
		
		SELECT @dblBalanceCustomerOwned = SUM(dblTotal)
		FROM #tmpInHouseResult 
		WHERE dtmDate <= @date --CONVERT(DATETIME, CONVERT(NVARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, @date)
		AND strOwnership = 'Customer Owned'

		SELECT @dblSalesInTransitAsOf = SUM(ISNULL(InTran.dblInTransitQty, 0))
		FROM #InTransitDateRange InTran
		WHERE InTran.dtmDate <= @date

		UPDATE @tblBalanceInvByDate
		SET dblSalesInTransit = @dblSalesInTransitAsOf
			,dblBalanceCompanyOwned = @dblBalanceCompanyOwned
			,dblBalanceCustomerOwned = @dblBalanceCustomerOwned
		WHERE dtmDate = @date
		
		DELETE #tempDateRange WHERE Date = @date
	END
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Inventory Receipt')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t 
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblInvIn = CASE WHEN dblTotal > 0 THEN dblTotal ELSE 0 END
		, dblInvOut = CASE WHEN dblTotal < 0 THEN ABS(dblTotal) ELSE 0 END 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Storage Settlement')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t 
			
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Credit Memo')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Inventory Transfer')
		AND dblTotal > 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 	
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Inventory Transfer')
		AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate  
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType = 'On Hold'
		AND dblTotal  > 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution ='PRDC' 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Produce')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t 


	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType = 'On Hold' 
		AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, ABS(dblTotal)
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Inventory Shipment')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, ABS(dblTotal)
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution  = 'CNSM'
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Consume')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory( dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, ABS(dblTotal)
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution  = ''
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Outbound Shipment')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ABS(ISNULL(dblTotal, 0)))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN ('Invoice', 'Cash')
		AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t


	INSERT INTO @tblResultInventory(dtmDate
		, dblAdjustments
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution  = CASE WHEN ISNULL(strDistribution,'') <> '' THEN strDistribution ELSE 'ADJ' END
			, strTransactionType = 'Inventory Adjustment'
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType LIKE 'Inventory Adjustment%'
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strOwnership
	) t

	INSERT INTO @tblResultInventory(dtmDate
		, dblInventoryCount
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal = SUM(ISNULL(dblTotal, 0))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult
		WHERE strTransactionType IN('Inventory Count')
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t


	INSERT INTO @tblResultInventory(dtmDate
		, dblInvIn
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT distinct dtmDate 
			, dblTotal =  sum(dblTotal)
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult s
		WHERE strTransactionType IN ( 'Scale Storage','Customer/Maintain Storage', 'Settle Storage', 'Transfer Storage')
			AND dblTotal > 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t
	
	INSERT INTO @tblResultInventory(dtmDate
		, dblInvOut
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution
		, strTransactionType
		, strOwnership
	FROM (
		SELECT distinct dtmDate 
			, dblTotal =  sum(ABS(dblTotal))
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult s
		WHERE strTransactionType IN ( 'Scale Storage','Customer/Maintain Storage', 'Settle Storage', 'Transfer Storage')
			AND dblTotal < 0
		GROUP BY dtmDate
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
	) t


	INSERT INTO @tblResultInventory(dtmDate
		, dblAdjustments
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership)
	SELECT dtmDate
		, dblTotal 
		, strTransactionId
		, intTransactionId
		, strDistribution 
		, strTransactionType
		, strOwnership
	FROM (
		SELECT dtmDate 
			, dblTotal =  dblTotal
			, strTransactionId
			, intTransactionId
			, strDistribution 
			, strTransactionType
			, strOwnership
		FROM #tmpInHouseResult s
		WHERE strTransactionType IN ( 'Storage Adjustment')
	) t

	--==============================
	-- FINAL SELECT
	--===============================
	
	DECLARE @dtmPrevTransactionDate DATE = CONVERT(DATE, DATEADD(DAY, -1, @dtmFromTransactionDate))

	SELECT * FROM (
		SELECT r.dtmDate
			, ri.dblInvIn
			, ri.dblInvOut
			, ri.dblAdjustments
			, ri.dblInventoryCount
			, ri.strTransactionId
			, ri.intTransactionId
			, ri.strDistribution
			, r.dblBalanceInv
			, r.dblBalanceCompanyOwned
			, r.dblBalanceCustomerOwned 
			, r.dblSalesInTransit
			, ri.strTransactionType
			, intCommodityId = @intCommodityId
			, strOwnership
		FROM @tblBalanceInvByDate r
		LEFT JOIN @tblResultInventory ri ON ri.dtmDate = r.dtmDate
		WHERE r.dblBalanceInv IS NOT NULL 
		
		--Insert Company Title Beginning Balance
		UNION SELECT NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, NULL
			, (SELECT sum(dblTotal) 
				FROM #tmpInHouseResult 
				WHERE dtmDate <= @dtmPrevTransactionDate --CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(DAY, -1, @dtmFromTransactionDate))
				) --dblBalanceInv
			, (SELECT sum(dblTotal) 
				FROM #tmpInHouseResult 
				WHERE dtmDate <= @dtmPrevTransactionDate --CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(DAY, -1, @dtmFromTransactionDate))
				AND strOwnership = 'Company Owned'
				)
			, (SELECT sum(dblTotal) 
				FROM #tmpInHouseResult 
				WHERE dtmDate <= @dtmPrevTransactionDate --CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) <= CONVERT(DATETIME, DATEADD(DAY, -1, @dtmFromTransactionDate))
				AND strOwnership = 'Customer Owned'
				)
			, NULL
			, NULL
			, NULL
			, NULL
		
	) t
	WHERE dblBalanceInv IS NOT NULL 

	DROP TABLE #LicensedLocation
	DROP TABLE #tempDateRange
	DROP TABLE #InTransitDateRange
	DROP TABLE #tmpInHouseResult
END