CREATE PROCEDURE [dbo].[uspMFDeletePickList]
	@intPickListId int,
	@intUserId int
AS
BEGIN TRY

Declare @ErrMsg nvarchar(max)
Declare @intKitStatusId int
Declare @intMinPickDetail int
Declare @intPickListDetailId int
Declare @intStageLotId int
Declare @intStorageLocationId int
Declare @dblPickQuantity numeric(18,6)
Declare @intNewSubLocationId int
Declare @strPickListNo nvarchar(50)
DECLARE @intMinWO int
DECLARE @intWorkOrderId int
DECLARE @ysnEnableParentLot BIT = 0
		,@intPickUOMId int
		,@dblQuantity numeric(38,20)
		,@intItemUOMId int

SELECT TOP 1 @ysnEnableParentLot = ISNULL(ysnEnableParentLot, 0) FROM tblMFCompanyPreference

Select @intKitStatusId=intKitStatusId,@strPickListNo=strPickListNo from tblMFPickList Where intPickListId = @intPickListId

If @intKitStatusId not in (7,12)
	RaisError('Pick List cannot be deleted as it is already transferred.',16,1)

If @intKitStatusId = 12 
Begin
	If Exists (Select 1 From tblMFWorkOrder Where intPickListId=@intPickListId AND intKitStatusId=8)
		Begin
			Set @ErrMsg='One or more blend sheets are already transferred for the selected pick no ' + @strPickListNo + '. This pick cannot be deleted.'
			RaisError(@ErrMsg,16,1)
		End
End

	Declare @tblPickListDetail table
	(
		intRowNo int IDENTITY(1,1),
		intPickListDetailId int,
		intStageLotId int,
		intStorageLocationId int,
		dblPickQuantity numeric(18,6),
		intPickUOMId int,
		dblQuantity numeric(38,20),
		intItemUOMId int
	)

