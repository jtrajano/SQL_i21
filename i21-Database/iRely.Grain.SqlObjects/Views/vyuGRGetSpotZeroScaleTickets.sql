CREATE VIEW [dbo].[vyuGRGetSpotZeroScaleTickets]
AS 
SELECT
 intTicketId			= SC.intTicketId
,strTicketNumber		= SC.strTicketNumber
,strInOutIndicator		= TicketType.strInOutIndicator
,strInOutType			= CASE WHEN TicketType.strInOutIndicator='I' THEN 'Inbound' ELSE 'Outbound' END
,intItemId				= SC.intItemId
,strItemNo				= Item.strItemNo
,intCompanyLocationId	= SC.intProcessingLocationId
,strLocationName		= Loc.strLocationName
,intEntityId			= SC.intEntityId
,strEntityName          = Entity.strName
,dblUnits				= SC.dblNetUnits
,dtmTicketDateTime		= SC.dtmTicketDateTime
,intItemUOMIdTo			 = SC.intItemUOMIdTo
,strItemStockUOM		 = UnitMeasure.strUnitMeasure
FROM tblSCTicket SC
JOIN tblICItem Item ON Item.intItemId = SC.intItemId
JOIN tblSCListTicketTypes TicketType ON TicketType.intTicketTypeId = SC.intTicketTypeId
JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId=SC.intProcessingLocationId
JOIN tblEMEntity Entity ON Entity.intEntityId=SC.intEntityId
JOIN tblICItemUOM UOM ON UOM.intItemUOMId=SC.intItemUOMIdTo
JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId=UOM.intUnitMeasureId
WHERE 
ISNULL(SC.dblUnitPrice,0) = 0 
AND ISNULL(SC.dblUnitBasis,0) = 0
AND SC.intStorageScheduleTypeId = -3
AND SC.strTicketStatus = 'C'
AND SC.intTicketId NOT IN (SELECT intTicketId FROM tblGRUnPricedSpotTicket)
