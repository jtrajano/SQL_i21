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
,intEntityId			= ISNULL(TS.intCustomerId,SC.intEntityId)
,strEntityName          = Entity.strName
,dblUnits				= ISNULL(TS.dblSplitPercent,100)*SC.dblNetUnits/100.0
,dtmTicketDateTime		= SC.dtmTicketDateTime
,intItemUOMIdTo			= SC.intItemUOMIdTo
,strItemStockUOM		= UnitMeasure.strUnitMeasure
FROM tblSCTicket SC
LEFT JOIN tblSCTicketSplit TS		 ON TS.intTicketId				 = SC.intTicketId AND TS.intStorageScheduleTypeId = -3 
																		AND TS.intCustomerId NOT IN 
																		(	
																			SELECT intEntityId 
																			FROM tblGRUnPricedSpotTicket 
																			WHERE intTicketId = SC.intTicketId
																		 )
JOIN tblICItem Item					 ON Item.intItemId				 = SC.intItemId
JOIN tblSCListTicketTypes TicketType ON TicketType.intTicketTypeId	 = SC.intTicketTypeId
JOIN tblSMCompanyLocation Loc		 ON Loc.intCompanyLocationId	 = SC.intProcessingLocationId
JOIN tblEMEntity Entity				 ON Entity.intEntityId			 = ISNULL(TS.intCustomerId,SC.intEntityId)
JOIN tblICItemUOM UOM				 ON UOM.intItemUOMId			 = SC.intItemUOMIdTo
JOIN tblICUnitMeasure UnitMeasure	 ON UnitMeasure.intUnitMeasureId = UOM.intUnitMeasureId
WHERE 
ISNULL(SC.dblUnitPrice,0) = 0 
AND ISNULL(SC.dblUnitBasis,0) = 0
AND SC.intStorageScheduleTypeId IN(-3,-4)	-- Spot,Split
AND SC.strTicketStatus = 'C'


