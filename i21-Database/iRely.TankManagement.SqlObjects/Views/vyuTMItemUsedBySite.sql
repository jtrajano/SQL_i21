
--CHECK ALSO the recreate SP
CREATE VIEW [dbo].[vyuTMItemUsedBySite]  
AS 

SELECT DISTINCT
	A.strItemNo
	,A.intItemId
	,A.strDescription
	,intConcurrencyId = 0
FROM tblICItem A
INNER JOIN tblTMSite B
	ON A.intItemId = B.intProduct
		
GO