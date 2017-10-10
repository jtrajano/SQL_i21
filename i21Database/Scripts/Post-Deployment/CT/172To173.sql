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

	UPDATE	CD 
	SET		CD.dblConvertedBasis = dbo.fnCTConvertQtyToTargetItemUOM(CD.intPriceItemUOMId,CD.intBasisUOMId,CD.dblBasis) / 
			CASE	WHEN	CD.intCurrencyId = CD.intBasisCurrencyId THEN 1 
					WHEN	ISNULL(CY.ysnSubCurrency,0) = 1 THEN 0.01 
					ELSE	100
			END
	FROM	tblCTContractDetail CD
	JOIN	tblSMCurrency		CY	ON	CD.intCurrencyId	=	CY.intCurrencyID
	WHERE	CD.dblBasis IS NOT NULL AND CD.dblConvertedBasis IS NULL
GO

PRINT('CT - 172To173 End')