CREATE VIEW [dbo].[vyuGRGetSpotZeroScaleTickets]
AS 
SELECT DISTINCT
	 intTicketId			= SC.intTicketId
	,strTicketNumber		= SC.strTicketNumber
	,strInOutIndicator		= TicketType.strInOutIndicator
	,strInOutType			= CASE WHEN TicketType.strInOutIndicator='I' THEN 'Inbound' ELSE 'Outbound' END COLLATE Latin1_General_CI_AS
	,intItemId				= SC.intItemId
	,strItemNo				= Item.strItemNo
	,intCompanyLocationId	= SC.intProcessingLocationId
	,strLocationName		= Loc.strLocationName
	,intEntityId			= ISNULL(TS.intCustomerId,SC.intEntityId)
	,strEntityName          = Entity.strName
	,dblUnits				= ISNULL(TS.dblSplitPercent,100)*SC.dblNetUnits/100.0
	,dtmTicketDateTime		= SC.dtmTicketDateTime
	,intItemUOMIdTo			= SC.intItemUOMIdTo
	,strItemStockUOM		= UnitMeasure.strUnitMeasure
	FROM tblSCTicket SC
	LEFT JOIN tblSCTicketSplit TS
		ON TS.intTicketId = SC.intTicketId 
			AND TS.intStorageScheduleTypeId = -3 
			AND TS.intCustomerId NOT IN (SELECT intEntityId FROM tblGRUnPricedSpotTicket  WHERE intTicketId = SC.intTicketId)
	JOIN tblICItem Item	
		ON Item.intItemId = SC.intItemId
	JOIN tblSCListTicketTypes TicketType 
		ON TicketType.intTicketTypeId = SC.intTicketTypeId
	JOIN tblSMCompanyLocation Loc 
		ON Loc.intCompanyLocationId = SC.intProcessingLocationId
	JOIN tblEMEntity Entity
		ON Entity.intEntityId = ISNULL(TS.intCustomerId,SC.intEntityId)
	JOIN tblICItemUOM UOM 
		ON UOM.intItemUOMId = SC.intItemUOMIdTo
	JOIN tblICUnitMeasure UnitMeasure
		ON UnitMeasure.intUnitMeasureId = UOM.intUnitMeasureId
	LEFT JOIN tblICInventoryReceiptItem IRI
		ON IRI.intSourceId = SC.intTicketId
	LEFT JOIN tblICInventoryShipmentItem ISI
		ON ISI.intSourceId = SC.intTicketId
	LEFT JOIN tblCTWeightGrade Wght
		ON Wght.intWeightGradeId = SC.intWeightId
	LEFT JOIN tblCTWeightGrade Grd
		ON Grd.intWeightGradeId = SC.intGradeId
	LEFT JOIN tblAPBillDetail APD
		ON APD.intInventoryReceiptItemId = IRI.intInventoryReceiptItemId
	LEFT JOIN tblARInvoiceDetail AID
		ON AID.intInventoryShipmentItemId = ISI.intInventoryShipmentItemId
WHERE ISNULL(SC.dblUnitPrice,0) = 0 
	AND ISNULL(SC.dblUnitBasis,0) = 0
	AND SC.intStorageScheduleTypeId IN(-3,-4)	-- Spot,Split
	AND SC.strTicketStatus = 'C'
	AND CASE WHEN (lower(Wght.strWhereFinalized) = 'destination' and lower(Grd.strWhereFinalized) = 'destination') THEN SC.ysnDestinationWeightGradePost ELSE 1 END = 1
	AND CASE WHEN TicketType.strInOutIndicator='I' THEN CASE WHEN ISNULL(IRI.dblUnitCost,0) = 0 OR (SC.dblUnitBasis + SC.dblUnitPrice) = 0 THEN 0 ELSE 1 END ELSE CASE WHEN ISNULL(ISI.dblUnitPrice,0) = 0 OR (SC.dblUnitBasis + SC.dblUnitPrice) = 0 THEN 0 ELSE 1 END END = 0
	AND SC.intTicketTypeId != 10
	AND APD.intBillDetailId IS NULL
	AND AID.intInvoiceDetailId IS NULL