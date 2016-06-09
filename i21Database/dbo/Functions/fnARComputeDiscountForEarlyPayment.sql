CREATE FUNCTION [dbo].[fnARComputeDiscountForEarlyPayment]
(
	@dtmDatePaid	DATETIME,
	@intInvoiceId	INT
)
RETURNS NUMERIC(18,6)
AS
BEGIN
	DECLARE @dblTotalDiscount	NUMERIC(18, 6)
		  , @dblInvoiceTotal	NUMERIC(18, 6)
		  , @dblDiscountEP		NUMERIC(18, 6)
		  , @intTermId			INT
		  , @intBalanceDue		INT
		  , @intDiscountDay		INT
		  , @strType			NVARCHAR(25)
		  , @dtmInvoiceDate		DATETIME

	IF @dtmDatePaid IS NULL OR ISNULL(@intInvoiceId, 0) = 0
		RETURN ISNULL(@dblTotalDiscount, 0)
		
	SET @dtmDatePaid = CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), @dtmDatePaid)))

	SELECT TOP 1
		  @intTermId		= I.intTermId
		, @dblInvoiceTotal	= I.dblInvoiceTotal
		, @dtmInvoiceDate	= CONVERT(DATETIME, FLOOR(CONVERT(DECIMAL(18,6), dtmDate)))
	FROM tblARInvoice I 
	WHERE I.intInvoiceId = @intInvoiceId

	IF ISNULL(@intTermId, 0) > 0
		BEGIN
			SELECT TOP 1
				  @dblDiscountEP	= T.dblDiscountEP
				, @intBalanceDue	= T.intBalanceDue
				, @intDiscountDay	= T.intDiscountDay
				, @strType			= T.strType
			FROM tblSMTerm T
			WHERE T.intTermID = @intTermId
			
			IF @dtmDatePaid BETWEEN @dtmInvoiceDate AND DATEADD(DAYOFYEAR, @intDiscountDay, @dtmInvoiceDate)
				BEGIN
					SET @dblTotalDiscount = @dblInvoiceTotal * (@dblDiscountEP/100)
				END
		END

	RETURN ISNULL(@dblTotalDiscount, 0)
END