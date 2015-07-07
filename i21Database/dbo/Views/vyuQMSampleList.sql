CREATE VIEW vyuQMSampleList
AS
SELECT S.intSampleId
	,S.strSampleNumber
	,ST.strSampleTypeName
	,CH.intContractNumber
	,IC.strContractItemName
	,I.strItemNo
	,I.strDescription
	,C.strContainerNumber
	,SH.intTrackingNumber
	,S.strLotNumber
	,S.strSampleNote
	,SS.strStatus
	,S.dtmSampleReceivedDate
	,S.dtmTestedOn
	,U.strUserName AS strTestedUserName
	,E.strName AS strPartyName
FROM dbo.tblQMSample S
JOIN dbo.tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId AND S.ysnIsContractCompleted <> 1
JOIN dbo.tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
LEFT JOIN dbo.tblCTContractHeader CH ON CH.intContractHeaderId = S.intContractHeaderId
LEFT JOIN dbo.tblICItemContract IC ON IC.intItemContractId = S.intItemContractId
LEFT JOIN dbo.tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN dbo.tblLGShipmentBLContainer C ON C.intShipmentBLContainerId = S.intShipmentBLContainerId
LEFT JOIN dbo.tblLGShipment SH ON SH.intShipmentId = S.intShipmentId
LEFT JOIN dbo.tblSMUserSecurity U ON U.intUserSecurityID = S.intTestedById
LEFT JOIN dbo.tblEntity E ON E.intEntityId = S.intEntityId
