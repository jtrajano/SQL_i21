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
						dbo.fnCTGetPrepaidIds(CH.intContractHeaderId) COLLATE Latin1_General_CI_AS AS strPrepaidIds,
						CY.ysnExchangeTraded,
						EY.strName					AS	strEntityName,
						PO.strPosition,
						W1.strWeightGradeDesc		AS	strGrade,
						W2.strWeightGradeDesc		AS	strWeight,
						TM.strTerm,
						CB.strINCOLocationType,
						U2.strUnitMeasure			AS	strCommodityUOM,
						CB.strContractBasis,
						CM.intUnitMeasureId,
						SP.strName					AS	strSalesperson,
						TX.strTextCode,

						AB.strCity					AS	strArbitration,
						IB.strDescription			AS	strInsuranceBy,	
						IT.strDescription			AS	strInvoiceType,	
						AN.strName					AS	strAssociationName,
						PR.strName					AS	strProducer,
						CO.strCountry,		
						CT.strCity					AS	strINCOLocation

				FROM	tblCTContractHeader			CH	
				JOIN	tblEMEntity					EY	ON	EY.intEntityId				=	CH.intEntityId			LEFT
				JOIN	tblICCommodity				CY	ON	CY.intCommodityId			=	CH.intCommodityId		LEFT
				JOIN	tblCTPriceFixation			PF	ON	CH.intContractHeaderId		=	PF.intContractHeaderId 
														AND CH.ysnMultiplePriceFixation = 1							LEFT
				JOIN	tblCTPosition				PO	ON	PO.intPositionId			=	CH.intPositionId		LEFT	
				JOIN	tblCTWeightGrade			W1	ON	W1.intWeightGradeId			=	CH.intGradeId			LEFT
				JOIN	tblCTWeightGrade			W2	ON	W2.intWeightGradeId			=	CH.intWeightId			LEFT
				JOIN	tblSMTerm					TM	ON	TM.intTermID				=	CH.intTermId			LEFT
				JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId		=	CH.intContractBasisId	LEFT
				JOIN	tblICCommodityUnitMeasure	CM	ON	CM.intCommodityUnitMeasureId=	CH.intCommodityUOMId	LEFT	
				JOIN	tblICUnitMeasure			U2	ON	U2.intUnitMeasureId			=	CM.intUnitMeasureId		LEFT	
				JOIN	tblEMEntity					SP	ON	SP.intEntityId				=	CH.intSalespersonId		LEFT	
				JOIN	tblCTContractText			TX	ON	TX.intContractTextId		=	CH.intContractTextId	LEFT
				JOIN	tblSMCountry				CO	ON	CO.intCountryID				=	CH.intCountryId			LEFT
				JOIN	tblSMCity					CT	ON	CT.intCityId				=	CH.intINCOLocationTypeId	LEFT
				JOIN	tblSMCity					AB	ON	AB.intCityId				=	CH.intArbitrationId		LEFT
				JOIN	tblCTInsuranceBy			IB	ON	IB.intInsuranceById			=	CH.intInsuranceById		LEFT
				JOIN	tblCTInvoiceType			IT	ON	IT.intInvoiceTypeId			=	CH.intInvoiceTypeId		LEFT
				JOIN	tblCTAssociation			AN	ON	AN.intAssociationId			=	CH.intAssociationId		LEFT
				JOIN	tblEMEntity					PR	ON	PR.intEntityId				=	CH.intProducerId		
			)t