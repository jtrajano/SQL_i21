CREATE VIEW vyuLGDeliveryOpenPickLots
AS
	SELECT 	PL.intPickLotHeaderId, 
			PL.[strPickLotNumber], 
			PL.dtmPickDate, 
			PL.intCustomerEntityId,
			PL.intCompanyLocationId,
			PL.intCommodityId,
			PL.intSubLocationId,
			PL.intWeightUnitMeasureId,
			EN.strName as strCustomer,
			EN.strEntityNo as strCustomerNo,
			CL.strLocationName,
			CO.strDescription as strCommodity,
			SubLocation.strSubLocationName as strWarehouse,
			UM.strUnitMeasure as strWeightUnitMeasure,
			ysnShipped = CASE WHEN InvShip.intSourceId > 0 THEN
							CAST(1 as bit)
						ELSE
							CAST (0 as bit)
						END
	FROM tblLGPickLotHeader 		PL
	LEFT JOIN vyuICGetInventoryShipmentItem InvShip ON InvShip.intSourceId = PL.intPickLotHeaderId AND InvShip.strSourceType='Pick Lot'
	JOIN tblEMEntity EN ON EN.intEntityId = PL.intCustomerEntityId
	JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = PL.intCompanyLocationId
	JOIN tblICCommodity CO ON CO.intCommodityId = PL.intCommodityId
	JOIN tblSMCompanyLocationSubLocation SubLocation ON SubLocation.intCompanyLocationSubLocationId = PL.intSubLocationId
	JOIN tblICUnitMeasure  UM ON UM.intUnitMeasureId  = PL.intWeightUnitMeasureId
