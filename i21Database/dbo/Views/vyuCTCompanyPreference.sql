CREATE VIEW [dbo].[vyuCTCompanyPreference]
	
AS 

	SELECT	CP.*,

			U1.strUnitMeasure		AS	strCleanCostUOM,
			C1.strCurrency			AS	strCleanCostCurrency,
			CS.strContractStatus	AS	strDefContractStatus,
			CT.strContainerType		AS	strDefContainerType,
			EY.strName				AS	strDefSalesperson,
			VI.strItemNo			AS	strVoucherItem,
			II.strItemNo			AS	strInvoiceItem,
			PC.strPriceCalculationType,
			SR.strScheduleDescription	AS	strDefStorageSchedule

	FROM	tblCTCompanyPreference		CP LEFT
	JOIN	tblICUnitMeasure			U1	ON	U1.intUnitMeasureId			=	CP.intCleanCostUOMId		LEFT
	JOIN	tblSMCurrency				C1	ON	C1.intCurrencyID			=	CP.intCleanCostCurrencyId	LEFT
	JOIN	tblCTContractStatus			CS	ON	CS.intContractStatusId		=	CP.intDefContractStatusId	LEFT
	JOIN	tblLGContainerType			CT	ON	CT.intContainerTypeId		=	CP.intDefContainerTypeId	LEFT
	JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CP.intDefSalespersonId		LEFT
	JOIN	tblICItem					VI	ON	VI.intItemId				=	CP.intVoucherItemId			LEFT
	JOIN	tblICItem					II	ON	II.intItemId				=	CP.intInvoiceItemId			LEFT
	JOIN	tblCTPriceCalculationType	PC	ON	PC.intPriceCalculationTypeId=	CP.intPriceCalculationTypeId	LEFT    
	JOIN	tblGRStorageScheduleRule	SR	ON	SR.intStorageScheduleRuleId	=	CP.intDefStorageSchedule

