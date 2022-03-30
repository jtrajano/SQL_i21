CREATE VIEW vyuQMAllocation
AS

WITH QUERY AS(
SELECT 

A.intPContractDetailId 
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
FROM vyuLGLoadDetailView A
join vyuQMSampleList  B
on B.intContractDetailId = intPContractDetailId
join vyuCTGridContractHeader C on C.intContractHeaderId = intPContractHeaderId
join vyuCTContractDetailView D on D.intContractDetailId = B.intContractDetailId

UNION

SELECT 
distinct
A.intPContractDetailId 
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
FROM vyuLGLoadDetailView A
join vyuQMSampleList  B
on B.intContractDetailId = intSContractDetailId
join vyuCTGridContractHeader C on C.intContractHeaderId = intSContractDetailId
join vyuCTContractDetailView D on D.intContractDetailId = B.intContractDetailId

)
SELECT DISTINCT * FROM QUERY