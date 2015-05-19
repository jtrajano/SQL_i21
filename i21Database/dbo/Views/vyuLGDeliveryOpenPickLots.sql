CREATE VIEW vyuLGDeliveryOpenPickLots
AS
	SELECT 	PL.intPickLotHeaderId, 
			PL.intReferenceNumber, 
			PL.dtmPickDate, 
			intCustomerEntityId,
			intCompanyLocationId,
			intCommodityId,
			intSubLocationId,
			intWeightUnitMeasureId
	FROM tblLGPickLotHeader 		PL
	WHERE PL.intPickLotHeaderId NOT IN (SELECT intPickLotHeaderId FROM tblLGDeliveryDetail)