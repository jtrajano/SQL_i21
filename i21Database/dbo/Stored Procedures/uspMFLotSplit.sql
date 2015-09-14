CREATE PROCEDURE [uspMFLotSplit]
 @intLotId INT,       
 @strNewLotNumber NVARCHAR(100),    
 @intSplitSubLocationId INT,  
 @intSplitStorageLocationId INT,  
 @dblSplitQty NUMERIC(16,8),  
 @intUserId INT,
 @strNote NVARCHAR(1024) = NULL

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
	DECLARE @intItemUOMId INT
		
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intNewLocationId INT
	DECLARE @intNewSubLocationId INT
	DECLARE @intNewStorageLocationId INT	
	DECLARE @intNewItemUOMId INT
	DECLARE @dblAdjustByQuantity NUMERIC(16,8)
	
	SELECT @intNewLocationId = intCompanyLocationId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSplitSubLocationId
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId,
		   @intItemUOMId = intItemUOMId	   
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dblAdjustByQuantity = - @dblSplitQty, 
		   @intNewItemUOMId = @intItemUOMId, 
		   @dtmDate = GETDATE(), 
		   @intSourceId = 1,
		   @intSourceTransactionTypeId= 8
	
	IF ISNULL(@strLotNumber,'') = ''
	BEGIN
		RAISERROR(51192,11,1)
	END
							 
	EXEC uspICInventoryAdjustment_CreatePostSplitLot @intItemId	= @intItemId,
													 @dtmDate =	@dtmDate,
													 @intLocationId	= @intLocationId,
													 @intSubLocationId = @intSubLocationId,
													 @intStorageLocationId = @intStorageLocationId,
													 @strLotNumber = @strLotNumber,
													 @intNewLocationId = @intNewLocationId,
													 @intNewSubLocationId = @intSplitSubLocationId,
													 @intNewStorageLocationId = @intSplitStorageLocationId,
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