CREATE PROCEDURE [dbo].[uspMFGetBudgets]
	@intYear int,
	@intLocationId int
AS
Declare @tblBudgetAll table
(
	intBudgetId int,
	intYear int,
	intLocationId int,
	intItemId int,
	strItemNo nvarchar(50),
	strDescription nvarchar(200),
	intBudgetTypeId int,
	strBudgetTypeName nvarchar(50),
	strBudgetTypeDesc nvarchar(50),
	dblJan numeric(18,6),
	dblFeb numeric(18,6),
	dblMar numeric(18,6),
	dblApr numeric(18,6),
	dblMay numeric(18,6),
	dblJun numeric(18,6),
	dblJul numeric(18,6),
	dblAug numeric(18,6),
	dblSep numeric(18,6),
	dblOct numeric(18,6),
	dblNov numeric(18,6),
	dblDec numeric(18,6),
	dblYTD numeric(18,6),
	ysnConfirmed BIT,
	intConfirmedByMonth INT,
	intConfirmedUserId INT,
	dtmConfirmedDate DATETIME,
	intCreatedUserId INT,
	dtmCreated DATETIME,
	intLastModifiedUserId INT,
	dtmLastModified DATETIME,
	intConcurrencyId INT,
	strConfirmedUserName nvarchar(50),
	strConfirmedByMonth nvarchar(50)
)

Declare @tblBudget table
(
	intBudgetId int,
	intYear int,
	intLocationId int,
	intItemId int,
	intBudgetTypeId int,
	dblJan numeric(18,6),
	dblFeb numeric(18,6),
	dblMar numeric(18,6),
	dblApr numeric(18,6),
	dblMay numeric(18,6),
	dblJun numeric(18,6),
	dblJul numeric(18,6),
	dblAug numeric(18,6),
	dblSep numeric(18,6),
	dblOct numeric(18,6),
	dblNov numeric(18,6),
	dblDec numeric(18,6),
	dblYTD numeric(18,6),
	ysnConfirmed BIT,
	intConfirmedByMonth INT,
	intConfirmedUserId INT,
	dtmConfirmedDate DATETIME,
	intCreatedUserId INT,
	dtmCreated DATETIME,
	intLastModifiedUserId INT,
	dtmLastModified DATETIME,
	intConcurrencyId INT,
	strConfirmedUserName nvarchar(50),
	strConfirmedByMonth nvarchar(50)
)

Declare @tblBudgetQtyCost table
(
	intItemId int,
	intMonth int,
	dblMonthQty numeric(18,6),
	dblMonthCost numeric(18,6),
	dblMonthAverage numeric(18,6)
)

Insert Into @tblBudgetAll
Select 0 AS intBudgetId,@intYear AS intYear,@intLocationId AS intLocationId,i.intItemId,i.strItemNo,i.strDescription,
bgt.intBudgetTypeId,bgt.strName AS strBudgetTypeName,bgt.strDescription AS strBudgetTypeDesc,
NULL AS dblJan,NULL AS dblFeb,NULL AS dblMar,NULL AS dblApr,NULL AS dblMay,NULL AS dblJun,NULL AS dblJul,NULL AS dblAug,NULL AS dblSep,NULL AS dblOct,NULL AS dblNov,NULL AS dblDec,NULL AS dblYTD,
CAST(0 AS BIT) AS ysnConfirmed,0 AS intConfirmedByMonth,0 AS intConfirmedUserId,NULL AS dtmConfirmedDate,0 AS intCreatedUserId,NULL AS dtmCreated,0 AS intLastModifiedUserId,
NULL AS dtmLastModified,0 AS intConcurrencyId,'' AS strConfirmedUserName,'' AS strConfirmedByMonth
From tblICItem i --Left Join tblMFBudget bg on i.intItemId=bg.intItemId And bg.intYear=@intYear
Cross Join tblMFBudgetType bgt 
Join tblMFRecipe r on i.intItemId=r.intItemId And r.intLocationId=@intLocationId And r.ysnActive=1 
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId And mp.intAttributeTypeId=2
Order By i.strItemNo,bgt.intBudgetTypeId


