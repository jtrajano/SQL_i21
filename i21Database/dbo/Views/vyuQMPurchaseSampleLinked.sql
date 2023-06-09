 CREATE VIEW vyuQMPurchaseSampleLinked
 AS
 SELECT  
	A.*,
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
	V1.intContractHeaderId intContractHeaderIdP,
	V.*
    FROM vyuQMSampleList S1   
	OUTER APPLY(
		SELECT strEntityName,dblNetWeight,strNetWeightUOM ,strFreightTerm ,strINCOLocation,intContractStatusId,intContractHeaderId 
        FROM vyuCTContractDetailView
		WHERE intContractDetailId = S1.intContractDetailId    
		AND intContractStatusId NOT IN( 3, 5, 6 )   
		AND intContractTypeId = 1
	)V1
	OUTER APPLY(
		 SELECT     
		S2.intSampleId intSampleIdS,    
		S2.dblSampleQty dblSampleQtyS,    
		S2.strSampleUOM strSampleUOMS,    
		S2.dblRepresentingQty dblRepresentingQtyS,    
		S2.strItemNo strItemNoS,    
		S2.strDescription strDescriptionS,
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
		OUTER APPLY(
			SELECT strEntityName,dblNetWeight,strNetWeightUOM ,strFreightTerm ,strINCOLocation,intContractStatusId,intContractHeaderId 
			FROM vyuCTContractDetailView
			WHERE intContractDetailId = S2.intContractDetailId  
			AND intContractStatusId NOT IN( 3, 5, 6 )   
			AND intContractTypeId =2
		)V2 
		
		WHERE --A.intSContractDetailId = S2.intContractDetailId    
		S2.strContractType = 'Sale' and
		S2.intRelatedSampleId = S1.intSampleId
	
	)V
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
		WHERE  intPContractDetailId = S1.intContractDetailId    
	)A
      
    WHERE S1.strContractType='Purchase' --and A.intPContractDetailId = S1.intContractDetailId
	

