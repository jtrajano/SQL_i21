CREATE VIEW vyuLGContainerTypeNotMapped 
AS
SELECT CT.intContainerTypeId
	  ,CT.intConcurrencyId
	  ,CT.strContainerType
	  ,CT.dblLength
	  ,CT.dblWidth
	  ,CT.dblHeight
	  ,CT.intDimensionUnitMeasureId
	  ,CT.dblNetWeight
	  ,CT.dblEmptyWeight
	  ,CT.dblGrossWeight
	  ,CT.intWeightUnitMeasureId
	  ,CTCQ.intContainerTypeCommodityQtyId
	  ,CTCQ.dblBulkQuantity
	  ,CTCQ.intCommodityAttributeId
	  ,CTCQ.dblQuantity
	  ,CA.strDescription AS strOrigin
	  ,CTCQ.intCommodityId
	  ,C.strCommodityCode 
	  ,C.strDescription AS strCommodityDescription
	  ,UM.strUnitMeasure
FROM tblLGContainerType CT
LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CT.intContainerTypeId = CTCQ.intContainerTypeId
LEFT JOIN tblICCommodity C ON C.intCommodityId = CTCQ.intCommodityId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CT.intWeightUnitMeasureId
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = CTCQ.intCommodityAttributeId