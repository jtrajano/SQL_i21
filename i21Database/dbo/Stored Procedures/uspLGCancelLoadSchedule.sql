CREATE PROCEDURE uspLGCancelLoadSchedule 
	 @intLoadId INT
	,@ysnCancel BIT
	,@intEntityUserSecurityId INT
	,@intShipmentType INT
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
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @intLoadShippingInstructionId INT
	DECLARE @tblLoadDetail TABLE (intLoadDetailRecordId INT Identity(1, 1)
								 ,intLoadDetailId INT
								 ,intPContractDetailId INT
								 ,intSContractDetailId INT
								 ,dblLoadDetailQuantity NUMERIC(18, 6))

	SELECT @intPurchaseSale = intPurchaseSale,
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

				SELECT  @intPContractDetailId = intPContractDetailId
					,@intSContractDetailId = intSContractDetailId
					,@dblQuantityToUpdate = - dblLoadDetailQuantity
					,@intExternalId = @intMinLoadDetailId
					,@strScreenName = 'Load Schedule'
				FROM @tblLoadDetail
				WHERE intLoadDetailId = @intMinLoadDetailId
				IF (ISNULL(@intPContractDetailId,0) <> 0)

				BEGIN
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intPContractDetailId
						,@dblQuantityToUpdate = @dblQuantityToUpdate
						,@intUserId = @intEntityUserSecurityId
						,@intExternalId = @intExternalId
						,@strScreenName = @strScreenName
				END

				IF (ISNULL(@intSContractDetailId,0) <> 0)
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

			IF EXISTS (SELECT 1 FROM tblICStockReservation WHERE intTransactionId = @intLoadId AND strTransactionId = @strLoadNumber)
			BEGIN
				EXEC [uspLGReserveStockForInventoryShipment] @intLoadId = @intLoadId
					,@ysnReserveStockForInventoryShipment = 0
			END

			UPDATE tblQMSample
			SET intLoadContainerId = NULL
				,intLoadDetailId = NULL
				,intLoadDetailContainerLinkId = NULL
				,intLoadId = NULL
			WHERE intLoadId = @intLoadId

			UPDATE tblLGLoad
			SET intShipmentStatus = 10
				,ysnCancelled = @ysnCancel
			WHERE intLoadId = @intLoadId

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

				IF (ISNULL(@intPContractDetailId,0) <> 0)
				BEGIN
					EXEC uspCTUpdateScheduleQuantity @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate = @dblQuantityToUpdate
					,@intUserId = @intEntityUserSecurityId
					,@intExternalId = @intExternalId
					,@strScreenName = @strScreenName
				END

				IF (ISNULL(@intSContractDetailId,0) <> 0)
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
				WHERE intLoadId = @intLoadId

				EXEC [uspLGReserveStockForInventoryShipment] @intLoadId = @intLoadId
					,@ysnReserveStockForInventoryShipment = 1

				EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadId
					,@strRowState = 'Added'
					,@intShipmentType = @intShipmentType

				EXEC [uspLGCreateLoadIntegrationLSPLog] @intLoadId = @intLoadId
					,@strRowState = 'Added'
					,@intShipmentType = @intShipmentType
			END
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

				EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate = @dblQuantityToUpdate
					,@intUserId = @intEntityUserSecurityId

				SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLoadDetail
				WHERE intLoadDetailId > @intMinLoadDetailId
			END

			UPDATE tblLGLoad
			SET intShipmentStatus = 10
				,ysnCancelled = @ysnCancel
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
					RAISERROR('Adequate qty is not there for the contract. Cannot reverse cancel.',16,1)
				END

				EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intPContractDetailId
					,@dblQuantityToUpdate = @dblQuantityToUpdate
					,@intUserId = @intEntityUserSecurityId

				SELECT @intMinLoadDetailId = MIN(intLoadDetailId)
				FROM @tblLoadDetail
				WHERE intLoadDetailId > @intMinLoadDetailId
			END

			UPDATE tblLGLoad
			SET intShipmentStatus = 1
				,ysnCancelled = @ysnCancel
			WHERE intLoadId = @intLoadId

			EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadId
				,@strRowState = 'Delete'
				,@intShipmentType = @intShipmentType
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	IF @strErrMsg != ''
	BEGIN
		SET @strErrMsg = @strErrMsg

		RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
	END
END CATCH