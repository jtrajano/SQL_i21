CREATE PROCEDURE [uspMFLotAdjustQty]
 @intLotId INT,       
 @dblNewLotQty numeric(38,20),
 @intUserId INT ,
 @strReasonCode NVARCHAR(1000),
 @strNotes NVARCHAR(MAX)=NULL,
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
	DECLARE @dblLotQty NUMERIC(38,20)
	DECLARE @dblAdjustByQuantity NUMERIC(38,20)
	DECLARE @dblNewUnitCost NUMERIC(38,20)
	
	DECLARE @intInventoryAdjustmentId INT
	DECLARE @TransactionCount INT
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @dblWeightPerQty NUMERIC(38, 20)
	DECLARE @intWeightUOMId INT
	DECLARE @intItemStockUOMId INT
	DECLARE @dblWeight NUMERIC(38, 20)
	DECLARE @dblLotReservedQty NUMERIC(38, 20)
	DECLARE @dblLotAvailableQty NUMERIC(38,20)
	
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @dblLotQty = dblQty,
		   @dblWeight=dblWeight,
		   @dblWeightPerQty = dblWeightPerQty,
		   @intWeightUOMId = intWeightUOMId
	FROM tblICLot WHERE intLotId = @intLotId
	
	SELECT @dblLotAvailableQty = (CASE 
		WHEN ISNULL(@dblWeight, 0) = 0
			THEN ISNULL(@dblLotQty, 0)
		ELSE ISNULL(@dblWeight, 0)
		END)

	SELECT @dblAdjustByQuantity = @dblNewLotQty - @dblLotAvailableQty

	SELECT @intItemStockUOMId = intItemUOMId
	FROM dbo.tblICItemUOM
	WHERE intItemId = @intItemId
		AND ysnStockUnit = 1

	SELECT @dblLotReservedQty = ISNULL(SUM(dblQty),0) FROM tblICStockReservation WHERE intLotId = @intLotId 

	IF @blnValidateLotReservation = 1 
	BEGIN
		IF (@dblLotAvailableQty + @dblAdjustByQuantity) < @dblLotReservedQty
		BEGIN
			RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
		END
	END

	--IF @intItemStockUOMId = @intWeightUOMId
	IF @dblWeightPerQty > 0 
	BEGIN
		SELECT @dblAdjustByQuantity = dbo.fnDivide(@dblAdjustByQuantity, @dblWeightPerQty)
	END

	IF @dblNewLotQty=0
	BEGIN
		Select @dblAdjustByQuantity=-@dblLotQty
	END

	SELECT @dtmDate = GETDATE()
	
	SELECT @intSourceId = 1,@intSourceTransactionTypeId= 8
	
	IF ISNULL(@strLotNumber,'') = ''
	BEGIN
		RAISERROR(51192,11,1)
	END
	
	IF @dblLotQty = @dblNewLotQty
	BEGIN
		RAISERROR(51190,11,1)
	END
	
	IF @strReasonCode IS NULL OR @strReasonCode=''  
	BEGIN                  
		RAISERROR(51191,16,1)                           
	END  

	EXEC uspICInventoryAdjustment_CreatePostQtyChange @intItemId,
													  @dtmDate,
													  @intLocationId,
													  @intSubLocationId,
													  @intStorageLocationId,
													  @strLotNumber,
													  @dblAdjustByQuantity,
													  @dblNewUnitCost,
													  @intSourceId,
													  @intSourceTransactionTypeId,
													  @intUserId,
													  @intInventoryAdjustmentId OUTPUT



	
	UPDATE tblICLot
	SET dblWeight = dblQty
	WHERE dblQty <> dblWeight
		AND intItemUOMId = intWeightUOMId
	and intLotId=@intLotId

	IF ((SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblWeight FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0) OR ((SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) < 0.01 AND (SELECT dblQty FROM dbo.tblICLot WHERE intLotId = @intLotId) > 0)
	BEGIN
		--EXEC dbo.uspMFLotAdjustQty
		-- @intLotId =@intLotId,       
		-- @dblNewLotQty =0,
		-- @intUserId=@intUserId ,
		-- @strReasonCode ='Residue qty clean up',
		-- @strNotes ='Residue qty clean up'
		UPDATE tblICLot
		SET dblWeight = 0
			,dblQty = 0
		WHERE intLotId = @intLotId
	END
END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @TransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @ErrMsg = ERROR_MESSAGE()      
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH 