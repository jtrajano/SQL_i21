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
Declare @dblMoveQty numeric(18,6)
Declare @strLotNumber nvarchar(50)
Declare @intNewLotId int
Declare @intItemId int
Declare @intPickListDetailId int
Declare @ErrMsg nvarchar(max)
Declare @dtmCurrentDateTime DateTime=GETDATE()
Declare @dblPhysicalQty numeric(18,6)
Declare @dblWeightPerQty numeric(18,6)
Declare @strUOM nvarchar(50)
Declare @intKitStatusId int
Declare @ysnBlendSheetRequired bit
Declare @intRecipeId int
Declare @dblQtyToProduce numeric(18,6)
Declare @intBlendItemId int
Declare @intBlendStagingLocationId int

Select @intManufacturingProcessId=intManufacturingProcessId,@intKitStatusId=intKitStatusId 
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
	dblPickQuantity numeric(18,6),
	intPickUOMId int,
	dblPhysicalQty numeric(18,6),
	dblWeightPerQty numeric(18,6),
	intItemUOMId int,
	intItemIssuedUOMId int
)

DECLARE @tblInputItem TABLE (
	intItemId INT
	,dblRequiredQty NUMERIC(18, 6)
	,ysnIsSubstitute BIT
	,intConsumptionMethodId INT
	,intConsumptionStorageLocationId INT
	)

Declare @tblRemainingPickedItems AS table
( 
	intRowNo int IDENTITY,
	intItemId int,
	dblRemainingQuantity numeric(18,6),
	intConsumptionMethodId int,
	intConsumptionStorageLocationId int
)

Insert Into @tblPickListDetail(intPickListId,intPickListDetailId,intLotId,strLotNumber,intParentLotId,intItemId,intStorageLocationId,
dblPickQuantity,intPickUOMId,dblPhysicalQty,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId)
Select pld.intPickListId,pld.intPickListDetailId,pld.intLotId,l.strLotNumber,pld.intParentLotId,pld.intItemId,pld.intStorageLocationId,
pld.dblPickQuantity,pld.intPickUOMId,dblWeight,
CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty,pld.intItemUOMId,pld.intItemIssuedUOMId
From tblMFPickListDetail pld Join tblICLot l on pld.intLotId=l.intLotId
Where intPickListId=@intPickListId AND pld.intLotId = pld.intStageLotId --Exclude Lots that are already in Kit Staging Location

If @ysnBlendSheetRequired=0
Begin

	Select TOP 1 @intBlendItemId = intItemId From tblMFWorkOrder Where intPickListId=@intPickListId 
	Select @dblQtyToProduce=SUM(dblQuantity) From tblMFWorkOrder Where intPickListId=@intPickListId

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
		,intConsumptionStorageLocationId
		)
	SELECT 
		ri.intItemId
		,(ri.dblCalculatedQuantity * (@dblQtyToProduce / r.dblQuantity)) AS dblRequiredQty
		,0
		,ri.intConsumptionMethodId
		,ri.intStorageLocationId
	FROM tblMFRecipeItem ri
	JOIN tblMFRecipe r ON r.intRecipeId = ri.intRecipeId
	WHERE r.intRecipeId = @intRecipeId
		AND ri.intRecipeItemTypeId = 1

	Insert Into @tblRemainingPickedItems(intItemId,dblRemainingQuantity,intConsumptionMethodId,intConsumptionStorageLocationId)
	Select ti.intItemId,(ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)) AS dblRemainingQuantity,ti.intConsumptionMethodId,ti.intConsumptionStorageLocationId 
	From @tblInputItem ti Left Join 
	(Select intItemId,SUM(dblQuantity) AS dblQuantity From tblMFPickListDetail Where intPickListId=@intPickListId Group by intItemId) tpl on  ti.intItemId=tpl.intItemId
	WHERE Round((ti.dblRequiredQty - ISNULL(tpl.dblQuantity,0)),0) > 0

	--intSalesOrderLineItemId = 0 implies WOs are created from Blend Managemnet Screen And Lots are already attached
	If (Select TOP 1 ISNULL(intSalesOrderLineItemId,0) From tblMFWorkOrder Where intPickListId=@intPickListId)=0
		Delete From @tblRemainingPickedItems

	If (Select Count(1) From @tblRemainingPickedItems Where intConsumptionMethodId=1) > 0
	Begin
		Set @ErrMsg='Staging is not allowed because there is shortage of inventory in pick list. Please pick lots with available inventory and save the pick list before staging.'
		RaisError(@ErrMsg,16,1)
	End

	--For Bulk Items there in Recipe
	If Exists (Select 1 From @tblRemainingPickedItems Where intConsumptionMethodId in (2,3))
	Begin
		Delete From @tblRemainingPickedItems Where intConsumptionMethodId not in (2,3)

		Declare @intBulkMinItemCount int
		Declare @intConsumptionMethodId int
		Declare @intConsumptionStorageLocationId int
		Declare @intBulkItemId int
		Declare @dblBulkAvailableQty numeric(18,6)
		Declare @dblBulkRemainingQty numeric(18,6)

		Select @intBulkMinItemCount=Min(intRowNo) From @tblRemainingPickedItems

		While(@intBulkMinItemCount is not null)
		Begin
			Select @intBulkItemId=intItemId,@intConsumptionMethodId=intConsumptionMethodId,@intConsumptionStorageLocationId=intConsumptionStorageLocationId,
					@dblBulkRemainingQty=dblRemainingQuantity From @tblRemainingPickedItems Where intRowNo=@intBulkMinItemCount

			If @intConsumptionMethodId =2 
				Select @dblBulkAvailableQty=ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot l 
				JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId
				Where intItemId=@intBulkItemId AND intStorageLocationId=@intConsumptionStorageLocationId AND dblQty > 0 
				AND ls.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND l.dtmExpiryDate >= GETDATE()
					AND l.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					)
			If @intConsumptionMethodId =3 
				Select @dblBulkAvailableQty=ISNULL(SUM(ISNULL(dblWeight,0)),0) From tblICLot l 
				JOIN tblICLotStatus ls ON l.intLotStatusId = ls.intLotStatusId 
				Where intItemId=@intBulkItemId AND intLocationId=@intLocationId AND dblQty > 0
				AND ls.strPrimaryStatus IN (
					'Active'
					,'Quarantine'
					)
				AND l.dtmExpiryDate >= GETDATE()
				AND l.dtmExpiryDate >= GETDATE()
					AND l.intStorageLocationId NOT IN (
					@intKitStagingLocationId
					,@intBlendStagingLocationId
					)

			If @dblBulkAvailableQty < @dblBulkRemainingQty
			Begin
				Set @ErrMsg='Staging is not allowed because there is shortage of inventory in pick list. Please pick lots with available inventory and save the pick list before staging.'
				RaisError(@ErrMsg,16,1)
			End

			Select @intBulkMinItemCount=Min(intRowNo) From @tblRemainingPickedItems Where intRowNo > @intBulkMinItemCount
		End
	End
