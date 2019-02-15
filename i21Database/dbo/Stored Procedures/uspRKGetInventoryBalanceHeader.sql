CREATE PROC uspRKGetInventoryBalanceHeader
	@dtmFromTransactionDate DATE = null
	, @dtmToTransactionDate DATE = NULL
	, @intCommodityId int =  NULL
	, @intItemId int= null
	, @strPositionIncludes nvarchar(100) = NULL
	, @intLocationId int = NULL

AS 

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

-- Customer Ownership START
EXEC uspRKGetCustomerOwnership @dtmFromTransactionDate = @dtmFromTransactionDate
	, @dtmToTransactionDate = @dtmToTransactionDate
	, @intCommodityId = @intCommodityId
	, @intItemId = @intItemId
	, @strPositionIncludes = @strPositionIncludes
	, @intLocationId = @intLocationId

-- Custoemr ownershiip END
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
EXEC uspRKGetCompanyOwnership @dtmFromTransactionDate = @dtmFromTransactionDate
	, @dtmToTransactionDate = @dtmToTransactionDate
	, @intCommodityId = @intCommodityId
	, @intItemId = @intItemId
	, @strPositionIncludes = @strPositionIncludes
	, @intLocationId = @intLocationId

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

INSERT INTO @tblConsolidatedResult (dtmDate
	, [Receive In]
	, [Ship Out]
	, [Adjustments]
	, dblCount
	, dblInvoiceQty
	, BalanceForward
	, InventoryBalanceCarryForward
	, [Unpaid In]
	, [Unpaid Out]
	, [Balance]
	, [Unpaid Balance]
	, [Paid Balance]
	, dblSalesInTransit
	, tranDSInQty)
SELECT ISNULL(a.dtmDate,b.dtmDate) [Date]
	, ISNULL(a.tranRecQty, 0) [Receive In]
	, ISNULL(a.tranShipQty, 0) [Ship Out]
	, ISNULL(dblAdjustmentQty, 0) [Adjustments]
	, ISNULL(dblCountQty, 0) as dblCount
	, ISNULL(dblInvoiceQty, 0) dblInvoiceQty
	, ISNULL(a.BalanceForward, 0)  BalanceForward
	, ISNULL(b.InventoryBalanceCarryForward, 0)
	, ISNULL(b.dblUnpaidIn, 0) [Unpaid In]
	, ISNULL(b.dblUnpaidOut, 0) [Unpaid Out]
	, ISNULL(b.dblUnpaidBalance, 0) as [Balance1]
	, null [Unpaid Balance] 
	, ISNULL(b.dblPaidBalance, 0) + ISNULL(b.InventoryBalanceCarryForward, 0)
	, a.dblSalesInTransit
	, a.tranDSInQty
FROM @tblFirstResult a
FULL JOIN @tblResultFinal b on a.dtmDate = b.dtmDate ORDER BY b.dtmDate, a.dtmDate asc

SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum
	, *
