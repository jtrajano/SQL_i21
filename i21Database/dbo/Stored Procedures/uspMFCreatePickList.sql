﻿CREATE PROCEDURE [dbo].[uspMFCreatePickList]
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
Declare @dblWeightPerUnit numeric(18,6)

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
	intItemIssuedUOMId int
)

Declare @tblChildLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	dblWeightPerUnit numeric(18,6)
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
	dblWeightPerUnit numeric(18,6)
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
	dblWeightPerUnit numeric(18,6)
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
	dblReservedQty numeric(18,6)
)

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
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

Select @intPickListPreferenceId=pa.strAttributeValue
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Pick List Preference'

If ISNULL(@intPickListPreferenceId,0)=0
	Set @intPickListPreferenceId=1

--Get Parent Lots from the supplied work orders
Insert Into @tblParentLot(intParentLotId,intItemId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId)
Select wi.intParentLotId,wi.intItemId,sum(wi.dblQuantity) AS dblQuantity,wi.intItemUOMId,
sum(wi.dblIssuedQuantity) AS dblIssuedQuantity,wi.intItemIssuedUOMId 
from tblMFWorkOrderInputParentLot wi 
Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder) 
Group by wi.intParentLotId,wi.intItemId,wi.intItemUOMId,wi.intItemIssuedUOMId

Select @intMinParentLot=Min(intRowNo) from @tblParentLot

While(@intMinParentLot is not null) --Parent Lot Loop
Begin
	Select @intParentLotId=tpl.intParentLotId,@dblReqQty=tpl.dblQuantity,@intItemUOMId=tpl.intItemUOMId,@intItemIssuedUOMId=tpl.intItemIssuedUOMId,
	@dblWeightPerUnit=pl.dblWeightPerQty 
	from @tblParentLot tpl Join tblICParentLot pl on tpl.intParentLotId=pl.intParentLotId where intRowNo=@intMinParentLot

	Delete From @tblChildLot
	Insert Into @tblChildLot(intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblWeightPerUnit)
	Select l.intLotId,intStorageLocationId,dblWeight,intWeightUOMId,
	Case When ISNULL(dblWeightPerQty,0)=0 Then 1 Else dblWeightPerQty End
	from tblICLot l Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId
	Where l.intParentLotId=@intParentLotId And l.dblWeight > 0 And ls.strPrimaryStatus='Active'

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
			dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty)
			Select @intParentLotId,intLotId,intStorageLocationId,@dblReqQty,intItemUOMId,@dblReqQty / dblWeightPerUnit,@intItemIssuedUOMId,
			@dblReqQty / dblWeightPerUnit,@intItemIssuedUOMId,@dblAvailableQty,dblAvailableIssuedQty,dblReservedQty 
			From @tblAvailableLot1 where intRowNo=@intMinChildLot

			GOTO NextParentLot
		End
		Else
		Begin
			Insert Into @tblPickedLot(intParentLotId,intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
			dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty)
			Select @intParentLotId,intLotId,intStorageLocationId,@dblAvailableQty,intItemUOMId,dblAvailableIssuedQty,@intItemIssuedUOMId,
			dblAvailableIssuedQty,@intItemIssuedUOMId,@dblAvailableQty,dblAvailableIssuedQty,dblReservedQty 
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
			dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty)
			Select @intParentLotId,0 AS intLotId,0 AS intStorageLocationId,@dblReqQty AS dblQuantity,@intItemUOMId,(@dblReqQty / @dblWeightPerUnit) AS dblIssuedQuantity,@intItemIssuedUOMId,
			(@dblReqQty / @dblWeightPerUnit) AS dblPickQuantity,@intItemIssuedUOMId,0 AS dblAvailableQty,0 AS dblAvailableIssuedQty,0 AS dblReservedQty
	
			GOTO NextParentLot
		End

	--If no lots are available for remaining required qty, add empty row
	If @dblReqQty > 0
		Insert Into @tblPickedLot(intParentLotId,intLotId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
		dblPickQuantity,intPickUOMId,dblAvailableQty,dblAvailableIssuedQty,dblReservedQty)
		Select @intParentLotId,0 AS intLotId,0 AS intStorageLocationId,@dblReqQty AS dblQuantity,@intItemUOMId,(@dblReqQty / @dblWeightPerUnit) AS dblIssuedQuantity,@intItemIssuedUOMId,
		(@dblReqQty / @dblWeightPerUnit) AS dblPickQuantity,@intItemIssuedUOMId,0 AS dblAvailableQty,0 AS dblAvailableIssuedQty,0 AS dblReservedQty

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
tpl.dblPickQuantity,tpl.intPickUOMId,um1.strUnitMeasure AS strPickUOM,pl.dblWeightPerQty AS dblWeightPerUnit,
pl.intLocationId
From @tblPickedLot tpl join tblICParentLot pl on tpl.intParentLotId=pl.intParentLotId 
Join tblICItem i on pl.intItemId=i.intItemId
Join tblICItemUOM iu on iu.intItemUOMId=tpl.intItemUOMId
Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
Join tblICItemUOM iu1 on iu1.intItemUOMId=tpl.intItemIssuedUOMId
Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId 
Where tpl.intLotId = 0
Order By intParentLotId