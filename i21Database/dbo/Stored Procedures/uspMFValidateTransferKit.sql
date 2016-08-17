CREATE PROCEDURE [dbo].[uspMFValidateTransferKit]
	@intWorkOrderId int,
	@intKitStagingLocationId int,
	@ysnSingleWorkOrderPerPickList bit=0
AS
Declare @intManufacturingProcessId int
--Declare @intKitStagingLocationId int
Declare @strKitStagingLocationName nvarchar(50)
--Declare @intLocationId int
Declare @intItemId int
Declare @ErrMsg nvarchar(max)
Declare @intMinParentLot int
Declare @intPickListId int
Declare @intParentLotId int
Declare @dblReqQty numeric(38,20)
Declare @dblReqUnit numeric(38,20)
Declare @dblAvailableQty numeric(38,20)
Declare @dblAvailableUnit numeric(38,20)
Declare @dblWeightPerUnit numeric(38,20)
Declare @strIssuedUOM nvarchar(50)
Declare @strLotAlias nvarchar(50)
Declare @strItemNo nvarchar(50)
Declare @strWONumber nvarchar(50)
Declare @intBlendItemId int
Declare @dblQtyToProduce numeric(38,20)
Declare @dblPickedQty numeric(38,20)
Declare @intRecipeId int
Declare @dblRecipeQty numeric(38,20)
Declare @intLocationId int
Declare @intMinItemCount int
Declare @dblPickQty numeric(38,20)
Declare @intConsumptionMethodId int
Declare @intInputItemId int
Declare @ysnHasSubstitute bit
Declare @strInputItemNo nvarchar(50)
Declare @strRemItems nvarchar(max)=''
Declare @dblSubstituteRatio numeric(38,20)
Declare @dblMaxSubstituteRatio numeric(38,20)

DECLARE @tblInputItem TABLE (
	intRowNo int IDENTITY
	,intItemId INT
	,dblRequiredQty NUMERIC(38,20)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intConsumptionStorageLocationId INT
	,intParentItemId INT
	,ysnHasSubstitute BIT
	,dblSubstituteRatio NUMERIC(38,20)
	,dblMaxSubstituteRatio NUMERIC(38,20)
)

Select @intPickListId=intPickListId,@intLocationId=intLocationId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
--Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId From tblMFManufacturingProcess Where intAttributeTypeId=2
--Select @intLocationId=intLocationId from tblMFPickList Where intPickListId=@intPickListId

--Select @intKitStagingLocationId=pa.strAttributeValue 
--From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
--Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
--and at.strAttributeName='Kit Staging Location'

If @ysnSingleWorkOrderPerPickList=0
Begin
If ISNULL(@intKitStagingLocationId ,0)=0
	RaisError('Kit Staging Location is not defined.',16,1)

Select @strKitStagingLocationName=strName 
From tblICStorageLocation Where intStorageLocationId=@intKitStagingLocationId

Declare @tblParentLot table
(
	intRowNo int Identity(1,1),
	intWorkOrderId int,
	intParentLotId int,
	dblReqQty numeric(38,20),
	intItemUOMId int,
	intItemIssuedUOMId int
)

	Select @strWONumber=strWorkOrderNo From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId

	If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 8
	Begin
		Set @ErrMsg='The Blend Sheet ' + @strWONumber + ' is already transferred.'
		RaisError(@ErrMsg,16,1)
	End

	If (Select intKitStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) <> 12 
	Begin
		Set @ErrMsg='The Blend Sheet ' + @strWONumber + ' is not staged.'
		RaisError(@ErrMsg,16,1)
	End

	If (Select intStatusId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId) = 13
	Begin
		Set @ErrMsg='The Blend Sheet ' + @strWONumber + ' is already completed.'
		RaisError(@ErrMsg,16,1)
	End

	-- Start Validate available qty in Kit Staging

	--Get the parent Lots for the workorder
	Delete From @tblParentLot
	Insert Into @tblParentLot(intWorkOrderId,intParentLotId,dblReqQty,intItemUOMId,intItemIssuedUOMId)
	Select DISTINCT wi.intWorkOrderId,wi.intParentLotId,wi.dblQuantity,wi.intItemUOMId,wi.intItemIssuedUOMId 
	From tblMFWorkOrderInputParentLot wi 
	Join tblMFPickListDetail pld on wi.intParentLotId=pld.intParentLotId
	Where wi.intWorkOrderId=@intWorkOrderId And pld.intPickListId=@intPickListId

	Select @intMinParentLot=Min(intRowNo) from @tblParentLot

	While(@intMinParentLot is not null) --Loop Parent Lots
	Begin
		Select @intParentLotId=intParentLotId,@dblReqQty=dblReqQty From @tblParentLot Where intRowNo=@intMinParentLot

		Select @dblAvailableQty=ISNULL(SUM(l.dblWeight),0)
		From tblICLot l Join tblMFPickListDetail pld on l.intLotId=pld.intStageLotId 
		Where pld.intPickListId=@intPickListId And l.intParentLotId=@intParentLotId And l.dblQty > 0 
		AND l.intStorageLocationId=@intKitStagingLocationId

		If Round(@dblAvailableQty,0) < Round(@dblReqQty,0)
		Begin
			Select @strIssuedUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
			Where iu.intItemUOMId=(Select intItemIssuedUOMId From @tblParentLot Where intRowNo=@intMinParentLot)

			Select TOP 1 @strLotAlias=l.strLotAlias,@dblWeightPerUnit=l.dblWeightPerQty,@strItemNo=i.strItemNo 
			From tblICLot l Join tblICItem i on l.intItemId=i.intItemId Where intParentLotId=@intParentLotId

			Set @dblAvailableUnit = @dblAvailableQty / @dblWeightPerUnit
			Set @dblReqUnit = @dblReqQty / @dblWeightPerUnit

			Set @ErrMsg='Required qty of ' + Convert(varchar,@dblReqUnit) + ' ' + @strIssuedUOM + ' is not available for the blend sheet ' + 
			@strWONumber + ' with Lot Alias ' + @strLotAlias + ' and Item No.' + @strItemNo + ' in kit staging location ' + @strKitStagingLocationName + '.' 
			RaisError(@ErrMsg,16,1)
		End
		
		Select @intMinParentLot=Min(intRowNo) from @tblParentLot where intRowNo>@intMinParentLot	
	End
	--End Validate available qty in Kit Staging
End

