GO

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblRKSummaryLog')
BEGIN
	DECLARE @ExistingHistory AS RKSummaryLog

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblRKSummaryLog WHERE strTransactionType = 'Contract')
	BEGIN
		PRINT 'Populate RK Summary Log - Contract'
		
		INSERT INTO @ExistingHistory(strTransactionType
			, intTransactionRecordId
			, strTransactionNumber
			, dtmTransactionDate
			, intContractDetailId
			, intContractHeaderId
			, intCommodityId
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblPrice
			, intEntityId
			, intUserId
			, strNotes)
		SELECT strTransactionType = 'Contract'
			, intTransactionRecordId = intContractDetailId
			, strTransactionNumber = strContractNumber + '-' + CAST(intContractSeq AS NVARCHAR(10))
			, dtmTransactionDate = dtmHistoryCreated
			, intContractDetailId = intContractDetailId
			, intContractHeaderId = intContractHeaderId
			, intCommodityId = intCommodityId
			, intBookId = intBookId
			, intSubBookId = intSubBookId
			, intFutureMarketId = intFutureMarketId
			, intFutureMonthId = intFutureMonthId
			, dblNoOfLots = dblLotsPriced
			, dblPrice = dblFinalPrice
			, intEntityId = intEntityId
			, intUserId = intUserId
			, strNotes = ''
		FROM tblCTSequenceHistory
		ORDER BY dtmTransactionDate ASC

		EXEC uspRKLogRiskPosition @ExistingHistory, 1		

		PRINT 'End Populate RK Summary Log - Contract'
	END	
END

GO