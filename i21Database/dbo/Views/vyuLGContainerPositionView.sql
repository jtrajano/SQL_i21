CREATE VIEW dbo.vyuLGContainerPositionView
AS
SELECT dtmStartDate,
	dtmEndDate,
	strPosition,
	strContractNumber,
	intContractSeq,
	strCustomerContract,
	strEntityName,
	strItemNo,
	strItemDescription,
	strContractBasis,
	strFixationStatus,
	strFinalPrice,
	strPriceWeightUOM,
	strPriceUOM,
	dblQuantity,
	strQuantityUOM,
	dblWeight,
	dblShippedWeight,
	intNoOfSequence,
	intNoOfApprovals			=sum(intNoOfApprovals),
	intNoOfRejects				=sum(intNoOfRejects) ,
	intNoOfIntegrationRequests	=sum(intNoOfIntegrationRequests) ,
	intTrucksRemaining			=intNoOfSequence-intNoOfReweigh ,
	dblBasis,
	strInternalComment
	from
	(
	SELECT 
		dtmStartDate				=	(SELECT  MIN(Seq.dtmStartDate) FROM vyuCTContractDetailView Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
		dtmEndDate					=	(SELECT  MAX(Seq.dtmEndDate) FROM vyuCTContractDetailView Seq  WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
		strPosition					=	PO.strPosition,
		strContractNumber			=	CH.strContractNumber,
		strCustomerContract			=	CH.strCustomerContract,
		strEntityName				=	EY.strName,
		strItemNo					=	IM.strItemNo,
		strItemDescription			=	IM.strDescription,
		strContractBasis			=	CB.strDescription,
		strFixationStatus			=	CASE PT.strPricingType WHEN 'Cash' THEN 'OT' WHEN 'Priced' THEN 'FX' ELSE 'UF' END,  
		strFinalPrice				=	CD.dblCashPrice,
		dblQuantity					=	CD.dblQuantity,  
		strQuantityUOM				=	U1.strUnitMeasure,
		dblWeight					=	dbo.fnRemoveTrailingZeroes (round(IsNull(dbo.fnCalculateQtyBetweenUOM (CD.intNetWeightUOMId,
												(SELECT Top (1) IU.intItemUOMId FROM tblICItemUOM IU 
													JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
													JOIN tblLGCompanyPreference C On C.intWeightUOMId = UOM.intUnitMeasureId),
												CD.dblNetWeight), 0),2) ),	
		dblShippedWeight			=	dbo.fnRemoveTrailingZeroes (round(IsNull(dbo.fnCalculateQtyBetweenUOM(LoadDetail.intWeightItemUOMId,
												(SELECT Top (1) IU.intItemUOMId FROM tblICItemUOM IU 
													JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
													JOIN tblLGCompanyPreference C On C.intWeightUOMId = UOM.intUnitMeasureId),
												LoadDetail.dblNet), 0),2) ),
		intNoOfSequence				= 1,
		intNoOfReweigh				= (SELECT COUNT(intLineNo) 
									   FROM tblICInventoryReceipt R
									   JOIN tblICInventoryReceiptItem I ON I.intInventoryReceiptId = R.intInventoryReceiptId
									   WHERE intLineNo = CD.intContractDetailId AND R.ysnPosted = 1),
		intNoOfApprovals			= CASE WHEN SampStatus.strStatus = 'Approved' THEN 1 ELSE 0 END,
		intNoOfRejects				= CASE WHEN SampStatus.strStatus = 'Rejected' THEN 1 ELSE 0 END,
		intNoOfIntegrationRequests	= CASE WHEN ContLink.strIntegrationOrderNumber is not null THEN 1 ELSE 0 END,
		dblBasis					= dbo.fnRemoveTrailingZeroes (round(CD.dblBasis,2)),
		strInternalComment = CH.strInternalComment,
		intContractSeq = CD.intContractSeq,
		strPriceWeightUOM = U2.strUnitMeasure,
		strPriceUOM = CU.strCurrency
FROM tblCTContractHeader CH
JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId --AND EY.strEntityType = (CASE WHEN CH.intContractTypeId = 1 THEN 'Vendor' ELSE 'Customer' END)
LEFT JOIN tblCTPosition PO ON PO.intPositionId = CH.intPositionId
LEFT JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intPContractDetailId = CD.intContractDetailId
LEFT JOIN tblICItem	IM ON IM.intItemId = CD.intItemId
LEFT JOIN tblCTContractBasis CB	ON CB.intContractBasisId = CH.intContractBasisId
LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
LEFT JOIN tblSMCurrency	CU ON CU.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = CD.intItemUOMId
LEFT JOIN tblICUnitMeasure U1 ON U1.intUnitMeasureId = IU.intUnitMeasureId
LEFT JOIN tblLGLoadDetailContainerLink ContLink ON ContLink.intLoadDetailId = LoadDetail.intLoadDetailId
LEFT JOIN tblICItemUOM PU ON PU.intItemUOMId = CD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = PU.intUnitMeasureId	
LEFT JOIN tblQMSample Samp ON Samp.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblQMSampleDetail SampDetail On SampDetail.intSampleId = Samp.intSampleId
LEFT JOIN tblQMSampleStatus SampStatus On SampStatus.intSampleStatusId = Samp.intSampleStatusId
LEFT JOIN tblQMAttribute SampAtt ON SampAtt.intAttributeId = SampDetail.intAttributeId AND SampAtt.strAttributeName = 'Approval Basis' AND SampDetail.strAttributeValue='Yes'
INNER JOIN tblCTPosition Pos on Pos.intPositionId=CH.intPositionId and Pos.strPosition='Spot'
) gc
group by  dtmStartDate,dtmEndDate,strPosition,strContractNumber,strCustomerContract,strEntityName,strItemNo,strItemDescription,strContractBasis,
strFixationStatus,strFinalPrice,dblQuantity,strQuantityUOM,dblWeight,dblShippedWeight,intNoOfSequence,dblBasis,strInternalComment,intContractSeq,
intNoOfReweigh,strPriceWeightUOM,strPriceUOM 