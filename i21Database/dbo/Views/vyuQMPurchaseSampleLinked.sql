 CREATE VIEW vyuQMPurchaseSampleLinked
 AS
 SELECT  
	A.*,
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
	V1.*,
	V.*
    FROM vyuQMSampleList S1   
	OUTER APPLY(
		SELECT 
		dtmStartDate dtmStartDateP, --con   
		dtmEndDate dtmEndDateP, --c
		intContractSeq intSequenceP, --c    
		intContractDetailId intContractDetailIdP,    --c
		strContractNumber strContractNumberP,    --
		strEntityName strEntityNameP,
		dblNetWeight dblNetWeightP,
		strNetWeightUOM strNetWeightUOMP,
		strFreightTerm strFreightTermP,
		strINCOLocation strINCOLocationP,
		intContractStatusId intContractStatusIdP,
		intContractHeaderId intContractHeaderIdP
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
		V2.*
		FROM vyuQMSampleList S2     
		OUTER APPLY(
			SELECT 
			dtmStartDate dtmStartDateS, --con   
			dtmEndDate dtmEndDateS, --c
			intContractSeq intSequenceS, --c    
			intContractDetailId intContractDetailIdS,    --c
			strContractNumber strContractNumberS,    --
			strEntityName strEntityNameS,
			dblNetWeight dblNetWeightS,
			strNetWeightUOM strNetWeightUOMS,
			strFreightTerm strFreightTermS,
			strINCOLocation strINCOLocationS,
			intContractStatusId intContractStatusIdS,
			intContractHeaderId intContractHeaderIdS
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
		strAllocationNumber,    ---a
		intAllocationDetailId,    --a
		dblSAllocatedQty,    --a
		dblPAllocatedQty --a
		FROM  vyuLGAllocatedContracts 
		WHERE  intPContractDetailId = S1.intContractDetailId    
	)A
    WHERE S1.strContractType='Purchase' --and A.intPContractDetailId = S1.intContractDetailId
	

