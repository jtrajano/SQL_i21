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
FROM 
	--Inbound/Drop Ship side
	(SELECT intPurchaseSale = 1 
		,strType = 'Inbound' COLLATE Latin1_General_CI_AS
		,strContractNumber = CH.strContractNumber
		,intContractTypeId = CH.intContractTypeId
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
		,intLoadId = LOAD.intLoadId
		,strLoadNumber = LOAD.strLoadNumber
		,dtmScheduledDate = LOAD.dtmScheduledDate
		,strTransportationMode = CASE 
			WHEN LOAD.intPurchaseSale = 1
				THEN 'Truck'
			ELSE 'Ocean Vessel'
			END
		,dtmETAPOD = LOAD.dtmETAPOD
		,dtmLastWeighingDate = LOAD.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dtmClaimValidTill = NULL
		,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
		,strBLNumber = LOAD.strBLNumber
		,dtmBLDate = LOAD.dtmBLDate
		,intWeightUnitMeasureId = LOAD.intWeightUnitMeasureId
		,strWeightUOM = WUOM.strUnitMeasure
		,intWeightId = CH.intWeightId
		,strWeightGradeDesc = WG.strWeightGradeDesc
		,dblShippedNetWt = (CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0))
		,dblReceivedNetWt = (RI.dblNet - ISNULL(IRN.dblIRNet, 0))
		,dblFranchisePercent = WG.dblFranchise
		,dblFranchise = WG.dblFranchise / 100
		,dblFranchiseWt = CASE WHEN (CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) > 0.0
							THEN ((CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100)
						ELSE 0.0 END
		,dblWeightLoss = CASE WHEN (RI.dblNet - CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) < 0.0
							THEN (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
						ELSE (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) END
		,dblClaimableWt = CASE WHEN ((RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
							THEN ((RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100))
							ELSE (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
						END
		,intWeightClaimId = WC.intWeightClaimId
		,ysnWeightClaimed = CAST(CASE WHEN IsNull(WC.intWeightClaimId, 0) <> 0 THEN 1 ELSE 0 END AS BIT)
		,dblSeqPrice = AD.dblSeqPrice
		,strSeqCurrency = AD.strSeqCurrency
		,strSeqPriceUOM = AD.strSeqPriceUOM
		,intSeqCurrencyId = AD.intSeqCurrencyId
		,intSeqPriceUOMId = AD.intSeqPriceUOMId
		,ysnSeqSubCurrency = AD.ysnSeqSubCurrency
		,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, AD.dblSeqPrice)
		,intItemId = CD.intItemId
		,intContractDetailId = CD.intContractDetailId
		,intBookId = CD.intBookId
		,strBook = BO.strBook
		,intSubBookId = CD.intSubBookId
		,strSubBook = SB.strSubBook
		,strReferenceNumber = WC.strReferenceNumber
		,dtmTransDate = WC.dtmTransDate
		,dtmActualWeighingDate = WC.dtmActualWeighingDate
		,strItemNo = I.strItemNo
		,strCommodityCode = C.strCommodityCode
		,strContractItemNo = CONI.strContractItemNo
		,strContractItemName = CONI.strContractItemName
		,strOrigin = OG.strCountry
		,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, 1)
		,intContractBasisId = CH.intContractBasisId
		,strContractBasis = CB.strContractBasis
		,strERPPONumber = CD.strERPPONumber
		,strERPItemNumber = CD.strERPItemNumber
		,strSublocation = (SELECT CLSL.strSubLocationName
							  FROM tblLGLoadWarehouse LW
							  JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
							  WHERE LW.intLoadId = LOAD.intLoadId) 
		,CD.intPurchasingGroupId
		,PG.strName AS strPurchasingGroupName
		,PG.strDescription AS strPurchasingGroupDesc
	FROM tblLGLoad LOAD
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = LOAD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = intPContractDetailId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId AND CA.strType = 'Origin'
	LEFT JOIN tblICItemContract CONI ON CONI.intItemId = I.intItemId AND CD.intItemContractId = CONI.intItemContractId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID  = (
		CASE 
			WHEN ISNULL(CONI.intCountryId, 0) = 0
				THEN ISNULL(CA.intCountryID, 0)
			ELSE CONI.intCountryId
			END
		)
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
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
		AND LOAD.intPurchaseSale IN (1, 3)
	LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = LOAD.intLoadId AND WC.intPurchaseSale = 1
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	CROSS APPLY (SELECT intCount = COUNT(*) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLCT
	CROSS APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
	CROSS APPLY (SELECT dblIRNet = SUM(IRI.dblNet) FROM tblICInventoryReceipt IR 
					JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
						AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = 'Inventory Return') IRN
	WHERE LOAD.intPurchaseSale IN (1, 3)
		AND (LOAD.intShipmentStatus = CASE LOAD.intPurchaseSale 
										WHEN 1 THEN 4 
										WHEN 3 THEN 6 
										ELSE 6 END
		OR LOAD.intShipmentStatus = CASE LOAD.intPurchaseSale 
										WHEN 3 THEN 11 END)
		AND ISNULL(WC.intWeightClaimId, 0) = 0
		AND ISNULL(LD.ysnNoClaim, 0) = 0
	
	UNION ALL

	--Outbound/Dropship Side
	SELECT intPurchaseSale = 2 
		,strType = 'Outbound' COLLATE Latin1_General_CI_AS
		,strContractNumber = CH.strContractNumber
		,intContractTypeId = CH.intContractTypeId
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
		,intLoadId = LOAD.intLoadId
		,strLoadNumber = LOAD.strLoadNumber
		,dtmScheduledDate = LOAD.dtmScheduledDate
		,strTransportationMode = CASE 
			WHEN LOAD.intPurchaseSale = 1
				THEN 'Truck'
			ELSE 'Ocean Vessel'
			END COLLATE Latin1_General_CI_AS
		,dtmETAPOD = LOAD.dtmETAPOD
		,dtmLastWeighingDate = LOAD.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
		,dtmClaimValidTill = NULL
		,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
		,strBLNumber = LOAD.strBLNumber
		,dtmBLDate = LOAD.dtmBLDate
		,intWeightUnitMeasureId = LOAD.intWeightUnitMeasureId
		,strWeightUOM = WUOM.strUnitMeasure
		,intWeightId = CH.intWeightId
		,strWeightGradeDesc = WG.strWeightGradeDesc
		,dblShippedNetWt = (CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0))
		,dblReceivedNetWt = (RI.dblNet - ISNULL(IRN.dblIRNet, 0))
		,dblFranchisePercent = WG.dblFranchise
		,dblFranchise = WG.dblFranchise / 100
		,dblFranchiseWt = CASE WHEN (CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END * WG.dblFranchise / 100) > 0.0
							THEN ((CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END - ISNULL(IRN.dblIRNet, 0)) * WG.dblFranchise / 100)
						ELSE 0.0 END
		,dblWeightLoss = CASE WHEN (RI.dblNet - CASE WHEN (CLCT.intCount > 0) THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) < 0.0
							THEN (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
						ELSE (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) END
		,dblClaimableWt = CASE WHEN ((RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100)) < 0.0
							THEN ((RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END) + (LD.dblNet * WG.dblFranchise / 100))
							ELSE (RI.dblNet - CASE WHEN (CLCT.intCount) > 0 THEN (CLNW.dblLinkNetWt) ELSE LD.dblNet END)
						END
		,intWeightClaimId = WC.intWeightClaimId
		,ysnWeightClaimed = CAST(CASE WHEN IsNull(WC.intWeightClaimId, 0) <> 0 THEN 1 ELSE 0 END AS BIT)
		,dblSeqPrice = AD.dblSeqPrice
		,strSeqCurrency = AD.strSeqCurrency
		,strSeqPriceUOM = AD.strSeqPriceUOM
		,intSeqCurrencyId = AD.intSeqCurrencyId
		,intSeqPriceUOMId = AD.intSeqPriceUOMId
		,ysnSeqSubCurrency = AD.ysnSeqSubCurrency
		,dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, AD.dblSeqPrice)
		,intItemId = CD.intItemId
		,intContractDetailId = CD.intContractDetailId
		,intBookId = CD.intBookId
		,strBook = BO.strBook
		,intSubBookId = CD.intSubBookId
		,strSubBook = SB.strSubBook
		,strReferenceNumber = WC.strReferenceNumber
		,dtmTransDate = WC.dtmTransDate
		,dtmActualWeighingDate = WC.dtmActualWeighingDate
		,strItemNo = I.strItemNo
		,strCommodityCode = C.strCommodityCode
		,strContractItemNo = CONI.strContractItemNo
		,strContractItemName = CONI.strContractItemName
		,strOrigin = OG.strCountry
		,dblSeqPriceConversionFactoryWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((
				SELECT TOP (1) IU.intItemUOMId
				FROM tblICItemUOM IU
				WHERE IU.intItemId = CD.intItemId
					AND IU.intUnitMeasureId = WUOM.intUnitMeasureId
				), AD.intSeqPriceUOMId, 1)
		,intContractBasisId = CH.intContractBasisId
		,strContractBasis = CB.strContractBasis
		,strERPPONumber = CD.strERPPONumber
		,strERPItemNumber = CD.strERPItemNumber
		,strSublocation = (SELECT CLSL.strSubLocationName
							  FROM tblLGLoadWarehouse LW
							  JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId
							  WHERE LW.intLoadId = LOAD.intLoadId) 
		,CD.intPurchasingGroupId
		,PG.strName AS strPurchasingGroupName
		,PG.strDescription AS strPurchasingGroupDesc
	FROM tblLGLoad LOAD
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = LOAD.intWeightUnitMeasureId
	JOIN tblLGLoadDetail LD ON LD.intLoadId = LOAD.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = intSContractDetailId
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
	LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId AND CA.strType = 'Origin'
	LEFT JOIN tblICItemContract CONI ON CONI.intItemId = I.intItemId AND CD.intItemContractId = CONI.intItemContractId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID  = (
		CASE 
			WHEN ISNULL(CONI.intCountryId, 0) = 0
				THEN ISNULL(CA.intCountryID, 0)
			ELSE CONI.intCountryId
			END
		)
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
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
		AND RI.intLineNo = LD.intSContractDetailId
		AND RI.intOrderId = CH.intContractHeaderId
		AND LOAD.intPurchaseSale IN (2, 3)
	LEFT JOIN tblLGWeightClaimDetail WCD ON WCD.intContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = LOAD.intLoadId AND WC.intPurchaseSale = 2
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	CROSS APPLY (SELECT intCount = COUNT(*) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLCT
	CROSS APPLY (SELECT dblLinkNetWt = SUM(dblLinkNetWt) FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = LD.intLoadDetailId) CLNW
	CROSS APPLY (SELECT dblIRNet = SUM(IRI.dblNet) FROM tblICInventoryReceipt IR 
					JOIN tblICInventoryReceiptItem IRI ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
					WHERE IRI.intSourceId = LD.intLoadDetailId AND IRI.intLineNo = CD.intContractDetailId
						AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType = 'Inventory Return') IRN
	WHERE LOAD.intPurchaseSale IN (2, 3)
		AND (LOAD.intShipmentStatus = 6 OR LOAD.intShipmentStatus = CASE LOAD.intPurchaseSale WHEN 3 THEN 11 END)
		AND ISNULL(WC.intWeightClaimId, 0) = 0
		AND ISNULL(LD.ysnNoClaim, 0) = 0
	) t1