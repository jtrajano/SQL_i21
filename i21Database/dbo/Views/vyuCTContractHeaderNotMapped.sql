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
						CY.ysnExchangeTraded,
						EY.strName					AS	strEntityName,
						PO.strPosition,
						W1.strWeightGradeDesc		AS	strGrade,
						W2.strWeightGradeDesc		AS	strWeight,
						TM.strTerm,
						CB.strINCOLocationType,
						U2.strUnitMeasure			AS	strCommodityUOM

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
				JOIN	tblICUnitMeasure			U2	ON	U2.intUnitMeasureId			=	CM.intUnitMeasureId	
			)t