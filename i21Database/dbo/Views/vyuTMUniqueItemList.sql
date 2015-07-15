CREATE VIEW [dbo].[vyuTMUniqueItemList]  
AS  
SELECT DISTINCT 
	intItemId
	,strItemNo
	,strDescription
FROM tblICItem
WHERE ysnAvailableTM = 1
	AND EXISTS(SELECT TOP 1 1 FROM tblICItemLocation WHERE intItemId = tblICItem.intItemId)