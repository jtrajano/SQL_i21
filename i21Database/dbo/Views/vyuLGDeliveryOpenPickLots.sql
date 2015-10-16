CREATE VIEW vyuLGDeliveryOpenPickLots
AS
	SELECT 	PL.intPickLotHeaderId, 
			PL.intReferenceNumber, 
			PL.dtmPickDate, 
			PL.intCustomerEntityId,
			PL.intCompanyLocationId,
			PL.intCommodityId,
			PL.intSubLocationId,
			PL.intWeightUnitMeasureId,
			EN.strName as strCustomer,
			CL.strLocationName,
			CO.strDescription as strCommodity,
			SubLocation.strSubLocationName as strWarehouse,
			UM.strUnitMeasure as strWeightUnitMeasure

	FROM tblLGPickLotHeader 		PL
	JOIN tblEntity EN ON EN.intEntityId = PL.intCustomerEntityId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = PL.intCompanyLocationId
	JOIN tblICCommodity CO ON CO.intCommodityId = PL.intCommodityId
	JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PL.intSubLocationId
	JOIN tblICUnitMeasure  UM ON UM.intUnitMeasureId  = PL.intWeightUnitMeasureId	