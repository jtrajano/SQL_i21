CREATE PROCEDURE [dbo].[uspGRGetInHousePerLocation] 
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
	WHERE intCommodityId = @intCommodityId 
		AND ysnStockUnit = 1

	
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
		--AND ((strTransactionType = 'Invoice' and CompOwn.intTicketId IS NOT NULL) OR (strTransactionType <> 'Invoice')) --Invoices from Scale and other transactions

	--=============================
	-- Company Owned *** Invoices that are not linked to scale tickets
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
		,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,CompOwn.dblTotal * -1)
		,CompOwn.strTransactionNumber
		,CompOwn.strTransactionType
		,'SO' --set strDistribution the same as Sales Order just to easily get the Invoice
		,strOwnership = 'Company Owned'
		,CompOwn.intLocationId
		,CompOwn.strLocationName
	FROM dbo.fnRKGetBucketCompanyOwned(@dtmDate,@intCommodityId,NULL) CompOwn
	INNER JOIN tblARInvoice AR
		ON AR.intInvoiceId = CompOwn.intTransactionRecordHeaderId
			AND AR.intSalesOrderId IS NULL
	INNER JOIN tblARInvoiceDetail AD
		ON AD.intInvoiceDetailId = CompOwn.intTransactionRecordId
			AND AD.intTicketId IS NULL
	WHERE CompOwn.intItemId = ISNULL(@intItemId,CompOwn.intItemId)
		AND (CompOwn.intLocationId = ISNULL(@intLocationId,CompOwn.intLocationId)
			OR CompOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation))
		AND CompOwn.strTransactionType = 'Invoice'-- and CompOwn.intTicketId IS NOT NULL) OR (strTransactionType <> 'Invoice')) --Invoices from Scale and other transactions

	--=================================
	-- Company Owned *** Sales Order
	--=================================
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
		dtmDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),AR.dtmPostDate,110),110)
		,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(CO.intCommodityUnitMeasureId,@intCommodityUnitMeasureId,SC.dblNetUnits)
		,AR.strInvoiceNumber
		,'Invoice'
		,'SO'
		,strOwnership = 'Company Owned'
		,AR.intCompanyLocationId
		,CL.strLocationName
	FROM tblSCTicket SC
	INNER JOIN tblICItemUOM UOM
		ON UOM.intItemUOMId = SC.intItemUOMIdTo
	INNER JOIN tblARInvoice AR
		ON AR.intSalesOrderId = SC.intSalesOrderId
	INNER JOIN tblSMCompanyLocation CL
		ON CL.intCompanyLocationId = AR.intCompanyLocationId
	INNER JOIN tblICItem IC
		ON IC.intItemId = UOM.intItemId
	INNER JOIN tblICCommodityUnitMeasure CO
		ON CO.intCommodityId = IC.intCommodityId
			AND CO.intUnitMeasureId = UOM.intUnitMeasureId
	WHERE IC.intItemId = ISNULL(@intItemId,IC.intItemId)
		AND (AR.intCompanyLocationId= ISNULL(@intLocationId,AR.intCompanyLocationId)
			OR AR.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation))
		AND IC.intCommodityId = ISNULL(@intCommodityId, IC.intCommodityId)

	--=============================
	-- Customer Owned
	--=============================
	INSERT INTO @tblResult 
	(
		dtmDate
		,dblTotal
		,strTransactionType
		,strDistribution
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	)
	SELECT
		dtmDate = CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmTransactionDate,110),110)
		,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
		,strTransactionType
		,ST.strStorageTypeCode
		,strOwnership = 'Customer Owned'
		,intLocationId
		,CusOwn.strLocationName
	FROM dbo.fnRKGetBucketCustomerOwned(@dtmDate,@intCommodityId,NULL) CusOwn
	LEFT JOIN tblGRStorageType ST ON ST.strStorageTypeDescription = CusOwn.strDistributionType
	WHERE ISNULL(CusOwn.strStorageType,'') <> 'ITR' AND CusOwn.intTypeId IN (1,3,4,5,8,9)
		AND CusOwn.intItemId = ISNULL(@intItemId,CusOwn.intItemId)
		AND (CusOwn.intLocationId = ISNULL(@intLocationId,CusOwn.intLocationId)
			OR CusOwn.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation))
		AND CusOwn.dblTotal <> 0

	--=============================
	-- On Hold
	--=============================
	INSERT INTO @tblResult 
	(
		dtmDate
		,dblTotal
		,strTransactionType
		,strDistribution
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	)
	SELECT CONVERT(DATETIME,CONVERT(VARCHAR(10),dtmTransactionDate,110),110)
		,dblTotal = dbo.fnCTConvertQuantityToTargetCommodityUOM(intOrigUOMId,@intCommodityUnitMeasureId,dblTotal)
		,'On Hold'
		,'HLD'
		,'HOLD'
		,intLocationId
		,OnHold.strLocationName
	FROM dbo.fnRKGetBucketOnHold(@dtmDate,@intCommodityId,NULL) OnHold
	WHERE OnHold.intItemId = ISNULL(@intItemId,OnHold.intItemId)
		AND (OnHold.intLocationId = ISNULL(@intLocationId,OnHold.intLocationId)
			OR OnHold.intLocationId IN (SELECT intCompanyLocationId FROM #LicensedLocation))
			
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
	SELECT 
		dtmDate
		,dblTotal
		,strDistribution 
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	FROM (
		SELECT 
			dtmDate 
			,dblTotal = SUM(ISNULL(dblTotal,0))
			,strDistribution
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult
		WHERE strTransactionType IN ('Inventory Receipt')
		GROUP BY dtmDate
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
	) t 
	WHERE dblTotal <> 0
	
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
		JOIN tblICInventoryTransfer IT
			ON IT.strTransferNo = A.strTransactionNo
		WHERE strTransactionType IN ('Inventory Transfer')
			--AND B.TOTAL <> 0
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
		JOIN tblICInventoryTransfer IT
			ON IT.strTransferNo = A.strTransactionNo
		WHERE strTransactionType IN ('Inventory Transfer')
			--AND B.TOTAL <> 0
		AND dblTotal < 0
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
		FROM @tblResult
		WHERE strTransactionType = 'On Hold'
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
			,dblTotal = SUM(ABS(ISNULL(dblTotal,0)))
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult
		WHERE strTransactionType = 'On Hold' 
		AND dblTotal < 0
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
		,dblInvIn
		,strDistribution 
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	)
	SELECT dtmDate
		,ABS(dblTotal)
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
		FROM @tblResult
		WHERE strTransactionType = 'Inventory Shipment'
		GROUP BY dtmDate
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
	) t
	WHERE dblTotal <> 0

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
		,ABS(dblTotal)
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
		FROM @tblResult
		WHERE strTransactionType = 'Invoice'
			AND strDistribution = 'SO'
		GROUP BY dtmDate
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
	) t
	WHERE dblTotal <> 0

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
		,ABS(dblTotal)
		,strDistribution 
		,strTransactionType
		,strOwnership
		,intCompanyLocationId
		,strLocationName
	FROM (
		SELECT dtmDate 
			,dblTotal = SUM(ISNULL(dblTotal,0))
			,strDistribution  = ''
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult
		WHERE strTransactionType = 'Outbound Shipment'
		GROUP BY dtmDate
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
	) t
	WHERE dblTotal <> 0

	INSERT INTO @tblResultInventory
	(
		dtmDate
		,dblAdjustments
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
			,strDistribution  = CASE WHEN ISNULL(strDistribution,'') <> '' THEN strDistribution ELSE 'ADJ' END
			,strTransactionType = 'Inventory Adjustment'
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult
		WHERE strTransactionType LIKE 'Inventory Adjustment%'
			AND dblTotal > 0
		GROUP BY dtmDate
			,strDistribution 
			,strOwnership
			,intCompanyLocationId
			,strLocationName
			,intCompanyLocationId
	) t

	INSERT INTO @tblResultInventory
	(
		dtmDate
		,dblAdjustments
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
			,strDistribution  = CASE WHEN ISNULL(strDistribution,'') <> '' THEN strDistribution ELSE 'ADJ' END
			,strTransactionType = 'Inventory Adjustment'
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult
		WHERE strTransactionType LIKE 'Inventory Adjustment%'
			AND dblTotal < 0
		GROUP BY dtmDate
			,strDistribution 
			,strOwnership
			,intCompanyLocationId
			,strLocationName
			,intCompanyLocationId
	) t

	INSERT INTO @tblResultInventory
	(
		dtmDate
		,dblAdjustments
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
			,dblTotal = dblTotal
			,strDistribution 
			,strTransactionType
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResult s
		WHERE strTransactionType IN ( 'Storage Adjustment')
	) t

	--==============================
	-- FINAL SELECT
	--===============================
		SELECT null dtmDate
			,dblInvIn = SUM(dblInvIn)
			,dblInvOut = SUM(dblInvOut)
			,dblAdjustments = SUM(dblAdjustments)
			--,strDistribution
			,strTransactionType
			,intCommodityId = @intCommodityId
			,strOwnership
			,intCompanyLocationId
			,strLocationName
		FROM @tblResultInventory
		WHERE dtmDate < @dtmDate
		GROUP BY --dtmDate, --strDistribution,
		strTransactionType,strOwnership,strOwnership,intCompanyLocationId,strLocationName
		UNION ALL
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
			AND strTransactionType <> 'Inventory Adjustment'
		GROUP BY dtmDate,strTransactionType,strOwnership,strOwnership,intCompanyLocationId,strLocationName
		UNION ALL
		SELECT dtmDate
			,dblInvIn = 0
			,dblInvOut = 0
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
			AND strTransactionType = 'Inventory Adjustment'
			AND dblAdjustments < 0
		GROUP BY dtmDate,strTransactionType,strOwnership,strOwnership,intCompanyLocationId,strLocationName
		UNION ALL
		SELECT dtmDate
			,dblInvIn = 0
			,dblInvOut = 0
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
			AND strTransactionType = 'Inventory Adjustment'
			AND dblAdjustments > 0
		GROUP BY dtmDate,strTransactionType,strOwnership,strOwnership,intCompanyLocationId,strLocationName
		

	DROP TABLE #LicensedLocation
END