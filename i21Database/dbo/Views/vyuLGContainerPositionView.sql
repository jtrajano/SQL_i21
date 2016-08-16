CREATE VIEW dbo.vyuLGContainerPositionView
AS
SELECT 
	CH.intContractHeaderId,
	dtmStartDate = (SELECT MIN(Seq.dtmStartDate) FROM tblCTContractDetail Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	dtmEndDate = (SELECT MAX(Seq.dtmEndDate) FROM tblCTContractDetail Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	strPosition = Pos.strPosition,
	strContractNumber = CH.strContractNumber,
	strCustomerContract = CH.strCustomerContract,
	strEntityName = EY.strName,
	strItemNo = (SELECT Top(1) Item.strItemNo FROM tblCTContractDetail Seq JOIN tblICItem Item ON Item.intItemId = Seq.intItemId WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	strItemDescription = (SELECT Top(1) Item.strDescription FROM tblCTContractDetail Seq JOIN tblICItem Item ON Item.intItemId = Seq.intItemId WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	strContractBasis = CB.strDescription,
	strFixationStatus = CASE WHEN (
							SELECT Top(1) PT.strPricingType FROM tblCTContractDetail Seq JOIN tblCTPricingType PT ON PT.intPricingTypeId = Seq.intPricingTypeId WHERE Seq.intContractHeaderId=CH.intContractHeaderId
						) = 'Priced' THEN
								'FX'
						ELSE
								'UF'
						END,
	dblBasis = (SELECT Top(1) Seq.dblBasis FROM tblCTContractDetail Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	strFinalPrice = (SELECT Top(1) Seq.dblCashPrice FROM tblCTContractDetail Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	strPriceWeightUOM = (SELECT Top(1) U2.strUnitMeasure FROM tblCTContractDetail Seq JOIN tblICItemUOM UOM ON UOM.intItemUOMId = Seq.intPriceItemUOMId JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = UOM.intUnitMeasureId WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	strPriceCurrency = (SELECT Top(1) CU.strCurrency FROM tblCTContractDetail Seq JOIN tblSMCurrency	CU ON CU.intCurrencyID = Seq.intCurrencyId WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	dblQuantity = CH.dblQuantity,
	strQuantityUOM = (SELECT Top(1) U2.strUnitMeasure FROM tblCTContractDetail Seq JOIN tblICItemUOM UOM ON UOM.intItemUOMId = Seq.intItemUOMId JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = UOM.intUnitMeasureId WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	dblWeight = (
					SELECT SUM (
						IsNull(dbo.fnCalculateQtyBetweenUOM (Seq.intNetWeightUOMId,
												(dbo.fnLGGetDefaultWeightItemUOM()),
												Seq.dblNetWeight), 0)
					) FROM tblCTContractDetail Seq GROUP BY Seq.intContractHeaderId HAVING Seq.intContractHeaderId = CH.intContractHeaderId
				),
	dblShippedWeight = (
					SELECT SUM (
						IsNull(dbo.fnCalculateQtyBetweenUOM (LoadDetail.intWeightItemUOMId,
												(dbo.fnLGGetDefaultWeightItemUOM()),
												LoadDetail.dblNet), 0)
					) FROM tblLGLoadDetailContainerLink LDLink
					JOIN tblLGLoadContainer Cont ON Cont.intLoadContainerId = LDLink.intLoadContainerId AND IsNull(Cont.ysnRejected, 0) = 0
					JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intLoadDetailId = LDLink.intLoadDetailId
					JOIN tblCTContractDetail Seq ON Seq.intContractDetailId = LoadDetail.intPContractDetailId GROUP BY Seq.intContractHeaderId HAVING Seq.intContractHeaderId = CH.intContractHeaderId
				),
	intNoOfContainers = (SELECT Count(Seq.intContractDetailId) FROM tblCTContractDetail Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId),
	intNoOfApprovals = (
						IsNull((SELECT Count(Samp.strSampleNumber)
						FROM tblQMSample Samp
						JOIN tblQMSampleDetail SampDetail On SampDetail.intSampleId = Samp.intSampleId
						JOIN tblQMAttribute SampAtt ON SampAtt.intAttributeId = SampDetail.intAttributeId AND SampAtt.strAttributeName = 'Approval Basis' AND SampDetail.strAttributeValue='Yes'
						JOIN tblQMSampleStatus SampStatus On SampStatus.intSampleStatusId = Samp.intSampleStatusId AND SampStatus.strStatus = 'Approved'
						JOIN tblCTContractDetail Seq ON Seq.intContractDetailId = Samp.intContractDetailId GROUP BY Seq.intContractHeaderId HAVING Seq.intContractHeaderId = CH.intContractHeaderId), 0)
				),
	intNoOfRejects = (
						IsNull((SELECT Count(Samp.strSampleNumber)
						FROM tblQMSample Samp
						JOIN tblQMSampleDetail SampDetail On SampDetail.intSampleId = Samp.intSampleId
						JOIN tblQMAttribute SampAtt ON SampAtt.intAttributeId = SampDetail.intAttributeId AND SampAtt.strAttributeName = 'Approval Basis' AND SampDetail.strAttributeValue='Yes'
						JOIN tblQMSampleStatus SampStatus On SampStatus.intSampleStatusId = Samp.intSampleStatusId AND SampStatus.strStatus = 'Rejected'
						JOIN tblCTContractDetail Seq ON Seq.intContractDetailId = Samp.intContractDetailId GROUP BY Seq.intContractHeaderId HAVING Seq.intContractHeaderId = CH.intContractHeaderId), 0)
				),
	intNoOfIntegrationRequests = (
					SELECT SUM (
						Cast(IsNull(LDLink.ysnExported, 0) as Int)
					) FROM tblLGLoadDetailContainerLink LDLink
					JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intLoadDetailId = LDLink.intLoadDetailId
					JOIN tblCTContractDetail Seq ON Seq.intContractDetailId = LoadDetail.intPContractDetailId GROUP BY Seq.intContractHeaderId HAVING Seq.intContractHeaderId = CH.intContractHeaderId
				),

	intTrucksRemaining = (SELECT Count(Seq.intContractDetailId) FROM tblCTContractDetail Seq WHERE Seq.intContractHeaderId=CH.intContractHeaderId AND Seq.intContractStatusId <> 5)
FROM tblCTContractHeader CH
JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
JOIN tblCTPosition Pos on Pos.intPositionId=CH.intPositionId and Pos.strPosition='Spot'
JOIN tblCTContractBasis CB	ON CB.intContractBasisId = CH.intContractBasisId

