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
DECLARE @MaxDaysInMonth int

SELECT 
	@Type = strType 
	,@BalanceDue = ISNULL(intBalanceDue, 0)
	,@DayMonthDue = ISNULL(intDayofMonthDue, 0)
	,@DueNextMonth = ISNULL(intDueNextMonth, 0)
	,@DueDate = ISNULL(dtmDueDate, @TransactionDate)
	,@MaxDaysInMonth = DATEDIFF(DAY, DATEADD(DAY, 1-DAY(@TransactionDate), @TransactionDate), DATEADD(MONTH, 1, DATEADD(DAY, 1-DAY(@TransactionDate), @TransactionDate)))
FROM
	tblSMTerm
WHERE
	intTermID = @TermId

IF (@MaxDaysInMonth < @DayMonthDue)
	SET @DayMonthDue = @MaxDaysInMonth

IF (@Type = 'Standard')
	BEGIN
		RETURN DATEADD(DAY, @BalanceDue, @TransactionDate);
	END	
ELSE IF (@Type = 'Date Driven')
	BEGIN

	DECLARE @daysOfMonth		INT
            ,@daysOfDueMonth	INT
            ,@dayDueMonthDiff	INT
            ,@dayOfDueMonth		INT
            ,@maxDayOfMonth		INT
            ,@currentDueDate	DATE

            --get the actual number of days in current month
			SELECT @daysOfMonth = [dbo].[fnGetDaysInMonth](@TransactionDate)

            --set the day of due if it was more than a day available for first due date
            IF(@daysOfMonth < @DayMonthDue)
				SET @DayMonthDue = @daysOfMonth

            SET @currentDueDate = DATEADD(DAY, -DATEPART(DAY,@TransactionDate), @TransactionDate)
            SET @currentDueDate = DATEADD(DAY, @DayMonthDue, @currentDueDate)
            SET @maxDayOfMonth = @DayMonthDue - @DueNextMonth

            if(DATEPART(DAY,@TransactionDate) < @maxDayOfMonth)
				RETURN @currentDueDate;
            ELSE
				BEGIN
					SET @DueDate = DATEADD(MONTH, 1, @currentDueDate);

					--get the actual number of days in due month
					SET @daysOfDueMonth = [dbo].[fnGetDaysInMonth](@DueDate);

					--get the actual day of the due month
					SET @dayOfDueMonth = DATEPART(DAY,@DueDate)

					--get the original due day
					if (@daysOfDueMonth > @DayMonthDue)
						SET @DayMonthDue = @dayOfDueMonth

					--current due month must have equal number days of every n of the month
					IF(@dayOfDueMonth <> @daysOfDueMonth AND @dayOfDueMonth <> @DayMonthDue)
					BEGIN
						SET @dayDueMonthDiff = @daysOfDueMonth - @dayOfDueMonth
						SET @DueDate = DATEADD(DAY, @dayOfDueMonth, @DueDate)
						RETURN @DueDate;
					END

					RETURN @DueDate;
				END		
	END
ELSE
	BEGIN
		RETURN ISNULL(@DueDate, @TransactionDate);
	END	

RETURN @TransactionDate;

END
