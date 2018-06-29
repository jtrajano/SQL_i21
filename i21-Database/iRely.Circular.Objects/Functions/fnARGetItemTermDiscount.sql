CREATE FUNCTION [dbo].[fnARGetItemTermDiscount]
(
	 @ItemTermDiscountBy	NVARCHAR(50)
	,@ItemTermDiscount		NUMERIC(18,6)
	,@Quantity				NUMERIC(18,6)
	,@Price					NUMERIC(18,6)
	,@ExchangeRate			NUMERIC(18,6)
)
RETURNS NUMERIC(18,6)
AS
BEGIN

DECLARE @ZeroDecimal NUMERIC(18,6) = 0.000000

SET @ItemTermDiscount	= ISNULL(@ItemTermDiscount, @ZeroDecimal)
SET @Quantity			= ISNULL(@Quantity, @ZeroDecimal)
SET @Price				= ISNULL(@Price, @ZeroDecimal)
SET @ExchangeRate		= ISNULL(@ExchangeRate, 1.000000)

IF @ItemTermDiscountBy = 'Percent'
	RETURN [dbo].fnRoundBanker([dbo].fnRoundBanker(((@Quantity * @Price) * (@ItemTermDiscount/100.000000)), [dbo].[fnARGetDefaultDecimal]()) * @ExchangeRate, [dbo].[fnARGetDefaultDecimal]())

ELSE IF (@ItemTermDiscountBy IN ('Amount','Terms Rate'))
	RETURN [dbo].fnRoundBanker(@ItemTermDiscount, [dbo].[fnARGetDefaultDecimal]())

RETURN @ZeroDecimal;

END
