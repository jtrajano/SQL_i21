CREATE VIEW [dbo].[vyuQMSampleEntryView]
AS
Select 
S.strSampleNumber
,S.strSampleRefNo
,ST.strSampleTypeName
,CH.strContractNumber AS strContract
,CY.strCommodityCode
,CY.strDescription AS strCommodityDescription
,CH.strCustomerContract
,IC.strContractItemName
,S.intItemBundleId
,I1.strItemNo
,I1.strDescription
,CD.strItemSpecification
,S.strCountry
,S.strContainerNumber
,SH.strLoadNumber
,SS.strStatus
,CASE WHEN S.dtmSampleReceivedDate = CAST('1900-01-01' AS DATE) THEN NULL ELSE S.dtmSampleReceivedDate END  AS dtmSampleReceivedDate
,B.strBook
,SB.strSubBook
,S.strSampleNote
,S.strComment
,E.strName AS strPartyName
,S.strRefNo
,S.strSamplingMethod
,S.dtmTestedOn
,U.strName AS strTestedUserName
,S.dblSampleQty
,UM.strUnitMeasure AS strSampleUOM
,S.dblRepresentingQty
,UM1.strUnitMeasure AS strRepresentingUOM
,S.strMarks
,S.dtmTestingStartDate
,S.dtmTestingEndDate
,S.dtmSamplingEndDate
,CL.strLocationName
,CS.strSubLocationName
,SL.strName AS strStorageLocationName
,S.strCourier
,S.strCourierRef
,E1.strName AS strForwardingAgentName
,S.strForwardingAgentRef as strCourierSentDate
,S.strSentBy
,CASE 
	WHEN S.strSentBy = 'Self'
		THEN CL1.strLocationName
	ELSE E2.strName
	END AS strSentByValue
FROM dbo.tblQMSample S
JOIN dbo.tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
	AND S.ysnIsContractCompleted <> 1
JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN dbo.tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN dbo.tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN dbo.tblLGLoad SH ON SH.intLoadId = S.intLoadId
LEFT JOIN tblICCommodity CY ON CY.intCommodityId = ISNULL(CH.intCommodityId, I1.intCommodityId)
LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
LEFT JOIN tblCTSubBook SB ON SB.intSubBookId = S.intSubBookId
LEFT JOIN dbo.tblEMEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblEMEntity U ON U.intEntityId = S.intTestedById
LEFT JOIN dbo.tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblEMEntity E1 ON E1.intEntityId = S.intForwardingAgentId
LEFT JOIN tblEMEntity E2 ON E2.intEntityId = S.intSentById
LEFT JOIN tblSMCompanyLocation CL1 ON CL1.intCompanyLocationId = S.intSentById
LEFT JOIN tblSMCompanyLocation AS CompanyLocation ON S.intCompanyId = CompanyLocation.intCompanyLocationId
