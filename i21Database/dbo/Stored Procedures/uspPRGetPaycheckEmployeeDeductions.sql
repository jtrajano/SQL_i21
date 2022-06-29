CREATE PROCEDURE [dbo].[uspPRGetPaycheckEmployeeDeductions]
	@intPaycheckId INT
	,@intYear INT	
	,@intEmployeeId INT
AS
BEGIN
	IF(NULLIF(@intPaycheckId,0) IS NOT NULL)
		BEGIN
			SELECT YEAR (vyuPRPaycheckDeduction.dtmPayDate) intYear,
				DATEPART (QQ, vyuPRPaycheckDeduction.dtmPayDate)
				intQuarter, 
				vyuPRPaycheckDeduction.intPaycheckId,
				vyuPRPaycheckDeduction.intPaycheckDeductionId,
				vyuPRPaycheckDeduction.strDeduction,
				vyuPRPaycheckDeduction.dblTotal,
				vyuPRPaycheckDeduction.dblTotalYTD,
				vyuPRPaycheckDeduction.strPaidBy,
				vyuPRPaycheckDeduction.strDeductFrom,
				vyuPRPaycheckDeduction.strDescription,
				vyuPRPaycheckDeduction.intEntityEmployeeId
      
			FROM vyuPRPaycheckDeduction
			WHERE vyuPRPaycheckDeduction.ysnVoid = 0
		END
	ELSE
		BEGIN
			SELECT YEAR (vyuPRPaycheckDeduction.dtmPayDate) intYear,
				DATEPART (QQ, vyuPRPaycheckDeduction.dtmPayDate)
				intQuarter, 
				vyuPRPaycheckDeduction.intPaycheckId,
				vyuPRPaycheckDeduction.intPaycheckDeductionId,
				vyuPRPaycheckDeduction.strDeduction,
				vyuPRPaycheckDeduction.dblTotal,
				vyuPRPaycheckDeduction.dblTotalYTD,
				vyuPRPaycheckDeduction.strPaidBy,
				vyuPRPaycheckDeduction.strDeductFrom,
				vyuPRPaycheckDeduction.strDescription,
				vyuPRPaycheckDeduction.intEntityEmployeeId
      
			FROM vyuPRPaycheckDeduction
			WHERE vyuPRPaycheckDeduction.ysnVoid = 0
			AND (@intYear IS NULL OR YEAR (vyuPRPaycheckDeduction.dtmPayDate) = @intYear )
			AND (@intEmployeeId IS NULL OR vyuPRPaycheckDeduction.intEntityEmployeeId = @intEmployeeId )
		END
 END
 
 GO