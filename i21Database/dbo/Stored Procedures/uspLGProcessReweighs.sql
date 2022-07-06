CREATE PROCEDURE [dbo].[uspLGProcessReweighs]
	@intLoadId INT
	,@intContractDetailId INT = NULL
	,@intLoadContainerId INT = NULL
AS
BEGIN
	DECLARE @ysnAllowReweighs BIT = 0
			,@intShipmentStatus INT

	SELECT @ysnAllowReweighs = ysnAllowReweighs
		,@intShipmentStatus = intShipmentStatus
	FROM tblLGLoad
	WHERE intLoadId = @intLoadId

	IF (ISNULL(@ysnAllowReweighs, 0) = 0) RETURN;

	IF (@intShipmentStatus = 4)
	BEGIN
		--If Voucher exists, do not allow changing the Shipped Weights
		IF EXISTS (SELECT TOP 1 1 FROM tblAPBillDetail BD
						INNER JOIN tblAPBill B ON B.intBillId = BD.intBillId
						INNER JOIN tblICItem Item ON Item.intItemId = BD.intItemId 
						INNER JOIN tblLGLoad L ON L.intLoadId = BD.intLoadId 
						INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = BD.intLoadDetailId 
					WHERE B.intTransactionType IN (1, 3) 
						AND BD.intItemId = LD.intItemId AND Item.strType <> 'Other Charge'
						AND BD.intLoadId = @intLoadId AND BD.intLoadDetailId = LD.intLoadDetailId
						AND BD.intContractDetailId = LD.intPContractDetailId)
		BEGIN
			RAISERROR('Unable to change Shipped Quantity/Weights. Voucher already exists for this Shipment.', 16, 1);
			RETURN;
		END

		--Update Payables with Shipped Fields values
		UPDATE VP
			SET dblQuantityToBill = LD.dblQuantity
				,dblNetWeight = LD.dblNet
		FROM tblAPVoucherPayable VP
			INNER JOIN tblLGLoad L ON L.intLoadId = VP.intLoadShipmentId
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = VP.intLoadShipmentDetailId
		WHERE VP.intLoadShipmentId = @intLoadId 
			AND VP.intLoadShipmentDetailId = LD.intLoadDetailId
			AND (@intContractDetailId IS NULL OR VP.intContractDetailId = @intContractDetailId)

		--Update Pending Claims with Shipped Fields values
		EXEC uspLGAddPendingClaim @intLoadId, 1, @intLoadContainerId, 1
		
	END
END

GO