Insert Into @tblBudget
Select ISNULL(bg.intBudgetId,0) AS intBudgetId,@intYear AS intYear,@intLocationId AS intLocationId,i.intItemId,bgt.intBudgetTypeId,
bg.dblJan,bg.dblFeb,bg.dblMar,bg.dblApr,bg.dblMay,bg.dblJun,bg.dblJul,bg.dblAug,bg.dblSep,bg.dblOct,bg.dblNov,bg.dblDec,bg.dblYTD,
CAST(ISNULL(bg.ysnConfirmed,0) AS BIT) AS ysnConfirmed,ISNULL(bg.intConfirmedByMonth,0) AS intConfirmedByMonth,bg.intConfirmedUserId,bg.dtmConfirmedDate,bg.intCreatedUserId,bg.dtmCreated,bg.intLastModifiedUserId,
bg.dtmLastModified,ISNULL(bg.intConcurrencyId,0) AS intConcurrencyId,us.strUserName AS strConfirmedUserName,
CASE WHEN bg.intConfirmedByMonth>0 THEN Left(DateName( month , DateAdd( month , bg.intConfirmedByMonth , -1 ) ),3) ELSE '' END AS strConfirmedByMonth
From tblMFBudget bg Join tblICItem i on bg.intItemId=i.intItemId 
Join tblMFBudgetType bgt on bg.intBudgetTypeId=bgt.intBudgetTypeId
Left Join tblSMUserSecurity us on bg.intConfirmedUserId=us.intEntityId
Where bg.intYear=@intYear And bg.intLocationId=@intLocationId

Update bga Set bga.intBudgetId=bg.intBudgetId,
bga.intYear=bg.intYear,
bga.intLocationId=bg.intLocationId,
bga.intItemId=bg.intItemId,
bga.intBudgetTypeId=bg.intBudgetTypeId,
bga.dblJan=bg.dblJan,
bga.dblFeb=bg.dblFeb,
bga.dblMar=bg.dblMar,
bga.dblApr=bg.dblApr,
bga.dblMay=bg.dblMay,
bga.dblJun=bg.dblJun,
bga.dblJul=bg.dblJul,
bga.dblAug=bg.dblAug,
bga.dblSep=bg.dblSep,
bga.dblOct=bg.dblOct,
bga.dblNov=bg.dblNov,
bga.dblDec=bg.dblDec,
bga.ysnConfirmed=bg.ysnConfirmed,
bga.intConfirmedByMonth=bg.intConfirmedByMonth,
bga.intConfirmedUserId=bg.intConfirmedUserId,
bga.dtmConfirmedDate=bg.dtmConfirmedDate,
bga.intCreatedUserId=bg.intCreatedUserId,
bga.dtmCreated=bg.dtmCreated,
bga.intLastModifiedUserId=bg.intLastModifiedUserId,
bga.dtmLastModified=bg.dtmLastModified,
bga.intConcurrencyId=bg.intConcurrencyId,
bga.strConfirmedUserName=bg.strConfirmedUserName,
bga.strConfirmedByMonth=bg.strConfirmedByMonth
From @tblBudgetAll bga Join @tblBudget bg on bga.intYear=bg.intYear And bga.intLocationId=bg.intLocationId 
And bga.intItemId=bg.intItemId And bga.intBudgetTypeId=bg.intBudgetTypeId

