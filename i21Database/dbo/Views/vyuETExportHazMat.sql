CREATE VIEW [dbo].[vyuETExportHazMat]    
AS    

WITH HazMatMessages (intTagId, strTagNumber, ItemMessageLineNo, ItemMessage)  
AS  
(  
	SELECT 
	I.intTagId
	,I.strTagNumber 
	,ROW_NUMBER() OVER ( PARTITION BY strTagNumber ORDER BY strTagNumber) AS ItemMessageLineNo
	,LTRIM(RTRIM(ISNULL(HazMatMsgs.Item,''))) ItemMessage
	FROM tblICTag I
	CROSS APPLY dbo.[fnSplitString](I.strMessage,CHAR(10)) HazMatMsgs
	WHERE LTRIM(RTRIM(ISNULL(HazMatMsgs.Item,'')))  <> ''
	AND strType = 'Hazmat Message'
)  

SELECT 
	tblICTag.intTagId
	,epa_group = tblICTag.intTagId
	,msg1 = ISNULL((SELECT TOP 1 SUBSTRING(ItemMessage,1, 40) FROM HazMatMessages WHERE ItemMessageLineNo = 1 AND strTagNumber = tblICTag.strTagNumber),'')
	,msg2 = ISNULL((SELECT TOP 1 SUBSTRING(ItemMessage,1, 40) FROM HazMatMessages WHERE ItemMessageLineNo = 2 AND strTagNumber = tblICTag.strTagNumber),'')
FROM tblICTag
WHERE REPLACE(LTRIM(RTRIM(ISNULL(strMessage,''))),CHAR(10),'') <> ''
AND strType = 'Hazmat Message'