CREATE VIEW vyuQMSampleTypeUserRole
AS
SELECT S.intSampleTypeId
	,S.strSampleTypeName
	,S.strDescription
	,S.intControlPointId
	,CAST(ROW_NUMBER() OVER (
			ORDER BY S.intSampleTypeId
			) AS INT) AS intRowNo
	,CP.strControlPointName
	,SU.intUserRoleID
	,S.ysnAdjustInventoryQtyBySampleQty
	,S.ysnPartyMandatory
FROM tblQMSampleType S
JOIN tblQMControlPoint CP ON CP.intControlPointId = S.intControlPointId
JOIN tblQMSampleTypeUserRole SU ON SU.intSampleTypeId = S.intSampleTypeId
