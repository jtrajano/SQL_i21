CREATE PROCEDURE [dbo].[uspRKGenerateDPI]
	@dtmFromTransactionDate DATE = null
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId INT = NULL
	, @intItemId INT = null
	, @strPositionIncludes NVARCHAR(100) = NULL
	, @intLocationId INT = NULL
	, @GUID UNIQUEIDENTIFIER = NULL

AS

BEGIN
	DECLARE @intDPIHeaderId INT
	SELECT intCompanyLocationId
	INTO #LicensedLocations
	FROM tblSMCompanyLocation
	WHERE ISNULL(ysnLicensed, 0) = CASE WHEN @strPositionIncludes = 'Licensed Storage' THEN 1 WHEN @strPositionIncludes = 'Non-licensed Storage' THEN 0 ELSE ISNULL(ysnLicensed, 0) END

	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END
	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END

	SELECT TOP 1 @intDPIHeaderId = intDPIHeaderId FROM tblRKDPIHeader WHERE imgReportId = @GUID
	IF ISNULL(@intDPIHeaderId, 0) = 0
	BEGIN
		INSERT INTO tblRKDPIHeader(imgReportId
			, strPositionIncludes
			, dtmStartDate
			, dtmEndDate
			, intCommodityId
			, intItemId
			, intLocationId)
		VALUES (@GUID
			, @strPositionIncludes
			, @dtmFromTransactionDate
			, @dtmToTransactionDate
			, @intCommodityId
			, @intItemId
			, @intLocationId)

		SET @intDPIHeaderId = SCOPE_IDENTITY()
	END
	ELSE
	BEGIN
		UPDATE tblRKDPIHeader
		SET strPositionIncludes = @strPositionIncludes
			, dtmStartDate = @dtmFromTransactionDate
			, dtmEndDate = @dtmToTransactionDate
			, intCommodityId = @intCommodityId
			, intItemId = @intItemId
			, intLocationId = @intItemId
		WHERE intDPIHeaderId = @intDPIHeaderId

		DELETE FROM tblRKDPISummary WHERE intDPIHeaderId = @intDPIHeaderId
		DELETE FROM tblRKDPIInventory WHERE intDPIHeaderId = @intDPIHeaderId
		DELETE FROM tblRKDPICompanyOwnership WHERE intDPIHeaderId = @intDPIHeaderId
	END

	DECLARE @intCommodityUnitMeasureId INT = NULL
			, @ysnIncludeDPPurchasesInCompanyTitled BIT
	SELECT @intCommodityUnitMeasureId = intCommodityUnitMeasureId
	FROM tblICCommodityUnitMeasure
	WHERE intCommodityId = @intCommodityId AND ysnDefault = 1
	
	SELECT TOP 1 @ysnIncludeDPPurchasesInCompanyTitled = ysnIncludeDPPurchasesInCompanyTitled FROM tblRKCompanyPreference

	------------------------------------
	---- Generate Company Ownership ----
	------------------------------------
	DECLARE @dtmOrigFromTransactionDate DATETIME

	--Grab the original start date and assinged to a varialbe to be used laster on.
	SET @dtmOrigFromTransactionDate = @dtmFromTransactionDate
	--Set the Start date as the beggining date "1900"
	SET @dtmFromTransactionDate =  '1900-01-01 00:00:00'

	DECLARE @CompanyOwnershipResult TABLE (Id INT identity(1, 1)
		, dtmDate DATETIME
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, dblUnpaidIn NUMERIC(24, 10)
		, dblUnpaidOut NUMERIC(24, 10)
		, dblUnpaidBalance NUMERIC(24, 10)
		, dblPaidBalance  NUMERIC(24, 10)
		, strDistributionOption NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, InventoryBalanceCarryForward NUMERIC(24, 10)
		, strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intReceiptId INT)
	
	DECLARE @DPTable TABLE (Id INT IDENTITY(1, 1)
		, dtmDate DATETIME
		, dblBalance NUMERIC(24, 10)
		, intStorageTypeId INT
		, strStorageType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intItemId INT
		, strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intCommodityUnitMeasureId INT
		, intTicketId INT
		, strTicketType NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strTicketNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intInventoryReceiptId INT
		, intInventoryShipmentId INT
		, strReceiptNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, strShipmentNumber NVARCHAR(50) COLLATE Latin1_General_CI_AS
		, intStorageScheduleTypeId INT
		, intCommodityId INT
		, intCompanyLocationId INT
		, ysnDPOwnedType BIT
		, strDistributionOption NVARCHAR(50) COLLATE Latin1_General_CI_AS)

	
	DECLARE @CompanyTitle AS TABLE (
		dtmDate  DATE  NULL
		,dblUnpaidIncrease  NUMERIC(18,6)
		,dblUnpaidDecrease  NUMERIC(18,6)
		,dblUnpaidBalance  NUMERIC(18,6)
		,dblPaidBalance  NUMERIC(18,6)
		,strTransactionId NVARCHAR(50)
		,intTransactionId INT
		,strTransactionType NVARCHAR(50)
		,strDistribution NVARCHAR(10)
		,dblCompanyTitled NUMERIC(18,6)
		,intCommodityId INT
	)
		
	INSERT INTO @CompanyTitle(
		dtmDate
		,dblUnpaidIncrease 
		,dblUnpaidDecrease 
		,dblUnpaidBalance  
		,dblPaidBalance  
		,strTransactionId
		,intTransactionId 
		,strTransactionType
		,strDistribution
		,dblCompanyTitled
		,intCommodityId
	)
	EXEC uspRKGetCompanyTitled @dtmFromTransactionDate = @dtmOrigFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId


	INSERT INTO tblRKDPICompanyOwnership(intDPIHeaderId
		, dtmTransactionDate
		, strDistribution
		, dblUnpaidIn
		, dblUnpaidOut
		, strReceiptNumber
		, intReceiptId
		, strTransactionType)
	SELECT @intDPIHeaderId
		,dtmDate
		,strDistribution
		,dblIn = CASE WHEN strDistribution IN('ADJ','IC','CM','DP', 'IT','IS', 'CLT', 'PRDC', 'CNSM', 'LG') AND  dblPaidBalance > 0 THEN dblPaidBalance ELSE dblUnpaidIncrease END
		,dblOut = CASE WHEN dblPaidBalance < 0 THEN ABS(dblPaidBalance) ELSE dblUnpaidDecrease END
		,strTransactionId
		,intTransactionId
		,strTransactionType
	FROM @CompanyTitle
	WHERE dtmDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate -- CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
		AND strTransactionId IS NOT NULL
	ORDER BY dtmDate desc, strTransactionId desc, intTransactionId desc
	

	
	SET @dtmFromTransactionDate = @dtmOrigFromTransactionDate


	--------------------------------------------
	---- Generate Inventory Balance Headers ----
	--------------------------------------------
	DECLARE @tblDateList TABLE (Id INT identity(1,1)
		, DateData datetime)

	DECLARE @StartDateTime DATETIME
	DECLARE @EndDateTime DATETIME

	SET @StartDateTime = @dtmFromTransactionDate
	SET @EndDateTime = @dtmToTransactionDate;

	WITH DateRange(DateData) AS (
		SELECT @StartDateTime as Date
		UNION ALL
		SELECT DATEADD(d,1,DateData)
		FROM DateRange 
		WHERE DateData < @EndDateTime
	)
	INSERT INTO @tblDateList(DateData)
	SELECT DateData FROM DateRange
	OPTION (MAXRECURSION 0)

	DECLARE @tblResult TABLE (Id INT identity(1,1)
		, intRowNum int
		, dtmDate datetime
		, [Distribution] nvarchar(50) COLLATE Latin1_General_CI_AS
		, [Unpaid IN] NUMERIC(24,10)
		, [Unpaid Out] NUMERIC(24,10)
		, [Unpaid Balance] NUMERIC(24,10)
		, [Paid Balance] NUMERIC(24,10)
		, [InventoryBalanceCarryForward] NUMERIC(24,10)
		, strReceiptNumber nvarchar(50) COLLATE Latin1_General_CI_AS
		, intReceiptId int)

	DECLARE @tblFirstResult TABLE (Id INT identity(1,1)
		, intRowNum int
		, dtmDate datetime
		, tranShipQty NUMERIC(24,10)
		, tranRecQty NUMERIC(24,10)
		, dblAdjustmentQty NUMERIC(24,10)
		, dblCountQty NUMERIC(24,10)
		, dblInvoiceQty NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
		, tranDSInQty NUMERIC(24,10))

	DECLARE @tblResultFinal TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS
		, dblUnpaidIn NUMERIC(24,10)
		, dblUnpaidOut NUMERIC(24,10)
		, dblUnpaidBalance NUMERIC(24,10)
		, dblPaidBalance NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, InventoryBalanceCarryForward NUMERIC(24,10))

	DECLARE @CompanyTitleByDate AS TABLE (
			dtmDate  DATE  NULL
			,dblUnpaidIncrease  NUMERIC(18,6)
			,dblUnpaidDecrease  NUMERIC(18,6)
			,dblUnpaidBalance  NUMERIC(18,6)
			,dblPaidBalance  NUMERIC(18,6)
			,dblCompanyTitled  NUMERIC(18,6)
	)

	EXEC uspRKGetCustomerOwnership @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId

	INSERT INTO @tblResult (intRowNum
		, dtmDate
		, [Distribution]
		, [Unpaid IN]
		, [Unpaid Out]
		, [Unpaid Balance]
		, [Paid Balance]
		, InventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId)
	SELECT intDPICompanyOwnershipId
		, dtmTransactionDate
		, strDistribution
		, dblUnpaidIn
		, dblUnpaidOut
		, dblUnpaidBalance
		, dblPaidBalance
		, dblInventoryBalanceCarryForward
		, strReceiptNumber
		, intReceiptId
	FROM tblRKDPICompanyOwnership
	WHERE intDPIHeaderId = @intDPIHeaderId

	INSERT INTO @tblFirstResult (dtmDate
		, tranShipQty
		, tranRecQty
		, dblAdjustmentQty
		, dblCountQty
		, dblInvoiceQty
		, BalanceForward
		, dblSalesInTransit
		, tranDSInQty)
	EXEC uspRKGetInventoryBalance @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId


	--=========================================
	--	Compose Company Title Summary By Date
	--=========================================

	;WITH CompanyOwnership(dtmDate
			,dblUnpaidIncrease 
			,dblUnpaidDecrease 
			,dblUnpaidBalance  
			,dblPaidBalance)
	AS(
		SELECT 
			dtmDate
			,dblUnpaidIncrease = SUM(dblUnpaidIncrease)
			,dblUnpaidDecrease = SUM(dblUnpaidDecrease)
			,dblUnpaidBalance = SUM(dblUnpaidBalance)
			,dblPaidBalance = SUM(dblPaidBalance)
		FROM @CompanyTitle 
		WHERE dtmDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate -- CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
		GROUP BY
			dtmDate
	)

	INSERT INTO @CompanyTitleByDate (
		 dtmDate
		,dblUnpaidIncrease
		,dblUnpaidDecrease
		,dblUnpaidBalance
		,dblPaidBalance
		,dblCompanyTitled 
	)
	SELECT DISTINCT
		 CO.dtmDate
		,CO.dblUnpaidIncrease
		,CO.dblUnpaidDecrease
		,CO.dblUnpaidBalance
		,CO.dblPaidBalance
		,CT.dblCompanyTitled 
	FROM CompanyOwnership CO
	FULL JOIN @CompanyTitle CT ON CO.dtmDate = CT.dtmDate


	INSERT INTO @tblResultFinal (dtmDate
		, dblUnpaidIn
		, dblUnpaidOut
		, BalanceForward
		, dblUnpaidBalance
		, dblPaidBalance
		, InventoryBalanceCarryForward)
	SELECT dtmDate
		, sum([Unpaid IN]) tranRecQty
		, sum([Unpaid Out]) tranShipQty
		, sum([Unpaid Balance]) dblUnpaidBalance
		, (SELECT SUM([Unpaid Balance]) FROM @tblResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(T1.dtmDate,'01/01/1900')) AS [Unpaid Balance]
		, sum(T1.[Paid Balance]) dblPaidBalance
		, sum(InventoryBalanceCarryForward) InventoryBalanceCarryForward
	FROM @tblResult T1 
	GROUP BY dtmDate


	DECLARE @InHouse TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, dblInvIn NUMERIC(24,10)
		, dblInvOut NUMERIC(24,10)
		, dblAdjustments NUMERIC(24,10)
		, dblInventoryCount NUMERIC(24,10)
		, dblBalanceInv NUMERIC(24,10)
		, dblBalanceCompanyOwned NUMERIC(24,10)
		, dblBalanceCustomerOwned NUMERIC(24,10)
		, strTransactionId NVARCHAR(50)
		, intTransactionId INT
		, strDistribution NVARCHAR(50)
		, dblSalesInTransit NUMERIC(24,10)
		, strTransactionType NVARCHAR(100)
		, intCommodityId INT
		, strOwnership NVARCHAR(20)
	)


	DECLARE @tblInHouseByDate TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, dblInvIn NUMERIC(24,10)
		, dblInvOut NUMERIC(24,10)
		, dblAdjustments NUMERIC(24,10)
		, dblInventoryCount NUMERIC(24,10)
		, dblBalanceInv NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
	)

	DECLARE @tblConsolidatedResult TABLE (Id INT identity(1,1)
		, dtmDate datetime
		, [Receive In] NUMERIC(24,10)
		, [Ship Out] NUMERIC(24,10)
		, [Adjustments] NUMERIC(24,10)
		, [dblCount] NUMERIC(24,10)
		, [dblInvoiceQty] NUMERIC(24,10)
		, BalanceForward NUMERIC(24,10)
		, InventoryBalanceCarryForward NUMERIC(24,10)
		, [Unpaid In] NUMERIC(24,10)
		, [Unpaid Out] NUMERIC(24,10)
		, dblUnpaidOut NUMERIC(24,10)
		, [Balance] NUMERIC(24,10)
		, [Unpaid Balance] NUMERIC(24,10)
		, [Paid Balance] NUMERIC(24,10)
		, dblSalesInTransit NUMERIC(24,10)
		, tranDSInQty NUMERIC(24,10))

	INSERT INTO @InHouse (dtmDate
		, dblInvIn
		, dblInvOut
		, dblAdjustments
		, dblInventoryCount
		, strTransactionId
		, intTransactionId
		, strDistribution
		, dblBalanceInv
		, dblBalanceCompanyOwned
		, dblBalanceCustomerOwned
		, dblSalesInTransit
		, strTransactionType
		, intCommodityId
		, strOwnership
		)
	EXEC uspRKGetInHouse @dtmFromTransactionDate = @dtmFromTransactionDate
		, @dtmToTransactionDate = @dtmToTransactionDate
		, @intCommodityId = @intCommodityId
		, @intItemId = @intItemId
		, @strPositionIncludes = @strPositionIncludes
		, @intLocationId = @intLocationId

	--=========== Compose In-House By Date ==============

		;WITH InHouse (dtmDate
				,dblInvIn
				,dblInvOut
				,dblAdjustments
				,dblInventoryCount
		)
		AS(
			SELECT 
				dtmDate
				,SUM(dblInvIn)
				,SUM(dblInvOut)
				,SUM(dblAdjustments)
				,SUM(dblInventoryCount)
			FROM @InHouse 
			WHERE dtmDate BETWEEN @dtmFromTransactionDate AND @dtmToTransactionDate --  CONVERT(DATETIME, CONVERT(VARCHAR(10), dtmDate, 110), 110) BETWEEN CONVERT(DATETIME, @dtmFromTransactionDate) AND CONVERT(DATETIME, @dtmToTransactionDate)
			GROUP BY
				dtmDate
		)

		INSERT INTO @tblInHouseByDate (
			dtmDate
			,dblInvIn
			,dblInvOut
			,dblAdjustments
			,dblInventoryCount
			,dblBalanceInv
			,dblSalesInTransit
		)
		SELECT DISTINCT
			CO.dtmDate
			,CO.dblInvIn
			,CO.dblInvOut
			,CO.dblAdjustments
			,CO.dblInventoryCount
			,CT.dblBalanceInv 
			,CT.dblSalesInTransit
		FROM InHouse CO
		FULL JOIN @InHouse CT ON CO.dtmDate = CT.dtmDate
		ORDER BY CO.dtmDate




	SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
		, *
	INTO #final
	FROM (
		SELECT 
			dtmDate
			,dblInvIn
			,dblInvOut
			,dblAdjustments
			,dblInventoryCount
			,dblBalanceInv
			,dblSalesInTransit
		FROM @tblInHouseByDate
	)t2 ORDER BY dtmDate

	INSERT INTO tblRKDPISummary(intDPIHeaderId
		, dtmTransactionDate
		, dblReceiveIn
		, dblShipOut
		, dblAdjustments
		, dblCount
		, dblInvoiceQty
		, dblInventoryBalance
		, dblSalesInTransit
		, strDistributionA
		, dblAIn
		, dblAOut
		, dblANet
		, strDistributionB
		, dblBIn
		, dblBOut
		, dblBNet
		, strDistributionC
		, dblCIn
		, dblCOut
		, dblCNet
		, strDistributionD
		, dblDIn
		, dblDOut
		, dblDNet
		, strDistributionE
		, dblEIn
		, dblEOut
		, dblENet
		, strDistributionF
		, dblFIn
		, dblFOut
		, dblFNet
		, strDistributionG
		, dblGIn
		, dblGOut
		, dblGNet
		, strDistributionH
		, dblHIn
		, dblHOut
		, dblHNet
		, strDistributionI
		, dblIIn
		, dblIOut
		, dblINet
		, strDistributionJ
		, dblJIn
		, dblJOut
		, dblJNet
		, strDistributionK
		, dblKIn
		, dblKOut
		, dblKNet
		, dblUnpaidIn
		, dblUnpaidOut
		, dblBalance
		, dblPaidBalance
		, dblTotalCompanyOwned
		, dblUnpaidBalance)
	SELECT DISTINCT @intDPIHeaderId
		, dtmDate
		, dblInvIn 
		, dblInvOut
		, dblAdjustments 
		, dblInventoryCount 
		, dblInvoiceQty = 0
		, dblBalanceInv
		, dblSalesInTransit
		, strDistributionA
		, [dblAIn] = CASE WHEN strDistributionA IS NULL THEN NULL ELSE ISNULL([dblAIn], 0) END
		, [dblAOut] = CASE WHEN strDistributionA IS NULL THEN NULL ELSE ISNULL([dblAOut], 0) END
		, [dblANet] = CASE WHEN strDistributionA IS NULL THEN NULL ELSE ISNULL([dblANet], 0) END
		, strDistributionB
		, [dblBIn] = CASE WHEN strDistributionB IS NULL THEN NULL ELSE ISNULL([dblBIn], 0) END
		, [dblBOut] = CASE WHEN strDistributionB IS NULL THEN NULL ELSE ISNULL([dblBOut], 0) END
		, [dblBNet] = CASE WHEN strDistributionB IS NULL THEN NULL ELSE ISNULL([dblBNet], 0) END
		, strDistributionC
		, [dblCIn] = CASE WHEN strDistributionC IS NULL THEN NULL ELSE ISNULL([dblCIn], 0) END
		, [dblCOut] = CASE WHEN strDistributionC IS NULL THEN NULL ELSE ISNULL([dblCOut], 0) END
		, [dblCNet] = CASE WHEN strDistributionC IS NULL THEN NULL ELSE ISNULL([dblCNet], 0) END
		, strDistributionD
		, [dblDIn] = CASE WHEN strDistributionD IS NULL THEN NULL ELSE ISNULL([dblDIn], 0) END
		, [dblDOut] = CASE WHEN strDistributionD IS NULL THEN NULL ELSE ISNULL([dblDOut], 0) END
		, [dblDNet] = CASE WHEN strDistributionD IS NULL THEN NULL ELSE ISNULL([dblDNet], 0) END
		, strDistributionE
		, [dblEIn] = CASE WHEN strDistributionE IS NULL THEN NULL ELSE ISNULL([dblEIn], 0) END
		, [dblEOut] = CASE WHEN strDistributionE IS NULL THEN NULL ELSE ISNULL([dblEOut], 0) END
		, [dblENet] = CASE WHEN strDistributionE IS NULL THEN NULL ELSE ISNULL([dblENet], 0) END
		, strDistributionF
		, [dblFIn] = CASE WHEN strDistributionF IS NULL THEN NULL ELSE ISNULL([dblFIn], 0) END
		, [dblFOut] = CASE WHEN strDistributionF IS NULL THEN NULL ELSE ISNULL([dblFOut], 0) END
		, [dblFNet] = CASE WHEN strDistributionF IS NULL THEN NULL ELSE ISNULL([dblFNet], 0) END
		, strDistributionG
		, [dblGIn] = CASE WHEN strDistributionG IS NULL THEN NULL ELSE ISNULL([dblGIn], 0) END
		, [dblGOut] = CASE WHEN strDistributionG IS NULL THEN NULL ELSE ISNULL([dblGOut], 0) END
		, [dblGNet] = CASE WHEN strDistributionG IS NULL THEN NULL ELSE ISNULL([dblGNet], 0) END
		, strDistributionH
		, [dblHIn] = CASE WHEN strDistributionH IS NULL THEN NULL ELSE ISNULL([dblHIn], 0) END
		, [dblHOut] = CASE WHEN strDistributionH IS NULL THEN NULL ELSE ISNULL([dblHOut], 0) END
		, [dblHNet] = CASE WHEN strDistributionH IS NULL THEN NULL ELSE ISNULL([dblHNet], 0) END
		, strDistributionI
		, [dblIIn] = CASE WHEN strDistributionI IS NULL THEN NULL ELSE ISNULL([dblIIn], 0) END
		, [dblIOut] = CASE WHEN strDistributionI IS NULL THEN NULL ELSE ISNULL([dblIOut], 0) END
		, [dblINet] = CASE WHEN strDistributionI IS NULL THEN NULL ELSE ISNULL([dblINet], 0) END
		, strDistributionJ
		, [dblJIn] = CASE WHEN strDistributionJ IS NULL THEN NULL ELSE ISNULL([dblJIn], 0) END
		, [dblJOut] = CASE WHEN strDistributionJ IS NULL THEN NULL ELSE ISNULL([dblJOut], 0) END
		, [dblJNet] = CASE WHEN strDistributionJ IS NULL THEN NULL ELSE ISNULL([dblJNet], 0) END
		, strDistributionK
		, [dblKIn] = CASE WHEN strDistributionK IS NULL THEN NULL ELSE ISNULL([dblKIn], 0) END
		, [dblKOut] = CASE WHEN strDistributionK IS NULL THEN NULL ELSE ISNULL([dblKOut], 0) END
		, [dblKNet] = CASE WHEN strDistributionK IS NULL THEN NULL ELSE ISNULL([dblKNet], 0) END
		, dblUnpaidIn = ISNULL(dblUnpaidIn, 0)
		, dblUnpaidOut = ISNULL(dblUnpaidOut, 0)
		, dblBalance = ISNULL(dblBalance, 0)
		, dblPaidBalance = ISNULL(dblPaidBalance, 0)
		, dblTotalCompanyOwned --= (ISNULL(dblBalance, 0) + ISNULL(dblTotalCompanyOwned, 0))
		, dblUnpaidBalance = ISNULL(dblUnpaidBalance, 0)
	FROM (
		SELECT DISTINCT intRowNum
			, dtmDate = CASE WHEN ISNULL(ct.dblUnpaidBalance, 0) = 0
									AND ISNULL(ct.dblUnpaidIncrease, 0) = 0
									AND ISNULL(ct.dblUnpaidDecrease, 0) = 0
									AND ISNULL(ct.dblPaidBalance, 0) = 0 THEN list.dtmDate ELSE ct.dtmDate END
			, dblInvIn
			, dblInvOut
			, dblAdjustments
			, dblInventoryCount
			, dblBalanceInv
			, abs(ISNULL(list.dblSalesInTransit, 0)) dblSalesInTransit
			, strDistributionA = (CASE WHEN strDistributionA is null then (SELECT DISTINCT TOP 1 strDistributionA FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionA,'') <>'') else strDistributionA end)
			, [dblAIn]
			, [dblAOut]
			, [dblANet] = (SELECT SUM(dblANet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionB = (CASE WHEN strDistributionB is null then (SELECT DISTINCT TOP 1 strDistributionB FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionB,'') <>'') else strDistributionB end)
			, [dblBIn]
			, [dblBOut]
			, [dblBNet] = (SELECT SUM(dblBNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionC = (CASE WHEN strDistributionC is null then (SELECT DISTINCT TOP 1 strDistributionC FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionC,'') <>'') else strDistributionC end)
			, [dblCIn]
			, [dblCOut]
			, [dblCNet] = (SELECT SUM(dblCNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionD = (CASE WHEN strDistributionD is null then (SELECT DISTINCT TOP 1 strDistributionD FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionD,'') <>'') else strDistributionD end)
			, [dblDIn]
			, [dblDOut]
			, [dblDNet] = (SELECT SUM(dblDNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionE = (CASE WHEN strDistributionE is null then (SELECT DISTINCT TOP 1 strDistributionE FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionE,'') <>'') else strDistributionE end)
			, [dblEIn]
			, [dblEOut]
			, [dblENet] = (SELECT SUM(dblENet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionF = (CASE WHEN strDistributionF is null then (SELECT DISTINCT TOP 1 strDistributionF FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionF,'') <>'') else strDistributionF end)
			, [dblFIn]
			, [dblFOut]
			, [dblFNet] = (SELECT SUM(dblFNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionG = (CASE WHEN strDistributionG is null then (SELECT DISTINCT TOP 1 strDistributionG FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionG,'') <>'') else strDistributionG end)
			, [dblGIn]
			, [dblGOut]
			, [dblGNet] = (SELECT SUM(dblGNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionH = (CASE WHEN strDistributionH is null then (SELECT DISTINCT TOP 1 strDistributionH FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionH,'') <>'') else strDistributionH end)
			, [dblHIn]
			, [dblHOut]
			, [dblHNet] = (SELECT SUM(dblHNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionI = (CASE WHEN strDistributionI is null then (SELECT DISTINCT TOP 1 strDistributionI FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionI,'') <>'') else strDistributionI end)
			, [dblIIn]
			, [dblIOut]
			, [dblINet] = (SELECT SUM(dblINet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionJ = (CASE WHEN strDistributionJ is null then (SELECT DISTINCT TOP 1 strDistributionJ FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionJ,'') <>'') else strDistributionJ end)
			, [dblJIn]
			, [dblJOut]
			, [dblJNet] = (SELECT SUM(dblJNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, strDistributionK = (CASE WHEN strDistributionK is null then (SELECT DISTINCT TOP 1 strDistributionK FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionK,'') <>'') else strDistributionK end)
			, [dblKIn]
			, [dblKOut]
			, [dblKNet] = (SELECT SUM(dblKNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900'))
			, dblUnpaidIn = ct.dblUnpaidIncrease
			, dblUnpaidOut = ct.dblUnpaidDecrease
			, dblBalance = ct.dblUnpaidBalance
			, dblPaidBalance = ct.dblPaidBalance
			, dblTotalCompanyOwned = ct.dblCompanyTitled
			, dblUnpaidBalance = ct.dblUnpaidBalance
		FROM #final list
		FULL JOIN tblRKDailyPositionForCustomer t ON ISNULL(t.dtmDate,'1900-01-01')=ISNULL(list.dtmDate,'1900-01-01')
		FULL JOIN @CompanyTitleByDate ct ON ISNULL(ct.dtmDate,'1900-01-01')=ISNULL(list.dtmDate,'1900-01-01')
	)t 
	ORDER BY dtmDate



	IF (ISNULL(@intItemId, 0) = 0)
	BEGIN
		SET @intItemId = NULL
	END
	IF (ISNULL(@intLocationId, 0) = 0)
	BEGIN
		SET @intLocationId = NULL
	END

	INSERT INTO tblRKDPIInventory(intDPIHeaderId
		, dtmTransactionDate
		, strReceiptNumber
		, strDistribution
		, dblIn
		, strShipTicketNo
		, dblOut
		, strAdjNo
		, dblAdjQty
		, strCountNumber
		, dblCountQty
		, dblDummy
		, dblBalanceForward
		, strShipDistributionOption
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, strDeliverySheetNumber
		, intTicketId
		, strTicketNumber
		, strTransactionType)
	SELECT @intDPIHeaderId
		, dtmDate
		, strReceiptNumber
		, strDistribution
		, dblIN
		, strShipTicketNo
		, dblOUT
		, strAdjNo
		, dblAdjQty
		, strCountNumber
		, dblCountQty
		, dblDummy
		, dblBalanceForward
		, strShipDistributionOption
		, intInventoryReceiptId
		, intInventoryShipmentId
		, intInventoryAdjustmentId
		, intInventoryCountId
		, intInvoiceId
		, intDeliverySheetId
		, deliverySheetNumber
		, intTicketId
		, ticketNumber
		, strTransactionType
	FROM (
		SELECT DISTINCT dtmDate [dtmDate]
			, strReceiptNumber = strTransactionId
			, strDistribution
			, dblInvIn [dblIN]
			, strTransactionId [strShipTicketNo]
			, dblInvOut [dblOUT]
			, strTransactionId [strAdjNo]
			, dblAdjustments [dblAdjQty]
			, strTransactionId [strCountNumber]
			, dblInventoryCount [dblCountQty]
			, 0 dblDummy
			, 0 AS dblBalanceForward
			, strShipDistributionOption = strDistribution
			, intInventoryReceiptId= intTransactionId
			, intInventoryShipmentId= intTransactionId
			, intInventoryAdjustmentId= intTransactionId
			, intInventoryCountId= intTransactionId
			, intInvoiceId= intTransactionId
			, intDeliverySheetId= intTransactionId
			, deliverySheetNumber= strTransactionId
			, intTicketId= intTransactionId
			, ticketNumber= strTransactionId
			, strTransactionType
		FROM @InHouse T1
	)t order by dtmDate desc,strReceiptNumber desc

	DROP TABLE #LicensedLocations

END