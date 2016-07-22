CREATE PROCEDURE uspLGPostLoadSchedule
	@intLoadId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT
AS
BEGIN
	DECLARE @intPurchaseSale INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ysnUnShip BIT

	SELECT @intPurchaseSale = intPurchaseSale
		  ,@strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	SELECT @ysnUnShip = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

	IF @intPurchaseSale = 1
	BEGIN
		EXEC uspLGUpdateInboundIntransitQty @intLoadId = @intLoadId
			,@ysnInventorize = @ysnPost
			,@ysnUnShip = @ysnUnShip

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
	END
	ELSE IF @intPurchaseSale = 3
	BEGIN
		UPDATE tblLGLoad SET ysnPosted = @ysnPost, dtmPostedDate=GETDATE() WHERE intLoadId = @intLoadId
	END
END