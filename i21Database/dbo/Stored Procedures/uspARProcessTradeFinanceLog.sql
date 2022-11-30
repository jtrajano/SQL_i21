CREATE PROCEDURE [dbo].[uspARProcessTradeFinanceLog]
	  @InvoiceIds		InvoiceId READONLY
	 ,@UserId			INT
	 ,@TransactionType	NVARCHAR(15)
	 ,@ForDelete		BIT = 0
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
)
SELECT
	  strAction						= CASE WHEN @TransactionType = 'Payment' 
										THEN CASE WHEN ARI.ysnPosted = 1 THEN 'Posted Payment' ELSE 'Unposted Payment' END
										ELSE CASE WHEN @ForDelete = 1 THEN 'Deleted ' ELSE ISNULL(ARAL.strActionType, 'Created') END + ' ' + @TransactionType
									  END
	, strTransactionType			= @TransactionType
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
FROM tblARInvoiceDetail ARID WITH (NOLOCK)
INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.intInvoiceId = ARI.intInvoiceId
INNER JOIN @PaymentStaging PS ON PS.intInvoiceId = ARID.intInvoiceId
LEFT JOIN tblCTContractDetail CTCD on CTCD.intContractDetailId = ARID.intContractDetailId
LEFT JOIN tblCTContractHeader CTCH on CTCH.intContractHeaderId = CTCD.intContractHeaderId
LEFT JOIN tblCMBorrowingFacilityLimit CMBFL ON ARI.intBorrowingFacilityLimitId = CMBFL.intBorrowingFacilityLimitId
WHERE ISNULL(ARI.intBankId, 0) <> 0
  AND ISNULL(ARI.intBankAccountId, 0) <> 0
  AND ISNULL(ARI.intBorrowingFacilityId, 0) <> 0
  AND ISNULL(ARI.intBorrowingFacilityLimitId, 0) <> 0

EXEC uspTRFLogTradeFinance @TradeFinanceLogs

RETURN 0