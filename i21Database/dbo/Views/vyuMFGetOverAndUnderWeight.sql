CREATE VIEW vyuMFGetOverAndUnderWeight
AS
SELECT RTRIM(CONVERT(CHAR, W.dtmPlannedDate, 101)) COLLATE Latin1_General_CI_AS AS [Production Date]
	 , I.strItemNo						AS Item
	 , I.strDescription					AS Description
	 , W.strWorkOrderNo					AS [Work Order #]
	 , W.strReferenceNo					AS [Job #]
	 , LEFT(WP.strParentLotNumber, 5)	AS [Production Lot]
	 , ISNULL(SUM(WP.dblPhysicalCount * I.intInnerUnits), 0) AS [Good produced Pouches]
	 , ISNULL((SELECT SUM(CONVERT(DECIMAL(24, 10), REPLACE(TR.strPropertyValue, ',', '')))
			   FROM dbo.tblQMTestResult TR
			   JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			   WHERE P.strPropertyName = 'Number of bags that pass' AND TR.intProductTypeId = 12 AND TR.intProductValueId = W.intWorkOrderId AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) AS [Total Pouches passed through counter]
	 , ISNULL((SELECT SUM(CONVERT(DECIMAL(24, 10), REPLACE(TR.strPropertyValue, ',', '')))
			   FROM dbo.tblQMTestResult TR
			   JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			   WHERE P.strPropertyName = 'Record underweight units' AND TR.intProductTypeId = 12 AND TR.intProductValueId = W.intWorkOrderId AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) AS [Underweight Pouches]
	 , ISNULL((SELECT SUM(CONVERT(DECIMAL(24, 10), REPLACE(TR.strPropertyValue, ',', '')))
			   FROM dbo.tblQMTestResult TR
			   JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			   WHERE P.strPropertyName = 'Record over-weight units' AND TR.intProductTypeId = 12 AND TR.intProductValueId = W.intWorkOrderId AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) AS [Overweight Pouches]
	 , ISNULL((SELECT SUM(CONVERT(DECIMAL(24, 10), REPLACE(TR.strPropertyValue, ',', '')))
			   FROM dbo.tblQMTestResult TR
			   JOIN dbo.tblQMProperty P ON P.intPropertyId = TR.intPropertyId
			   WHERE P.strPropertyName = 'Sweeps in lbs' AND TR.intProductTypeId = 12 AND TR.intProductValueId = W.intWorkOrderId AND ISNUMERIC(TR.strPropertyValue) = 1
			), 0) [Total sweeps (lb)]
	 , W.intWorkOrderId
 	 , RTRIM(CONVERT(CHAR, W.dtmPlannedDate, 23)) COLLATE Latin1_General_CI_AS AS dtmPlannedDate
	 , W.intLocationId			
	 , CompanyLocation.strLocationName
	 , Category.strCategoryCode
	 , Category.strDescription
FROM dbo.tblMFWorkOrder W
JOIN dbo.tblMFWorkOrderProducedLot WP ON WP.intWorkOrderId = W.intWorkOrderId AND W.intStatusId = 13
JOIN dbo.tblICItem I ON I.intItemId = W.intItemId
JOIN dbo.tblICLot L ON L.intLotId = WP.intLotId
JOIN dbo.tblICParentLot PL ON PL.intParentLotId = L.intParentLotId
JOIN dbo.tblICItemUOM IIU ON IIU.intItemUOMId = WP.intPhysicalItemUOMId
JOIN dbo.tblSMCompanyLocation AS CompanyLocation ON W.intLocationId = CompanyLocation.intCompanyLocationId
JOIN dbo.tblICCategory AS Category ON I.intCategoryId = Category.intCategoryId
WHERE WP.ysnProductionReversed = 0
GROUP BY W.dtmPlannedDate
	   , W.intItemId
	   , I.strItemNo
	   , I.strDescription
	   , W.strWorkOrderNo
	   , W.strReferenceNo
	   , LEFT(WP.strParentLotNumber, 5)
	   , W.intWorkOrderId
	   , W.intLocationId			
	   , CompanyLocation.strLocationName
	   , Category.strCategoryCode
	   , Category.strDescription
