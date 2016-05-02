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
		intPickUOMId int
	)

Begin Tran

	If @intKitStatusId = 7
	Begin
		--Move the Staged (Kitting Area) Lots back to Storage Location
		Insert Into @tblPickListDetail(intPickListDetailId,intStageLotId,intStorageLocationId,dblPickQuantity,intPickUOMId)
		Select PL.intPickListDetailId,PL.intStageLotId,PL.intStorageLocationId,
		--CASE WHEN PL.intItemUOMId = PL.intItemIssuedUOMId THEN PL.dblPickQuantity / L.dblWeightPerQty ELSE PL.dblPickQuantity END 
		PL.dblPickQuantity,PL.intPickUOMId
		From tblMFPickListDetail PL
		JOIN dbo.tblICLot L on L.intLotId=PL.intStageLotId
		Where intPickListId=@intPickListId AND PL.intLotId <> PL.intStageLotId

		Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail

		While(@intMinPickDetail is not null) --Pick List Detail Loop
		Begin
			Select @intPickListDetailId = pld.intPickListDetailId, @intStageLotId=pld.intStageLotId,
			@intStorageLocationId=pld.intStorageLocationId,@dblPickQuantity=pld.dblPickQuantity,@intPickUOMId=intPickUOMId 
			From @tblPickListDetail pld
			where intRowNo=@intMinPickDetail

			Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intStorageLocationId

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
		Insert Into @tblPickListDetail(intPickListDetailId,intStageLotId,intStorageLocationId,dblPickQuantity,intPickUOMId)
		Select PL.intPickListDetailId,PL.intStageLotId,PL.intStorageLocationId,
		--CASE WHEN PL.intItemUOMId = PL.intItemIssuedUOMId THEN PL.dblPickQuantity / L.dblWeightPerQty ELSE PL.dblPickQuantity END 
		PL.dblPickQuantity,PL.intPickUOMId
		From tblMFPickListDetail PL
		JOIN dbo.tblICLot L on L.intLotId=PL.intStageLotId
		Where intPickListId=@intPickListId

		Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail

		While(@intMinPickDetail is not null) --Pick List Detail Loop
		Begin
			Select @intPickListDetailId = pld.intPickListDetailId, @intStageLotId=pld.intStageLotId,
			@intStorageLocationId=pld.intStorageLocationId,@dblPickQuantity=pld.dblPickQuantity,@intPickUOMId=intPickUOMId 
			From @tblPickListDetail pld
			where intRowNo=@intMinPickDetail

			Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intStorageLocationId

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
