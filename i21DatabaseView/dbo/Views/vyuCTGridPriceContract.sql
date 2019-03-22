CREATE VIEW [dbo].[vyuCTGridPriceContract]

AS

	SELECT	 PC.*
			,UM.strUnitMeasure	AS	strFinalPriceUOM
			,CY.strCurrency		AS	strFinalCurrency
			,CY.ysnSubCurrency
			,MY.strCurrency		AS	strMainCurrency

	FROM			tblCTPriceContract			PC
			JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	PC.intFinalPriceUOMId
			JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
	LEFT	JOIN	tblSMCurrency				CY	ON	CY.intCurrencyID				=	PC.intFinalCurrencyId
	LEFT	JOIN	tblSMCurrency				MY	ON	MY.intCurrencyID				=	CY.intMainCurrencyId
