CREATE PROC uspRKGetInventoryBalanceHeader

		  @dtmFromTransactionDate DATETIME = null,
          @dtmToTransactionDate DATETIME = NULL,
          @intCommodityId int =  NULL,
	      @intItemId int= null
AS 

DECLARE @tblDateList TABLE
(Id INT identity(1,1),
       DateData datetime
)

DECLARE @StartDateTime DATETIME
DECLARE @EndDateTime DATETIME

SET @StartDateTime = @dtmFromTransactionDate
SET @EndDateTime = @dtmToTransactionDate;

WITH DateRange(DateData) AS 
(
    SELECT @StartDateTime as Date
    UNION ALL
    SELECT DATEADD(d,1,DateData)
    FROM DateRange 
    WHERE DateData < @EndDateTime
)
INSERT INTO @tblDateList(DateData)
SELECT DateData FROM DateRange
OPTION (MAXRECURSION 0)

DECLARE @tblResult TABLE
(Id INT identity(1,1),
       intRowNum int,
       dtmDate datetime,
       [Distribution] nvarchar(50),
       [Unpaid IN] NUMERIC(24,10),
       [Unpaid Out] NUMERIC(24,10),
       [Unpaid Balance] NUMERIC(24,10),
       [InventoryBalanceCarryForward] NUMERIC(24,10),
	   strReceiptNumber nvarchar(50),
	   intReceiptId int
)

DECLARE @tblFirstResult TABLE
(Id INT identity(1,1),
       intRowNum int,
       dtmDate datetime,
       tranShipQty NUMERIC(24,10),
       tranRecQty NUMERIC(24,10),
       dblAdjustmentQty NUMERIC(24,10),
       BalanceForward NUMERIC(24,10)
)

DECLARE @tblResultFinal TABLE
(Id INT identity(1,1),
       dtmDate datetime,
       strItemNo nvarchar(50),
       dblUnpaidIn NUMERIC(24,10),
       dblUnpaidOut NUMERIC(24,10),
       dblUnpaidBalance NUMERIC(24,10),
   BalanceForward NUMERIC(24,10),
       InventoryBalanceCarryForward NUMERIC(24,10)
)

INSERT INTO @tblResult (intRowNum ,dtmDate ,    [Distribution] ,     [Unpaid IN] , [Unpaid Out] ,       [Unpaid Balance],InventoryBalanceCarryForward,strReceiptNumber,intReceiptId )
EXEC uspRKGetCompanyOwnership @dtmFromTransactionDate=@dtmFromTransactionDate,@dtmToTransactionDate=@dtmToTransactionDate, @intCommodityId =  @intCommodityId, @intItemId=@intItemId

INSERT INTO @tblFirstResult (dtmDate ,   tranShipQty , tranRecQty ,  dblAdjustmentQty , BalanceForward )
EXEC uspRKGetInventoryBalance @dtmFromTransactionDate=@dtmFromTransactionDate,@dtmToTransactionDate=@dtmToTransactionDate, @intCommodityId =  @intCommodityId, @intItemId=@intItemId


INSERT INTO @tblResultFinal (dtmDate,dblUnpaidIn,dblUnpaidOut,BalanceForward,dblUnpaidBalance,InventoryBalanceCarryForward)
SELECT
  dtmDate,sum([Unpaid IN]) tranRecQty,sum([Unpaid Out]) tranShipQty,sum([Unpaid Balance]) dblUnpaidBalance,
    (SELECT SUM([Unpaid Balance]) FROM @tblResult AS T2 WHERE isnull(T2.dtmDate,'01/01/1900') <= isnull(T1.dtmDate,'01/01/1900')) AS [Unpaid Balance],sum(InventoryBalanceCarryForward) InventoryBalanceCarryForward
FROM @tblResult T1 GROUP BY dtmDate

DECLARE @tblConsolidatedResult TABLE
(Id INT identity(1,1),
       dtmDate datetime,
       [Receive In] NUMERIC(24,10),
       [Ship Out] NUMERIC(24,10),
       [Adjustments] NUMERIC(24,10),
       BalanceForward NUMERIC(24,10),
       InventoryBalanceCarryForward NUMERIC(24,10),
       [Unpaid In] NUMERIC(24,10),
       [Unpaid Out] NUMERIC(24,10),
       dblUnpaidOut NUMERIC(24,10),
       [Balance] NUMERIC(24,10),
       [Unpaid Balance] NUMERIC(24,10)
)
INSERT INTO @tblConsolidatedResult(dtmDate ,[Receive In],[Ship Out],[Adjustments],BalanceForward,InventoryBalanceCarryForward ,
              [Unpaid In],[Unpaid Out],[Balance], [Unpaid Balance])

SELECT isnull(a.dtmDate,b.dtmDate) [Date],isnull(a.tranRecQty,0) [Receive In],       isnull(a.tranShipQty,0) [Ship Out], isnull(dblAdjustmentQty,0) [Adjustments],
                     isnull(a.BalanceForward,0) BalanceForward,isnull(a.BalanceForward,0)+ isnull(b.InventoryBalanceCarryForward,0),
              isnull(b.dblUnpaidIn,0) [Unpaid In],isnull(b.dblUnpaidOut,0) [Unpaid Out],
                     isnull(b.dblUnpaidBalance,0) as [Balance1],null [Unpaid Balance] 
FROM @tblFirstResult a
FULL JOIN @tblResultFinal b on a.dtmDate=b.dtmDate ORDER BY b.dtmDate,a.dtmDate asc

SELECT CONVERT(INT,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum,* FROM(
SELECT DISTINCT dtmDate,[Receive In] as [dblReceiveIn],[Ship Out] as [dblShipOut],Adjustments as dblAdjustments,isnull([InventoryBalance],0) as [dblInventoryBalance],
[Unpaid In] as dblUnpaidIn,[Unpaid Out] dblUnpaidOut,[Balance] dblBalance,    
          ISNULL([InventoryBalance],0) - isnull( [Balance] ,0) [dblPaidBalance], 
          ISNULL([Balance],0) + (isnull([InventoryBalance],0) - isnull( [Balance] ,0)) [dblTotalCompanyOwned],
           isnull(isnull([Unpaid In],0)-isnull([Unpaid Out],0),0) dblUnpaidBalance
FROM (
SELECT dtmDate ,[Receive In],[Ship Out],[Adjustments],BalanceForward, InventoryBalanceCarryForward,
              (SELECT SUM(BalanceForward) FROM @tblConsolidatedResult AS T2 WHERE isnull(T2.dtmDate,'01/01/1900') <= isnull(t.dtmDate,'01/01/1900')) AS 
                       [InventoryBalance],
              
                       (case when isnull([Unpaid In],0)=0 and isnull([Unpaid Out],0)=0 then
                           (SELECT top 1 Balance FROM @tblConsolidatedResult AS T2 WHERE Balance > 0 and isnull(T2.dtmDate,'01/01/1900') <= isnull(t.dtmDate,'01/01/1900') order by isnull                                        (T2.dtmDate,'01/01/1900') desc) 
              else [Balance] end) [Balance],
              [Unpaid In],[Unpaid Out]
              
FROM(
SELECT DateData dtmDate ,[Receive In],[Ship Out],[Adjustments],BalanceForward, InventoryBalanceCarryForward,
              [Unpaid In],[Unpaid Out],[Balance]
FROM @tblConsolidatedResult T1
full JOIN @tblDateList list on T1.dtmDate=list.DateData
  )t )t1)t2 order by dtmDate