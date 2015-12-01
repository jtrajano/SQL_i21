CREATE PROCEDURE [uspMFLotSplit]
 @intLotId INT,       
 @intSplitSubLocationId INT,  
 @intSplitStorageLocationId INT,  
 @dblSplitQty NUMERIC(16,8),  
 @intUserId INT,
 @strSplitLotNumber NVARCHAR(100)=NULL OUTPUT,
 @strNewLotNumber NVARCHAR(100) = NULL,    
 @strNote NVARCHAR(1024) = NULL,
 @intInventoryAdjustmentId int=NULL OUTPUT

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
		
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intNewLocationId INT
	DECLARE @intNewSubLocationId INT
	DECLARE @intNewStorageLocationId INT	
	DECLARE @intNewItemUOMId INT
	DECLARE @dblAdjustByQuantity NUMERIC(16,8)
	DECLARE @strLotTracking NVARCHAR(50)
	
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
	
	SELECT @strLotTracking = strLotTracking
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF (@strNewLotNumber = '' OR @strNewLotNumber IS NULL) 
	BEGIN 
		IF (@strLotTracking = 'Yes - Serial Number')
		BEGIN
			EXEC dbo.uspSMGetStartingNumber 24, @strNewLotNumber OUTPUT
		END
		ELSE 
		BEGIN
			RAISERROR('Lot tracking for the item is set as manual. Please supply the split lot number.',11,1)
		END
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
													 @intEntityUserSecurityId = @intUserId,
													 @intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	
	SELECT @strSplitLotNumber = strLotNumber FROM tblICLot WHERE intSplitFromLotId = @intLotId
	SELECT @strSplitLotNumber AS strSplitLotNumber
													 
END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @TransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 