CREATE PROCEDURE [dbo].[uspLGShipmentUpdatePurchaseContractReceivedQty]
	@intShipmentContractQtyId INT
	,@dblReceivedQty NUMERIC(18,6)
AS
BEGIN

	DECLARE @dblQty NUMERIC(18,6);
	DECLARE @dblTempReceivedQty NUMERIC(18,6);

	SELECT	@dblQty = IsNull(S.dblQuantity, 0), @dblTempReceivedQty = IsNull(S.dblReceivedQty, 0) FROM tblLGShipmentContractQty S WHERE S.intShipmentContractQtyId = @intShipmentContractQtyId

	IF(IsNull(@dblQty, 0) = 0)
	BEGIN
		RAISERROR('Invalid intShipmentContractQtyId', 11, 1);
		RETURN;
	END
	IF (IsNull(@dblReceivedQty, 0) = 0)
	BEGIN
		RAISERROR('Invalid Quantity', 11, 1);
		RETURN;
	END
	IF(@dblTempReceivedQty + @dblReceivedQty > @dblQty)
	BEGIN
		RAISERROR('Received quantity exceeds shipped quantity', 11, 1);
		RETURN;
	END

	UPDATE tblLGShipmentContractQty SET dblReceivedQty = (@dblTempReceivedQty + @dblReceivedQty) WHERE intShipmentContractQtyId = @intShipmentContractQtyId
END
