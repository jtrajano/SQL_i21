CREATE PROCEDURE [uspMFSetLotExpiryDate]
 @intLotId INT,       
 @dtmNewExpiryDate DATETIME,  
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
	DECLARE @dtmLotExpiryDate DATETIME
	DECLARE @dtmLotCreateDate DATETIME
	
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @dtmLotExpiryDate = dtmExpiryDate,
		   @dtmLotCreateDate = dtmDateCreated
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dtmDate = GETDATE()
	
	SELECT @intSourceId = 1,@intSourceTransactionTypeId= 8
	
	IF ISNULL(@strLotNumber,'') = ''
	BEGIN
		RAISERROR(51178,11,1)
	END
	
	IF @dtmLotExpiryDate = @dtmNewExpiryDate
	BEGIN
		RAISERROR(51180,11,1)
	END
	
	IF @dtmLotCreateDate > @dtmNewExpiryDate
	BEGIN
		RAISError(51179,11,1)
	END
	

	EXEC uspICInventoryAdjustment_CreatePostExpiryDateChange @intItemId,
															 @dtmDate,
															 @intLocationId,
															 @intSubLocationId,
															 @intStorageLocationId,
															 @strLotNumber,
															 @dtmNewExpiryDate,
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