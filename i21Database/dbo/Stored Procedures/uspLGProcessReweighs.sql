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
		UPDATE PC
			SET dblShippedNetWt = (LC.dblNetWt - ISNULL(IRN.dblIRNet, 0))
				,dblFranchiseWt = CASE WHEN (LC.dblNetWt * WG.dblFranchise / 100) <> 0.0
										THEN (LC.dblNetWt - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100
									ELSE 0.0 END
				,dblWeightLoss = RI.dblNet - LC.dblNetWt
				,dblClaimableWt = CASE WHEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
									THEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100))
									ELSE (RI.dblNet - LC.dblNetWt)
									END
				,dblClaimableAmount = ROUND(
										CASE WHEN (
												((CASE WHEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
													THEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100))
													ELSE (RI.dblNet - LC.dblNetWt) END 
													* dblSeqPriceInWeightUOM) 
													/ CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) < 0)
												THEN ((CASE WHEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
														THEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100))
														ELSE (RI.dblNet - LC.dblNetWt)
														END * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) * - 1
											ELSE ((CASE WHEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
													THEN ((RI.dblNet - LC.dblNetWt) + (LD.dblNet * WG.dblFranchise / 100))
													ELSE (RI.dblNet - LC.dblNetWt) END 
													* dblSeqPriceInWeightUOM) 
													/ CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END)
											END
										, 2)
		FROM
			tblLGPendingClaim PC 
			JOIN tblLGLoad L ON L.intLoadId = PC.intLoadId
			JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			JOIN tblCTContractDetail CD ON CD.intContractDetailId = intPContractDetailId
			JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
			JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
			OUTER APPLY (SELECT TOP 1 ysnWeightClaimsByContainer = ISNULL(ysnWeightClaimsByContainer, 1) FROM tblLGCompanyPreference) CP
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadId = L.intLoadId AND L.intPurchaseSale = 1 
				AND LC.intLoadContainerId = PC.intLoadContainerId AND CP.ysnWeightClaimsByContainer = 1
			OUTER APPLY (SELECT dblLinkNetWt = SUM(ISNULL(dblLinkNetWt, 0)) FROM tblLGLoadDetailContainerLink 
									WHERE intLoadDetailId = LD.intLoadDetailId 
									AND (LC.intLoadContainerId IS NULL OR intLoadContainerId = LC.intLoadContainerId)) CLNW
			CROSS APPLY (SELECT dblNet = SUM(ISNULL(IRI.dblNet,0)),dblGross = SUM(ISNULL(IRI.dblGross,0)) FROM tblICInventoryReceipt IR 
							JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
							WHERE IR.ysnPosted = 1 AND IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
								AND (LC.intLoadContainerId IS NULL OR IRI.intContainerId = LC.intLoadContainerId)
								AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType <> 'Inventory Return') RI
			CROSS APPLY (SELECT dblIRNet = SUM(ISNULL(IRI.dblNet,0)),dblIRGross = SUM(ISNULL(IRI.dblGross,0)) FROM tblICInventoryReceipt IR 
							JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
							WHERE IR.ysnPosted = 1 AND IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
								AND (LC.intLoadContainerId IS NULL OR IRI.intContainerId = LC.intLoadContainerId)
								AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = 'Inventory Return') IRN
			WHERE 
				L.intLoadId = @intLoadId
				AND L.intPurchaseSale = 1
				AND (@intLoadContainerId IS NULL OR (@intLoadContainerId IS NOT NULL AND PC.intLoadContainerId = @intLoadContainerId))
				AND (@intContractDetailId IS NULL OR (@intContractDetailId IS NOT NULL AND PC.intContractDetailId = @intContractDetailId))
		
	END
END

GO