CREATE PROC uspRKGetInventoryBalanceHeader

       @dtmFromTransactionDate datetime = null,
	   @dtmToTransactionDate datetime = null,
	   @intCommodityId int =  NULL
AS 
DECLARE @tblResult TABLE
(Id INT identity(1,1),
	intRowNum int,
	dtmDate datetime,
	[Distribution] nvarchar(50),
	[Unpaid IN] numeric(18, 6),
	[Unpaid Out] numeric(18, 6),
	[Unpaid Balance] numeric(18, 6),
	[InventoryBalanceCarryForward] numeric(18, 6)
)

DECLARE @tblFirstResult TABLE
(Id INT identity(1,1),
	intRowNum int,
	dtmDate datetime,
	tranShipQty numeric(18, 6),
	tranRecQty numeric(18, 6),
	dblAdjustmentQty numeric(18, 6),
	BalanceForward numeric(18, 6)
)

DECLARE @tblResultFinal TABLE
(Id INT identity(1,1),
	dtmDate datetime,
	strItemNo nvarchar(50),
	dblUnpaidIn numeric(18, 6),
	dblUnpaidOut numeric(18, 6),
	dblUnpaidBalance numeric(18, 6),
   BalanceForward numeric(18, 6),
	InventoryBalanceCarryForward numeric(18, 6)
)

INSERT INTO @tblResult (intRowNum ,dtmDate ,	[Distribution] ,	[Unpaid IN] ,	[Unpaid Out] ,	[Unpaid Balance],InventoryBalanceCarryForward )
EXEC uspRKGetCompanyOwnership @dtmFromTransactionDate=@dtmFromTransactionDate,@dtmToTransactionDate=@dtmToTransactionDate, @intCommodityId =  @intCommodityId

INSERT INTO @tblFirstResult (dtmDate ,	tranShipQty ,	tranRecQty ,	dblAdjustmentQty ,	BalanceForward )
EXEC uspRKGetInventoryBalance @dtmFromTransactionDate=@dtmFromTransactionDate,@dtmToTransactionDate=@dtmToTransactionDate, @intCommodityId =  @intCommodityId


INSERT INTO @tblResultFinal (dtmDate,dblUnpaidIn,dblUnpaidOut,BalanceForward,dblUnpaidBalance,InventoryBalanceCarryForward)
 SELECT
  dtmDate,sum([Unpaid IN]) tranRecQty,sum([Unpaid Out]) tranShipQty,sum([Unpaid Balance]) dblUnpaidBalance,
    (SELECT SUM([Unpaid Balance]) FROM @tblResult AS T2 WHERE isnull(T2.dtmDate,'01/01/1900') <= isnull(T1.dtmDate,'01/01/1900')) AS [Unpaid Balance],sum(InventoryBalanceCarryForward) InventoryBalanceCarryForward
FROM @tblResult T1 GROUP BY dtmDate

DECLARE @tblConsolidatedResult TABLE
(Id INT identity(1,1),
	dtmDate datetime,
	[Receive In] numeric(18, 6),
	[Ship Out] numeric(18, 6),
	[Adjustments] numeric(18, 6),
	BalanceForward numeric(18, 6),
	InventoryBalanceCarryForward numeric(18, 6),
	[Unpaid In] numeric(18, 6),
	[Unpaid Out] numeric(18, 6),
	dblUnpaidOut numeric(18, 6),
	[Balance] numeric(18, 6),
	[Unpaid Balance] numeric(18, 6)
)
insert into @tblConsolidatedResult(dtmDate ,[Receive In],[Ship Out],[Adjustments],BalanceForward,InventoryBalanceCarryForward ,
		[Unpaid In],[Unpaid Out],[Balance], [Unpaid Balance])

SELECT isnull(a.dtmDate,b.dtmDate) [Date],isnull(a.tranRecQty,0) [Receive In],	isnull(a.tranShipQty,0) [Ship Out], isnull(dblAdjustmentQty,0) [Adjustments],
			isnull(a.BalanceForward,0) BalanceForward,isnull(a.BalanceForward,0)+ isnull(b.InventoryBalanceCarryForward,0),
		isnull(b.dblUnpaidIn,0) [Unpaid In],isnull(b.dblUnpaidOut,0) [Unpaid Out],
			isnull(b.dblUnpaidBalance,0) as [Balance1],null [Unpaid Balance] 
FROM @tblFirstResult a
FULL JOIN @tblResultFinal b on a.dtmDate=b.dtmDate order by b.dtmDate,a.dtmDate asc

SELECT convert(int,ROW_NUMBER() OVER (ORDER BY dtmDate)) intRowNum, dtmDate,[Receive In] as [dblReceiveIn],[Ship Out] as [dblShipOut],Adjustments as dblAdjustments,[InventoryBalance] as [dblInventoryBalance],
[Unpaid In] as dblUnpaidIn,[Unpaid Out] dblUnpaidOut,[Balance] dblBalance,	   
	   ISNULL([InventoryBalance],0) - isnull( [Balance] ,0) [dblPaidBalance], 
	   ISNULL([Balance],0) + (isnull([InventoryBalance],0) - isnull( [Balance] ,0)) [dblTotalCompanyOwned],
	    [Unpaid In]-[Unpaid Out] dblUnpaidBalance
FROM (
SELECT dtmDate ,[Receive In],[Ship Out],[Adjustments],BalanceForward, InventoryBalanceCarryForward,
		(SELECT SUM(InventoryBalanceCarryForward) FROM @tblConsolidatedResult AS T2 WHERE isnull(T2.dtmDate,'01/01/1900') <= isnull(t.dtmDate,'01/01/1900')) AS [InventoryBalance],
		[Unpaid In],[Unpaid Out],[Balance]

 FROM(
SELECT	dtmDate ,[Receive In],[Ship Out],[Adjustments],BalanceForward, InventoryBalanceCarryForward,
		[Unpaid In],[Unpaid Out],[Balance]
FROM @tblConsolidatedResult T1 )t )t1 order by dtmDate

