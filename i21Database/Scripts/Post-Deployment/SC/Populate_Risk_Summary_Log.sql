IF EXISTS(SELECT TOP 1
	1
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'tblRKSummaryLog')
BEGIN
	DECLARE @SummaryLogs AS RKSummaryLog

	INSERT INTO @SummaryLogs
	(
		  strBatchId
		, strTransactionType
		, intTransactionRecordId
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
		, intTicketId
		, intCommodityId
		, intCommodityUOMId
		, intItemId
		, intBookId
		, intSubBookId
		, intLocationId
		, intFutureMarketId
		, intFutureMonthId
		, dblNoOfLots
		, dblQty
		, dblPrice
		, intEntityId
		, ysnDelete
		, intUserId
		, strNotes
	)
	SELECT
		  strBatchId = t.strBatchId
		, strTransactionType = t.strTransactionForm
		, intTransactionRecordId = r.intTicketId
		, strTransactionNumber = r.strTicketNumber
		, dtmTransactionDate = r.dtmTransactionDateTime
		, intContractDetailId = NULL
		, intContractHeaderId = NULL
		, intTicketId = r.intTicketId
		, intCommodityId = c.intCommodityId
		, intCommodityUOMId = t.intItemUOMId
		, intItemId = r.intItemId
		, intBookId = NULL
		, intSubBookId = NULL
		, intLocationId = il.intLocationId
		, intFutureMarketId = NULL
		, intFutureMonthId = NULL
		, dblNoOfLots = NULL
		, dblQty = t.dblQty
		, dblPrice = r.dblUnitPrice
		, intEntityId = r.intEntityId
		, ysnDelete = 0
		, intUserId = 1
		, strNotes = NULL
	FROM tblSCTicket r
		LEFT OUTER JOIN tblICInventoryTransaction t ON t.intTransactionId = r.intTicketId
		INNER JOIN tblICItemLocation il ON il.intItemId = r.intItemId
			AND il.intLocationId = r.intProcessingLocationId
		INNER JOIN tblICItem i ON i.intItemId = r.intItemId
		LEFT OUTER JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	WHERE t.intTransactionTypeId = 52 -- Transaction Type Id for Scale Ticket
		AND r.strTicketStatus = 'O'
		AND r.strDistributionOption = 'HLD'

	INSERT INTO @SummaryLogs
	(
		  strBatchId
		, strTransactionType
		, intTransactionRecordId
		, strTransactionNumber
		, dtmTransactionDate
		, intContractDetailId
		, intContractHeaderId
		, intTicketId
		, intCommodityId
		, intCommodityUOMId
		, intItemId
		, intBookId
		, intSubBookId
		, intLocationId
		, intFutureMarketId
		, intFutureMonthId
		, dblNoOfLots
		, dblQty
		, dblPrice
		, intEntityId
		, ysnDelete
		, intUserId
		, strNotes
	)
	SELECT
	  	  strBatchId = t.strBatchId
		, strTransactionType = t.strTransactionForm
		, intTransactionRecordId = d.intDeliverySheetId
		, strTransactionNumber = d.strDeliverySheetNumber
		, dtmTransactionDate = d.dtmDeliverySheetDate
		, intContractDetailId = NULL
		, intContractHeaderId = NULL
		, intTicketId = r.intTicketId
		, intCommodityId = c.intCommodityId
		, intCommodityUOMId = r.intItemUOMIdTo
		, intItemId = r.intItemId
		, intBookId = NULL
		, intSubBookId = NULL
		, intLocationId = il.intLocationId
		, intFutureMarketId = NULL
		, intFutureMonthId = NULL
		, dblNoOfLots = NULL
		, dblQty = t.dblQty
		, dblPrice = r.dblUnitPrice
		, intEntityId = r.intEntityId
		, ysnDelete = 0
		, intUserId = 1
		, strNotes = NULL
	FROM tblSCTicket r
		INNER JOIN tblSCDeliverySheet d ON d.intDeliverySheetId = r.intDeliverySheetId
		LEFT OUTER JOIN tblICInventoryTransaction t ON t.intTransactionId = r.intTicketId
		INNER JOIN tblICItemLocation il ON il.intItemId = r.intItemId
			AND il.intLocationId = r.intProcessingLocationId
		INNER JOIN tblICItem i ON i.intItemId = r.intItemId
		LEFT OUTER JOIN tblICCommodity c ON c.intCommodityId = i.intCommodityId
	WHERE t.intTransactionTypeId = 52 -- Transaction Type Id for Scale Ticket
		AND r.strTicketStatus = 'O'
		AND r.strDistributionOption = 'HLD'

	EXEC uspRKLogRiskPosition @SummaryLogs

	PRINT 'End Populate RK Summary Log From Scale Ticket'
END