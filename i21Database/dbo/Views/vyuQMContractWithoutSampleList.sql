CREATE VIEW vyuQMContractWithoutSampleList
AS
SELECT 
	 CTCT.strContractType
	,CTCH.intContractHeaderId AS intLinkContractHeaderId
	,CTCD.intContractDetailId
	,EME.strName AS strCounterParty
	,CTWG.strWeightGradeDesc AS strGrade
	,CTCH.strContractNumber
	,CTCD.intContractSeq AS intSequenceNumber
	,CTCD.dtmStartDate AS dtmContractStartDate
	,CTCD.dtmEndDate AS dtmContractEndDate
	,CTCD.dblQuantity AS dblContractQuantity
	,CTCD.dblAppliedQty AS dblContractAppliedQuantity
	,CTCD.dblAvailableQty AS dblContractAvailableQuantity
	,ICUM.strUnitMeasure
	,CTCD.dtmPlannedAvailabilityDate
	,CTCD.dtmUpdatedAvailabilityDate
	,ICSI.strItemNo
	,ICSI.strCommodityCode
	,ICSI.strProductType
	,SMC.strCountry
	,SMCL.strLocationName
	,CTCS.strContractStatus
	,CTCD.strBundleItemNo
FROM vyuCTGridContractDetail CTCD
INNER JOIN tblCTContractHeader CTCH ON CTCD.intContractHeaderId = CTCH.intContractHeaderId
INNER JOIN tblCTContractStatus CTCS ON CTCS.intContractStatusId = CTCD.intContractStatusId AND CTCS.strContractStatus NOT IN ('Cancelled' , 'Complete', 'Short Close')
INNER JOIN tblEMEntity EME ON CTCH.intEntityId = EME.intEntityId
INNER JOIN tblICUnitMeasure ICUM ON CTCD.intUnitMeasureId = ICUM.intUnitMeasureId
INNER JOIN vyuICSearchItem ICSI ON ICSI.intItemId = CTCD.intItemId
INNER JOIN tblCTWeightGrade CTWG ON CTCH.intGradeId = CTWG.intWeightGradeId AND ISNULL(CTWG.ysnSample, 0) = 1
INNER JOIN tblCTContractType CTCT ON CTCH.intContractTypeId = CTCT.intContractTypeId
INNER JOIN tblSMCompanyLocation SMCL ON CTCD.intCompanyLocationId = SMCL.intCompanyLocationId
LEFT JOIN tblQMSample QMS ON CTCD.intContractDetailId = QMS.intContractDetailId
LEFT JOIN tblSMCountry SMC ON CTCH.intCountryId = SMC.intCountryID
WHERE QMS.intSampleId IS NULL