--Get the month wise production Qty and Cost
Insert Into @tblBudgetQtyCost
Select t1.*,t1.dblMonthCost/t1.dblMonthQty dblMonthAverage from
(
Select t.intItemId,t.intMonth,SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId,t.intItemUOMId,t.dblQuantity)) dblMonthQty ,
SUM(dbo.fnICConvertUOMtoStockUnit(t.intItemId,t.intItemUOMId,t.dblQuantity) * t.dblLastCost) dblMonthCost
From
(
Select MONTH(wp.dtmProductionDate) intMonth,wp.intItemId,wp.intItemUOMId,wp.dblQuantity,l.dblLastCost 
From tblMFWorkOrderProducedLot wp Join tblICLot l on wp.intLotId=l.intLotId 
Join @tblBudget bg on wp.intItemId=bg.intItemId
Where YEAR(wp.dtmProductionDate)=@intYear AND l.intLocationId=@intLocationId
) t 
Group By t.intItemId,t.intMonth
) t1 Where t1.dblMonthQty>0

--Month Average
Update bga Set 
bga.dblJan=CASE WHEN t2.intMonth=1 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblFeb=CASE WHEN t2.intMonth=2 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblMar=CASE WHEN t2.intMonth=3 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblApr=CASE WHEN t2.intMonth=4 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblMay=CASE WHEN t2.intMonth=5 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblJun=CASE WHEN t2.intMonth=6 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblJul=CASE WHEN t2.intMonth=7 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblAug=CASE WHEN t2.intMonth=8 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblSep=CASE WHEN t2.intMonth=9 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblOct=CASE WHEN t2.intMonth=10 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblNov=CASE WHEN t2.intMonth=11 THEN t2.dblMonthAverage ELSE NULL END,
bga.dblDec=CASE WHEN t2.intMonth=12 THEN t2.dblMonthAverage ELSE NULL END
From @tblBudgetAll bga Join
@tblBudgetQtyCost t2 on bga.intItemId=t2.intItemId AND bga.intBudgetTypeId=3

--Month Average YTD
Update bga Set bga.dblYTD = t.dblYTD
From @tblBudgetAll bga Join
(
Select intItemId,SUM(ISNULL(dblMonthCost,0.0)) / CASE WHEN SUM(ISNULL(dblMonthQty,0.0)) > 0 THEN SUM(ISNULL(dblMonthQty,0.0)) ELSE NULL END dblYTD From
@tblBudgetQtyCost 
Group By intItemId
) t
on bga.intItemId=t.intItemId
Where bga.intBudgetTypeId=3

