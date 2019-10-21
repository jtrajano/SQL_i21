CREATE PROCEDURE [dbo].[uspMFAddLotsToPickList]
	@strXml nvarchar(max)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrMsg nvarchar(max)
DECLARE @idoc int 
DECLARE @dblRequiredQty numeric(38,20)
DECLARE @intBlendItemId INT
DECLARE @intBlendRequirementId INT
DECLARE @strWorkOrderIds nvarchar(max)
DECLARE @strWorkOrderNos nvarchar(max)
DECLARE @id NVARCHAR(50)
DECLARE @index INT
DECLARE @intWorkOrderId INT
DECLARE @dblQtyToProduce numeric(38,20)
DECLARE @intRecipeId INT
DECLARE @intLocationId INT
DECLARE @intMinItemCount INT
DECLARE @intRawItemId INT
DECLARE @ysnIsSubstitute BIT
DECLARE @intParentItemId INT
DECLARE @intRecipeItemId INT
DECLARE @intPickListId INT
DECLARE @intConsumptionMethodId INT
DECLARE @intConsumptionStoragelocationId INT
DECLARE @strXmlItem nvarchar(max)
DECLARE @strXmlLot nvarchar(max)
DECLARE @strExcludedLots nvarchar(max)

EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml  

Declare @tblWorkOrder AS table
(
	intWorkOrderId int
)

Declare @tblPickList table
(
	intPickListId int,
	strPickListNo nvarchar(50),
	strWorkOrderNo nvarchar(max),
	intAssignedToId int,
	intLocationId int,
	intUserId int
)

Declare @tblPickListDetail table
(
	intRowNo int IDENTITY(1,1),
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity  numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	intUserId int
)

Declare @tblRemainingPickedItems AS table
( 
	intRowNo int IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(38,20),
	intConsumptionMethodId int,
	ysnIsSubstitute bit,
	intParentItemId int,
	intLotId int
)

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

Declare @tblPickedLotsFinal AS table
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

Declare @tblChildLot AS table
(
	intLotId int,
	intStorageLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblWeightPerUnit numeric(38,20)
)

INSERT INTO @tblPickList(
 intPickListId,strPickListNo,strWorkOrderNo,intAssignedToId,intLocationId,intUserId)
 Select intPickListId,strPickListNo,strWorkOrderNo,intAssignedToId,intLocationId,intUserId
 FROM OPENXML(@idoc, 'root', 2)  
 WITH ( 
	intPickListId int, 
	strPickListNo nvarchar(50),
	strWorkOrderNo nvarchar(max),
	intAssignedToId int,
	intLocationId int,
	intUserId int
	)

INSERT INTO @tblPickListDetail(
 intPickListId,intPickListDetailId,intLotId,intParentLotId,intItemId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
 dblPickQuantity,intPickUOMId,intUserId)
 Select intPickListId,intPickListDetailId,intLotId,intParentLotId,intItemId,intStorageLocationId,dblQuantity,intItemUOMId,dblIssuedQuantity,intItemIssuedUOMId,
 dblPickQuantity,intPickUOMId,intUserId
 FROM OPENXML(@idoc, 'root/lot', 2)  
 WITH ( 
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	dblQuantity numeric(38,20),
	intItemUOMId int,
	dblIssuedQuantity  numeric(38,20),
	intItemIssuedUOMId int,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	intUserId int
	)

Select TOP 1 @intPickListId=intPickListId From @tblPickList

Select @strWorkOrderNos=strWorkOrderNo From @tblPickList 

--Get the Comma Separated Work Order Ids into a table
SET @index = CharIndex(',',@strWorkOrderNos)
WHILE @index > 0
BEGIN
        SET @id = SUBSTRING(@strWorkOrderNos,1,@index-1)
        SET @strWorkOrderNos = SUBSTRING(@strWorkOrderNos,@index+1,LEN(@strWorkOrderNos)-@index)

        INSERT INTO @tblWorkOrder Select intWorkOrderId From tblMFWorkOrder Where strWorkOrderNo=@id
        SET @index = CharIndex(',',@strWorkOrderNos)
END
SET @id=@strWorkOrderNos
INSERT INTO @tblWorkOrder Select intWorkOrderId From tblMFWorkOrder Where strWorkOrderNo=@id

Select @strWorkOrderIds=COALESCE(@strWorkOrderIds, '') + convert(varchar,intWorkOrderId) + ',' From @tblWorkOrder

