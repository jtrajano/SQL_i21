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
		strPosition					=	CH.strPosition,
		strContractNumber			=	CH.strContractNumber,
		strCustomerContract			=	CH.strCustomerContract,
		strEntityName				=	CH.strEntityName,
		strItemNo					=	CD.strItemNo,
		strItemDescription			=	CD.strItemDescription,
		strContractBasis			=	CH.strContractBasisDescription,
		strFixationStatus			=	CASE CD.strPricingType WHEN 'Cash' THEN 'OT' WHEN 'Priced' THEN 'FX' ELSE 'UF' END,  
		strFinalPrice				=	dbo.fnRemoveTrailingZeroes (round(dbo.fnCalculateCostBetweenUOM(CD.intPriceItemUOMId,
													(SELECT Top (1) IU.intItemUOMId FROM tblICItemUOM IU 
													JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = IU.intUnitMeasureId
													JOIN tblLGCompanyPreference C On C.intWeightUOMId = UOM.intUnitMeasureId),
													CD.dblCashPrice)*CASE CD.ysnSubCurrency when 1 then 1 else 100 end,2) ),
		dblQuantity					=	CD.dblDetailQuantity,  
		strQuantityUOM				=	CD.strItemUOM,  
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
		strInternalComment=CD.strInternalComment,
		intContractSeq=CD.intContractSeq
FROM vyuCTContractHeaderView CH
JOIN vyuCTContractDetailView CD ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intPContractDetailId = CD.intContractDetailId
LEFT JOIN tblLGLoadDetailContainerLink ContLink ON ContLink.intLoadDetailId = LoadDetail.intLoadDetailId
LEFT JOIN tblQMSample Samp ON Samp.intContractDetailId = CD.intContractDetailId
LEFT JOIN tblQMSampleDetail SampDetail On SampDetail.intSampleId = Samp.intSampleId
LEFT JOIN tblQMSampleStatus SampStatus On SampStatus.intSampleStatusId = Samp.intSampleStatusId
LEFT JOIN tblQMAttribute SampAtt ON SampAtt.intAttributeId = SampDetail.intAttributeId AND SampAtt.strAttributeName = 'Approval Basis' AND SampDetail.strAttributeValue='Yes'
INNER JOIN tblCTPosition Pos on Pos.intPositionId=CD.intPositionId and Pos.strPosition='Spot'
) gc
group by  dtmStartDate,dtmEndDate,strPosition,strContractNumber,strCustomerContract,strEntityName,strItemNo,strItemDescription,strContractBasis,
strFixationStatus,strFinalPrice,dblQuantity,strQuantityUOM,dblWeight,dblShippedWeight,intNoOfSequence,dblBasis,strInternalComment,intContractSeq,
intNoOfReweigh