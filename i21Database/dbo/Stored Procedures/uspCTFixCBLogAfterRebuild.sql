CREATE PROCEDURE uspCTFixCBLogAfterRebuild 
	@strContractNumber NVARCHAR(50) = 'All' -->> Specify Contract Number, put All if you want to apply in all contracts
	, @strContractType NVARCHAR(50) = 'All' -->> Purchase or Sale

AS

BEGIN
	DECLARE @intContractTypeId INT
		, @intContractHeaderId INT

	SELECT @intContractTypeId = intContractTypeId FROM tblCTContractType WHERE strContractType = @strContractType
	SELECT @intContractHeaderId = intContractHeaderId FROM tblCTContractHeader WHERE strContractNumber = @strContractNumber

	-----------------------------------------------------
	-- UPDATE Null Transaction Reference Ids (CT-6094) --
	-----------------------------------------------------
	UPDATE cbLog
	SET cbLog.intTransactionReferenceDetailId = pfd.intPriceFixationDetailId
		, cbLog.intTransactionReferenceId = pf.intPriceContractId
	FROM tblCTContractBalanceLog cbLog
	JOIN tblCTPriceFixation pf ON pf.intPriceFixationId = cbLog.intTransactionReferenceId
	CROSS APPLY (
		SELECT pfd.intPriceFixationDetailId FROM tblCTPriceFixationDetail pfd WHERE pfd.intPriceFixationId = pf.intPriceFixationId AND pfd.dtmFixationDate = cbLog.dtmTransactionDate
	) pfd
	WHERE cbLog.intActionId = 1
		AND cbLog.strTransactionReference = 'Price Fixation' 
		AND cbLog.intTransactionReferenceDetailId IS NULL
		AND cbLog.intContractHeaderId = (CASE WHEN @strContractNumber = 'All' THEN cbLog.intContractHeaderId ELSE @intContractHeaderId END)
		AND cbLog.intContractTypeId = (CASE WHEN @strContractType = 'All' THEN cbLog.intContractTypeId ELSE @intContractTypeId END)
	-----------------------------------------------
	-- END UPDATE Null Transaction Reference Ids --
	-----------------------------------------------

END