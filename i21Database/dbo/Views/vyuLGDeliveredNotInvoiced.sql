CREATE VIEW vyuLGDeliveredNotInvoiced
AS
SELECT   Load.intLoadId
		,Load.[strLoadNumber]
		,ALH.strAllocationNumber
		,ALD.strAllocationDetailRefNo
		,strPContractNumber = PHeader.strContractNumber
		,intPContractSeq = PDetail.intContractSeq
        ,strSContractNumber = SHeader.strContractNumber
        ,intSContractSeq = SDetail.intContractSeq
		,Lot.strLotNumber
		,'' AS strWarehouseCargo

		,LoadDetail.dblQuantity
		,LoadDetail.intItemUOMId
		,LoadDetail.dblGross
		,LoadDetail.dblTare
		,LoadDetail.dblNet

		,Item.strItemNo
		,Item.strDescription AS strItemDescription
		,UOM.strUnitMeasure AS strItemUOM
		,WeightUOM.strUnitMeasure AS strWeightItemUOM
		,PLH.strPickLotNumber 
		,CLSL.strSubLocationName
		,CLSL.strSubLocationDescription
		,Load.intBookId
		,BO.strBook
		,Load.intSubBookId
		,SB.strSubBook
FROM tblLGLoadDetail LoadDetail
JOIN tblLGLoad Load ON Load.intLoadId = LoadDetail.intLoadId
LEFT JOIN tblLGGenerateLoad GLoad ON GLoad.intGenerateLoadId = Load.intGenerateLoadId
LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LoadDetail.intPContractDetailId
LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LoadDetail.intSContractDetailId
LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
LEFT JOIN tblICItem Item On Item.intItemId = LoadDetail.intItemId
LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LoadDetail.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
LEFT JOIN tblICItemUOM WeightItemUOM ON WeightItemUOM.intItemUOMId = LoadDetail.intWeightItemUOMId
LEFT JOIN tblICUnitMeasure WeightUOM ON WeightUOM.intUnitMeasureId = WeightItemUOM.intUnitMeasureId
LEFT JOIN tblLGLoadDetailLot LoadDetailLot ON LoadDetailLot.intLoadDetailId = LoadDetail.intLoadDetailId
LEFT JOIN tblICLot Lot ON Lot.intLotId = LoadDetailLot.intLotId
LEFT JOIN tblLGPickLotDetail PLD ON PLD.intPickLotDetailId= LoadDetail.intPickLotDetailId
LEFT JOIN tblLGPickLotHeader PLH ON PLH.intPickLotHeaderId = PLD.intPickLotHeaderId
LEFT JOIN tblLGAllocationDetail ALD ON ALD.intAllocationDetailId = PLD.intAllocationDetailId
LEFT JOIN tblLGAllocationHeader ALH ON ALH.intAllocationHeaderId = ALD.intAllocationHeaderId
LEFT JOIN tblLGLoadWarehouse LW ON LW.intLoadId = Load.intLoadId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL ON CLSL.intCompanyLocationSubLocationId = LW.intSubLocationId
LEFT JOIN tblCTBook BO ON BO.intBookId = Load.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = Load.intSubBookId
WHERE LoadDetail.intLoadDetailId NOT IN (SELECT ISNULL(tblARInvoiceDetail.intLoadDetailId,0) FROM tblARInvoiceDetail)
  AND Load.intPurchaseSale IN (2,3)
  AND Load.intShipmentType = 1