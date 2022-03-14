CREATE PROCEDURE [dbo].[uspARProcessTradeFinanceLog]
	  @PaymentStaging	PaymentIntegrationStagingTable READONLY
	 ,@UserId			INT
	 ,@Post				BIT
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

DECLARE @TradeFinanceLogs AS TRFLog

INSERT INTO @TradeFinanceLogs (
	strAction
	, strTransactionType
	, intTransactionHeaderId
	, intTransactionDetailId
	, strTransactionNumber
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
	, intWarrantId
	, strWarrantId
	, intUserId
	, intConcurrencyId
	, intContractHeaderId
	, intContractDetailId
)
SELECT
	  strAction						= CASE WHEN @Post = 1 THEN 'Posted Payment' ELSE 'Unposted Payment' END
	, strTransactionType			= 'Payment'
	, intTransactionHeaderId		= PS.intPaymentId
	, intTransactionDetailId		= PS.intPaymentDetailId
	, strTransactionNumber			= PS.strTransactionNumber
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
	, intWarrantId					= NULL
	, strWarrantId					= ''
	, intUserId						= @UserId
	, intConcurrencyId				= 1 
	, intContractHeaderId			= ARID.intContractHeaderId
	, intContractDetailId			= ARID.intContractDetailId
FROM tblARInvoiceDetail ARID WITH (NOLOCK)
INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON ARID.intInvoiceId = ARI.intInvoiceId
INNER JOIN @PaymentStaging PS ON PS.intInvoiceId = ARID.intInvoiceId
LEFT JOIN tblCTContractDetail CTCD on CTCD.intContractDetailId = ARID.intContractDetailId
LEFT JOIN tblCTContractHeader CTCH on CTCH.intContractHeaderId = CTCD.intContractHeaderId
LEFT JOIN tblCMBorrowingFacilityLimit CMBFL ON ARI.intBorrowingFacilityLimitId = CMBFL.intBorrowingFacilityLimitId
WHERE ISNULL(ARI.intBankId, 0) <> 0
   OR ISNULL(ARI.intBankAccountId, 0) <> 0
   OR ISNULL(ARI.intBorrowingFacilityId, 0) <> 0
   OR ISNULL(ARI.intBorrowingFacilityLimitId, 0) <> 0
   OR ISNULL(ARI.strBankReferenceNo, '') <> ''

EXEC uspTRFLogTradeFinance @TradeFinanceLogs

RETURN 0