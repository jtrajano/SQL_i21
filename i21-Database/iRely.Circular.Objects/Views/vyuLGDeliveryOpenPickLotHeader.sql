CREATE VIEW vyuLGDeliveryOpenPickLotHeader
AS
SELECT DISTINCT PL.intPickLotHeaderId
	,PL.[strPickLotNumber]
	,PL.dtmPickDate
	,PL.intCustomerEntityId
	,PL.intCompanyLocationId
	,PL.intCommodityId
	,PL.intSubLocationId
	,PL.intWeightUnitMeasureId
	,PL.intParentPickLotHeaderId
	,EN.strName AS strCustomer
	,EN.strEntityNo AS strCustomerNo
	,CL.strLocationName
	,CO.strDescription AS strCommodity
	,SubLocation.strSubLocationName AS strWarehouse
	,UM.strUnitMeasure AS strWeightUnitMeasure
	,ysnShipped = ISNULL(L.ysnPosted,0)
	,PPL.strPickLotNumber AS strSplitFrom
	,PL.intBookId
	,BO.strBook
	,PL.intSubBookId
	,SB.strSubBook
FROM tblLGPickLotHeader PL
JOIN tblLGPickLotDetail PLD ON PLD.intPickLotHeaderId = PL.intPickLotHeaderId
JOIN tblEMEntity EN ON EN.intEntityId = PL.intCustomerEntityId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = PL.intCompanyLocationId
JOIN tblICCommodity CO ON CO.intCommodityId = PL.intCommodityId
JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PL.intSubLocationId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = PL.intWeightUnitMeasureId
LEFT JOIN tblLGLoadDetail LD ON LD.intPickLotDetailId = PLD.intPickLotDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGPickLotHeader PPL ON PPL.intPickLotHeaderId = PL.intParentPickLotHeaderId
LEFT JOIN tblCTBook BO ON BO.intBookId = PL.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = PL.intSubBookId