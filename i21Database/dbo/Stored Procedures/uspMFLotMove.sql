CREATE PROCEDURE [uspMFLotMove]
				 @intLotId INT,       
				 @intNewSubLocationId INT,  
				 @intNewStorageLocationId INT,  
				 @dblMoveQty NUMERIC(16,8),
				 @intUserId INT

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
	DECLARE @intNewLocationId INT
	DECLARE @strNewLotNumber NVARCHAR(50)
	
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId,
		   @intNewLocationId = intLocationId
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @strNewLotNumber=@strLotNumber
	SELECT @dtmDate = GETDATE()
	
	SELECT @intSourceId = 1,@intSourceTransactionTypeId= 8
	
	IF ISNULL(@strLotNumber,'') = ''
	BEGIN
		RAISERROR(51178,11,1)
	END
	
	IF @intNewStorageLocationId = @intStorageLocationId
	BEGIN
		RAISERROR(51182,11,1)
	END

	EXEC uspICInventoryAdjustment_CreatePostLotMove @intItemId,
													@dtmDate,
													@intLocationId,
													@intSubLocationId,
													@intStorageLocationId,
													@strLotNumber,
													@intNewLocationId,
													@intNewSubLocationId,
													@intNewStorageLocationId,
													@strNewLotNumber,
													@dblMoveQty,
													@intSourceId,
													@intSourceTransactionTypeId,
													@intUserId,
													@intInventoryAdjustmentId

END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @TransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 