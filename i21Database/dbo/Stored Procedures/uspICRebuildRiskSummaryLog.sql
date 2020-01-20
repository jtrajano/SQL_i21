CREATE PROCEDURE [dbo].[uspICRebuildRiskSummaryLog]
	@intEntityUserSecurityId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @SummaryLogs AS RKSummaryLog 

INSERT INTO @SummaryLogs (	
	strBatchId
	,strTransactionType
	,intTransactionRecordId 
	,strTransactionNumber 
	,dtmTransactionDate 
	,intContractDetailId 
	,intContractHeaderId 
	,intTicketId 
	,intCommodityId 
	,intCommodityUOMId 
	,intItemId 
	,intBookId 
	,intSubBookId 
	,intLocationId 
	,intFutureMarketId 
	,intFutureMonthId 
	,dblNoOfLots 
	,dblQty 
	,dblPrice 
	,intEntityId 
	,ysnDelete 
	,intUserId 
	,strNotes 	
)
SELECT 
	strBatchId = t.strBatchId
	,strTransactionType = v.strTransactionType
	,intTransactionRecordId = ISNULL(t.intTransactionDetailId, t.intTransactionId) 
	,strTransactionNumber = t.strTransactionId
	,dtmTransactionDate = t.dtmDate
	,intContractDetailId = NULL
	,intContractHeaderId = NULL
	,intTicketId = v.intTicketId
	,intCommodityId = v.intCommodityId
	,intCommodityUOMId = u.intUnitMeasureId
	,intItemId = t.intItemId
	,intBookId = NULL
	,intSubBookId = NULL
	,intLocationId = v.intLocationId
	,intFutureMarketId = NULL
	,intFutureMonthId = NULL
	,dblNoOfLots = NULL
	,dblQty = t.dblQty
	,dblPrice = t.dblCost
	,intEntityId = v.intEntityId
	,ysnDelete = 0
	,intUserId = @intEntityUserSecurityId
	,strNotes = t.strDescription
FROM	
	tblICInventoryTransaction t inner join vyuICGetInventoryValuation v 
		ON t.intInventoryTransactionId = v.intInventoryTransactionId
	INNER JOIN tblICItemUOM iu
		ON iu.intItemUOMId = t.intItemUOMId
	INNER JOIN tblICUnitMeasure u
		ON u.intUnitMeasureId = iu.intUnitMeasureId
WHERE
	t.dblQty <> 0 
ORDER BY
	t.intInventoryTransactionId ASC 

EXEC uspRKLogRiskPosition @SummaryLogs, 1