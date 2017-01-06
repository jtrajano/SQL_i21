CREATE VIEW [dbo].[vyuCTContractFeed]

AS 


	SELECT	CD.intContractHeaderId,			CD.intContractDetailId,		CH.strCommodityCode,	CH.strCommodityDescription AS strCommodityDesc,
			CH.strContractBasis,			CD.strSubLocation,			CH.strCreatedBy,		CH.strContractBasisDescription AS strContractBasisDesc,	
			CD.strCreatedByNo,				CH.strTerm,					CD.strPurchasingGroup,	CH.strEntityNumber AS strEntityNo,	
			CH.strContractNumber,			CD.strERPPONumber,			CD.intContractSeq,		CD.strItemNo,
			CD.strStorageLocation,			CD.dblQuantity,				CD.dblCashPrice,		CD.strItemUOM	AS strQuantityUOM,
			CD.dtmPlannedAvailabilityDate,	CD.dblBasis,				CD.strCurrency,			CD.dblCashPrice / 100.0	AS dblUnitCashPrice,	
			CD.strPriceUOM,					CH.dtmContractDate,			CD.dtmStartDate,		CD.dtmEndDate
	FROM	vyuCTContractSequence	CD
	JOIN	vyuCTContractHeaderView	CH	ON CH.intContractHeaderId	=	CD.intContractHeaderId
