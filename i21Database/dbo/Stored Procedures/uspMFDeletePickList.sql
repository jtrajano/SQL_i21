CREATE PROCEDURE [dbo].[uspMFDeletePickList]
	@intPickListId int
AS
BEGIN TRY

Declare @ErrMsg nvarchar(max)

Begin Tran

	Delete From tblMFPickListDetail Where intPickListId=@intPickListId

	Delete From tblMFPickList Where intPickListId=@intPickListId

	Update tblMFWorkOrder Set intKitStatusId=6,intPickListId=NULL Where intPickListId=@intPickListId

Commit Tran

END TRY  
  
BEGIN CATCH  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION      
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')  
  
END CATCH 
