CREATE PROCEDURE [uspMFLotMerge] 
 @intLotId INT,     
 @intNewLotId INT,  
 @dblMergeQty NUMERIC(16,8),
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
	DECLARE @dblLotWeightPerUnit NUMERIC(16,8)
		
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intNewLocationId INT
	DECLARE @intNewSubLocationId INT
	DECLARE @intNewStorageLocationId INT	
	DECLARE @intNewItemUOMId INT
	DECLARE @intNewLotStatusId INT
	DECLARE @dblNewLotWeightPerUnit NUMERIC(16,8)
	DECLARE @strNewLotNumber NVARCHAR(100)
	DECLARE @dblAdjustByQuantity NUMERIC(16,8)
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId,
		   @intNewLocationId = intLocationId,
		   @dblLotWeightPerUnit = dblWeightPerQty
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dblAdjustByQuantity = - @dblMergeQty
	
	SELECT @intNewLocationId = intLocationId ,
		   @intNewSubLocationId = intSubLocationId ,	
		   @intNewStorageLocationId = intStorageLocationId,
		   @intNewItemUOMId = intItemUOMId,
		   @strNewLotNumber = strLotNumber,
		   @intNewLotStatusId = intLotStatusId,
		   @dblNewLotWeightPerUnit = dblWeightPerQty
	FROM tblICLot WHERE intLotId = @intNewLotId
		   
	SELECT @dtmDate = GETDATE()
	
	SELECT @intSourceId = 1,@intSourceTransactionTypeId= 8
	
	IF ISNULL(@strLotNumber,'') = ''
	BEGIN
		RAISERROR(51192,11,1)
	END

	IF @intNewLotStatusId <> @intLotStatusId
	BEGIN
		RAISERROR(51195,11,1)
	END

	IF @dblNewLotWeightPerUnit <> @dblLotWeightPerUnit
	BEGIN
		RAISERROR(51196,11,1)
	END
													 
	EXEC uspICInventoryAdjustment_CreatePostLotMerge @intItemId	= @intItemId,
													 @dtmDate =	@dtmDate,
													 @intLocationId	= @intLocationId,
													 @intSubLocationId = @intSubLocationId,
													 @intStorageLocationId = @intStorageLocationId,
													 @strLotNumber = @strLotNumber,
													 @intNewLocationId = @intNewLocationId,
													 @intNewSubLocationId = @intNewSubLocationId,
													 @intNewStorageLocationId = @intNewStorageLocationId,
													 @strNewLotNumber = @strNewLotNumber,
													 @dblAdjustByQuantity = @dblAdjustByQuantity,
													 @dblNewSplitLotQuantity = NULL,
													 @dblNewWeight = NULL,
													 @intNewItemUOMId = @intNewItemUOMId,
													 @intNewWeightUOMId = NULL,
													 @dblNewUnitCost = NULL,
													 @intSourceId = @intSourceId,
													 @intSourceTransactionTypeId = @intSourceTransactionTypeId,
													 @intUserId = @intUserId,
													 @intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT


END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @TransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 