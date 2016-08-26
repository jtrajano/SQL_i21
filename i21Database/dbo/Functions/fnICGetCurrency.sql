CREATE FUNCTION [dbo].[fnICGetCurrency] (@contractDetailId INT, @ysnSubCurrency BIT)
RETURNS INT
AS
BEGIN
	DECLARE @defaultCurrency INT = NULL

	IF @ysnSubCurrency=1
		BEGIN
			SELECT @defaultCurrency = 
					CASE 
						WHEN ContractDetail.ysnUseFXPrice = 1
						THEN ContractDetail.intSeqCurrencyId			
						ELSE ISNULL(ISNULL(ContractDetail.intCurrencyId, ContractDetail.intMainCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL'))
					END
			FROM vyuCTContractDetailView ContractDetail 
			WHERE ContractDetail.intContractDetailId = @contractDetailId
		END
	ELSE
		BEGIN
			SELECT @defaultCurrency = 
					CASE 
						WHEN ContractDetail.ysnUseFXPrice = 1
						THEN ContractDetail.intSeqCurrencyId			
						ELSE ISNULL(ISNULL(ContractDetail.intMainCurrencyId, ContractDetail.intCurrencyId), dbo.fnSMGetDefaultCurrency('FUNCTIONAL'))
					END
			FROM vyuCTContractDetailView ContractDetail 
			WHERE ContractDetail.intContractDetailId = @contractDetailId
		END

	
	RETURN @defaultCurrency
END