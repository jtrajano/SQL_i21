
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

SELECT 
	 @Type = strType 
	,@DiscountDay = ISNULL(intDiscountDay, 0)
	,@DiscountDate = ISNULL(dtmDiscountDate, @PaymentDate) 
	,@DiscountEP = ISNULL(dblDiscountEP,0)
FROM
	tblSMTerm
WHERE
	intTermID = @TermId


IF (@Type = 'Standard')
	BEGIN
		IF (DATEADD(DAY,@DiscountDay,@TransactionDate) >= @PaymentDate)
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
			
		IF (@TempDiscountDate >= @PaymentDate)
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
		IF (@DiscountDate >= @PaymentDate)
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

