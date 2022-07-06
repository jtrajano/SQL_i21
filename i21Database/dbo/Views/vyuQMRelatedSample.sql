/*
FOR VIEWING OF ALLOCATION IN THE QUALITY SAMPLE SCREEN
IF THE SALES CONTRACT SELECTED ON A NEW SAMPLE HAS PURCHASE CONTRACT, GET THE SAMPLE ID
- IF MORE THAN ONE, USER WILL MANUALLY CREATE THE SAMPLE
*/

CREATE VIEW vyuQMRelatedSample
AS

SELECT DISTINCT A.intPContractDetailId,
                --B.intRelatedSampleId
                --,strDescription = 'Purchase Contract'
                --,
                --A.intAllocationDetailId
                --,A.strAllocationNumber
                --,A.intSContractDetailId
                --,
                --B.intSampleId,
                C.strContractNumber strContractNumberP,
                intPContractSeq intSequenceP,
                C.strEntityName strEntityNameP,
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
                D.dtmEndDate dtmEndDateP
                --,B.strRepresentingUOM
                --,B.strSamplingMethod
                --,B.dtmSamplingEndDate
                --,C.strLocationName
                --,B.strCourier
                --,C.strGrade 
                --,B.strSampleTypeName
                --,B.strStatus
                ,
                SalesContract.*
FROM   vyuQMSampleList B
       LEFT JOIN vyuLGAllocationDetails A
              ON B.intContractDetailId = intPContractDetailId
       LEFT JOIN vyuCTGridContractHeader C
              ON C.intContractHeaderId = intPContractHeaderId
       LEFT JOIN vyuCTContractDetailView D
              ON D.intContractDetailId = B.intContractDetailId
       LEFT JOIN tblLGAllocationDetail E
              ON E.intPContractDetailId = B.intContractDetailId
       OUTER APPLY(SELECT DISTINCT
                  --,AA.intAllocationDetailId
                  --,AA.strAllocationNumber
                  --,AA.intPContractDetailId 
                  --,BB.intSampleId
                  --AA.intSContractDetailId,
                  CC.strContractNumber strContractNumberS,
                  intPContractSeq  intSequenceS,
                  CC.strEntityName strEntityNameS,
                  BB.dblSampleQty dblSampleQtyS,
                  BB.strSampleUOM strSampleUOMS,
                  DD.dblNetWeight dblNetWeightS,
                  DD.strNetWeightUOM strNetWeightUOMS,
                  BB.dblRepresentingQty dblRepresentingQtyS,
                  BB.strSampleNumber strSampleNumberS,
                  BB.strGrade strSampleTypeS,
                  CC.strFreightTerm strFreightTermS,
                  C.strINCOLocation strINCOLocationS,
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
                  vyuQMSampleList BB
                  LEFT JOIN vyuLGAllocationDetails AA
                         ON BB.intContractDetailId = AA.intSContractDetailId
                  LEFT JOIN vyuCTGridContractHeader CC
                         ON CC.intContractHeaderId = intSContractHeaderId
                  LEFT JOIN vyuCTContractDetailView DD
                         ON DD.intContractDetailId = BB.intContractDetailId
                  LEFT JOIN tblLGAllocationDetail EE
                         ON EE.intSContractDetailId = BB.intContractDetailId
                   WHERE  B.intRelatedSampleId = BB.intSampleId
                          AND intContractStatusId NOT IN( 3, 5, 6 ))
                  SalesContract
WHERE  intContractStatusId NOT IN( 3, 5, 6 ) 
AND B.intRelatedSampleId IS NOT NULL