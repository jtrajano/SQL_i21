CREATE PROCEDURE [dbo].[uspLGProcessTradeFinance]
	@intLoadId INT,
	@strAction NVARCHAR(20), /* 'ADD' or 'UPDATE' */
	@intUserId INT
AS
BEGIN 
	DECLARE @TRFTradeFinance TRFTradeFinance
			,@TRFTradeFinanceCancel TRFTradeFinance
			,@TRFLog TRFLog
			,@TRFLogCancel TRFLog
			,@intTradeFinanceId INT = NULL
			,@strTradeFinanceNumber NVARCHAR(100) = NULL
			,@intLastTradeFinanceId INT = NULL
			,@strLastTradeFinanceNo NVARCHAR(100) = NULL
			,@strLastApprovalStatus NVARCHAR(100) = NULL
			,@intLastTradeFinanceLogId INT = NULL
			,@strLastTradeFinanceLogStatus INT = NULL
	
	/* Generate Trade Finance No if blank */
	IF EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND intBankAccountId IS NOT NULL AND ISNULL(strTradeFinanceNo, '') = '')
	BEGIN	
		EXEC uspSMGetStartingNumber 166, @strTradeFinanceNumber OUT

		UPDATE tblLGLoad
		SET strTradeFinanceNo = @strTradeFinanceNumber
		WHERE intLoadId = @intLoadId
	END
	ELSE
	BEGIN
		SELECT @strTradeFinanceNumber = strTradeFinanceNo FROM tblLGLoad WHERE intLoadId = @intLoadId
	END

	/* Get intTradeFinanceId */
	SELECT TOP 1 @intTradeFinanceId = intTradeFinanceId 
	FROM tblTRFTradeFinance TRF
	INNER JOIN tblLGLoad L ON ISNULL(L.strTradeFinanceNo, '') = TRF.strTradeFinanceNumber 
		AND TRF.strTransactionType = 'Logistics' AND TRF.intTransactionHeaderId = L.intLoadId
	WHERE L.intLoadId = @intLoadId

	/* Construct Trade Finance SP parameter */
	INSERT INTO @TRFTradeFinance 
		(intTradeFinanceId
		,strTradeFinanceNumber
		,strTransactionType
		,strTransactionNumber
		,intTransactionHeaderId
		,intTransactionDetailId
		,intBankId
		,intBankAccountId
		,intBorrowingFacilityId
		,intLimitTypeId
		,intSublimitTypeId
		,ysnSubmittedToBank
		,dtmDateSubmitted
		,strApprovalStatus
		,dtmDateApproved
		,strRefNo
		,intOverrideFacilityValuation
		,strCommnents
		,dtmCreatedDate
		,intConcurrencyId)
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
	
	/* Get Last Trade Finance Number associated to this LS */
	SELECT TOP 1 
		@intLastTradeFinanceId = intTradeFinanceId
		,@strLastTradeFinanceNo = TRF.strTradeFinanceNumber
		,@strLastApprovalStatus = TRF.strApprovalStatus
	FROM tblTRFTradeFinance TRF
	WHERE TRF.strTransactionType = 'Logistics' AND TRF.intTransactionHeaderId = @intLoadId
	ORDER BY intTradeFinanceId DESC

	/* If Last Trade Finance Number does not match the current Trade Finance Number, Cancel the previous */
	IF (@strLastTradeFinanceNo IS NOT NULL AND ISNULL(@strLastApprovalStatus, '') NOT IN ('Canceled', 'Cancelled')
		AND ISNULL(@strLastTradeFinanceNo, '') <> ISNULL(@strTradeFinanceNumber, ''))
	BEGIN 
		INSERT INTO @TRFTradeFinanceCancel
			(intTradeFinanceId
			,strTradeFinanceNumber
			,strTransactionType
			,strTransactionNumber
			,intTransactionHeaderId
			,intTransactionDetailId
			,intBankId
			,intBankAccountId
			,intBorrowingFacilityId
			,intLimitTypeId
			,intSublimitTypeId
			,ysnSubmittedToBank
			,dtmDateSubmitted
			,strApprovalStatus
			,dtmDateApproved
			,strRefNo
			,intOverrideFacilityValuation
			,strCommnents
			,dtmCreatedDate
			,intConcurrencyId)
		SELECT
			intTradeFinanceId = @intLastTradeFinanceId
			,strTradeFinanceNumber = @strLastTradeFinanceNo
			,strTransactionType
			,strTransactionNumber
			,intTransactionHeaderId
			,intTransactionDetailId
			,intBankId
			,intBankAccountId
			,intBorrowingFacilityId
			,intLimitTypeId
			,intSublimitTypeId
			,ysnSubmittedToBank
			,dtmDateSubmitted
			,strApprovalStatus = 'Cancelled'
			,dtmDateApproved
			,strRefNo
			,intOverrideFacilityValuation
			,strCommnents
			,dtmCreatedDate = GETDATE()
			,intConcurrencyId = 1
		FROM @TRFTradeFinance

		EXEC [uspTRFModifyTFRecord] @records = @TRFTradeFinanceCancel, @intUserId = @intUserId, @strAction = @strAction
	END

	/* Execute Trade Finance SP */
	If (@strAction = 'ADD' OR (@intTradeFinanceId IS NULL AND ISNULL(@strTradeFinanceNumber, '') <> ''))
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
	ORDER BY intTradeFinanceId DESC

	INSERT INTO @TRFLog
		(strAction
		,strTransactionType
		,intTradeFinanceTransactionId
		,strTradeFinanceTransaction
		,intTransactionHeaderId
		,intTransactionDetailId
		,strTransactionNumber
		,dtmTransactionDate
		,intBankTransactionId
		,strBankTransactionId
		,intBankId
		,strBank
		,intBankAccountId
		,strBankAccount
		,intBorrowingFacilityId
		,strBorrowingFacility
		,strBorrowingFacilityBankRefNo
		,dblTransactionAmountAllocated
		,dblTransactionAmountActual
		,intLoanLimitId
		,strLoanLimitNumber
		,strLoanLimitType
		,intLimitId
		,strLimit
		,dblLimit
		,intSublimitId
		,strSublimit
		,dblSublimit
		,strBankTradeReference
		,dblFinanceQty
		,dblFinancedAmount
		,strBankApprovalStatus
		,dtmAppliedToTransactionDate
		,intStatusId
		,intWarrantId
		,strWarrantId
		,intUserId
		,intConcurrencyId
		,intContractHeaderId
		,intContractDetailId)
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
		,intBankId = BA.intBankId
		,strBank = BA.strBankName
		,intBankAccountId = L.intBankAccountId
		,strBankAccount = BA.strBankAccountNo
		,intBorrowingFacilityId = L.intBorrowingFacilityId
		,strBorrowingFacility = FA.strBorrowingFacilityId
		,strBorrowingFacilityBankRefNo = FA.strBankReferenceNo
		,dblTransactionAmountAllocated = CD.dblLoanAmount
		,dblTransactionAmountActual = CD.dblLoanAmount
		,intLoanLimitId = L.intLoanLimitId
		,strLoanLimitNumber = BL.strBankLoanId
		,strLoanLimitType = BL.strLimitDescription
		,intLimitId = L.intBorrowingFacilityLimitId
		,strLimit = FL.strBorrowingFacilityLimit
		,dblLimit = FL.dblLimit 
		,intSublimitId = L.intBorrowingFacilityLimitDetailId
		,strSublimit = FLD.strLimitDescription
		,dblSublimit = FLD.dblLimit
		,strBankTradeReference = L.strTradeFinanceReferenceNo
		,dblFinanceQty = LD.dblQuantity
		,dblFinancedAmount = LD.dblAmount
		,strBankApprovalStatus = ASTF.strApprovalStatus
		,dtmAppliedToTransactionDate = GETDATE()
		,intStatusId = CASE WHEN L.intShipmentStatus = 4 THEN 2 ELSE 1 END
		,intWarrantId = null
		,strWarrantId = L.strWarrantNo
		,intUserId = @intUserId
		,intConcurrencyId = 1
		,intContractHeaderId = CD.intContractHeaderId
		,intContractDetailId = L.intContractDetailId
	FROM tblLGLoad L
		CROSS APPLY (SELECT TOP 1 intLoadDetailId, dblQuantity, dblAmount FROM tblLGLoadDetail WHERE intLoadId = L.intLoadId AND intPContractDetailId = L.intContractDetailId) LD
		INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = L.intContractDetailId
		INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = CD.intContractHeaderId
		LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = L.intBankAccountId
		LEFT JOIN tblCMBorrowingFacility FA ON FA.intBorrowingFacilityId = L.intBorrowingFacilityId
		LEFT JOIN tblCMBorrowingFacilityLimit FL ON FL.intBorrowingFacilityLimitId = L.intBorrowingFacilityLimitId
		LEFT JOIN tblCMBorrowingFacilityLimitDetail FLD ON FLD.intBorrowingFacilityLimitDetailId = L.intBorrowingFacilityLimitDetailId
		LEFT JOIN tblCMBankValuationRule BVR ON BVR.intBankValuationRuleId = L.intBankValuationRuleId
		LEFT JOIN tblCTApprovalStatusTF ASTF on ASTF.intApprovalStatusId = L.intApprovalStatusId
		LEFT JOIN tblCMBankLoan BL on BL.intBankLoanId = L.intLoanLimitId
	WHERE intLoadId = @intLoadId

	IF EXISTS (SELECT 1 FROM @TRFLog)
	BEGIN
		/* If Last Trade Finance Number does not match the current Trade Finance Number, Cancel the previous */
		IF (@strLastTradeFinanceNo IS NOT NULL AND ISNULL(@strLastApprovalStatus, '') NOT IN ('Canceled', 'Cancelled')
			AND ISNULL(@strLastTradeFinanceNo, '') <> ISNULL(@strTradeFinanceNumber, ''))
		BEGIN

			INSERT INTO @TRFLogCancel
				(strAction
				,strTransactionType
				,intTradeFinanceTransactionId
				,strTradeFinanceTransaction
				,intTransactionHeaderId
				,intTransactionDetailId
				,strTransactionNumber
				,dtmTransactionDate
				,intBankTransactionId
				,strBankTransactionId
				,intBankId
				,strBank
				,intBankAccountId
				,strBankAccount
				,intBorrowingFacilityId
				,strBorrowingFacility
				,strBorrowingFacilityBankRefNo
				,dblTransactionAmountAllocated
				,dblTransactionAmountActual
				,intLoanLimitId
				,strLoanLimitNumber
				,strLoanLimitType
				,intLimitId
				,strLimit
				,dblLimit
				,intSublimitId
				,strSublimit
				,dblSublimit
				,strBankTradeReference
				,dblFinanceQty
				,dblFinancedAmount
				,strBankApprovalStatus
				,dtmAppliedToTransactionDate
				,intStatusId
				,intWarrantId
				,strWarrantId
				,intUserId
				,intConcurrencyId
				,intContractHeaderId
				,intContractDetailId)
			SELECT TOP 1
				strAction = REPLACE(strAction, 'Created', 'Updated')
				,strTransactionType
				,intTradeFinanceTransactionId = @intLastTradeFinanceId
				,strTradeFinanceTransaction = @strLastTradeFinanceNo
				,intTransactionHeaderId
				,intTransactionDetailId
				,strTransactionNumber
				,dtmTransactionDate = GETDATE()
				,intBankTransactionId
				,strBankTransactionId
				,intBankId
				,strBank
				,intBankAccountId
				,strBankAccount
				,intBorrowingFacilityId
				,strBorrowingFacility
				,strBorrowingFacilityBankRefNo
				,dblTransactionAmountAllocated
				,dblTransactionAmountActual
				,intLoanLimitId
				,strLoanLimitNumber
				,strLoanLimitType
				,intLimitId
				,strLimit
				,dblLimit
				,intSublimitId
				,strSublimit
				,dblSublimit
				,strBankTradeReference
				,dblFinanceQty
				,dblFinancedAmount
				,strBankApprovalStatus = 'Canceled'
				,dtmAppliedToTransactionDate = GETDATE()
				,intStatusId
				,intWarrantId
				,strWarrantId
				,intUserId
				,intConcurrencyId
				,intContractHeaderId
				,intContractDetailId
			FROM tblTRFTradeFinanceLog
			WHERE strTransactionType = 'Logistics'
			AND intTransactionHeaderId = @intLoadId
			ORDER BY intTradeFinanceLogId DESC

			EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLogCancel;
		END

		IF EXISTS (SELECT 1 FROM @TRFLog WHERE ISNULL(strTradeFinanceTransaction, '') <> '')
			EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
	END

END

GO