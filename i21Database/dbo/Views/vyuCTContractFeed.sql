CREATE VIEW [dbo].[vyuCTContractFeed]

AS 


	SELECT	CD.intContractHeaderId,			CD.intContractDetailId,		CH.strCommodityCode,	CH.strCommodityDescription AS strCommodityDesc,
			CH.strContractBasis,			CD.strSubLocation,			CH.strCreatedBy,		CH.strContractBasisDescription AS strContractBasisDesc,	
			CD.strCreatedByNo,				CH.strTerm,					CD.strPurchasingGroup,	CH.strEntityNumber AS strEntityNo,	
			CH.strContractNumber,			CD.strERPPONumber,			CD.intContractSeq,		CD.strItemNo,
			CD.strStorageLocation,			CD.dblQuantity,				CD.dblCashPrice,		CD.strItemUOM	AS strQuantityUOM,
			CD.dtmPlannedAvailabilityDate,	CD.dblBasis,				CD.strCurrency,			CD.dblCashPrice / 100.0	AS dblUnitCashPrice,	
			CD.strPriceUOM,					CH.dtmContractDate,			CD.dtmStartDate,		CD.dtmEndDate,
			AE.intEntityId	AS intSubmittedById,
			AE.strName		AS strSubmittedBy,
			AE.strEntityNo	AS strSubmittedByNo
	FROM	vyuCTContractSequence	CD
	JOIN	vyuCTContractHeaderView	CH	ON CH.intContractHeaderId	=	CD.intContractHeaderId LEFT
	JOIN	(
					SELECT	DISTINCT TR.intRecordId, AP.intSubmittedById 
					FROM	tblSMApproval		AP
					JOIN	tblSMTransaction	TR	ON	TR.intTransactionId =	AP.intTransactionId
					JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
					WHERE	SC.strNamespace = 'ContractManagement.view.Contract' AND AP.strStatus = 'Submitted'

			) AP ON AP.intRecordId = CD.intContractDetailId	LEFT
	JOIN	tblEMEntity	AE	ON	AE.intEntityId	=	AP.intSubmittedById
