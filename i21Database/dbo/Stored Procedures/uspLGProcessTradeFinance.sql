CREATE PROCEDURE [dbo].[uspLGProcessTradeFinance]
	@intLoadId INT,
	@strAction NVARCHAR(20),
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
			,@intApprovalStatusId INT = NULL
			,@ysnDelete BIT = 0
			,@intSourceType INT = NULL
			,@intPurchaseSale INT = NULL

	IF @strAction = 'DELETE' BEGIN SET @ysnDelete = 1 END

	/* Get current approval status */
	SELECT 
		@intApprovalStatusId = intApprovalStatusId,
		@intSourceType = intSourceType,
		@intPurchaseSale = intPurchaseSale
	FROM tblLGLoad WHERE intLoadId = @intLoadId
	
	/* Get Last Trade Finance Number associated to this LS */
	SELECT TOP 1 
		@intLastTradeFinanceId = intTradeFinanceId
		,@strLastTradeFinanceNo = TRF.strTradeFinanceNumber
		,@strLastApprovalStatus = TRF.strApprovalStatus
	FROM tblTRFTradeFinance TRF
	WHERE TRF.strTransactionType = 'Logistics' AND TRF.intTransactionHeaderId = @intLoadId
	ORDER BY intTradeFinanceId DESC

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

	/* If LS is for deletion, no need to modify TF records */
	IF (@ysnDelete <> 1)
	BEGIN

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

		/* If Last Trade Finance Number does not match the current Trade Finance Number, Cancel/Reject the previous */
		IF (@strLastTradeFinanceNo IS NOT NULL AND ISNULL(@strLastApprovalStatus, '') NOT IN ('Canceled', 'Cancelled', 'Rejected')
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
				,strApprovalStatus = CASE WHEN ISNULL(@intApprovalStatusId, '') = 3 THEN 'Rejected' ELSE 'Cancelled' END
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
	END

	IF (@intPurchaseSale = 1)
	BEGIN
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
			,intContractDetailId
			,intOverrideBankValuationId
			,ysnDeleted)
		SELECT
			strAction = CASE WHEN (@strAction = 'ADD') THEN 'Created ' ELSE CASE WHEN (@ysnDelete = 1) THEN 'Deleted ' ELSE 'Updated ' END END
						+ CASE WHEN (L.intShipmentType = 2) THEN 'Shipping Instruction' ELSE 'Shipment 1' END
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
			,intOverrideBankValuationId = L.intBankValuationRuleId
			,ysnDeleted = @ysnDelete
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
			/* If Last Trade Finance Number does not match the current Trade Finance Number, Cancel/Reject the previous */
			IF (@strLastTradeFinanceNo IS NOT NULL AND ISNULL(@strLastApprovalStatus, '') NOT IN ('Canceled', 'Cancelled', 'Rejected')
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
					,dblFinanceQty = 0
					,dblFinancedAmount
					,strBankApprovalStatus = CASE WHEN ISNULL(@intApprovalStatusId, '') = 3 THEN 'Rejected' ELSE 'Cancelled' END
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

			IF EXISTS (SELECT 1 FROM @TRFLog WHERE ISNULL(strTradeFinanceTransaction, '') <> '') OR @ysnDelete = 1
				EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog;
		END

		/* Clear trade finance approval status after updating tfrecord and logs if rejected/cancelled */
		IF (@intApprovalStatusId = 3 OR @intApprovalStatusId = 4)
		BEGIN
			UPDATE tblLGLoad
			SET intApprovalStatusId = NULL
			WHERE intLoadId = @intLoadId 
		END
	END
	/* Log Outbound Shipment TF logs upon creation and deletion */
	ELSE IF (@intPurchaseSale = 2 AND @intSourceType IN (5,6) AND
			(@ysnDelete = 1 OR NOT EXISTS (SELECT * FROM tblTRFTradeFinanceLog WHERE intTransactionHeaderId = @intLoadId)))
	BEGIN

		INSERT INTO @TRFLog (
			strAction
			, strTransactionType
			, intTradeFinanceTransactionId
			, strTradeFinanceTransaction
			, intTransactionHeaderId
			, intTransactionDetailId
			, strTransactionNumber
			, dtmTransactionDate
			, intBankTransactionId
			, strBankTransactionId
			, dblTransactionAmountAllocated
			, dblTransactionAmountActual
			, dtmAppliedToTransactionDate
			, intStatusId
			, intWarrantId
			, strWarrantId
			, intUserId
			, intConcurrencyId
			, intContractHeaderId
			, intContractDetailId
			, intBankId
			, intBankAccountId
			, intBorrowingFacilityId
			, intLimitId
			, intSublimitId
			, strBankTradeReference
			, strBankApprovalStatus
			, dblLimit
			, dblSublimit
			, dblFinanceQty
			, dblFinancedAmount
			, strBorrowingFacilityBankRefNo
			, ysnDeleted
			, intOverrideBankValuationId
		)
		SELECT
			strAction = CASE WHEN @ysnDelete = 1 THEN 'Deleted ' ELSE 'Created ' END + 'Shipment'
			, strTransactionType = 'Logistics'
			, intTradeFinanceTransactionId = TF.intTradeFinanceId
			, strTradeFinanceTransaction = TF.strTradeFinanceNumber
			, intTransactionHeaderId = L.intLoadId
			, intTransactionDetailId = LD.intLoadDetailId
			, strTransactionNumber = L.strLoadNumber
			, dtmTransactionDate = getdate()
			, intBankTransactionId = null
			, strBankTransactionId = null
			, dblTransactionAmountAllocated = IC.dblGrandTotal 
			, dblTransactionAmountActual = IC.dblGrandTotal
			, dtmAppliedToTransactionDate = getdate()
			, intStatusId = 1
			, intWarrantId = null
			, strWarrantId = null
			, intUserId = @intUserId
			, intConcurrencyId = 1
			, intContractHeaderId = CR.intContractHeaderId
			, intContractDetailId = CR.intContractDetailId
			, intBankId = IC.intBankId
			, intBankAccountId = IC.intBankAccountId
			, intBorrowingFacilityId = IC.intBorrowingFacilityId
			, intLimitId = IC.intLimitTypeId
			, intSublimitId = IC.intSublimitTypeId
			, strBankTradeReference = IC.strReferenceNo
			, strBankApprovalStatus = IC.strApprovalStatus
			, dblLimit = FL.dblLimit
			, dblSublimit = FLD.dblLimit
			, dblFinanceQty = LT.dblLotQuantity
			, dblFinancedAmount = (IC.dblSubTotal  / LT.dblLotQuantity) * (LT.dblLotQuantity)
			, strBorrowingFacilityBankRefNo = IC.strBankReferenceNo
			, ysnDeleted = @ysnDelete
			, intOverrideBankValuationId = TF.intOverrideFacilityValuation
		FROM
			tblLGLoad L
			INNER JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId
			INNER JOIN tblLGLoadDetailLot LT ON LT.intLoadDetailId = LD.intLoadDetailId
			INNER JOIN tblICInventoryReceiptItemLot IL ON IL.intLotId = LT.intLotId
			INNER JOIN tblICInventoryReceiptItem II ON II.intInventoryReceiptItemId = IL.intInventoryReceiptItemId
			INNER JOIN tblICInventoryReceipt IC ON IC.intInventoryReceiptId = II.intInventoryReceiptId
			INNER JOIN tblTRFTradeFinance TF ON TF.strTradeFinanceNumber = (IC.strTradeFinanceNumber COLLATE Latin1_General_CI_AS) and TF.strTransactionType = 'Inventory'
			LEFT JOIN tblCMBorrowingFacilityLimit FL ON FL.intBorrowingFacilityLimitId = IC.intLimitTypeId
			LEFT JOIN tblCMBorrowingFacilityLimitDetail FLD ON FLD.intBorrowingFacilityLimitDetailId = IC.intSublimitTypeId
			OUTER APPLY (
						SELECT TOP 1 
							RI.intContractHeaderId
							,RI.intContractDetailId
						FROM 
							tblICInventoryReceiptItem RI 
						WHERE
							RI.intInventoryReceiptId = IC.intInventoryReceiptId
					) CR
		WHERE L.intLoadId = @intLoadId

		-- Log Trade Finance
		IF EXISTS(SELECT 1 FROM @TRFLog)
		BEGIN
			EXEC uspTRFLogTradeFinance @TradeFinanceLogs = @TRFLog
		END
	END
END

GO