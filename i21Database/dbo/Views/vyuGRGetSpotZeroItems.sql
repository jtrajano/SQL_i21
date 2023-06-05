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
LEFT JOIN tblSCTicketSplit TS
	ON TS.intTicketId = SC.intTicketId 
		AND TS.intCustomerId NOT IN (SELECT intEntityId FROM tblGRUnPricedSpotTicket  WHERE intTicketId = SC.intTicketId)
JOIN tblICItem Item 
	ON Item.intItemId = SC.intItemId
JOIN tblSCListTicketTypes TicketType 
	ON TicketType.intTicketTypeId = SC.intTicketTypeId
JOIN tblICCommodity Com 
	ON Com.intCommodityId = Item.intCommodityId
LEFT JOIN (
				select A.* from tblICInventoryReceiptItem A
					join tblICInventoryReceipt B
						on A.intInventoryReceiptId = B.intInventoryReceiptId
						 and B.intSourceType = 1
		) IRI
		ON IRI.intSourceId = SC.intTicketId
	LEFT JOIN tblICInventoryShipmentItem ISI
		ON ISI.intSourceId = SC.intTicketId

LEFT JOIN tblCTWeightGrade Wght
	ON Wght.intWeightGradeId = SC.intWeightId
LEFT JOIN tblCTWeightGrade Grd
	ON Grd.intWeightGradeId = SC.intGradeId
WHERE 
	ISNULL(SC.dblUnitPrice,0) = 0 
	AND ISNULL(SC.dblUnitBasis,0) = 0
	AND SC.intStorageScheduleTypeId IN(-3,-4)	
	AND (TS.intTicketSplitId is null or (TS.intTicketSplitId is not null and TS.strDistributionOption = 'SPT'))
	AND SC.strTicketStatus = 'C'
	AND CASE WHEN (lower(Wght.strWhereFinalized) = 'destination' and lower(Grd.strWhereFinalized) = 'destination') THEN SC.ysnDestinationWeightGradePost ELSE 1 END = 1
	AND (CASE WHEN TicketType.strInOutIndicator='I' 
			THEN CASE WHEN ISNULL(IRI.dblUnitCost,0) = 0 OR (ISNULL(SC.dblUnitBasis,0) + ISNULL(SC.dblUnitPrice,0)) = 0 
				THEN 0 
				ELSE 1 
				END 
			ELSE CASE WHEN ISNULL(ISI.dblUnitPrice,0) = 0 OR (ISNULL(SC.dblUnitBasis,0) + ISNULL(SC.dblUnitPrice,0)) = 0 
				THEN 0 
				ELSE 1 
				END 
			END) = 0
	AND SC.intTicketTypeId != 10