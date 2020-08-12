CREATE VIEW vyuQMSampleTypeControlPoint
AS
WITH Item
AS (
	SELECT ST.intControlPointId
		,ST.intSampleTypeId
		,ST.strSampleTypeName
		,ST.strDescription
		,PC.intProductId
		,P.intProductTypeId
		,P.intProductValueId
		,P.ysnActive
		,ST.ysnAdjustInventoryQtyBySampleQty
		,ST.ysnPartyMandatory
	FROM tblQMProductControlPoint PC
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId
	JOIN tblQMProduct P ON P.intProductId = PC.intProductId
		AND P.intProductTypeId IN (2, 3, 4)
	)
SELECT CAST(ROW_NUMBER() OVER (
			ORDER BY intProductId
			) AS INT) AS intRowNo
	,*
FROM (
	SELECT *
	FROM Item
	
	UNION ALL
	
	SELECT ST.intControlPointId
		,ST.intSampleTypeId
		,ST.strSampleTypeName
		,ST.strDescription
		,PC.intProductId
		,2 AS intProductTypeId -- Configuring as 2 to not to change client filter
		,I.intItemId AS intProductValueId
		,P.ysnActive
		,ST.ysnAdjustInventoryQtyBySampleQty
		,ST.ysnPartyMandatory
	FROM tblQMProductControlPoint PC
	JOIN tblQMSampleType ST ON ST.intSampleTypeId = PC.intSampleTypeId
	JOIN tblQMProduct P ON P.intProductId = PC.intProductId
	JOIN tblICItem I ON I.intCategoryId = P.intProductValueId
		AND P.intProductTypeId = 1
		AND NOT EXISTS (
			SELECT intSampleTypeId
				,intProductValueId
			FROM Item x
			WHERE x.intSampleTypeId = ST.intSampleTypeId
				AND x.intProductValueId = I.intItemId
			)
	) t
