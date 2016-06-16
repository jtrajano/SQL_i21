CREATE PROCEDURE [uspMFLotSplit]
 @intLotId INT,       
 @intSplitSubLocationId INT,  
 @intSplitStorageLocationId INT,  
 @dblSplitQty NUMERIC(38,20),  
 @intSplitItemUOMId int,
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
	DECLARE @dblAdjustByQuantity NUMERIC(38,20)
	DECLARE @strLotTracking NVARCHAR(50)
			,@intCategoryId int
	DECLARE @dblWeightPerQty NUMERIC(38, 20)
	DECLARE @intWeightUOMId INT
	
	DECLARE @dblLotReservedQty NUMERIC(38, 20)
	DECLARE @dblWeight NUMERIC(38,20)
	DECLARE @dblLotQty NUMERIC(38,20)
	DECLARE @dblLotAvailableQty NUMERIC(38,20)
			,@dblOldDestinationWeight NUMERIC(38,20)
			,@dblOldSourceWeight NUMERIC(38,20)
	
	SELECT @intNewLocationId = intCompanyLocationId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSplitSubLocationId
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @dblLotQty = dblQty,
		   @intLotStatusId = intLotStatusId,
		   @intItemUOMId = intItemUOMId,	 
		   @dblWeightPerQty = dblWeightPerQty,
		   @intWeightUOMId = intWeightUOMId,
		   @dblWeight = dblWeight,
		   @dblOldSourceWeight=Case When intWeightUOMId is null Then dblQty Else dblWeight End
	FROM tblICLot WHERE intLotId = @intLotId

	SELECT @dblLotAvailableQty = (CASE 
		WHEN ISNULL(@dblWeight, 0) = 0
			THEN ISNULL(@dblLotQty, 0)
		ELSE ISNULL(@dblWeight, 0)
		END)

	SELECT @dblAdjustByQuantity = - @dblSplitQty, 
		   @intNewItemUOMId = @intItemUOMId, 
		   @dtmDate = GETDATE(), 
		   @intSourceId = 1,
		   @intSourceTransactionTypeId= 8
	
	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId,ISNULL(@intWeightUOMId,@intItemUOMId),ISNULL(dblQty,0))) FROM tblICStockReservation WHERE intLotId = @intLotId AND ISNULL(ysnPosted,0)=0
	
	IF (@dblLotAvailableQty + (CASE WHEN @intItemUOMId=@intSplitItemUOMId AND @intWeightUOMId IS NOT NULL THEN @dblAdjustByQuantity*@dblWeightPerQty ELSE @dblAdjustByQuantity END)) < @dblLotReservedQty
	BEGIN
		RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
	END

	SELECT @strLotTracking = strLotTracking
			,@intCategoryId=intCategoryId
	FROM dbo.tblICItem
	WHERE intItemId = @intItemId

	IF(ISNULL(@strNewLotNumber,'') <> '')
	BEGIN
		IF EXISTS(SELECT 1 FROM tblICLot WHERE strLotNumber = @strNewLotNumber AND intItemId <> @intItemId)
		BEGIN
			RAISERROR('Supplied lot number already exists for a lot with a different item. Please provide a different lot number to continue.',11,1)
		END
	END

	IF (@strNewLotNumber = '' OR @strNewLotNumber IS NULL) 
	BEGIN 
		IF (@strLotTracking = 'Yes - Serial Number')
		BEGIN
			SET @strNewLotNumber = 'Split Lot Serial Number'
		END
		ELSE 
		BEGIN
			RAISERROR('Lot tracking for the item is set as manual. Please supply the split lot number.',11,1)
		END
	END
	
	IF EXISTS (SELECT 1 FROM tblWHSKU WHERE intLotId = @intLotId)
	BEGIN
		RAISERROR(90008,11,1)
	END

	BEGIN TRANSACTION
									 
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
													 @intItemUOMId=@intSplitItemUOMId,
													 @dblNewSplitLotQuantity = NULL,
													 @dblNewWeight = NULL,
													 @intNewItemUOMId = NULL,
													 @intNewWeightUOMId = NULL,
													 @dblNewUnitCost = NULL,
													 @intSourceId = @intSourceId,
													 @intSourceTransactionTypeId = @intSourceTransactionTypeId,
													 @intEntityUserSecurityId = @intUserId,
													 @intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	
	SELECT @strSplitLotNumber = strLotNumber FROM tblICLot WHERE intSplitFromLotId = @intLotId
	SELECT @strSplitLotNumber AS strSplitLotNumber

	IF EXISTS (SELECT 1 FROM tblICLot WHERE dblQty <> dblWeight AND intItemUOMId = intWeightUOMId AND intLotId=@intLotId)
	BEGIN
		EXEC dbo.uspMFLotAdjustQty
			@intLotId = @intLotId,       
			@dblNewLotQty = @dblLotQty,
			@intAdjustItemUOMId=@intItemUOMId,
			@intUserId = @intUserId ,
			@strReasonCode = 'Weight qty same',
			@strNotes = 'Weight qty same'
	END

	IF ((SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.00001 AND (SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0) OR ((SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.00001 AND (SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0)
	BEGIN
		EXEC dbo.uspMFLotAdjustQty
		 @intLotId =@intLotId,       
		 @dblNewLotQty =0,
		 @intAdjustItemUOMId=@intItemUOMId,
		 @intUserId=@intUserId ,
		 @strReasonCode ='Residue qty clean up',
		 @strNotes ='Residue qty clean up'
	END
COMMIT TRANSACTION													 
END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 