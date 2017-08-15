CREATE VIEW [dbo].[vyuCTNotificationHeader]
AS

		SELECT	CH.intContractHeaderId,	CH.dtmContractDate,		CT.strContractType,		CO.strCommodityCode,	CH.strContractNumber,
				CB.strContractBasis,	PO.strPosition,			CR.strCountry,			CH.strCustomerContract,	CH.dblQuantity			AS	dblHdrQuantity,	
				CH.intCommodityId,	
				PT.strPricingType		AS	strHdrPricingType,	
				UM.strUnitMeasure		AS	strHdrUOM,	
				EY.strName				AS	strEntityName,		
				ISNULL(ysnSigned,0)		AS	ysnSigned,
				ISNULL(ysnMailSent,0)	AS	ysnMailSent,		
				CY.strEntityNo			AS	strCreatedByNo,	
				SP.strName				AS	strSalesperson,
				dbo.fnCTConvertQuantityToTargetCommodityUOM(CH.intCommodityUOMId,SU.intCommodityUnitMeasureId,CH.dblQuantity) dblQtyInStockUOM,

				CD.intCurrencyId,		CD.intBookId,			CD.intSubBookId,		CD.intCompanyLocationId, 
				CD.intContractSeq,		CD.dtmStartDate,		CD.dtmEndDate,			CD.strPurchasingGroup,
				CD.dblQuantity,			CD.dblFutures,			CD.dblBasis,			CD.dblCashPrice,
				CD.dblScheduleQty,		CD.dblNoOfLots,			CD.strItemNo,			CD.strPricingType,
				CD.strFutMarketName,	CD.strItemUOM,			CD.strLocationName,		CD.strPriceUOM,
				CD.strCurrency,			CD.strFutureMonth,		CD.strStorageLocation,	CD.strSubLocation,
				CD.strItemDescription,	CD.intContractDetailId,	CD.strProductType,		PW.intAllStatusId,
				BC.strBasisComponent,
				CD.intContractStatusId,	CD.strContractItemName,	CD.strContractItemNo
				
		FROM	tblCTContractHeader			CH
		JOIN	tblICCommodity				CO	ON	CO.intCommodityId				=	CH.intCommodityId
		JOIN	tblCTPricingType			PT	ON	PT.intPricingTypeId				=	CH.intPricingTypeId
		JOIN	tblEMEntity					EY	ON	EY.intEntityId					=	CH.intEntityId
		JOIN	tblCTContractType			CT	ON	CT.intContractTypeId			=	CH.intContractTypeId
		JOIN	tblICCommodityUnitMeasure	CU	ON	CU.intCommodityUnitMeasureId	=	CH.intCommodityUOMId
		JOIN	tblICUnitMeasure			UM	ON	UM.intUnitMeasureId				=	CU.intUnitMeasureId
		JOIN	tblICCommodityUnitMeasure	SU	ON	SU.intCommodityId				=	CH.intCommodityId
												AND	SU.ysnStockUnit					=	1						LEFT
		JOIN	tblCTContractBasis			CB	ON	CB.intContractBasisId			=	CH.intContractBasisId	LEFT
		JOIN	tblCTPosition				PO	ON	PO.intPositionId				=	CH.intPositionId		LEFT
		JOIN	tblEMEntity					SP	ON	SP.intEntityId					=	CH.intSalespersonId		LEFT
		JOIN	tblSMCountry				CR	ON	CR.intCountryID					=	CH.intCountryId			LEFT
		JOIN	tblEMEntity					CY	ON	CY.intEntityId					=	CH.intCreatedById		LEFT
		JOIN	
		(
				SElECT * FROM
				(
					SELECT	intCurrencyId,					intBookId,					intSubBookId,					intCompanyLocationId, 
							intContractSeq,					dtmStartDate,				dtmEndDate,						strPurchasingGroup,
							dblQuantity,					dblFutures,					dblBasis,						dblCashPrice,
							dblScheduleQty,					dblNoOfLots,				strItemNo,						strPricingType,
							strFutMarketName,				strItemUOM,					strLocationName,				strPriceUOM,
							strCurrency,					strFutureMonth,				strStorageLocation,				strSubLocation,
							strItemDescription,				intContractDetailId,		strProductType,					ysnSubCurrency,
							intContractStatusId,			strContractItemName,		strContractItemNo,				intContractHeaderId,
							ROW_NUMBER() OVER (PARTITION BY intContractHeaderId ORDER BY intContractDetailId ASC) intRowNum
					FROM	vyuCTContractSequence 
					WHERE	ISNULL(intContractStatusId,1) NOT IN (3,5)
				)t	WHERE intRowNum = 1			

		)									CD	ON	CD.intContractHeaderId			=	CH.intContractHeaderId	LEFT
		JOIN
		(
				SELECT intContractDetailId, strBasisComponent = STUFF((
				SELECT ', ' + strItemNo + ' = ' + dbo.fnRemoveTrailingZeroes(dblRate) FROM vyuCTContractCostView
				WHERE intContractDetailId = x.intContractDetailId
				FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, '')
				FROM vyuCTContractCostView AS x
				GROUP BY intContractDetailId
		)									BC	ON	BC.intContractDetailId			=	CD.intContractDetailId	LEFT
		JOIN 
		(
				SELECT intContractHeaderId
				,SUM(POWER(2, intContractStatusId )) intAllStatusId
				FROM 
				(
					SELECT DISTINCT intContractHeaderId
					,intContractStatusId
					FROM tblCTContractDetail
				 ) t
				GROUP BY intContractHeaderId
		)									PW	ON	PW.intContractHeaderId			=	CD.intContractHeaderId
	
