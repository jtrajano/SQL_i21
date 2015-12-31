CREATE PROCEDURE [dbo].[uspMFGetPickListDetails]
	@intPickListId int
AS

Declare @intKitStatusId int
Declare @intRecipeId int
Declare @intBlendItemId int
Declare @intLocationId int
Declare @dblQtyToProduce numeric(18,6)
Declare @intBlendRequirementId int
Declare @strXml nvarchar(max)
Declare @strWorkOrderIds nvarchar(max)
Declare @intKitStagingLocationId int
Declare @intManufacturingProcessId int
Declare @intMinItemCount int,
		@intRecipeItemId int,
		@intRawItemId int,
		@dblRequiredQty numeric(18,6),
		@intConsumptionMethodId int,
		@intConsumptionStoragelocationId int

Select @intManufacturingProcessId=intManufacturingProcessId
From tblMFWorkOrder Where intPickListId=@intPickListId

Select @intKitStatusId=intKitStatusId,@intLocationId=intLocationId from tblMFPickList Where intPickListId=@intPickListId
Select TOP 1 @intBlendItemId=intItemId,@intBlendRequirementId=intBlendRequirementId,@strWorkOrderIds=convert(varchar,intWorkOrderId) 
From tblMFWorkOrder Where intPickListId=@intPickListId

Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Kit Staging Location'

Declare @tblReservedQty table
(
	intLotId int,
	dblReservedQty numeric(18,6)
)

DECLARE @tblInputItem TABLE (
	intItemId INT
	,dblRequiredQty NUMERIC(18, 6)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
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
	strDescription nvarchar(50) COLLATE Latin1_General_CI_AS,
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblAvailableQty numeric(18,6),
	dblReservedQty numeric(18,6),
	dblPickQuantity numeric(18,6),
	intPickUOMId int,
	strPickUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intStageLotId int,
	dblAvailableUnit numeric(18,6),
	strAvailableUnitUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblWeightPerUnit numeric(18,6),
	strStatus nvarchar(50) COLLATE Latin1_General_CI_AS
)

Declare @tblRemainingPickedItems AS table
( 
	intRowNo int IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(18,6),
	intConsumptionMethodId int
)

