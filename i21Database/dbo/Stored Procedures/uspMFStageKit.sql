CREATE PROCEDURE [dbo].[uspMFStageKit]
	@intPickListId int,
	@intUserId int
AS
Begin Try

Declare @intKitStagingLocationId int
Declare @intManufacturingProcessId int
Declare @intLocationId int
Declare @intMinLot int
Declare @intLotId int
Declare @intNewSubLocationId int
Declare @dblMoveQty numeric(38,20)
Declare @strLotNumber nvarchar(50)
Declare @intNewLotId int
Declare @intItemId int
Declare @intPickListDetailId int
Declare @ErrMsg nvarchar(max)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @dblPhysicalQty numeric(38,20)
Declare @dblWeightPerQty numeric(38,20)
Declare @strUOM nvarchar(50)
Declare @intKitStatusId int
Declare @ysnBlendSheetRequired bit
Declare @intRecipeId int
Declare @dblQtyToProduce numeric(38,20)
Declare @intBlendItemId int
Declare @intBlendStagingLocationId int
Declare @dblPickedQty numeric(38,20)
Declare @dblQuantity numeric(38,20)
Declare @strRemItems nvarchar(max)=''
Declare @strBulkItemXml nvarchar(max)
Declare @intWorkOrderId INT
Declare @intMinItemCount int
Declare @dblReqQty NUMERIC(38,20)
Declare @intConsumptionMethodId INT
Declare @dblPickQty NUMERIC(38,20)
Declare @intInputItemId INT
Declare @ysnHasSubstitute bit
Declare @strInputItemNo nvarchar(50)
DECLARE @strInActiveLots NVARCHAR(MAX) 
Declare @dblRecipeQty NUMERIC(38,20)
		,@dblPickQuantity numeric(38,20)
		,@intPickUOMId int
		,@intItemUOMId int

Select TOP 1 @intManufacturingProcessId=intManufacturingProcessId,@intKitStatusId=intKitStatusId,@intWorkOrderId=intWorkOrderId 
From tblMFWorkOrder Where intPickListId=@intPickListId
Select @intLocationId=intLocationId from tblMFPickList Where intPickListId=@intPickListId

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Kit Staging Location'

Select TOP 1 @ysnBlendSheetRequired=ISNULL(ysnBlendSheetRequired,0) From tblMFCompanyPreference

SELECT @intBlendStagingLocationId = ISNULL(intBlendProductionStagingUnitId, 0)
FROM tblSMCompanyLocation
WHERE intCompanyLocationId = @intLocationId

If @intKitStatusId = 12 
	RaisError('Kit is already staged.',16,1)

If @intKitStatusId = 8 
	RaisError('Kit is already transferred.',16,1)

If @intKitStatusId <> 7
	RaisError('Kit is not picked.',16,1)

If ISNULL(@intKitStagingLocationId ,0)=0
	RaisError('Kit Staging Location is not defined.',16,1)

Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intKitStagingLocationId

Declare @tblPickListDetail table
(
	intRowNo int Identity(1,1),
	intPickListId int,
	intPickListDetailId int,
	intLotId int,
	strLotNumber nvarchar(50),
	intParentLotId int,
	intItemId int,
	intStorageLocationId int,
	dblPickQuantity numeric(38,20),
	intPickUOMId int,
	dblPhysicalQty numeric(38,20),
	dblWeightPerQty numeric(38,20),
	intItemUOMId int,
	intItemIssuedUOMId int,
	dblQuantity numeric(38,20)
)

DECLARE @tblInputItem TABLE (
	intRowNo int IDENTITY
	,intItemId INT
	,dblRequiredQty NUMERIC(38,20)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intConsumptionStorageLocationId INT
	,intParentItemId INT
	,ysnHasSubstitute BIT
	)

Declare @tblRemainingPickedItems AS table
( 
	intRowNo int IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(38,20),
	intConsumptionMethodId int,
	intConsumptionStorageLocationId int
)

Insert Into @tblPickListDetail(intPickListId,intPickListDetailId,intLotId,strLotNumber,intParentLotId,intItemId,intStorageLocationId,
dblPickQuantity,intPickUOMId,dblPhysicalQty,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId,dblQuantity)
Select pld.intPickListId,pld.intPickListDetailId,pld.intLotId,l.strLotNumber,pld.intParentLotId,pld.intItemId,pld.intStorageLocationId,
pld.dblPickQuantity,pld.intPickUOMId,dblWeight,
CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty,pld.intItemUOMId,pld.intItemIssuedUOMId,pld.dblQuantity
From tblMFPickListDetail pld Join tblICLot l on pld.intLotId=l.intLotId
Where intPickListId=@intPickListId AND pld.intLotId = pld.intStageLotId --Exclude Lots that are already in Kit Staging Location
UNION --Non Lot Tracked
Select pld.intPickListId,pld.intPickListDetailId,0,'',0,pld.intItemId,0,
pld.dblQuantity,pld.intItemUOMId,0,1,pld.intItemUOMId,pld.intItemUOMId,pld.dblQuantity
From tblMFPickListDetail pld Join tblICItem i on pld.intItemId=i.intItemId 
Where i.strLotTracking='No'

--Only Active lots are allowed to stage
SELECT @strInActiveLots = COALESCE(@strInActiveLots + ', ', '') + l.strLotNumber
FROM @tblPickListDetail tpl Join tblICLot l on tpl.intLotId=l.intLotId 
Join tblICLotStatus ls on l.intLotStatusId=ls.intLotStatusId Where ls.strPrimaryStatus<>'Active'

