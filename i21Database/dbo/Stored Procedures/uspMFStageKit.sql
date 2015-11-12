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

Select @intManufacturingProcessId=intManufacturingProcessId,@intKitStatusId=intKitStatusId 
From tblMFWorkOrder Where intPickListId=@intPickListId
Select @intLocationId=intLocationId from tblMFPickList Where intPickListId=@intPickListId

Select @intKitStagingLocationId=pa.strAttributeValue 
From tblMFManufacturingProcessAttribute pa Join tblMFAttribute at on pa.intAttributeId=at.intAttributeId
Where intManufacturingProcessId=@intManufacturingProcessId and intLocationId=@intLocationId 
and at.strAttributeName='Kit Staging Location'

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

Insert Into @tblPickListDetail(intPickListId,intPickListDetailId,intLotId,strLotNumber,intParentLotId,intItemId,intStorageLocationId,
dblPickQuantity,intPickUOMId,dblPhysicalQty,dblWeightPerQty,intItemUOMId,intItemIssuedUOMId)
Select pld.intPickListId,pld.intPickListDetailId,pld.intLotId,l.strLotNumber,pld.intParentLotId,pld.intItemId,pld.intStorageLocationId,
pld.dblPickQuantity,pld.intPickUOMId,dblWeight,
CASE WHEN ISNULL(l.dblWeightPerQty,0)=0 THEN 1 ELSE l.dblWeightPerQty END AS dblWeightPerQty,pld.intItemUOMId,pld.intItemIssuedUOMId
From tblMFPickListDetail pld Join tblICLot l on pld.intLotId=l.intLotId
Where intPickListId=@intPickListId

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