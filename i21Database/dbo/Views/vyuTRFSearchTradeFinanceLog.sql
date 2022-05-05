CREATE VIEW [dbo].[vyuTRFSearchTradeFinanceLog]

AS

SELECT intRowNumber  = row_number() OVER(ORDER BY tf.dtmCreatedDate DESC) 
	, tf.dtmCreatedDate
	, tf.strAction
	, tf.strTransactionType
	, tf.strTradeFinanceTransaction
	, tf.intTransactionHeaderId
	, tf.intTransactionDetailId
	, tf.strTransactionNumber
	, tf.dtmTransactionDate
	, tf.intBankTransactionId
	, tf.strBankTransactionId
	, tf.dblTransactionAmountAllocated
	, tf.dblTransactionAmountActual
	, tf.intLoanLimitId
	, tf.strLoanLimitNumber
	, tf.strLoanLimitType
	, tf.dtmAppliedToTransactionDate
	, tf.intStatusId
	, strStatus = CASE WHEN  tf.intStatusId = 1 THEN 'Active' 
						WHEN tf.intStatusId = 2 THEN 'Completed'
						WHEN tf.intStatusId = 3 THEN 'Inactive'
						WHEN tf.intStatusId = 0 THEN 'Cancelled'
						ELSE '' END
	, tf.intWarrantId
	, tf.strWarrantId
	, strUserName = U.strName
	, der.intFutOptTransactionHeaderId
	, der.strInternalTradeNo
	, sold_to.intContractHeaderId
	, sold_to.strContractNumber
	, tf.intConcurrencyId
	, tf.strBank
	, tf.strBankAccount
	, tf.strBorrowingFacility
	, tf.strBorrowingFacilityBankRefNo
	, tf.strLimit
	, tf.dblLimit
	, tf.strSublimit
	, tf.dblSublimit
	, tf.strBankTradeReference
	, dblFinanceQty = ROUND(tf.dblFinanceQty, 2)
	, dblFinancedAmount = ROUND(tf.dblFinancedAmount, 2)
	, tf.strBankApprovalStatus
	, wStatus.strWarrantStatus
FROM tblTRFTradeFinanceLog tf
LEFT JOIN tblEMEntity U 
	ON U.intEntityId = tf.intUserId
LEFT JOIN tblICWarrantStatus wStatus
	ON wStatus.intWarrantStatus = tf.intWarrantStatusId

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
