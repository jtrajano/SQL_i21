CREATE FUNCTION [dbo].[fnCTGetTransactionForexRate]
(
	@intContractDetailId	INT
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@dblResult NUMERIC(18,6)
            ,@intTransactionForexId INT

    SELECT @intTransactionForexId = CH.intTransactionForexId
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	WHERE CD.intContractDetailId = @intContractDetailId

	IF @intTransactionForexId = 1 -- Contract
		SELECT @dblResult = ISNULL(dblRate, 1)
		FROM tblCTContractDetail
		WHERE intContractDetailId = @intContractDetailId
	ELSE
		SELECT TOP 1 @dblResult = ISNULL(CER.dblRate, 1)
		FROM tblCTContractDetail CD
		INNER JOIN vyuSMForex CER ON CER.intCurrencyExchangeRateId = CD.intCurrencyExchangeRateId
		WHERE CD.intContractDetailId = @intContractDetailId
		ORDER BY CER.dtmValidFromDate DESC
	
	RETURN @dblResult;
END
GO