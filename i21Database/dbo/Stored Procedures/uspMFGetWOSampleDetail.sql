CREATE PROCEDURE uspMFGetWOSampleDetail @intWorkOrderId INT
AS
BEGIN
	SELECT S.intSampleId
		,S.strSampleNumber
		,ST.strSampleTypeName
		,SS.strStatus AS strSampleStatus
		,I.strItemNo
		,I.strDescription
		,S.dtmSampleReceivedDate
		,S.strSampleNote
		,S.strComment
		,E.strName AS strPartyName
		,S.dblSampleQty
		,UM.strUnitMeasure AS strSampleUOM
		,S.dblRepresentingQty
		,UM1.strUnitMeasure AS strRepresentingUOM
		,S.dtmTestingStartDate
		,S.dtmTestingEndDate
		,S.dtmSamplingEndDate
	FROM tblQMSample S
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = S.intSampleTypeId
		AND S.intProductTypeId = 12
		AND S.intProductValueId = @intWorkOrderId
	JOIN tblQMSampleStatus SS ON SS.intSampleStatusId = S.intSampleStatusId
	LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
	LEFT JOIN tblEMEntity E ON E.intEntityId = S.intEntityId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = S.intSampleUOMId
	LEFT JOIN tblICUnitMeasure UM1 ON UM1.intUnitMeasureId = S.intRepresentingUOMId
	ORDER BY S.intSampleId DESC
END
