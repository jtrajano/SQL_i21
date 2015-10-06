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
				@ysnReverse						BIT = 0

	SELECT @strReceiptType = strReceiptType, @intSourceType = intSourceType FROM @ItemsFromInventoryReceipt
	IF (@strReceiptType <> 'Purchase Contract' AND @intSourceType <> 2)
		RETURN
	
	SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt
	WHILE ISNULL(@intLotId,0) > 0
	BEGIN
		SELECT	@intSourceId					=	NULL,
				@intContainerId					=	NULL,
				@dblQty							=	NULL

				
		SELECT	@intSourceId					=	intSourceId,
				@intContainerId					=	intContainerId,
				@dblQty							=	dblQty,
				@intLotId						=	intLotId
		FROM	@ItemsFromInventoryReceipt 
		WHERE	intLotId						=	 @intLotId
		
		IF NOT EXISTS(SELECT * FROM tblLGShipmentContractQty WHERE intShipmentContractQtyId = @intSourceId)
		BEGIN
		SELECT 1, @intSourceId, Cast(@intSourceId as varchar(100))
			SET @ErrMsg = 'Contract for this shipment does not exist'
			RAISERROR(@ErrMsg,16,1)
		END

		IF NOT EXISTS(SELECT * FROM tblLGShipmentBLContainerContract WHERE intShipmentContractQtyId = @intSourceId AND intShipmentBLContainerId = @intContainerId)
		BEGIN		
			SET @ErrMsg = 'Container for this shipment does not exist'
			RAISERROR(@ErrMsg,16,1)
		END
		
		SELECT @dblContractQty = IsNull(dblReceivedQty, 0) FROM tblLGShipmentContractQty WHERE intShipmentContractQtyId = @intSourceId
		SELECT @dblContainerQty = IsNull(dblReceivedQty, 0) FROM tblLGShipmentBLContainerContract WHERE intShipmentContractQtyId = @intSourceId AND intShipmentBLContainerId = @intContainerId		
		
		IF (@dblContractQty + @dblQty) < 0
		BEGIN		
			SET @ErrMsg = 'Negative contract quantity is not allowed'
			RAISERROR(@ErrMsg,16,1)
		END
		
		IF (@dblContainerQty + @dblQty) < 0
		BEGIN		
			SET @ErrMsg = 'Negative container quantity is not allowed'
			RAISERROR(@ErrMsg,16,1)
		END

		UPDATE tblLGShipmentContractQty 		SET dblReceivedQty = (@dblContractQty + @dblQty) WHERE intShipmentContractQtyId = @intSourceId
		UPDATE tblLGShipmentBLContainerContract SET dblReceivedQty = (@dblContainerQty + @dblQty) WHERE intShipmentContractQtyId = @intSourceId AND intShipmentBLContainerId = @intContainerId
		
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
		SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt WHERE intLotId > @intLotId
	END
	SELECT TOP(1) @intShipmentId = intShipmentId FROM tblLGShipmentContractQty WHERE intShipmentContractQtyId = @intSourceId
	SELECT @ysnInventorize = ysnInventorized FROM tblLGShipment WHERE intShipmentId = @intShipmentId
	IF (@ysnReverse = 0) AND (@ysnInventorize != 1)
	BEGIN
		UPDATE tblLGShipment SET ysnInventorized = 1, dtmInventorizedDate=GETDATE() WHERE intShipmentId=@intShipmentId		
	END
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGReceived - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH
