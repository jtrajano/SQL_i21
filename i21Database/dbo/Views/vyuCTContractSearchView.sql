CREATE VIEW [dbo].[vyuCTContractSearchView]

AS

	SELECT		CH.intContractHeaderId,
				CH.dtmContractDate,
				CH.strEntityName AS strCustomerVendor,
				CH.strContractType,
				CH.dblHeaderQuantity,
				CH.intContractNumber,
				CH.strCustomerContract,
				CH.ysnSigned,
				CH.ysnPrinted,
				BL.dblBalance,
				CH.strHeaderUnitMeasure
			
	FROM		vyuCTContractHeaderView		CH	LEFT
	JOIN		tblICCommodityUnitMeasure	CM	ON	CM.intCommodityUnitMeasureId	= CH.intCommodityUnitMeasureId
	JOIN
	(
		SELECT	HV.intContractHeaderId,SUM([dbo].[fnCTConvertQuantityToTargetItemUOM](CD.intItemId,CD.intUnitMeasureId,UM.intUnitMeasureId,CD.dblBalance)) AS dblBalance
		FROM	vyuCTContractHeaderView		HV	LEFT
		JOIN	tblICCommodityUnitMeasure	UM	ON	UM.intCommodityUnitMeasureId	=	HV.intCommodityUnitMeasureId LEFT
		JOIN	vyuCTContractDetailView		CD	ON CD.intContractHeaderId			=	HV.intContractHeaderId
		GROUP 
		BY		HV.intContractHeaderId
	)BL ON		BL.intContractHeaderId = CH.intContractHeaderId