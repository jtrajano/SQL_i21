CREATE VIEW vyuQMContractWithoutSampleList
AS
SELECT 
	 CTCDV.strContractType
	,CTCDV.intContractHeaderId AS intLinkContractHeaderId
	,CTCDV.intContractDetailId
	,CTCDV.strEntityName AS strCounterParty
	,CTWG.strWeightGradeDesc AS strGrade
	,CTCDV.strContractNumber
	,CTCDV.intContractSeq AS intSequenceNumber
	,CTCDV.dtmStartDate AS dtmContractStartDate
	,CTCDV.dtmEndDate AS dtmContractEndDate
	,CTCDV.dblDetailQuantity AS dblContractQuantity
	,CTCDV.dblAppliedQty AS dblContractAppliedQuantity
	,CTCDV.dblAvailableQty AS dblContractAvailableQuantity
	,ICUM.strUnitMeasure
	,CTCDV.dtmPlannedAvailabilityDate
	,CTCDV.dtmUpdatedAvailabilityDate
	,ITEM.intItemId
	,ITEM.strItemNo
	,ITEM.strCommodityCode
	,ITEM.strProductType
	,SMC.strCountry
	,CTCDV.strLocationName
	,CTCS.strContractStatus
	,ITEM.strBundleItemNo
	,CTCDV.strSampleTypeName
FROM vyuCTContractDetailView CTCDV
INNER JOIN tblCTContractStatus CTCS ON CTCS.intContractStatusId = CTCDV.intContractStatusId AND CTCS.strContractStatus NOT IN ('Cancelled' , 'Complete', 'Short Close')
INNER JOIN tblICUnitMeasure ICUM ON CTCDV.intUnitMeasureId = ICUM.intUnitMeasureId
INNER JOIN tblCTWeightGrade CTWG ON CTCDV.intGradeId = CTWG.intWeightGradeId AND ISNULL(CTWG.ysnSample, 0) = 1
LEFT JOIN tblQMSample QMS ON CTCDV.intContractDetailId = QMS.intContractDetailId
LEFT JOIN tblSMCountry SMC ON CTCDV.intCountryId = SMC.intCountryID
OUTER APPLY (
	SELECT 
		 ICI.intItemId
		,ICI.strItemNo
		,strCommodityCode
		,ICCA.strDescription AS strProductType
		,ICIB.strItemNo AS strBundleItemNo
	FROM tblCTContractDetail CTCD
	INNER JOIN tblICItem ICI ON ICI.intItemId = CTCD.intItemId
	LEFT JOIN tblICCommodityAttribute ICCA ON ICCA.intCommodityAttributeId = ICI.intProductTypeId
	LEFT JOIN tblICItem ICIB ON ICIB.intItemId = CTCD.intItemBundleId
	WHERE CTCD.intContractDetailId = CTCDV.intContractDetailId
) ITEM
WHERE QMS.intSampleId IS NULL