CREATE VIEW [dbo].[vyuGRGetSpotZeroItems]
AS   
SELECT DISTINCT
	 strInOutIndicator	= CASE WHEN TicketType.strInOutIndicator = 'I' THEN 'Inbound' ELSE 'Outbound' END COLLATE Latin1_General_CI_AS
	,intItemId			= SC.intItemId
	,strItemNo			= Item.strItemNo
	,ysnExchangeTraded	= Com.ysnExchangeTraded
	,intFutureMarketId	= ISNULL(Com.intFutureMarketId,0)
	,dblPriceCheckMin	= Com.dblPriceCheckMin
	,dblPriceCheckMax	= Com.dblPriceCheckMax
FROM tblSCTicket SC
JOIN tblICItem Item 
	ON Item.intItemId = SC.intItemId
JOIN tblSCListTicketTypes TicketType 
	ON TicketType.intTicketTypeId = SC.intTicketTypeId
JOIN tblICCommodity Com 
	ON Com.intCommodityId = Item.intCommodityId
LEFT JOIN tblCTWeightGrade Wght
	ON Wght.intWeightGradeId = SC.intWeightId
LEFT JOIN tblCTWeightGrade Grd
	ON Grd.intWeightGradeId = SC.intGradeId
WHERE 
	ISNULL(SC.dblUnitPrice,0) = 0 
	AND ISNULL(SC.dblUnitBasis,0) = 0
	AND SC.intStorageScheduleTypeId = -3
	AND SC.strTicketStatus = 'C'
	AND CASE WHEN (lower(Wght.strWhereFinalized) = 'destination' and lower(Grd.strWhereFinalized) = 'destination') THEN SC.ysnDestinationWeightGradePost ELSE 1 END = 1