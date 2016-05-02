CREATE PROCEDURE uspMFLotItemChange
 @intLotId INT,
 @intNewItemId INT,
 @intUserId INT

AS

BEGIN TRY

	DECLARE @intItemId INT
	DECLARE @dtmDate DATETIME
	DECLARE @intLocationId INT
	DECLARE @intStorageLocationId INT
	DECLARE @intSubLocationId INT
	DECLARE @strLotNumber NVARCHAR(50)
	DECLARE @intSourceId INT
	DECLARE @intSourceTransactionTypeId INT
	DECLARE @intLotStatusId INT
	DECLARE @intItemUOMId INT
	DECLARE @dblLotWeightPerUnit NUMERIC(38,20) 
	DECLARE @dblLotQty NUMERIC(38,20)
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @intTransactionCount INT
	DECLARE @strErrMsg NVARCHAR(MAX)
			,@intAdjustItemUOMId int

	DECLARE @dblAdjustByQuantity NUMERIC(16,8)
		
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intItemUOMId = intItemUOMId,
		   @dblAdjustByQuantity=CASE WHEN intWeightUOMId IS NULL THEN -dblQty ELSE -dblWeight END,
		   @intAdjustItemUOMId= CASE WHEN intWeightUOMId IS NULL THEN intItemUOMId ELSE intWeightUOMId End    
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dtmDate = GETDATE(), 
		   @intSourceId = 1,
		   @intSourceTransactionTypeId= 8
	
	EXEC uspICInventoryAdjustment_CreatePostItemChange @intItemId = @intItemId
													   ,@dtmDate = @dtmDate
													   ,@intLocationId = @intLocationId
													   ,@intSubLocationId = @intSubLocationId
													   ,@intStorageLocationId = @intStorageLocationId
													   ,@strLotNumber = @strLotNumber
													   ,@dblAdjustByQuantity = @dblAdjustByQuantity
													   ,@intNewItemId = @intNewItemId
													   ,@intNewSubLocationId = @intSubLocationId
													   ,@intNewStorageLocationId = @intStorageLocationId
													   ,@intItemUOMId=@intAdjustItemUOMId
													   ,@intSourceId = @intSourceId
													   ,@intSourceTransactionTypeId = @intSourceTransactionTypeId
													   ,@intEntityUserSecurityId  = @intUserId
													   ,@intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
													 
END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @intTransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @strErrMsg = ERROR_MESSAGE()      
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH