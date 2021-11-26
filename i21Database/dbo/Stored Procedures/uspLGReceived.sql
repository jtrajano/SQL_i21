CREATE PROCEDURE [dbo].[uspLGReceived]
	@ItemsFromInventoryReceipt ReceiptItemTableType READONLY 
	,@intUserId INT 
AS

DECLARE @ItemsToIncreaseInTransitInBound AS InTransitTableType,
        @total as int;

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

	DECLARE		@ErrMsg							NVARCHAR(MAX),
				@strReceiptType					NVARCHAR(50),
				@intSourceType					INT,
				@intReceiptDetailId				INT,
				@intItemId						INT,
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
				@dblNetWeight					NUMERIC(18,6),
				@ysnWeightClaimsByContainer		BIT,
				@intContractDetailId			INT,
				@intItemUOMId					INT,
				@dblQtyDifference				NUMERIC(18,6)

	SELECT TOP 1 @ysnWeightClaimsByContainer = ISNULL(ysnWeightClaimsByContainer, 0) FROM tblLGCompanyPreference

	SELECT @strReceiptType = strReceiptType, @intSourceType = intSourceType FROM @ItemsFromInventoryReceipt
	IF (@strReceiptType <> 'Purchase Contract' AND @intSourceType <> 2)
		RETURN
	
	SELECT @intReceiptDetailId = MIN(intInventoryReceiptDetailId) FROM @ItemsFromInventoryReceipt
	WHILE ISNULL(@intReceiptDetailId, 0) > 0
	BEGIN
		SELECT @intItemId = NULL
				,@intSourceId = NULL
				,@intContainerId = NULL

		SELECT @intItemId = intItemId
				,@intSourceId = intSourceId
				,@intContainerId = intContainerId
		FROM @ItemsFromInventoryReceipt 
		WHERE intInventoryReceiptDetailId = @intReceiptDetailId

		IF NOT EXISTS(SELECT * FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId)
		BEGIN
		SELECT 1, @intSourceId, Cast(@intSourceId as varchar(100))
			SET @ErrMsg = 'Contract for this shipment does not exist'
			RAISERROR(@ErrMsg,16,1)
		END

		IF (ISNULL((SELECT TOP 1 strLotTracking FROM tblICItem WHERE intItemId = @intItemId), 'No') <> 'No')
		BEGIN
			SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt WHERE intInventoryReceiptDetailId = @intReceiptDetailId
			WHILE ISNULL(@intLotId,0) > 0
			BEGIN
				SELECT @dblQty							=	NULL,
						@dblNetWeight					=	NULL,
						@dblContainerQty				=	NULL
				
				SELECT	@dblQty							=	dblQty,
						@intLotId						=	intLotId,
						@dblNetWeight					=	dblNetWeight
				FROM	@ItemsFromInventoryReceipt 
				WHERE	intLotId						=	@intLotId
					AND intInventoryReceiptDetailId		=	@intReceiptDetailId
		
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
				
				SELECT 
					@dblContractQty = ISNULL(dblDeliveredQuantity,0)
					,@intContractDetailId = intPContractDetailId 
					,@intItemUOMId = intItemUOMId
				FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId

				IF (@dblContractQty + @dblQty) < 0
				BEGIN		
					SET @ErrMsg = 'Negative contract quantity is not allowed'
					RAISERROR(@ErrMsg,16,1)
				END

				UPDATE tblLGLoadDetail SET dblDeliveredQuantity = (@dblContractQty + @dblQty), dblDeliveredGross = @dblNetWeight, dblDeliveredNet = @dblNetWeight WHERE intLoadDetailId = @intSourceId
	
				/*Update Pick Containers*/
				IF EXISTS (SELECT TOP 1 1 FROM tblLGPickLotDetail PLC LEFT JOIN tblLGPickLotHeader PL ON PL.intPickLotHeaderId = PLC.intPickLotHeaderId 
							WHERE PL.intType = 2 AND PLC.intLotId IS NULL AND PLC.intContainerId = @intContainerId)
				BEGIN
					UPDATE PLC
					SET intLotId = CASE WHEN (@dblQty > 0) THEN @intLotId ELSE NULL END
						,intConcurrencyId = PLC.intConcurrencyId + 1
					FROM tblLGPickLotDetail PLC
						LEFT JOIN tblLGPickLotHeader PL ON PL.intPickLotHeaderId = PLC.intPickLotHeaderId
					WHERE PL.intType = 2
						AND PLC.intLotId IS NULL
						AND PL.intPickLotHeaderId NOT IN (SELECT ISNULL(intParentPickLotHeaderId, 0) FROM tblLGPickLotHeader WHERE intType = 1)
						AND PLC.intContainerId = @intContainerId
				END

				SET @ysnReverse = CASE WHEN @dblQty < 0 THEN 1 ELSE 0 END

				SELECT @intLoadId = intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId

				IF @ysnReverse = 0
				BEGIN
					--CHECK IF ALLOW REWEIGHS
					IF EXISTS(SELECT TOP 1 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ISNULL(ysnAllowReweighs, 0) = 1)
					BEGIN
						SELECT @dblQtyDifference = (dblQuantity - @dblQty) * -1 FROM tblLGLoadContainer WHERE intLoadContainerId = @intContainerId AND dblQuantity <> @dblQty
						
						IF (@dblQtyDifference <> 0)
						BEGIN
							EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId, @dblQtyDifference, @intUserId, @intSourceId, 'Load Schedule', @intItemUOMId

							UPDATE tblLGLoadContainer SET dblQuantity = @dblQty WHERE intLoadContainerId = @intContainerId
							UPDATE tblLGLoadDetailContainerLink SET dblQuantity = @dblQty WHERE intLoadContainerId = @intContainerId
							UPDATE tblLGLoadDetail
								SET dblQuantity = (SELECT SUM(dblQuantity) FROM tblLGLoadContainer WHERE intLoadId = @intLoadId)
							WHERE intLoadId = @intLoadId AND intLoadDetailId = @intSourceId

						END
					END

					IF (@ysnWeightClaimsByContainer = 1)
						UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId
						AND EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId HAVING SUM(ISNULL(dblDeliveredQuantity, 0)) >= SUM(ISNULL(dblQuantity, 0)))
					ELSE 
						UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId
				
					-- Insert to Pending Claims
					IF (@ysnWeightClaimsByContainer = 1)
						EXEC uspLGAddPendingClaim @intLoadId, 1, @intContainerId
					ELSE
						EXEC uspLGAddPendingClaim @intLoadId, 1
				END
				ELSE 
				BEGIN
					UPDATE tblLGLoadDetail SET dblDeliveredGross = dblDeliveredGross-@dblNetWeight, dblDeliveredNet = dblDeliveredGross-@dblNetWeight WHERE intLoadDetailId = @intSourceId

					IF EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId HAVING SUM(ISNULL(dblDeliveredQuantity, 0)) < SUM(ISNULL(dblQuantity, 0)))
						UPDATE tblLGLoad SET intShipmentStatus = 3 WHERE intLoadId = @intLoadId
							
					SELECT TOP 1
						@ErrMsg = 'Unable to unpost. Weight Claim ' + strReferenceNumber + ' exists for ' + L.strLoadNumber 
						+ CASE WHEN (@ysnWeightClaimsByContainer = 1) THEN ' Container No. ' + LC.strContainerNumber ELSE '' END + '.' 
					FROM tblLGWeightClaim WC 
						INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
						LEFT JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
						LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WCD.intLoadContainerId
					WHERE WC.intLoadId = @intLoadId
						AND (@ysnWeightClaimsByContainer = 0
							OR @ysnWeightClaimsByContainer = 1 AND WCD.intLoadContainerId = @intContainerId)

					IF (LEN(@ErrMsg) > 0) RAISERROR(@ErrMsg,16,1)
					
					-- Remove from Pending Claims
					IF (@ysnWeightClaimsByContainer = 1)
						EXEC uspLGAddPendingClaim @intLoadId, 1, @intContainerId, 0
					ELSE
						EXEC uspLGAddPendingClaim @intLoadId, 1, NULL, 0
				END	

				SELECT @intLotId = MIN(intLotId) FROM @ItemsFromInventoryReceipt WHERE intLotId > @intLotId AND intInventoryReceiptDetailId	= @intReceiptDetailId
			END
		END
		ELSE
		BEGIN
			SELECT @dblQty							=	NULL,
					@dblNetWeight					=	NULL,
					@dblContainerQty				=	NULL
				
			SELECT	@dblQty							=	dblQty,
					@intLotId						=	intLotId,
					@dblNetWeight					=	dblNetWeight
			FROM	@ItemsFromInventoryReceipt 
			WHERE	intInventoryReceiptDetailId		=	@intReceiptDetailId

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

			SELECT @intLoadId = intLoadId FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId

			IF @ysnReverse = 0
			BEGIN
				IF (@ysnWeightClaimsByContainer = 1)
					UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId
					AND EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId HAVING SUM(ISNULL(dblDeliveredQuantity, 0)) >= SUM(ISNULL(dblQuantity, 0)))
				ELSE 
					UPDATE tblLGLoad SET intShipmentStatus = 4 WHERE intLoadId = @intLoadId
				
				-- Insert to Pending Claims
				IF (@ysnWeightClaimsByContainer = 1)
					EXEC uspLGAddPendingClaim @intLoadId, 1, @intContainerId
				ELSE
					EXEC uspLGAddPendingClaim @intLoadId, 1
			END
			ELSE 
			BEGIN
				UPDATE tblLGLoadDetail SET dblDeliveredGross = dblDeliveredGross-@dblNetWeight, dblDeliveredNet = dblDeliveredGross-@dblNetWeight WHERE intLoadDetailId = @intSourceId

				IF EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadDetailId = @intSourceId HAVING SUM(ISNULL(dblDeliveredQuantity, 0)) < SUM(ISNULL(dblQuantity, 0)))
					UPDATE tblLGLoad SET intShipmentStatus = 3 WHERE intLoadId = @intLoadId
							
				SELECT TOP 1
					@ErrMsg = 'Unable to unpost. Weight Claim ' + strReferenceNumber + ' exists for ' + L.strLoadNumber 
					+ CASE WHEN (@ysnWeightClaimsByContainer = 1) THEN ' Container No. ' + LC.strContainerNumber ELSE '' END + '.' 
				FROM tblLGWeightClaim WC 
					INNER JOIN tblLGLoad L ON L.intLoadId = WC.intLoadId
					LEFT JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId
					LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = WCD.intLoadContainerId
				WHERE WC.intLoadId = @intLoadId
					AND (@ysnWeightClaimsByContainer = 0
						OR @ysnWeightClaimsByContainer = 1 AND WCD.intLoadContainerId = @intContainerId)

				IF (LEN(@ErrMsg) > 0) RAISERROR(@ErrMsg,16,1)
					
				-- Remove from Pending Claims
				IF (@ysnWeightClaimsByContainer = 1)
					EXEC uspLGAddPendingClaim @intLoadId, 1, @intContainerId, 0
				ELSE
					EXEC uspLGAddPendingClaim @intLoadId, 1, NULL, 0
			END	
		END

		SELECT @intReceiptDetailId = MIN(intInventoryReceiptDetailId) FROM @ItemsFromInventoryReceipt WHERE intInventoryReceiptDetailId > @intReceiptDetailId
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
			,ISNULL(LW.intSubLocationId, LD.intPSubLocationId)
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
				LEFT JOIN tblLGLoadWarehouse LW 
				ON LW.intLoadId= L.intLoadId
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