If @ysnSingleWorkOrderPerPickList=1
Begin
	Select TOP 1 @intBlendItemId = intItemId From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
	Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intWorkOrderId=@intWorkOrderId
	Select @dblPickedQty=SUM(dblQuantity) From tblMFPickListDetail Where intPickListId=@intPickListId

	SELECT @intRecipeId = intRecipeId,@dblRecipeQty = dblQuantity
	FROM tblMFWorkOrderRecipe
	WHERE intItemId = @intBlendItemId
		AND intLocationId = @intLocationId
		AND ysnActive = 1
		AND intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intPickListId=@intPickListId)

		INSERT INTO @tblInputItem (
		intItemId
		,dblRequiredQty
		,ysnIsSubstitute
		,intConsumptionMethodId
		,intConsumptionStorageLocationId
		,intParentItemId
		,dblSubstituteRatio
		,dblMaxSubstituteRatio
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,0 AS intParentItemId
		,0.0
		,0.0
	FROM tblMFWorkOrderRecipeItem ri
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = ri.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intPickListId=@intPickListId)
		AND ri.intConsumptionMethodId IN (1,2,3)

	UNION
	
	SELECT 
		rs.intSubstituteItemId AS intItemId
		,(rs.dblQuantity * (@dblQtyToProduce / r.dblQuantity)) dblRequiredQty
		,1
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,ri.intItemId
		,rs.dblSubstituteRatio
		,rs.dblMaxSubstituteRatio
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId AND ri.intWorkOrderId=r.intWorkOrderId
	WHERE r.intRecipeId = @intRecipeId
		AND rs.intRecipeItemTypeId = 1
		AND r.intWorkOrderId = (Select TOP 1 intWorkOrderId From tblMFWorkOrder Where intPickListId=@intPickListId)

	Update a Set a.ysnHasSubstitute=1 from @tblInputItem a Join @tblInputItem b on a.intItemId=b.intParentItemId
	Update @tblInputItem Set ysnHasSubstitute=0 Where ysnHasSubstitute is null

	Select @intMinItemCount=Min(intRowNo) From @tblInputItem Where ysnIsSubstitute=0

	While(@intMinItemCount is not null)
	Begin
		Set @dblPickQty=0

		Select @dblReqQty=dblRequiredQty,@intConsumptionMethodId=intConsumptionMethodId,@intInputItemId=intItemId,@ysnHasSubstitute=ysnHasSubstitute 
		From @tblInputItem Where intRowNo=@intMinItemCount
		Select @dblPickQty=ISNULL(SUM(dblQuantity),0) From tblMFPickListDetail Where intPickListId=@intPickListId AND intItemId=@intInputItemId
		Select @strInputItemNo=strItemNo From tblICItem Where intItemId=@intInputItemId

		If @intConsumptionMethodId=1
		Begin
			--Item has substitute
			If @ysnHasSubstitute=0 AND @dblPickQty<@dblReqQty
				Set @strRemItems=@strRemItems + @strInputItemNo + ','

			--Item does not have substitute
			If @ysnHasSubstitute=1 AND @dblPickQty<@dblReqQty
			Begin
				--Find Remaining Qty (Req - Selected for main item)
				Set @dblReqQty=@dblReqQty-ISNULL(@dblPickQty,0)

				--Calculate Req Qty for Substitute item based on remaining qty
				Select TOP 1 @dblSubstituteRatio=dblSubstituteRatio,@dblMaxSubstituteRatio=dblMaxSubstituteRatio 
				From @tblInputItem Where intParentItemId=@intInputItemId AND ysnIsSubstitute=1
				Set @dblReqQty=@dblReqQty * (@dblSubstituteRatio*@dblMaxSubstituteRatio/100)

				Select @dblPickQty=ISNULL(SUM(ISNULL(dblQuantity,0)),0) From tblMFPickListDetail Where intPickListId=@intPickListId 
				AND intItemId IN (Select intItemId From @tblInputItem Where intParentItemId=@intInputItemId)

				If @dblPickQty<@dblReqQty
				Begin
					Select @strInputItemNo=strItemNo From tblICItem Where intItemId=(Select TOP 1 intItemId From @tblInputItem Where intParentItemId=@intInputItemId)
					Set @strRemItems=@strRemItems + @strInputItemNo + ','
				End
		
			End
		End
		Else
		Begin
			--For Bulk Item Pick Qty is the same as reserved qty
			Select @dblPickQty = ISNULL(SUM(ISNULL(dblQty,0)),0) 
			From tblICStockReservation Where intTransactionId=@intPickListId AND intInventoryTransactionType=34 AND intItemId=@intInputItemId

			If @dblPickQty<@dblReqQty
				Set @strRemItems=@strRemItems + @strInputItemNo + ','
		End

		Select @intMinItemCount=Min(intRowNo) From @tblInputItem Where intRowNo>@intMinItemCount AND ysnIsSubstitute=0
	End

	If LTRIM(RTRIM(@strRemItems))<>''
	Begin
		Set @strRemItems=SUBSTRING(@strRemItems,1,LEN(@strRemItems)-1)
		Set @ErrMsg='Transfer is not allowed because there is shortage of inventory of item(s) (' + @strRemItems + ') in pick list. Please pick lots with available inventory. If inventory is available then save the pick list before staging.'
		RaisError(@ErrMsg,16,1)
	End

End