End

Begin Tran

--Move or Merge
Select @intMinLot=Min(intRowNo) from @tblPickListDetail

While(@intMinLot is not null)
Begin
	Set @intNewLotId=NULL

	Select @intLotId=intLotId,@strLotNumber=strLotNumber,
	@dblMoveQty=CASE WHEN intItemUOMId = intItemIssuedUOMId THEN dblPickQuantity / dblWeightPerQty ELSE dblPickQuantity END,
	@intItemId=intItemId,
	@intPickListDetailId=intPickListDetailId,@dblPhysicalQty=dblPhysicalQty,@dblWeightPerQty=dblWeightPerQty 
	From @tblPickListDetail Where intRowNo=@intMinLot

	If @dblPhysicalQty < (@dblMoveQty * @dblWeightPerQty)
	Begin
		Select @strUOM=um.strUnitMeasure From tblICItemUOM iu Join tblICUnitMeasure um on iu.intUnitMeasureId=um.intUnitMeasureId 
		Where iu.intItemUOMId=(Select intItemUOMId From @tblPickListDetail Where intRowNo=@intMinLot)

		Set @ErrMsg='Required qty of ' + Convert(varchar,(@dblMoveQty * @dblWeightPerQty)) + ' ' + @strUOM + ' is not available from lot ' + @strLotNumber + '.'
		RaisError(@ErrMsg,16,1)
	End

	Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intLocationId 
		And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intKitStagingLocationId 
		--And dtmExpiryDate > @dtmCurrentDateTime AND intLotStatusId = 1 AND dblQty > 0

	If ISNULL(@intNewLotId,0) = 0
		Begin
			Exec [uspMFLotMove] @intLotId=@intLotId,
								@intNewSubLocationId=@intNewSubLocationId,
								@intNewStorageLocationId=@intKitStagingLocationId,
								@dblMoveQty=@dblMoveQty,
								@intUserId=@intUserId

			Select TOP 1 @intNewLotId=intLotId From tblICLot where strLotNumber=@strLotNumber And intItemId=@intItemId And intLocationId=@intLocationId 
			And intSubLocationId=@intNewSubLocationId And intStorageLocationId=@intKitStagingLocationId --And dblQty > 0

		End
	Else
		Exec [uspMFLotMerge] @intLotId=@intLotId,
					@intNewLotId=@intNewLotId,
					@dblMergeQty=@dblMoveQty,
					@intUserId=@intUserId

	Update tblMFPickListDetail Set intStageLotId=@intNewLotId,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime
	Where intPickListDetailId=@intPickListDetailId

	Select @intMinLot=Min(intRowNo) from @tblPickListDetail where intRowNo>@intMinLot
End

--Reserve Lots
Exec [uspMFCreateLotReservationByPickList] @intPickListId

Update tblMFWorkOrder Set intKitStatusId=12,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime Where intPickListId=@intPickListId

Update tblMFPickList Set intKitStatusId=12,intLastModifiedUserId=@intUserId,dtmLastModified=@dtmCurrentDateTime Where intPickListId=@intPickListId

Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH  