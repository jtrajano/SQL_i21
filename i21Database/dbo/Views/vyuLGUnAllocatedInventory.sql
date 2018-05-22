CREATE VIEW vyuLGUnAllocatedInventory
AS
SELECT CD.intContractDetailId
	,CH.strContractNumber
	,CD.intContractSeq
	,L.strLoadNumber
	,CD.dtmStartDate
	,CD.dtmEndDate
	,PO.strPosition
	,SUM(CD.dblQuantity) AS dblContractDetailQty
	,SUM(IRIL.dblQuantity) AS dblReceiptQty
	,SUM(CD.dblQuantity) - SUM(ISNULL(CD.dblAllocatedQty, 0)) AS dblUnAllocatedQty
	,SUM(CD.dblAllocatedQty) AS dblAllocatedQty
	,RES.dblReservedQuantity
	,RUM.strUnitMeasure AS strReservedUOM
	,USR.strName AS strReservedBy
	,L.intLoadId
	,strPOStatus = CASE 
		WHEN PO.strPosition = 'Shipment'
			THEN CASE 
					WHEN ISNULL(IR.intInventoryReceiptId, 0) > 0
						THEN 'W'
					ELSE CASE 
							WHEN ISNULL(L.intLoadId, 0) > 0
								THEN 'A'
							ELSE CASE 
									WHEN ISNULL(L.intLoadId, 0) = 0
										THEN 'O'
									END
							END
					END
		WHEN PO.strPosition IN (
				'Delivery'
				,'Spot'
				)
			THEN 'W'
		END
	,CO.strCountry AS strOrigin
	,PT.strDescription AS strProductType
	,IM.strItemNo
	,IM.strDescription AS strItemDescription
	,CD.strItemSpecification
	,CY.strCropYear
	,L.strMVessel
	,L.strMVoyageNumber
	,L.strFVessel
	,L.strFVoyageNumber
	,L.dtmETAPOD
	,CLSL.strSubLocationName AS strWarehouse
	,CLSL.strCity AS strWarehouseCity
	,IR.dtmReceiptDate
	,AD.dblSeqPrice
	,AD.dblCostUnitQty
	,AD.strSeqCurrency
	,AD.strSeqPriceUOM
	,AD.strSeqCurrency + ' per ' + AD.strSeqPriceUOM AS strPriceBasis
	,CD.dblBasis AS dblDifferential
	,CB.strContractBasis
	,TER.strName AS strTerminal
	,FM.strFutureMonth
	,IRI.strComments
	,IRIL.strLotNumber
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CH.intContractHeaderId = CD.intContractHeaderId
	AND CH.intContractTypeId = 1
CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intLineNo = CD.intContractDetailId
LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = IRI.intSubLocationId
LEFT JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
LEFT JOIN tblRKFuturesMonth FM ON FM.intFutureMonthId = CD.intFutureMonthId
LEFT JOIN tblLGLoadDetail LD ON LD.intPContractDetailId = CD.intContractDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND L.intShipmentType = 1
LEFT JOIN tblLGReservation RES ON RES.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblICUnitMeasure RUM ON RUM.intUnitMeasureId = RES.intUnitMeasureId
LEFT JOIN tblEMEntity TER ON TER.intEntityId = L.intTerminalEntityId
LEFT JOIN tblEMEntity USR ON USR.intEntityId = RES.intUserSecurityId
LEFT JOIN tblICItem IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblICItemContract ICI ON ICI.intItemId = IM.intItemId
	AND CD.intItemContractId = ICI.intItemContractId
LEFT JOIN tblSMCountry CO ON CO.intCountryID = (
		CASE 
			WHEN ISNULL(ICI.intCountryId, 0) = 0
				THEN ISNULL(CA.intCountryID, 0)
			ELSE ICI.intCountryId
			END
		)
LEFT JOIN tblICCommodityAttribute PT ON PT.intCommodityAttributeId = IM.intProductTypeId
	AND PT.strType = 'ProductType'
LEFT JOIN tblCTCropYear CY ON CY.intCropYearId = CH.intCropYearId
GROUP BY CH.strContractNumber
	,CD.intContractSeq
	,CO.strCountry
	,PT.strDescription
	,IM.strItemNo
	,IM.strDescription
	,CD.strItemSpecification
	,CY.strCropYear
	,L.strLoadNumber
	,L.strMVessel
	,L.strMVoyageNumber
	,L.strFVessel
	,L.strFVoyageNumber
	,L.dtmETAPOD
	,CLSL.strSubLocationName
	,CLSL.strCity
	,IRI.dtmDateCreated
	,AD.dblSeqPrice
	,AD.dblCostUnitQty
	,AD.strSeqCurrency
	,AD.strSeqPriceUOM
	,CD.dblBasis
	,CB.strContractBasis
	,TER.strName
	,FM.strFutureMonth
	,IRI.strComments
	,CD.dtmStartDate
	,CD.dtmEndDate
	,IRIL.strLotNumber
	,RES.dblReservedQuantity
	,CD.intContractDetailId
	,RUM.strUnitMeasure
	,USR.strName
	,IR.dtmReceiptDate
	,PO.strPosition
	,IR.intInventoryReceiptId
	,L.intLoadId