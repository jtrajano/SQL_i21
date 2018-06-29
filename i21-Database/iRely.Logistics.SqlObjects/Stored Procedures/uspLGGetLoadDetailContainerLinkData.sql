CREATE PROCEDURE uspLGGetLoadDetailContainerLinkData
	@intLoadId INT
AS
BEGIN
	SELECT DISTINCT LDCL.*
		,UOM.strUnitMeasure
		,LC.strContainerNumber
		,LC.strLotNumber
		,LC.strMarks
		,PHeader.strContractNumber AS strPContractNumber
		,PDetail.intContractSeq AS intPContractSeq
		,PTP.strPricingType AS strPPricingType
		,SHeader.strContractNumber AS strSContractNumber
		,SDetail.intContractSeq AS intSContractSeq
		,PTS.strPricingType AS strSPricingType
		,PDetail.intContractDetailId AS intPContractDetailId
		,SDetail.intContractDetailId AS intSContractDetailId
		,Item.strDescription AS strItemDescription
		,CONVERT(BIT, ISNULL(LC.ysnRejected, 0)) AS ysnRejected
		,CAST((
				CASE 
					WHEN ISNULL(LDCL.dblReceivedQty, 0) = 0
						THEN 0
					ELSE 1
					END
				) AS BIT) AS ysnReceived
		,PDetail.dblCashPrice AS dblPCashPrice
		,SDetail.dblCashPrice AS dblSCashPrice
		,PDetail.dblCashPrice AS dblPContractPrice
		,SDetail.dblCashPrice AS dblSContractPrice
		,LCWU.strUnitMeasure AS strWeightUnitMeasure
		,LC.dblNetWt
		,NULL AS dblCashPrice
		,NULL AS strPriceUOM
		,NULL AS dblContractCost
		,NULL AS dblLineTotal
		,NULL AS dblRatePerUnit
		,strSampleStatus = (SELECT TOP 1 SSA.strStatus
							FROM tblQMSample SAM 
							JOIN tblQMSampleStatus SSA ON SSA.intSampleStatusId = SAM.intSampleStatusId
							WHERE SAM.intLoadContainerId = LC.intLoadContainerId)
		,NULL AS ysnSendIntegrationRequest
		,NULL AS ysnReverseIntegrationRequest
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON LD.intLoadId = L.intLoadId AND L.intLoadId = @intLoadId
	JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
	LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
	LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = LC.intUnitMeasureId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblCTContractDetail PDetail ON PDetail.intContractDetailId = LD.intPContractDetailId
	LEFT JOIN tblCTContractHeader PHeader ON PHeader.intContractHeaderId = PDetail.intContractHeaderId
	LEFT JOIN tblCTContractDetail SDetail ON SDetail.intContractDetailId = LD.intSContractDetailId
	LEFT JOIN tblCTContractHeader SHeader ON SHeader.intContractHeaderId = SDetail.intContractHeaderId
	LEFT JOIN tblCTPricingType PTP ON PTP.intPricingTypeId = PDetail.intPricingTypeId
	LEFT JOIN tblCTPricingType PTS ON PTS.intPricingTypeId = SDetail.intPricingTypeId
END