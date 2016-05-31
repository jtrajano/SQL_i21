CREATE PROCEDURE uspLGPostLoadSchedule
	@intLoadId INT,
	@intEntityUserSecurityId INT,
	@ysnPost BIT
AS
BEGIN
	DECLARE @intPurchaseSale INT
	DECLARE @strLoadNumber NVARCHAR(100)

	SELECT @intPurchaseSale = intPurchaseSale
		  ,@strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF @intPurchaseSale = 1
	BEGIN
		EXEC uspLGUpdateInboundIntransitQty @intLoadId = @intLoadId
			,@ysnInventorize = @ysnPost
			,@ysnUnShip = 0

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
		SELECT 'EXEC uspLGPostInventoryShipment @ysnPost = @ysnPost
			,@ysnRecap = 0
			,@strTransactionId = @strLoadNumber
			,@intEntityUserSecurityId = @intEntityUserSecurityId'
	END
	ELSE IF @intPurchaseSale = 3
	BEGIN
		UPDATE tblLGLoad SET ysnPosted = @ysnPost, dtmPostedDate=GETDATE() WHERE intLoadId = @intLoadId
	END
END