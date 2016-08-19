CREATE PROCEDURE [dbo].[uspMFGetPickListDetails]
	@intPickListId int
AS

Declare @intKitStatusId int
Declare @intRecipeId int
Declare @intBlendItemId int
Declare @intLocationId int
Declare @dblQtyToProduce numeric(38,20)
Declare @intBlendRequirementId int
Declare @strXml nvarchar(max)
Declare @strWorkOrderIds nvarchar(max)
Declare @intKitStagingLocationId int
Declare @strKitStagingLocationName nvarchar(50)
DECLARE @intBlendStagingLocationId INT
Declare @intManufacturingProcessId int
Declare @intWorkOrderId int
DECLARE @intInventoryTransactionType AS INT=34
Declare @intMinItemCount int,
		@intRecipeItemId int,
		@intRawItemId int,
		@dblRequiredQty numeric(38,20),
		@intConsumptionMethodId int,
		@intConsumptionStoragelocationId int,
		@ysnIsSubstitute bit,
		@intParentItemId int,
		@intMinRemainingItem int

Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId,@intWorkOrderId=intWorkOrderId
From tblMFWorkOrder Where intPickListId=@intPickListId

Select @intKitStatusId=intKitStatusId,@intLocationId=intLocationId from tblMFPickList Where intPickListId=@intPickListId
Select TOP 1 @intBlendItemId=intItemId,@intBlendRequirementId=intBlendRequirementId,@strWorkOrderIds=convert(varchar,intWorkOrderId) 
From tblMFWorkOrder Where intPickListId=@intPickListId

Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Kit Staging Location'

Select @strKitStagingLocationName=strName From tblICStorageLocation Where intStorageLocationId=@intKitStagingLocationId

Select @intBlendStagingLocationId=ISNULL(intBlendProductionStagingUnitId,0) From tblSMCompanyLocation Where intCompanyLocationId=@intLocationId

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(38,20)
)

DECLARE @tblInputItem TABLE (
	intRowNo INT IDENTITY,
	intItemId INT
	,dblRequiredQty NUMERIC(38,20)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intParentItemId INT
	)

DECLARE @tblPickList TABLE (
	intPickListDetailId int,
	intPickListId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
	intParentLotId int,
	strParentLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(250) COLLATE Latin1_General_CI_AS,
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(38,20),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblAvailableQty numeric(38,20),
	dblReservedQty numeric(38,20),
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	strPickUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intStageLotId int,
	dblAvailableUnit numeric(38,20),
	strAvailableUnitUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblWeightPerUnit numeric(38,20),
	strStatus nvarchar(50) COLLATE Latin1_General_CI_AS
)

Declare @tblRemainingPickedItems AS table
( 
	intRowNo int IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(38,20),
	intConsumptionMethodId int,
	ysnIsSubstitute bit,
	intParentItemId int
)

Declare @tblChildLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblWeightPerUnit numeric(38,20)
)

--to hold not available and less qty lots
Declare @tblRemainingPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(250) COLLATE Latin1_General_CI_AS,
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

--Temp Table to hold picked Lots when ysnBlendSheetRequired setting is false, 
--Picked the Lots based on FIFO using Recipe
Declare @tblPickedLots AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(250) COLLATE Latin1_General_CI_AS,
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

