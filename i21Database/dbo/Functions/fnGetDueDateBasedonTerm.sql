CREATE FUNCTION [dbo].[fnGetDueDateBasedOnTerm]
(
	 @dtmTransactionDate	DATETIME
	,@intTermId				INT
)
RETURNS DATETIME
AS
BEGIN

DECLARE @strType			NVARCHAR(100)
      , @intBalanceDue		INT
	  , @intDayMonthDue		INT
	  , @intDueNextMonth	INT
	  , @dtmDueDate			DATETIME

SELECT @strType			= strType 
	 , @intBalanceDue	= ISNULL(intBalanceDue, 0)
	 , @intDayMonthDue	= ISNULL(intDayofMonthDue, 0)
	 , @intDueNextMonth = ISNULL(intDueNextMonth, 0)
	 , @dtmDueDate		= ISNULL(dtmDueDate, @dtmTransactionDate)
FROM tblSMTerm
WHERE intTermID = @intTermId

IF (@strType = 'Standard')
	BEGIN
		RETURN DATEADD(DAY, @intBalanceDue, @dtmTransactionDate);
	END	
ELSE IF (@strType = 'Date Driven')
	BEGIN

		DECLARE @intInvoiceDate		INT
			  , @intDaysInDueMonth	INT
			  , @dtmDueDateTemp		DATE
			  , @intMonthToAdd		INT = 1
		
		SELECT TOP 1 @intDayMonthDue	= intCutoff
				   , @intDueNextMonth	= intCutoff
		FROM tblSMTermCutoff
		WHERE intTermId = @intTermId
		  AND DAY(@dtmTransactionDate) BETWEEN intFromDate AND intToDate

		SET @intInvoiceDate = DAY(@dtmTransactionDate)

		IF EXISTS(SELECT TOP 1 NULL FROM tblSMTermCutoff WHERE intTermId = @intTermId) 
			BEGIN
				IF @intInvoiceDate >= @intDueNextMonth
					SET @intMonthToAdd = 1		
				ELSE
					SET @intMonthToAdd = 0
			END
		ELSE 
			SET @intMonthToAdd = 1		

        SET @dtmDueDateTemp = DATEADD(MONTH, @intMonthToAdd, @dtmTransactionDate)
        SET @intDaysInDueMonth = [dbo].[fnGetDaysInMonth](@dtmDueDateTemp)

        IF @intDayMonthDue > @intDaysInDueMonth
            SET @intDayMonthDue = @intDaysInDueMonth;
							
        RETURN CAST((CAST(YEAR(@dtmDueDateTemp) AS NVARCHAR(10)) + '-' + CAST(MONTH(@dtmDueDateTemp) AS NVARCHAR(10)) + '-' + CAST(CASE WHEN @intDayMonthDue = 0 THEN 1 ELSE @intDayMonthDue END  AS NVARCHAR(10))) AS DATE)
 
	END
ELSE
	BEGIN
		RETURN ISNULL(@dtmDueDate, @dtmTransactionDate);		 
	END	

RETURN @dtmTransactionDate;

END