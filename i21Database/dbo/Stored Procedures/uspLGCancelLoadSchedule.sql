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

			IF EXISTS (SELECT TOP 1 1 FROM tblRKCompanyPreference WHERE ysnImposeReversalTransaction = 1)
			BEGIN
				DECLARE @strTransactionNo NVARCHAR(100)
				DECLARE @strInvoiceNo NVARCHAR(100) = NULL
				DECLARE @strVoucherNo NVARCHAR(100) = NULL
				/* Validations to Reverse related transactions */

				--Validate if Load has posted Weight Claim
				IF EXISTS (SELECT TOP 1 1 FROM tblLGWeightClaim WHERE intLoadId = @intLoadId AND ysnPosted = 1)
				BEGIN
					SELECT TOP 1 @strTransactionNo = tblLGWeightClaim.strReferenceNumber 
					FROM tblLGWeightClaim WHERE intLoadId = @intLoadId

					SET @strErrMsg = 'Weight Claim ' + @strTransactionNo + ' has been created for ' + @strLoadNumber 
									+ '. Cannot cancel.'

					RAISERROR (@strErrMsg,16,1);

					RETURN 0;
				END

				--Validate if Invoice exists
				SELECT TOP 1 @strInvoiceNo = I.strInvoiceNumber
					FROM tblLGLoad L
					JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
					WHERE L.intLoadId = @intLoadId
						AND I.ysnReturned = 0 and I.strTransactionType <> 'Credit Memo'

				--Validate if Voucher exists
				SELECT TOP 1 @strVoucherNo = B.strBillId
				FROM tblAPBillDetail BD 
				JOIN tblAPBill B ON B.intBillId = BD.intBillId
				JOIN tblLGLoadDetail LD ON BD.intLoadDetailId = LD.intLoadDetailId
				WHERE LD.intLoadId = @intLoadId

				IF (@strInvoiceNo IS NOT NULL OR @strVoucherNo IS NOT NULL)
				BEGIN
					SET @strErrMsg = CASE WHEN (@strInvoiceNo IS NOT NULL) THEN 'Invoice ' + @strInvoiceNo + ' ' ELSE '' END
						+ CASE WHEN (@strInvoiceNo IS NOT NULL AND @strVoucherNo IS NOT NULL) THEN 'and ' ELSE '' END
						+ CASE WHEN (@strVoucherNo IS NOT NULL) THEN 'Voucher ' + @strVoucherNo + ' ' ELSE '' END 
						+ CASE WHEN (@strInvoiceNo IS NOT NULL AND @strVoucherNo IS NOT NULL) THEN 'were ' ELSE 'was ' END
						+ 'already created for ' + @strLoadNumber + '. Cannot cancel.';

					RAISERROR(@strErrMsg, 16, 1);
					RETURN 0;
				END

				--Validate if Inventory Receipt exists
				IF EXISTS (SELECT TOP 1 1 FROM tblICInventoryReceiptItem IRI
					INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.intSourceType = 2 AND IR.intSourceInventoryReceiptId IS NULL
					INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IRI.intSourceId AND LD.intPContractDetailId = IRI.intLineNo AND LD.intLoadId = @intLoadId
					WHERE IR.intInventoryReceiptId NOT IN (SELECT intSourceInventoryReceiptId FROM tblICInventoryReceipt WHERE intSourceInventoryReceiptId IS NOT NULL AND strDataSource = 'Reverse'))
				BEGIN
					SELECT TOP 1 @strTransactionNo = IR.strReceiptNumber
					FROM tblICInventoryReceiptItem IRI
					INNER JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId AND IR.intSourceType = 2 AND IR.intSourceInventoryReceiptId IS NULL
					INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = IRI.intSourceId AND LD.intPContractDetailId = IRI.intLineNo AND LD.intLoadId = @intLoadId
					WHERE IR.intInventoryReceiptId NOT IN (SELECT intSourceInventoryReceiptId FROM tblICInventoryReceipt WHERE intSourceInventoryReceiptId IS NOT NULL AND strDataSource = 'Reverse')

					SET @strErrMsg = 'Inventory Receipt ' + @strTransactionNo + ' has been generated for ' + @strLoadNumber 
						+ '. Cannot cancel.';

					RAISERROR (@strErrMsg,16,1);

					RETURN 0;
				END
			END
			ELSE
			BEGIN
				IF EXISTS (SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ysnPosted = 1) 
				BEGIN
					RAISERROR ('Shipment is already posted. Cannot cancel.',11,1)
				END
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
				WHERE intLoadId = @intLoadShippingInstructionId

				EXEC [uspLGCreateLoadIntegrationLog] @intLoadId = @intLoadShippingInstructionId
					,@strRowState = 'Added'
					,@intShipmentType = 2
			END

			/* Perform Reversal */
			IF EXISTS(SELECT TOP 1 1 FROM tblRKCompanyPreference WHERE ISNULL(ysnImposeReversalTransaction, 0) = 1)
			BEGIN
				EXEC uspLGPostLoadSchedule @intLoadId, @intEntityUserSecurityId, 1
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

				IF EXISTS(SELECT TOP 1 1 FROM tblCTContractDetail WHERE intContractDetailId = @intPContractDetailId AND intContractStatusId = 3)
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
				WHERE intLoadId = @intLoadId
				
				UPDATE tblLGLoadContainer
				SET ysnNewContainer = 1
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