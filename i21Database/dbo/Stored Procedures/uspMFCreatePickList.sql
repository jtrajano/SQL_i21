CREATE PROCEDURE [dbo].[uspMFCreatePickList]
	@strWorkOrderIds nvarchar(max),
	@intLocationId int
AS

Declare @index int
Declare @id int
Declare @intMinParentLot int
Declare @intMinChildLot int
Declare @intParentLotId int
Declare @dblReqQty numeric(18,6)
Declare @dblQuantity numeric(18,6)
Declare @dblIssuedQuantity numeric(18,6)
Declare @intItemIssuedUOMId int
Declare @dblAvailableQty numeric(18,6)
Declare @intPickListPreferenceId int
Declare @intManufacturingProcessId int
Declare @intItemUOMId int
Declare @dblWeightPerUnit numeric(38,20)
Declare @ysnBlendSheetRequired bit
Declare @intBlendRequirementId int
DECLARE @intKitStagingLocationId INT
DECLARE @intBlendStagingLocationId INT

Declare @tblWorkOrder AS table
(
	intWorkOrderId int
)

Declare @tblParentLot AS table
(
	intRowNo int IDENTITY(1,1),
	intParentLotId int,
	intItemId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(38,20)
)

Declare @tblChildLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dblWeightPerUnit numeric(38,20)
)

Declare @tblAvailableLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblAvailableQty numeric(18,6),
	intItemUOMId int,
	dblAvailableIssuedQty numeric(18,6),
	intItemIssuedUOMId int,
	dblReservedQty numeric(18,6),
	dblDiffQty numeric(18,6),
	dblWeightPerUnit numeric(38,20)
)

Declare @tblAvailableLot1 AS table
(
	intRowNo int IDENTITY(1,1),
	intLotId int,
	intStorageLocationId int,
	dblAvailableQty numeric(18,6),
	intItemUOMId int,
	dblAvailableIssuedQty numeric(18,6),
	intItemIssuedUOMId int,
	dblReservedQty numeric(18,6),
	dblWeightPerUnit numeric(38,20)
)

Declare @tblPickedLot AS table
(
	intParentLotId int,
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(18,6),
	intPickUOMId int,
	dblAvailableQty numeric(18,6),
	dblAvailableIssuedQty numeric(18,6),
	dblReservedQty numeric(18,6),
	dblWeightPerUnit numeric(38,20)
)

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
)

--Temp Table to hold picked Lots when ysnBlendSheetRequired setting is false, 
--Picked the Lots based on FIFO using Recipe
Declare @tblPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50),
	strItemNo nvarchar(50),
	strDescription nvarchar(200),
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50),
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50),
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(18,6),
	dblDensity numeric(18,6),
	dblRequiredQtyPerSheet numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	dblRiskScore numeric(18,6),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50),
	strLocationName nvarchar(50),
	intLocationId int,
	strSubLocationName nvarchar(50),
	strLotAlias nvarchar(50),
	ysnParentLot bit,
	strRowState nvarchar(50)
)

--Get the Comma Separated Work Order Ids into a table
SET @index = CharIndex(',',@strWorkOrderIds)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strWorkOrderIds,1,@index-1)
        SET @strWorkOrderIds = SUBSTRING(@strWorkOrderIds,@index+1,LEN(@strWorkOrderIds)-@index)

        INSERT INTO @tblWorkOrder values (@id)
        SET @index = CharIndex(',',@strWorkOrderIds)
END
SET @id=@strWorkOrderIds
INSERT INTO @tblWorkOrder values (@id)

Select @intManufacturingProcessId=intManufacturingProcessId From tblMFWorkOrder 
Where intWorkOrderId in (Select TOP 1 intWorkOrderId From @tblWorkOrder)

Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference

If @ysnBlendSheetRequired=0
Begin
	Select @dblQuantity=SUM(dblQuantity) From tblMFWorkOrder 
	Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder)

	Select @intBlendRequirementId=intBlendRequirementId From tblMFWorkOrder 
	Where intWorkOrderId in (Select TOP 1 intWorkOrderId From @tblWorkOrder)

	Insert Into @tblPickedLots
	Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,@dblQuantity

	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(sr.dblQty) from tblICLot l join tblICStockReservation sr on l.intLotId=sr.intLotId 
	Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
	Group by sr.intLotId

	Insert Into @tblChildLot(intLotId,dblQuantity)
	Select l.intLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) AS dblAvailableQty 
	from tblICLot l 
	Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
	Left Join @tblReservedQty rq on l.intLotId=rq.intLotId

	Select DISTINCT tpl.*,cl.dblQuantity AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,(cl.dblQuantity / tpl.dblWeightPerUnit) AS dblAvailableUnit,um.strUnitMeasure AS strAvailableUnitUOM,
	tpl.dblIssuedQuantity AS dblPickQuantity,tpl.intItemIssuedUOMId AS intPickUOMId,tpl.strIssuedUOM AS strPickUOM,
	l.intParentLotId,pl.strParentLotNumber
	From @tblPickedLots tpl Join @tblChildLot cl on tpl.intLotId=cl.intLotId 
	Join tblICLot l on tpl.intLotId=l.intLotId
	Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Left Join @tblReservedQty rq on tpl.intLotId = rq.intLotId
	ORDER BY tpl.strItemNo,tpl.strStorageLocationName

	return
End


Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Kit Staging Location'

Select @intBlendStagingLocationId=ISNULL(intBlendProductionStagingUnitId,0) From tblSMCompanyLocation Where intCompanyLocationId=@intLocationId

Select @intPickListPreferenceId=pa.strAttributeValue
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Pick List Preference'

If ISNULL(@intPickListPreferenceId,0)=0
	Set @intPickListPreferenceId=1

--Get Parent Lots from the supplied work orders
Insert Into @tblParentLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,dblWeightPerUnit)
Select wi.intParentLotId,wi.intItemId,sum(wi.dblQuantity) AS dblQuantity,wi.intItemUOMId,
sum(wi.dblIssuedQuantity) AS dblIssuedQuantity,wi.intItemIssuedUOMId,wi.dblWeightPerUnit 
from tblMFWorkOrderInputParentLot wi 
Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder) 
Group by wi.intParentLotId,wi.intItemId,wi.intItemUOMId,wi.intItemIssuedUOMId,wi.dblWeightPerUnit 

Select @intMinParentLot=Min(intRowNo) from @tblParentLot

