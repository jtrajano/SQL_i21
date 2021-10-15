CREATE VIEW vyuLGGetOpenWeightClaim
AS
SELECT
	intKeyColumn = PC.intPendingClaimId
	,PC.intPurchaseSale
	,strType = CASE WHEN PC.intPurchaseSale = 2 THEN 'Outbound' ELSE 'Inbound' END COLLATE Latin1_General_CI_AS
	,strContractNumber = CH.strContractNumber
	,intAging = DATEDIFF(DD, (CASE WHEN (PC.intPurchaseSale = 2) THEN INV.dtmDate ELSE ISNULL(PC.dtmReceiptDate, IR.dtmReceiptDate) END), GETDATE())
	,intContractTypeId = CH.intContractTypeId
	,intContractSeq = CD.intContractSeq
	,strEntityName = EM.strName
	,intEntityId = PC.intEntityId
	,intPartyEntityId = PC.intPartyEntityId
	,strPaidTo = CASE WHEN ISNULL(CD.ysnClaimsToProducer, 0) = 1
						THEN EMPD.strName
					WHEN ISNULL(CH.ysnClaimsToProducer, 0) = 1
						THEN EMPH.strName
					ELSE EM.strName END
	,intLoadId = PC.intLoadId
	,strLoadNumber = L.strLoadNumber
	,dtmScheduledDate = L.dtmScheduledDate
	,strTransportationMode = CASE L.intTransportationMode 
								WHEN 1 THEN 'Truck' 
								WHEN 2 THEN 'Ocean Vessel' 
								WHEN 3 THEN 'Rail' END COLLATE Latin1_General_CI_AS
	,dtmETAPOD = L.dtmETAPOD
	,dtmLastWeighingDate = L.dtmETAPOD + ISNULL(ASN.intLastWeighingDays, 0)
	,dtmClaimValidTill = CAST(NULL AS DATETIME)
	,intClaimValidTill = ISNULL(ASN.intClaimValidTill, 0)
	,strBLNumber = L.strBLNumber
	,dtmBLDate = L.dtmBLDate
	,intWeightUnitMeasureId = PC.intWeightUnitMeasureId
	,strWeightUOM = WUOM.strUnitMeasure
	,intWeightId = PC.intWeightId
	,strWeightGradeDesc = WG.strWeightGradeDesc
	,intLoadContainerId = PC.intLoadContainerId
	,strContainerNumber = LC.strContainerNumber
	,strMarks = LC.strMarks
	,dblShippedNetWt = PC.dblShippedNetWt
	,dblReceivedNetWt = PC.dblReceivedNetWt
	,dblReceivedGrossWt = PC.dblReceivedGrossWt
	,dblFranchisePercent = PC.dblFranchisePercent
	,dblFranchise = PC.dblFranchise
	,dblFranchiseWt = PC.dblFranchiseWt
	,dblWeightLoss = PC.dblWeightLoss
	,dblClaimableWt = PC.dblClaimableWt
	,dblClaimableAmount = PC.dblClaimableAmount
	,intWeightClaimId = CAST(NULL AS INT)
	,ysnWeightClaimed = CAST(0 AS BIT)
	,dblSeqPrice = PC.dblSeqPrice
	,strSeqCurrency = CUR.strCurrency
	,strSeqPriceUOM = SPUM.strUnitMeasure
	,intSeqCurrencyId = PC.intSeqCurrencyId
	,intSeqPriceUOMId = PC.intSeqPriceUOMId
	,intSeqBasisCurrencyId = PC.intSeqBasisCurrencyId
	,strSeqBasisCurrency = BCUR.strCurrency
	,ysnSeqSubCurrency = BCUR.ysnSubCurrency
	,dblSeqPriceInWeightUOM = PC.dblSeqPriceInWeightUOM
	,intItemId = PC.intItemId
	,intContractDetailId = PC.intContractDetailId
	,intBookId = CD.intBookId
	,strBook = BO.strBook
	,intSubBookId = CD.intSubBookId
	,strSubBook = SB.strSubBook
	,strReferenceNumber = CAST(NULL AS NVARCHAR(100)) COLLATE Latin1_General_CI_AS
	,dtmTransDate = CAST(NULL AS DATETIME)
	,dtmActualWeighingDate = CAST(NULL AS DATETIME)
	,strItemNo = I.strItemNo
	,strCommodityCode = I.strCommodityCode
	,strContractItemNo = CONI.strContractItemNo
	,strContractItemName = CONI.strContractItemName
	,strOrigin = ISNULL(OG.strCountry, I.strCountry)
	,dblSeqPriceConversionFactoryWeightUOM = PC.dblSeqPriceConversionFactoryWeightUOM
	,intContractBasisId = CH.intFreightTermId
	,strContractBasis = CB.strContractBasis
	,strERPPONumber = CD.strERPPONumber
	,strERPItemNumber = CD.strERPItemNumber
	,strSublocation = SL.strSubLocation
	,intPurchasingGroupId = CD.intPurchasingGroupId
	,strPurchasingGroupName = PG.strName
	,strPurchasingGroupDesc = PG.strDescription
	,dtmReceiptDate = ISNULL(PC.dtmReceiptDate, IR.dtmReceiptDate)
