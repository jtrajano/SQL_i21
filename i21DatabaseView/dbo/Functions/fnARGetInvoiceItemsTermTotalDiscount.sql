CREATE FUNCTION [dbo].[fnARGetInvoiceItemsTermTotalDiscount]
(
	 @PaymentDate			DATETIME 
	,@InvoiceId				INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN

DECLARE @Type NVARCHAR(100)
DECLARE @DiscountDay INT, @DayMonthDue INT, @DueNextMonth INT
DECLARE @DiscountEP NUMERIC(18,6)
DECLARE @DiscountDate DATETIME
DECLARE @TransactionDate DATETIME
DECLARE @InvoiceDiscountTotal NUMERIC(18,6)
DECLARE @TermId INT
DECLARE @LocationId INT


SELECT
	 @TermId			= intTermId
	,@TransactionDate	= dtmDate
	,@LocationId		= intCompanyLocationId 
FROM
	tblARInvoice
WHERE
	intInvoiceId = @InvoiceId

SELECT 
	 @Type = strType 
	,@DiscountDay = ISNULL(intDiscountDay, 0)
	,@DiscountDate = ISNULL(dtmDiscountDate, @PaymentDate) 
	,@DiscountEP = ISNULL(dblDiscountEP,0)
FROM
	tblSMTerm
WHERE
	intTermID = @TermId


DECLARE @DetailTable AS TABLE (intInvoiceDetailId INT, intItemId INT, intItemUOMId INT, dblPrice NUMERIC(18,6), dblQuantity NUMERIC(18,6))
INSERT INTO @DetailTable
	(
	 intInvoiceDetailId
	,intItemId
	,intItemUOMId
	,dblPrice
	,dblQuantity
	)
SELECT
	 intInvoiceDetailId
	,intItemId
	,intItemUOMId
	,dblPrice
	,dblQtyShipped 
FROM
	tblARInvoiceDetail
WHERE
	intInvoiceId = @InvoiceId
	AND CHARINDEX('Inventory Promotional Pricing(Terms Discount)', strPricing) > 0



WHILE EXISTS(SELECT NULL FROM @DetailTable)
BEGIN
	 DECLARE @InvoiceDetailId	INT
			,@ItemId			INT		
			,@ItemUOMId			INT
			,@Price				NUMERIC(18,6)	
			,@QtyShipped		NUMERIC(18,6)
			,@ItemDiscount		NUMERIC(18,6)

	SELECT TOP 1
		 @InvoiceDetailId	= intInvoiceDetailId
		,@ItemId			= intItemId
		,@ItemUOMId			= intItemUOMId
		,@Price				= dblPrice
		,@QtyShipped		= dblQuantity
	FROM
		@DetailTable

	DECLARE  @DiscountBy	NVARCHAR(50)
			,@Discount		NUMERIC(18, 6)

	SELECT TOP 1 
		@ItemDiscount		= @QtyShipped *
								(CASE
									WHEN strDiscountBy = 'Amount'
										THEN ISNULL(dblDiscount, 0.00)
									ELSE	
										(@Price * (ISNULL(dblDiscount, 0.00)/100.00) )
								END)						
		,@DiscountBy		= strDiscountBy
	FROM
		tblICItemSpecialPricing 
	WHERE
		intItemId = @ItemId 
		AND intItemLocationId = @LocationId 
		AND intItemUnitMeasureId = @ItemUOMId
		AND CAST(@TransactionDate AS DATE) BETWEEN CAST(dtmBeginDate AS DATE) AND CAST(ISNULL(dtmEndDate,@TransactionDate) AS DATE)
	ORDER BY
		dtmBeginDate DESC

	IF @DiscountBy = 'Terms Rate'
		BEGIN
			IF (@Type = 'Standard')
				BEGIN
					IF (DATEADD(DAY,@DiscountDay,@TransactionDate) >= @PaymentDate)
						BEGIN
							SET @InvoiceDiscountTotal = @InvoiceDiscountTotal + (@QtyShipped * (@Price * (@DiscountEP / 100)))
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
							SET @InvoiceDiscountTotal = @InvoiceDiscountTotal + (@QtyShipped * (@Price * (@DiscountEP / 100)))
						END		
				END	
			ELSE
				BEGIN
					IF (@DiscountDate >= @PaymentDate)
						BEGIN
							SET @InvoiceDiscountTotal = @InvoiceDiscountTotal + (@QtyShipped * (@Price * (@DiscountEP / 100)))
						END
				END
		END
	ELSE
		BEGIN
			SET @InvoiceDiscountTotal = @InvoiceDiscountTotal + @ItemDiscount
		END

	


	DELETE FROM @DetailTable WHERE intInvoiceDetailId = @InvoiceDetailId	
END



RETURN @InvoiceDiscountTotal;

END

