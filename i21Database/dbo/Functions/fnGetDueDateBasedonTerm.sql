CREATE FUNCTION [dbo].[fnGetDueDateBasedOnTerm]
(
	@TransactionDate		datetime
	,@TermId				int
)
RETURNS datetime
AS
BEGIN

DECLARE @Type nvarchar(100)
DECLARE @BalanceDue int, @DayMonthDue int, @DueNextMonth int
DECLARE @DueDate datetime

SELECT 
	@Type = strType 
	,@BalanceDue = ISNULL(intBalanceDue, 0)
	,@DayMonthDue = ISNULL(intDayofMonthDue, 0)
	,@DueNextMonth = ISNULL(intDueNextMonth, 0)
	,@DueDate = ISNULL(dtmDueDate, @TransactionDate) 
FROM
	tblSMTerm
WHERE
	intTermID = @TermId


IF (@Type = 'Standard')
	BEGIN
		RETURN DATEADD(DAY, @BalanceDue, @TransactionDate);
	END	
ELSE IF (@Type = 'Date Driven')
	BEGIN
		DECLARE @TransactionMonth int, @TransactionDay int, @TransactionYear int
		SELECT @TransactionMonth = DATEPART(MONTH,@TransactionDate), @TransactionDay = DATEPART(DAY,@TransactionDate) ,@TransactionYear = DATEPART(YEAR,@TransactionDate)
		
		DECLARE @TempDueDate datetime
		Set @TempDueDate = CONVERT(datetime, (CAST(@TransactionMonth AS nvarchar(10)) + '/' + CAST(@DayMonthDue AS nvarchar(10)) + '/' + CAST(@TransactionYear AS nvarchar(10))), 101)
			
		IF (DATEDIFF(DAY,@TransactionDate,@TempDueDate) < @DueNextMonth)
			RETURN DATEADD(MONTH, 0, @TempDueDate);
		ELSE	
			RETURN DATEADD(MONTH, 1, @TempDueDate);
		
	END	
ELSE
	BEGIN
		RETURN ISNULL(@DueDate, @TransactionDate);
	END	

RETURN @TransactionDate;

END
