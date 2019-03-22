
--CHECK ALSO the recreate SP
CREATE VIEW [dbo].[vyuTMClockUsedBySite]  
AS 

SELECT DISTINCT
	A.strClockNumber
	,intClockId = A.intClockID
	,intConcurrencyId = 0
FROM tblTMClock A
INNER JOIN tblTMSite B
	ON A.intClockID = B.intClockID
		
GO