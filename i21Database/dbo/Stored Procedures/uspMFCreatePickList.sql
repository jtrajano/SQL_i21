CREATE PROCEDURE [dbo].[uspMFCreatePickList]
	@strWorkOrderIds nvarchar(max),
	@intLocationId int
AS

Declare @index int
Declare @id int
Declare @intMinParentLot int
Declare @intMinChildLot int
Declare @intParentLotId int
Declare @dblReqQty numeric(38,20)
Declare @dblQuantity numeric(38,20)
Declare @dblIssuedQuantity numeric(38,20)
Declare @intItemIssuedUOMId int
Declare @dblAvailableQty numeric(38,20)
Declare @intPickListPreferenceId int
Declare @intManufacturingProcessId int
Declare @intItemUOMId int
Declare @dblWeightPerUnit numeric(38,20)
Declare @ysnBlendSheetRequired bit
Declare @intBlendRequirementId int
DECLARE @intKitStagingLocationId INT
DECLARE @intBlendStagingLocationId INT
Declare @ysnIsSubstitute bit
Declare @intParentItemId int
Declare @intMinItemCount int,
		@intRecipeItemId int,
		@intRawItemId int,
		@dblRequiredQty numeric(38,20),
		@intConsumptionMethodId int,
		@intConsumptionStoragelocationId int,
		@strXml nvarchar(max),
		@intRecipeId int,
		@intBlendItemId int

Declare @tblWorkOrder AS table
(
	intWorkOrderId int
)

Declare @tblParentLot AS table
(
	intRowNo int IDENTITY(1,1),
	intParentLotId int,
	intItemId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	dblWeightPerUnit numeric(38,20)
)

Declare @tblChildLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblWeightPerUnit numeric(38,20)
)

Declare @tblAvailableLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblAvailableQty numeric(38,20),
	intItemUOMId int,
	dblAvailableIssuedQty numeric(38,20),
	intItemIssuedUOMId int,
	dblReservedQty numeric(38,20),
	dblDiffQty numeric(38,20),
	dblWeightPerUnit numeric(38,20)
)

Declare @tblAvailableLot1 AS table
(
	intRowNo int IDENTITY(1,1),
	intLotId int,
	intStorageLocationId int,
	dblAvailableQty numeric(38,20),
	intItemUOMId int,
	dblAvailableIssuedQty numeric(38,20),
	intItemIssuedUOMId int,
	dblReservedQty numeric(38,20),
	dblWeightPerUnit numeric(38,20)
)

Declare @tblPickedLot AS table
(
	intParentLotId int,
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	dblAvailableQty numeric(38,20),
	dblAvailableIssuedQty numeric(38,20),
	dblReservedQty numeric(38,20),
	dblWeightPerUnit numeric(38,20)
)

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(38,20)
)

--Temp Table to hold picked Lots when ysnBlendSheetRequired setting is false, 
--Picked the Lots based on FIFO using Recipe
Declare @tblPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(38,20),
	dblDensity numeric(38,20),
	dblRequiredQtyPerSheet numeric(38,20),
	dblWeightPerUnit numeric(38,20),
	dblRiskScore numeric(38,20),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intLocationId int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intSubLocationId int,
	strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
	ysnParentLot bit,
	strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
)

--to hold not available and less qty lots
Declare @tblRemainingPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(38,20),
	dblDensity numeric(38,20),
	dblRequiredQtyPerSheet numeric(38,20),
	dblWeightPerUnit numeric(38,20),
	dblRiskScore numeric(38,20),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intLocationId int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intSubLocationId int,
	strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
	ysnParentLot bit,
	strRowState nvarchar(50) COLLATE Latin1_General_CI_AS
)

--Bulk Item Picking if WO is created from Blend Management
Declare @tblRemainingPickedItems AS table
( 
	intRowNo int IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(38,20),
	intConsumptionMethodId int,
	ysnIsSubstitute bit
)

