CREATE FUNCTION [dbo].[fnGetDaysInMonth]
(
	@TransactionDate	DATETIME
)
RETURNS INT
AS
BEGIN

DECLARE @Year	INT
		,@Month	INT

select	@Year 	= DATEPART(YEAR, @TransactionDate)
		,@Month	= DATEPART(MONTH, @TransactionDate)

RETURN (SELECT	datediff(day, 
		dateadd(day, 0, dateadd(month, ((@Year - 1900) * 12) + @Month - 1, 0)),
		dateadd(day, 0, dateadd(month, ((@Year - 1900) * 12) + @Month, 0))
		))
END
