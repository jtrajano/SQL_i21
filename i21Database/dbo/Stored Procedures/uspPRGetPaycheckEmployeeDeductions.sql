CREATE PROCEDURE [dbo].[uspPRGetPaycheckEmployeeDeductions]
@intPaycheckId INT
AS 
BEGIN

 SELECT intPaycheckId,
       intPaycheckDeductionId,
       strDeduction,
       dblTotal = dblTotal * CASE WHEN (ysnVoid = 1) THEN - 1 ELSE 1 END,
       dblTotalYTD,
       strPaidBy,
       strDeductFrom
  FROM vyuPRPaycheckDeduction
  WHERE intPaycheckId = @intPaycheckId
  
END
GO