Declare @tblPickedLotsFinal AS table
( 
	intWorkOrderInputLotId int,
	intLotId int,
	strLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS,
	strItemNo nvarchar(50) COLLATE Latin1_General_CI_AS,
	strDescription nvarchar(250) COLLATE Latin1_General_CI_AS,
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
	strRowState nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblAvailableQty numeric(38,20),
	dblReservedQty numeric(38,20),
	dblAvailableUnit numeric(38,20),
	strAvailableUnitUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	strPickUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intParentLotId int,
	strParentLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS
)

	SELECT @intRecipeId = intRecipeId
	FROM tblMFWorkOrderRecipe
	WHERE intWorkOrderId = @intWorkOrderId
		AND intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1

		INSERT INTO @tblInputItem (
		intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,intConsumptionMethodId
		,intParentItemId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,0
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId AND ri.intConsumptionMethodId IN (1,2,3)
	
	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,ri.intConsumptionMethodId
		,ri.intItemId
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId AND ri.intWorkOrderId=r.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId

--WO created from Blend Management Screen if Lots are there input lot table when kitting enabled
If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
Begin
If Exists(Select 1 From @tblInputItem Where intConsumptionMethodId in (2,3)) --Bulk Item
Begin
	--Delete and recalculate using dblPlannedQuantity
	Delete From @tblInputItem

	Select @dblQtyToProduce=SUM(dblPlannedQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId

		INSERT INTO @tblInputItem (
		intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,intConsumptionMethodId
		,intParentItemId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,0
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1  AND ri.intConsumptionMethodId IN (1,2,3)
	
	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,ri.intConsumptionMethodId
		,rs.intItemId
	FROM tblMFRecipeSubstituteItem rs 
	JOIN tblMFRecipeItem ri on rs.intItemId=ri.intItemId
	JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
End
End

If @intKitStatusId = 7
Begin
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(distinct sr.dblQty) 
	from tblMFPickListDetail pld join tblICStockReservation sr on pld.intStageLotId=sr.intLotId 
	Where pld.intPickListId=@intPickListId AND ISNULL(sr.ysnPosted,0)=0
	Group by sr.intLotId

	Insert Into @tblPickList
	Select pld.intPickListDetailId,pld.intPickListId,pld.intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
	l.intItemId,i.strItemNo,i.strDescription,sl.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
	ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0) AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
	pld.intStageLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0))/ (Case When ISNULL(l.dblWeightPerQty,0)=0 Then 1 Else l.dblWeightPerQty End) AS dblAvailableUnit,
	um2.strUnitMeasure AS strAvailableUnitUOM,l.dblWeightPerQty AS dblWeightPerUnit,Case When l.intStorageLocationId=@intKitStagingLocationId Then 'Staged' Else 'Picking' End AS strStatus
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId 
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on pld.intItemIssuedUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Join tblICItemUOM iu2 on l.intItemUOMId=iu2.intItemUOMId
	Join tblICUnitMeasure um2 on iu2.intUnitMeasureId=um2.intUnitMeasureId
	Left Join @tblReservedQty rq on pld.intLotId=rq.intLotId
	Where pld.intPickListId=@intPickListId
	UNION --Bulk Items from Reservation table
	Select 0 AS intPickListDetailId,@intPickListId AS intPickListId,
	(Select TOP 1 intLotId From tblICLot Where intItemId=ti.intItemId AND intLocationId=@intLocationId) AS intLotId,
	'' AS strLotNumber,'' AS strLotAlias,0 intParentLotId,'' AS strParentLotNumber,
	i.intItemId,i.strItemNo,i.strDescription,0 AS intStorageLocationId,'' strName,
	sr.dblQty,sr.intItemUOMId AS intWeightUOMId,um.strUnitMeasure,sr.dblQty,sr.intItemUOMId AS intWeightUOMId,um.strUnitMeasure,
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
			Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = ti.intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1 
			AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
			AND L.dblWeight >= .01
			AND L.intStorageLocationId NOT IN (
				@intKitStagingLocationId
				,@intBlendStagingLocationId
				) --Exclude Kit Staging,Blend Staging
			AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblAvailableQty,
	(Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblReservedQty,
	sr.dblQty,sr.intItemUOMId AS intWeightUOMId,um.strUnitMeasure,
	(Select TOP 1 intLotId From tblICLot Where intItemId=ti.intItemId) AS intLotId,
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
			Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = ti.intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1 
			AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
			AND L.dblWeight >= .01
			AND L.intStorageLocationId NOT IN (
				@intKitStagingLocationId
				,@intBlendStagingLocationId
				) --Exclude Kit Staging,Blend Staging
			AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblAvailableUnit,
	um.strUnitMeasure,1 dblWeightPerQty,'Picking'
	From @tblInputItem ti Join tblICStockReservation sr on ti.intItemId=sr.intItemId
	Join tblICItem i on sr.intItemId=i.intItemId
	Join tblICItemUOM iu on sr.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where ti.intConsumptionMethodId in (2,3) AND sr.intTransactionId=@intPickListId AND sr.intInventoryTransactionType=@intInventoryTransactionType 
	AND ISNULL(sr.ysnPosted,0)=0 AND i.strLotTracking <> 'No'

	Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId,ysnIsSubstitute,intParentItemId)
	Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.ysnIsSubstitute,ti.intParentItemId 
	From @tblInputItem ti Left Join 
	(Select intItemId,SUM(dblQuantity) AS dblQuantity From @tblPickList Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
	WHERE (ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) > 0

	--intSalesOrderLineItemId = 0 implies WOs are created from Blend Managemnet Screen And Lots are already attached, keep only bulk items
	If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
		Delete From @tblRemainingPickedItems Where intConsumptionMethodId not in (2,3)

	--Remove main item if substitute is selected
	Select @intMinRemainingItem=Min(intRowNo) From @tblInputItem Where ysnIsSubstitute=1
	Declare @intRemainingSubItemId int
	Declare @intRemainingParentItemId int
	While(@intMinRemainingItem is not null)
	Begin
		Select @intRemainingSubItemId=intItemId,@intRemainingParentItemId=intParentItemId From @tblInputItem Where intRowNo=@intMinRemainingItem
		
		If Exists (Select 1 From @tblPickList Where intItemId=@intRemainingSubItemId)
			Delete From @tblRemainingPickedItems Where intItemId=@intRemainingParentItemId

		Select @intMinRemainingItem=Min(intRowNo) From @tblInputItem Where intRowNo>@intMinRemainingItem And ysnIsSubstitute=1
	End

	--Remove sub item if main is selected
	Delete a From @tblRemainingPickedItems a join @tblPickList b on a.intParentItemId=b.intItemId Where a.ysnIsSubstitute=1

	--Remove Non Lot Tracked Items
	Delete ti From @tblRemainingPickedItems ti Join tblICItem i on ti.intItemId=i.intItemId Where i.strLotTracking = 'No'

	--Find the Remaining Lots
	If (Select COUNT(1) From @tblRemainingPickedItems) > 0
	Begin
		Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

		Set @strXml = '<root>'
		While(@intMinItemCount is not null)
		Begin
			Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity,@ysnIsSubstitute=ysnIsSubstitute,@intParentItemId=ISNULL(intParentItemId,0)
			From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

			--WO created from Blend Management Screen if Lots are there input lot table when kitting enabled
			If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
				Begin
				If @ysnIsSubstitute=0
					Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
					From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
					Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1

				If @ysnIsSubstitute=1
					Select @intRecipeItemId=rs.intRecipeSubstituteItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
					From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
					Join tblMFRecipeSubstituteItem rs on ri.intItemId=rs.intItemId
					Where r.intRecipeId=@intRecipeId And rs.intSubstituteItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1
				End
			Else
				Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
				From tblMFWorkOrderRecipe r Join tblMFWorkOrderRecipeItem ri on r.intWorkOrderId=ri.intWorkOrderId 
				Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1 AND r.intWorkOrderId=@intWorkOrderId

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
		Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXml,1

		--Remaining Lots to Pick
		Insert Into @tblRemainingPickedLots
		Select * from @tblPickedLots Where intLotId=0

		Delete From @tblPickedLots Where intLotId=0

		Delete From @tblReservedQty

		Insert @tblReservedQty(intLotId,dblReservedQty)
		Select sr.intLotId,sum(sr.dblQty) from tblICLot l join tblICStockReservation sr on l.intLotId=sr.intLotId 
		Join @tblPickedLots tpl on l.intLotId=tpl.intLotId Where ISNULL(sr.ysnPosted,0)=0
		Group by sr.intLotId

		Insert Into @tblChildLot(intLotId,dblQuantity)
		Select l.intLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) AS dblAvailableQty 
		from tblICLot l 
		Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
		Left Join @tblReservedQty rq on l.intLotId=rq.intLotId

		Insert Into @tblPickedLotsFinal
		Select DISTINCT tpl.*,cl.dblQuantity AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,(cl.dblQuantity / tpl.dblWeightPerUnit) AS dblAvailableUnit,um.strUnitMeasure AS strAvailableUnitUOM,
		tpl.dblIssuedQuantity AS dblPickQuantity,tpl.intItemIssuedUOMId AS intPickUOMId,tpl.strIssuedUOM AS strPickUOM,
		l.intParentLotId,pl.strParentLotNumber
		From @tblPickedLots tpl Join @tblChildLot cl on tpl.intLotId=cl.intLotId 
		Join tblICLot l on tpl.intLotId=l.intLotId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Left Join @tblReservedQty rq on tpl.intLotId = rq.intLotId
		UNION 
		Select rpl.*,0.0 AS dblAvailableQty,0.0 AS dblReservedQty,0.0 AS dblAvailableUnit,'' AS strAvailableUnitUOM, 
		0.0 AS dblPickQuantity,0 AS intPickUOMId,'' AS strPickUOM,0 AS intParentLotId,'' AS strParentLotNumber
		From @tblRemainingPickedLots rpl
		ORDER BY tpl.strItemNo,tpl.strStorageLocationName

	End

	If (Select COUNT(1) From @tblPickedLotsFinal) > 0
	Insert Into @tblPickList
	Select 0,0,tpl.intLotId,tpl.strLotNumber,tpl.strLotAlias,tpl.intParentLotId,tpl.strParentLotNumber,
	tpl.intItemId,tpl.strItemNo,tpl.strDescription,tpl.intStorageLocationId,tpl.strStorageLocationName,
	tpl.dblQuantity,tpl.intItemUOMId,tpl.strUOM,
	tpl.dblIssuedQuantity,tpl.intItemIssuedUOMId,tpl.strIssuedUOM,
	tpl.dblAvailableQty,tpl.dblReservedQty,tpl.dblPickQuantity,tpl.intPickUOMId,tpl.strPickUOM,
	tpl.intLotId,tpl.dblAvailableUnit,tpl.strAvailableUnitUOM,tpl.dblWeightPerUnit,'' AS strStatus
	from @tblPickedLotsFinal tpl Join @tblInputItem ti on tpl.intItemId=ti.intItemId 
	Where ti.intConsumptionMethodId=1
	UNION --Bulk Items
	Select 0,0,tpl.intLotId,'' AS strLotNumber,'' AS strLotAlias,tpl.intParentLotId,'' AS strParentLotNumber,
	tpl.intItemId,tpl.strItemNo,tpl.strDescription,tpl.intStorageLocationId,'' AS strStorageLocationName,
	tpl.dblQuantity,tpl.intItemUOMId,tpl.strUOM,
	tpl.dblIssuedQuantity,tpl.intItemIssuedUOMId,tpl.strIssuedUOM,
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
			Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = ti.intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1 
			AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
			AND L.dblWeight >= .01
			AND L.intStorageLocationId NOT IN (
				@intKitStagingLocationId
				,@intBlendStagingLocationId
				) --Exclude Kit Staging,Blend Staging
			AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblAvailableQty,
	(Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblReservedQty,
	tpl.dblPickQuantity,tpl.intPickUOMId,tpl.strPickUOM,tpl.intLotId,
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
			Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = ti.intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1 
			AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
			AND L.dblWeight >= .01
			AND L.intStorageLocationId NOT IN (
				@intKitStagingLocationId
				,@intBlendStagingLocationId
				) --Exclude Kit Staging,Blend Staging
			AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblAvailableUnit,
	tpl.strAvailableUnitUOM,1 AS dblWeightPerUnit,'' AS strStatus
	from @tblPickedLotsFinal tpl Join @tblInputItem ti on tpl.intItemId=ti.intItemId 
	Where ti.intConsumptionMethodId IN (2,3)

	Select a.*,b.intConsumptionMethodId From @tblPickList a Left Join @tblInputItem b on a.intItemId=b.intItemId 
	UNION --Non Lot Tracked Items
	Select pld.intPickListDetailId,pld.intPickListId,-1,'','',0,'',pld.intItemId,i.strItemNo,i.strDescription,pld.intStorageLocationId,sl.strName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure,pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure,
	(Select TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pld.intItemUOMId,sd.dblAvailableQty) 
	From vyuMFGetItemStockDetail sd Where ISNULL(sd.ysnStockUnit,0)=1 AND sd.intLocationId=@intLocationId AND 
	ISNULL(sd.intSubLocationId,0)=ISNULL(pld.intSubLocationId,0) AND ISNULL(sd.intStorageLocationId,0)=ISNULL(pld.intStorageLocationId,0) 
	AND sd.intItemId=pld.intItemId) AS dblAvailableQty,
	(Select TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pld.intItemUOMId,sd.dblReservedQty) 
	From vyuMFGetItemStockDetail sd Where ISNULL(sd.ysnStockUnit,0)=1 AND sd.intLocationId=@intLocationId AND 
	ISNULL(sd.intSubLocationId,0)=ISNULL(pld.intSubLocationId,0) AND ISNULL(sd.intStorageLocationId,0)=ISNULL(pld.intStorageLocationId,0) 
	AND sd.intItemId=pld.intItemId) AS dblReservedQty,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure,
	-1,
	(Select TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pld.intItemUOMId,sd.dblAvailableQty) 
	From vyuMFGetItemStockDetail sd Where ISNULL(sd.ysnStockUnit,0)=1 AND sd.intLocationId=@intLocationId AND 
	ISNULL(sd.intSubLocationId,0)=ISNULL(pld.intSubLocationId,0) AND ISNULL(sd.intStorageLocationId,0)=ISNULL(pld.intStorageLocationId,0) 
	AND sd.intItemId=pld.intItemId) As dblAvailableUnit,
	um.strUnitMeasure,1,'Picking',
	ti.intConsumptionMethodId
	From tblMFPickListDetail pld 
	Join tblICItem i on pld.intItemId=i.intItemId
	Left Join tblICStorageLocation sl on pld.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join @tblInputItem ti on pld.intItemId=ti.intItemId
	Where pld.intPickListId=@intPickListId AND ISNULL(pld.intLotId,0)=0
	ORDER BY a.strItemNo,a.strLotNumber DESC
