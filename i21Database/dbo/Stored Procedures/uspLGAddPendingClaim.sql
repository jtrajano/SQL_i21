CREATE PROCEDURE uspLGAddPendingClaim
	@intLoadId INT
	,@intPurchaseSale INT
	,@ysnAddClaim BIT = 1
AS
BEGIN

	IF (@ysnAddClaim = 1)
	BEGIN
		IF (@intPurchaseSale IN (1, 3))
		BEGIN
			--Inbound/Drop Ship side
			INSERT INTO tblLGPendingClaim 
				([intPurchaseSale]
				,[intLoadId]
				,[intContractDetailId]
				,[intEntityId]
				,[intPartyEntityId]
				,[intWeightId]
				,[intItemId]
				,[intWeightUnitMeasureId]
				,[dblShippedNetWt]
				,[dblReceivedNetWt]
				,[dblReceivedGrossWt]
				,[dblFranchisePercent]
				,[dblFranchise]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,[dblClaimableAmount]
				,[dblSeqPrice]
				,[intSeqCurrencyId]
				,[intSeqPriceUOMId]
				,[intSeqBasisCurrencyId]
				,[ysnSeqSubCurrency]
				,[dblSeqPriceInWeightUOM]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[dtmDateAdded]
				)
			SELECT 
				[intPurchaseSale] = 1
				,[intLoadId]
				,[intContractDetailId]
				,[intEntityId]
				,[intPartyEntityId]
				,[intWeightId]
				,[intItemId]
				,[intWeightUnitMeasureId]
				,[dblShippedNetWt]
				,[dblReceivedNetWt]
				,[dblReceivedGrossWt]
				,[dblFranchisePercent]
				,[dblFranchise]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,[dblClaimableAmount] = ROUND(CASE WHEN (((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) < 0)
									THEN ((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) * - 1
									ELSE ((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END)
									END, 2)
				,[dblSeqPrice]
				,[intSeqCurrencyId]
				,[intSeqPriceUOMId]
				,[intSeqBasisCurrencyId]
				,[ysnSeqSubCurrency]
				,[dblSeqPriceInWeightUOM]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[dtmDateAdded] = GETDATE()
			FROM 
				(SELECT 
					intEntityId = EM.intEntityId
					,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
												THEN EMPD.intEntityId
											WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
												THEN EMPH.intEntityId
											ELSE EM.intEntityId END
					,intLoadId = L.intLoadId
					,intWeightUnitMeasureId = L.intWeightUnitMeasureId
					,intWeightId = CH.intWeightId
					,dblShippedNetWt = (CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0))
					,dblReceivedNetWt = (RI.dblNet - ISNULL(IRN.dblIRNet, 0))
					,dblReceivedGrossWt = (RI.dblGross - ISNULL(IRN.dblIRGross, 0))
					,dblFranchisePercent = WG.dblFranchise
					,dblFranchise = WG.dblFranchise / 100
					,dblFranchiseWt = CASE WHEN (CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) <> 0.0
										THEN ((CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100)
									ELSE 0.0 END
					,dblWeightLoss = CASE WHEN (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) < 0.0
										THEN (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
									ELSE (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) END
					,dblClaimableWt = CASE WHEN ((RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
										THEN ((RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100))
										ELSE (RI.dblNet - CASE WHEN (CLNW.dblLinkNetWt IS NOT NULL) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
									END
					,dblSeqPrice = AD.dblSeqPrice
					,strSeqCurrency = AD.strSeqCurrency
					,strSeqPriceUOM = AD.strSeqPriceUOM
					,intSeqCurrencyId = AD.intSeqCurrencyId
					,intSeqPriceUOMId = ISNULL(CD.intPriceItemUOMId,CD.intAdjItemUOMId)
					,intSeqBasisCurrencyId = AD.intSeqBasisCurrencyId
					,strSeqBasisCurrency = BCUR.strCurrency 
					,ysnSeqSubCurrency = BCUR.ysnSubCurrency
					,dblSeqPriceInWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty) * AD.dblSeqPrice
					,intItemId = LD.intItemId
					,intContractDetailId = CD.intContractDetailId
					,dblSeqPriceConversionFactoryWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty)
				FROM tblLGLoad L
					JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = intPContractDetailId
					JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
					JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
					LEFT JOIN tblSMCurrency BCUR ON BCUR.intCurrencyID = AD.intSeqBasisCurrencyId
					LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
					LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
					OUTER APPLY (SELECT TOP 1 intWeightClaimId = WC.intWeightClaimId 
						FROM tblLGWeightClaim WC INNER JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId 
						WHERE WCD.intContractDetailId = LD.intPContractDetailId AND WC.intLoadId = L.intLoadId AND WC.intPurchaseSale = 1) WC
					OUTER APPLY (SELECT TOP 1 intWeightUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = L.intWeightUnitMeasureId) WUI
					OUTER APPLY (SELECT TOP 1 intPriceUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemUOMId = AD.intSeqPriceUOMId) PUI
					OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = L.intLoadId) SL
					OUTER APPLY (SELECT dblLinkNetWt = SUM(ISNULL(dblLinkNetWt, 0)) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
					CROSS APPLY (SELECT dblNet = SUM(ISNULL(IRI.dblNet,0)),dblGross = SUM(ISNULL(IRI.dblGross,0)) FROM tblICInventoryReceipt IR 
									JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
									WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
										AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType <> 'Inventory Return') RI
					CROSS APPLY (SELECT dblIRNet = SUM(ISNULL(IRI.dblNet,0)),dblIRGross = SUM(ISNULL(IRI.dblGross,0)) FROM tblICInventoryReceipt IR 
									JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
									WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
										AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = 'Inventory Return') IRN
					WHERE 
						L.intLoadId = @intLoadId
						AND L.intPurchaseSale IN (1, 3)
						AND ((L.intPurchaseSale = 1 AND L.intShipmentStatus = 4) OR (L.intPurchaseSale <> 1 AND L.intShipmentStatus IN (6,11)))
						AND WC.intWeightClaimId IS NULL
						AND (LD.ysnNoClaim IS NULL OR LD.ysnNoClaim = 0)
						AND NOT EXISTS (SELECT TOP 1 1 FROM tblLGPendingClaim WHERE intLoadId = @intLoadId AND intPurchaseSale = @intPurchaseSale)
					) LI
			END

		IF (@intPurchaseSale IN (2, 3))
		BEGIN
		--Outbound/Drop Ship side
			INSERT INTO tblLGPendingClaim 
				([intPurchaseSale]
				,[intLoadId]
				,[intContractDetailId]
				,[intEntityId]
				,[intPartyEntityId]
				,[intWeightId]
				,[intItemId]
				,[intWeightUnitMeasureId]
				,[dblShippedNetWt]
				,[dblReceivedNetWt]
				,[dblReceivedGrossWt]
				,[dblFranchisePercent]
				,[dblFranchise]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,[dblClaimableAmount]
				,[dblSeqPrice]
				,[intSeqCurrencyId]
				,[intSeqPriceUOMId]
				,[intSeqBasisCurrencyId]
				,[ysnSeqSubCurrency]
				,[dblSeqPriceInWeightUOM]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[dtmDateAdded]
				)
			SELECT 
				[intPurchaseSale] = 2
				,[intLoadId]
				,[intContractDetailId]
				,[intEntityId]
				,[intPartyEntityId]
				,[intWeightId]
				,[intItemId]
				,[intWeightUnitMeasureId]
				,[dblShippedNetWt]
				,[dblReceivedNetWt]
				,[dblReceivedGrossWt]
				,[dblFranchisePercent]
				,[dblFranchise]
				,[dblWeightLoss]
				,[dblClaimableWt]
				,[dblClaimableAmount] = ROUND(CASE WHEN (((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) < 0)
									THEN ((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END) * - 1
									ELSE ((dblClaimableWt * dblSeqPriceInWeightUOM) / CASE WHEN ysnSeqSubCurrency = 1 THEN 100 ELSE 1 END)
									END, 2)
				,[dblSeqPrice]
				,[intSeqCurrencyId]
				,[intSeqPriceUOMId]
				,[intSeqBasisCurrencyId]
				,[ysnSeqSubCurrency]
				,[dblSeqPriceInWeightUOM]
				,[dblSeqPriceConversionFactoryWeightUOM]
				,[dtmDateAdded] = GETDATE()
			FROM 
				(SELECT
					intEntityId = EM.intEntityId
					,intPartyEntityId = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
												THEN EMPD.intEntityId
											WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
												THEN EMPH.intEntityId
											ELSE EM.intEntityId END
					,intLoadId = L.intLoadId
					,intWeightUnitMeasureId = L.intWeightUnitMeasureId
					,intWeightId = CH.intWeightId
					,dblShippedNetWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END
					,dblReceivedNetWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END
					,dblReceivedGrossWt = CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkGrossWt) ELSE LD.dblGross END
					,dblFranchisePercent = WG.dblFranchise
					,dblFranchise = WG.dblFranchise / 100
					,dblFranchiseWt = CASE WHEN (CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) <> 0.0
										THEN ((CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) * WG.dblFranchise / 100)
									ELSE 0.0 END
					,dblWeightLoss = CAST(0.0 AS NUMERIC(18, 6))
					,dblClaimableWt = CAST(0.0 AS NUMERIC(18, 6))
					,dblSeqPrice = AD.dblSeqPrice
					,strSeqCurrency = AD.strSeqCurrency
					,strSeqPriceUOM = AD.strSeqPriceUOM
					,intSeqCurrencyId = AD.intSeqCurrencyId
					,intSeqPriceUOMId = AD.intSeqPriceUOMId
					,intSeqBasisCurrencyId = AD.intSeqBasisCurrencyId
					,strSeqBasisCurrency = BCUR.strCurrency 
					,ysnSeqSubCurrency = BCUR.ysnSubCurrency
					,dblSeqPriceInWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty) * AD.dblSeqPrice
					,intItemId = CD.intItemId
					,intContractDetailId = CD.intContractDetailId
					,dblSeqPriceConversionFactoryWeightUOM = (WUI.dblUnitQty / PUI.dblUnitQty)
				FROM tblLGLoad L
					JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
					JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
					JOIN tblCTContractDetail CD ON CD.intContractDetailId = intSContractDetailId
					JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
					JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
					JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
					JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
					LEFT JOIN tblSMCurrency BCUR ON BCUR.intCurrencyID = AD.intSeqBasisCurrencyId
					LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
					LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
					LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
					OUTER APPLY (SELECT TOP 1 intWeightClaimId = WC.intWeightClaimId 
						FROM tblLGWeightClaim WC INNER JOIN tblLGWeightClaimDetail WCD ON WC.intWeightClaimId = WCD.intWeightClaimId 
						WHERE WCD.intContractDetailId = CD.intContractDetailId AND WC.intLoadId = L.intLoadId AND WC.intPurchaseSale = 2) WC
					OUTER APPLY (SELECT TOP 1 intWeightUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemId = CD.intItemId AND IU.intUnitMeasureId = WUOM.intUnitMeasureId) WUI
					OUTER APPLY (SELECT TOP 1 intPriceUOMId = IU.intItemUOMId, dblUnitQty FROM tblICItemUOM IU WHERE IU.intItemUOMId = AD.intSeqPriceUOMId) PUI
					OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = L.intLoadId) SL
					OUTER APPLY (SELECT intCount = COUNT(1) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLCT
					OUTER APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt),dblLinkGrossWt = SUM(dblLinkGrossWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
					WHERE L.intLoadId = @intLoadId
						AND L.intPurchaseSale IN (2, 3)
						AND L.intShipmentStatus IN (6, 11)
						AND WC.intWeightClaimId IS NULL
						AND (LD.ysnNoClaim IS NULL OR LD.ysnNoClaim = 0)
						AND NOT EXISTS (SELECT TOP 1 1 FROM tblLGPendingClaim WHERE intLoadId = @intLoadId AND intPurchaseSale = @intPurchaseSale)
					) LO
			END
		END
	ELSE
	BEGIN
		DELETE FROM tblLGPendingClaim WHERE intLoadId = @intLoadId AND intPurchaseSale = @intPurchaseSale
	END

END

GO