CREATE VIEW vyuQMComponentPropertyMap
AS
SELECT C.intComponentMapId
	,C.strComponent
	,C.intPropertyId
	,P.strPropertyName
FROM tblQMComponentMap C
JOIN tblQMProperty P ON P.intPropertyId = C.intPropertyId