End

If @intKitStatusId=12
Begin
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(distinct sr.dblQty) 
	from tblMFPickListDetail pld join tblICStockReservation sr on pld.intStageLotId=sr.intLotId 
	Where pld.intPickListId=@intPickListId AND ISNULL(sr.ysnPosted,0)=0
	Group by sr.intLotId

	--Bulk Items
	Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId,ysnIsSubstitute,intParentItemId)
	Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.ysnIsSubstitute,intParentItemId 
	From @tblInputItem ti Left Join 
	(Select intItemId,SUM(dblQty) AS dblQuantity 
	From tblICStockReservation Where intTransactionId=@intPickListId AND intInventoryTransactionType=@intInventoryTransactionType AND ISNULL(ysnPosted,0)=0 Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
	WHERE (ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) > 0 AND ti.intConsumptionMethodId in (2,3)

	--Remove Non Lot Tracked Items
	Delete ti From @tblRemainingPickedItems ti Join tblICItem i on ti.intItemId=i.intItemId Where i.strLotTracking = 'No'

	--Find the Remaining Lots
	If (Select COUNT(1) From @tblRemainingPickedItems) > 0
	Begin
		Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

		Set @strXml = '<root>'
		While(@intMinItemCount is not null)
		Begin
			Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity,@ysnIsSubstitute=ysnIsSubstitute,@intParentItemId=intParentItemId
			From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

			--WO created from Blend Management Screen if Lots are there input lot table when kitting enabled
			If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
			Begin
				if @ysnIsSubstitute=0
					Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
					From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
					Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1

				If @ysnIsSubstitute=1
					Select @intRecipeItemId=rs.intRecipeSubstituteItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
					From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
					Join tblMFRecipeSubstituteItem rs on ri.intItemId=rs.intItemId
					Where r.intRecipeId=@intRecipeId And rs.intSubstituteItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1
			End
			Else
				Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
				From tblMFWorkOrderRecipe r Join tblMFWorkOrderRecipeItem ri on r.intWorkOrderId=ri.intWorkOrderId 
				Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1 AND r.intWorkOrderId=@intWorkOrderId

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
		Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXml,1

		--Remaining Lots to Pick
		Insert Into @tblRemainingPickedLots
		Select * from @tblPickedLots Where intLotId=0

		Delete From @tblPickedLots Where intLotId=0

		Delete From @tblReservedQty

		Insert @tblReservedQty(intLotId,dblReservedQty)
		Select sr.intLotId,sum(sr.dblQty) from tblICLot l join tblICStockReservation sr on l.intLotId=sr.intLotId 
		Join @tblPickedLots tpl on l.intLotId=tpl.intLotId AND ISNULL(sr.ysnPosted,0)=0
		Group by sr.intLotId

		Insert Into @tblChildLot(intLotId,dblQuantity)
		Select l.intLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) AS dblAvailableQty 
		from tblICLot l 
		Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
		Left Join @tblReservedQty rq on l.intLotId=rq.intLotId

		Insert Into @tblPickedLotsFinal
		Select DISTINCT tpl.*,cl.dblQuantity AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,(cl.dblQuantity / tpl.dblWeightPerUnit) AS dblAvailableUnit,um.strUnitMeasure AS strAvailableUnitUOM,
		tpl.dblIssuedQuantity AS dblPickQuantity,tpl.intItemIssuedUOMId AS intPickUOMId,tpl.strIssuedUOM AS strPickUOM,
		l.intParentLotId,pl.strParentLotNumber
		From @tblPickedLots tpl Join @tblChildLot cl on tpl.intLotId=cl.intLotId 
		Join tblICLot l on tpl.intLotId=l.intLotId
		Join tblICItemUOM iu on l.intItemUOMId=iu.intItemUOMId
		Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
		Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId
		Left Join @tblReservedQty rq on tpl.intLotId = rq.intLotId
		UNION 
		Select rpl.*,0.0 AS dblAvailableQty,0.0 AS dblReservedQty,0.0 AS dblAvailableUnit,'' AS strAvailableUnitUOM, 
		0.0 AS dblPickQuantity,0 AS intPickUOMId,'' AS strPickUOM,0 AS intParentLotId,'' AS strParentLotNumber
		From @tblRemainingPickedLots rpl
		ORDER BY tpl.strItemNo,tpl.strStorageLocationName
	End

	If (Select COUNT(1) From @tblPickedLotsFinal) > 0
	Insert Into @tblPickList
	Select 0,0,tpl.intLotId,tpl.strLotNumber,tpl.strLotAlias,tpl.intParentLotId,tpl.strParentLotNumber,
	tpl.intItemId,tpl.strItemNo,tpl.strDescription,tpl.intStorageLocationId,tpl.strStorageLocationName,
	tpl.dblQuantity,tpl.intItemUOMId,tpl.strUOM,
	tpl.dblIssuedQuantity,tpl.intItemIssuedUOMId,tpl.strIssuedUOM,
	tpl.dblAvailableQty,tpl.dblReservedQty,tpl.dblPickQuantity,tpl.intPickUOMId,tpl.strPickUOM,
	tpl.intLotId,tpl.dblAvailableUnit,tpl.strAvailableUnitUOM,tpl.dblWeightPerUnit,'' AS strStatus
	from @tblPickedLotsFinal tpl

	Insert Into @tblPickList
	Select pld.intPickListDetailId,pld.intPickListId,pld.intStageLotId AS intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
	l.intItemId,i.strItemNo,i.strDescription,l.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
	((ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) + pld.dblQuantity) AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
	pld.intStageLotId,((ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) + pld.dblQuantity)/ (Case When ISNULL(l.dblWeightPerQty,0)=0 Then 1 Else l.dblWeightPerQty End) AS dblAvailableUnit,
	um2.strUnitMeasure AS strAvailableUnitUOM,l.dblWeightPerQty AS dblWeightPerUnit,Case When l.intStorageLocationId=@intKitStagingLocationId Then 'Staged' Else '' End AS strStatus
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId 
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on pld.intItemIssuedUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Join tblICItemUOM iu2 on l.intItemUOMId=iu2.intItemUOMId
	Join tblICUnitMeasure um2 on iu2.intUnitMeasureId=um2.intUnitMeasureId
	Left Join @tblReservedQty rq on pld.intStageLotId=rq.intLotId
	Where pld.intPickListId=@intPickListId
	UNION --Bulk Items from Reservation table
	Select 0 AS intPickListDetailId,@intPickListId AS intPickListId,
	(Select TOP 1 intLotId From tblICLot Where intItemId=ti.intItemId) AS intLotId,
	'' AS strLotNumber,'' AS strLotAlias,0 intParentLotId,'' AS strParentLotNumber,
	i.intItemId,i.strItemNo,i.strDescription,0 AS intStorageLocationId,'' AS strName,
	sr.dblQty,sr.intItemUOMId AS intWeightUOMId,um.strUnitMeasure,sr.dblQty,sr.intItemUOMId AS intWeightUOMId,um.strUnitMeasure,
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
			Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = ti.intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1 
			AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
			AND L.dblWeight >= .01
			AND L.intStorageLocationId NOT IN (
				@intKitStagingLocationId
				,@intBlendStagingLocationId
				) --Exclude Kit Staging,Blend Staging
			AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblAvailableQty,
	(Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblReservedQty,
	sr.dblQty,sr.intItemUOMId AS intWeightUOMId,um.strUnitMeasure,
	(Select TOP 1 intLotId From tblICLot Where intItemId=ti.intItemId) AS intLotId,
	(Select ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot L 
			Join tblICStorageLocation SL ON L.intStorageLocationId=SL.intStorageLocationId
			WHERE L.intItemId = ti.intItemId
			AND L.intLocationId = @intLocationId
			AND L.intLotStatusId = 1 
			AND (L.dtmExpiryDate IS NULL OR L.dtmExpiryDate >= GETDATE())
			AND L.dblWeight >= .01
			AND L.intStorageLocationId NOT IN (
				@intKitStagingLocationId
				,@intBlendStagingLocationId
				) --Exclude Kit Staging,Blend Staging
			AND ISNULL(SL.ysnAllowConsume,0)=1)
	- (Select ISNULL(SUM(ISNULL(dblQty,0)),0) From tblICStockReservation Where intItemId=ti.intItemId AND intLocationId = @intLocationId AND ISNULL(ysnPosted,0)=0) AS dblAvailableUnit,
	um.strUnitMeasure,1 dblWeightPerQty,'Picking'
	From @tblInputItem ti Join tblICStockReservation sr on ti.intItemId=sr.intItemId
	Join tblICItem i on sr.intItemId=i.intItemId
	Join tblICItemUOM iu on sr.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Where ti.intConsumptionMethodId in (2,3) AND sr.intTransactionId=@intPickListId AND sr.intInventoryTransactionType=@intInventoryTransactionType 
	AND ISNULL(sr.ysnPosted,0)=0 AND i.strLotTracking <> 'No'

	Select a.*,b.intConsumptionMethodId From @tblPickList a Left Join @tblInputItem b on a.intItemId=b.intItemId 
	UNION --Non Lot Tracked Items
	Select pld.intPickListDetailId,pld.intPickListId,-1,'','',0,'',pld.intItemId,i.strItemNo,i.strDescription,@intKitStagingLocationId,@strKitStagingLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure,pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure,
	(Select TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pld.intItemUOMId,sd.dblAvailableQty) 
	From vyuMFGetItemStockDetail sd Where ISNULL(sd.ysnStockUnit,0)=1 AND sd.intLocationId=@intLocationId AND 
	ISNULL(sd.intStorageLocationId,0)=ISNULL(@intKitStagingLocationId,0) 
	AND sd.intItemId=pld.intItemId) AS dblAvailableQty,
	(Select TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pld.intItemUOMId,sd.dblReservedQty) 
	From vyuMFGetItemStockDetail sd Where ISNULL(sd.ysnStockUnit,0)=1 AND sd.intLocationId=@intLocationId AND 
	ISNULL(sd.intStorageLocationId,0)=ISNULL(@intKitStagingLocationId,0) 
	AND sd.intItemId=pld.intItemId) AS dblReservedQty,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure,
	-1,
	(Select TOP 1 dbo.fnMFConvertQuantityToTargetItemUOM(sd.intItemUOMId,pld.intItemUOMId,sd.dblAvailableQty) 
	From vyuMFGetItemStockDetail sd Where ISNULL(sd.ysnStockUnit,0)=1 AND sd.intLocationId=@intLocationId AND 
	ISNULL(sd.intStorageLocationId,0)=ISNULL(@intKitStagingLocationId,0) 
	AND sd.intItemId=pld.intItemId) As dblAvailableUnit,
	um.strUnitMeasure,1,'Staged',
	ti.intConsumptionMethodId
	From tblMFPickListDetail pld 
	Join tblICItem i on pld.intItemId=i.intItemId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Left Join @tblInputItem ti on pld.intItemId=ti.intItemId
	Where pld.intPickListId=@intPickListId AND ISNULL(pld.intLotId,0)=0
	ORDER BY a.strItemNo,a.strLotNumber DESC	
End