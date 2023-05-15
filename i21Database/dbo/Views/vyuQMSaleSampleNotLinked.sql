 CREATE VIEW vyuQMSaleSampleNotLinked
 AS
 SELECT  
	A.*,
    null intSampleIdP,    
    NULL dblSampleQtyP,    
    '' COLLATE Latin1_General_CI_AS strSampleUOMP,   
    NULL dblRepresentingQtyP,    
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
	NULL dtmStartDateP, --con   
	NULL dtmEndDateP, --c
	NULL intSequenceP, --c    
	NULL intContractDetailIdP,    --c
	'' COLLATE Latin1_General_CI_AS strContractNumberP,    --
	'' COLLATE Latin1_General_CI_AS strEntityNameP,
	NULL dblNetWeightP,
	'' COLLATE Latin1_General_CI_AS strNetWeightUOMP,
	'' COLLATE Latin1_General_CI_AS strFreightTermP,
	'' COLLATE Latin1_General_CI_AS strINCOLocationP,
	NULL intContractStatusIdP,
	NULL intContractHeaderIdP,
	S1.intSampleId intSampleIdS,    
	S1.dblSampleQty dblSampleQtyS,    
	S1.strSampleUOM strSampleUOMS,    
	S1.dblRepresentingQty dblRepresentingQtyS,    
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
	V1.*
    FROM vyuQMSampleList S1   
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
		intContractHeaderId intContractHeaderIdS,
		intContractTypeId intContractTypeIdS
        FROM vyuCTContractDetailView
		WHERE intContractDetailId = S1.intContractDetailId    
		AND intContractStatusId NOT IN( 3, 5, 6 )   
		AND intContractTypeId = 2
	)V1
	
	OUTER APPLY(
		SELECT 
		sum(dblSAllocatedQty)dblSAllocatedQty,    --a
		sum(dblPAllocatedQty) dblPAllocatedQty --a
		FROM  vyuLGAllocatedContracts 
		WHERE  intSContractDetailId = S1.intContractDetailId       
		group by intSContractDetailId
	)A
      
    WHERE
	ISNULL(S1.intRelatedSampleId,0) = 0
	and V1.intContractTypeIdS = 2	

