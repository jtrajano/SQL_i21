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
	  ,CTCQ.dblQuantity
	  ,C.strCommodityCode
	  ,C.strDescription AS strCommodityDescription
	  ,UM.strUnitMeasure
FROM tblLGContainerType CT
JOIN tblLGContainerTypeCommodityQty CTCQ ON CT.intContainerTypeId = CTCQ.intContainerTypeId
JOIN tblICCommodity C ON C.intCommodityId = CTCQ.intCommodityId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CT.intWeightUnitMeasureId