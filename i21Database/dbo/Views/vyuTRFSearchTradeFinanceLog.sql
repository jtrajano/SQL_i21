CREATE VIEW [dbo].[vyuTRFSearchTradeFinanceLog]

AS

SELECT intRowNumber  = row_number() OVER(ORDER BY dtmCreatedDate DESC) 
	, dtmCreatedDate
	, strAction
	, strTransactionType
	, strTradeFinanceTransaction
	, intTransactionHeaderId
	, intTransactionDetailId
	, strTransactionNumber
	, tf.dtmTransactionDate
	, intBankTransactionId
	, strBankTransactionId
	, dblTransactionAmountAllocated
	, dblTransactionAmountActual
	, intLoanLimitId
	, strLoanLimitNumber
	, strLoanLimitType
	, dtmAppliedToTransactionDate
	, intStatusId
	, strStatus = CASE WHEN intStatusId = 1 THEN 'Active' ELSE 'Completed' END
	, intWarrantId
	, strWarrantId
	, strUserName = U.strName
	, der.intFutOptTransactionHeaderId
	, der.strInternalTradeNo
	, sold_to.intContractHeaderId
	, sold_to.strContractNumber
	, tf.intConcurrencyId
FROM tblTRFTradeFinanceLog tf
LEFT JOIN tblEMEntity U ON U.intEntityId = tf.intUserId

OUTER APPLY(
	SELECT TOP 1 
			ifot.intFutOptTransactionHeaderId
		  , ifot.strInternalTradeNo 
	FROM tblRKAssignFuturesToContractSummary aftcs
	LEFT JOIN tblRKFutOptTransaction ifot
		ON aftcs.intFutOptTransactionId = ifot.intFutOptTransactionId
	WHERE tf.strTransactionType = 'Contract'
	AND tf.intTransactionDetailId = aftcs.intContractDetailId
	AND aftcs.ysnIsHedged = 1
	ORDER BY aftcs.dtmMatchDate DESC
) der

OUTER APPLY(
	SELECT TOP 1 
		  cth.intContractHeaderId
		, cth.strContractNumber
	FROM tblLGAllocationDetail allocd
	LEFT JOIN tblCTContractDetail ctd
		ON allocd.intSContractDetailId = ctd.intContractDetailId
	LEFT JOIN tblCTContractHeader cth
		ON ctd.intContractHeaderId = cth.intContractHeaderId
	WHERE  tf.strTransactionType = 'Contract'
	AND	intPContractDetailId = tf.intTransactionDetailId
	ORDER BY allocd.dtmAllocatedDate DESC
) sold_to
