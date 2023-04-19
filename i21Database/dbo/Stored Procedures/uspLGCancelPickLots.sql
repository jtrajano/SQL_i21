CREATE PROCEDURE [dbo].[uspLGCancelPickLots]
	 @intPickLotHeaderId INT,
	 @ysnCancel BIT = 0,
	 @UserId INT = NULL
AS
BEGIN TRY
	DECLARE @ysnCancelled AS BIT
	DECLARE @strErrMsg NVARCHAR(MAX)

	-- Validate if the Cancellation/Reversal is valid
	SELECT @ysnCancelled = ysnCancelled FROM tblLGPickLotHeader WHERE @intPickLotHeaderId = intPickLotHeaderId
	IF (ISNULL(@ysnCancelled, 0) = ISNULL(@ysnCancel, 0))
	BEGIN
		RETURN
	END	

	-- Validate if the LS associated with the Allocation, if it exists, is cancelled
	IF EXISTS (
		SELECT PH.intPickLotHeaderId
		FROM tblLGPickLotHeader PH
		INNER JOIN tblLGPickLotDetail PD ON PD.intPickLotHeaderId = PH.intPickLotHeaderId
		INNER JOIN tblLGLoadDetail LD ON LD.intPickLotDetailId = PD.intPickLotDetailId
		INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
		WHERE PH.intPickLotHeaderId = @intPickLotHeaderId AND L.intShipmentStatus != 10
	)
	BEGIN
		RAISERROR('Cannot cancel the Picked Lot/s. The Load associated with it is being used. Try cancelling the Load first.', 16, 1)  
	END

	IF (@ysnCancel = 1)
	BEGIN
		EXEC dbo.uspLGUpdateReleasedQtyForPickLot
			@intPickLotHeaderId = @intPickLotHeaderId,
			@intUserSecurityId = @UserId,
			@ysnClear = 1

		EXEC dbo.uspLGReserveStockForPickLots
			@intPickLotHeaderId = @intPickLotHeaderId

		DELETE FROM tblICStockReservation WHERE intTransactionId = @intPickLotHeaderId

		UPDATE tblLGPickLotHeader
		SET ysnCancelled = 1
		WHERE intPickLotHeaderId = @intPickLotHeaderId
	END
	ELSE
	BEGIN
		EXEC dbo.uspLGReserveStockForPickLots
			@intPickLotHeaderId = @intPickLotHeaderId

		EXEC dbo.uspLGUpdateReleasedQtyForPickLot
			@intPickLotHeaderId = @intPickLotHeaderId,
			@intUserSecurityId = @UserId,
			@ysnClear = 0

		UPDATE tblLGPickLotHeader
		SET ysnCancelled = 0
		WHERE intPickLotHeaderId = @intPickLotHeaderId
	END


END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()  
	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT')
END CATCH