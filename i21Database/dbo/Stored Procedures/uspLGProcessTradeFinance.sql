CREATE PROCEDURE [dbo].[uspLGProcessTradeFinance]
	@intLoadId INT,
	@strAction NVARCHAR(20), /* 'ADD' or 'UPDATE' */
	@intUserId INT
AS
BEGIN 
	DECLARE @TRFTradeFinance TRFTradeFinance
			,@TRFLog TRFLog
			,@intTradeFinanceId INT = NULL
	
	/* Generate Trade Finance No if blank */
	IF NOT EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ISNULL(strTradeFinanceNo, '') <> '')
	BEGIN
		DECLARE @strTradeFinanceNumber NVARCHAR(100)	
		EXEC uspSMGetStartingNumber 166, @strTradeFinanceNumber OUT

		UPDATE tblLGLoad
		SET strTradeFinanceNo = @strTradeFinanceNumber
		WHERE intLoadId = @intLoadId
	END

	/* Get intTradeFinanceId */
	SELECT TOP 1 @intTradeFinanceId = intTradeFinanceId 
	FROM tblTRFTradeFinance TRF
	INNER JOIN tblLGLoad L ON L.strTradeFinanceNo = TRF.strTradeFinanceNumber 
		AND TRF.strTransactionType = 'Logistics' AND TRF.intTransactionHeaderId = L.intLoadId
	WHERE L.intLoadId = @intLoadId

	/* Construct Trade Finance SP parameter */
	INSERT INTO @TRFTradeFinance
	SELECT
		intTradeFinanceId = @intTradeFinanceId
		,strTradeFinanceNumber = L.strTradeFinanceNo
		,strTransactionType = 'Logistics'
		,strTransactionNumber = L.strLoadNumber
		,intTransactionHeaderId = L.intLoadId
		,intTransactionDetailId = LD.intLoadDetailId
		,intBankId = BA.intBankId
		,intBankAccountId = L.intBankAccountId
		,intBorrowingFacilityId = L.intBorrowingFacilityId
		,intLimitTypeId = L.intBorrowingFacilityLimitId
		,intSublimitTypeId = L.intBorrowingFacilityLimitDetailId
		,ysnSubmittedToBank = L.ysnSubmittedToBank
		,dtmDateSubmitted = L.dtmDateSubmitted
		,strApprovalStatus = AP.strApprovalStatus
		,dtmDateApproved = L.dtmDateApproved
		,strRefNo = L.strTradeFinanceReferenceNo
		,intOverrideFacilityValuation = L.intBankValuationRuleId
		,strCommnents = L.strTradeFinanceComments
		,dtmCreatedDate = GETDATE()
		,intConcurrencyId = 1
	FROM
		tblLGLoad L
		CROSS APPLY (SELECT TOP 1 intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = L.intLoadId AND intPContractDetailId = L.intContractDetailId) LD
		INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = L.intContractDetailId
		INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
		LEFT JOIN tblCTApprovalStatusTF AP on AP.intApprovalStatusId = L.intApprovalStatusId
		LEFT JOIN tblCMBankLoan BL on BL.intBankLoanId = L.intLoanLimitId
	WHERE intLoadId = @intLoadId
	
	/* Execute Trade Finance SP */
	If (@strAction = 'ADD' OR @intTradeFinanceId IS NULL)
	BEGIN
		EXEC [uspTRFCreateTFRecord] @records = @TRFTradeFinance, @intUserId = @intUserId
	END	
	ELSE
	BEGIN
		EXEC [uspTRFModifyTFRecord] @records = @TRFTradeFinance, @intUserId = @intUserId, @strAction = @strAction
	END

	/* Construct Trade Finance Log SP parameter */
	SELECT TOP 1 @intTradeFinanceId = intTradeFinanceId 
	FROM tblTRFTradeFinance WHERE strTransactionType = 'Logistics' AND intTransactionHeaderId = @intLoadId

	INSERT INTO @TRFLog
	SELECT
		strAction = CASE WHEN (@strAction = 'ADD') THEN 'Created ' ELSE 'Updated ' END
					+ CASE WHEN (L.intShipmentType = 2) THEN 'Shipping Instruction' ELSE 'Shipment' END
		,strTransactionType = 'Logistics'
		,intTradeFinanceTransactionId = @intTradeFinanceId
		,strTradeFinanceTransaction = L.strTradeFinanceNo
		,intTransactionHeaderId = L.intLoadId
		,intTransactionDetailId = LD.intLoadDetailId
		,strTransactionNumber = L.strLoadNumber
		,dtmTransactionDate = GETDATE()
		,intBankTransactionId = null
		,strBankTransactionId = null
		,dblTransactionAmountAllocated = CD.dblLoanAmount
		,dblTransactionAmountActual = CD.dblLoanAmount
		,intLoanLimitId = L.intLoanLimitId
		,strLoanLimitNumber = BL.strBankLoanId
		,strLoanLimitType = BL.strLimitDescription
		,dtmAppliedToTransactionDate = GETDATE()
		,intStatusId = CASE WHEN L.intShipmentStatus = 4 THEN 2 ELSE 1 END
		,intWarrantId = null
		,strWarrantId = null
		,intUserId = @intUserId
		,intConcurrencyId = 1
		,intContractHeaderId = CD.intContractHeaderId
		,intContractDetailId = L.intContractDetailId
	FROM tblLGLoad L
		CROSS APPLY (SELECT TOP 1 intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = L.intLoadId AND intPContractDetailId = L.intContractDetailId) LD
		INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = L.intContractDetailId
		INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN tblCMBankLoan BL on BL.intBankLoanId = L.intLoanLimitId
	WHERE intLoadId = @intLoadId

	IF EXISTS (SELECT 1 FROM @TRFLog)
	BEGIN
		EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
	END

END

GO