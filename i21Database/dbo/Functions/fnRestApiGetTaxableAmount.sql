CREATE FUNCTION [dbo].[fnRestApiGetTaxableAmount]
(
      @dblQuantity NUMERIC(18, 6)
    , @dblPrice  NUMERIC(18, 6)
    , @dblDiscount NUMERIC(18, 6)
    , @ysnTaxOnly BIT
    , @intTaxCodeId INT
    , @guiTaxesSessionUniqueId UNIQUEIDENTIFIER
)
RETURNS NUMERIC (18, 6)
AS
BEGIN

DECLARE @dblTaxableAmount NUMERIC(18, 6) = ((@dblQuantity * @dblPrice) - ((@dblQuantity * @dblPrice) * (ISNULL(@dblDiscount, 0) / 100.00)))

RETURN ROUND(ISNULL(@dblTaxableAmount, 0), 2)

END