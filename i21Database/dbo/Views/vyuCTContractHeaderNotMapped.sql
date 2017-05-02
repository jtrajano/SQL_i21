CREATE VIEW [dbo].[vyuCTContractHeaderNotMapped]
	
AS 

	SELECT	*,
			CAST(CASE WHEN ISNULL(strPrepaidIds,'') = '' THEN 0 ELSE 1 END AS BIT) ysnPrepaid
	FROM	(
				SELECT	CH.intContractHeaderId,
						PF.intPriceFixationId, 
						PF.intPriceContractId,
						CASE	WHEN	(	
											SELECT	COUNT(SA.intSpreadArbitrageId) 
											FROM	tblCTSpreadArbitrage SA  
											WHERE	SA.intPriceFixationId = PF.intPriceFixationId
										) > 0
								THEN	CAST(1 AS BIT) 
								ELSE	CAST(0 AS BIT)
						END		AS		ysnSpreadAvailable,

						dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intLoadUOMId,CH.intCommodityUOMId,1)	AS	dblCommodityUOMConversionFactor,
						dbo.fnCTGetPrepaidIds(CH.intContractHeaderId) strPrepaidIds,
						
						EY.strName					AS	strEntityName,
						SP.strName					AS	strSalesperson,
						CN.strName					AS	strContact,
						PR.strName					AS	strProducer,
						CU.strName					AS	strCounterParty,

						AN.strName					AS	strAssociationName,
						CB.strContractBasis,						
						CB.strDescription			AS	strContractBasisDescription,		
						CB.strINCOLocationType,						
						CM.intUnitMeasureId,						
						CO.strCountry,						
						CP.strContractPlan,						
						CY.strCommodityCode,						
						CY.strDescription			AS	strCommodityDescription,		
						CY.ysnExchangeTraded,												
						IB.strDescription			AS	strInsuranceByDescription,		
						IB.strInsuranceBy,						
						IT.strDescription			AS	strInvoiceTypeDescription,		
						IT.strInvoiceType,						
						PL.strPricingLevelName,						
						PO.strPosition,						
						PT.strPricingType,						
						TM.strTerm,						
						TM.strTermCode,						
						TP.strContractType,						
						TX.strTextCode,						
						U2.strUnitMeasure			AS	strCommodityUOM,		
						U3.strUnitMeasure			AS	strLoadUnitMeasure,		
						U4.strUnitMeasure			AS	strCategoryUnitMeasure,		
						U5.strUnitMeasure			AS	strLoadCategoryUnitMeasure,		
						W1.strWeightGradeDesc		AS	strGrade,			
						W2.strWeightGradeDesc		AS	strWeight,			
						YR.strCropYear,					
						SL.strSubLocationName,
						CT.strCity					AS	strINCOLocation,
						AB.strCity					AS	strArbitration

				FROM	tblCTContractHeader					CH	
				
				JOIN	tblEMEntity							EY	ON	EY.intEntityId						=		CH.intEntityId						LEFT
				JOIN	tblEMEntity							SP	ON	SP.intEntityId						=		CH.intSalespersonId					LEFT				
				JOIN	tblEMEntity							CN	ON	CN.intEntityId						=		CH.intEntityContactId				LEFT
				JOIN	tblEMEntity							PR	ON	PR.intEntityId						=		CH.intProducerId					LEFT
				JOIN	tblEMEntity							CU	ON	CU.intEntityId						=		CH.intCounterPartyId				LEFT
				
				JOIN	tblICCommodity						CY	ON	CY.intCommodityId					=		CH.intCommodityId					LEFT
				JOIN	tblCTPosition						PO	ON	PO.intPositionId					=		CH.intPositionId					LEFT	
				JOIN	tblCTWeightGrade					W1	ON	W1.intWeightGradeId					=		CH.intGradeId						LEFT
				JOIN	tblCTWeightGrade					W2	ON	W2.intWeightGradeId					=		CH.intWeightId						LEFT
				JOIN	tblSMTerm							TM	ON	TM.intTermID						=		CH.intTermId						LEFT
				JOIN	tblCTContractBasis					CB	ON	CB.intContractBasisId				=		CH.intContractBasisId				LEFT
				JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId				LEFT
				JOIN	tblCTAssociation					AN	ON	AN.intAssociationId					=		CH.intAssociationId					LEFT
				JOIN	tblCTContractText					TX	ON	TX.intContractTextId				=		CH.intContractTextId				LEFT
			  --JOIN	tblCTApprovalBasis					AB	ON	AB.intApprovalBasisId				=		CH.intApprovalBasisId				LEFT
				JOIN	tblCTInsuranceBy					IB	ON	IB.intInsuranceById					=		CH.intInsuranceById					LEFT
				JOIN	tblCTInvoiceType					IT	ON	IT.intInvoiceTypeId					=		CH.intInvoiceTypeId					LEFT
				JOIN	tblSMCountry						CO	ON	CO.intCountryID						=		CH.intCountryId						LEFT
				JOIN	tblSMCity							CT	ON	CT.intCityId						=		CH.intINCOLocationTypeId			LEFT
				JOIN	tblSMCity							AB	ON	AB.intCityId						=		CH.intArbitrationId					LEFT
				JOIN	tblCTPricingType					PT	ON	PT.intPricingTypeId					=		CH.intPricingTypeId					LEFT
				
				JOIN	tblICCommodityUnitMeasure			CM	ON	CM.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				LEFT
				JOIN	tblICCommodityUnitMeasure			CL	ON	CL.intCommodityUnitMeasureId		=		CH.intLoadUOMId						LEFT
				JOIN	tblICUnitMeasure					U2	ON	U2.intUnitMeasureId					=		CM.intUnitMeasureId					LEFT
				JOIN	tblICUnitMeasure					U3	ON	U3.intUnitMeasureId					=		CL.intUnitMeasureId					LEFT
				JOIN	tblICUnitMeasure					U4	ON	U4.intUnitMeasureId					=		CH.intCategoryUnitMeasureId			LEFT
				JOIN	tblICUnitMeasure					U5	ON	U5.intUnitMeasureId					=		CH.intLoadCategoryUnitMeasureId		LEFT
				
				JOIN	tblSMCompanyLocationPricingLevel	PL	ON	PL.intCompanyLocationPricingLevelId	=		CH.intCompanyLocationPricingLevelId LEFT
				JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intINCOLocationTypeId			LEFT
				JOIN	tblCTContractPlan					CP	ON	CP.intContractPlanId				=		CH.intContractPlanId				LEFT
				JOIN	tblCTCropYear						YR	ON	YR.intCropYearId					=		CH.intCropYearId					LEFT
				JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId				=		CH.intFutureMarketId				LEFT
				JOIN	tblRKFuturesMonth					MO	ON	MO.intFutureMonthId					=		CH.intFutureMonthId					LEFT

				JOIN	tblCTPriceFixation					PF	ON	CH.intContractHeaderId				=		PF.intContractHeaderId 
																AND CH.ysnMultiplePriceFixation			=		1							
			)t
