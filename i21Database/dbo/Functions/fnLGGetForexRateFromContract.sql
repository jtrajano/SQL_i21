CREATE FUNCTION [dbo].[fnLGGetForexRateFromContract]
(
	@intContractDetailId	INT
)
RETURNS NUMERIC(18,6)
AS 
BEGIN 
	/** This function fetches the FX rate for the conversion of the Contract Currency to Functional Currency based
	on the Contract's Transaction Forex  Rate setting. **/
	
	DECLARE	@dblResult NUMERIC(18,6)
			,@intTransactionForexId INT
			,@intContractCurrencyId INT
			,@intContractInvCurrencyId INT
			,@DefaultCurrencyId INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
			,@dblCtTransactionForexRate NUMERIC(18,6)

	SELECT 
		@intTransactionForexId = CH.intTransactionForexId,
		@intContractCurrencyId = ISNULL(SC.intMainCurrencyId, SC.intCurrencyID),
		@intContractInvCurrencyId = CD.intInvoiceCurrencyId
	FROM tblCTContractHeader CH
	INNER JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
	WHERE CD.intContractDetailId = @intContractDetailId

	SELECT @dblCtTransactionForexRate = dbo.fnCTGetTransactionForexRate(@intContractDetailId)

	SELECT 
		@dblResult = CASE
			WHEN (CD.dblHistoricalRate IS NOT NULL AND @intTransactionForexId = 1)
				THEN CD.dblHistoricalRate -- If Historical Rate is Present
			WHEN AD.ysnValidFX = 1 THEN -- Contract Seq Fx tab is set
				CASE WHEN (@intContractInvCurrencyId <> @DefaultCurrencyId) THEN
					CASE 
						WHEN (@intContractCurrencyId = @DefaultCurrencyId) THEN dbo.fnDivide(1, @dblCtTransactionForexRate) -- Functional to Foreign Currency
						WHEN (@intContractCurrencyId <> @DefaultCurrencyId) THEN ISNULL(FX.dblFXRate, 1) -- Foreign to Foreign Currency
					END
				ELSE 1 END -- Foreign Currency to Functional Currency
			ELSE 
			CASE WHEN (@DefaultCurrencyId <> @intContractCurrencyId) 
				THEN ISNULL(FX.dblFXRate, 1)
				ELSE 1 
			END
		END
	FROM tblCTContractDetail CD
	CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
	LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = CD.intCurrencyId
	OUTER APPLY (SELECT	TOP 1  
				intForexRateTypeId = RD.intRateTypeId
				,dblFXRate = CASE WHEN ER.intFromCurrencyId = @DefaultCurrencyId  
							THEN 1/RD.[dblRate] 
							ELSE RD.[dblRate] END 
				FROM tblSMCurrencyExchangeRate ER
				JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = ER.intCurrencyExchangeRateId
				WHERE @DefaultCurrencyId <> @intContractCurrencyId
					AND ((ER.intFromCurrencyId = @intContractInvCurrencyId AND ER.intToCurrencyId = @DefaultCurrencyId) 
						OR (ER.intFromCurrencyId = @DefaultCurrencyId AND ER.intToCurrencyId = @intContractInvCurrencyId))
				ORDER BY RD.dtmValidFromDate DESC) FX
	WHERE CD.intContractDetailId = @intContractDetailId

	RETURN @dblResult
END
GO