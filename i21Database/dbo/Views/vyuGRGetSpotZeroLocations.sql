CREATE VIEW [dbo].[vyuGRGetSpotZeroLocations]
AS   
SELECT DISTINCT
 CASE WHEN TicketType.strInOutIndicator='I' THEN 'Inbound' ELSE 'Outbound' END COLLATE Latin1_General_CI_AS AS strInOutIndicator
,intItemId				= SC.intItemId
,strItemNo				= Item.strItemNo
,intCompanyLocationId	= SC.intProcessingLocationId
,strLocationName		= Loc.strLocationName
FROM tblSCTicket SC
JOIN tblICItem Item ON Item.intItemId = SC.intItemId
JOIN tblSCListTicketTypes TicketType ON TicketType.intTicketTypeId = SC.intTicketTypeId
JOIN tblSMCompanyLocation Loc ON Loc.intCompanyLocationId=SC.intProcessingLocationId
WHERE 
ISNULL(SC.dblUnitPrice,0) = 0 
AND ISNULL(SC.dblUnitBasis,0) = 0
AND SC.intStorageScheduleTypeId = -3
AND SC.strTicketStatus = 'C'