While(@intMinParentLot is not null) --Parent Lot Loop
Begin
	Select @intParentLotId=tpl.intParentLotId,@dblReqQty=tpl.dblQuantity,@intItemUOMId=tpl.intItemUOMId,@intItemIssuedUOMId=tpl.intItemIssuedUOMId,
	@dblWeightPerUnit=CASE WHEN ISNULL(tpl.dblWeightPerUnit,0)=0 THEN 1 ELSE tpl.dblWeightPerUnit END 
	from @tblParentLot tpl where intRowNo=@intMinParentLot

	Delete From @tblChildLot
	Insert Into @tblChildLot(intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblWeightPerUnit)
	Select l.intLotId,l.intStorageLocationId,l.dblWeight,l.intWeightUOMId,
	Case When ISNULL(dblWeightPerQty,0)=0 Then 1 Else dblWeightPerQty End
	from tblICLot l Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId 
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Where l.intParentLotId=@intParentLotId And l.intLocationId=@intLocationId And l.dblWeight > 0 
	And ls.strPrimaryStatus='Active' And ISNULL(sl.ysnAllowConsume,0)=1 
	AND l.intStorageLocationId NOT IN (@intKitStagingLocationId,@intBlendStagingLocationId)

	Delete From @tblReservedQty
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(sr.dblQty) from @tblChildLot cl join tblICStockReservation sr on cl.intLotId=sr.intLotId 
	Group by sr.intLotId

	Delete From @tblAvailableLot
	Insert Into @tblAvailableLot(intLotId,intStorageLocationId,dblAvailableQty,intItemUOMId,dblAvailableIssuedQty,intItemIssuedUOMId,dblReservedQty,dblDiffQty,dblWeightPerUnit)
	Select cl.intLotId,cl.intStorageLocationId,(cl.dblQuantity-ISNULL(rq.dblReservedQty,0)) AS dblAvailableQty,cl.intItemUOMId,
	((cl.dblQuantity-ISNULL(rq.dblReservedQty,0))/cl.dblWeightPerUnit) AS dblAvailableIssuedQty,@intItemIssuedUOMId,
	ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	((cl.dblQuantity-ISNULL(rq.dblReservedQty,0)) - @dblReqQty) AS dblDiffQty,cl.dblWeightPerUnit
	from @tblChildLot cl left join @tblReservedQty rq on cl.intLotId=rq.intLotId

	Delete From @tblAvailableLot1
	If @intPickListPreferenceId=1 --Best Match
		Begin
			Insert Into @tblAvailableLot1(intLotId,intStorageLocationId,dblAvailableQty,intItemUOMId,dblAvailableIssuedQty,intItemIssuedUOMId,dblReservedQty,dblWeightPerUnit)
			Select al.intLotId,al.intStorageLocationId,al.dblAvailableQty,al.intItemUOMId,al.dblAvailableIssuedQty,al.intItemIssuedUOMId,al.dblReservedQty,al.dblWeightPerUnit
			from @tblAvailableLot al Where al.dblAvailableQty>0 And dblDiffQty >= 0 Order By dblDiffQty ASC

			Insert Into @tblAvailableLot1(intLotId,intStorageLocationId,dblAvailableQty,intItemUOMId,dblAvailableIssuedQty,intItemIssuedUOMId,dblReservedQty,dblWeightPerUnit)
			Select al.intLotId,al.intStorageLocationId,al.dblAvailableQty,al.intItemUOMId,al.dblAvailableIssuedQty,al.intItemIssuedUOMId,al.dblReservedQty,al.dblWeightPerUnit
			from @tblAvailableLot al Where al.dblAvailableQty>0 And dblDiffQty < 0 Order By dblDiffQty ASC
		End

	If @intPickListPreferenceId=2 --Partial Match
		Begin
			Insert Into @tblAvailableLot1(intLotId,intStorageLocationId,dblAvailableQty,intItemUOMId,dblAvailableIssuedQty,intItemIssuedUOMId,dblReservedQty,dblWeightPerUnit)
			Select al.intLotId,al.intStorageLocationId,al.dblAvailableQty,al.intItemUOMId,al.dblAvailableIssuedQty,al.intItemIssuedUOMId,al.dblReservedQty,al.dblWeightPerUnit
			from @tblAvailableLot al Where al.dblAvailableQty>0 Order By al.dblAvailableQty ASC		
		End

	Select @intMinChildLot=Min(intRowNo) from @tblAvailableLot1 where dblAvailableQty > 0 
	While(@intMinChildLot is not null) --Pick Child Lot Loop
	Begin
		Select @dblAvailableQty=dblAvailableQty from @tblAvailableLot1 where intRowNo=@intMinChildLot

		If @dblAvailableQty >= @dblReqQty
		Begin
			Insert Into @tblPickedLot(intParentLotId,intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
			dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty,dblWeightPerUnit)
			Select @intParentLotId,intLotId,intStorageLocationId,@dblReqQty,intItemUOMId,@dblReqQty / dblWeightPerUnit,@intItemIssuedUOMId,
			@dblReqQty / dblWeightPerUnit,@intItemIssuedUOMId,@dblAvailableQty,dblAvailableIssuedQty,dblReservedQty,dblWeightPerUnit 
			From @tblAvailableLot1 where intRowNo=@intMinChildLot

			GOTO NextParentLot
		End
		Else
		Begin
			Insert Into @tblPickedLot(intParentLotId,intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
			dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty,dblWeightPerUnit)
			Select @intParentLotId,intLotId,intStorageLocationId,@dblAvailableQty,intItemUOMId,dblAvailableIssuedQty,@intItemIssuedUOMId,
			dblAvailableIssuedQty,@intItemIssuedUOMId,@dblAvailableQty,dblAvailableIssuedQty,dblReservedQty,dblWeightPerUnit 
			From @tblAvailableLot1 where intRowNo=@intMinChildLot

			Update @tblAvailableLot1 set dblAvailableQty=0 where intRowNo=@intMinChildLot
			Set @dblReqQty=@dblReqQty-@dblAvailableQty
		End

		Select @intMinChildLot=Min(intRowNo) from @tblAvailableLot1 where dblAvailableQty>0 And intRowNo>@intMinChildLot
	End

	--If no lots available for the parent lot , add empty row
	If (Select count(1) From @tblChildLot) = 0
		Begin
			Insert Into @tblPickedLot(intParentLotId,intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
			dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty,dblWeightPerUnit)
			Select @intParentLotId,0 AS intLotId,0 AS intStorageLocationId,@dblReqQty AS dblQuantity,@intItemUOMId,(@dblReqQty / @dblWeightPerUnit) AS dblIssuedQuantity,@intItemIssuedUOMId,
			(@dblReqQty / @dblWeightPerUnit) AS dblPickQuantity,@intItemIssuedUOMId,0 AS dblAvailableQty,0 AS dblAvailableIssuedQty,0 AS dblReservedQty,@dblWeightPerUnit
	
			GOTO NextParentLot
		End

	--If no lots are available for remaining required qty, add empty row
	If @dblReqQty > 0
		Insert Into @tblPickedLot(intParentLotId,intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
		dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty,dblWeightPerUnit)
		Select @intParentLotId,0 AS intLotId,0 AS intStorageLocationId,@dblReqQty AS dblQuantity,@intItemUOMId,(@dblReqQty / @dblWeightPerUnit) AS dblIssuedQuantity,@intItemIssuedUOMId,
		(@dblReqQty / @dblWeightPerUnit) AS dblPickQuantity,@intItemIssuedUOMId,0 AS dblAvailableQty,0 AS dblAvailableIssuedQty,0 AS dblReservedQty,@dblWeightPerUnit

	NextParentLot:
	Select @intMinParentLot=Min(intRowNo) from @tblParentLot where intRowNo>@intMinParentLot
