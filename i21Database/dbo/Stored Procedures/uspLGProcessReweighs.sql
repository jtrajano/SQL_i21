﻿CREATE PROCEDURE [dbo].[uspLGProcessReweighs]
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

	IF (@intShipmentStatus <> 4)
	BEGIN
		--Upon Posting, if Shipment is not yet received, copy Quantities and Weights to Shipped Fields
		UPDATE tblLGLoadDetail
			SET dblShippedQuantity = dblQuantity
				,dblShippedGross = dblGross
				,dblShippedTare = dblTare
				,dblShippedNet = dblNet
		WHERE intLoadId = @intLoadId
			AND (@intContractDetailId IS NULL OR intPContractDetailId = @intContractDetailId)

		UPDATE tblLGLoadContainer
			SET dblShippedQuantity = dblQuantity
				,dblShippedGrossWt = dblGrossWt
				,dblShippedTareWt = dblTareWt
				,dblShippedNetWt = dblNetWt
		WHERE intLoadId = @intLoadId
			AND intLoadContainerId IN 
				(SELECT intLoadContainerId FROM tblLGLoadDetailContainerLink ldcl 
					INNER JOIN tblLGLoadDetail ld ON ld.intLoadDetailId = ldcl.intLoadDetailId
					WHERE (@intContractDetailId IS NULL OR ld.intPContractDetailId = @intContractDetailId))
	END
	ELSE
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
			SET dblQuantityToBill = LD.dblShippedQuantity
				,dblNetWeight = LD.dblShippedNet
		FROM tblAPVoucherPayable VP
			INNER JOIN tblLGLoad L ON L.intLoadId = VP.intLoadShipmentId
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = VP.intLoadShipmentDetailId
		WHERE VP.intLoadShipmentId = @intLoadId 
			AND VP.intLoadShipmentDetailId = LD.intLoadDetailId
			AND (@intContractDetailId IS NULL OR VP.intContractDetailId = @intContractDetailId)

		--Update Pending Claims with Shipped Fields values
		UPDATE PC
			SET dblShippedNetWt = (LC.dblShippedNetWt - ISNULL(IRN.dblIRNet, 0))
				,dblFranchiseWt = CASE WHEN (LC.dblShippedNetWt * WG.dblFranchise / 100) <> 0.0
										THEN (LC.dblShippedNetWt - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100
									ELSE 0.0 END
				,dblWeightLoss = RI.dblNet - LC.dblShippedNetWt
				,dblClaimableWt = CASE WHEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
									THEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100))
									ELSE (RI.dblNet - LC.dblShippedNetWt)
									END
				,dblClaimableAmount = ROUND(
										CASE WHEN (
												((CASE WHEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
													THEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100))
													ELSE (RI.dblNet - LC.dblShippedNetWt) END 
													* dblSeqPriceInWeightUOM) 
													/ CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) < 0)
												THEN ((CASE WHEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
														THEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100))
														ELSE (RI.dblNet - LC.dblShippedNetWt)
														END * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) * - 1
											ELSE ((CASE WHEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
													THEN ((RI.dblNet - LC.dblShippedNetWt) + (LD.dblNet * WG.dblFranchise / 100))
													ELSE (RI.dblNet - LC.dblShippedNetWt) END 
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
			LEFT JOIN tblLGLoadContainer LC ON LC.intLoadId = L.intLoadId AND L.intPurchaseSale = 1 AND CP.ysnWeightClaimsByContainer = 1
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
				AND (@intLoadContainerId IS NULL OR (@intLoadContainerId IS NOT NULL AND LC.intLoadContainerId = @intLoadContainerId))
				AND (@intContractDetailId IS NULL OR (@intContractDetailId IS NOT NULL AND PC.intContractDetailId = @intContractDetailId))
				AND LC.intLoadContainerId IS NULL OR (LC.intLoadContainerId IS NOT NULL AND PC.intLoadContainerId = LC.intLoadContainerId)

		
	END
END

GO