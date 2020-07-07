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

	SELECT @intPurchaseSale = intPurchaseSale
		  ,@strLoadNumber = strLoadNumber
		  ,@intSourceType = intSourceType
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
				UPDATE tblLGLoad SET intShipmentStatus = 2, ysnPosted = @ysnPost, dtmPostedDate = NULL WHERE intLoadId = @intLoadId
			END
			ELSE 
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 3, ysnPosted = @ysnPost, dtmPostedDate = GETDATE() WHERE intLoadId = @intLoadId
			END

			IF(ISNULL(@strFOBPoint,'') = 'Origin')
			BEGIN	
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
			END
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
				UPDATE tblLGLoad SET intShipmentStatus = 1, ysnPosted = @ysnPost, dtmPostedDate = GETDATE() WHERE intLoadId = @intLoadId
			END

			IF(ISNULL(@strFOBPoint,'') = 'Origin')
			BEGIN	
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
			END
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

			UPDATE tblLGLoad
			SET ysnPosted = @ysnPost
				,dtmPostedDate = GETDATE()
				,intShipmentStatus = CASE 
					WHEN @ysnPost = 1
						THEN 6
					ELSE 1
					END
			WHERE intLoadId = @intLoadId

			IF(ISNULL(@strFOBPoint,'') = 'Origin')
			BEGIN	
				EXEC dbo.uspLGProcessPayables @intLoadId, NULL, @ysnPost, @intEntityUserSecurityId
			END
		END
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH