﻿CREATE VIEW vyuQMSampleList
AS
SELECT S.intSampleId
	,S.strSampleNumber
	,ST.strSampleTypeName
	,CH.strContractNumber
	,IC.strContractItemName
	,I1.strItemNo AS strBundleItemNo
	,I.strItemNo
	,I.strDescription
	--,C.strContainerNumber
	,S.strContainerNumber
	,SH.intTrackingNumber
	,S.strLotNumber
	,SS.strStatus
	,S.dtmSampleReceivedDate
	,S.strSampleNote
	,E.strName AS strPartyName
	,S.strRefNo
	,S.strSamplingMethod
	,S.dtmTestedOn
	,U.strUserName AS strTestedUserName
	,LS.strSecondaryStatus AS strLotStatus
	,S.strCountry
	,S.dblSampleQty
	,UM.strUnitMeasure AS strSampleUOM
	,S.dblRepresentingQty
	,UM1.strUnitMeasure AS strRepresentingUOM
	,S.strMarks
	,CS.strSubLocationName
	,S.dtmTestingStartDate
	,S.dtmTestingEndDate
	,S.dtmSamplingEndDate
	,S.intContractDetailId
	,ST.intSampleTypeId
	,CH.intContractHeaderId
	,I.intItemId
	,SH.intShipmentId
	,ISNULL(L.intLotId, (SELECT TOP 1 intLotId FROM tblICLot WHERE intParentLotId = PL.intParentLotId)) AS intLotId
	,S.intSampleUOMId
	,S.intRepresentingUOMId
FROM dbo.tblQMSample S
JOIN dbo.tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId AND S.ysnIsContractCompleted <> 1
JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = S.intContractHeaderId
LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN dbo.tblICItem I1 ON I1.intItemId = S.intItemBundleId
LEFT JOIN dbo.tblLGShipmentBLContainer C ON C.intShipmentBLContainerId = S.intShipmentBLContainerId
LEFT JOIN dbo.tblLGShipment SH ON SH.intShipmentId = S.intShipmentId
LEFT JOIN dbo.tblSMUserSecurity U ON U.[intEntityUserSecurityId] = S.intTestedById
LEFT JOIN dbo.tblEntity E ON E.intEntityId = S.intEntityId
LEFT JOIN dbo.tblICLot L ON L.intLotId = S.intProductValueId AND S.intProductTypeId = 6
LEFT JOIN dbo.tblICParentLot PL ON PL.intParentLotId = S.intProductValueId AND S.intProductTypeId = 11
LEFT JOIN dbo.tblICLotStatus LS ON LS.intLotStatusId = S.intLotStatusId
LEFT JOIN dbo.tblSMCompanyLocationSubLocation CS ON CS.intCompanyLocationSubLocationId = S.intCompanyLocationSubLocationId
LEFT JOIN dbo.tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intSampleUOMId
LEFT JOIN dbo.tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
