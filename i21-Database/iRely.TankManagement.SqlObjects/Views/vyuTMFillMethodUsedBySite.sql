CREATE VIEW [dbo].[vyuTMFillMethodUsedBySite]  
AS 

SELECT DISTINCT
	A.*
FROM tblTMFillMethod A
INNER JOIN tblTMSite B
	ON A.intFillMethodId = B.intFillMethodId
		
GO