DECLARE @tblInputItem TABLE (
	intItemId INT
	,dblRequiredQty NUMERIC(38,20)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
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

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Kit Staging Location'

Select @intBlendStagingLocationId=ISNULL(intBlendProductionStagingUnitId,0) From tblSMCompanyLocation Where intCompanyLocationId=@intLocationId

If @ysnBlendSheetRequired=0
Begin
	Select @dblQuantity=SUM(dblQuantity) From tblMFWorkOrder 
	Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder)

	Select @intBlendRequirementId=intBlendRequirementId,@intBlendItemId=intItemId From tblMFWorkOrder 
	Where intWorkOrderId in (Select TOP 1 intWorkOrderId From @tblWorkOrder)

	--Get Recipe Items
	Select @dblQuantity=SUM(dblPlannedQuantity) From tblMFWorkOrder 
	Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder)

	SELECT @intRecipeId = intRecipeId
	FROM tblMFWorkOrderRecipe
	WHERE intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1 
		AND intWorkOrderId = (Select TOP 1 intWorkOrderId From @tblWorkOrder)

		INSERT INTO @tblInputItem (
		intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,intConsumptionMethodId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQuantity / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = (Select TOP 1 intWorkOrderId From @tblWorkOrder)

	UNION
	SELECT 
		rs.intSubstituteItemId
		,(rs.dblQuantity * (@dblQuantity / r.dblQuantity)) AS dblRequiredQty
		,1
		,ri.intConsumptionMethodId
	FROM tblMFWorkOrderRecipeSubstituteItem rs 
	JOIN tblMFWorkOrderRecipeItem ri ON rs.intRecipeItemId=ri.intRecipeItemId
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = (Select TOP 1 intWorkOrderId From @tblWorkOrder)

	--WO created from Blend Management Screen if Lots are there input lot table when kitting enabled
	If Exists (Select 1 From tblMFWorkOrderInputLot Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder))
		Begin
			Insert Into @tblPickedLots
			Select 0,l.intLotId,l.strLotNumber,i.strItemNo,i.strDescription,SUM(wi.dblQuantity),wi.intItemUOMId,um.strUnitMeasure,
			SUM(wi.dblIssuedQuantity),wi.intItemIssuedUOMId,um1.strUnitMeasure,i.intItemId,
			0,0.0,0.0,0.0,AVG(l.dblWeightPerQty),0.0,l.intStorageLocationId,sl.strName,'',@intLocationId,'',0,l.strLotAlias,0,'Added'
			From tblMFWorkOrderInputLot wi join tblICLot l on wi.intLotId=l.intLotId 
			Join tblICItem i on l.intItemId=i.intItemId
			Join tblICItemUOM iu on wi.intItemUOMId=iu.intItemUOMId
			Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
			Join tblICItemUOM iu1 on wi.intItemIssuedUOMId=iu1.intItemUOMId
			Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
			Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
			Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder) 
			Group By l.intLotId,l.strLotNumber,i.strItemNo,i.strDescription,wi.intItemUOMId,um.strUnitMeasure,
			wi.intItemIssuedUOMId,um1.strUnitMeasure,i.intItemId,
			l.intStorageLocationId,sl.strName,l.strLotAlias

			Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId,ysnIsSubstitute)
			Select ti.intItemId,ti.dblRequiredQty AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.ysnIsSubstitute 
			From @tblInputItem ti 
			WHERE ti.intConsumptionMethodId in (2,3)

			--Find the Remaining Lots
			If (Select COUNT(1) From @tblRemainingPickedItems) > 0
			Begin
				Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

				Set @strXml = '<root>'
				While(@intMinItemCount is not null)
				Begin
					Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity,@ysnIsSubstitute=ysnIsSubstitute
					From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

					If @ysnIsSubstitute=0
						Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId,
						@intParentItemId=0 
						From tblMFWorkOrderRecipe r Join tblMFWorkOrderRecipeItem ri on r.intWorkOrderId=ri.intWorkOrderId 
						Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1 
						AND r.intWorkOrderId = (Select TOP 1 intWorkOrderId From @tblWorkOrder)

					If @ysnIsSubstitute=1
						Select @intRecipeItemId=rs.intRecipeSubstituteItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId,
						@intParentItemId=rs.intItemId 
						From tblMFWorkOrderRecipe r Join tblMFWorkOrderRecipeItem ri on r.intWorkOrderId=ri.intWorkOrderId 
						Join tblMFWorkOrderRecipeSubstituteItem rs on ri.intRecipeItemId=rs.intRecipeItemId
						Where r.intRecipeId=@intRecipeId And rs.intSubstituteItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1 
						AND r.intWorkOrderId = (Select TOP 1 intWorkOrderId From @tblWorkOrder)

					Set @strXml = @strXml + '<item>'
					Set @strXml = @strXml + '<intRecipeId>' + CONVERT(varchar,@intRecipeId) + '</intRecipeId>'
					Set @strXml = @strXml + '<intRecipeItemId>' + CONVERT(varchar,@intRecipeItemId) + '</intRecipeItemId>'
					Set @strXml = @strXml + '<intItemId>' + CONVERT(varchar,@intRawItemId) + '</intItemId>'
					Set @strXml = @strXml + '<dblRequiredQty>' + CONVERT(varchar,@dblRequiredQty) + '</dblRequiredQty>'
					Set @strXml = @strXml + '<ysnIsSubstitute>' + CONVERT(varchar,@ysnIsSubstitute) + '</ysnIsSubstitute>'
					Set @strXml = @strXml + '<ysnMinorIngredient>' + CONVERT(varchar,0) + '</ysnMinorIngredient>'
					Set @strXml = @strXml + '<intConsumptionMethodId>' + CONVERT(varchar,@intConsumptionMethodId) + '</intConsumptionMethodId>'
					Set @strXml = @strXml + '<intConsumptionStoragelocationId>' + CONVERT(varchar,ISNULL(@intConsumptionStoragelocationId,0)) + '</intConsumptionStoragelocationId>'
					Set @strXml = @strXml + '<intParentItemId>' + CONVERT(varchar,@intParentItemId) + '</intParentItemId>'
					Set @strXml = @strXml + '</item>'

					Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems Where intRowNo > @intMinItemCount
				End
				Set @strXml = @strXml + '</root>'

				Insert Into @tblPickedLots
				Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXml,1,'',@strWorkOrderIds
			End
		End
	Else
		Insert Into @tblPickedLots
		Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,@dblQuantity,'',1,'',@strWorkOrderIds

	--Remaining Lots to Pick
	Insert Into @tblRemainingPickedLots
	Select * from @tblPickedLots Where intLotId=0

	Delete From @tblPickedLots Where intLotId=0

	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(distinct sr.dblQty) from tblICLot l join tblICStockReservation sr on l.intLotId=sr.intLotId 
	Join @tblPickedLots tpl on l.intLotId=tpl.intLotId Where ISNULL(sr.ysnPosted,0)=0
	Group by sr.intLotId

	Insert Into @tblChildLot(intLotId,dblQuantity)
	Select l.intLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) AS dblAvailableQty 
	from tblICLot l 
	Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
	Left Join @tblReservedQty rq on l.intLotId=rq.intLotId

	Select DISTINCT tpl.intWorkOrderInputLotId,tpl.intLotId,CASE When ri.intConsumptionMethodId=1 Then tpl.strLotNumber Else '' End AS strLotNumber,
	tpl.strItemNo,tpl.strDescription,tpl.dblQuantity,tpl.intItemUOMId,tpl.strUOM,tpl.dblIssuedQuantity,
	tpl.intItemIssuedUOMId,tpl.strIssuedUOM,tpl.intItemId,tpl.intRecipeItemId,tpl.dblUnitCost,tpl.dblDensity,tpl.dblRequiredQtyPerSheet,tpl.dblWeightPerUnit,tpl.dblRiskScore,
	tpl.intStorageLocationId,
	CASE When ri.intConsumptionMethodId=1 Then tpl.strStorageLocationName Else '' End AS strStorageLocationName,tpl.strLocationName,tpl.intLocationId,tpl.strSubLocationName,tpl.intSubLocationId,
	CASE When ri.intConsumptionMethodId=1 Then tpl.strLotAlias Else '' End AS strLotAlias,tpl.ysnParentLot,tpl.strRowState,
	CASE When ri.intConsumptionMethodId=1 Then cl.dblQuantity 
	Else 
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
				Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
				WHERE L.intItemId = tpl.intItemId
				AND L.intLocationId = @intLocationId
				AND L.intLotStatusId = 1 
				AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
				AND L.dblWeight >= .01
				AND L.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging
				AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=tpl.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0
					AND intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging	
	)
	End AS dblAvailableQty,
	CASE When ri.intConsumptionMethodId=1 Then  ISNULL(rq.dblReservedQty,0) 
	Else
	(Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=tpl.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0
					AND intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging	
	)
	End AS dblReservedQty,
	CASE When ri.intConsumptionMethodId=1 Then  (cl.dblQuantity / tpl.dblWeightPerUnit) 
	Else
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
				Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
				WHERE L.intItemId = tpl.intItemId
				AND L.intLocationId = @intLocationId
				AND L.intLotStatusId = 1 
				AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
				AND L.dblWeight >= .01
				AND L.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging
				AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=tpl.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0
					AND intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					) --Exclude Kit Staging,Blend Staging	
	)
	End AS dblAvailableUnit,
	um.strUnitMeasure AS strAvailableUnitUOM,
	tpl.dblIssuedQuantity AS dblPickQuantity,tpl.intItemIssuedUOMId AS intPickUOMId,tpl.strIssuedUOM AS strPickUOM,
	l.intParentLotId,CASE When ri.intConsumptionMethodId=1 Then pl.strParentLotNumber Else '' End AS strParentLotNumber
	From @tblPickedLots tpl Join @tblChildLot cl on tpl.intLotId=cl.intLotId 
	Join tblICLot l on tpl.intLotId=l.intLotId
	Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
	Left Join @tblReservedQty rq on tpl.intLotId = rq.intLotId
	Left Join @tblInputItem ri on tpl.intItemId=ri.intItemId
	UNION 
	Select rpl.*,0.0 AS dblAvailableQty,0.0 AS dblReservedQty,0.0 AS dblAvailableUnit,'' AS strAvailableUnitUOM, 
	0.0 AS dblPickQuantity,0 AS intPickUOMId,'' AS strPickUOM,0 AS intParentLotId,'' AS strParentLotNumber
	From @tblRemainingPickedLots rpl
	UNION --Non Lot Tracked Items
	Select pl.*,
	dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pl.intItemUOMId,sd.dblAvailableQty) AS dblAvailableQty,
	dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pl.intItemUOMId,sd.dblReservedQty) AS dblReservedQty,
	dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pl.intItemUOMId,sd.dblAvailableQty) AS dblAvailableUnit,pl.strUOM AS strAvailableUnitUOM, 
	pl.dblQuantity AS dblPickQuantity,pl.intItemUOMId AS intPickUOMId,pl.strUOM AS strPickUOM,0 AS intParentLotId,'' AS strParentLotNumber
	From @tblPickedLots pl Join vyuMFGetItemStockDetail sd on pl.intWorkOrderInputLotId=sd.intItemStockUOMId
	Where pl.intLotId=-1
	ORDER BY tpl.strItemNo,tpl.intStorageLocationId

	return
End

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
	Select sr.intLotId,sum(sr.dblQty) from @tblChildLot cl join tblICStockReservation sr on cl.intLotId=sr.intLotId Where ISNULL(sr.ysnPosted,0)=0
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