--Variance
Update bga Set 
bga.dblJan=(Select dblJan From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblJan From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblFeb=(Select dblFeb From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblFeb From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblMar=(Select dblMar From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblMar From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblApr=(Select dblApr From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblApr From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblMay=(Select dblMay From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblMay From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblJun=(Select dblJun From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblJun From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblJul=(Select dblJul From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblJul From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblAug=(Select dblAug From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblAug From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblSep=(Select dblSep From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblSep From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblOct=(Select dblOct From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblOct From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblNov=(Select dblNov From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblNov From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3),
bga.dblDec=(Select dblDec From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=2) - (Select dblDec From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=3)
From @tblBudgetAll bga Join @tblBudgetAll bga1 on bga.intItemId=bga1.intItemId Where bga.intBudgetTypeId=4

--Variance YTD
Update @tblBudgetAll Set dblYTD = (ISNULL(dblJan,0.0)+ISNULL(dblFeb,0.0)+ISNULL(dblMar,0.0)+ISNULL(dblApr,0.0)+ISNULL(dblMay,0.0)+ISNULL(dblJun,0.0)
+ISNULL(dblJul,0.0)+ISNULL(dblAug,0.0)+ISNULL(dblSep,0.0)+ISNULL(dblOct,0.0)+ISNULL(dblNov,0.0)+ISNULL(dblDec,0.0))
Where intBudgetTypeId=4

--Total Qty in Stock UOM
Update bga Set 
bga.dblJan=CASE WHEN t2.intMonth=1 THEN t2.dblMonthQty ELSE NULL END,
bga.dblFeb=CASE WHEN t2.intMonth=2 THEN t2.dblMonthQty ELSE NULL END,
bga.dblMar=CASE WHEN t2.intMonth=3 THEN t2.dblMonthQty ELSE NULL END,
bga.dblApr=CASE WHEN t2.intMonth=4 THEN t2.dblMonthQty ELSE NULL END,
bga.dblMay=CASE WHEN t2.intMonth=5 THEN t2.dblMonthQty ELSE NULL END,
bga.dblJun=CASE WHEN t2.intMonth=6 THEN t2.dblMonthQty ELSE NULL END,
bga.dblJul=CASE WHEN t2.intMonth=7 THEN t2.dblMonthQty ELSE NULL END,
bga.dblAug=CASE WHEN t2.intMonth=8 THEN t2.dblMonthQty ELSE NULL END,
bga.dblSep=CASE WHEN t2.intMonth=9 THEN t2.dblMonthQty ELSE NULL END,
bga.dblOct=CASE WHEN t2.intMonth=10 THEN t2.dblMonthQty ELSE NULL END,
bga.dblNov=CASE WHEN t2.intMonth=11 THEN t2.dblMonthQty ELSE NULL END,
bga.dblDec=CASE WHEN t2.intMonth=12 THEN t2.dblMonthQty ELSE NULL END
From @tblBudgetAll bga Join
@tblBudgetQtyCost t2 on bga.intItemId=t2.intItemId AND bga.intBudgetTypeId=5

--Total Qty in Stock UOM YTD
Update bga Set bga.dblYTD = t.dblYTD
From @tblBudgetAll bga Join
(
Select intItemId,SUM(ISNULL(dblMonthQty,0.0)) dblYTD From
@tblBudgetQtyCost 
Group By intItemId
) t
on bga.intItemId=t.intItemId
Where bga.intBudgetTypeId=5

--Impact (USD)
Update bga Set 
bga.dblJan=(Select dblJan From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblJan From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblFeb=(Select dblFeb From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblFeb From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblMar=(Select dblMar From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblMar From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblApr=(Select dblApr From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblApr From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblMay=(Select dblMay From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblMay From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblJun=(Select dblJun From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblJun From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblJul=(Select dblJul From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblJul From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblAug=(Select dblAug From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblAug From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblSep=(Select dblSep From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblSep From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblOct=(Select dblOct From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblOct From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblNov=(Select dblNov From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblNov From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5),
bga.dblDec=(Select dblDec From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=4) * (Select dblDec From @tblBudgetAll Where intItemId=bga.intItemId AND intBudgetTypeId=5)
From @tblBudgetAll bga Join @tblBudgetAll bga1 on bga.intItemId=bga1.intItemId Where bga.intBudgetTypeId=6

--Impact (USD) YTD
Update @tblBudgetAll Set dblYTD = (ISNULL(dblJan,0.0)+ISNULL(dblFeb,0.0)+ISNULL(dblMar,0.0)+ISNULL(dblApr,0.0)+ISNULL(dblMay,0.0)+ISNULL(dblJun,0.0)
+ISNULL(dblJul,0.0)+ISNULL(dblAug,0.0)+ISNULL(dblSep,0.0)+ISNULL(dblOct,0.0)+ISNULL(dblNov,0.0)+ISNULL(dblDec,0.0))
Where intBudgetTypeId=6

--Change the Budget Type Desc
Update @tblBudgetAll Set strBudgetTypeDesc=CASE WHEN intBudgetTypeId=5 THEN 'Total Quantity in Stock UOM' 
WHEN intBudgetTypeId=6 THEN 'Impact Cost (in ' + 
(Select TOP 1 ISNULL(c.strCurrency,'') from tblSMCompanyPreference cp join tblSMCurrency c on cp.intDefaultReportingCurrencyId=c.intCurrencyID) + ')' ELSE strBudgetTypeDesc END

Select ROW_NUMBER() OVER(ORDER BY intItemId,intBudgetTypeId) intRowNo , * from @tblBudgetAll