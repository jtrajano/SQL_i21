CREATE VIEW vyuMFLabelValues
AS
SELECT CAST(ROW_NUMBER() OVER (
			ORDER BY intTypeId
				,ValueMember
			) AS INT) AS intRowNo
	,intTypeId
	,ValueMember
	,DisplayMember
	,strDescription
FROM (
	SELECT DISTINCT 1 AS intTypeId
		,intItemId AS ValueMember
		,strItemNo AS DisplayMember
		,strDescription
	FROM tblICItem
	
	UNION
	
	SELECT DISTINCT 2 AS intTypeId
		,intStorageLocationId AS ValueMember
		,strName AS DisplayMember
		,strDescription
	FROM tblICStorageLocation

	UNION
	
	SELECT DISTINCT 3 AS intTypeId
		,intCompanyLocationSubLocationId AS ValueMember
		,strSubLocationName AS DisplayMember
		,strSubLocationDescription AS strDescription
	FROM tblSMCompanyLocationSubLocation
	) t
