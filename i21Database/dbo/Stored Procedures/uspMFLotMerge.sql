CREATE PROCEDURE [uspMFLotMerge] 
 @intLotId INT,     
 @intNewLotId INT,  
 @dblMergeQty NUMERIC(38,20),
 @intMergeItemUOMId int,
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
	DECLARE @intSourceLotWeightUOM INT
	DECLARE @intDestinationLotWeightUOM INT
	DECLARE @dblAdjustByQuantity NUMERIC(38,20)
	DECLARE @intWeightUOMId INT
	DECLARE @dblLotReservedQty NUMERIC(38, 20)
	DECLARE @dblWeight NUMERIC(38,20)
			,@dblOldDestinationWeight NUMERIC(38,20)
			,@dblOldSourceWeight NUMERIC(38,20)
			,@dblMergeWeight NUMERIC(38,20)
			,@strStorageLocationName NVARCHAR(50)
			,@strItemNumber NVARCHAR(50)
			,@strUnitMeasure NVARCHAR(50)
			,@intItemUOMId int

	SELECT @dblMergeWeight = @dblMergeQty

	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intLotStatusId = intLotStatusId,
		   @intNewLocationId = intLocationId,
		   @dblLotWeightPerUnit = dblWeightPerQty,
		   @intWeightUOMId = intWeightUOMId,
		   @intSourceLotWeightUOM = intWeightUOMId,
		   @dblWeight = dblWeight,
		   @dblOldSourceWeight=Case When intWeightUOMId is null Then dblQty Else dblWeight End,
		   @intItemUOMId=intItemUOMId
		FROM tblICLot WHERE intLotId = @intLotId

	--SELECT @intItemStockUOMId = intItemUOMId
	--FROM dbo.tblICItemUOM
	--WHERE intItemId = @intItemId
	--	AND ysnStockUnit = 1

	IF (CASE WHEN @intItemUOMId=@intMergeItemUOMId AND @intWeightUOMId IS NOT NULL THEN -@dblMergeQty*@dblLotWeightPerUnit ELSE -@dblMergeQty END)>@dblOldSourceWeight
	BEGIN
		SELECT @strStorageLocationName = strName FROM tblICStorageLocation WHERE intStorageLocationId = @intStorageLocationId
		SELECT @strItemNumber = strItemNo FROM tblICItem WHERE intItemId = @intItemId
		
		SELECT @strUnitMeasure = UM.strUnitMeasure
		FROM tblICItemUOM U 
		JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = U.intUnitMeasureId
		WHERE U.intItemUOMId = IsNULL(@intWeightUOMId,@intItemUOMId)

		SET @ErrMsg = 'Merge qty '+ LTRIM(CONVERT(NUMERIC(38,4), @dblMergeQty)) + ' ' + @strUnitMeasure + ' is not available for lot ''' + @strLotNumber + ''' having item '''+ @strItemNumber + ''' in location ''' + @strStorageLocationName + '''.'
		RAISERROR (@ErrMsg,11,1)
	END
	
	SELECT @dblLotReservedQty = SUM(dbo.fnMFConvertQuantityToTargetItemUOM(intItemUOMId,ISNULL(@intWeightUOMId,@intItemUOMId),ISNULL(dblQty,0))) FROM tblICStockReservation WHERE intLotId = @intLotId AND ISNULL(ysnPosted,0)=0
	
	IF @blnValidateLotReservation = 1
	BEGIN
		IF (@dblOldSourceWeight + (CASE WHEN @intItemUOMId=@intMergeItemUOMId AND @intWeightUOMId IS NOT NULL THEN -@dblMergeQty*@dblLotWeightPerUnit ELSE -@dblMergeQty END)) < @dblLotReservedQty
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
		   @intDestinationLotWeightUOM = intWeightUOMId,
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

	IF EXISTS (SELECT 1 FROM tblWHSKU WHERE intLotId = @intLotId)
	BEGIN
		RAISERROR(90008,11,1)
	END
	
	IF @intDestinationLotWeightUOM <> @intSourceLotWeightUOM
	BEGIN
		RAISERROR(90009,11,1)
	END												 

	--IF ROUND(@dblNewLotWeightPerUnit,3) <> ROUND(@dblLotWeightPerUnit,3)
	--BEGIN
	--	RAISERROR(51196,11,1)
	--END

	--IF @dblOldDestinationWeight IS NULL
	--SELECT @dblOldDestinationWeight=0

	--IF @dblOldSourceWeight IS NULL
	--SELECT @dblOldSourceWeight=0

	BEGIN TRANSACTION
													 
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
													 @intItemUOMId=@intMergeItemUOMId,
													 @dblNewSplitLotQuantity = NULL,
													 @dblNewWeight = NULL,
													 @intNewItemUOMId = NULL,
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
		--UPDATE tblICLot
		--SET dblWeight = 0
		--	,dblQty = 0
		--WHERE intLotId = @intLotId
	END
	COMMIT TRANSACTION
END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 