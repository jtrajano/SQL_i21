CREATE VIEW [dbo].[vyuCTSequenceUsageHistory]
AS 

	SELECT	UH.intSequenceUsageHistoryId,
			UH.intContractDetailId,
			UH.intContractHeaderId,
			UH.intContractSeq,
			UH.dtmTransactionDate,
			UH.strScreenName,
			UH.strNumber,
			UH.strFieldName,
			UH.dblOldValue,
			UH.dblTransactionQuantity,
			UH.dblNewValue,
			UH.strUserName,
			UH.intExternalHeaderId,
			CAST(CASE WHEN ISNULL(AP.strNumber,'') = '' THEN 1 ELSE 0 END AS BIT) AS ysnDeleted,
			AP.strHeaderIdColumn
			
	FROM	tblCTSequenceUsageHistory	UH	CROSS
	APPLY	dbo.fnCTGetSequenceUsageHistoryAdditionalParam(UH.intContractDetailId,UH.strScreenName,UH.intExternalId,UH.intUserId) AP