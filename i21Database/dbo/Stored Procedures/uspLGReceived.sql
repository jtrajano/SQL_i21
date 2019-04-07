﻿CREATE PROCEDURE [dbo].[uspLGReceived]
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
				@dblNetWeight					=	NULL,
				@dblContainerQty				=	NULL
				
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

			SELECT @dblContainerQty = ISNULL(dblReceivedQty,0) 
			FROM tblLGLoadDetailContainerLink 
			WHERE intLoadContainerId = @intContainerId 
				AND intLoadDetailId = @intSourceId

			IF (@dblContainerQty + @dblQty) < 0
			BEGIN		
				SET @ErrMsg = 'Negative container quantity is not allowed'
				RAISERROR(@ErrMsg,16,1)
			END
						
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

		--INSERT into @ItemsToIncreaseInTransitInBound(
		--	[intItemId] 
		--	,[intItemLocationId] 
		--	,[intItemUOMId] 
		--	,[intLotId] 
		--	,[intSubLocationId] 
		--	,[intStorageLocationId] 
		--	,[dblQty] 
		--	,[intTransactionId]
		--	,[strTransactionId]
		--	,[intTransactionTypeId] 		 	
		--)	
		--SELECT 
		--	LD.intItemId
		--	,IL.intItemLocationId
		--	,LD.intItemUOMId
		--	,NULL
		--	,LD.intPSubLocationId
		--	,NULL
		--	,- @dblQty
		--	,LD.intLoadId
		--	,CAST(L.strLoadNumber AS VARCHAR(100))
		--	,22
		--FROM tblLGLoadDetail LD	INNER JOIN tblLGLoad L 
		--		ON L.intLoadId = LD.intLoadId			
		--	LEFT JOIN vyuCTCompactContractDetailView CT --LEFT JOIN vyuCTContractDetailView CT 
		--		ON CT.intContractDetailId = LD.intPContractDetailId
		--	LEFT JOIN tblICItemLocation IL 
		--		ON IL.intLocationId = CT.intCompanyLocationId 
		--		AND IL.intItemId = LD.intItemId
		--WHERE LD.intLoadDetailId = @intSourceId;

		---- Reduce the Inbound In-Transit Qty when posting an IR. 
		---- Or Increase it back when unposting the IR. 
		--EXEC dbo.uspICIncreaseInTransitInBoundQty @ItemsToIncreaseInTransitInBound;

		SELECT @intLoadId = intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId

		IF @ysnReverse = 0
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId
		END
		ELSE 
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 3 WHERE intLoadId = @intLoadId
			UPDATE tblLGLoadDetail SET dblDeliveredGross = dblDeliveredGross-@dblNetWeight, dblDeliveredNet = dblDeliveredGross-@dblNetWeight WHERE intLoadDetailId = @intSourceId
		END

		SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt WHERE intLotId > @intLotId
	END
	
	-- Reduce the Inbound In-Transit Qty when posting an IR. 
	-- Or Increase it back when unposting the IR. 
	BEGIN
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
			r.intItemId
			,r.intItemLocationId
			,r.intItemUOMId
			,NULL
			,LD.intPSubLocationId
			,NULL
			,-r.dblQty
			,LD.intLoadId
			,CAST(L.strLoadNumber AS VARCHAR(100))
			,22
		FROM 
			@ItemsFromInventoryReceipt r INNER JOIN 
			(
				tblLGLoadDetail LD	INNER JOIN tblLGLoad L 
				ON L.intLoadId = LD.intLoadId			
			)
				ON r.intSourceId = LD.intLoadDetailId
			LEFT JOIN vyuCTCompactContractDetailView CT --LEFT JOIN vyuCTContractDetailView CT 
				ON CT.intContractDetailId = LD.intPContractDetailId
			LEFT JOIN tblICItemLocation IL 
				ON IL.intLocationId = CT.intCompanyLocationId 
				AND IL.intItemId = LD.intItemId

		-- Reduce the Inbound In-Transit Qty when posting an IR. 
		-- Or Increase it back when unposting the IR. 
		EXEC dbo.uspICIncreaseInTransitInBoundQty @ItemsToIncreaseInTransitInBound
	END
END TRY

BEGIN CATCH

	SET @ErrMsg = 'uspLGReceived - ' + ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')  
	
END CATCH