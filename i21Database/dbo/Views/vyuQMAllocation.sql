CREATE VIEW vyuQMAllocation    
AS    
SELECT     
A.strAllocationNumber,    
A.intAllocationDetailId,    
A.dtmPStartDate dtmStartDateP,    
A.dtmPEndDate dtmEndDateP,
A.intPContractSeq intSequenceP,    
A.intSContractSeq intSequenceS,    
A.dtmSStartDate dtmStartDateS,    
A.dtmSEndDate dtmEndDateS,    
A.intPContractDetailId intContractDetailIdP,    
A.strPContractNumber strContractNumberP,    
A.intSContractDetailId intContractDetailIdS,    
A.strSContractNumber strContractNumberS,    
A.dblSAllocatedQty,    
A.dblPAllocatedQty,    
U.*,    
V.*    
FROM  vyuLGAllocatedContracts A     
OUTER APPLY (    
    SELECT     
    S1.intSampleId intSampleIdP,    
    V1.strEntityName strEntityNameP,    
    S1.dblSampleQty dblSampleQtyP,    
    S1.strSampleUOM strSampleUOMP,    
    V1.dblNetWeight dblNetWeightP,    
    V1.strNetWeightUOM strNetWeightUOMP,    
    S1.dblRepresentingQty dblRepresentingQtyP,  
    S1.strDescription strDescriptionP, 
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
    V1.strFreightTerm strFreightTermP,    
    V1.strINCOLocation strINCOLocationP,    
    V1.intContractStatusId intContractStatusIdP,
	V1.intContractHeaderId intContractHeaderIdP
    FROM    
    vyuQMSampleList S1    
    LEFT JOIN     
    vyuCTContractDetailView V1    
    ON V1.intContractDetailId = S1.intContractDetailId    
    WHERE A.intPContractDetailId = S1.intContractDetailId    
AND V1.intContractStatusId NOT IN( 3, 5, 6 )    
) U    
OUTER APPLY(    
    SELECT     
    S2.intSampleId intSampleIdS,    
    S2.dblSampleQty dblSampleQtyS,    
    S2.strSampleUOM strSampleUOMS,    
    S2.dblRepresentingQty dblRepresentingQtyS,    
    S2.strDescription strDescriptionS,
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
    FROM     
    vyuQMSampleList S2     
    LEFT JOIN     
    vyuCTContractDetailView V2     
    ON V2.intContractDetailId = S2.intContractDetailId    
    WHERE --A.intSContractDetailId = S2.intContractDetailId    
    S2.intContractDetailId = A.intSContractDetailId  
   AND V2.intContractStatusId NOT IN( 3, 5, 6 )  
) V    
WHERE U.intSampleIdP IS NOT NULL OR V.intSampleIdS IS NOT NULL