CREATE VIEW vyuLGDeliveryOpenPickLotHeader
AS
SELECT DISTINCT PL.intPickLotHeaderId
	,PL.[strPickLotNumber]
	,strType = CASE WHEN (PL.intType = 2) THEN 'Containers' ELSE 'Lots' END
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
	,IM.dblGAShrinkFactor
	,strOrigin = ISNULL(SM.strCountry, Origin.strDescription)
	,strProductType = ProductType.strDescription
	,strGrade = Grade.strDescription
	,strRegion = Region.strDescription
	,strSeason = Season.strDescription
	,strClass = Class.strDescription
	,strProductLine = ProductLine.strDescription
	,IM.strMarketValuation
FROM tblLGPickLotHeader PL
JOIN tblLGPickLotDetail PLD ON PLD.intPickLotHeaderId = PL.intPickLotHeaderId
JOIN tblEMEntity EN ON EN.intEntityId = PL.intCustomerEntityId
JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = PL.intCompanyLocationId
JOIN tblICCommodity CO ON CO.intCommodityId = PL.intCommodityId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = PL.intWeightUnitMeasureId
JOIN tblLGAllocationDetail AD ON AD.intAllocationDetailId = PLD.intAllocationDetailId
JOIN tblCTContractDetail SCD ON SCD.intContractDetailId = AD.intSContractDetailId
JOIN tblICItem IM ON IM.intItemId = SCD.intItemId 
LEFT JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PL.intSubLocationId
LEFT JOIN tblLGLoadDetail LD ON LD.intPickLotDetailId = PLD.intPickLotDetailId
LEFT JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId
LEFT JOIN tblLGPickLotHeader PPL ON PPL.intPickLotHeaderId = PL.intParentPickLotHeaderId
LEFT JOIN tblCTBook BO ON BO.intBookId = PL.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = PL.intSubBookId
LEFT JOIN tblICCommodityAttribute Origin ON Origin.intCommodityAttributeId = IM.intOriginId
LEFT JOIN tblICCommodityAttribute ProductType ON ProductType.intCommodityAttributeId = IM.intProductTypeId
LEFT JOIN tblICCommodityAttribute Grade ON Grade.intCommodityAttributeId = IM.intGradeId
LEFT JOIN tblICCommodityAttribute Region ON Region.intCommodityAttributeId = IM.intRegionId
LEFT JOIN tblICCommodityAttribute Season ON Season.intCommodityAttributeId = IM.intSeasonId
LEFT JOIN tblICCommodityAttribute Class ON Class.intCommodityAttributeId = IM.intClassVarietyId
LEFT JOIN tblICCommodityProductLine ProductLine ON ProductLine.intCommodityProductLineId = IM.intProductLineId
LEFT JOIN tblICItemContract ICI ON ICI.intItemId = IM.intItemId AND SCD.intItemContractId = ICI.intItemContractId
LEFT JOIN tblSMCountry SM ON SM.intCountryID = ICI.intCountryId