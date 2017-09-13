PRINT('CT - 172To173 Started')

GO
	UPDATE tblCTWeightGrade SET strWhereFinalized = CASE WHEN strWhereFinalized = '1' THEN 'Origin' ELSE 'Destination' END WHERE strWhereFinalized IN ('1','2')
GO

GO
	UPDATE tblCTContractDetail SET intBasisCurrencyId =  intCurrencyId   WHERE intPricingTypeId IN (1,2,3) AND intBasisCurrencyId IS NULL
	UPDATE tblCTContractDetail SET intBasisUOMId =  intPriceItemUOMId   WHERE intPricingTypeId IN (1,2,3) AND intBasisUOMId IS NULL

	UPDATE	PC 
	SET		PC.intFinalCurrencyId	=	CD.intCurrencyId
	FROM	tblCTPriceContract		PC
	JOIN	tblCTPriceFixation		PF	ON	PF.intPriceContractId	=	PC.intPriceContractId
	JOIN	tblCTContractDetail		CD	ON	CD.intContractHeaderId	=	PF.intContractHeaderId
	WHERE	PC.intFinalCurrencyId	IS	NULL
GO

PRINT('CT - 172To173 End')