If ISNULL(@strInActiveLots,'')<>''
Begin
	Set @ErrMsg='Lots ' + @strInActiveLots + ' are not active. Unable to perform stage operation.'
	RaisError(@ErrMsg,16,1)
End

If @ysnBlendSheetRequired=0
Begin

	Select TOP 1 @intBlendItemId = intItemId From tblMFWorkOrder Where intPickListId=@intPickListId 
	Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId
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
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
		,0 AS intParentItemId
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
	FROM tblMFWorkOrderRecipeSubstituteItem rs
	JOIN tblMFWorkOrderRecipe r ON r.intWorkOrderId = rs.intWorkOrderId
	JOIN tblMFWorkOrderRecipeItem ri on rs.intRecipeItemId=ri.intRecipeItemId
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
				Set @dblReqQty=(@dblReqQty * (@dblQtyToProduce / @dblRecipeQty))

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
		Set @ErrMsg='Staging is not allowed because there is shortage of inventory of item(s) (' + @strRemItems + ') in pick list. Please pick lots with available inventory. If inventory is available then save the pick list before staging.'
		RaisError(@ErrMsg,16,1)
	End

End

Begin Tran

--Reserve Lots
--Get Bulk Items From Reserved Lots
Set @strBulkItemXml='<root>'

--Bulk Item
Select @strBulkItemXml=COALESCE(@strBulkItemXml, '') + '<lot>' + 
'<intItemId>' + convert(varchar,sr.intItemId) + '</intItemId>' +
'<intItemUOMId>' + convert(varchar,sr.intItemUOMId) + '</intItemUOMId>' + 
'<dblQuantity>' + convert(varchar,sr.dblQty) + '</dblQuantity>' + '</lot>'
From tblICStockReservation sr 
Where sr.intTransactionId=@intPickListId AND sr.intInventoryTransactionType=34 AND ISNULL(sr.intLotId,0)=0

Set @strBulkItemXml=@strBulkItemXml+'</root>'

If LTRIM(RTRIM(@strBulkItemXml))='<root></root>' 
	Set @strBulkItemXml=''

EXEC uspMFDeleteLotReservationByPickList @intPickListId = @intPickListId

--Move or Merge
Select @intMinLot=Min(intRowNo) from @tblPickListDetail

While(@intMinLot is not null)
Begin
	Select @intNewLotId=NULL,@intItemUOMId=NULL

	Select @intLotId=intLotId,@strLotNumber=strLotNumber,
	@dblMoveQty=CASE WHEN intItemUOMId = intItemIssuedUOMId THEN dblPickQuantity / dblWeightPerQty ELSE dblPickQuantity END,
	@intItemId=intItemId,
	@intPickListDetailId=intPickListDetailId,@dblPhysicalQty=dblPhysicalQty,@dblWeightPerQty=dblWeightPerQty,@dblQuantity=dblQuantity,@dblPickQuantity=dblPickQuantity,@intPickUOMId=intPickUOMId 
	,@intItemUOMId=intItemUOMId
	From @tblPickListDetail Where intRowNo=@intMinLot

	--Non Lot Tracked Item
	If ISNULL(@intLotId,0)=0
	Begin
		Exec uspMFKitItemMove @intPickListDetailId,@intKitStagingLocationId,@intUserId

		GOTO NEXT_RECORD
	End

	If ROUND(@dblPhysicalQty,3) < ROUND(@dblQuantity,3)
	Begin
		Select @strUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
		Where iu.intItemUOMId=(Select intItemUOMId From @tblPickListDetail Where intRowNo=@intMinLot)

		Set @ErrMsg='Required qty of ' + Convert(varchar,@dblQuantity) + ' ' + @strUOM + ' is not available from lot ' + @strLotNumber + '.'
		RaisError(@ErrMsg,16,1)
	End

	Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intLocationId 
		And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intKitStagingLocationId 
		--And dtmExpiryDate > @dtmCurrentDateTime AND intLotStatusId = 1 AND dblQty > 0

	IF NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intLotId AND (intItemUOMId=@intPickUOMId OR intWeightUOMId =@intPickUOMId ))
	BEGIN
		SELECT @dblPickQuantity=@dblQuantity
		SELECT @intPickUOMId=@intItemUOMId
	END

	If ISNULL(@intNewLotId,0) = 0
		Begin
			Exec [uspMFLotMove] @intLotId=@intLotId,
								@intNewSubLocationId=@intNewSubLocationId,
								@intNewStorageLocationId=@intKitStagingLocationId,
								@dblMoveQty=@dblPickQuantity,
								@intMoveItemUOMId=@intPickUOMId,
								@intUserId=@intUserId

			Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intLocationId 
			And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intKitStagingLocationId --And dblQty > 0

		End
	Else
		Exec [uspMFLotMerge] @intLotId=@intLotId,
					@intNewLotId=@intNewLotId,
					@dblMergeQty=@dblPickQuantity,
					@intMergeItemUOMId=@intPickUOMId,
					@intUserId=@intUserId

	NEXT_RECORD:
	Update tblMFPickListDetail Set intStageLotId=@intNewLotId,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime
	Where intPickListDetailId=@intPickListDetailId
	
	Select @intMinLot=Min(intRowNo) from @tblPickListDetail where intRowNo>@intMinLot
End

Exec [uspMFCreateLotReservationByPickList] @intPickListId,@strBulkItemXml,1,@intKitStagingLocationId

Update tblMFWorkOrder Set intKitStatusId=12,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime Where intPickListId=@intPickListId

Update tblMFPickList Set intKitStatusId=12,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime Where intPickListId=@intPickListId

Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  