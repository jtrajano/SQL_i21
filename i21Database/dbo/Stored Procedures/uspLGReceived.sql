CREATE PROCEDURE [dbo].[uspLGReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	,@intUserId INT 
AS

DECLARE @ItemsToIncreaseInTransitInBound AS InTransitTableType,
        @total as int;

BEGIN TRY

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg							NVARCHAR(MAX),
				@strReceiptType					NVARCHAR(50),
				@intSourceType					INT,
				@intLotId						INT,
				@intSourceId					INT,
				@intContainerId					INT,
				@intShipmentId					INT,
				@dblQty							NUMERIC(18,6),
				@dblContractQty					NUMERIC(18,6),
				@dblContainerQty				NUMERIC(18,6),
				@ysnInventorize					BIT,
				@ysnReverse						BIT = 0,
				@intLoadId						INT,
				@dblNetWeight					NUMERIC(18,6)

	SELECT @strReceiptType = strReceiptType, @intSourceType = intSourceType FROM @ItemsFromInventoryReceipt
	IF (@strReceiptType <> 'Purchase Contract' AND @intSourceType <> 2)
		RETURN
	
	SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt
	WHILE ISNULL(@intLotId,0) > 0
	BEGIN
		SELECT	@intSourceId					=	NULL,
				@intContainerId					=	NULL,
				@dblQty							=	NULL,
				@dblNetWeight					=	NULL
				
		SELECT	@intSourceId					=	intSourceId,
				@intContainerId					=	intContainerId,
				@dblQty							=	dblQty,
				@intLotId						=	intLotId,
				@dblNetWeight					=	dblNetWeight
		FROM	@ItemsFromInventoryReceipt 
		WHERE	intLotId						=	 @intLotId
		
		IF NOT EXISTS(SELECT * FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId)
		BEGIN
		SELECT 1, @intSourceId, Cast(@intSourceId as varchar(100))
			SET @ErrMsg = 'Contract for this shipment does not exist'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF ISNULL(@intContainerId,0) <> -1
		BEGIN
			IF NOT EXISTS(SELECT * FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = @intSourceId AND intLoadContainerId = @intContainerId)
			BEGIN		
				SET @ErrMsg = 'Container for this shipment does not exist'
				RAISERROR(@ErrMsg,16,1)
			END
					
			IF (@dblContainerQty + @dblQty) < 0
			BEGIN		
				SET @ErrMsg = 'Negative container quantity is not allowed'
				RAISERROR(@ErrMsg,16,1)
			END

			SELECT @dblContainerQty = ISNULL(dblReceivedQty,0) 
			FROM tblLGLoadDetailContainerLink 
			WHERE intLoadContainerId = @intContainerId
			
			UPDATE tblLGLoadDetailContainerLink 
			SET dblReceivedQty = (@dblContainerQty + @dblQty)  
			WHERE intLoadDetailId = @intSourceId 
				AND intLoadContainerId = @intContainerId
		END
				
		SELECT @dblContractQty = ISNULL(dblDeliveredQuantity,0) FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId

		IF (@dblContractQty + @dblQty) < 0
		BEGIN		
			SET @ErrMsg = 'Negative contract quantity is not allowed'
			RAISERROR(@ErrMsg,16,1)
		END

		UPDATE tblLGLoadDetail SET dblDeliveredQuantity = (@dblContractQty + @dblQty), dblDeliveredGross = @dblNetWeight, dblDeliveredNet = @dblNetWeight WHERE intLoadDetailId = @intSourceId
	
		SET @ysnReverse = CASE WHEN @dblQty < 0 THEN 1 ELSE 0 END

		INSERT into @ItemsToIncreaseInTransitInBound(
			[intItemId] 
			,[intItemLocationId] 
			,[intItemUOMId] 
			,[intLotId] 
			,[intSubLocationId] 
			,[intStorageLocationId] 
			,[dblQty] 
			,[intTransactionId]
			,[strTransactionId]
			,[intTransactionTypeId] 		 	
		)	
		SELECT 
			SC.intItemId,
			intItemLocationId = (SELECT Top(1) intItemLocationId from tblICItemLocation where intItemId=SC.intItemId),
			CT.intItemUOMId,
			NULL,
			SH.intSubLocationId,
			NULL,
			-@dblQty,
			SH.intShipmentId,
			CAST (SH.intTrackingNumber as VARCHAR(100)),
			22
			FROM tblLGShipmentContractQty SC
			JOIN tblLGShipment SH ON SH.intShipmentId = SC.intShipmentId
			JOIN vyuCTContractDetailView CT ON CT.intContractDetailId = SC.intContractDetailId
			WHERE SC.intShipmentContractQtyId = @intSourceId;
		EXEC dbo.uspICIncreaseInTransitInBoundQty @ItemsToIncreaseInTransitInBound;

		SELECT @intLoadId = intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId

		IF @ysnReverse = 0
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId
		END
		ELSE 
		BEGIN
			IF NOT EXISTS(SELECT 1
						  FROM tblICInventoryReceipt R
						  JOIN tblICInventoryReceiptItem RI ON RI.intInventoryReceiptId = R.intInventoryReceiptId
						  JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = RI.intSourceId
						  WHERE R.ysnPosted = 1 AND LD.intLoadId = @intLoadId)
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 3 WHERE intLoadId = @intLoadId
				UPDATE tblLGLoadDetail SET dblDeliveredGross = dblDeliveredGross-@dblNetWeight, dblDeliveredNet = dblDeliveredGross-@dblNetWeight WHERE intLoadDetailId = @intSourceId
			END
		END

		SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt WHERE intLotId > @intLotId
	END
	
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGReceived - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH