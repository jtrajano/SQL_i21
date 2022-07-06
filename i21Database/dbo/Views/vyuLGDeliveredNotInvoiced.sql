CREATE VIEW vyuLGDeliveredNotInvoiced
AS
SELECT   L.intLoadId
		,L.strLoadNumber
		,L.dtmScheduledDate
		,ALH.strAllocationNumber
		,ALD.strAllocationDetailRefNo
		,strPContractNumber = PHeader.strContractNumber
		,intPContractSeq = PDetail.intContractSeq
        ,strSContractNumber = SHeader.strContractNumber
        ,intSContractSeq = SDetail.intContractSeq
		,strCustomerName = Cust.strName
		,strCustomerReference = SHeader.strCustomerContract
		,SDetail.dtmStartDate
		,SDetail.dtmEndDate
		,Lot.strLotNumber
		,strWarehouseCargo = Lot.strCargoNo
		,Lot.strWarrantNo

		,LoadDetail.dblQuantity
		,LoadDetail.intItemUOMId
		,LoadDetail.dblGross
		,LoadDetail.dblTare
		,LoadDetail.dblNet

		,Item.strItemNo
		,strItemDescription = Item.strDescription
		,strItemUOM = UOM.strUnitMeasure
		,strWeightItemUOM = WeightUOM.strUnitMeasure
		,PLH.strPickLotNumber 
		,CLSL.strSubLocationName
		,CLSL.strSubLocationDescription
		,L.intBookId
		,BO.strBook
		,L.intSubBookId
		,SB.strSubBook
FROM tblLGLoadDetail LoadDetail
JOIN tblLGLoad L ON L.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = L.intGenerateLoadId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblEMEntity Cust ON Cust.intEntityId = SHeader.intEntityId
LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblLGLoadDetailLot LoadDetailLot ON LoadDetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
LEFT JOIN tblICLot Lot ON Lot.intLotId = LoadDetailLot.intLotId
LEFT JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId= LoadDetail.intPickLotDetailId
LEFT JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = LoadDetail.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = L.intLoadId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblCTBook BO ON BO.intBookId = L.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = L.intSubBookId
WHERE LoadDetail.intLoadDetailId NOT IN (SELECT ISNULL(tblARInvoiceDetail.intLoadDetailId,0) FROM tblARInvoiceDetail)
  AND L.intPurchaseSale IN (2,3)
  AND L.intShipmentType = 1
  AND L.ysnPosted = 1