Begin Tran

	If @intKitStatusId = 7
	Begin
		--Move the Staged (Kitting Area) Lots back to Storage Location
		Insert Into @tblPickListDetail(intPickListDetailId,intStageLotId,intStorageLocationId,dblPickQuantity,intPickUOMId,dblQuantity,intItemUOMId)
		Select PL.intPickListDetailId,PL.intStageLotId,PL.intStorageLocationId,
		PL.dblPickQuantity,PL.intPickUOMId,PL.dblQuantity,PL.intItemUOMId
		From tblMFPickListDetail PL
		JOIN dbo.tblICLot L on L.intLotId=PL.intStageLotId
		Where intPickListId=@intPickListId AND PL.intLotId <> PL.intStageLotId

		Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail

		While(@intMinPickDetail is not null) --Pick List Detail Loop
		Begin

			SELECT @dblPickQuantity=NULL,@intPickUOMId=NULL,@dblQuantity=NULL,@intItemUOMId=NULL

			Select @intPickListDetailId = pld.intPickListDetailId, @intStageLotId=pld.intStageLotId,
			@intStorageLocationId=pld.intStorageLocationId,@dblPickQuantity=pld.dblPickQuantity,@intPickUOMId=intPickUOMId,@dblQuantity=pld.dblQuantity,@intItemUOMId=pld.intItemUOMId  
			From @tblPickListDetail pld
			where intRowNo=@intMinPickDetail

			Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intStorageLocationId

			IF NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intStageLotId AND (intItemUOMId=@intPickUOMId OR intWeightUOMId =@intPickUOMId ))
			BEGIN
				SELECT @dblPickQuantity=@dblQuantity
				SELECT @intPickUOMId=@intItemUOMId
			END

			Exec [uspMFLotMove] @intLotId=@intStageLotId,
					@intNewSubLocationId=@intNewSubLocationId,
					@intNewStorageLocationId=@intStorageLocationId,
					@dblMoveQty=@dblPickQuantity,
					@intMoveItemUOMId=@intPickUOMId,
					@intUserId=@intUserId

			Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail where intRowNo>@intMinPickDetail
		End

		Delete From tblMFPickListDetail Where intPickListId=@intPickListId

		Delete From tblMFPickList Where intPickListId=@intPickListId

		--Restore the reservation for blend sheet
		Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder Where intPickListId=@intPickListId

		While(@intMinWO is not null)
		Begin
			Select @intWorkOrderId=intWorkOrderId from tblMFWorkOrder Where intWorkOrderId=@intMinWO

			EXEC uspMFCreateLotReservation @intWorkOrderId,@ysnEnableParentLot

			Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder where intPickListId=@intPickListId And intWorkOrderId>@intWorkOrderId
		End

		Exec [uspMFDeleteLotReservationByPickList] @intPickListId

		Update tblMFWorkOrder Set intKitStatusId=6,intPickListId=NULL Where intPickListId=@intPickListId
	End

	If @intKitStatusId = 12
	Begin

		--Move the Staged (Kitting Area) Lots back to Storage Location
		Insert Into @tblPickListDetail(intPickListDetailId,intStageLotId,intStorageLocationId,dblPickQuantity,intPickUOMId,dblQuantity,intItemUOMId)
		Select PL.intPickListDetailId,PL.intStageLotId,PL.intStorageLocationId,
		PL.dblPickQuantity,PL.intPickUOMId,PL.dblQuantity,PL.intItemUOMId
		From tblMFPickListDetail PL
		JOIN dbo.tblICLot L on L.intLotId=PL.intStageLotId
		Where intPickListId=@intPickListId

		Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail

		While(@intMinPickDetail is not null) --Pick List Detail Loop
		Begin
			SELECT @dblPickQuantity=NULL,@intPickUOMId=NULL,@dblQuantity=NULL,@intItemUOMId=NULL

			Select @intPickListDetailId = pld.intPickListDetailId, @intStageLotId=pld.intStageLotId,
			@intStorageLocationId=pld.intStorageLocationId,@dblPickQuantity=pld.dblPickQuantity,@intPickUOMId=intPickUOMId,@dblQuantity=pld.dblQuantity,@intItemUOMId=pld.intItemUOMId   
			From @tblPickListDetail pld
			where intRowNo=@intMinPickDetail

			Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intStorageLocationId

			IF NOT EXISTS(SELECT *FROM dbo.tblICLot WHERE intLotId=@intStageLotId AND (intItemUOMId=@intPickUOMId OR intWeightUOMId =@intPickUOMId ))
			BEGIN
				SELECT @dblPickQuantity=@dblQuantity
				SELECT @intPickUOMId=@intItemUOMId
			END

			Exec [uspMFLotMove] @intLotId=@intStageLotId,
					@intNewSubLocationId=@intNewSubLocationId,
					@intNewStorageLocationId=@intStorageLocationId,
					@dblMoveQty=@dblPickQuantity,
					@intMoveItemUOMId=@intPickUOMId,
					@intUserId=@intUserId

			Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail where intRowNo>@intMinPickDetail
		End

		Delete From tblMFPickListDetail Where intPickListId=@intPickListId

		Delete From tblMFPickList Where intPickListId=@intPickListId

		--Restore the reservation for blend sheet
		Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder Where intPickListId=@intPickListId

		While(@intMinWO is not null)
		Begin
			Select @intWorkOrderId=intWorkOrderId from tblMFWorkOrder Where intWorkOrderId=@intMinWO

			EXEC uspMFCreateLotReservation @intWorkOrderId,@ysnEnableParentLot

			Select @intMinWO=Min(intWorkOrderId) from tblMFWorkOrder where intPickListId=@intPickListId And intWorkOrderId>@intWorkOrderId
		End

		Exec [uspMFDeleteLotReservationByPickList] @intPickListId

		Update tblMFWorkOrder Set intKitStatusId=6,intPickListId=NULL Where intPickListId=@intPickListId

	End
Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH 
