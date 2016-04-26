CREATE PROCEDURE uspWHLotMerge
 @intLotId INT,     
 @intNewLotId INT,  
 @dblMergeQty NUMERIC(38,20),
 @intUserId INT,
 @blnValidateLotReservation BIT = 0
 ,@intItemUOMId int =NULL

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
			,@dblOldDestinationQty NUMERIC(38,20)
			,@dblOldSourceQty NUMERIC(38,20)

	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId,
		   @intNewLocationId = intLocationId,
		   @dblLotWeightPerUnit = dblWeightPerQty,
		   @intWeightUOMId = intWeightUOMId,
		   @dblWeight = dblWeight,
		   @dblOldSourceQty=dblQty,
		   @intItemUOMId=CASE WHEN @intItemUOMId IS NULL THEN intItemUOMId ELSE @intItemUOMId END
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

	SELECT @dblAdjustByQuantity = - @dblMergeQty
	
	SELECT @intNewLocationId = intLocationId ,
		   @intNewSubLocationId = intSubLocationId ,	
		   @intNewStorageLocationId = intStorageLocationId,
		   @intNewItemUOMId = intItemUOMId,
		   @strNewLotNumber = strLotNumber,
		   @intNewLotStatusId = intLotStatusId,
		   @dblNewLotWeightPerUnit = dblWeightPerQty,
		   @dblOldDestinationQty=dblQty
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
													 @intItemUOMId=@intItemUOMId,
													 @dblNewSplitLotQuantity = NULL,
													 @dblNewWeight = NULL,
													 @intNewItemUOMId = @intNewItemUOMId,
													 @intNewWeightUOMId = NULL,
													 @dblNewUnitCost = NULL,
													 @intSourceId = @intSourceId,
													 @intSourceTransactionTypeId = @intSourceTransactionTypeId,
													 @intEntityUserSecurityId = @intUserId,
													 @intInventoryAdjustmentId = @intInventoryAdjustmentId OUTPUT
	--IF @dblOldDestinationQty IS NULL
	--SELECT @dblOldDestinationQty=0

	--IF @dblOldSourceQty IS NULL
	--SELECT @dblOldSourceQty=0

	--UPDATE dbo.tblICLot
	--SET dblWeightPerQty = @dblLotWeightPerUnit,
	--	dblWeight = (@dblOldSourceQty-@dblMergeQty)*@dblLotWeightPerUnit,
	--	dblQty = (@dblOldSourceQty-@dblMergeQty)
	--WHERE intLotId=@intLotId

	--UPDATE dbo.tblICLot
	--SET dblWeightPerQty = @dblNewLotWeightPerUnit,
	--	dblWeight = (@dblOldDestinationQty+@dblMergeQty)*@dblNewLotWeightPerUnit,
	--	dblQty = (@dblOldDestinationQty+@dblMergeQty)
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

	IF ((SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01) AND ((SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01)
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