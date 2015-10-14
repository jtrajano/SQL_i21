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
		dblPickQuantity numeric(18,6)
	)

Begin Tran

	If @intKitStatusId = 7
	Begin
		Delete From tblMFPickListDetail Where intPickListId=@intPickListId

		Delete From tblMFPickList Where intPickListId=@intPickListId

		Update tblMFWorkOrder Set intKitStatusId=6,intPickListId=NULL Where intPickListId=@intPickListId

		Exec [uspMFDeleteLotReservationByPickList] @intPickListId
	End

	If @intKitStatusId = 12
	Begin

		--Move the Staged (Kitting Area) Lots back to Storage Location
		Insert Into @tblPickListDetail(intPickListDetailId,intStageLotId,intStorageLocationId,dblPickQuantity)
		Select intPickListDetailId,intStageLotId,intStorageLocationId,dblPickQuantity 
		From tblMFPickListDetail Where intPickListId=@intPickListId

		Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail

		While(@intMinPickDetail is not null) --Pick List Detail Loop
		Begin
			Select @intPickListDetailId = pld.intPickListDetailId, @intStageLotId=pld.intStageLotId,
			@intStorageLocationId=pld.intStorageLocationId,@dblPickQuantity=pld.dblPickQuantity 
			From @tblPickListDetail pld
			where intRowNo=@intMinPickDetail

			Select @intNewSubLocationId=intSubLocationId from tblICStorageLocation Where intStorageLocationId=@intStorageLocationId

			Exec [uspMFLotMove] @intLotId=@intStageLotId,
					@intNewSubLocationId=@intNewSubLocationId,
					@intNewStorageLocationId=@intStorageLocationId,
					@dblMoveQty=@dblPickQuantity,
					@intUserId=@intUserId

			Select @intMinPickDetail=Min(intRowNo) from @tblPickListDetail where intRowNo>@intMinPickDetail
		End

		Delete From tblMFPickListDetail Where intPickListId=@intPickListId

		Delete From tblMFPickList Where intPickListId=@intPickListId

		Update tblMFWorkOrder Set intKitStatusId=6,intPickListId=NULL Where intPickListId=@intPickListId

		--Restore the Reservation to Parent Lot
	End
Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH 
