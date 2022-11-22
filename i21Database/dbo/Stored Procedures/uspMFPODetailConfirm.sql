CREATE PROCEDURE uspMFPODetailConfirm 
(
	@intPurchaseId		  INT
  , @intPurchaseDetailId  INT
  , @intItemId			  INT
  , @dblQuantity		  NUMERIC(18, 6)
  , @intItemUOMId		  INT
  , @intStorageLocationId INT
  , @intSubLocationId	  INT
  , @intUserId			  INT
  , @intLocationId		  INT
)
AS
BEGIN

IF NOT EXISTS (SELECT * FROM dbo.tblMFPODetail WHERE intPurchaseDetailId = @intPurchaseDetailId)
	BEGIN
		INSERT INTO dbo.tblMFPODetail 
		(
			intPurchaseId
		  , intPurchaseDetailId
		  , intItemId
		  , dblQuantity
		  , intItemUOMId
		  , intStorageLocationId
		  , intSubLocationId
		  , intUserId
		  , ysnProcessed
		  , intLocationId
		)
		SELECT @intPurchaseId 
			 , @intPurchaseDetailId
			 , @intItemId
			 , @dblQuantity
			 , @intItemUOMId
			 , (CASE WHEN @intStorageLocationId = 0 THEN NULL ELSE @intStorageLocationId END)
			 , (CASE WHEN @intSubLocationId = 0 THEN NULL ELSE @intSubLocationId END)
			 , @intUserId
			 , 0 AS ysnProcessed
			 , @intLocationId
	END
ELSE
	BEGIN
		UPDATE tblMFPODetail
		SET dblQuantity = dblQuantity + @dblQuantity
		WHERE intPurchaseDetailId = @intPurchaseDetailId;
	END
END