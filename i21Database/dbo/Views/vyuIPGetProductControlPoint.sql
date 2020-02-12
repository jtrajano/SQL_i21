CREATE VIEW vyuIPGetProductControlPoint
AS
SELECT PC.intProductControlPointId
	,PC.intConcurrencyId
	,PC.intProductId
	,PC.intControlPointId
	,PC.intSampleTypeId
	,PC.intCreatedUserId
	,PC.dtmCreated
	,PC.intLastModifiedUserId
	,PC.dtmLastModified
	,PC.intProductControlPointRefId
	,ST.strSampleTypeName
	,CP.strControlPointName
FROM tblQMProductControlPoint PC
LEFT JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId
LEFT JOIN tblQMControlPoint CP ON CP.intControlPointId = ST.intControlPointId
