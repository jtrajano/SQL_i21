CREATE PROCEDURE [dbo].[uspLGShipmentUpdateContainerReceivedQty]
	@intShipmentBLContainerContractId INT
	,@dblReceivedQty NUMERIC(18,6)
AS
BEGIN

	DECLARE @dblQty NUMERIC(18,6);
	DECLARE @dblTempReceivedQty NUMERIC(18,6);

	SELECT	@dblQty = IsNull(S.dblQuantity, 0), @dblTempReceivedQty = IsNull(S.dblReceivedQty, 0) FROM tblLGShipmentBLContainerContract S WHERE S.intShipmentBLContainerContractId = @intShipmentBLContainerContractId

	IF(IsNull(@dblQty, 0) = 0)
	BEGIN
		RAISERROR('Invalid intShipmentBLContainerContractId', 11, 1);
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

	UPDATE tblLGShipmentBLContainerContract SET dblReceivedQty = (@dblTempReceivedQty + @dblReceivedQty) WHERE intShipmentBLContainerContractId = @intShipmentBLContainerContractId
END