FROM tblLGPendingClaim PC
	JOIN tblLGLoad L ON L.intLoadId = PC.intLoadId
	JOIN tblICUnitMeasure WUOM ON WUOM.intUnitMeasureId = PC.intWeightUnitMeasureId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = PC.intContractDetailId
	JOIN vyuLGAdditionalColumnForContractDetailView AD ON AD.intContractDetailId = CD.intContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblEMEntity EM ON EM.intEntityId = PC.intEntityId
	JOIN tblCTWeightGrade WG ON WG.intWeightGradeId = PC.intWeightId
	CROSS APPLY (SELECT TOP 1 
					I.intItemId
					,I.strItemNo
					,C.strCommodityCode 
					,OG2.strCountry
				 FROM tblICItem I 
					INNER JOIN tblICCommodity C ON C.intCommodityId = I.intCommodityId
					LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = I.intOriginId
					LEFT JOIN tblSMCountry OG2 ON OG2.intCountryID = CA.intCountryID
				 WHERE intItemId = PC.intItemId) I
	LEFT JOIN tblICItemContract CONI ON CONI.intItemContractId = CD.intItemContractId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CONI.intCountryId
	LEFT JOIN tblEMEntity EMPH ON EMPH.intEntityId = CH.intProducerId
	LEFT JOIN tblEMEntity EMPD ON EMPD.intEntityId = CD.intProducerId
	LEFT JOIN tblCTAssociation ASN ON ASN.intAssociationId = CH.intAssociationId
	LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = PC.intSeqCurrencyId
	LEFT JOIN tblSMCurrency BCUR ON BCUR.intCurrencyID = PC.intSeqBasisCurrencyId
	LEFT JOIN tblICItemUOM SPUOM ON SPUOM.intItemUOMId = PC.intSeqPriceUOMId
	LEFT JOIN tblICUnitMeasure SPUM ON SPUM.intUnitMeasureId = SPUOM.intUnitMeasureId
	LEFT JOIN tblCTBook BO ON BO.intBookId = CD.intBookId
	LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = CD.intSubBookId
	LEFT JOIN tblSMFreightTerms CB ON CB.intFreightTermId = CH.intFreightTermId
	LEFT JOIN tblSMPurchasingGroup PG ON PG.intPurchasingGroupId = CD.intPurchasingGroupId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = PC.intLoadContainerId
	OUTER APPLY (SELECT dtmReceiptDate = MAX(IR.dtmReceiptDate) FROM tblICInventoryReceipt IR
				INNER JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptId = IR.intInventoryReceiptId
				WHERE IR.ysnPosted = 1 AND IRI.intLineNo = PC.intContractDetailId
					AND IRI.intOrderId = CH.intContractHeaderId AND IR.strReceiptType <> 'Inventory Return'
					AND (PC.intLoadContainerId IS NULL OR IRI.intContainerId = PC.intLoadContainerId)) IR
	OUTER APPLY (SELECT TOP 1 IV.dtmDate FROM tblARInvoice IV
					INNER JOIN tblARInvoiceDetail IVD ON IVD.intInvoiceId = IV.intInvoiceId
					WHERE IV.ysnPosted = 1 AND IVD.intContractDetailId = CD.intContractDetailId
						AND IVD.intContractHeaderId = CH.intContractHeaderId AND IV.strType = 'Standard' AND strTransactionType = 'Invoice'
						AND IVD.intLoadDetailId IN (SELECT intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = PC.intLoadId)
					) INV
	OUTER APPLY (SELECT TOP 1 strSubLocation = CLSL.strSubLocationName FROM tblLGLoadWarehouse LW 
		JOIN tblSMCompanyLocationSubLocation CLSL ON LW.intSubLocationId = CLSL.intCompanyLocationSubLocationId WHERE LW.intLoadId = PC.intLoadId) SL
GO
