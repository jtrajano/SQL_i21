CREATE FUNCTION [dbo].[fnGetDiscountDateBasedOnTerm]
(
	 @TransactionDate		DATETIME 
	,@TermId				INT
	,@PaymentDate			DATETIME = NULL
)
RETURNS DATETIME
AS
BEGIN

DECLARE @Type NVARCHAR(100)
DECLARE @DiscountDay INT, @DayMonthDue INT, @DueNextMonth INT
DECLARE @DiscountDate datetime
DECLARE @CurrentDate datetime
DECLARE @MaxDaysInMonth INT
DECLARE @intDiscountDueNextMonth INT 

SET @PaymentDate = CAST(ISNULL(@PaymentDate, GETDATE()) AS DATE)
SET @TransactionDate = CAST(@TransactionDate AS DATE)
SET @CurrentDate = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

SELECT 
	 @Type = strType 
	,@DiscountDay = ISNULL(intDiscountDay, 1)
	,@DiscountDate = ISNULL(dtmDiscountDate, @PaymentDate) 
	,@MaxDaysInMonth = DATEDIFF(DAY, DATEADD(DAY, 1-DAY(@TransactionDate), @TransactionDate), DATEADD(MONTH, 1, DATEADD(DAY, 1-DAY(@TransactionDate), @TransactionDate)))
	,@intDiscountDueNextMonth= ISNULL(intDiscountDueNextMonth,0)
FROM
	tblSMTerm
WHERE
	intTermID = @TermId

SET @DiscountDay = CASE WHEN @DiscountDay = 0 OR @DiscountDay > @MaxDaysInMonth  THEN 1 ELSE @DiscountDay END

IF (@Type = 'Standard')
	BEGIN		
		RETURN CAST(DATEADD(DAY,@DiscountDay,@TransactionDate) AS DATE)
	END	
ELSE IF (@Type = 'Date Driven')
	BEGIN
		DECLARE @TransactionMonth int, @TransactionDay int, @TransactionYear int
		SELECT @TransactionMonth = DATEPART(MONTH,@TransactionDate), @TransactionDay = DATEPART(DAY,@TransactionDate) ,@TransactionYear = DATEPART(YEAR,@TransactionDate)
		
		DECLARE @TempDiscountDate datetime
		Set @TempDiscountDate = CONVERT(datetime, (CAST(@TransactionMonth AS nvarchar(10)) + '/' + CAST(@DiscountDay AS nvarchar(10)) + '/' + CAST(@TransactionYear AS nvarchar(10))), 101)
				
		IF @DiscountDay = 1 AND @intDiscountDueNextMonth <> 0 
		BEGIN
		RETURN CAST(ISNULL(DATEADD(DAY, @intDiscountDueNextMonth - DAY(DATEADD(MONTH,1,@TransactionDate)), DATEADD(MONTH,1,@TransactionDate)),@TempDiscountDate) AS DATE)
        END
		ELSE	
		BEGIN
		RETURN CAST(ISNULL(DATEADD(DAY,@DiscountDay,@TransactionDate),@TempDiscountDate) AS DATE)
		END
		
	END	
ELSE IF (@Type = 'Specific Date')
	BEGIN
		RETURN @DiscountDate
	END	

RETURN NULL;

END
