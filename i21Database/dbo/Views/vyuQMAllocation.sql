/*
FOR VIEWING OF ALLOCATION IN THE QUALITY SAMPLE SCREEN
IF THE SALES CONTRACT SELECTED ON A NEW SAMPLE HAS PURCHASE CONTRACT, GET THE SAMPLE ID
- IF MORE THAN ONE, USER WILL MANUALLY CREATE THE SAMPLE
*/

CREATE VIEW vyuQMAllocation
AS

WITH QUERY AS(
SELECT 
strDescription = 'Purchase Contract'
,A.intAllocationDetailId
,A.strAllocationNumber
,A.intPContractDetailId 
,A.intSContractDetailId
,B.intSampleId
,C.strContractNumber
, intPContractSeq strSequence
, B.strSampleNumber
, B.intItemId
, intPContractHeaderId 
,C.strEntityName strVendor
,B.dblSampleQty
,B.strSampleUOM
,D.dblAllocatedQty
,D.strItemUOM
,D.dblNetWeight
,D.strNetWeightUOM
,B.dblRepresentingQty
,B.strRepresentingUOM
,B.strItemNo
,B.strSamplingMethod
,B.dtmSamplingEndDate
,strSamplingCriteria = ''
,C.strLocationName
,C.strFreightTerm
,C.strINCOLocation
,D.dtmStartDate
,D.dtmEndDate
,dtmRequestedDate
,dtmSampleSentDate
,B.strCourier
--,C.strGrade 
,B.strSampleTypeName
,B.strStatus
,B.dtmSampleReceivedDate
from vyuLGAllocationDetails A
join vyuQMSampleList  B
on B.intContractDetailId = intPContractDetailId
join vyuCTGridContractHeader C on C.intContractHeaderId = intPContractHeaderId
join vyuCTContractDetailView D on D.intContractDetailId = B.intContractDetailId
join tblLGAllocationDetail E on E.intPContractDetailId = B.intContractDetailId

UNION

SELECT 
distinct
strDescription = 'Sales Contract'
,A.intAllocationDetailId
,A.strAllocationNumber
,A.intPContractDetailId 
,A.intSContractDetailId
,B.intSampleId
,C.strContractNumber
, intPContractSeq strSequence
, B.strSampleNumber
, B.intItemId
, intPContractHeaderId 
,C.strEntityName strVendor
,B.dblSampleQty 
,B.strSampleUOM
,D.dblAllocatedQty
,D.strItemUOM
,D.dblNetWeight
,D.strNetWeightUOM
,B.dblRepresentingQty
,B.strRepresentingUOM
,B.strItemNo
,B.strSamplingMethod
,B.dtmSamplingEndDate
,strSamplingCriteria = ''
,C.strLocationName
,C.strFreightTerm
,C.strINCOLocation
,D.dtmStartDate
,D.dtmEndDate
,dtmRequestedDate
,dtmSampleSentDate
,B.strCourier 
--,C.strGrade 
,B.strSampleTypeName
,B.strStatus
,B.dtmSampleReceivedDate

FROM --vyuLGLoadDetailView A
vyuLGAllocationDetails A
join vyuQMSampleList  B
on B.intContractDetailId = A.intSContractDetailId
join vyuCTGridContractHeader C on C.intContractHeaderId = intSContractDetailId
join vyuCTContractDetailView D on D.intContractDetailId = B.intContractDetailId
join tblLGAllocationDetail E on E.intSContractDetailId = B.intContractDetailId

)
SELECT DISTINCT * FROM QUERY

