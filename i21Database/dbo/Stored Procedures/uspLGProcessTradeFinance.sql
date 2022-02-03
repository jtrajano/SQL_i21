CREATE PROCEDURE [dbo].[uspLGProcessTradeFinance]
	@intLoadId INT,
	@strAction NVARCHAR(20),
	@intUserId INT
AS
BEGIN 
	DECLARE @TRFTradeFinance TRFTradeFinance
			,@intTradeFinanceId INT = NULL
	
	IF (@strAction = 'ADD')
	BEGIN
		/* If Creating New entry, generate new Trade Finance No if blank */
		DECLARE @strTradeFinanceNumber NVARCHAR(100)
		IF NOT EXISTS(SELECT 1 FROM tblLGLoad WHERE intLoadId = @intLoadId AND ISNULL(strTradeFinanceNo, '') <> '')
		BEGIN
			EXEC uspSMGetStartingNumber 166, @strTradeFinanceNumber OUT

			UPDATE tblLGLoad
			SET strTradeFinanceNo = @strTradeFinanceNumber
			WHERE intLoadId = @intLoadId
		END
	END
	ELSE
	BEGIN 
		/* If Modiying or Deleting, get intTradeFinanceId*/
		SELECT TOP 1 @intTradeFinanceId = intTradeFinanceId 
		FROM tblTRFTradeFinance TRF
		INNER JOIN tblLGLoad L ON L.strTradeFinanceNo = TRF.strTradeFinanceNumber 
			AND TRF.strTransactionType = 'Logistics' AND TRF.intTransactionHeaderId = L.intLoadId
		WHERE L.intLoadId = @intLoadId
	END

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
	If @strAction = 'ADD'
	BEGIN
		EXEC [uspTRFCreateTFRecord] @records = @TRFTradeFinance, @intUserId = @intUserId
	END	
	ELSE
	BEGIN
		EXEC [uspTRFModifyTFRecord] @records = @TRFTradeFinance, @intUserId = @intUserId, @strAction = @strAction
	END


END