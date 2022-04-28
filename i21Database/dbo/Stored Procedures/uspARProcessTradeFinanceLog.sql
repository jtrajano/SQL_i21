CREATE PROCEDURE [dbo].[uspARProcessTradeFinanceLog]
	  @InvoiceIds			InvoiceId READONLY
	 ,@UserId				INT
	 ,@TransactionType		NVARCHAR(15)
	 ,@ForDelete			BIT = 0
	 ,@Post					BIT = 0
	 ,@FromPosting			BIT = 0
	 ,@LogTradeFinanceInfo	BIT = 0
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

DECLARE  @TRFTradeFinance	TRFTradeFinance
		,@TradeFinanceLogs	TRFLog
		,@strAction			NVARCHAR(30) = ''
		,@intStatusId		INT = 0

IF @TransactionType = 'Payment'
BEGIN
	IF @Post = 1
		BEGIN
			SET @strAction = 'Posted Payment'
			SET @intStatusId = 2
		END
	ELSE
	BEGIN
		SET @strAction = 'Unposted Payment'
		SET @intStatusId = 1
	END
END

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
	  strAction						= CASE WHEN @strAction = '' 
										   THEN CASE WHEN @FromPosting = 1 
												     THEN CASE WHEN @Post = 1 THEN 'Posted ' ELSE ' Unposted ' END
													 ELSE
														CASE WHEN @ForDelete = 1 
															 THEN 'Deleted ' 
															 ELSE ISNULL(ARAL.strActionType, 'Created') 
														END
													 END   + ' ' + @TransactionType
									       ELSE @strAction 
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
	, strBankApprovalStatus			=  ISNULL(LS.strApprovalStatus, '')
	, dtmAppliedToTransactionDate	= GETDATE() 
	, intStatusId					= CASE WHEN @intStatusId = 0
										   THEN CASE WHEN @FromPosting = 1 
												     THEN 1
													 ELSE
														CASE WHEN @ForDelete = 1 
															 THEN 3
															 ELSE 1
														END
													 END
									       ELSE @intStatusId 
									  END
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
ON ARI.intInvoiceId = ARID.intInvoiceId
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
OUTER APPLY (
	SELECT TOP 1 ICIR.strApprovalStatus
	FROM tblLGLoadDetailLot LGLD
	LEFT JOIN tblICInventoryReceiptItemLot ICIRIL ON ICIRIL.intLotId = LGLD.intLotId
	LEFT JOIN tblICInventoryReceiptItem ICIRI ON ICIRI.intInventoryReceiptItemId = ICIRIL.intInventoryReceiptItemId
	LEFT JOIN tblICInventoryReceipt ICIR ON ICIR.intInventoryReceiptId = ICIRI.intInventoryReceiptId
	WHERE LGLD.intLoadDetailId = ARID.intLoadDetailId
) LS
WHERE ARI.intInvoiceId IN (SELECT intHeaderId FROM @InvoiceIds)
AND (
	(ISNULL(ARPD.intPaymentDetailId, 0) <> 0 AND @TransactionType = 'Payment')
	OR
	@TransactionType <> 'Payment'
)
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
	OR @ForDelete = 1
	OR @FromPosting = 1
	OR @LogTradeFinanceInfo = 1
)

DECLARE  @strTradeFinanceNumber		NVARCHAR(100)
		,@dtmTransactionDate		DATETIME
		,@intTransactionHeaderId	INT = 0
DECLARE TFLogCursor CURSOR LOCAL FAST_FORWARD
FOR
SELECT 
	 strTradeFinanceTransaction
	,dtmTransactionDate
	,strAction
	,intTransactionHeaderId
FROM @TradeFinanceLogs
GROUP BY 
	 strTradeFinanceTransaction
	,dtmTransactionDate
	,strAction
	,intTransactionHeaderId

OPEN TFLogCursor

FETCH NEXT FROM TFLogCursor INTO 
	 @strTradeFinanceNumber
	,@dtmTransactionDate
	,@strAction
	,@intTransactionHeaderId

