CREATE VIEW [dbo].[vyuCTCompanyPreference]
	
AS 

	SELECT	CP.intCompanyPreferenceId,
			CP.ysnAssignSaleContract,
			CP.ysnAssignPurchaseContract,
			CP.ysnRequireDPContract,
			CP.ysnApplyScaleToBasis,
			CP.intPriceCalculationTypeId,
			CP.intConcurrencyId,
			CP.strLotCalculationType,
			CP.ysnPartialPricing,
			CP.ysnPolarization,
			CP.strPricingQuantity,
			CP.intCleanCostCurrencyId,
			CP.intCleanCostUOMId,
			CP.strDefaultContractReport,
			CP.ysnDemandViewForBlend,
			CP.intEarlyDaysPurchase,
			CP.intEarlyDaysSales,
			CP.strDemandItemType,
			CP.ysnBagMarkMandatory,
			CP.strESA,
			CP.ysnAutoCreateDP,
			CP.intDefSalespersonId,
			CP.dtmDefEndDate,
			CP.strSignature,
			CP.strDefPackingDescription,
			CP.intDefContractStatusId,
			CP.ysnBasisComponent,

			U1.strUnitMeasure		AS	strCleanCostUOM,
			C1.strCurrency			AS	strCleanCostCurrency,
			CS.strContractStatus	AS	strDefContractStatus

	FROM	tblCTCompanyPreference	CP LEFT
	JOIN	tblICUnitMeasure		U1	ON	U1.intConcurrencyId		=	CP.intCleanCostUOMId		LEFT
	JOIN	tblSMCurrency			C1	ON	C1.intCurrencyID		=	CP.intCleanCostCurrencyId	LEFT
	JOIN	tblCTContractStatus		CS	ON	CS.intContractStatusId	=	CP.intDefContractStatusId