CREATE PROCEDURE uspLGCancelLoadSchedule 
	 @intLoadId INT
	,@ysnCancel BIT
	,@intEntityUserSecurityId INT
	,@intShipmentType INT = NULL
AS
BEGIN TRY
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @intPurchaseSale INT
	DECLARE @intMinLoadDetailId INT
	DECLARE @intPContractDetailId INT
	DECLARE @intSContractDetailId INT
	DECLARE @dblQuantityToUpdate NUMERIC(18, 6)
	DECLARE @dblAvailableContractQty NUMERIC(18, 6)
	DECLARE @dblContractSIQty NUMERIC(18, 6)
	DECLARE @intExternalId INT
	DECLARE @strScreenName NVARCHAR(100)
	DECLARE @intLoadShippingInstructionId INT
	DECLARE @strAuditLogActionType NVARCHAR(MAX)
	DECLARE	@dblScheduleQty	NUMERIC(18,6)
	DECLARE	@intNoOfLoad	INT
	DECLARE @ysnPosted BIT
	DECLARE @strLoadNumber NVARCHAR(MAX)
	DECLARE @tblLoadDetail TABLE (intLoadDetailRecordId INT Identity(1, 1)
								 ,intLoadDetailId INT
								 ,intPContractDetailId INT
								 ,intSContractDetailId INT
								 ,dblLoadDetailQuantity NUMERIC(18, 6))

	SELECT @intPurchaseSale = intPurchaseSale,
		   @intShipmentType = ISNULL(@intShipmentType,intShipmentType),
		   @ysnPosted = ISNULL(ysnPosted, 0),
		   @strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	INSERT INTO @tblLoadDetail
	SELECT intLoadDetailId
		,intPContractDetailId
		,intSContractDetailId
		,dblQuantity
	FROM tblLGLoadDetail
	WHERE intLoadId = @intLoadId

	IF (@intShipmentType = 1)
	BEGIN
		IF (@ysnCancel = 1)
		BEGIN
			IF EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ISNULL(ysnCancelled, 0) = 1)
			BEGIN
				RAISERROR ('Shipment is already cancelled.',11,1)
			END
			
			IF EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ysnPosted = 1) 
			BEGIN
				RAISERROR ('Shipment is already posted. Cannot cancel.',11,1)
			END

			SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
			FROM @tblLoadDetail

			SELECT @intLoadShippingInstructionId = intLoadShippingInstructionId
			FROM tblLGLoad
			WHERE intLoadId = @intLoadId

			UPDATE tblQMSample
			SET intLoadContainerId = NULL
				,intLoadDetailId = NULL
				,intLoadDetailContainerLinkId = NULL
				,intLoadId = NULL
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intLoadId = @intLoadId

			UPDATE tblLGLoad
			SET intShipmentStatus = 10
				,ysnCancelled = @ysnCancel
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intLoadId = @intLoadId

			WHILE (@intMinLoadDetailId IS NOT NULL)
			BEGIN
				SET @intPContractDetailId = NULL
				SET @intSContractDetailId = NULL
				SET @dblQuantityToUpdate = NULL
				SET @intExternalId = NULL
				SET @strScreenName = NULL

				SELECT @intPContractDetailId = intPContractDetailId
					,@intSContractDetailId = intSContractDetailId
					,@dblQuantityToUpdate = - dblLoadDetailQuantity
					,@intExternalId = @intMinLoadDetailId
					,@strScreenName = 'Load Schedule'
				FROM @tblLoadDetail
				WHERE intLoadDetailId = @intMinLoadDetailId

				SELECT	@dblScheduleQty = dblScheduleQty,@intNoOfLoad = ISNULL(intNoOfLoad,0) FROM tblCTContractDetail WHERE intContractDetailId = ISNULL(@intPContractDetailId,@intSContractDetailId)

				IF @intNoOfLoad > 0
				BEGIN
					SET @dblQuantityToUpdate = -1
				END

				IF @dblScheduleQty < ABS(@dblQuantityToUpdate)
					SET @dblQuantityToUpdate = - @dblScheduleQty

				IF (ISNULL(@intPContractDetailId,0) > 0) AND ABS(@dblQuantityToUpdate) > 0
				BEGIN 
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intPContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
						,@intExternalId = @intExternalId
						,@strScreenName = @strScreenName
				END

				IF (ISNULL(@intSContractDetailId,0) > 0) AND ABS(@dblQuantityToUpdate) > 0
				BEGIN 
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intSContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
						,@intExternalId = @intExternalId
						,@strScreenName = @strScreenName
				END

				SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLoadDetail
				WHERE intLoadDetailId > @intMinLoadDetailId
			END

			EXEC [uspLGReserveStockForInventoryShipment] @intLoadId = @intLoadId
				,@ysnReserveStockForInventoryShipment = 0

			EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadId
				,@strRowState = 'Delete'
				,@intShipmentType = @intShipmentType

			EXEC [uspLGCreateLoadIntegrationLSPLog] @intLoadId = @intLoadId
				,@strRowState = 'Delete'
				,@intShipmentType = @intShipmentType

			IF (ISNULL(@intLoadShippingInstructionId,0) <> 0)
			BEGIN
				UPDATE tblLGLoad
				SET intShipmentStatus = 7
					,strExternalShipmentNumber = NULL
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intLoadId = @intLoadShippingInstructionId

				EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadShippingInstructionId
					,@strRowState = 'Added'
					,@intShipmentType = 2
			END
		END
		ELSE
		BEGIN
			SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
			FROM @tblLoadDetail

			WHILE (@intMinLoadDetailId IS NOT NULL)
			BEGIN
				SET @intPContractDetailId = NULL
				SET @intSContractDetailId = NULL
				SET @dblQuantityToUpdate = NULL
				SET @intExternalId = NULL
				SET @strScreenName = NULL

				SELECT @intPContractDetailId = intPContractDetailId
					,@intSContractDetailId = intSContractDetailId
					,@dblQuantityToUpdate = dblLoadDetailQuantity
					,@intExternalId = @intMinLoadDetailId
					,@strScreenName = 'Load Schedule'
				FROM @tblLoadDetail
				WHERE intLoadDetailId = @intMinLoadDetailId

				IF EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intContractStatusId = 3 AND intContractDetailId IN (@intPContractDetailId, @intSContractDetailId))
				BEGIN
					RAISERROR ('Associated contract seq is in cancelled status. Cannot continue.',11,1)
				END

				IF (ISNULL(@intPContractDetailId,0) > 0)
				BEGIN 
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intPContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
						,@intExternalId = @intExternalId
						,@strScreenName = @strScreenName
				END

				IF (ISNULL(@intSContractDetailId,0) > 0)
				BEGIN 
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intSContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
						,@intExternalId = @intExternalId
						,@strScreenName = @strScreenName
				END

				SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLoadDetail
				WHERE intLoadDetailId > @intMinLoadDetailId

				UPDATE tblLGLoad
				SET intShipmentStatus = 1
					,ysnCancelled = @ysnCancel
					,strExternalShipmentNumber = NULL
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intLoadId = @intLoadId
				
				UPDATE tblLGLoadContainer
				SET ysnNewContainer = 1
					,intConcurrencyId = intConcurrencyId + 1
				WHERE intLoadId = @intLoadId

				IF EXISTS(SELECT 1 FROM tblLGLoadStg WHERE intLoadId = @intLoadId)
				BEGIN
					DELETE FROM tblLGLoadStg WHERE intLoadId = @intLoadId
				END	

				EXEC [uspLGReserveStockForInventoryShipment] @intLoadId = @intLoadId
					,@ysnReserveStockForInventoryShipment = 1

				EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadId
					,@strRowState = 'Added'
					,@intShipmentType = @intShipmentType

				EXEC [uspLGCreateLoadIntegrationLSPLog] @intLoadId = @intLoadId
					,@strRowState = 'Added'
					,@intShipmentType = @intShipmentType
			END

			EXEC [uspLGReserveStockForInventoryShipment] @intLoadId = @intLoadId
			,@ysnReserveStockForInventoryShipment = 1

		END
	END
	ELSE IF (@intShipmentType = 2)
	BEGIN
		IF (@ysnCancel = 1)
		BEGIN
			IF EXISTS (
					SELECT 1
					FROM tblLGLoad
					WHERE intLoadShippingInstructionId = @intLoadId
						AND intShipmentStatus <> 10
					)
			BEGIN
				RAISERROR ('Shipment has already been created for the shipping instruction. Cannot cancel.',11,1)
			END

			IF EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ISNULL(ysnCancelled, 0) = 1)
			BEGIN
				RAISERROR ('Shipping instruction is already cancelled.',11,1)
			END

			SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
			FROM @tblLoadDetail

			SELECT @intLoadShippingInstructionId = intLoadShippingInstructionId
			FROM tblLGLoad
			WHERE intLoadId = @intLoadId

			WHILE (@intMinLoadDetailId IS NOT NULL)
			BEGIN
				SET @intPContractDetailId = NULL
				SET @intSContractDetailId = NULL
				SET @dblQuantityToUpdate = NULL
				SET @intExternalId = NULL
				SET @strScreenName = NULL

				SELECT @intPContractDetailId = intPContractDetailId
					,@intSContractDetailId = intSContractDetailId
					,@dblQuantityToUpdate = - dblLoadDetailQuantity
					,@intExternalId = @intMinLoadDetailId
					,@strScreenName = 'Load Schedule'
				FROM @tblLoadDetail
				WHERE intLoadDetailId = @intMinLoadDetailId

				IF (ISNULL(@intPContractDetailId,0) > 0)
				BEGIN
					EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intPContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
				END

				IF (ISNULL(@intSContractDetailId,0) > 0)
				BEGIN
					EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intSContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
				END

				SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLoadDetail
				WHERE intLoadDetailId > @intMinLoadDetailId
			END

			UPDATE tblLGLoad
			SET intShipmentStatus = 10
				,ysnCancelled = @ysnCancel
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intLoadId = @intLoadId

			EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadId
				,@strRowState = 'Delete'
				,@intShipmentType = @intShipmentType
		END
		ELSE 
		BEGIN
			SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
			FROM @tblLoadDetail

			WHILE (@intMinLoadDetailId IS NOT NULL)
			BEGIN
				SET @intPContractDetailId = NULL
				SET @intSContractDetailId = NULL
				SET @dblQuantityToUpdate = NULL
				SET @dblAvailableContractQty = NULL

				SELECT @intPContractDetailId = intPContractDetailId
					,@intSContractDetailId = intSContractDetailId
					,@dblQuantityToUpdate = dblLoadDetailQuantity
				FROM @tblLoadDetail
				WHERE intLoadDetailId = @intMinLoadDetailId

				SELECT @dblContractSIQty = ISNULL(SUM(LD.dblQuantity),0) FROM tblLGLoadDetail LD
				JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
				WHERE intPContractDetailId = @intPContractDetailId AND ISNULL(L.ysnCancelled,0) = 0 

				SELECT @dblAvailableContractQty = dblQuantity - ISNULL(@dblContractSIQty, 0)
				FROM tblCTContractDetail
				WHERE intContractDetailId = @intPContractDetailId

				IF @dblAvailableContractQty<=0
				BEGIN
					RAISERROR('Adequate qty is not there for the purchase contract. Cannot reverse cancel.',16,1)
				END
				
				IF(ISNULL(@intPContractDetailId,0) > 0 )
				BEGIN
					EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intPContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
				END
				
				IF(ISNULL(@intSContractDetailId,0) > 0 )
				BEGIN
					EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intSContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
				END

				SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLoadDetail
				WHERE intLoadDetailId > @intMinLoadDetailId
			END

			UPDATE tblLGLoad
			SET intShipmentStatus = 7
				,ysnCancelled = @ysnCancel
				,intConcurrencyId = intConcurrencyId + 1
			WHERE intLoadId = @intLoadId

			EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadId
				,@strRowState = 'Delete'
				,@intShipmentType = @intShipmentType
		END
	END

	IF(ISNULL(@ysnCancel,0) = 1)
	BEGIN
		SET @strAuditLogActionType  = 'Cancel'
	END 
	ELSE 
	BEGIN
		SET @strAuditLogActionType  = 'Reverse Cancel'
	END

	EXEC uspSMAuditLog	
			@keyValue	=	@intLoadId,
			@screenName =	'Logistics.view.ShipmentSchedule',
			@entityId	=	@intEntityUserSecurityId,
			@actionType =	@strAuditLogActionType,
			@actionIcon =	'small-tree-modified',
			@details	=	''
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH