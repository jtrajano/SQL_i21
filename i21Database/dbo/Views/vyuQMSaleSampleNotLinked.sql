 CREATE VIEW vyuQMSaleSampleNotLinked
 AS
 SELECT  
	A.*,
    null intSampleIdP,    
    '' COLLATE Latin1_General_CI_AS strEntityNameP,    
    0 dblSampleQtyP,    
    '' COLLATE Latin1_General_CI_AS strSampleUOMP,    
    V1.dblNetWeight dblNetWeightP,    
    V1.strNetWeightUOM strNetWeightUOMP,    
    0 dblRepresentingQtyP,    
	'' COLLATE Latin1_General_CI_AS strDescriptionP,
    '' COLLATE Latin1_General_CI_AS strItemNoP,    
    '' COLLATE Latin1_General_CI_AS strSampleNumberP,    
    '' COLLATE Latin1_General_CI_AS strSampleTypeP,    
    '' COLLATE Latin1_General_CI_AS strSamplingCriteriaP,    
    null dtmSamplingEndDateP,    
    NULL dtmRequestedDateP,    
    NULL dtmSampleSentDateP,    
    '' COLLATE Latin1_General_CI_AS strCourierP,    
    NULL dtmSampleReceivedDateP,    
    '' COLLATE Latin1_General_CI_AS strStatusP,    
    '' COLLATE Latin1_General_CI_AS strLotNumberP,   
    V1.strFreightTerm strFreightTermP,    
    V1.strINCOLocation strINCOLocationP,    
    V1.intContractStatusId intContractStatusIdP,
	V1.intContractHeaderId intContractHeaderIdP,
	S1.intSampleId intSampleIdS,    
	S1.dblSampleQty dblSampleQtyS,    
	S1.strSampleUOM strSampleUOMS,    
	S1.dblRepresentingQty dblRepresentingQtyS,    
	S1.strDescription strDescriptionS,
	S1.strItemNo strItemNoS,    
	S1.strSampleNumber strSampleNumberS,    
	S1.strSampleTypeName strSampleTypeS,    
	S1.strSamplingCriteria strSamplingCriteriaS,    
	S1.dtmSamplingEndDate dtmSamplingEndDateS,    
	S1.dtmRequestedDate dtmRequestedDateS,    
	S1.dtmSampleSentDate dtmSampleSentDateS,    
	S1.strCourier strCourierS,    
	S1.dtmSampleReceivedDate dtmSampleReceivedDateS,    
	S1.strStatus strStatusS,    
	S1.strLotNumber strLotNumberS,  
	V1.strEntityName strEntityNameS,   
	V1.dblNetWeight dblNetWeightS,    
	V1.strNetWeightUOM strNetWeightUOMS,  
	V1.strFreightTerm strFreightTermS,    
	V1.strINCOLocation strINCOLocationS,    
	V1.intContractStatusId intContractStatusIdS,
	V1.intContractHeaderId intContractHeaderIdS
	
    FROM vyuQMSampleList S1   
	OUTER APPLY(
		SELECT strEntityName,dblNetWeight,strNetWeightUOM ,strFreightTerm ,strINCOLocation,intContractStatusId,intContractHeaderId 
        FROM vyuCTContractDetailView
		WHERE intContractDetailId = S1.intContractDetailId    
		AND intContractStatusId NOT IN( 3, 5, 6 )   
		AND intContractTypeId = 2
	)V1
	
	OUTER APPLY(
		SELECT 
		strAllocationNumber,    
		intAllocationDetailId,    
		dtmPStartDate dtmStartDateP,    
		dtmPEndDate dtmEndDateP,
		intPContractSeq intSequenceP,    
		intSContractSeq intSequenceS,    
		dtmSStartDate dtmStartDateS,    
		dtmSEndDate dtmEndDateS,    
		intPContractDetailId intContractDetailIdP,    
		strPContractNumber strContractNumberP,    
		intSContractDetailId intContractDetailIdS,    
		strSContractNumber strContractNumberS,    
		dblSAllocatedQty,    
		dblPAllocatedQty
		FROM  vyuLGAllocatedContracts 
		WHERE  intSContractDetailId = S1.intContractDetailId    
	)A
      
    WHERE S1.strContractType='Sale' --and A.intPContractDetailId = S1.intContractDetailId
	AND ISNULL(S1.intRelatedSampleId,0) = 0
	

