CREATE VIEW [dbo].[vyuCTContractImport]
	
AS 

	SELECT	*,
			CASE WHEN strLotCalculationType = 'Floor' THEN FLOOR(dblCalcNoOfLots) ELSE CEILING(dblCalcNoOfLots) END dblNoOfLots,
			(SELECT strPricingType FROM tblCTPricingType WHERE intPricingTypeId = t.intPricingTypeId) AS strPricingType
	FROM
	(
		SELECT			CI.intContractImportId,
						CI.strContractType,
						CI.strEntityName,
						CI.strCommodity,
						CI.strSalesperson,
						CI.strCropYear,
						CI.strPosition,
						ISNULL(CI.strContractStatus,'Open') strContractStatus,
						CI.strLocationName,
						CI.strFutMarketName,
						CI.strCurrency,
						CI.strPriceUOM,
						CI.strErrorMsg,
						CI.ysnImported,

						intContractTypeId	=	CASE WHEN CI.strContractType = 'B' THEN 1 ELSE 2 END,
						intEntityId			=	EY.intEntityId,			
						dtmContractDate		=	CI.dtmStartDate,
						intCommodityId		=	CM.intCommodityId,		
						intCommodityUOMId	=	CU.intCommodityUnitMeasureId,
						intSalespersonId	=	SY.intEntityId,	
						ysnSigned			=	0,						
						strContractNumber	=	CI.strContractNumber,
						ysnPrinted			=	0,						
						intCropYearId		=	CP.intCropYearId,
						intPositionId		=	PN.intPositionId,
						strCommodityUOM		=	IU.strUnitMeasure, 
						dblCommodityUOMConversionFactor = 1,
						ysnExchangeTraded	=	CM.ysnExchangeTraded,
				  
						intItemId			=	IM.intItemId,			
						intItemUOMId		=	QU.intItemUOMId,
						intContractSeq		=	1,						
						intStorageScheduleRuleId	=	NULL,
						dtmEndDate			=	CI.dtmEndDate,			
						intCompanyLocationId=	CL.intCompanyLocationId, 
						dblQuantity			=	CI.dblQuantity,			
						intContractStatusId	=	1,
						dblBalance			=	CI.dblQuantity,			
						dtmStartDate		=	CI.dtmStartDate,
						intPriceItemUOMId	=	QU.intItemUOMId,		
						dtmCreated			=	GETDATE(),
						intConcurrencyId	=	1,						
						intFutureMarketId	=	MA.intFutureMarketId,	
						intFutureMonthId	=	MO.intFutureMonthId,
						dblFutures			=	CI.dblFutures,			
						dblBasis			=	CI.dblBasis,
						dblCashPrice		=	CI.dblCashPrice,		
						dblCalcNoOfLots		=	CI.dblQuantity / dbo.fnCTConvertQuantityToTargetItemUOM(IM.intItemId,MA.intUnitMeasureId,QU.intUnitMeasureId,MA.dblContractSize),
						strLotCalculationType = PR.strLotCalculationType,
						strRemark			=	CI.strRemark,
						intPricingTypeId	=	CASE	WHEN	MA.intFutureMarketId IS NOT NULL AND CI.dblCashPrice IS NOT NULL
																THEN	1
														WHEN	MA.intFutureMarketId IS NOT NULL AND CI.dblCashPrice IS NULL AND CI.dblFutures IS NOT NULL
																THEN	3
														WHEN	MA.intFutureMarketId IS NOT NULL AND CI.dblCashPrice IS NULL AND CI.dblBasis IS NOT NULL
																THEN	2
														WHEN	MA.intFutureMarketId IS NULL AND CI.dblCashPrice IS NOT NULL
																THEN	6
														ELSE	4
												END,
						dblTotalCost		=	CI.dblCashPrice * CI.dblQuantity,
						intCurrencyId		=	CY.intCurrencyID,
						strItemNo			=	IM.strItemNo,
						strUOM				=	IU.strUnitMeasure, 
						strFutureMonth		=	MO.strFutureMonth,
						dblConversionFactor	=	1,
						ysnItemUOMIdExist	=	CAST(1 AS BIT)
				FROM	tblCTContractImport			CI	CROSS
				APPLY	tblCTCompanyPreference		PR	LEFT
				JOIN	tblICItem					IM	ON	IM.strItemNo		=	CI.strItem				LEFT
				JOIN	tblICUnitMeasure			IU	ON	IU.strUnitMeasure	=	CI.strQuantityUOM		LEFT
				JOIN	tblICItemUOM				QU	ON	QU.intItemId		=	IM.intItemId		
														AND	QU.intUnitMeasureId	=	IU.intUnitMeasureId		LEFT
				JOIN	tblICCommodity				CM	ON	CM.strCommodityCode	=	CI.strCommodity			LEFT
				JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityId	=	CM.intCommodityId	 		
														AND	CU.intUnitMeasureId =	IU.intUnitMeasureId		LEFT
				JOIN	tblSMCurrency				CY	ON	CY.strCurrency		=	CI.strCurrency			LEFT
				JOIN	tblSMCompanyLocation		CL	ON	CL.strLocationName	=	CI.strLocationName		LEFT
				JOIN	tblCTCropYear				CP	ON	CP.strCropYear		=	CI.strCropYear			
														AND	CP.intCommodityId	=	CM.intCommodityId		LEFT
				JOIN	tblCTPosition				PN	ON	PN.strPosition		=	CI.strPosition			LEFT
				JOIN	tblRKFutureMarket			MA	ON	MA.strFutMarketName	=	CI.strFutMarketName		LEFT
				JOIN	tblRKFuturesMonth			MO	ON	MO.intFutureMarketId=	MA.intFutureMarketId
														AND	MONTH(MO.dtmFutureMonthsDate) = CI.intMonth
														AND	YEAR(MO.dtmFutureMonthsDate) = CI.intYear		LEFT
				JOIN	(
							SELECT	E.intEntityId,E.strName
							FROM	tblEMEntity			E
							JOIN	tblEMEntityLocation	L	ON	E.intEntityId	=	L.intEntityId			
						)EY	ON	EY.strName			=	CI.strEntityName									LEFT
				JOIN	(
							SELECT	E.intEntityId,E.strName
							FROM	tblEMEntity			E
							JOIN	tblEMEntityLocation	L	ON	E.intEntityId	=	L.intEntityId			
						)SY	ON	SY.strName			=	CI.strSalesperson
		)t
