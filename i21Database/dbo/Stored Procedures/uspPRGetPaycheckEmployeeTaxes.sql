CREATE PROCEDURE [dbo].[uspPRGetPaycheckEmployeeTaxes]
	@intPaycheckId INT
AS
BEGIN

select intPaycheckId,
       strTaxId,
       dblTotal = dblTotal * CASE WHEN
       (ysnVoid = 1) THEN - 1 ELSE 1 END,
       dblTotalYTD,
       strPaidBy
  from 
	[vyuPRPaycheckTax]
	WHERE intPaycheckId = @intPaycheckId AND strPaidBy = 'Employee'

END
GO