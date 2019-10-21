
CREATE VIEW [dbo].[vyuICGetRetailCategoryCount]
AS
SELECT 
intId = CAST(ROW_NUMBER() OVER(ORDER BY tblICCategory.intCategoryId ASC) AS INT)
,tblICCategory.intCategoryId 
,tblICCategory.strCategoryCode
,tblICCategory.strDescription
,tblICCategoryLocation.intLocationId
,dblTargetMargin = tblICCategoryLocation.dblTargetGrossProfit - tblICCategoryLocation.dblTargetInventoryCost
,dblCurrentMargin = vyuICGetRetailValuationByLocation.dblGrossMarginPct
,dblCurrentRetail = vyuICGetRetailValuationByLocation.dblEndingRetail
,dblCurrentCost = vyuICGetRetailValuationByLocation.dblEndingCost
,dtmRetailDate = vyuICGetRetailValuationByLocation.dtmDate
,intUserId
FROM tblICCategory 
INNER JOIN tblICCategoryLocation
ON tblICCategory.intCategoryId = tblICCategoryLocation.intCategoryId
INNER JOIN vyuICGetRetailValuationByLocation 
ON tblICCategory.intCategoryId = vyuICGetRetailValuationByLocation.intCategoryId 
AND tblICCategoryLocation.intLocationId = vyuICGetRetailValuationByLocation.intLocationId
WHERE tblICCategory.ysnRetailValuation = 1
GO


