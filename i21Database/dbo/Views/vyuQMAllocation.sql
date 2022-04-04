/*
- FOR VIEWING RELATED SAMPLE
- EXCLUDES CONTRACT WITH STATUS SHORT CLOSE, COMPLETED, CANCELLED
*/
CREATE VIEW vyuQMAllocation
AS
SELECT DISTINCT --A.intPContractDetailId,
		  D.intContractDetailId intContractDetailIdP,
                B.intSampleId,
                D.intContractHeaderId intContractHeaderIdP,
                D.strContractNumber strContractNumberP,
		  D.intContractSeq intSequenceP,
                D.strEntityName strEntityNameP,
                B.dblSampleQty dblSampleQtyP,
                B.strSampleUOM strSampleUOMP,
                D.dblNetWeight dblNetWeightP,
                D.strNetWeightUOM strNetWeightUOMP,
                B.dblRepresentingQty dblRepresentingQtyP,
                B.strItemNo strItemNoP,
                B.strSampleNumber strSampleNumberP,
                B.strGrade strSampleTypeP,
                B.strSamplingCriteria strSamplingCriteriaP,
                B.dtmSamplingEndDate dtmSamplingEndDateP,
                B.dtmRequestedDate dtmRequestedDateP,
                B.dtmSampleSentDate dtmSampleSentDateP,
                B.strCourier strCourierP,
                B.dtmSampleReceivedDate dtmSampleReceivedDateP,
                B.strStatus strStatusP,
                B.strLotNumber strLotNumberP,
                C.strFreightTerm strFreightTermP,
                C.strINCOLocation strINCOLocationP,
                D.dtmStartDate dtmStartDateP,
                D.dtmEndDate dtmEndDateP,
                SalesContract.*
FROM   vyuQMSampleList B -- PURCHASE SAMPLES CAN HAVE NO PURCHASE CONTRACT
       LEFT JOIN vyuLGAllocationDetails A
              ON B.intContractDetailId = intPContractDetailId
       LEFT JOIN vyuCTGridContractHeader C
              ON C.intContractHeaderId = intPContractHeaderId
       LEFT JOIN vyuCTContractDetailView D
              ON D.intContractDetailId = B.intContractDetailId
       LEFT JOIN tblLGAllocationDetail E
              ON E.intPContractDetailId = B.intContractDetailId
       OUTER APPLY(SELECT
                  DD.intContractDetailId intContractDetailIdS,
                  DD.intContractHeaderId intContractHeaderIdS,
		    DD.strContractNumber strContractNumberS,
                  DD.intContractSeq  intSequenceS,
                  DD.strEntityName strEntityNameS,
                  BB.dblSampleQty dblSampleQtyS,
                  BB.strSampleUOM strSampleUOMS,
                  DD.dblNetWeight dblNetWeightS,
                  DD.strNetWeightUOM strNetWeightUOMS,
                  BB.dblRepresentingQty dblRepresentingQtyS,
                  BB.strSampleNumber strSampleNumberS,
                  BB.strGrade strSampleTypeS,
                  CC.strFreightTerm strFreightTermS,
                  CC.strINCOLocation strINCOLocationS,
                  DD.dtmStartDate dtmStartDateS,
                  DD.dtmEndDate dtmEndDateS,
                  BB.strSamplingCriteria strSamplingCriteriaS,
                  BB.dtmSamplingEndDate dtmSamplingEndDateS, 
                  BB.dtmSampleSentDate dtmSampleSentDateS,
                  BB.strCourier strCourierS,
                  BB.dtmSampleReceivedDate dtmSampleReceivedDateS,
                  BB.strStatus strStatusS,
                  BB.strLotNumber strLotNumberS	  
                  FROM   --vyuLGLoadDetailView A
                  vyuLGAllocationDetails AA -- SALES CONTRACT CAN HAVE NO SAMPLES
                  LEFT JOIN vyuQMSampleList BB
                         ON BB.intContractDetailId = AA.intSContractDetailId
                  LEFT JOIN vyuCTGridContractHeader CC
                         ON CC.intContractHeaderId = intSContractHeaderId
                  LEFT JOIN vyuCTContractDetailView DD
                         ON DD.intContractDetailId = BB.intContractDetailId
                  LEFT JOIN tblLGAllocationDetail EE
                         ON EE.intSContractDetailId = BB.intContractDetailId
                   WHERE   AA.intPContractDetailId = D.intContractDetailId
                          AND intContractStatusId NOT IN( 3, 5, 6 ))
                  SalesContract
WHERE  intContractStatusId NOT IN( 3, 5, 6 )