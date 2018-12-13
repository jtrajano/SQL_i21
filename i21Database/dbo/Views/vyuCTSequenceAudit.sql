CREATE VIEW [dbo].[vyuCTSequenceAudit]

AS

	WITH CTEAudit AS
	(
		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmHistoryCreated AS dtmTransactionDate
				,SH.strContractNumber AS strNumber
				,SH.intContractStatusId
				,SH.dblQuantity
				,SH.dblBalance
				,SH.intOldStatusId
				,SH.dblOldQuantity
				,SH.dblOldBalance
				,SH.ysnStatusChange
				,SH.ysnQtyChange
				,SH.ysnBalanceChange
				,EY.strName AS strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,CAST(ISNULL(CD.intContractDetailId,0) AS BIT) ^ 1 ysnDeleted
				,dtmHistoryCreated AS dtmScreenDate
				,SH.intPricingTypeId

				,SH.dblFutures
				,SH.dblBasis
				,SH.dblCashPrice
				,SH.dblOldFutures
				,SH.dblOldBasis
				,SH.dblOldCashPrice
				,SH.ysnFuturesChange
				,SH.ysnBasisChange
				,SH.ysnCashPriceChange

		FROM	tblCTSequenceHistory		SH
		LEFT	JOIN tblEMEntity			EY ON EY.intEntityId			=	SH.intUserId 
		LEFT	JOIN tblCTContractDetail	CD ON CD.intContractDetailId	=	SH.intContractDetailId
	)

	SELECT ROW_NUMBER() OVER(ORDER BY dtmTransactionDate ASC,intSequenceUsageHistoryId DESC) intRowId,* FROM
	(
		SELECT	 intContractDetailId
				,intContractHeaderId
				,intContractSeq
				,dtmTransactionDate
				,strScreenName
				,strNumber
				,strFieldName
				,dblOldValue
				,dblTransactionQuantity
				,dblNewValue
				,dblBalance
				,strUserName
				,intExternalHeaderId
				,ysnDeleted
				,strHeaderIdColumn
				,dtmScreenDate
				,intSequenceUsageHistoryId * -1 AS intSequenceUsageHistoryId
		FROM	vyuCTSequenceUsageHistory

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Quantity' AS strFieldName
				,SH.dblOldQuantity AS dblOldValue
				,SH.dblQuantity - dblOldQuantity AS dblTransactionQuantity
				,SH.dblQuantity AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-1 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnQtyChange = 1
		AND     intPricingTypeId <> 5

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Balance' AS strFieldName
				,SH.dblOldBalance AS dblOldValue
				,SH.dblBalance - dblOldBalance AS dblTransactionQuantity
				,SH.dblBalance AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-2 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnBalanceChange = 1 AND ysnQtyChange = 1
		AND     intPricingTypeId <> 5

		------------------Status changes---------------------

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Quantity'  AS strFieldName
				,SH.dblQuantity AS dblOldValue
				,SH.dblQuantity * -1 AS dblTransactionQuantity
				,0 AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-3 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnStatusChange = 1 AND SH.intContractStatusId = 3
		
		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Balance' AS strFieldName
				,SH.dblBalance AS dblOldValue
				,SH.dblBalance * -1 AS dblTransactionQuantity
				,0 AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-4 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnStatusChange = 1 AND SH.intContractStatusId = 3
		
		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Balance' AS strFieldName
				,SH.dblBalance AS dblOldValue
				,SH.dblBalance * -1 AS dblTransactionQuantity
				,0 AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-5 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnStatusChange = 1 AND SH.intContractStatusId = 6

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Quantity'  AS strFieldName
				,0 AS dblOldValue
				,SH.dblQuantity AS dblTransactionQuantity
				,SH.dblQuantity AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-6 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnStatusChange = 1 AND SH.intOldStatusId = 3
		
		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Balance' AS strFieldName
				,0 AS dblOldValue
				,SH.dblBalance AS dblTransactionQuantity
				,SH.dblBalance AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-7 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnStatusChange = 1 AND SH.intOldStatusId = 3
		
		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Balance' AS strFieldName
				,0 AS dblOldValue
				,SH.dblBalance AS dblTransactionQuantity
				,SH.dblBalance AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-8 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnStatusChange = 1 AND SH.intOldStatusId = 6

		------------------Price changes---------------------

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Futures' AS strFieldName
				,SH.dblOldFutures AS dblOldValue
				,SH.dblFutures - dblOldFutures AS dblTransactionQuantity
				,SH.dblFutures AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-9 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnFuturesChange = 1

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Basis' AS strFieldName
				,SH.dblOldBasis AS dblOldValue
				,SH.dblBasis - dblOldBasis AS dblTransactionQuantity
				,SH.dblBasis AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-10 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnBasisChange = 1

		UNION ALL

		SELECT	 SH.intContractDetailId
				,SH.intContractHeaderId
				,SH.intContractSeq
				,SH.dtmTransactionDate
				,'Contract' AS strScreenName
				,SH.strNumber
				,'Cash Price' AS strFieldName
				,SH.dblCashPrice AS dblOldValue
				,SH.dblCashPrice - dblOldCashPrice AS dblTransactionQuantity
				,SH.dblCashPrice AS dblNewValue
				,SH.dblBalance
				,SH.strUserName
				,SH.intContractHeaderId AS intExternalHeaderId
				,SH.ysnDeleted
				,'intContractHeaderId' AS strHeaderIdColumn
				,SH.dtmScreenDate
				,-11 AS intSequenceUsageHistoryId

		FROM	CTEAudit SH
		WHERE	ysnCashPriceChange = 1
	)t 