Declare @tblChildLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(18,6),
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
	strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(18,6),
	dblDensity numeric(18,6),
	dblRequiredQtyPerSheet numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	dblRiskScore numeric(18,6),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intLocationId int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
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
	strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(18,6),
	dblDensity numeric(18,6),
	dblRequiredQtyPerSheet numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	dblRiskScore numeric(18,6),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intLocationId int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
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
	strDescription nvarchar(200) COLLATE Latin1_General_CI_AS,
	dblQuantity numeric(18,6),
	intItemUOMId int,
	strUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblIssuedQuantity numeric(18,6),
	intItemIssuedUOMId int,
	strIssuedUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intItemId int,
	intRecipeItemId int,
	dblUnitCost numeric(18,6),
	dblDensity numeric(18,6),
	dblRequiredQtyPerSheet numeric(18,6),
	dblWeightPerUnit numeric(18,6),
	dblRiskScore numeric(18,6),
	intStorageLocationId int,
	strStorageLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	intLocationId int,
	strSubLocationName nvarchar(50) COLLATE Latin1_General_CI_AS,
	strLotAlias nvarchar(50) COLLATE Latin1_General_CI_AS,
	ysnParentLot bit,
	strRowState nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblAvailableQty numeric(18,6),
	dblReservedQty numeric(18,6),
	dblAvailableUnit numeric(18,6),
	strAvailableUnitUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	dblPickQuantity numeric(18,6),
	intPickUOMId int,
	strPickUOM nvarchar(50) COLLATE Latin1_General_CI_AS,
	intParentLotId int,
	strParentLotNumber nvarchar(50) COLLATE Latin1_General_CI_AS
)

	SELECT @intRecipeId = intRecipeId
	FROM tblMFRecipe
	WHERE intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1

		INSERT INTO @tblInputItem (
		intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,intConsumptionMethodId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
	
	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,0
	FROM tblMFRecipeSubstituteItem rs
	JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1

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
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
	
	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,0
	FROM tblMFRecipeSubstituteItem rs
	JOIN tblMFRecipe r ON r.intRecipeId = rs.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
End
End

If @intKitStatusId = 7
Begin
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(distinct sr.dblQty) 
	from tblMFPickListDetail pld join tblICStockReservation sr on pld.intLotId=sr.intLotId 
	Where pld.intPickListId=@intPickListId
	Group by sr.intLotId

	Insert Into @tblPickList
	Select pld.intPickListDetailId,pld.intPickListId,pld.intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
	l.intItemId,i.strItemNo,i.strDescription,pld.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
	ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0) AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
	pld.intStageLotId,(ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0))/ (Case When ISNULL(l.dblWeightPerQty,0)=0 Then 1 Else l.dblWeightPerQty End) AS dblAvailableUnit,
	um1.strUnitMeasure AS strAvailableUnitUOM,l.dblWeightPerQty AS dblWeightPerUnit,Case When l.intStorageLocationId=@intKitStagingLocationId Then 'Staged' Else 'Picking' End AS strStatus
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId 
	Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join @tblReservedQty rq on pld.intLotId=rq.intLotId
	Where pld.intPickListId=@intPickListId

	Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId)
	Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId 
	From @tblInputItem ti Left Join 
	(Select intItemId,SUM(dblQuantity) AS dblQuantity From @tblPickList Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
	WHERE (ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) > 0

	--intSalesOrderLineItemId = 0 implies WOs are created from Blend Managemnet Screen And Lots are already attached, keep only bulk items
	If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
		Delete From @tblRemainingPickedItems Where intConsumptionMethodId not in (2,3)

	--Find the Remaining Lots
	If (Select COUNT(1) From @tblRemainingPickedItems) > 0
	Begin
		Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

		Set @strXml = '<root>'
		While(@intMinItemCount is not null)
		Begin
			Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity
			From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

			Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
			From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
			Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1

			Set @strXml = @strXml + '<item>'
			Set @strXml = @strXml + '<intRecipeId>' + CONVERT(varchar,@intRecipeId) + '</intRecipeId>'
			Set @strXml = @strXml + '<intRecipeItemId>' + CONVERT(varchar,@intRecipeItemId) + '</intRecipeItemId>'
			Set @strXml = @strXml + '<intItemId>' + CONVERT(varchar,@intRawItemId) + '</intItemId>'
			Set @strXml = @strXml + '<dblRequiredQty>' + CONVERT(varchar,@dblRequiredQty) + '</dblRequiredQty>'
			Set @strXml = @strXml + '<ysnIsSubstitute>' + CONVERT(varchar,0) + '</ysnIsSubstitute>'
			Set @strXml = @strXml + '<ysnMinorIngredient>' + CONVERT(varchar,0) + '</ysnMinorIngredient>'
			Set @strXml = @strXml + '<intConsumptionMethodId>' + CONVERT(varchar,@intConsumptionMethodId) + '</intConsumptionMethodId>'
			Set @strXml = @strXml + '<intConsumptionStoragelocationId>' + CONVERT(varchar,ISNULL(@intConsumptionStoragelocationId,0)) + '</intConsumptionStoragelocationId>'
			Set @strXml = @strXml + '</item>'

			Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems Where intRowNo > @intMinItemCount
		End
		Set @strXml = @strXml + '</root>'

		Insert Into @tblPickedLots
		Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXml

		--Remaining Lots to Pick
		Insert Into @tblRemainingPickedLots
		Select * from @tblPickedLots Where intLotId=0

		Delete From @tblPickedLots Where intLotId=0

		Delete From @tblReservedQty

		Insert @tblReservedQty(intLotId,dblReservedQty)
		Select sr.intLotId,sum(sr.dblQty) from tblICLot l join tblICStockReservation sr on l.intLotId=sr.intLotId 
		Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
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

	Select * From @tblPickList ORDER BY strItemNo,strLotNumber DESC

End

If @intKitStatusId=12
Begin
	Insert @tblReservedQty(intLotId,dblReservedQty)
	Select sr.intLotId,sum(distinct sr.dblQty) 
	from tblMFPickListDetail pld join tblICStockReservation sr on pld.intStageLotId=sr.intLotId 
	Where pld.intPickListId=@intPickListId
	Group by sr.intLotId

	--Bulk Items
	Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId)
	Select ti.intItemId,ti.dblRequiredQty AS dblRemainingQuantity,ti.intConsumptionMethodId 
	From @tblInputItem ti 
	WHERE ti.intConsumptionMethodId in (2,3)

	--Find the Remaining Lots
	If (Select COUNT(1) From @tblRemainingPickedItems) > 0
	Begin
		Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

		Set @strXml = '<root>'
		While(@intMinItemCount is not null)
		Begin
			Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity
			From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

			Select @intRecipeItemId=ri.intRecipeItemId,@intConsumptionMethodId=ri.intConsumptionMethodId,@intConsumptionStoragelocationId=ri.intStorageLocationId 
			From tblMFRecipe r Join tblMFRecipeItem ri on r.intRecipeId=ri.intRecipeId 
			Where r.intRecipeId=@intRecipeId And ri.intItemId=@intRawItemId And r.intLocationId=@intLocationId And r.ysnActive=1

			Set @strXml = @strXml + '<item>'
			Set @strXml = @strXml + '<intRecipeId>' + CONVERT(varchar,@intRecipeId) + '</intRecipeId>'
			Set @strXml = @strXml + '<intRecipeItemId>' + CONVERT(varchar,@intRecipeItemId) + '</intRecipeItemId>'
			Set @strXml = @strXml + '<intItemId>' + CONVERT(varchar,@intRawItemId) + '</intItemId>'
			Set @strXml = @strXml + '<dblRequiredQty>' + CONVERT(varchar,@dblRequiredQty) + '</dblRequiredQty>'
			Set @strXml = @strXml + '<ysnIsSubstitute>' + CONVERT(varchar,0) + '</ysnIsSubstitute>'
			Set @strXml = @strXml + '<ysnMinorIngredient>' + CONVERT(varchar,0) + '</ysnMinorIngredient>'
			Set @strXml = @strXml + '<intConsumptionMethodId>' + CONVERT(varchar,@intConsumptionMethodId) + '</intConsumptionMethodId>'
			Set @strXml = @strXml + '<intConsumptionStoragelocationId>' + CONVERT(varchar,ISNULL(@intConsumptionStoragelocationId,0)) + '</intConsumptionStoragelocationId>'
			Set @strXml = @strXml + '</item>'

			Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems Where intRowNo > @intMinItemCount
		End
		Set @strXml = @strXml + '</root>'

		Insert Into @tblPickedLots
		Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXml

		--Remaining Lots to Pick
		Insert Into @tblRemainingPickedLots
		Select * from @tblPickedLots Where intLotId=0

		Delete From @tblPickedLots Where intLotId=0

		Delete From @tblReservedQty

		Insert @tblReservedQty(intLotId,dblReservedQty)
		Select sr.intLotId,sum(sr.dblQty) from tblICLot l join tblICStockReservation sr on l.intLotId=sr.intLotId 
		Join @tblPickedLots tpl on l.intLotId=tpl.intLotId
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

	Insert Into @tblPickList
	Select pld.intPickListDetailId,pld.intPickListId,pld.intStageLotId AS intLotId,l.strLotNumber,l.strLotAlias,l.intParentLotId,pl.strParentLotNumber,
	l.intItemId,i.strItemNo,i.strDescription,pld.intStorageLocationId,sl.strName AS strStorageLocationName,
	pld.dblQuantity,pld.intItemUOMId,um.strUnitMeasure AS strUOM,pld.dblIssuedQuantity,pld.intItemIssuedUOMId,um1.strUnitMeasure AS strIssuedUOM, 
	((ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) + pld.dblQuantity) AS dblAvailableQty,ISNULL(rq.dblReservedQty,0) AS dblReservedQty,
	pld.dblPickQuantity,pld.intPickUOMId,um1.strUnitMeasure AS strPickUOM,
	pld.intStageLotId,((ISNULL(l.dblWeight,0) - ISNULL(rq.dblReservedQty,0)) + pld.dblQuantity)/ (Case When ISNULL(l.dblWeightPerQty,0)=0 Then 1 Else l.dblWeightPerQty End) AS dblAvailableUnit,
	um1.strUnitMeasure AS strAvailableUnitUOM,l.dblWeightPerQty AS dblWeightPerUnit,Case When l.intStorageLocationId=@intKitStagingLocationId Then 'Staged' Else '' End AS strStatus
	From tblMFPickListDetail pld Join tblICLot l on pld.intStageLotId=l.intLotId 
	Left Join tblICParentLot pl on l.intParentLotId=pl.intParentLotId 
	Join tblICItem i on l.intItemId=i.intItemId
	Join tblICStorageLocation sl on l.intStorageLocationId=sl.intStorageLocationId
	Join tblICItemUOM iu on pld.intItemUOMId=iu.intItemUOMId
	Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId
	Join tblICItemUOM iu1 on l.intItemUOMId=iu1.intItemUOMId
	Join tblICUnitMeasure um1 on iu1.intUnitMeasureId=um1.intUnitMeasureId
	Left Join @tblReservedQty rq on pld.intStageLotId=rq.intLotId
	Where pld.intPickListId=@intPickListId

	If (Select COUNT(1) From @tblPickedLotsFinal) > 0
	Insert Into @tblPickList
	Select 0,0,tpl.intLotId,tpl.strLotNumber,tpl.strLotAlias,tpl.intParentLotId,tpl.strParentLotNumber,
	tpl.intItemId,tpl.strItemNo,tpl.strDescription,tpl.intStorageLocationId,tpl.strStorageLocationName,
	tpl.dblQuantity,tpl.intItemUOMId,tpl.strUOM,
	tpl.dblIssuedQuantity,tpl.intItemIssuedUOMId,tpl.strIssuedUOM,
	tpl.dblAvailableQty,tpl.dblReservedQty,tpl.dblPickQuantity,tpl.intPickUOMId,tpl.strPickUOM,
	tpl.intLotId,tpl.dblAvailableUnit,tpl.strAvailableUnitUOM,tpl.dblWeightPerUnit,'' AS strStatus
	from @tblPickedLotsFinal tpl

	Select * From @tblPickList ORDER BY strItemNo,strLotNumber DESC
End