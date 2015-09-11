CREATE VIEW [dbo].[vyuTMLeaseCode]  
AS 

SELECT
	A.*
	,strItemNumber = B.strItemNo
	,strItemDescription = B.strDescription
FROM dbo.tblTMLeaseCode A
LEFT JOIN tblICItem B
	ON A.intItemId = B.intItemId
		
GO