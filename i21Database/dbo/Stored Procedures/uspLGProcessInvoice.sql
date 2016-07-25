CREATE PROCEDURE uspLGProcessInvoice
		@intLoadId INT,
		@intEntityUserSecurityId INT,
		@intNewInvoiceId INT OUTPUT
AS	
BEGIN
	DECLARE @intPurchaseSale INT
	DECLARE @strLoadNumber NVARCHAR(100)
	DECLARE @ysnUnShip BIT
	DECLARE @NewInvoiceId INT

	SELECT @intPurchaseSale = intPurchaseSale
		,@strLoadNumber = strLoadNumber
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF @intPurchaseSale = 2
	BEGIN
		EXEC uspLGCreateInvoiceForShipment
				@intLoadId = @intLoadId ,
				@intUserId = @intEntityUserSecurityId ,
				@NewInvoiceId = @NewInvoiceId OUTPUT
	END
	ELSE IF @intPurchaseSale = 3
	BEGIN
		EXEC uspLGCreateInvoiceForDropShip
				@intLoadId = @intLoadId ,
				@intUserId = @intEntityUserSecurityId ,
				@Post = 1
	END

	SELECT @intNewInvoiceId = @NewInvoiceId
END