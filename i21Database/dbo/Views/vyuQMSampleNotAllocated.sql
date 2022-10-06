CREATE VIEW vyuQMSampleNotAllocated AS 
SELECT
  ''   COLLATE Latin1_General_CI_AS strAllocationNumber ,
   NULL intAllocationDetailId,
   V1.dtmStartDate dtmStartDateP,
   V1.dtmEndDate dtmEndDateP,
   V1.intContractSeq intSequenceP,
   NULL intSequenceS,
   NULL dtmStartDateS,
   NULL dtmEndDateS,
   V1.intContractDetailId intContractDetailIdP,
   V1.strContractNumber strContractNumberP,
   NULL intContractDetailIdS,
   NULL strContractNumberS,
   0 dblSAllocatedQty,
   V1.dblAllocatedQty dblPAllocatedQty,
   S1.intSampleId intSampleIdP,
   S1.dblSampleQty dblSampleQtyP,
   S1.strSampleUOM strSampleUOMP,
   S1.dblRepresentingQty dblRepresentingQtyP,
   S1.strItemNo strItemNoP,
   S1.strSampleNumber strSampleNumberP,
   S1.strSampleTypeName strSampleTypeP,
   S1.strSamplingCriteria strSamplingCriteriaP,
   S1.dtmSamplingEndDate dtmSamplingEndDateP,
   S1.dtmRequestedDate dtmRequestedDateP,
   S1.dtmSampleSentDate dtmSampleSentDateP,
   S1.strCourier strCourierP,
   S1.dtmSampleReceivedDate dtmSampleReceivedDateP,
   S1.strStatus strStatusP,
   S1.strLotNumber strLotNumberP,
   V1.strEntityName strEntityNameP,
   V1.dblNetWeight dblNetWeightP,
   V1.strNetWeightUOM strNetWeightUOMP,
   V1.strFreightTerm strFreightTermP,
   V1.strINCOLocation strINCOLocationP,
   V1.intContractStatusId intContractStatusIdP,
   V1.intContractHeaderId intContractHeaderIdP,
   NULL intSampleIdS,
   NULL dblSampleQtyS,
   NULL strSampleUOMS,
   NULL dblRepresentingQtyS,
   NULL strItemNoS,
   NULL strSampleNumberS,
   NULL strSampleTypeS,
   NULL strSamplingCriteriaS,
   NULL dtmSamplingEndDateS,
   NULL dtmRequestedDateS,
   NULL dtmSampleSentDateS,
   NULL strCourierS,
   NULL dtmSampleReceivedDateS,
   NULL strStatusS,
   NULL strLotNumberS,
   NULL strEntityNameS,
   NULL dblNetWeightS,
   NULL strNetWeightUOMS,
   NULL strFreightTermS,
   NULL strINCOLocationS,
   NULL intContractStatusIdS,
   NULL intContractHeaderIdS 
   FROM vyuQMSampleList S1 
   LEFT JOIN vyuLGAllocatedContracts A ON A.intPContractDetailId = S1.intContractDetailId
	OUTER APPLY(
		SELECT strEntityName,dblNetWeight,strNetWeightUOM,strFreightTerm,strINCOLocation,intContractStatusId,dblAllocatedQty,
      intContractHeaderId,intContractSeq,dtmStartDate,dtmEndDate,intContractDetailId,strContractNumber
		FROM vyuCTContractDetailView WHERE intContractDetailId = S1.intContractDetailId 
		AND intContractStatusId NOT in(3,5,6) AND intContractTypeId =1
	)V1
WHERE S1.strContractType='Purchase' AND A.intAllocationDetailId IS NULL 
UNION
SELECT
   ''  COLLATE Latin1_General_CI_AS strAllocationNumber,
   NULL intAllocationDetailId,
   NULL dtmStartDateP,
   NULL dtmEndDateP,
   NULL intSequenceP,
   V2.intContractSeq intSequenceS,
   V2.dtmStartDate dtmStartDateS,
   V2.dtmEndDate  dtmEndDateS,
   NULL intContractDetailIdP,
   NULL strContractNumberP,
   V2.intContractDetailId intContractDetailIdS,
   V2.strContractNumber  strContractNumberS,
   A.dblSAllocatedQty,
   0 dblPAllocatedQty,
   NULL intSampleIdP,
   NULL dblSampleQtyP,
   NULL strSampleUOMP,
   NULL dblRepresentingQtyP,
   NULL strItemNoP,
   NULL strSampleNumberP,
   NULL strSampleTypeP,
   NULL strSamplingCriteriaP,
   NULL dtmSamplingEndDateP,
   NULL dtmRequestedDateP,
   NULL dtmSampleSentDateP,
   NULL strCourierP,
   NULL dtmSampleReceivedDateP,
   NULL strStatusP,
   NULL strLotNumberP,
   NULL strEntityNameP,
   NULL dblNetWeightP,
   NULL strNetWeightUOMP,
   NULL strFreightTermP,
   NULL strINCOLocationP,
   NULL intContractStatusIdP,
   NULL intContractHeaderIdP,
   S2.intSampleId intSampleIdS,
   S2.dblSampleQty dblSampleQtyS,
   S2.strSampleUOM strSampleUOMS,
   S2.dblRepresentingQty dblRepresentingQtyS,
   S2.strItemNo strItemNoS,
   S2.strSampleNumber strSampleNumberS,
   S2.strSampleTypeName strSampleTypeS,
   S2.strSamplingCriteria strSamplingCriteriaS,
   S2.dtmSamplingEndDate dtmSamplingEndDateS,
   S2.dtmRequestedDate dtmRequestedDateS,
   S2.dtmSampleSentDate dtmSampleSentDateS,
   S2.strCourier strCourierS,
   S2.dtmSampleReceivedDate dtmSampleReceivedDateS,
   S2.strStatus strStatusS,
   S2.strLotNumber strLotNumberS,
   V2.strEntityName strEntityNameS,
   V2.dblNetWeight dblNetWeightS,
   V2.strNetWeightUOM strNetWeightUOMS,
   V2.strFreightTerm strFreightTermS,
   V2.strINCOLocation strINCOLocationS,
   V2.intContractStatusId intContractStatusIdS,
   V2.intContractHeaderId intContractHeaderIdS 
   FROM vyuQMSampleList S2 
   LEFT JOIN vyuLGAllocatedContracts A ON A.intSContractDetailId = S2.intContractDetailId 
	OUTER APPLY(
		SELECT strEntityName,dblNetWeight,strNetWeightUOM,strFreightTerm,strINCOLocation,intContractStatusId,
      intContractHeaderId,intContractSeq,dtmStartDate,dtmEndDate,intContractDetailId,strContractNumber
		FROM vyuCTContractDetailView where intContractDetailId = S2.intContractDetailId 
		AND intContractStatusId not in(3,5,6) AND intContainerTypeId =2
	)V2
WHERE S2.strContractType = 'Sale' AND A.intAllocationDetailId IS NULL
