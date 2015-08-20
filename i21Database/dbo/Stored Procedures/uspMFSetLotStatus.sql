CREATE PROCEDURE [uspMFSetLotStatus]
 @intLotId INT,       
 @intNewLotStatusId INT,  
 @intUserId INT ,
 @strNotes NVARCHAR(MAX)=NULL

AS

BEGIN TRY

	DECLARE @intItemId INT
	DECLARE @dtmDate DATETIME
	DECLARE @intLocationId INT
	DECLARE @intSubLocationId INT 
	DECLARE @intStorageLocationId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intSourceId INT
	DECLARE @intSourceTransactionTypeId INT
	DECLARE @intLotStatusId INT
	
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dtmDate = GETDATE()
	
	SELECT @intSourceId = 1,@intSourceTransactionTypeId= 8
	
	IF ISNULL(@strLotNumber,'') = ''
	BEGIN
		RAISERROR(51178,16,1)
	END
	
	IF @intLotStatusId = @intNewLotStatusId
	BEGIN
		RAISERROR(51181,16,1)
	END
	

	EXEC uspICInventoryAdjustment_CreatePostLotStatusChange @intItemId,
															@dtmDate,
															@intLocationId,
															@intSubLocationId,
															@intStorageLocationId,
															@strLotNumber,
															@intNewLotStatusId,
															@intSourceId,
															@intSourceTransactionTypeId,
															@intUserId,
															@intInventoryAdjustmentId OUTPUT

END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @TransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 