Select TOP 1 @intWorkOrderId=intWorkOrderId From @tblWorkOrder
Select @intLocationId=intLocationId,@intBlendItemId=intItemId,@intBlendRequirementId=intBlendRequirementId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intWorkOrderId in (Select intWorkOrderId From @tblWorkOrder)

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
		AND r.intWorkOrderId = @intWorkOrderId
	
	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,ri.intConsumptionMethodId
		,ri.intItemId
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = @intWorkOrderId

Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId,ysnIsSubstitute,intParentItemId)
Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.ysnIsSubstitute,ti.intParentItemId 
From @tblInputItem ti Left Join 
(Select intItemId,SUM(dblQuantity) AS dblQuantity From @tblPickListDetail Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
WHERE (ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) > 0

--Find the Remaining Lots
If (Select COUNT(1) From @tblRemainingPickedItems) > 0
Begin
	Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems

	Set @strXmlItem = '<root>'
	Set @strXmlLot = '<root>'

	While(@intMinItemCount is not null)
	Begin
		Set @strExcludedLots=''

		Select @intRawItemId=intItemId,@dblRequiredQty=dblRemainingQuantity,@ysnIsSubstitute=ysnIsSubstitute,@intParentItemId=ISNULL(intParentItemId,0)
		From @tblRemainingPickedItems Where intRowNo=@intMinItemCount

		--WO created from Blend Management Screen if Lots are there input lot table when kitting enabled
		If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId)=0
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

		Set @strXmlItem = @strXmlItem + '<item>'
		Set @strXmlItem = @strXmlItem + '<intRecipeId>' + CONVERT(varchar,@intRecipeId) + '</intRecipeId>'
		Set @strXmlItem = @strXmlItem + '<intRecipeItemId>' + CONVERT(varchar,@intRecipeItemId) + '</intRecipeItemId>'
		Set @strXmlItem = @strXmlItem + '<intItemId>' + CONVERT(varchar,@intRawItemId) + '</intItemId>'
		Set @strXmlItem = @strXmlItem + '<dblRequiredQty>' + CONVERT(varchar,@dblRequiredQty) + '</dblRequiredQty>'
		Set @strXmlItem = @strXmlItem + '<ysnIsSubstitute>' + CONVERT(varchar,@ysnIsSubstitute) + '</ysnIsSubstitute>'
		Set @strXmlItem = @strXmlItem + '<ysnMinorIngredient>' + CONVERT(varchar,0) + '</ysnMinorIngredient>'
		Set @strXmlItem = @strXmlItem + '<intConsumptionMethodId>' + CONVERT(varchar,@intConsumptionMethodId) + '</intConsumptionMethodId>'
		Set @strXmlItem = @strXmlItem + '<intConsumptionStoragelocationId>' + CONVERT(varchar,ISNULL(@intConsumptionStoragelocationId,0)) + '</intConsumptionStoragelocationId>'
		Set @strXmlItem = @strXmlItem + '<intParentItemId>' + CONVERT(varchar,@intParentItemId) + '</intParentItemId>'
		Set @strXmlItem = @strXmlItem + '</item>'

		--Exclude Lot
		Select @strExcludedLots=COALESCE(@strExcludedLots, '') + '<lot>' +  '<intItemId>' + convert(varchar,@intRawItemId) + '</intItemId>' + 
		'<intLotId>' + convert(varchar,pld.intLotId) + '</intLotId>' + '</lot>'
		From tblMFPickListDetail pld Join @tblPickListDetail tpld ON pld.intPickListDetailId=tpld.intPickListDetailId 
		Where pld.intPickListId=@intPickListId AND pld.intLotId=pld.intStageLotId AND pld.intItemId=@intRawItemId 
		AND tpld.dblQuantity < pld.dblQuantity

		If LTRIM(RTRIM(@strExcludedLots)) <> ''
		Begin
			Set @strXmlLot = @strXmlLot + @strExcludedLots
		End

		--Exclude the replaced lot
		Select @strExcludedLots=COALESCE(@strExcludedLots, '') + '<lot>' +  '<intItemId>' + convert(varchar,@intRawItemId) + '</intItemId>' + 
		'<intLotId>' + convert(varchar,pld.intLotId) + '</intLotId>' + '</lot>'
		From tblMFPickListDetail pld Where pld.intPickListId=@intPickListId AND pld.intLotId=pld.intStageLotId AND pld.intItemId=@intRawItemId 
		AND pld.intLotId NOT IN (Select intLotId From @tblPickListDetail)

		If LTRIM(RTRIM(@strExcludedLots)) <> ''
		Begin
			Set @strXmlLot = @strXmlLot + @strExcludedLots
		End

		Select @intMinItemCount=Min(intRowNo) from @tblRemainingPickedItems Where intRowNo > @intMinItemCount
	End
	Set @strXmlItem = @strXmlItem + '</root>'
	Set @strXmlLot = @strXmlLot + '</root>'

	Insert Into @tblPickedLots
	Exec uspMFAutoBlendSheetFIFO @intLocationId,@intBlendRequirementId,0,@strXmlItem,1,@strXmlLot,@strWorkOrderIds

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

	Select * from @tblPickedLotsFinal
End

 IF @idoc <> 0 EXEC sp_xml_removedocument @idoc   