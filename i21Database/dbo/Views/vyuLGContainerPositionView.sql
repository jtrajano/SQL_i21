CREATE VIEW dbo.vyuLGContainerPositionView
AS
SELECT * FROM (
	SELECT CH.intContractHeaderId
		,dtmStartDate = MIN(CD.dtmStartDate)
		,dtmEndDate = MAX(CD.dtmEndDate)
		,Pos.strPosition
		,CH.strContractNumber
		,CH.strCustomerContract
		,strEntityName = EY.strName
		,I.strItemNo
		,strItemDescription = I.strDescription
		,strContractBasis = CB.strDescription
		,strFixationStatus = CASE MAX(PT.strPricingType)
			WHEN 'Priced'
				THEN 'FX'
			ELSE 'UF'
			END
		,dblBasis = MAX(CD.dblBasis)
		,strFinalPrice = MAX(CD.dblCashPrice)
		,strPriceWeightUOM = U2.strUnitMeasure
		,strPriceCurrency = CU.strCurrency
		,dblSeqQuantity = SUM(CD.dblQuantity)
		,dblContractQuantity = CH.dblQuantity
		,strQuantityUOM = MAX(UM.strUnitMeasure)
		,dblWeight = ISNULL(dbo.fnCalculateQtyBetweenUOM(CD.intNetWeightUOMId, (dbo.fnLGGetDefaultWeightItemUOM()), CD.dblNetWeight), 0)
		,dblShippedWeight = SUM(ISNULL(dbo.fnCalculateQtyBetweenUOM(LoadDetail.intWeightItemUOMId, (dbo.fnLGGetDefaultWeightItemUOM()), LoadDetail.dblNet), 0))
		,intNoOfContainers = COUNT(CD.intContractDetailId)
		,intNoOfApprovals = ISNULL(Samp.intApprovalCount, 0)
		,intNoOfRejects = ISNULL(RSamp.intApprovalCount, 0)
		,intNoOfIntegrationRequests = SUM(CAST(ISNULL(LDLink.ysnExported, 0) AS INT))
		,intTrucksRemaining = (
			SELECT COUNT(Seq.intContractDetailId)
			FROM tblCTContractDetail Seq
			WHERE Seq.intContractHeaderId = CH.intContractHeaderId
				AND Seq.intItemId = CD.intItemId
				AND Seq.intContractStatusId <> 5
			)
		,strRemarks = CH.strInternalComment
		,strDeliveryMonth = DATENAME(MM, MAX(CD.dtmEndDate)) + '-' + RIGHT(DATEPART(YY, CD.dtmEndDate), 2)
	FROM tblCTContractHeader CH
	JOIN tblCTContractDetail CD ON CD.intContractHeaderId = CH.intContractHeaderId
	JOIN tblICItem I ON I.intItemId = CD.intItemId
	JOIN tblCTPosition Pos ON Pos.intPositionId = CH.intPositionId
		AND Pos.strPosition = 'Spot'
	JOIN tblEMEntity EY ON EY.intEntityId = CH.intEntityId
	JOIN tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
	JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId
	JOIN tblICItemUOM UOM ON UOM.intItemUOMId = CD.intPriceItemUOMId
	JOIN tblICUnitMeasure U2 ON U2.intUnitMeasureId = UOM.intUnitMeasureId
	JOIN tblSMCurrency CU ON CU.intCurrencyID = CD.intCurrencyId
	JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = CD.intItemUOMId
	JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IUOM.intUnitMeasureId
	LEFT JOIN tblLGLoadDetail LoadDetail ON LoadDetail.intPContractDetailId = CD.intContractDetailId
	LEFT JOIN tblLGLoadDetailContainerLink LDLink ON LDLink.intLoadDetailId = LoadDetail.intLoadDetailId
	LEFT JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = LDLink.intLoadContainerId
		AND ISNULL(LC.ysnRejected, 0) = 0
	LEFT JOIN (
		SELECT DISTINCT Seq.intContractHeaderId
			,Samp.intItemId
			,COUNT(*) intApprovalCount
		FROM tblQMSample Samp
		JOIN tblQMSampleDetail SampDetail ON SampDetail.intSampleId = Samp.intSampleId
		JOIN tblQMAttribute SampAtt ON SampAtt.intAttributeId = SampDetail.intAttributeId
			AND SampAtt.strAttributeName = 'Approval Basis'
			AND SampDetail.strAttributeValue = 'Yes'
		JOIN tblQMSampleStatus SampStatus ON SampStatus.intSampleStatusId = Samp.intSampleStatusId
			AND SampStatus.strStatus = 'Approved'
		JOIN tblCTContractDetail Seq ON Seq.intContractDetailId = Samp.intContractDetailId
		GROUP BY Seq.intItemId
			,Seq.intContractHeaderId
			,Samp.intItemId
		) Samp ON Samp.intContractHeaderId = CH.intContractHeaderId
		AND Samp.intItemId = CD.intItemId
	LEFT JOIN (
		SELECT DISTINCT Seq.intContractHeaderId
			,Samp.intItemId
			,COUNT(*) intApprovalCount
		FROM tblQMSample Samp
		JOIN tblQMSampleDetail SampDetail ON SampDetail.intSampleId = Samp.intSampleId
		JOIN tblQMAttribute SampAtt ON SampAtt.intAttributeId = SampDetail.intAttributeId
			AND SampAtt.strAttributeName = 'Approval Basis'
			AND SampDetail.strAttributeValue = 'Yes'
		JOIN tblQMSampleStatus SampStatus ON SampStatus.intSampleStatusId = Samp.intSampleStatusId
			AND SampStatus.strStatus = 'Rejected'
		JOIN tblCTContractDetail Seq ON Seq.intContractDetailId = Samp.intContractDetailId
		GROUP BY Seq.intItemId
			,Seq.intContractHeaderId
			,Samp.intItemId
		) RSamp ON RSamp.intContractHeaderId = CH.intContractHeaderId
		AND RSamp.intItemId = CD.intItemId
	WHERE ISNULL(LC.ysnRejected, 0) = 0
	GROUP BY CD.intItemId,I.strItemNo,I.strDescription,CH.strContractNumber,CH.intContractHeaderId
		,CH.strCustomerContract,Pos.strPosition,EY.strName,CB.strDescription,PT.strPricingType
		,U2.strUnitMeasure,CU.strCurrency,CH.dblQuantity,UM.strUnitMeasure,CD.intNetWeightUOMId
		,CD.dblNetWeight,Samp.intApprovalCount,RSamp.intApprovalCount,CH.strInternalComment
	) tbl
WHERE intTrucksRemaining > 0