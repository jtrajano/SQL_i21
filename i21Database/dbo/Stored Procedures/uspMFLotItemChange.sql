CREATE PROCEDURE uspMFLotItemChange
 @intLotId INT,
 @intNewItemId INT,
 @intUserId INT,
 @strNewLotNumber NVARCHAR(100) = NULL OUTPUT

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
			,@intUnitMeasureId int
			,@strUnitMeasure nvarchar(50)
			,@strItemNo nvarchar(50)

	DECLARE @dblAdjustByQuantity NUMERIC(16,8)
	DECLARE @dblLotReservedQty NUMERIC(16,8)
		
	SELECT @intItemId = intItemId, 
		   @intLocationId = intLocationId,
		   @intSubLocationId = intSubLocationId,
		   @intStorageLocationId = intStorageLocationId, 
		   @strLotNumber = strLotNumber,
		   @intItemUOMId = intItemUOMId,
		   @dblAdjustByQuantity=-dblQty,
		   @intAdjustItemUOMId= intItemUOMId  
	FROM tblICLot WHERE intLotId = @intLotId

	SELECT @dblLotReservedQty = dblQty  FROM tblICStockReservation WHERE intLotId = @intLotId AND ISNULL(ysnPosted,0)=0
	IF (ISNULL(@dblLotReservedQty,0) > 0)
	BEGIN
		RAISERROR('There is reservation against this lot. Cannot proceed.',16,1)
	END
	
	SELECT @intUnitMeasureId=intUnitMeasureId FROM tblICItemUOM WHERE intItemUOMId=@intItemUOMId

	IF NOT EXISTS(SELECT *FROM dbo.tblICItemUOM WHERE intItemId=@intNewItemId AND intUnitMeasureId=@intUnitMeasureId)
	BEGIN
		SELECT @strUnitMeasure =strUnitMeasure 
		FROM dbo.tblICUnitMeasure 
		WHERE intUnitMeasureId =@intUnitMeasureId 

		SELECT @strItemNo=strItemNo
		FROM dbo.tblICItem
		WHERE intItemId=@intNewItemId

		RAISERROR(90016
				,11
				,1
				,@strUnitMeasure
				,@strItemNo)
	END
	
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

	SELECT TOP 1 @strNewLotNumber = strLotNumber
	FROM tblICLot
	WHERE intSplitFromLotId = @intLotId
	ORDER BY intLotId DESC

	SELECT @strNewLotNumber AS strNewLotNumber
													 
END TRY  
  
BEGIN CATCH  
  
 IF XACT_STATE() != 0 AND @intTransactionCount = 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION  
 SET @strErrMsg = ERROR_MESSAGE()      
 RAISERROR(@strErrMsg, 16, 1, 'WITH NOWAIT')     
  
END CATCH