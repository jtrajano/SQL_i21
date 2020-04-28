CREATE PROCEDURE uspLGPostLoadSchedule
	@intLoadId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT
AS
BEGIN TRY
	DECLARE @intPurchaseSale INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ysnUnShip BIT
	DECLARE @ysnValidateExternalShipmentNo BIT
	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strExternalShipmentNumber NVARCHAR(100)
	DECLARE @strFOBPoint NVARCHAR(50)
	DECLARE @intSourceType INT
	DECLARE @strInvoiceNo NVARCHAR(1000)
	DECLARE @strMsg NVARCHAR(MAX)
	DECLARE @ysnCancel BIT

	SELECT @intPurchaseSale = intPurchaseSale
		  ,@strLoadNumber = strLoadNumber
		  ,@intSourceType = intSourceType
		  ,@ysnCancel = ISNULL(ysnCancelled, 0)
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @ysnValidateExternalShipmentNo = ISNULL(ysnValidateExternalShipmentNo,0)
	FROM tblLGCompanyPreference 

	SELECT @ysnUnShip = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

	SELECT @strFOBPoint = FT.strFobPoint 
	FROM tblLGLoad L
	JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId 
	WHERE intLoadId = @intLoadId

	IF ISNULL(@intSourceType,0) = 1
	BEGIN
		UPDATE tblLGLoad SET ysnPosted = @ysnPost, dtmPostedDate=GETDATE() WHERE intLoadId = @intLoadId
	END
	ELSE 
	BEGIN
		--Validate if Load has posted Weight Claim
		IF EXISTS (SELECT TOP 1 1 FROM tblLGWeightClaim WHERE intLoadId = @intLoadId AND ysnPosted = 1)
			BEGIN
				SELECT TOP 1 @strInvoiceNo = tblLGWeightClaim.strReferenceNumber 
				FROM tblLGWeightClaim WHERE intLoadId = @intLoadId

				SET @strMsg = 'Weight Claim ' + @strInvoiceNo + ' has been created for ' + @strLoadNumber 
								+ '. Cannot unpost. Please delete the claim and try again.'

				RAISERROR (@strMsg,16,1);

				RETURN 0;
		END

		IF @intPurchaseSale = 1
		BEGIN
		
			IF ISNULL(@ysnValidateExternalShipmentNo,0) = 1 
			BEGIN
				SELECT @strExternalShipmentNumber = strExternalShipmentNumber
				FROM tblLGLoad
				WHERE intLoadId = @intLoadId

				IF(ISNULL(@strExternalShipmentNumber,'') = '')
				BEGIN
					RAISERROR('External shipment no. has not been received. Cannot continue.', 16, 1)
				END
			END
		
			IF(ISNULL(@strFOBPoint,'') = 'Origin')
			BEGIN		
				EXEC uspLGPostInTransitCosting 
					 @intLoadId = @intLoadId
					,@ysnPost = @ysnPost
					,@intPurchaseSale = 1
					,@intEntityUserSecurityId = @intEntityUserSecurityId

				-- Increase the Inbound In-Transit Qty.
				EXEC uspLGUpdateInboundIntransitQty 
					@intLoadId = @intLoadId
					,@ysnInventorize = @ysnPost
					,@ysnUnShip = @ysnUnShip
					,@intEntityUserSecurityId = @intEntityUserSecurityId
			END

			IF(@ysnPost = 0)
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 2, ysnPosted = @ysnPost, dtmPostedDate = NULL WHERE intLoadId = @intLoadId AND @ysnCancel = 0
			END
			ELSE 
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 3, ysnPosted = @ysnPost, dtmPostedDate = GETDATE() WHERE intLoadId = @intLoadId AND @ysnCancel = 0
			END

			IF (@ysnCancel = 1) 
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, 0, @intEntityUserSecurityId
			ELSE
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId

		END
		ELSE IF @intPurchaseSale = 2
		BEGIN
			IF EXISTS (
					SELECT TOP 1 1
					FROM tblLGLoad L
					JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
					WHERE L.intLoadId = @intLoadId
					AND I.ysnReturned = 0 and I.strTransactionType NOT IN ('Credit Memo', 'Proforma Invoice')
					)
			BEGIN
				SELECT TOP 1 @strInvoiceNo = I.strInvoiceNumber
				FROM tblLGLoad L
				JOIN tblARInvoice I ON L.intLoadId = I.intLoadId
				WHERE L.intLoadId = @intLoadId
					AND I.ysnReturned = 0 and I.strTransactionType NOT IN ('Credit Memo', 'Proforma Invoice')

				SET @strMsg = 'Invoice ' + @strInvoiceNo + ' has been generated for ' + @strLoadNumber + '. Cannot unpost. Please delete the invoice and try again.';

				RAISERROR (@strMsg,16,1);

				RETURN 0;
			END

			EXEC uspLGPostInventoryShipment 
					@ysnPost = @ysnPost
					,@strTransactionId = @strLoadNumber
					,@intEntityUserSecurityId = @intEntityUserSecurityId

			IF(@ysnPost = 0)
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 1, ysnPosted = @ysnPost, dtmPostedDate = GETDATE() WHERE intLoadId = @intLoadId AND @ysnCancel = 0
			END

			IF (@ysnCancel = 1) 
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, 0, @intEntityUserSecurityId
			ELSE
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId

		END
		ELSE IF @intPurchaseSale = 3
		BEGIN
			EXEC uspLGPostInTransitCosting 
				@intLoadId = @intLoadId
				,@ysnPost = @ysnPost
				,@intPurchaseSale = @intPurchaseSale
				,@intEntityUserSecurityId = @intEntityUserSecurityId

			-- Increase the Inbound In-Transit Qty.
			EXEC uspLGUpdateInboundIntransitQty 
				@intLoadId = @intLoadId
				,@ysnInventorize = @ysnPost
				,@ysnUnShip = @ysnUnShip
				,@intEntityUserSecurityId = @intEntityUserSecurityId

			--Return Contract Balance when Cancelling Drop Ship (PPT)
			IF (@ysnCancel = 1)
			BEGIN
				DECLARE @ItemsFromInventoryShipment AS dbo.ShipmentItemTableType

				INSERT INTO @ItemsFromInventoryShipment (
					[intShipmentId]
					,[strShipmentId]
					,[intOrderType]
					,[intSourceType]
					,[dtmDate]
					,[intCurrencyId]
					,[dblExchangeRate]
					,[intEntityCustomerId]
					,[intInventoryShipmentItemId]
					,[intItemId]
					,[intLocationId]
					,[intItemLocationId]
					,[intSubLocationId]
					,[intStorageLocationId]
					,[intItemUOMId]
					,[intWeightUOMId]
					,[dblQty]
					,[dblUOMQty]
					,[dblSalesPrice]
					,[intDockDoorId]
					,[intOrderId]
					,[intSourceId]
					,[intLineNo]
					,[intLoadShipped]
					,[ysnLoad]
					)
				SELECT L.intLoadId
					,L.strLoadNumber
					,1 AS intOrderType
					,-1 AS intSourceType
					,GETDATE()
					,intCurrencyId = NULL
					,[dblExchangeRate] = 1
					,LD.intCustomerEntityId
					,LD.intLoadDetailId
					,LD.intItemId
					,[intLocationId] = LD.intSCompanyLocationId
					,[intItemLocationId] = 
									(SELECT TOP 1 ITL.intItemLocationId
									FROM tblICItemLocation ITL
									WHERE ITL.intItemId = LD.intItemId
										AND ITL.intLocationId = CD.intCompanyLocationId)
					,[intSubLocationId] = LD.intSSubLocationId
					,[intStorageLocationId] = NULL
					,[intItemUOMId] = LD.intItemUOMId
					,[intWeightUOMId] = LD.intWeightItemUOMId
					,[dblQty] = LD.dblQuantity
					,[dblUOMQty] = IU.dblUnitQty
					,[dblSalesPrice] = ISNULL(CD.dblCashPrice, 0)
					,[intDockDoorId] = NULL
					,[intOrderId] = NULL
					,[intSourceId] = NULL
					,[intLineNo] = ISNULL(LD.intSContractDetailId, 0)
					,[intLoadShipped] = CASE WHEN CH.ysnLoad = 1 THEN 
											CASE WHEN @ysnPost = 1 THEN -1 ELSE 1 END
										ELSE NULL END
					,[ysnLoad] = CH.ysnLoad
				FROM tblLGLoad L
				JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
				JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
				JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
				LEFT JOIN tblICItemUOM WU ON WU.intItemUOMId = LD.intWeightItemUOMId
				WHERE L.intLoadId = @intLoadId

				EXEC dbo.uspCTShipped @ItemsFromInventoryShipment
					,@intEntityUserSecurityId
					,@ysnPost
			END

			UPDATE tblLGLoad
			SET ysnPosted = @ysnPost
				,dtmPostedDate = GETDATE()
				,intShipmentStatus = CASE 
					WHEN @ysnPost = 1
						THEN 6
					ELSE 1
					END
			WHERE intLoadId = @intLoadId
				AND @ysnCancel = 0

			IF (@ysnCancel = 1) 
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, 0, @intEntityUserSecurityId
			ELSE
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH