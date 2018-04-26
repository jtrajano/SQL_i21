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

		DECLARE @InvoiceDate	INT,
				@DaysInDueMonth	INT,
				@DueDateTemp	DATE,
				@MToAdd			INT = 1

        SET @InvoiceDate = DAY(@TransactionDate)
        IF @InvoiceDate > @DueNextMonth
            SET @MToAdd = 2

        SET @DueDateTemp = DATEADD(MONTH, @MToAdd, @TransactionDate)
        SET @DaysInDueMonth = [dbo].[fnGetDaysInMonth](@DueDateTemp)

        IF @DayMonthDue > @DaysInDueMonth
            SET @DayMonthDue = @DaysInDueMonth;

				
        RETURN CAST((CAST(YEAR(@DueDateTemp) AS NVARCHAR(10)) + '-' + CAST(MONTH(@DueDateTemp) AS NVARCHAR(10)) + '-' + CAST(@DayMonthDue AS NVARCHAR(10))) AS DATE)
 
	END
ELSE
	BEGIN
		RETURN ISNULL(@DueDate, @TransactionDate);		 
	END	

RETURN @TransactionDate;

END

