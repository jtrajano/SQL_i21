--///Check on recreate

CREATE VIEW [dbo].[vyuTMBudgetCalculationProjection]  
AS 

SELECT
	A.*
	,strClockName = B.strClockNumber
FROM dbo.tblTMBudgetCalculationProjection A
INNER JOIN tblTMClock B
	ON A.intClockId = B.intClockID
		
GO