CREATE VIEW vyuQMTemplateList
AS
-- Material Type  
SELECT DISTINCT P.intProductId
	,PT.strProductTypeName 'strProductTypeName'
	,IC.strCategoryCode 'strProductValue'
	,IC.strDescription
	,P.intProductValueId
	,(
		Stuff((
				SELECT ',' + strControlPointName
				FROM (
					SELECT PT.strControlPointName
					FROM tblQMProduct AS P1
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P1.intProductId
					JOIN tblQMControlPoint PT ON PT.intControlPointId = PC.intControlPointId
					WHERE P1.intProductId = P.intProductId
					) t
				ORDER BY ',' + strControlPointName
				FOR XML Path('')
				), 1, 1, '')
		) 'strControlPoints'
FROM tblQMProduct P
JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
JOIN tblQMControlPoint CP ON CP.intControlPointId = PC.intControlPointId
JOIN tblQMProductType PT ON PT.intProductTypeId = P.intProductTypeId
JOIN tblICCategory IC ON IC.intCategoryId = P.intProductValueId
WHERE P.intProductTypeId = 1

UNION ALL

-- Material  
SELECT DISTINCT P.intProductId
	,PT.strProductTypeName 'strProductTypeName'
	,II.strItemNo 'strProductValue'
	,II.strDescription
	,P.intProductValueId
	,(
		Stuff((
				SELECT ',' + strControlPointName
				FROM (
					SELECT PT.strControlPointName
					FROM tblQMProduct AS P1
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P1.intProductId
					JOIN tblQMControlPoint PT ON PT.intControlPointId = PC.intControlPointId
					WHERE P1.intProductId = P.intProductId
					) t
				ORDER BY ',' + strControlPointName
				FOR XML Path('')
				), 1, 1, '')
		) 'strControlPoints'
FROM tblQMProduct P
JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
JOIN tblQMControlPoint CP ON CP.intControlPointId = PC.intControlPointId
JOIN tblQMProductType PT ON PT.intProductTypeId = P.intProductTypeId
JOIN tblICItem II ON II.intItemId = P.intProductValueId
	AND II.strStatus = 'Active'
WHERE P.intProductTypeId = 2

UNION ALL

-- Receipt  
SELECT DISTINCT P.intProductId
	,PT.strProductTypeName 'strProductTypeName'
	,'' 'strProductValue' --PT1.strProductTypeName 'strProductValue'
	,'' --PT1.strDescription
	,P.intProductValueId
	,(
		Stuff((
				SELECT ',' + strControlPointName
				FROM (
					SELECT PT.strControlPointName
					FROM tblQMProduct AS P1
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P1.intProductId
					JOIN tblQMControlPoint PT ON PT.intControlPointId = PC.intControlPointId
					WHERE P1.intProductId = P.intProductId
					) t
				ORDER BY ',' + strControlPointName
				FOR XML Path('')
				), 1, 1, '')
		) 'strControlPoints'
FROM tblQMProduct P
JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
JOIN tblQMControlPoint CP ON CP.intControlPointId = PC.intControlPointId
JOIN tblQMProductType PT ON PT.intProductTypeId = P.intProductTypeId
JOIN tblQMProductType PT1 ON PT1.intProductTypeId = PT.intProductTypeId
WHERE P.intProductTypeId = 3

UNION ALL

-- Shipment  
SELECT DISTINCT P.intProductId
	,PT.strProductTypeName 'strProductTypeName'
	,'' 'strProductValue' --PT1.strProductTypeName 'strProductValue'
	,'' --PT1.strDescription
	,P.intProductValueId
	,(
		Stuff((
				SELECT ',' + strControlPointName
				FROM (
					SELECT PT.strControlPointName
					FROM tblQMProduct AS P1
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P1.intProductId
					JOIN tblQMControlPoint PT ON PT.intControlPointId = PC.intControlPointId
					WHERE P1.intProductId = P.intProductId
					) t
				ORDER BY ',' + strControlPointName
				FOR XML Path('')
				), 1, 1, '')
		) 'strControlPoints'
FROM tblQMProduct P
JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
JOIN tblQMControlPoint CP ON CP.intControlPointId = PC.intControlPointId
JOIN tblQMProductType PT ON PT.intProductTypeId = P.intProductTypeId
JOIN tblQMProductType PT1 ON PT1.intProductTypeId = PT.intProductTypeId
WHERE P.intProductTypeId = 4

UNION ALL

-- Transfer  
SELECT DISTINCT P.intProductId
	,PT.strProductTypeName 'strProductTypeName'
	,'' 'strProductValue' --PT1.strProductTypeName 'strProductValue'
	,'' --PT1.strDescription
	,P.intProductValueId
	,(
		Stuff((
				SELECT ',' + strControlPointName
				FROM (
					SELECT PT.strControlPointName
					FROM tblQMProduct AS P1
					JOIN tblQMProductControlPoint PC ON PC.intProductId = P1.intProductId
					JOIN tblQMControlPoint PT ON PT.intControlPointId = PC.intControlPointId
					WHERE P1.intProductId = P.intProductId
					) t
				ORDER BY ',' + strControlPointName
				FOR XML Path('')
				), 1, 1, '')
		) 'strControlPoints'
FROM tblQMProduct P
JOIN tblQMProductControlPoint PC ON PC.intProductId = P.intProductId
JOIN tblQMControlPoint CP ON CP.intControlPointId = PC.intControlPointId
JOIN tblQMProductType PT ON PT.intProductTypeId = P.intProductTypeId
JOIN tblQMProductType PT1 ON PT1.intProductTypeId = PT.intProductTypeId
WHERE P.intProductTypeId = 5
