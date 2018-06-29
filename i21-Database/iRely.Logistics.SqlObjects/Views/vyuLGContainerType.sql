CREATE VIEW vyuLGContainerType
AS
SELECT  CT.intContainerTypeId
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
	  ,0 intContainerTypeCommodityQtyId
	  ,0.0 dblBulkQuantity
	  ,0 intCommodityAttributeId
	  ,0.0 dblQuantity
	  ,'' strOrigin
	  ,0 intCommodityId
	  ,'' strCommodityCode 
	  ,'' strCommodityDescription
	  ,UM.strUnitMeasure
FROM tblLGContainerType CT
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CT.intWeightUnitMeasureId