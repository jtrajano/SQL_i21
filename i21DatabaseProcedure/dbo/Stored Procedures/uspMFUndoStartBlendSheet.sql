CREATE PROCEDURE [dbo].[uspMFUndoStartBlendSheet]
	@intWorkOrderId int,
	@intUserId int
AS
Begin Try

	Declare @intStatusId int
	Declare @strWONo nvarchar(50)
	Declare @strErrMsg nvarchar(max)

	Select @intStatusId=intStatusId,@strWONo=strWorkOrderNo 
	From tblMFWorkOrder where intWorkOrderId=@intWorkOrderId And intBlendRequirementId is not null

	If @intStatusId <> 10
		Begin
			Set @strErrMsg='Blend Sheet ' + @strWONo + ' is not started. Please reload the blend sheet.'
			Raiserror(@strErrMsg,16,1)
		End

	Begin Tran

		If @intStatusId = 10
		Begin
			Update tblMFWorkOrderConsumedLot Set ysnStaged=0 where intWorkOrderId=@intWorkOrderId
			Update tblMFWorkOrder Set intStatusId=9,intLastModifiedUserId=@intUserId,dtmLastModified=GetDate() where intWorkOrderId=@intWorkOrderId
		End

	Commit Tran

END TRY

BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @strErrMsg = ERROR_MESSAGE()  
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')  
END CATCH

