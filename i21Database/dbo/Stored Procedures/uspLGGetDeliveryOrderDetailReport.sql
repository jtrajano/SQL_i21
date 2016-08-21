﻿CREATE PROCEDURE uspLGGetDeliveryOrderDetailReport
			@strLoadNumber NVARCHAR(100)
AS
BEGIN
	SELECT L.strLoadNumber
		  ,L.intLoadId 
		  ,LD.intLoadDetailId
		  ,CH.intContractHeaderId
		  ,CD.intContractDetailId
		  ,CH.strContractNumber
		  ,CD.intContractSeq
		  ,LDL.intLotId
		  ,LOT.strLotNumber
		  ,I.strItemNo
		  ,I.strDescription AS strItemDescription
		  ,LDL.dblLotQuantity AS dblQty
		  ,IU.strUnitMeasure AS strQtyUOM
		  ,LDL.dblNet AS dblWeight
		  ,WU.strUnitMeasure AS strWeightUOM
		  ,IRIL.strContainerNo AS strContainerNumber
		  ,L.strMarks
		  ,LW.strDeliveryNoticeNumber
		  ,CLSL.strSubLocationName
		  ,LDL.strWarehouseCargoNumber
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	JOIN tblLGLoadDetailLot LDL ON LDL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblICLot LOT ON LOT.intLotId = LDL.intLotId
	JOIN tblICItem I ON I.intItemId = LOT.intItemId
	JOIN tblLGLoadWarehouse LW ON LW.intLoadId= L.intLoadId
	JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intSContractDetailId
	JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = LOT.intItemUOMId
	JOIN tblICUnitMeasure IU ON IU.intUnitMeasureId = IUOM.intUnitMeasureId
	JOIN tblICItemUOM WUOM ON WUOM.intItemUOMId = LOT.intWeightUOMId
	JOIN tblICUnitMeasure WU ON WU.intUnitMeasureId = WUOM.intUnitMeasureId
	JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
	LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LOT.intLotId
	WHERE strLoadNumber = @strLoadNumber 
END