INTO #final
FROM (
	SELECT DISTINCT dtmDate
		, [Receive In] + ISNULL(tranDSInQty, 0) as [dblReceiveIn]
		, ISNULL([Ship Out], 0) as [dblShipOut]
		, Adjustments as dblAdjustments
		, dblCount,dblInvoiceQty
		, ISNULL([InventoryBalance], 0) as [dblInventoryBalance]
		, [Unpaid In] as dblUnpaidIn
		, [Unpaid Out] dblUnpaidOut
		, [Balance] dblBalance
		, ISNULL([Paid Balance], 0) [dblPaidBalance]
		,  [dblTotalCompanyOwned]
		, ISNULL(ISNULL([Unpaid In], 0)-ISNULL([Unpaid Out], 0), 0) dblUnpaidBalance
		, dblSalesInTransit
	FROM (
		SELECT dtmDate
			, [Receive In]
			, tranDSInQty
			, [Ship Out]
			, [Adjustments]
			, dblCount
			, dblInvoiceQty
			, BalanceForward
			, InventoryBalanceCarryForward
			, (SELECT SUM(BalanceForward) + sum(ISNULL(tranDSInQty, 0)) FROM @tblConsolidatedResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900')) AS [InventoryBalance]
			, (CASE WHEN ISNULL([Unpaid In], 0)=0 and ISNULL([Unpaid Out], 0)=0 then
                           (SELECT top 1 Balance FROM @tblConsolidatedResult AS T2 WHERE Balance > 0 and ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900') order by ISNULL(T2.dtmDate,'01/01/1900') desc) 
				ELSE [Balance] END) [Balance]
			, [Unpaid In]
			, [Unpaid Out]
			, (SELECT sum([Paid Balance]) FROM @tblConsolidatedResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900'))[Paid Balance] 
			, dblSalesInTransit
			, (SELECT sum([Paid Balance]) FROM @tblConsolidatedResult AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(t.dtmDate,'01/01/1900'))  [dblTotalCompanyOwned]
		FROM (
			SELECT DateData dtmDate
				, [Receive In]
				, tranDSInQty
				, [Ship Out]
				, [Adjustments]
				, dblCount
				, dblInvoiceQty
				, BalanceForward
				, InventoryBalanceCarryForward
				, [Unpaid In]
				, [Unpaid Out]
				, [Balance]
				, [Paid Balance]
				, T1.dblSalesInTransit
			FROM @tblConsolidatedResult T1
			FULL JOIN @tblDateList list on T1.dtmDate=list.DateData
		)t 
	)t1
)t2 ORDER BY dtmDate

SELECT intRowNum
	, dtmDate
	, dblReceiveIn
	, dblShipOut
	, dblAdjustments
	, dblCount
	, dblInvoiceQty
	, dblInventoryBalance
	, dblSalesInTransit
	, strDistributionA,[dblAIn],[dblAOut], [dblANet]
	, strDistributionB,[dblBIn],[dblBOut], [dblBNet]
	, strDistributionC,[dblCIn],[dblCOut], [dblCNet]
	, strDistributionD,[dblDIn],[dblDOut], [dblDNet]
	, strDistributionE,[dblEIn],[dblEOut], [dblENet]
	, strDistributionF,[dblFIn],[dblFOut], [dblFNet]
	, strDistributionG,[dblGIn],[dblGOut], [dblGNet]
	, strDistributionH,[dblHIn],[dblHOut], [dblHNet]
	, strDistributionI,[dblIIn],[dblIOut], [dblINet]
	, strDistributionJ,[dblJIn],[dblJOut], [dblJNet]
	, strDistributionK,[dblKIn],[dblKOut], [dblKNet]
	, dblUnpaidIn
	, dblUnpaidOut
	, dblBalance
	, ISNULL(dblPaidBalance, 0) dblPaidBalance
	, (ISNULL(dblBalance, 0) + ISNULL(dblTotalCompanyOwned, 0)) dblTotalCompanyOwned
	, dblUnpaidBalance
FROM (
	SELECT intRowNum
		, list.dtmDate dtmDate
		, dblReceiveIn
		, abs(dblShipOut) dblShipOut
		, dblAdjustments
		, dblCount
		, dblInvoiceQty
		, dblInventoryBalance
		, abs(ISNULL(list.dblSalesInTransit, 0)) dblSalesInTransit
		, (CASE WHEN strDistributionA is null then (SELECT DISTINCT TOP 1 strDistributionA FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionA,'') <>'') else strDistributionA end) strDistributionA
		, [dblAIn],[dblAOut],(SELECT SUM(dblANet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblANet]
		, (CASE WHEN strDistributionB is null then (SELECT DISTINCT TOP 1 strDistributionB FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionB,'') <>'') else strDistributionB end) strDistributionB
		, [dblBIn],[dblBOut],(SELECT SUM(dblBNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblBNet]
		, (CASE WHEN strDistributionC is null then (SELECT DISTINCT TOP 1 strDistributionC FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionC,'') <>'') else strDistributionC end) strDistributionC
		, [dblCIn],[dblCOut],(SELECT SUM(dblCNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblCNet]
		, (CASE WHEN strDistributionD is null then (SELECT DISTINCT TOP 1 strDistributionD FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionD,'') <>'') else strDistributionD end) strDistributionD
		, [dblDIn],[dblDOut],(SELECT SUM(dblDNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblDNet]
		, (CASE WHEN strDistributionE is null then (SELECT DISTINCT TOP 1 strDistributionE FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionE,'') <>'') else strDistributionE end) strDistributionE
		, [dblEIn],[dblEOut],(SELECT SUM(dblENet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblENet]
		, (CASE WHEN strDistributionF is null then (SELECT DISTINCT TOP 1 strDistributionF FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionF,'') <>'') else strDistributionF end) strDistributionF
		, [dblFIn],[dblFOut],(SELECT SUM(dblFNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblFNet]
		, (CASE WHEN strDistributionG is null then (SELECT DISTINCT TOP 1 strDistributionG FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionG,'') <>'') else strDistributionG end) strDistributionG
		, [dblGIn],[dblGOut],(SELECT SUM(dblGNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblGNet]
		, (CASE WHEN strDistributionH is null then (SELECT DISTINCT TOP 1 strDistributionH FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionH,'') <>'') else strDistributionH end) strDistributionH
		, [dblHIn],[dblHOut],(SELECT SUM(dblHNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblHNet]
		, (CASE WHEN strDistributionI is null then (SELECT DISTINCT TOP 1 strDistributionI FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionI,'') <>'') else strDistributionI end) strDistributionI
		, [dblIIn],[dblIOut],(SELECT SUM(dblINet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblINet]
		, (CASE WHEN strDistributionJ is null then (SELECT DISTINCT TOP 1 strDistributionJ FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionJ,'') <>'') else strDistributionJ end) strDistributionJ
		, [dblJIn],[dblJOut],(SELECT SUM(dblJNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblJNet]
		, (CASE WHEN strDistributionK is null then (SELECT DISTINCT TOP 1 strDistributionK FROM tblRKDailyPositionForCustomer WHERE ISNULL(strDistributionK,'') <>'') else strDistributionK end) strDistributionK
		, [dblKIn],[dblKOut],(SELECT SUM(dblKNet) FROM tblRKDailyPositionForCustomer AS T2 WHERE ISNULL(T2.dtmDate,'01/01/1900') <= ISNULL(list.dtmDate,'01/01/1900')) [dblKNet]
		, dblUnpaidIn
		, dblUnpaidOut
		, dblBalance
		, dblPaidBalance
		, dblTotalCompanyOwned
		, dblUnpaidBalance
	FROM #final list
	FULL JOIN tblRKDailyPositionForCustomer t ON ISNULL(t.dtmDate,'1900-01-01')=ISNULL(list.dtmDate,'1900-01-01')
)t 
--WHERE ISNULL(dtmDate,'') <> ''
ORDER BY dtmDate