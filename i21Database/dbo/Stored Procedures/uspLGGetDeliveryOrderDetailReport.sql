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
		  ,I.strDescription  + ' ' + ISNULL(PCD.strItemSpecification,'') AS strItemDescriptionWithSpecification
		  ,LDL.dblLotQuantity AS dblQty
		  ,IU.strUnitMeasure AS strQtyUOM
		  ,LDL.dblNet AS dblWeight
		  ,WU.strUnitMeasure AS strWeightUOM
		  ,WU.strSymbol AS strWeightUOMSymbol
		  ,IRIL.strContainerNo AS strContainerNumber
		  ,strMarks = ISNULL(IRIL.strMarkings, LC2.strMarks)
		  ,strCustomsComments = ISNULL(LC.strCustomsComments, LC2.strCustomsComments)
		  ,LW.strDeliveryNoticeNumber
		  ,CLSL.strSubLocationName
		  ,LDL.strWarehouseCargoNumber
		  ,PCH.strContractNumber + '/' + CONVERT(NVARCHAR,PCD.intContractSeq) strOurRef
		  ,R.strWarehouseRefNo
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
	LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = IRI.intInventoryReceiptId
	LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = IRI.intLineNo
	LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = IRI.intContainerId
	LEFT JOIN tblLGLoadContainer LC2 ON LC2.intLoadId = L.intLoadId
	INNER JOIN tblLGLoadDetailContainerLink LDCL ON LC2.intLoadContainerId = LDCL.intLoadContainerId
	WHERE strLoadNumber = @strLoadNumber 
END