CREATE FUNCTION [dbo].[fnGetDueDate]
(
	@termId			INT,
	@dateToCompute	DATETIME
)
RETURNS DATETIME
AS
BEGIN
	DECLARE @dueDate DATETIME, @currentDueDate DATETIME, @firstDayOfMonth DATETIME, @specificDueDate DATETIME;
	DECLARE @termType NVARCHAR(50);
	DECLARE @discountDay INT, @dueNextMonth INT, @dueDay INT, @maxDayOfMonth INT;
	DECLARE @dayOfMonthDue INT;
	DECLARE @daysInMonth INT; --number of days in month
	DECLARE @dayInMonth	INT; --day of dateToCompute

	SELECT
		@termType = A.strType,
		@dayOfMonthDue = A.intDayofMonthDue,
		@dueNextMonth = A.intDueNextMonth,
		@specificDueDate = A.dtmDueDate,
		@dueDay = A.intBalanceDue
	FROM tblSMTerm A
	WHERE A.intTermID = @termId
	
	IF @termType = 'Date Driven'
	BEGIN

		--get the actual number of days in month
		SELECT @daysInMonth = DAY(DATEADD(ms,-2,DATEADD(MONTH, DATEDIFF(MONTH,0,@dateToCompute)+1,0))) 

		--set the day of due if it was more than a day available for first due date
		IF @daysInMonth < @dayOfMonthDue
		BEGIN
			SET @dayOfMonthDue = @daysInMonth
		END

		--get the first day of month
		SET @firstDayOfMonth = DATEADD(day, -DAY(@dateToCompute) + 1, @dateToCompute)
		--set the current due date
		SET @currentDueDate = DATEADD(day, @dayOfMonthDue, @firstDayOfMonth) 
		
		SET @maxDayOfMonth = @dayOfMonthDue - @dueNextMonth;

		IF DAY(@dateToCompute) < @maxDayOfMonth
		BEGIN
			SET @dueDate = @currentDueDate;
		END
		ELSE
		BEGIN
			SET @dueDate = DATEADD(month, 1, @currentDueDate);
			SET @dueDate = DATEADD(day, -DAY(@dueDate) + 1, @dueDate);
			DECLARE @lastDayOfMonth DATETIME = DAY(DATEADD(ms,-2,DATEADD(MONTH, DATEDIFF(MONTH,0,@dueDate)+1,0)));
			SET @dueDate = DATEADD(day, DAY(@lastDayOfMonth)-1, @dueDate);
		END

	END
	ELSE IF @termType = 'Specific Date'
	BEGIN
		SET @dueDate = @specificDueDate;
	END
	ELSE IF @termType = 'Standard'
	BEGIN
		SET @dueDate = DATEADD(day, @dueDay, @dateToCompute);
	END
	

	RETURN @dueDate;
END