End --End Paraent Lot Loop

Select tpl.intLotId, l.strLotNumber,l.strLotAlias,
l.intParentLotId,pl.strParentLotNumber,l.intItemId,i.strItemNo,i.strDescription,
sl.intStorageLocationId,sl.strName AS strStorageLocationName,
tpl.dblQuantity,tpl.intItemUOMId,um.strUnitMeasure AS strUOM,tpl.dblIssuedQuantity,tpl.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM,
tpl.dblAvailableQty,tpl.dblReservedQty,tpl.dblAvailableIssuedQty AS dblAvailableUnit,um1.strUnitMeasure AS strAvailableUnitUOM,
tpl.dblPickQuantity,tpl.intPickUOMId,um1.strUnitMeasure AS strPickUOM,l.dblWeightPerQty AS dblWeightPerUnit,
l.intLocationId
From @tblPickedLot tpl Join tblICLot l on tpl.intLotId=l.intLotId 
Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
Join tblICItem i on l.intItemId=i.intItemId
Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId 
Join tblICItemUOM iu on iu.intItemUOMId=tpl.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICItemUOM iu1 on iu1.intItemUOMId=tpl.intItemIssuedUOMId
Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
Where l.dblQty > 0 And tpl.intLotId > 0
UNION ALL
Select 0 AS intLotId , '' strLotNumber,pl.strParentLotAlias,
pl.intParentLotId,pl.strParentLotNumber,pl.intItemId,i.strItemNo,i.strDescription,
0 AS intStorageLocationId,'' AS strStorageLocationName,
tpl.dblQuantity,tpl.intItemUOMId,um.strUnitMeasure AS strUOM,tpl.dblIssuedQuantity,tpl.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM,
tpl.dblAvailableQty,tpl.dblReservedQty,tpl.dblAvailableIssuedQty AS dblAvailableUnit,um1.strUnitMeasure AS strAvailableUnitUOM,
tpl.dblPickQuantity,tpl.intPickUOMId,um1.strUnitMeasure AS strPickUOM,tpl.dblWeightPerUnit,
@intLocationId AS intLocationId
From @tblPickedLot tpl join tblICParentLot pl on tpl.intParentLotId=pl.intParentLotId 
Join tblICItem i on pl.intItemId=i.intItemId
Join tblICItemUOM iu on iu.intItemUOMId=tpl.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICItemUOM iu1 on iu1.intItemUOMId=tpl.intItemIssuedUOMId
Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId 
Where tpl.intLotId = 0
Order By intParentLotId