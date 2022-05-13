CREATE PROCEDURE [dbo].[uspPRGetPaycheckEmployeeTaxes]
	@intPaycheckId INT
	,@intYear INT	
	,@intEmployeeId INT
AS
BEGIN

	--check if PaycheckId param is Not NUll.. 
	--if so.. consider this is for paycheck middle report's sub report (paycheck tax) . 
	--as of this writing only employee paid is showing in that report

	--ELSE consider for earning register where all is being shown but only those not voided
	IF(NULLIF(@intPaycheckId,0) IS NOT NULL)
		BEGIN

			SELECT intPaycheckId,
				   strTaxId,
				   dblTotal = dblTotal * CASE WHEN (ysnVoid = 1) THEN - 1 ELSE 1 END,
				   dblTotalYTD,
				   strPaidBy,
				   strDescription
			FROM 
				[vyuPRPaycheckTax]
			WHERE (intPaycheckId = @intPaycheckId AND strPaidBy = 'Employee')

		END
	ELSE
		BEGIN
			SELECT intPaycheckId,
				   strTaxId,
				   dblTotal,
				   strDescription
			FROM 
				[vyuPRPaycheckTax]
			WHERE ysnVoid = 0
			AND (@intYear IS NULL OR YEAR ([vyuPRPaycheckTax].dtmPayDate) = @intYear )
			AND (@intEmployeeId IS NULL OR [vyuPRPaycheckTax].intEntityEmployeeId = @intEmployeeId )
		END

END
GO