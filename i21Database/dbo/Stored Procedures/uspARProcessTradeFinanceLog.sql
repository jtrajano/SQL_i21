CREATE PROCEDURE [dbo].[uspARProcessTradeFinanceLog]
	  @InvoiceIds			InvoiceId READONLY
	 ,@UserId				INT
	 ,@TransactionType		NVARCHAR(15)
	 ,@ForDelete			BIT = 0
	 ,@LogTradeFinanceInfo	BIT = 0
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

DECLARE   @TradeFinanceLogs	TRFLog
		, @strAction		NVARCHAR(30)

INSERT INTO @TradeFinanceLogs (
	  strAction
	, strTransactionType
	, intTransactionHeaderId
	, intTransactionDetailId
	, strTransactionNumber
	, strTradeFinanceTransaction
	, dtmTransactionDate
	, intBankId
	, intBankAccountId
	, intBorrowingFacilityId
	, dblTransactionAmountAllocated
	, dblTransactionAmountActual
	, intLimitId
	, dblLimit
	, strBankTradeReference
	, strBankApprovalStatus
	, dtmAppliedToTransactionDate
	, intStatusId
	, intUserId
	, intConcurrencyId
	, dblFinanceQty
	, dblFinancedAmount
	, intContractHeaderId
	, intContractDetailId
	, intSublimitId
	, strSublimit
	, dblSublimit
)
SELECT
	  strAction						= CASE WHEN @TransactionType = 'Payment' 
										THEN CASE WHEN ARI.ysnPosted = 1 THEN 'Posted Payment' ELSE 'Unposted Payment' END
										ELSE CASE WHEN @ForDelete = 1 THEN 'Deleted ' ELSE ISNULL(ARAL.strActionType, 'Created') END + ' ' + @TransactionType
									  END
	, strTransactionType			= 'Sales'
	, intTransactionHeaderId		= CASE WHEN @TransactionType = 'Payment' THEN ARP.intPaymentId ELSE ARI.intInvoiceId END
	, intTransactionDetailId		= CASE WHEN @TransactionType = 'Payment' THEN ARPD.intPaymentDetailId ELSE ARID.intInvoiceDetailId END
	, strTransactionNumber			= CASE WHEN @TransactionType = 'Payment' THEN ARP.strRecordNumber ELSE ARI.strInvoiceNumber END
	, strTradeFinanceTransaction	= ARI.strTransactionNo
	, dtmTransactionDate			= GETDATE()
	, intBankId						= ARI.intBankId
	, intBankAccountId				= ARI.intBankAccountId
	, intBorrowingFacilityId		= ARI.intBorrowingFacilityId
	, dblTransactionAmountAllocated = CTCD.dblLoanAmount
	, dblTransactionAmountActual	= CTCD.dblLoanAmount
	, intLimitId					= ARI.intBorrowingFacilityLimitId
	, dblLimit						= CMBFL.dblLimit
	, strBankTradeReference			= ARI.strBankReferenceNo
	, strBankApprovalStatus			= 'No Need For Approval'
	, dtmAppliedToTransactionDate	= GETDATE() 
	, intStatusId					= 2
	, intUserId						= @UserId
	, intConcurrencyId				= 1 
	, dblFinanceQty					= ARID.dblQtyShipped
	, dblFinancedAmount				= ARID.dblTotal
	, intContractHeaderId			= ARID.intContractHeaderId
	, intContractDetailId			= ARID.intContractDetailId
	, intSublimitId					= ARI.intBorrowingFacilityLimitDetailId
	, strSublimit					= CMBFLD.strLimitDescription
	, dblSublimit					= CMBFLD.dblLimit
FROM tblARInvoice ARI WITH (NOLOCK)
LEFT JOIN tblARInvoiceDetail ARID WITH (NOLOCK) 
ON (ARI.intInvoiceId = ARID.intInvoiceId AND ARI.intInvoiceId IN (SELECT intHeaderId FROM @InvoiceIds))
LEFT JOIN tblARPaymentDetail ARPD ON ARI.intInvoiceId = ARPD.intInvoiceId
LEFT JOIN tblARPayment ARP ON ARPD.intPaymentId = ARP.intPaymentId
LEFT JOIN tblCTContractDetail CTCD on CTCD.intContractDetailId = ARID.intContractDetailId
LEFT JOIN tblCTContractHeader CTCH on CTCH.intContractHeaderId = CTCD.intContractHeaderId
LEFT JOIN tblCMBorrowingFacilityLimit CMBFL ON ARI.intBorrowingFacilityLimitId = CMBFL.intBorrowingFacilityLimitId
LEFT JOIN tblCMBorrowingFacilityLimitDetail CMBFLD ON CMBFLD.intBorrowingFacilityLimitDetailId = ARI.intBorrowingFacilityLimitDetailId
OUTER APPLY (
	SELECT TOP 1 strActionType
	FROM tblARAuditLog
	WHERE strRecordNo COLLATE SQL_Latin1_General_CP1_CS_AS = ARI.strInvoiceNumber
	ORDER BY intAuditLogId DESC
) ARAL
WHERE ARI.intInvoiceId IN (SELECT intHeaderId FROM @InvoiceIds)
AND 
(
	(
		ISNULL(ARAL.strActionType, 'Created') = 'Created'
		AND (
			  ISNULL(ARI.intBankId, 0) <> 0
		   OR ISNULL(ARI.intBankAccountId, 0) <> 0
		   OR ISNULL(ARI.intBorrowingFacilityId, 0) <> 0
		   OR ISNULL(ARI.intBorrowingFacilityLimitId, 0) <> 0
		   OR ISNULL(ARI.strBankReferenceNo, '') <> ''
		   OR ISNULL(ARI.dblLoanAmount, 0) <> 0
		   OR ISNULL(ARI.strTransactionNo, '') <> ''
		)
	)
	OR @LogTradeFinanceInfo = 1
)

EXEC uspTRFLogTradeFinance @TradeFinanceLogs

RETURN 0