WHILE @@FETCH_STATUS = 0
BEGIN
	DECLARE	 @strImpactedModule			NVARCHAR(100) = 'Sales'
			,@intTradeFinanceId			INT = NULL
			,@strNewTradeFinanceNumber	NVARCHAR(100)

	IF @FromPosting = 0
	BEGIN
		SELECT TOP 1 @intTradeFinanceId = intTradeFinanceId 
		FROM tblTRFTradeFinance TRTF
		INNER JOIN @TradeFinanceLogs TRFL 
		ON TRTF.strTransactionNumber = TRFL.strTransactionNumber AND TRTF.strTransactionType = 'Sales' AND TRTF.intTransactionHeaderId = TRFL.intTransactionHeaderId
		WHERE strTradeFinanceNumber = @strTradeFinanceNumber

		IF (ISNULL(@strTradeFinanceNumber, '') = '')
		BEGIN
			EXEC uspSMGetStartingNumber 166, @strNewTradeFinanceNumber OUT
		END	

		DELETE FROM @TRFTradeFinance
		-- This is for direct invoice.
		INSERT INTO @TRFTradeFinance 
		(
			 intTradeFinanceId
			,strTradeFinanceNumber
			,strTransactionType
			,strTransactionNumber
			,intTransactionHeaderId
			,intTransactionDetailId
			,intBankId
			,intBankAccountId
			,intBorrowingFacilityId
			,strRefNo
			,intOverrideFacilityValuation
			,strCommnents
			,dtmCreatedDate
			,intConcurrencyId
		)
		SELECT
			 intTradeFinanceId				= @intTradeFinanceId
			,strTradeFinanceNumber			= ISNULL(TFL.strTradeFinanceTransaction, @strNewTradeFinanceNumber)
			,strTransactionType				= TFL.strTransactionType
			,strTransactionNumber			= TFL.strTransactionNumber
			,intTransactionHeaderId			= TFL.intTransactionHeaderId
			,intTransactionDetailId			= TFL.intTransactionDetailId
			,intBankId						= ARI.intBankId
			,intBankAccountId				= ARI.intBankAccountId
			,intBorrowingFacilityId			= ARI.intBorrowingFacilityId
			,strRefNo						= ARI.strBankReferenceNo
			,intOverrideFacilityValuation	= ARI.intBankValuationRuleId
			,strCommnents					= ARI.strTradeFinanceComments
			,dtmCreatedDate					= GETDATE()
			,intConcurrencyId				= 1
		FROM @TradeFinanceLogs TFL
		INNER JOIN tblARInvoice ARI WITH (NOLOCK)
		ON ARI.intInvoiceId = TFL.intTransactionHeaderId
		WHERE ARI.intInvoiceId = @intTransactionHeaderId

		IF (ISNULL(@strTradeFinanceNumber, '') = '')
		BEGIN
			UPDATE tblARInvoice 
			SET strTransactionNo = @strNewTradeFinanceNumber
			WHERE intInvoiceId = @intTransactionHeaderId

			UPDATE @TradeFinanceLogs 
			SET strTradeFinanceTransaction = @strNewTradeFinanceNumber
			WHERE intTransactionHeaderId = @intTransactionHeaderId

			EXEC [uspTRFCreateTFRecord] @records = @TRFTradeFinance, @intUserId = @UserId
		END	
		ELSE IF ISNULL(@intTradeFinanceId, 0) <> 0
		BEGIN
			EXEC [uspTRFModifyTFRecord] @records = @TRFTradeFinance, @intUserId = @UserId, @strAction = 'UPDATE'
		END
	END

	SELECT TOP 1 @strImpactedModule = strTransactionType
	FROM tblTRFTradeFinanceLog
	WHERE strTradeFinanceTransaction = @strTradeFinanceNumber
	ORDER BY dtmTransactionDate DESC

	EXEC uspTRFNegateTFLogFinancedQtyAndAmount
		 @strTradeFinanceNumber = @strTradeFinanceNumber
		,@strTransactionType	= @strImpactedModule
		,@strLimitType			= NULL
		,@dtmTransactionDate	= @dtmTransactionDate
		,@strAction				= @strAction

	FETCH NEXT FROM TFLogCursor INTO 
		 @strTradeFinanceNumber
		,@dtmTransactionDate
		,@strAction
		,@intTransactionHeaderId
END

CLOSE TFLogCursor
DEALLOCATE TFLogCursor

IF @ForDelete <> 1
BEGIN
	EXEC uspTRFLogTradeFinance @TradeFinanceLogs
END

RETURN 0