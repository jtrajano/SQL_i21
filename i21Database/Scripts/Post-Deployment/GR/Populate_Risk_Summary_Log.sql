IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKSummaryLog')
BEGIN
	DECLARE @SummaryLogs AS RKSummaryLog 

	-- Settle Storage
	INSERT INTO @SummaryLogs ( 
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
		, strTransactionType = h.strType
		, intTransactionRecordId = h.intSettleStorageId
		, strTransactionNumber = t.strTransactionId
		, dtmTransactionDate = t.dtmDate
		, intContractDetailId = sc.intContractDetailId
		, intContractHeaderId = h.intContractHeaderId
		, intTicketId = NULL
		, intCommodityId = i.intCommodityId
		, intCommodityUOMId = u.intUnitMeasureId
		, intItemId = t.intItemId
		, intBookId = NULL
		, intSubBookId = NULL
		, intLocationId = il.intLocationId
		, intFutureMarketId = NULL
		, intFutureMonthId = NULL
		, dblNoOfLots = NULL
		, dblQty = t.dblQty
		, dblPrice = t.dblCost
		, intEntityId = s.intEntityId
		, ysnDelete = 0
		, intUserId = h.intUserId
		, strNotes = t.strDescription
	FROM tblICInventoryTransaction t
		INNER JOIN tblGRStorageHistory h ON t.intTransactionId = h.intSettleStorageId
		INNER JOIN tblGRSettleStorage s ON s.intSettleStorageId = h.intSettleStorageId
		INNER JOIN tblICItem i ON i.intItemId = t.intItemId
		INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = t.intItemUOMId
		INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
		INNER JOIN tblICItemLocation il ON il.intItemLocationId = t.intItemLocationId
		LEFT OUTER JOIN tblGRSettleContract sc ON sc.intSettleStorageId = s.intSettleStorageId
	WHERE t.intTransactionTypeId = 44 -- Transaction Type Id for Settle Storage

	-- Storage Transfer
	INSERT INTO @SummaryLogs ( 
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
		, strTransactionType = h.strType
		, intTransactionRecordId = h.intTransferStorageId
		, strTransactionNumber = t.strTransactionId
		, dtmTransactionDate = t.dtmDate
		, intContractDetailId = ct.intContractDetailId
		, intContractHeaderId = ct.intContractHeaderId
		, intTicketId = NULL
		, intCommodityId = i.intCommodityId
		, intCommodityUOMId = u.intUnitMeasureId
		, intItemId = t.intItemId
		, intBookId = NULL
		, intSubBookId = NULL
		, intLocationId = il.intLocationId
		, intFutureMarketId = NULL
		, intFutureMonthId = NULL
		, dblNoOfLots = NULL
		, dblQty = t.dblQty
		, dblPrice = t.dblCost
		, intEntityId = NULL
		, ysnDelete = 0
		, intUserId = h.intUserId
		, strNotes = t.strDescription
	FROM tblICInventoryTransaction t
		INNER JOIN tblGRStorageHistory h ON t.intTransactionId = h.intTransferStorageId
		INNER JOIN tblGRTransferStorageReference sr ON sr.intTransferStorageId = h.intTransferStorageId
			AND sr.intToCustomerStorageId = h.intCustomerStorageId
		INNER JOIN tblGRCustomerStorage fs ON fs.intCustomerStorageId = sr.intSourceCustomerStorageId
		INNER JOIN tblGRStorageType ft ON ft.intStorageScheduleTypeId = fs.intStorageTypeId
		INNER JOIN tblGRCustomerStorage tos ON tos.intCustomerStorageId = sr.intToCustomerStorageId
		INNER JOIN tblICItem i ON i.intItemId = t.intItemId
		INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = t.intItemUOMId
		INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
		INNER JOIN tblICItemLocation il ON il.intItemLocationId = t.intItemLocationId
		INNER JOIN tblGRTransferStorageSplit spt ON spt.intTransferStorageSplitId = sr.intTransferStorageSplitId
		LEFT OUTER JOIN tblCTContractDetail ct ON ct.intContractDetailId = spt.intContractDetailId
	WHERE t.intTransactionTypeId = 56 -- Transaction Type Id for Transfer Storage

	-- Split Storage Transfer
	INSERT INTO @SummaryLogs ( 
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
		, strTransactionType = h.strType
		, intTransactionRecordId = h.intTransferStorageId
		, strTransactionNumber = t.strTransactionId
		, dtmTransactionDate = t.dtmDate
		, intContractDetailId = ct.intContractDetailId
		, intContractHeaderId = ct.intContractHeaderId
		, intTicketId = NULL
		, intCommodityId = i.intCommodityId
		, intCommodityUOMId = u.intUnitMeasureId
		, intItemId = t.intItemId
		, intBookId = NULL
		, intSubBookId = NULL
		, intLocationId = il.intLocationId
		, intFutureMarketId = NULL
		, intFutureMonthId = NULL
		, dblNoOfLots = NULL
		, dblQty = t.dblQty
		, dblPrice = t.dblCost
		, intEntityId = NULL
		, ysnDelete = 0
		, intUserId = h.intUserId
		, strNotes = t.strDescription
	FROM tblICInventoryTransaction t
		INNER JOIN tblGRStorageHistory h ON t.intTransactionId = h.intTransferStorageId
		INNER JOIN tblGRTransferStorageSourceSplit spt ON spt.intTransferStorageId = h.intTransferStorageId
			AND spt.intSourceCustomerStorageId = h.intCustomerStorageId
		LEFT JOIN tblCTContractDetail ct ON ct.intContractDetailId = spt.intContractDetailId
		INNER JOIN tblGRTransferStorage ts ON ts.intTransferStorageId = spt.intTransferStorageId
		INNER JOIN tblGRTransferStorageSplit tss ON tss.intTransferStorageId = spt.intTransferStorageId
		INNER JOIN tblICItem i ON i.intItemId = t.intItemId
		INNER JOIN tblICItemUOM iu ON iu.intItemUOMId = t.intItemUOMId
		INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
		INNER JOIN tblICItemLocation il ON il.intItemLocationId = t.intItemLocationId
	WHERE t.intTransactionTypeId = 56 -- Transaction Type Id for Transfer Storage

	EXEC uspRKLogRiskPosition @SummaryLogs

	PRINT 'End Populate RK Summary Log From Grain'
END