CREATE VIEW [dbo].[vyuCTSequenceUsageHistory]
AS 

	SELECT	 UH.intSequenceUsageHistoryId
			,UH.intContractDetailId
			,UH.intContractHeaderId
			,UH.intContractSeq
			,UH.dtmTransactionDate
			,UH.strScreenName
			,ISNULL(UH.strNumber,AP.strNumber) strNumber
			,UH.strFieldName
			,UH.dblOldValue
			,UH.dblTransactionQuantity
			,UH.dblNewValue
			,UH.dblBalance
			,UH.strUserName
			,UH.intExternalHeaderId
			,CAST(CASE WHEN ISNULL(AP.intExternalHeaderId,0) = 0 THEN 1 ELSE 0 END AS BIT) AS ysnDeleted
			,AP.strHeaderIdColumn
			,CASE WHEN UH.strScreenName LIKE '%Auto%' THEN UH.dtmTransactionDate ELSE AP.dtmScreenDate END AS dtmScreenDate

	FROM	tblCTSequenceUsageHistory	UH	CROSS
	APPLY	dbo.fnCTGetSequenceUsageHistoryAdditionalParam(UH.intContractDetailId,UH.strScreenName,UH.intExternalId,UH.intUserId) AP