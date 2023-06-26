CREATE FUNCTION [dbo].[fnCTGetContractCostTransactionForexRate]
(
	@intContractCostId	INT
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	DECLARE	@dblResult NUMERIC(18,6)
            ,@intTransactionForexId INT
            ,@intCostCurrencyId INT
            ,@intDefaultCurrencyId INT

    SELECT
        @intTransactionForexId = CH.intTransactionForexId
        ,@intCostCurrencyId = CC.intCurrencyId
        ,@intDefaultCurrencyId = DC.intDefaultCurrencyId
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
    INNER JOIN tblCTContractCost CC ON CC.intContractDetailId = CD.intContractDetailId
    OUTER APPLY (SELECT TOP 1 intDefaultCurrencyId FROM tblSMCompanyPreference) DC
	WHERE CC.intContractCostId = @intContractCostId

	
    IF @intCostCurrencyId = @intDefaultCurrencyId
        SELECT @dblResult = 1
    ELSE IF @intTransactionForexId = 1 -- Contract
		SELECT @dblResult = ISNULL(dblFX, 1)
		FROM tblCTContractCost
		WHERE intContractCostId = @intContractCostId
	ELSE    
		SELECT TOP 1 @dblResult = ISNULL(CER.dblRate, 1)
		FROM tblCTContractCost CC
		INNER JOIN vyuSMForex CER
            ON CER.intCurrencyExchangeRateTypeId = CC.intRateTypeId
            AND CER.intFromCurrencyId = CC.intCurrencyId
            AND CER.intToCurrencyId = @intDefaultCurrencyId
		WHERE CC.intContractCostId = @intContractCostId
		ORDER BY CER.dtmValidFromDate DESC
	
	RETURN @dblResult;
END
GO