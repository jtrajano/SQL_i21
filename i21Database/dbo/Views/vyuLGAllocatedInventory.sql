CREATE VIEW vyuLGAllocatedInventory
AS
SELECT ALD.intAllocationDetailId
	,ALD.intAllocationHeaderId
	-- Allocation Header details
	,ALH.[strAllocationNumber]
	,ALH.intCommodityId
	,Comm.strDescription AS strCommodity
	,ALH.intCompanyLocationId
	,CompLoc.strLocationName
	,ALH.intWeightUnitMeasureId
	,WTUOM.strUnitMeasure
	,ALH.strComments AS strHeaderComments
	-- Allocation Details
	,ALD.dtmAllocatedDate
	,ALD.intUserSecurityId
	,ALD.strComments
	-- Purchase Contract Details
	,ALD.intPContractDetailId
	,ALD.dblPAllocatedQty AS ALLOCATED_QTY
	,ALD.intPUnitMeasureId
	,PCH.strContractNumber AS strPurchaseContractNumber
	,PCT.intContractSeq AS intPContractSeq
	,PO_NUMBER = Cast(PCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(PCT.intContractSeq AS VARCHAR(100)) -- PO_NUMBER
	,U1.strUnitMeasure AS PO_QTY_UOM
	,IM.strItemNo AS PO_ITEM_NAME
	,IM.strDescription AS PO_ITEM_DESC
	,PCT.dblQuantity AS PO_ORIGINAL_QTY
	,PCH.dtmContractDate AS dtmPContractDate
	,PCT.dblBalance AS dblPBalance
	,PCT.dblBasis AS PO_DIFFERENTIAL
	,PCT.dblCashPrice AS PO_PRICE
	,PCT.dblFutures AS PO_FUTURES_PRICE
	,PCT.dtmStartDate AS PO_SHIPPERIOD_FROM
	,PCT.dtmEndDate AS PO_SHIPPERIOD_TO
	,PCB.strContractBasis AS PO_CONTRACT_TERM
	,PCS.strContractStatus AS strPContractStatus
	,PEY.strName AS SELLER_NAME
	,PCT.strFixationBy AS strPFixationBy
	,PFM.strFutMarketName AS strPFutMarketName
	,PMO.strFutureMonth AS PO_TERMINAL_MONTH
	,U2.strUnitMeasure AS PO_PRICE_UOM
	,PCT.dblNoOfLots AS dblPNoOfLots
	,PCT.dblTotalCost AS PO_VALUE
	---- Sales Contract Details
	,SCH.strContractNumber AS strSalesContractNumber
	,SCT.intContractSeq AS intSContractSeq
	,SO_NUMBER = Cast(SCH.strContractNumber AS VARCHAR(100)) + '/' + Cast(SCT.intContractSeq AS VARCHAR(100)) -- SO_NUMBER
	,U3.strUnitMeasure AS SO_QTY_UOM
	,SIM.strItemNo AS strSItemNo
	,SIM.strDescription AS strSItemDescription
	,SCT.dblQuantity AS SO_ORIGINAL_QTY
	,SCT.dblBasis AS SO_DIFFERENTIAL
	,SCT.dblCashPrice AS SO_PRICE
	,SCT.dblFutures AS SO_FUTURES_PRICE
	,SCT.dtmStartDate AS SO_SHIPPERIOD_FROM
	,SCT.dtmEndDate AS SO_SHIPPERIOD_TO
	,SCB.strContractBasis AS SO_CONTRACT_TERM
	,SEY.strName AS BUYER_NAME
	,SCT.dblTotalCost AS SO_VALUE
	,SFM.strFutMarketName AS strSFutMarketName
	,SMO.strFutureMonth AS SO_TERMINAL_MONTH
	,U2.strUnitMeasure AS SO_PRICE_UOM
	,SCT.dblNoOfLots AS dblSNoOfLots
	,ysnDelivered = CONVERT(BIT, CASE 
			WHEN (
					ALD.dblSAllocatedQty > ISNULL((
							SELECT SUM(LD.dblQuantity)
							FROM tblLGLoadDetail LD
							INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
							WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId
								AND L.ysnPosted = 1
								AND L.intPurchaseSale IN (
									2
									,3
									)
								AND L.intShipmentType = 1
							), 0)
					)
				THEN 0
			ELSE 1
			END)
	,dblSDeliveredQty = IsNull((
			SELECT SUM(LD.dblQuantity)
			FROM tblLGLoadDetail LD
			INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId
				AND L.ysnPosted = 1
				AND L.intPurchaseSale IN (
					2
					,3
					)
				AND L.intShipmentType = 1
			), 0)
	,BALANCE_BAGS = ALD.dblSAllocatedQty - IsNull((
			SELECT SUM(LD.dblQuantity)
			FROM tblLGLoadDetail LD
			INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
			WHERE LD.intAllocationDetailId = ALD.intAllocationDetailId
				AND L.ysnPosted = 1
				AND L.intPurchaseSale IN (
					2
					,3
					)
				AND L.intShipmentType = 1
			), 0) --BALANCE_BAGS
	,PCO.strCountry AS PO_ORIGIN_NAME
	,SCO.strCountry AS strSOrigin
	,LC.strContainerNumber AS CONTAINER_NO
	,LOAD.strLoadNumber
	,LOAD.intShipmentStatus
	,LOAD.dtmETAPOD AS ETA
	,LOAD.dtmETSPOL AS ETD
	,LW.dtmLastFreeDate AS FREE_TIME
	,LOAD.strComments AS COMMENTS_FIELD
	,LOAD.strBLNumber AS BL_NO
	,IR.dtmReceiptDate AS DATE_IN_WAREHOUSE
	,PDP.strCity AS PO_DESTINATION
	,SDP.strCity AS SO_DESTINATION
	,SHIPMENT_STATUS = CASE LOAD.intShipmentStatus
		WHEN 1
			THEN 'Scheduled'
		WHEN 2
			THEN 'Dispatched'
		WHEN 3
			THEN 'Inbound transit'
		WHEN 4
			THEN 'Received'
		WHEN 5
			THEN 'Outbound transit'
		WHEN 6
			THEN 'Delivered'
		WHEN 7
			THEN 'Instruction created'
		WHEN 8
			THEN 'Partial Shipment Created'
		WHEN 9
			THEN 'Full Shipment Created'
		WHEN 10
			THEN 'Cancelled'
		WHEN 11
			THEN 'Invoiced'
		ELSE ''
		END --Position:
	,STA.strContractStatus AS PRICE_FIX_STATUS
	,CASE 
		WHEN ISNULL(PCT.dblInvoicedQty, 0) = 0
			THEN 'Not Invoiced'
		WHEN ISNULL(PCT.dblInvoicedQty, 0) > 0
			AND DO.intShipmentStatus <> 11
			THEN 'Partially Invoiced'
		WHEN DO.intShipmentStatus = 11
			THEN 'Fully Invoiced'
		END AS strPosition
	,CASE 
		WHEN ISNULL(LOAD.ysnPosted, 0) = 1
			THEN 'True'
		ELSE 'False'
		END AS INVENTORIZED
	,ISNULL(LOT.dblQty, 0) STOCK_QTY
	,ISNULL(LOT.dblWeight, 0) PO_NET_WEIGHT
	,dbo.fnCTConvertQtyToTargetItemUOM(LOT.intItemUOMId, (
			SELECT intItemUOMId
			FROM tblICItemUOM
			WHERE intItemId = LOT.intItemId
				AND intUnitMeasureId = 9
			), 1) * ISNULL(LOT.dblQty, 0) PO_NET_WEIGHT_LB
	,DO.strLoadNumber strDeliveryOrderNumber
	,CLSL.strSubLocationName AS strWarehouse
FROM tblLGAllocationDetail ALD
INNER JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId
LEFT JOIN tblICCommodity Comm ON Comm.intCommodityId = ALH.intCommodityId
LEFT JOIN tblSMCompanyLocation CompLoc ON CompLoc.intCompanyLocationId = ALH.intCompanyLocationId
LEFT JOIN tblICUnitMeasure WTUOM ON WTUOM.intUnitMeasureId = ALH.intWeightUnitMeasureId
LEFT JOIN tblCTContractDetail PCT ON PCT.intContractDetailId = ALD.intPContractDetailId
LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCT.intContractHeaderId
LEFT JOIN tblCTContractStatus STA ON STA.intContractStatusId = PCT.intContractStatusId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = PCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblICItem IM ON IM.intItemId = PCT.intItemId
LEFT JOIN tblICCommodityAttribute PCA ON PCA.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblSMCountry PCO ON PCO.intCountryID = PCA.intCountryID
LEFT JOIN tblCTContractBasis PCB ON PCB.intContractBasisId = PCH.intContractBasisId
LEFT JOIN tblCTContractStatus PCS ON PCS.intContractStatusId = PCT.intContractStatusId
LEFT JOIN tblEMEntity PEY ON PEY.intEntityId = PCH.intEntityId
LEFT JOIN tblRKFutureMarket PFM ON PFM.intFutureMarketId = PCT.intFutureMarketId
LEFT JOIN tblRKFuturesMonth PMO ON PMO.intFutureMonthId = PCT.intFutureMonthId
LEFT JOIN tblICItemUOM PPU ON PPU.intItemUOMId = PCT.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PPU.intUnitMeasureId
LEFT JOIN tblCTContractDetail SCT ON SCT.intContractDetailId = ALD.intSContractDetailId
LEFT JOIN tblCTContractHeader SCH ON SCH.intContractHeaderId = SCT.intContractHeaderId
LEFT JOIN tblICItemUOM SIU ON SIU.intItemUOMId = SCT.intItemUOMId
LEFT JOIN tblICUnitMeasure U3 ON U3.intUnitMeasureId = SIU.intUnitMeasureId
LEFT JOIN tblICItem SIM ON SIM.intItemId = SCT.intItemId
LEFT JOIN tblICCommodityAttribute SCA ON SCA.intCommodityAttributeId = SIM.intOriginId
LEFT JOIN tblSMCountry SCO ON SCO.intCountryID = SCA.intCountryID
LEFT JOIN tblCTContractBasis SCB ON SCB.intContractBasisId = SCH.intContractBasisId
LEFT JOIN tblCTContractStatus SCS ON SCS.intContractStatusId = SCT.intContractStatusId
LEFT JOIN tblEMEntity SEY ON SEY.intEntityId = SCH.intEntityId
LEFT JOIN tblRKFutureMarket SFM ON SFM.intFutureMarketId = SCT.intFutureMarketId
LEFT JOIN tblRKFuturesMonth SMO ON SMO.intFutureMonthId = SCT.intFutureMonthId
LEFT JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intPContractDetailId = PCT.intContractDetailId
LEFT JOIN tblLGLoad LOAD ON LOAD.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LoadDetail.intLoadDetailId
LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId
LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intSourceId = LoadDetail.intLoadDetailId
	AND IRI.intContainerId = LC.intLoadContainerId
LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
LEFT JOIN tblICLot LOT ON LOT.intLotId = IRIL.intLotId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LOT.intSubLocationId
LEFT JOIN tblSMCity PDP ON PDP.intCityId = PCT.intDestinationPortId
LEFT JOIN tblSMCity SDP ON SDP.intCityId = SCT.intDestinationPortId
LEFT JOIN tblLGLoadDetail DOD ON DOD.intAllocationDetailId = ALD.intAllocationDetailId
LEFT JOIN tblLGLoad DO ON DO.intLoadId = DOD.intLoadId
WHERE LOAD.intShipmentType = 1
