
CREATE FUNCTION [dbo].[fnGetDiscountBasedOnTerm]
(
	 @PaymentDate			DATETIME 
	,@TransactionDate		DATETIME 
	,@TermId				INT
	,@InvoiceTotal			NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN

DECLARE @Type NVARCHAR(100)
DECLARE @DiscountDay INT, @DayMonthDue INT, @DueNextMonth INT
DECLARE @DiscountEP NUMERIC(18,6)
DECLARE @DiscountDate datetime
DECLARE @CurrentDate datetime

SET @CurrentDate = DATEADD(DAY, 0, DATEDIFF(DAY, 0, GETDATE()))

SELECT 
	 @Type = strType 
	,@DiscountDay = ISNULL(intDiscountDay, 1)
	,@DiscountDate = ISNULL(dtmDiscountDate, @PaymentDate) 
	,@DiscountEP = ISNULL(dblDiscountEP,0)
FROM
	tblSMTerm
WHERE
	intTermID = @TermId

SET @DiscountDay = CASE WHEN @DiscountDay = 0 THEN 1 ELSE @DiscountDay END

IF (@Type = 'Standard')
	BEGIN
		IF ((DATEADD(DAY,@DiscountDay,@TransactionDate) >= @PaymentDate) AND (DATEADD(DAY,@DiscountDay,@TransactionDate) >= @CurrentDate))
			BEGIN
				RETURN @InvoiceTotal * (@DiscountEP / 100)
			END
		ELSE
			BEGIN
				RETURN 0
			END
	END	
ELSE IF (@Type = 'Date Driven')
	BEGIN
		DECLARE @TransactionMonth int, @TransactionDay int, @TransactionYear int
		SELECT @TransactionMonth = DATEPART(MONTH,@TransactionDate), @TransactionDay = DATEPART(DAY,@TransactionDate) ,@TransactionYear = DATEPART(YEAR,@TransactionDate)
		
		DECLARE @TempDiscountDate datetime
		Set @TempDiscountDate = CONVERT(datetime, (CAST(@TransactionMonth AS nvarchar(10)) + '/' + CAST(@DiscountDay AS nvarchar(10)) + '/' + CAST(@TransactionYear AS nvarchar(10))), 101)
				
		IF ((@TempDiscountDate >= @PaymentDate) AND (DATEADD(DAY,@DiscountDay,@TransactionDate) >= @CurrentDate))
			BEGIN
				RETURN @InvoiceTotal * (@DiscountEP / 100)
			END
		ELSE
			BEGIN
				RETURN 0
			END
		
	END	
ELSE
	BEGIN
		IF ((@DiscountDate >= @PaymentDate) AND (DATEADD(DAY,@DiscountDay,@TransactionDate) >= @CurrentDate)) 
			BEGIN
				RETURN @InvoiceTotal * (@DiscountEP / 100)
			END
		ELSE
			BEGIN
				RETURN 0
			END
	END	

RETURN 0;

END

