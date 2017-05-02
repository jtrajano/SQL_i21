CREATE VIEW [dbo].[vyuCTCompanyPreference]
	
AS 

	SELECT	CP.*,

			U1.strUnitMeasure		AS	strCleanCostUOM,
			C1.strCurrency			AS	strCleanCostCurrency,
			CS.strContractStatus	AS	strDefContractStatus

	FROM	tblCTCompanyPreference	CP LEFT
	JOIN	tblICUnitMeasure		U1	ON	U1.intUnitMeasureId		=	CP.intCleanCostUOMId		LEFT
	JOIN	tblSMCurrency			C1	ON	C1.intCurrencyID		=	CP.intCleanCostCurrencyId	LEFT
	JOIN	tblCTContractStatus		CS	ON	CS.intContractStatusId	=	CP.intDefContractStatusId