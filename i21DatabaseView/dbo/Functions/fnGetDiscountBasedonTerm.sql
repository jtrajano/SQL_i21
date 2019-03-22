
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

DECLARE @Type		NVARCHAR(100)
	,@DiscountEP	NUMERIC(18,6)
	,@DiscountDate	DATETIME
	,@CurrentDate	DATETIME

SET @CurrentDate = CAST(GETDATE() AS DATE)
SET @DiscountDate = [dbo].[fnGetDiscountDateBasedOnTerm](@TransactionDate, @TermId, @PaymentDate)

SELECT 
	  @Type			= strType
	 ,@DiscountEP	= ISNULL(dblDiscountEP, 0.000000)
FROM
	tblSMTerm
WHERE
	intTermID = @TermId

IF (@Type = 'Standard')
	BEGIN
		IF (@DiscountDate >= @PaymentDate) AND (@DiscountDate >= @CurrentDate)
			BEGIN
				RETURN @InvoiceTotal * (@DiscountEP / 100.000000)
			END
		ELSE
			BEGIN
				RETURN 0.000000
			END
	END	
ELSE IF (@Type = 'Date Driven')
	BEGIN						
		IF ((@DiscountDate >= @PaymentDate) AND (@DiscountDate >= @CurrentDate))
			BEGIN
				RETURN @InvoiceTotal * (@DiscountEP / 100.000000)
			END
		ELSE
			BEGIN
				RETURN 0.000000
			END		
	END	
ELSE
	BEGIN
		IF ((@DiscountDate >= @PaymentDate) AND (@DiscountDate >= @CurrentDate)) 
			BEGIN
				RETURN @InvoiceTotal * (@DiscountEP / 100.000000)
			END
		ELSE
			BEGIN
				RETURN 0.000000
			END
	END	

RETURN 0;

END

