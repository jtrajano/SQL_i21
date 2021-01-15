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
	  ,dblConversionFactor = CASE WHEN (UM.intUnitMeasureId = WUM.intUnitMeasureId) THEN 1 ELSE ISNULL(UMC.dblConversionToStock, 0) END
FROM tblLGContainerType CT
LEFT JOIN tblLGContainerTypeCommodityQty CTCQ ON CT.intContainerTypeId = CTCQ.intContainerTypeId
LEFT JOIN tblICCommodity C ON C.intCommodityId = CTCQ.intCommodityId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = CT.intWeightUnitMeasureId
LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CTCQ.intUnitMeasureId
OUTER APPLY 
	(SELECT TOP 1 dblConversionToStock FROM tblICUnitMeasureConversion 
	WHERE intUnitMeasureId = WUM.intUnitMeasureId AND intStockUnitMeasureId = UM.intUnitMeasureId) UMC
LEFT JOIN tblICCommodityAttribute CA ON CA.intCommodityAttributeId = CTCQ.intCommodityAttributeId