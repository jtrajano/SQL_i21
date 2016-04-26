﻿CREATE PROCEDURE [uspMFLotMerge] 
 @intLotId INT,     
 @intNewLotId INT,  
 @dblMergeQty NUMERIC(38,20),
 @intUserId INT,
 @blnValidateLotReservation BIT = 0

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
	DECLARE @dblLotWeightPerUnit NUMERIC(38,20)
		
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @intNewLocationId INT
	DECLARE @intNewSubLocationId INT
	DECLARE @intNewStorageLocationId INT	
	DECLARE @intNewItemUOMId INT
	DECLARE @intNewLotStatusId INT
	DECLARE @dblNewLotWeightPerUnit NUMERIC(38,20)
	DECLARE @strNewLotNumber NVARCHAR(100)
	DECLARE @dblAdjustByQuantity NUMERIC(38,20)
	DECLARE @intWeightUOMId INT
	DECLARE @intItemStockUOMId INT
	DECLARE @dblLotReservedQty NUMERIC(38, 20)
	DECLARE @dblWeight NUMERIC(38,20)
			,@dblOldDestinationWeight NUMERIC(38,20)
			,@dblOldSourceWeight NUMERIC(38,20)
			,@dblMergeWeight NUMERIC(38,20)

	SELECT @dblMergeWeight = @dblMergeQty

	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId,
		   @intNewLocationId = intLocationId,
		   @dblLotWeightPerUnit = dblWeightPerQty,
		   @intWeightUOMId = IsNull(intWeightUOMId,intItemUOMId),
		   @dblWeight = dblWeight,
		   @dblOldSourceWeight=Case When intWeightUOMId is null Then dblQty Else dblWeight End
	FROM tblICLot WHERE intLotId = @intLotId

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	
	SELECT @dblLotReservedQty = ISNULL(SUM(dblQty),0) FROM tblICStockReservation WHERE intLotId = @intLotId 
	
	IF @blnValidateLotReservation = 1
	BEGIN
		IF (@dblWeight + (-@dblMergeQty)) < @dblLotReservedQty
		BEGIN
			RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
		END
	END

	--IF @dblLotWeightPerUnit > 0 
	--BEGIN
	--	SELECT @dblMergeQty = dbo.fnDivide(@dblMergeQty, @dblLotWeightPerUnit)
	--END

	SELECT @dblAdjustByQuantity = - @dblMergeQty
	
	SELECT @intNewLocationId = intLocationId ,
		   @intNewSubLocationId = intSubLocationId ,	
		   @intNewStorageLocationId = intStorageLocationId,
		   @intNewItemUOMId = intItemUOMId,
		   @strNewLotNumber = strLotNumber,
		   @intNewLotStatusId = intLotStatusId,
		   @dblNewLotWeightPerUnit = dblWeightPerQty,
		   @dblOldDestinationWeight=Case When intWeightUOMId is null Then dblQty Else dblWeight End
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

	--IF ROUND(@dblNewLotWeightPerUnit,3) <> ROUND(@dblLotWeightPerUnit,3)
	--BEGIN
	--	RAISERROR(51196,11,1)
	--END

	--IF @dblOldDestinationWeight IS NULL
	--SELECT @dblOldDestinationWeight=0

	--IF @dblOldSourceWeight IS NULL
	--SELECT @dblOldSourceWeight=0
													 
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
													 @intItemUOMId=@intWeightUOMId,
													 @dblNewSplitLotQuantity = NULL,
													 @dblNewWeight = NULL,
													 @intNewItemUOMId = @intNewItemUOMId,
													 @intNewWeightUOMId = NULL,
													 @dblNewUnitCost = NULL,
													 @intSourceId = @intSourceId,
													 @intSourceTransactionTypeId = @intSourceTransactionTypeId,
													 @intEntityUserSecurityId = @intUserId,
													 @intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	--UPDATE dbo.tblICLot
	--SET dblWeightPerQty = @dblLotWeightPerUnit,
	--	dblWeight = CASE WHEN @dblLotWeightPerUnit = 0 THEN 0 ELSE @dblOldSourceWeight-@dblMergeWeight END,
	--	dblQty = (@dblOldSourceWeight-@dblMergeWeight)/CASE WHEN @dblLotWeightPerUnit = 0 THEN 1 ELSE @dblLotWeightPerUnit END
	--WHERE intLotId=@intLotId

	--UPDATE dbo.tblICLot
	--SET dblWeightPerQty = @dblNewLotWeightPerUnit,
	--	dblWeight = CASE WHEN @dblNewLotWeightPerUnit = 0 THEN 0 ELSE @dblOldDestinationWeight+@dblMergeWeight END,
	--	dblQty = (@dblOldDestinationWeight+@dblMergeWeight)/CASE WHEN @dblNewLotWeightPerUnit = 0 THEN 1 ELSE @dblNewLotWeightPerUnit END
	--WHERE intLotId=@intNewLotId

	IF EXISTS (SELECT 1 FROM tblICLot WHERE dblQty <> dblWeight AND intItemUOMId = intWeightUOMId AND intLotId=@intLotId)
	BEGIN
		DECLARE @dblLotQty NUMERIC(38,20)
		SELECT @dblLotQty = dblQty FROM tblICLot WHERE intLotId = @intLotId

		EXEC dbo.uspMFLotAdjustQty
			@intLotId = @intLotId,       
			@dblNewLotQty = @dblLotQty,
			@intUserId = @intUserId ,
			@strReasonCode = 'Weight qty same',
			@strNotes = 'Weight qty same'
	END

	IF ((SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0) OR ((SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0)
	BEGIN
		EXEC dbo.uspMFLotAdjustQty
		 @intLotId =@intLotId,       
		 @dblNewLotQty =0,
		 @intUserId=@intUserId ,
		 @strReasonCode ='Residue qty clean up',
		 @strNotes ='Residue qty clean up'
		--UPDATE tblICLot
		--SET dblWeight = 0
		--	,dblQty = 0
		--WHERE intLotId = @intLotId
	END

END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @TransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 