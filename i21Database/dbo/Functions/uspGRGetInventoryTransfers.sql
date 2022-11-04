﻿CREATE PROCEDURE [dbo].[uspGRGetInventoryTransfers] 
	@dtmDate DATE = NULL
	,@intCommodityId INT = NULL
	,@intItemId INT = NULL
	,@Locations Id READONLY
	,@intLocationId INT = NULL
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

	
	DECLARE @tblResult TABLE (
		Id INT IDENTITY
		,dtmDate DATETIME
		,dblTotal NUMERIC(18,6)
		,strTransactionNo NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strDistribution NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strOwnership NVARCHAR(20) COLLATE Latin1_General_CI_AS
		,intCompanyLocationId INT
		,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	)

	--=============================
	-- Company Owned
	--=============================
	INSERT INTO @tblResult (
		dtmDate
		,dblTotal
		,strTransactionNo
		,strTransactionType
		,strDistribution
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	)
	SELECT
		 dtmDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmTransactionDate,110),110)
		,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
		,CompOwn.strTransactionNumber
		,strTransactionType
		,CASE WHEN (SELECT TOP 1 1 FROM tblGRSettleContract WHERE intSettleStorageId = CompOwn.intTransactionRecordId) = 1 THEN 'CNT'
			WHEN (SELECT TOP 1 1 FROM dbo.fnRKGetBucketDelayedPricing(@dtmDate,@intCommodityId,NULL) WHERE intTransactionRecordId = CompOwn.intTransactionRecordHeaderId) = 1 THEN 'DP'
			WHEN CompOwn.intContractHeaderId IS NOT NULL 
				THEN ISNULL(
			     (SELECT TOP 1 strDistributionOption FROM tblSCTicket WHERE intTicketId = CompOwn.intTicketId and intContractId = CompOwn.intContractDetailId),
				 (SELECT TOP 1 'CNT' FROM tblSCTicketContractUsed WHERE intTicketId = CompOwn.intTicketId and intContractDetailId = CompOwn.intContractDetailId) )
			WHEN CompOwn.strTransactionType = 'Inventory Adjustment' THEN 'ADJ'
			WHEN CompOwn.strTransactionType IN ('Inventory Receipt','Inventory Shipment') AND CompOwn.intContractHeaderId IS NULL AND CompOwn.intTicketId IS NULL THEN ''
			ELSE ST.strStorageTypeCode END
		,strOwnership = 'Company Owned'
		,CompOwn.intLocationId
		,CompOwn.strLocationName
	FROM dbo.fnRKGetBucketCompanyOwned(@dtmDate,@intCommodityId,NULL) CompOwn
	LEFT JOIN tblGRStorageType ST ON ST.strStorageTypeDescription = CompOwn.strDistributionType
	WHERE CompOwn.intItemId = ISNULL(@intItemId,CompOwn.intItemId)
		AND (CompOwn.intLocationId = ISNULL(@intLocationId,CompOwn.intLocationId)
			OR CompOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation))
		AND strTransactionType = 'Inventory Transfer'

			
	DECLARE @tblResultInventory TABLE 
	(
		Id INT IDENTITY
		,dtmDate DATETIME
		,dblInvIn NUMERIC(18,6)
		,dblInvOut NUMERIC(18,6)
		,dblAdjustments NUMERIC(18,6)
		,dblInventoryCount NUMERIC(18,6)
		,dblSalesInTransit NUMERIC(18,6)
		,dblBalanceInv NUMERIC(18,6)
		,strDistribution NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strTransactionType NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,strOwnership NVARCHAR(20) COLLATE Latin1_General_CI_AS
		,intCompanyLocationId INT
		,strLocationName NVARCHAR(200) COLLATE Latin1_General_CI_AS
	)
	
	INSERT INTO @tblResultInventory
	(	
		dtmDate
		,dblInvIn
		,strDistribution 
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	)
	SELECT dtmDate
		,dblTotal 
		,strDistribution 
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	FROM (
		SELECT dtmDate 
			,dblTotal = SUM(ISNULL(dblTotal,0))
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult A
		OUTER APPLY (
			SELECT strTransactionNo, TOTAL = SUM(dblTotal) FROM @tblResult WHERE strTransactionNo = A.strTransactionNo GROUP BY strTransactionNo
		) B
		WHERE strTransactionType IN ('Inventory Transfer')
			AND B.TOTAL <> 0
		AND dblTotal > 0
		GROUP BY dtmDate
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
	) t

	INSERT INTO @tblResultInventory
	(
		dtmDate
		,dblInvOut
		,strDistribution 	
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	)
	SELECT dtmDate
		,dblTotal
		,strDistribution 
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	FROM (
		SELECT dtmDate 
			,dblTotal = SUM(ABS(ISNULL(dblTotal,0)))
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult A
		OUTER APPLY (
			SELECT strTransactionNo, TOTAL = SUM(dblTotal) FROM @tblResult WHERE strTransactionNo = A.strTransactionNo GROUP BY strTransactionNo
		) B
		WHERE strTransactionType IN ('Inventory Transfer')
			AND B.TOTAL <> 0
		AND dblTotal < 0
		GROUP BY dtmDate
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
	) t

	--==============================
	-- FINAL SELECT
	--===============================
		--SELECT null dtmDate
		--	,dblInvIn = SUM(dblInvIn)
		--	,dblInvOut = SUM(dblInvOut)
		--	,dblAdjustments = SUM(dblAdjustments)
		--	--,strDistribution
		--	,strTransactionType
		--	,intCommodityId = @intCommodityId
		--	,strOwnership
		--	,intCompanyLocationId
		--	,strLocationName
		--FROM @tblResultInventory
		--WHERE dtmDate < @dtmDate
		--GROUP BY --dtmDate, --strDistribution,
		--strTransactionType,strOwnership,strOwnership,intCompanyLocationId,strLocationName
		--UNION ALL
		SELECT dtmDate
			,dblInvIn = SUM(dblInvIn)
			,dblInvOut = SUM(dblInvOut)
			,dblAdjustments = SUM(dblAdjustments)
			--,strDistribution
			--,r.dblBalanceInv
			--,r.dblBalanceCompanyOwned
			--,r.dblBalanceCustomerOwned 
			--,r.dblSalesInTransit
			,strTransactionType
			,intCommodityId = @intCommodityId
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResultInventory
		WHERE dtmDate = @dtmDate
		GROUP BY dtmDate,strTransactionType,strOwnership,strOwnership,intCompanyLocationId,strLocationName

	DROP TABLE #LicensedLocation
END