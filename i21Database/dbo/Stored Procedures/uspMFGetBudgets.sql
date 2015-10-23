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
	strConfirmedUserName nvarchar(50)
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
	strConfirmedUserName nvarchar(50)
)

Insert Into @tblBudgetAll
Select 0 AS intBudgetId,@intYear AS intYear,@intLocationId AS intLocationId,i.intItemId,i.strItemNo,i.strDescription,
bgt.intBudgetTypeId,bgt.strName AS strBudgetTypeName,bgt.strDescription AS strBudgetTypeDesc,
NULL AS dblJan,NULL AS dblFeb,NULL AS dblMar,NULL AS dblApr,NULL AS dblMay,NULL AS dblJun,NULL AS dblJul,NULL AS dblAug,NULL AS dblSep,NULL AS dblOct,NULL AS dblNov,NULL AS dblDec,NULL AS dblYTD,
CAST(0 AS BIT) AS ysnConfirmed,0 AS intConfirmedByMonth,0 AS intConfirmedUserId,NULL AS dtmConfirmedDate,0 AS intCreatedUserId,NULL AS dtmCreated,0 AS intLastModifiedUserId,
NULL AS dtmLastModified,0 AS intConcurrencyId,'' AS strConfirmedUserName
From tblICItem i --Left Join tblMFBudget bg on i.intItemId=bg.intItemId And bg.intYear=@intYear
Cross Join tblMFBudgetType bgt 
Join tblMFRecipe r on i.intItemId=r.intItemId And r.intLocationId=@intLocationId And r.ysnActive=1 
Join tblMFManufacturingProcess mp on r.intManufacturingProcessId=mp.intManufacturingProcessId And mp.intAttributeTypeId=2
Order By i.strItemNo,bgt.intBudgetTypeId


Insert Into @tblBudget
Select ISNULL(bg.intBudgetId,0) AS intBudgetId,@intYear AS intYear,@intLocationId AS intLocationId,i.intItemId,bgt.intBudgetTypeId,
bg.dblJan,bg.dblFeb,bg.dblMar,bg.dblApr,bg.dblMay,bg.dblJun,bg.dblJul,bg.dblAug,bg.dblSep,bg.dblOct,bg.dblNov,bg.dblDec,bg.dblYTD,
CAST(ISNULL(bg.ysnConfirmed,0) AS BIT) AS ysnConfirmed,ISNULL(bg.intConfirmedByMonth,0) AS intConfirmedByMonth,bg.intConfirmedUserId,bg.dtmConfirmedDate,bg.intCreatedUserId,bg.dtmCreated,bg.intLastModifiedUserId,
bg.dtmLastModified,ISNULL(bg.intConcurrencyId,0) AS intConcurrencyId,'' AS strConfirmedUserName 
From tblMFBudget bg Join tblICItem i on bg.intItemId=i.intItemId 
Join tblMFBudgetType bgt on bg.intBudgetTypeId=bgt.intBudgetTypeId
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
bga.intConcurrencyId=bg.intConcurrencyId
From @tblBudgetAll bga Join @tblBudget bg on bga.intYear=bg.intYear And bga.intLocationId=bg.intLocationId 
And bga.intItemId=bg.intItemId And bga.intBudgetTypeId=bg.intBudgetTypeId

Select * from @tblBudgetAll