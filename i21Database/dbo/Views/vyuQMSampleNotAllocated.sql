CREATE VIEW vyuQMSampleNotAllocated AS 
SELECT
   A.strAllocationNumber,
   A.intAllocationDetailId,
   A.dtmPStartDate dtmStartDateP,
   A.dtmPEndDate dtmEndDateP,
   A.intPContractSeq intSequenceP,
   A.intSContractSeq intSequenceS,
   A.dtmPStartDate dtmStartDateS,
   A.dtmPEndDate dtmEndDateS,
   A.intPContractDetailId intContractDetailIdP,
   ISNULL(A.strPContractNumber, S1.strContractNumber) strContractNumberP,
   A.intSContractDetailId intContractDetailIdS,
   A.strSContractNumber strContractNumberS,
   A.dblSAllocatedQty,
   A.dblPAllocatedQty,
   S1.intSampleId intSampleIdP,
   S1.dblSampleQty dblSampleQtyP,
   S1.strSampleUOM strSampleUOMP,
   S1.dblRepresentingQty dblRepresentingQtyP,
   S1.strItemNo strItemNoP,
   S1.strSampleNumber strSampleNumberP,
   S1.strGrade strSampleTypeP,
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
FROM
   vyuQMSampleList S1 
   LEFT JOIN
      vyuCTContractDetailView V1 
      ON V1.intContractDetailId = S1.intContractDetailId 
   LEFT JOIN
      vyuLGAllocatedContracts A 
      ON A.intPContractDetailId = S1.intContractDetailId 
WHERE
   V1.intContractStatusId NOT IN
   (
      3,
      5,
      6 
   )
   AND V1.intContractTypeId = 1 
   AND A.intAllocationDetailId IS NULL 
UNION
SELECT
   A.strAllocationNumber,
   A.intAllocationDetailId,
   A.dtmPStartDate dtmStartDateP,
   A.dtmPEndDate dtmEndDateP,
   A.intPContractSeq intSequenceP,
   A.intSContractSeq intSequenceS,
   A.dtmPStartDate dtmStartDateS,
   A.dtmPEndDate dtmEndDateS,
   A.intPContractDetailId intContractDetailIdP,
   A.strPContractNumber strContractNumberP,
   A.intSContractDetailId intContractDetailIdS,
   A.strSContractNumber strContractNumberS,
   A.dblSAllocatedQty,
   A.dblPAllocatedQty,
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
   S2.strGrade strSampleTypeS,
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
FROM
   vyuQMSampleList S2 
   LEFT JOIN
      vyuCTContractDetailView V2 
      ON V2.intContractDetailId = S2.intContractDetailId 
   LEFT JOIN
      vyuLGAllocatedContracts A 
      ON A.intSContractDetailId = S2.intContractDetailId 
WHERE
   V2.intContractStatusId NOT IN
   (
      3,
      5,
      6 
   )
   AND V2.intContractTypeId = 2 
   AND A.intAllocationDetailId IS NULL
