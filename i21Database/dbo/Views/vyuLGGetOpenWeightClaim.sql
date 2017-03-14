CREATE VIEW vyuLGGetOpenWeightClaim
AS
SELECT Top 100 percent Convert(int, ROW_NUMBER() OVER (ORDER BY intLoadId)) as intKeyColumn, 
	dblClaimableAmount = CASE WHEN ysnSeqSubCurrency = 1 THEN 
								dblClaimableWt * dblSeqPriceInWeightUOM / 100
							ELSE
								dblClaimableWt * dblSeqPriceInWeightUOM
							END, *
FROM (
	SELECT
	intPurchaseSale = Load.intPurchaseSale, 
	strType = CASE WHEN Load.intPurchaseSale = 1 THEN 'Inbound' ELSE CASE WHEN Load.intPurchaseSale = 2 THEN 'Outbound'  ELSE 'Drop Ship' END END,
	CH.strContractNumber,
	CD.intContractSeq,
	strEntityName = EM.strName,
	intEntityId = EM.intEntityId,
	intPartyEntityId = (CASE 
						WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
						THEN EMPD.intEntityId
						ELSE CASE 
							WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
								THEN EMPH.intEntityId
							ELSE EM.intEntityId
							END
						END),
	strPaidTo = (CASE 
				 WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
					THEN EMPD.strName
				 ELSE CASE 
						WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
							THEN EMPH.strName
						ELSE EM.strName
						END
				 END),
	Load.intLoadId,
	Load.strLoadNumber,
	Load.dtmScheduledDate,
	strTransportationMode = CASE WHEN Load.intPurchaseSale = 1 THEN 'Truck' ELSE 'Ocean Vessel' END,
	Load.dtmETAPOD,
	dtmLastWeighingDate = Load.dtmETAPOD + ISNULL(ASN.intLastWeighingDays,0),
	dtmClaimValidTill = NULL,
	intClaimValidTill = ISNULL(ASN.intClaimValidTill,0),
	Load.strBLNumber,
	Load.dtmBLDate,
	Load.intWeightUnitMeasureId,
	strWeightUOM = WUOM.strUnitMeasure,
	CH.intWeightId,
	WG.strWeightGradeDesc,
	dblShippedNetWt = LD.dblNet,
	dblReceivedNetWt = CASE Load.intPurchaseSale WHEN  1 THEN  RI.dblNet ELSE 0.0 END,
	dblFranchisePercent = WG.dblFranchise,
	dblFranchise = WG.dblFranchise / 100,
	dblFranchiseWt = CASE Load.intPurchaseSale WHEN  1 THEN
						CASE WHEN (LD.dblNet * dblFranchise/100) > 0.0 THEN
							(LD.dblNet * dblFranchise/100)
						ELSE
							0.0
						END
					ELSE
						0.0
					END,
	dblWeightLoss = CASE Load.intPurchaseSale WHEN  1 THEN
						CASE WHEN (LD.dblNet - RI.dblNet) > 0.0 THEN
							(LD.dblNet - RI.dblNet)
						ELSE
							0.0
						END
					ELSE
						0.0
					END,
	dblClaimableWt = CASE Load.intPurchaseSale WHEN  1 THEN
						CASE WHEN ((LD.dblNet - RI.dblNet) - (LD.dblNet * dblFranchise/100)) > 0.0 THEN
							((LD.dblNet - RI.dblNet) - (LD.dblNet * dblFranchise/100))
						ELSE
							0.0
						END
					ELSE
						0.0
					END,
	intWeightClaimId = WC.intWeightClaimId,
	ysnWeightClaimed = CASE WHEN IsNull(WC.intWeightClaimId, 0) <> 0 THEN CAST(1 AS bit) ELSE CAST(0 AS Bit) END,
	AD.dblSeqPrice,
	AD.strSeqCurrency,
	AD.strSeqPriceUOM,
	AD.intSeqCurrencyId,
	AD.intSeqPriceUOMId,
	AD.ysnSeqSubCurrency,
	dblSeqPriceInWeightUOM = dbo.fnCTConvertQtyToTargetItemUOM((SELECT Top(1) IU.intItemUOMId FROM tblICItemUOM IU WHERE IU.intItemId=CD.intItemId AND IU.intUnitMeasureId=WUOM.intUnitMeasureId),AD.intSeqPriceUOMId,AD.dblSeqPrice),
	CD.intItemId,
	CD.intContractDetailId,
	WC.strReferenceNumber,
	WC.dtmTransDate,
	WC.dtmActualWeighingDate,
	I.strItemNo,
	C.strCommodityCode,
	CONI.strContractItemNo,
	CONI.strContractItemName,
	OG.strCountry AS strOrigin

FROM tblLGLoad Load
JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = Load.intWeightUnitMeasureId
JOIN tblLGLoadDetail LD ON LD.intLoadId = Load.intLoadId
JOIN tblCTContractDetail CD ON CD.intContractDetailId = CASE Load.intPurchaseSale WHEN  1 THEN LD.intPContractDetailId ELSE LD.intSContractDetailId END
	CROSS
	APPLY	dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblEMEntity EM ON EM.intEntityId = CH.intEntityId
JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = CH.intWeightId 
JOIN tblICItem I ON I.intItemId = CD.intItemId
JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
LEFT JOIN tblICCommodityAttribute CA ON	CA.intCommodityAttributeId	= I.intOriginId	AND CA.strType = 'Origin'
LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
LEFT JOIN tblICItemContract CONI ON CONI.intItemContractId = CD.intItemContractId
LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
LEFT JOIN (
		SELECT SUM(ReceiptItem.dblNet) dblNet, ReceiptItem.intSourceId, ReceiptItem.intLineNo, ReceiptItem.intOrderId 
		FROM tblICInventoryReceiptItem ReceiptItem 
		GROUP BY ReceiptItem.intSourceId, ReceiptItem.intLineNo, ReceiptItem.intOrderId
	) RI ON RI.intSourceId = LD.intLoadDetailId AND RI.intLineNo = LD.intPContractDetailId AND RI.intOrderId = CH.intContractHeaderId AND Load.intPurchaseSale = 1
LEFT JOIN tblLGWeightClaim WC ON WC.intLoadId = Load.intLoadId
WHERE Load.intShipmentStatus = CASE Load.intPurchaseSale WHEN  1 THEN 4 ELSE 6 END AND IsNull(WC.intWeightClaimId, 0) = 0

) t1