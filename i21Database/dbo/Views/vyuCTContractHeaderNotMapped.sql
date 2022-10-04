﻿
Create VIEW [dbo].[vyuCTContractHeaderNotMapped]
	
AS 

	SELECT	*,
			CAST(CASE WHEN ISNULL(strPrepaidIds,'') = '' THEN 0 ELSE 1 END AS BIT) ysnPrepaid,
			CAST(CASE WHEN ISNULL(strProvisionalVoucherIds,'') = '' THEN 0 ELSE 1 END AS BIT) ysnProvisionalVoucher
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
						dbo.fnCTGetPrepaidIds(CH.intContractHeaderId)  COLLATE Latin1_General_CI_AS AS strPrepaidIds,
						dbo.fnCTGetProvisionalIds(CH.intContractHeaderId)  COLLATE Latin1_General_CI_AS AS strProvisionalVoucherIds,
						
						EY.strName					AS	strEntityName,
						SP.strName					AS	strSalesperson,
						CN.strName					AS	strContact,
						PR.strName					AS	strProducer,
						CU.strName					AS	strCounterParty,

						AN.strName					AS	strAssociationName,
					    --CB.strContractBasis,        
					    --CB.strDescription   AS strContractBasisDescription,    
					    --CB.strINCOLocationType,  
					    FT.strFreightTerm AS strContractBasis,        
					    FT.strDescription   AS strContractBasisDescription,    
					    FT.strINCOLocationType, 					
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
						ISNULL(TM.intBalanceDue, 0) intBalanceDue,
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
						AB.strCity					AS	strArbitration,
						MA.strFutMarketName			AS	strFutureMarket,
						REPLACE(MO.strFutureMonth,' ','('+MO.strSymbol+') ') strFutureMonthYear,
						U6.strUnitMeasure			AS	strMarketUnitMeasure,
						MA.dblContractSize			AS	dblMarketContractSize,
						MA.intCurrencyId			AS	intMarketCurrencyId,
						CR.strCurrency				AS	strMarketCurrency,
						CR.ysnSubCurrency			AS	ysnMarketSubCurrency,
						CR.intCent					AS	intMarketCent,
						CA.strCommodityAttributeId,
						EL.intEntityLocationId		AS	intEntityDefaultLocationId,
						EL.strLocationName			AS	strEntityDefaultLocation,
						PO.intNoOfDays				AS	intPositionNoOfDays,
						BK.strBook,
						SB.strSubBook,
						MR.strCurrency				AS	strMarketMainCurrency,
						FT.intFreightTermId,
						FT.strFreightTerm,
						BE.strName					AS strBroker,
						BA.strAccountNumber			AS strBrokerAccount,
						intCommodityFutureMarketId = CY.intFutureMarketId, -- CT-5315
						strEntitySelectedLocation = ESL.strLocationName, -- CT-5315
						COL.strLocationName,
						ST.strSampleTypeName,
						CY.ysnCheckMissingStandardPriceInContract,
						dblHeaderBalance = cd.dblHeaderBalance,
						dblHeaderAvailable = cd.dblHeaderAvailable,
						strHeaderProductType = HPT.strDescription,
						strApprovalStatus = app.strApprovalStatus,
						strShipVia = SV.strName
				FROM	tblCTContractHeader						CH	
				
				JOIN	tblEMEntity								EY	ON	EY.intEntityId						=		CH.intEntityId
				cross apply (
					select
					dblHeaderBalance = CH.dblQuantity - sum(cd.dblQuantity - cd.dblBalance)
					,dblHeaderAvailable = CH.dblQuantity - (sum(cd.dblQuantity - cd.dblBalance) + sum(isnull(cd.dblScheduleQty,0)))
					from tblCTContractDetail cd
					where cd.intContractHeaderId = CH.intContractHeaderId
				) cd
			LEFT	JOIN	tblEMEntity							SP	ON	SP.intEntityId						=		CH.intSalespersonId									
			LEFT	JOIN	tblEMEntity							SV	ON	SV.intEntityId						=		CH.intShipViaId									
			LEFT	JOIN	tblEMEntity							CN	ON	CN.intEntityId						=		CH.intEntityContactId				
			LEFT	JOIN	tblEMEntity							PR	ON	PR.intEntityId						=		CH.intProducerId					
			LEFT	JOIN	tblEMEntity							CU	ON	CU.intEntityId						=		CH.intCounterPartyId				
			LEFT	JOIN	tblEMEntityLocation					EL	ON	EL.intEntityId						=		CH.intEntityId 
																	AND EL.ysnDefaultLocation				=		1
			
			LEFT	JOIN	tblICCommodity						CY	ON	CY.intCommodityId					=		CH.intCommodityId					
			LEFT	JOIN	tblCTPosition						PO	ON	PO.intPositionId					=		CH.intPositionId						
			LEFT	JOIN	tblCTWeightGrade					W1	ON	W1.intWeightGradeId					=		CH.intGradeId						
			LEFT	JOIN	tblCTWeightGrade					W2	ON	W2.intWeightGradeId					=		CH.intWeightId						
			LEFT	JOIN	tblSMTerm							TM	ON	TM.intTermID						=		CH.intTermId						
			-- LEFT	JOIN	tblCTContractBasis					CB	ON	CB.intContractBasisId				=		CH.intContractBasisId				
			LEFT	JOIN	tblCTContractType					TP	ON	TP.intContractTypeId				=		CH.intContractTypeId				
			LEFT	JOIN	tblCTAssociation					AN	ON	AN.intAssociationId					=		CH.intAssociationId					
			LEFT	JOIN	tblCTContractText					TX	ON	TX.intContractTextId				=		CH.intContractTextId										
			LEFT	JOIN	tblCTInsuranceBy					IB	ON	IB.intInsuranceById					=		CH.intInsuranceById					
			LEFT	JOIN	tblCTInvoiceType					IT	ON	IT.intInvoiceTypeId					=		CH.intInvoiceTypeId					
			LEFT	JOIN	tblSMCountry						CO	ON	CO.intCountryID						=		CH.intCountryId						
			LEFT	JOIN	tblSMCity							CT	ON	CT.intCityId						=		CH.intINCOLocationTypeId			
			LEFT	JOIN	tblSMCity							AB	ON	AB.intCityId						=		CH.intArbitrationId					
			LEFT	JOIN	tblCTPricingType					PT	ON	PT.intPricingTypeId					=		CH.intPricingTypeId					
			LEFT	JOIN	tblRKFutureMarket					MA	ON	MA.intFutureMarketId				=		CH.intFutureMarketId				
			LEFT	JOIN	tblRKFuturesMonth					MO	ON	MO.intFutureMonthId					=		CH.intFutureMonthId					
			LEFT	JOIN	tblRKCommodityMarketMapping			CA	ON	CA.intFutureMarketId				=		CH.intFutureMarketId				
																AND	CA.intCommodityId						=		CH.intCommodityId					
			
			LEFT	JOIN	tblICCommodityUnitMeasure			CM	ON	CM.intCommodityUnitMeasureId		=		CH.intCommodityUOMId				
			LEFT	JOIN	tblICCommodityUnitMeasure			CL	ON	CL.intCommodityUnitMeasureId		=		CH.intLoadUOMId						
			LEFT	JOIN	tblICUnitMeasure					U2	ON	U2.intUnitMeasureId					=		CM.intUnitMeasureId					
			LEFT	JOIN	tblICUnitMeasure					U3	ON	U3.intUnitMeasureId					=		CL.intUnitMeasureId					
			LEFT	JOIN	tblICUnitMeasure					U4	ON	U4.intUnitMeasureId					=		CH.intCategoryUnitMeasureId			
			LEFT	JOIN	tblICUnitMeasure					U5	ON	U5.intUnitMeasureId					=		CH.intLoadCategoryUnitMeasureId		
			LEFT	JOIN	tblICUnitMeasure					U6	ON	U6.intUnitMeasureId					=		MA.intUnitMeasureId					
				
			LEFT	JOIN	tblSMCurrency						CR	ON	CR.intCurrencyID					=		MA.intCurrencyId					
			LEFT	JOIN	tblSMCurrency						MR	ON	MR.intCurrencyID					=		CR.intMainCurrencyId				
			LEFT	JOIN	tblSMCompanyLocationPricingLevel	PL	ON	PL.intCompanyLocationPricingLevelId	=		CH.intCompanyLocationPricingLevelId 
			LEFT	JOIN	tblSMCompanyLocationSubLocation		SL	ON	SL.intCompanyLocationSubLocationId	=		CH.intWarehouseId					
			LEFT	JOIN	tblCTContractPlan					CP	ON	CP.intContractPlanId				=		CH.intContractPlanId				
			LEFT	JOIN	tblCTCropYear						YR	ON	YR.intCropYearId					=		CH.intCropYearId					
				
			LEFT	JOIN	tblCTBook							BK	ON	BK.intBookId						=		CH.intBookId						
			LEFT	JOIN	tblCTSubBook						SB	ON	SB.intSubBookId						=		CH.intSubBookId						
			LEFT	JOIN	tblICCommodityAttribute				HPT ON HPT.intCommodityAttributeId			=		CH.intProductTypeId
						
			OUTER APPLY (
			SELECT TOP 1 PF.intPriceFixationId, 
						PF.intPriceContractId
						FROM tblCTPriceFixation PF
						WHERE  CH.intContractHeaderId =	PF.intContractHeaderId  AND CH.ysnMultiplePriceFixation	= 1	
			) PF				
			LEFT	JOIN	tblSMFreightTerms					FT	ON	FT.intFreightTermId					=		CH.intFreightTermId					
			LEFT	JOIN	tblEMEntity							BE	ON	BE.intEntityId						=		CH.intBrokerId										
			LEFT	JOIN	tblRKBrokerageAccount				BA	ON	BA.intBrokerageAccountId			=		CH.intBrokerageAccountId							
			LEFT	JOIN	tblEMEntityLocation					ESL	ON	ESL.intEntityLocationId				=		CH.intEntitySelectedLocationId  -- CT-5315
			LEFT JOIN tblSMCompanyLocation COL on COL.intCompanyLocationId = CH.intCompanyLocationId
			LEFT JOIN tblQMSampleType ST on ST.intSampleTypeId = CH.intSampleTypeId

			Outer Apply(
				select tr.intRecordId, 
					   strApprovalStatus =	CASE WHEN tr.strApprovalStatus in ('Waiting for Submit','Waiting for Approval','Approved') THEN  
												CASE WHEN tr.strApprovalStatus = 'Approved with Modifications' then 'Approved' ELSE tr.strApprovalStatus END
											ELSE '' END
				from
					tblSMScreen sc
					join tblSMTransaction tr on tr.intScreenId = sc.intScreenId
				where
					sc.strModule = 'Contract Management'
					and sc.strNamespace in ('ContractManagement.view.Contract','ContractManagement.view.Amendments')
					and tr.intRecordId = CH.intContractHeaderId
			) app

			)t
			
GO



