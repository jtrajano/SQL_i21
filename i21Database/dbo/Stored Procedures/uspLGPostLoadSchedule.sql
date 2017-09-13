﻿CREATE PROCEDURE uspLGPostLoadSchedule
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

	SELECT @intPurchaseSale = intPurchaseSale
		  ,@strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @ysnValidateExternalShipmentNo = ISNULL(ysnValidateExternalShipmentNo,0)
	FROM tblLGCompanyPreference 

	SELECT @ysnUnShip = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

	SELECT @strFOBPoint = FT.strFobPoint 
	FROM tblLGLoad L
	JOIN tblSMFreightTerms FT ON FT.intFreightTermId = L.intFreightTermId 
	WHERE intLoadId = @intLoadId

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

		EXEC uspLGUpdateInboundIntransitQty @intLoadId = @intLoadId
			,@ysnInventorize = @ysnPost
			,@ysnUnShip = @ysnUnShip
			,@intEntityUserSecurityId = @intEntityUserSecurityId
		
		IF(ISNULL(@strFOBPoint,'') = 'Origin')
		BEGIN		
			EXEC uspLGPostInTransitCosting 
				 @intLoadId = @intLoadId
				,@ysnPost = @ysnPost
				,@intPurchaseSale = 1
				,@intEntityUserSecurityId = @intEntityUserSecurityId
		END

		IF(@ysnPost = 0)
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 2 WHERE intLoadId = @intLoadId
		END
		ELSE 
		BEGIN
			UPDATE tblLGLoad SET intShipmentStatus = 3 WHERE intLoadId = @intLoadId
		END
	END
	ELSE IF @intPurchaseSale = 2
	BEGIN
			EXEC uspLGPostInventoryShipment 
					@ysnPost = @ysnPost
				   ,@strTransactionId = @strLoadNumber
				   ,@intEntityUserSecurityId = @intEntityUserSecurityId

			IF(@ysnPost = 0)
			BEGIN
				UPDATE tblLGLoad SET intShipmentStatus = 1 WHERE intLoadId = @intLoadId
			END
	END
	ELSE IF @intPurchaseSale = 3
	BEGIN
		IF(ISNULL(@strFOBPoint,'') = 'Origin')
		BEGIN		
			EXEC uspLGPostInTransitCosting 
				 @intLoadId = @intLoadId
				,@ysnPost = @ysnPost
				,@intPurchaseSale = 1
				,@intEntityUserSecurityId = @intEntityUserSecurityId
		END

		UPDATE tblLGLoad SET ysnPosted = @ysnPost, dtmPostedDate=GETDATE() WHERE intLoadId = @intLoadId
	END
END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH