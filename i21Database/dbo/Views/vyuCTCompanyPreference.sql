CREATE VIEW [dbo].[vyuCTCompanyPreference]
	
AS 

	SELECT	CP.*,

			U1.strUnitMeasure		AS	strCleanCostUOM,
			C1.strCurrency			AS	strCleanCostCurrency,
			CS.strContractStatus	AS	strDefContractStatus,
			CT.strContainerType		AS	strDefContainerType,
			EY.strName				AS	strDefSalesperson,
			PC.strPriceCalculationType

	FROM	tblCTCompanyPreference		CP LEFT
	JOIN	tblICUnitMeasure			U1	ON	U1.intUnitMeasureId			=	CP.intCleanCostUOMId		LEFT
	JOIN	tblSMCurrency				C1	ON	C1.intCurrencyID			=	CP.intCleanCostCurrencyId	LEFT
	JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CP.intDefContractStatusId	LEFT
	JOIN	tblLGContainerType			CT	ON	CT.intContainerTypeId		=	CP.intDefContainerTypeId	LEFT
	JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CP.intDefSalespersonId		LEFT
	JOIN	tblCTPriceCalculationType	PC	ON	PC.intPriceCalculationTypeId=	CP.intPriceCalculationTypeId
