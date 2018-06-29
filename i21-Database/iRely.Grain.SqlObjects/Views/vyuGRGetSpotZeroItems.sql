CREATE VIEW [dbo].[vyuGRGetSpotZeroItems]
AS   
SELECT DISTINCT
 strInOutIndicator = CASE WHEN TicketType.strInOutIndicator='I' THEN 'Inbound' ELSE 'Outbound' END
,intItemId		   = SC.intItemId
,strItemNo		   = Item.strItemNo
,ysnExchangeTraded = Com.ysnExchangeTraded
,intFutureMarketId = ISNULL(Com.intFutureMarketId,0)
,dblPriceCheckMin  = Com.dblPriceCheckMin
,dblPriceCheckMax  = Com.dblPriceCheckMax
FROM tblSCTicket SC
JOIN tblICItem Item ON Item.intItemId = SC.intItemId
JOIN tblSCListTicketTypes TicketType ON TicketType.intTicketTypeId = SC.intTicketTypeId
JOIN tblICCommodity Com ON Com.intCommodityId=Item.intCommodityId
WHERE 
ISNULL(SC.dblUnitPrice,0) = 0 
AND ISNULL(SC.dblUnitBasis,0) = 0
AND SC.intStorageScheduleTypeId = -3
AND SC.strTicketStatus = 'C'
