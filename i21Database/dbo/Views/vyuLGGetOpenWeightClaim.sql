CREATE VIEW vyuLGGetOpenWeightClaim
AS
SELECT TOP 100 PERCENT Convert(INT, ROW_NUMBER() OVER (
			ORDER BY intLoadId
			)) AS intKeyColumn
	,dblClaimableAmount = CASE WHEN ((CASE WHEN ysnSeqSubCurrency = 1
										THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
										ELSE dblClaimableWt * dblSeqPriceInWeightUOM END) < 0)
								THEN (CASE WHEN ysnSeqSubCurrency = 1
										THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
										ELSE dblClaimableWt * dblSeqPriceInWeightUOM END) * - 1
								ELSE (CASE WHEN ysnSeqSubCurrency = 1
										THEN dblClaimableWt * dblSeqPriceInWeightUOM / 100
										ELSE dblClaimableWt * dblSeqPriceInWeightUOM END)
								END
	,*
FROM (
	SELECT intPurchaseSale = L.intPurchaseSale
		,strType = CASE WHEN L.intPurchaseSale = 1 THEN 'Inbound' ELSE 
					CASE WHEN L.intPurchaseSale = 2 THEN 'Outbound'
					ELSE 'Drop Ship' END
					END COLLATE Latin1_General_CI_AS 
		,strContractNumber = CH.strContractNumber
		,intContractSeq = CD.intContractSeq
		,strEntityName = EM.strName
		,intEntityId = EM.intEntityId
		,intPartyEntityId = ISNULL((
				CASE 
					WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
						THEN EMPD.intEntityId
					ELSE CASE 
							WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
								THEN EMPH.intEntityId
							ELSE EM.intEntityId
							END
					END
				), 0)
		,strPaidTo = (
			CASE 
				WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
					THEN EMPD.strName
				ELSE CASE 
						WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
							THEN EMPH.strName
						ELSE EM.strName
						END
				END
			)
		,L.intLoadId
		,L.strLoadNumber
		,L.dtmScheduledDate
		,strTransportationMode = CASE WHEN L.intPurchaseSale = 1 THEN 'Truck' ELSE 'Ocean Vessel' END COLLATE Latin1_General_CI_AS
		,L.dtmETAPOD
		,dtmLastWeighingDate = L.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dtmClaimValidTill = NULL
		,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
		,L.strBLNumber
		,L.dtmBLDate
		,L.intWeightUnitMeasureId
		,strWeightUOM = WUOM.strUnitMeasure
		,CH.intWeightId
		,WG.strWeightGradeDesc
		,dblShippedNetWt = (ISNULL(CLNW.dblLinkNetWt, LD.dblNet) - ISNULL(IRN.dblIRNet, 0))
		,dblReceivedNetWt = ((CASE L.intPurchaseSale WHEN 1 THEN RI.dblNet ELSE 0.0 END) - ISNULL(IRN.dblIRNet, 0))
		,dblFranchisePercent = WG.dblFranchise
		,dblFranchise = WG.dblFranchise / 100
		,dblFranchiseWt = CASE L.intPurchaseSale WHEN 1
								THEN CASE WHEN (ISNULL(CLNW.dblLinkNetWt, LD.dblNet) * WG.dblFranchise / 100) > 0.0
											THEN ((ISNULL(CLNW.dblLinkNetWt, LD.dblNet) - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100)
										ELSE 0.0 END
						  ELSE 0.0 END
		,dblWeightLoss = CASE L.intPurchaseSale WHEN 1
				THEN CASE WHEN (RI.dblNet - ISNULL(CLNW.dblLinkNetWt, LD.dblNet)) < 0.0
							THEN (RI.dblNet - ISNULL(CLNW.dblLinkNetWt, LD.dblNet))
						ELSE (RI.dblNet - ISNULL(CLNW.dblLinkNetWt, LD.dblNet)) END
				ELSE 0.0 END
		,dblClaimableWt = CASE L.intPurchaseSale WHEN 1
				THEN CASE WHEN ((RI.dblNet - ISNULL(CLNW.dblLinkNetWt, LD.dblNet)) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
							THEN ((RI.dblNet - ISNULL(CLNW.dblLinkNetWt, LD.dblNet)) + (LD.dblNet * WG.dblFranchise / 100))
							ELSE (RI.dblNet - ISNULL(CLNW.dblLinkNetWt, LD.dblNet))
						END
				ELSE 0.0 END
		,intWeightClaimId = WC.intWeightClaimId
		,ysnWeightClaimed = CAST(CASE WHEN ISNULL(WC.intWeightClaimId, 0) <> 0 THEN 1 ELSE 0 END AS BIT)
		,AD.dblSeqPrice
		,AD.strSeqCurrency
		,AD.strSeqPriceUOM
		,AD.intSeqCurrencyId
		,AD.intSeqPriceUOMId
		,AD.ysnSeqSubCurrency
		,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, AD.dblSeqPrice)
		,CD.intItemId
		,CD.intContractDetailId
		,WC.strReferenceNumber
		,WC.dtmTransDate
		,WC.dtmActualWeighingDate
		,I.strItemNo
		,C.strCommodityCode
		,CONI.strContractItemNo
		,CONI.strContractItemName
		,OG.strCountry AS strOrigin
		,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, 1)
		,CH.intContractBasisId
		,CB.strContractBasis
		,CD.strERPPONumber
		,CD.strERPItemNumber
		,(SELECT CLSL.strSubLocationName
		  FROM tblLGLoadWarehouse LW
		  JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
		  WHERE LW.intLoadId = L.intLoadId) strSublocation
		,CD.intPurchasingGroupId
		,PG.strName AS strPurchasingGroupName
		,PG.strDescription AS strPurchasingGroupDesc
	FROM tblLGLoad L
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = L.intWeightUnitMeasureId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE L.intPurchaseSale
			WHEN 1
				THEN LD.intPContractDetailId
			ELSE LD.intSContractDetailId
			END
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId AND CA.strType = 'Origin'
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
	LEFT JOIN tblICItemContract CONI ON CONI.intItemContractId = CD.intItemContractId
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN (
		SELECT SUM(ReceiptItem.dblNet) dblNet
			,ReceiptItem.intSourceId
			,ReceiptItem.intLineNo
			,ReceiptItem.intOrderId
		FROM tblICInventoryReceiptItem ReceiptItem
		JOIN tblICInventoryReceipt RI ON RI.intInventoryReceiptId = ReceiptItem.intInventoryReceiptId
		WHERE RI.strReceiptType <> 'Inventory Return'
		GROUP BY ReceiptItem.intSourceId
			,ReceiptItem.intLineNo
			,ReceiptItem.intOrderId
		) RI ON RI.intSourceId = LD.intLoadDetailId
		AND RI.intLineNo = LD.intPContractDetailId
		AND RI.intOrderId = CH.intContractHeaderId
		AND L.intPurchaseSale = 1
	LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = L.intLoadId
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	CROSS APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
	CROSS APPLY (SELECT dblIRNet = SUM(IRI.dblNet) FROM tblICInventoryReceipt IR 
					JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
						AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = 'Inventory Return') IRN
	WHERE L.intShipmentStatus = CASE L.intPurchaseSale WHEN 1 THEN 4 ELSE 6 END
		AND ISNULL(WC.intWeightClaimId, 0) = 0
		AND ISNULL(LD.ysnNoClaim, 0) = 0
	) t1