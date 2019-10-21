CREATE VIEW [dbo].[vyuTMUniqueItemList]  
AS  
SELECT DISTINCT 
	intItemId
	,strItemNo
	,strDescription
	,ysnAvailableTM = CAST(ISNULL(ysnAvailableTM,0) AS BIT)
FROM tblICItem
WHERE EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemId = tblICItem.intItemId)