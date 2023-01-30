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
		,strItemDescription = I.strDescription
		,strSItemSpecification = CASE WHEN ISNULL(CD.strItemSpecification, '') <> '' THEN CD.strItemSpecification ELSE I.strDescription END
		,strItemDescriptionWithSpecification = I.strDescription  + ' ' + ISNULL(PCD.strItemSpecification,'')
		,dblQty = LDL.dblLotQuantity
		,strQtyUOM = IU.strUnitMeasure
		,dblWeight = LDL.dblNet
		,strWeightUOM = WU.strUnitMeasure
		,strWeightUOMSymbol = WU.strSymbol
		,strContainerNumber = CASE WHEN ISNULL(IRIL.strContainerNo, '') <> '' THEN IRIL.strContainerNo ELSE LC2.strContainerNumber END
		,strMarks = CASE WHEN ISNULL(IRIL.strMarkings, '') <> '' THEN IRIL.strMarkings ELSE LC2.strMarks END
		,strSealNo = ISNULL(LC.strSealNumber, LC2.strSealNumber)
		,strID1 = LDL.strID1
		,strID2 = LDL.strID2
		,strID3 = LDL.strID3
		,ysnHasIDData = CAST(CASE WHEN (ISNULL(LDL.strID1, '') <> '' OR ISNULL(LDL.strID2, '') <> '' OR ISNULL(LDL.strID3, '') <> '') THEN 1 ELSE 0 END AS BIT)
		,dtmFDA = ISNULL(LC.dtmFDA, LC2.dtmFDA)
		,strCustomsComments = ISNULL(LC.strCustomsComments, LC2.strCustomsComments)
		,LW.strDeliveryNoticeNumber
		,CLSL.strSubLocationName
		,LDL.strWarehouseCargoNumber
		,strOurRef = PCH.strContractNumber + '/' + CONVERT(NVARCHAR,PCD.intContractSeq)
		,strPONo = PCH.strContractNumber + '-' + CONVERT(NVARCHAR,PCD.intContractSeq)
		,strSONo = CH.strContractNumber + '-' + CONVERT(NVARCHAR,CD.intContractSeq)
		,R.strWarehouseRefNo
		,WS.strWarrantStatus
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
		JOIN tblICUnitMeasure WU ON WU.intUnitMeasureId = L.intWeightUnitMeasureId
		JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
		LEFT JOIN tblICInventoryReceiptItemLot IRIL ON IRIL.intLotId = LOT.intLotId
		LEFT JOIN tblICInventoryReceiptItem IRI ON IRI.intInventoryReceiptItemId = IRIL.intInventoryReceiptItemId
		LEFT JOIN tblICInventoryReceipt R ON R.intInventoryReceiptId = IRI.intInventoryReceiptId
		LEFT JOIN tblCTContractDetail PCD ON PCD.intContractDetailId = IRI.intLineNo
		LEFT JOIN tblCTContractHeader PCH ON PCH.intContractHeaderId = PCD.intContractHeaderId
		LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = IRI.intContainerId
		LEFT JOIN tblLGLoadContainer LC2 ON LC2.intLoadId = L.intLoadId
		LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LC2.intLoadContainerId = LDCL.intLoadContainerId
		LEFT JOIN tblICWarrantStatus WS ON WS.intWarrantStatus = LOT.intWarrantStatus
	WHERE strLoadNumber = @strLoadNumber 
END