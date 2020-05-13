CREATE VIEW vyuLGPickOpenInTransitContainers
AS
SELECT
	LDCL.intLoadDetailContainerLinkId
	,intContainerId = LC.intLoadContainerId
	,strContainerID = CAST(LC.intLoadContainerId AS NVARCHAR(50)) COLLATE Latin1_General_CI_AS --TO BE REPLACED WITH CONTAINER ID
	,strContainerNumber = LC.strContainerNumber
	,intLotId = LOT.intLotId
	,strLotNumber = LOT.strLotNumber
	,strLotStatus = LOT.strLotStatus
	,strMarkings = LC.strMarks
	,intLoadId = L.intLoadId
	,strLoadNumber = L.strLoadNumber
	,intCommodityId = COM.intCommodityId
	,strCommodity = COM.strCommodityCode
	,intItemId = LD.intItemId
	,strItemNo = I.strItemNo
	,strItemDescription = I.strDescription
	,intCompanyLocationId = CD.intCompanyLocationId
    ,strLocationName = CL.strLocationName
	,intSubLocationId = LW.intSubLocationId
    ,strSubLocationName = CLSL.strSubLocationName
	,intStorageLocationId = LW.intStorageLocationId
    ,strStorageLocation = SL.strName
	,intOriginId = OG.intCountryID
	,strOrigin = OG.strCountry
	,intItemUOMId = LD.intItemUOMId
	,intItemWeightUOMId = LD.intWeightItemUOMId
	,intUnitMeasureId = UM.intUnitMeasureId
	,strItemUOM = UM.strUnitMeasure
    ,strItemUOMType = UM.strUnitType
	,dblQty = LC.dblQuantity
	,dblUnPickedQty = CASE WHEN LC.dblQuantity > 0.0 
						THEN LC.dblQuantity - ISNULL(PL.dblPickedQty, 0) ELSE 0.0 END
	,intContractDetailId = CD.intContractDetailId
	,strContractNumber = CH.strContractNumber
	,intContractSeq = CD.intContractSeq
	,dblGrossWeight = LDCL.dblLinkGrossWt
	,dblTareWeight = LDCL.dblLinkTareWt
	,dblNetWeight = LDCL.dblLinkNetWt
	,dblUnchangedGrossWeight = LDCL.dblLinkGrossWt
	,dblUnchangedTareWeight = LDCL.dblLinkTareWt
	,dblUnchangedNetWeight = LDCL.dblLinkNetWt
	,intConcurrencyId = LC.intConcurrencyId
FROM
	tblLGLoadDetailContainerLink LDCL
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
	INNER JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDCL.intLoadContainerId
	INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
	LEFT JOIN tblLGLoadWarehouseContainer LWC ON LWC.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadWarehouseId = LWC.intLoadWarehouseId 
	LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = LW.intStorageLocationId
	LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CD.intCompanyLocationId
	LEFT JOIN tblICItem I ON I.intItemId = LD.intItemId AND I.strLotTracking <> 'No'
	LEFT JOIN tblICItemUOM UOM ON UOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblICCommodity COM ON COM.intCommodityId = I.intCommodityId
	LEFT JOIN tblICCommodityAttribute CA ON	CA.intCommodityAttributeId = I.intOriginId
	LEFT JOIN tblSMCountry OG ON OG.intCountryID = CA.intCountryID
	OUTER APPLY 
		(SELECT 
			LOT.intLotId
			,LOT.strLotNumber
			,strLotStatus = LOTST.strPrimaryStatus
			,dblLotQty = IRIL.dblQuantity
		 FROM tblICInventoryReceiptItem IRI 
			LEFT JOIN tblICInventoryReceipt IR ON IR.intInventoryReceiptId = IRI.intInventoryReceiptId
			LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
			LEFT JOIN tblICLot LOT ON LOT.intLotId = IRIL.intLotId
			LEFT JOIN tblICLotStatus LOTST ON LOTST.intLotStatusId = LOT.intLotStatusId
		 WHERE IRI.intContainerId = LC.intLoadContainerId
			AND IR.ysnPosted = 1 AND IR.strReceiptType <> 'Inventory Return' AND IR.strDataSource <> 'Reverse') LOT
	OUTER APPLY 
		(SELECT dblPickedQty = SUM(dblPickedQtyToLoadUOM) FROM
			(SELECT 
				dblPickedQtyToLoadUOM = dbo.fnCalculateQtyBetweenUOM(LUM.intItemUOMId, LD.intItemUOMId, PLD.dblLotPickedQty)
			 FROM tblLGPickLotDetail PLD 
				LEFT JOIN tblICItemUOM LUM ON LUM.intUnitMeasureId = PLD.intLotUnitMeasureId AND LUM.intItemId = I.intItemId
			 WHERE intContainerId = LC.intLoadContainerId) PLQ		
		) PL
WHERE L.intPurchaseSale = 1
	AND L.intShipmentType = 1
	AND L.ysnPosted = 1
	AND (L.ysnCancelled IS NULL OR L.ysnCancelled = 0)
	AND LOT.intLotId IS NULL

GO