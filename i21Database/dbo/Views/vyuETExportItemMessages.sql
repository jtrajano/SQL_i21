CREATE VIEW [dbo].[vyuETExportItemMessages]
AS 

WITH ItemCrossMessages (intItemId, strItemNo, ItemMessageLineNo, ItemMessage)  
AS  
(  
	SELECT 
	I.intItemId
	,I.strItemNo 
	,ROW_NUMBER() OVER ( PARTITION BY intItemId ORDER BY intItemId) AS ItemMessageLineNo
	,LTRIM(RTRIM(ISNULL(ItemMsgs.Item,''))) ItemMessage
	FROM tblICItem I
	CROSS APPLY dbo.[fnSplitString](I.strInvoiceComments,CHAR(10)) ItemMsgs
	WHERE LTRIM(RTRIM(ISNULL(ItemMsgs.Item,'')))  <> ''
)  

SELECT 
	tblICItem.intItemId
	,imsgno = tblICItem.strItemNo
	,imsg1 = (SELECT TOP 1 SUBSTRING(ItemMessage,1, 60) FROM ItemCrossMessages WHERE ItemMessageLineNo = 1)
	,imsg2 = (SELECT TOP 1 SUBSTRING(ItemMessage,1, 60) FROM ItemCrossMessages WHERE ItemMessageLineNo = 2)
	,imsg3 = (SELECT TOP 1 SUBSTRING(ItemMessage,1, 60) FROM ItemCrossMessages WHERE ItemMessageLineNo = 3)
	,iamsgno = 0
FROM tblICItem
WHERE REPLACE(LTRIM(RTRIM(ISNULL(strInvoiceComments,''))),CHAR(10),'') <> ''