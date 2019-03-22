CREATE FUNCTION [dbo].[fnARGetItemTermDiscountExemption]
(
	 @TermDiscountExempt	BIT
	,@TermDiscountRate		NUMERIC(18,6)
	,@Quantity				NUMERIC(18,6)
	,@Price					NUMERIC(18,6)
	,@ExchangeRate			NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN

DECLARE @ZeroDecimal NUMERIC(18,6) = 0.000000

SET @TermDiscountExempt = ISNULL(@TermDiscountExempt, 1)
SET @TermDiscountRate	= ISNULL(@TermDiscountRate, @ZeroDecimal)
SET @Quantity			= ISNULL(@Quantity, @ZeroDecimal)
SET @Price				= ISNULL(@Price, @ZeroDecimal)
SET @ExchangeRate		= ISNULL(@ExchangeRate, 1.000000)

IF @TermDiscountExempt = 1
	RETURN [dbo].fnRoundBanker([dbo].fnRoundBanker(((@Quantity * @Price) * (@TermDiscountRate/100.000000)), [dbo].[fnARGetDefaultDecimal]()) * @ExchangeRate, [dbo].[fnARGetDefaultDecimal]())

RETURN @ZeroDecimal;

END
