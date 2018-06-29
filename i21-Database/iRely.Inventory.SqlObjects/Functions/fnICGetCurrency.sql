CREATE FUNCTION [dbo].[fnICGetCurrency] (@contractDetailId INT, @ysnSubCurrency BIT)
RETURNS INT
AS
BEGIN
	DECLARE @defaultCurrency INT = NULL

	SELECT	@defaultCurrency = 
				CASE 
					WHEN ContractDetail.ysnUseFXPrice = 1 THEN 
						ContractDetail.intSeqCurrencyId			
					ELSE 
						ISNULL(
							CASE 
								WHEN @ysnSubCurrency = 1 THEN 
									ISNULL(ContractDetail.intCurrencyId, ContractDetail.intMainCurrencyId)
								ELSE 
									ISNULL(ContractDetail.intMainCurrencyId, ContractDetail.intCurrencyId)
							END 
							, dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
						)
				END
	FROM	vyuCTContractDetailView ContractDetail 
	WHERE	ContractDetail.intContractDetailId = @contractDetailId
	
	RETURN @defaultCurrency
END