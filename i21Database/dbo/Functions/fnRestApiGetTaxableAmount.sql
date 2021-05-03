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

DECLARE @dblOtherTaxes NUMERIC(18, 6) = 0
DECLARE @strTaxableByOtherTaxes NVARCHAR(1000)
DECLARE @strCalculationMethod NVARCHAR(50)
DECLARE @ysnTaxExempt BIT
DECLARE @dblExemptionPercent BIT
DECLARE @ysnCheckoffTax BIT
DECLARE @dblAdjustedTax NUMERIC(18, 6)
DECLARE @dblRate NUMERIC(18, 6)
DECLARE @ysnTaxAdjusted BIT = 0

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
      strTaxableByOtherTaxes
    , dblAdjustedTax
    , strCalculationMethod
    , ysnTaxExempt
    , dblExemptionPercent
    , ysnCheckoffTax
    , dblRate
FROM tblRestApiItemTaxes
WHERE guiTaxesUniqueId = @guiTaxesSessionUniqueId

OPEN cur

FETCH NEXT FROM cur INTO
      @strTaxableByOtherTaxes
    , @dblAdjustedTax
    , @strCalculationMethod
    , @ysnTaxExempt
    , @dblExemptionPercent
    , @ysnCheckoffTax
    , @dblRate

WHILE @@FETCH_STATUS = 0
BEGIN
    IF (NULLIF(@strTaxableByOtherTaxes, '') IS NULL)
    BEGIN
        IF (CHARINDEX(CAST(@intTaxCodeId AS NVARCHAR(50)), @strTaxableByOtherTaxes) <> 0)
        BEGIN
            IF (@ysnTaxOnly = 1)
                SET @dblTaxableAmount = 0.0

            IF @ysnTaxAdjusted = 1
                SET @dblOtherTaxes = @dblOtherTaxes + @dblAdjustedTax
            ELSE
            BEGIN
                IF @strCalculationMethod = 'Percentage'
                BEGIN
                    SET @dblOtherTaxes = @dblOtherTaxes + 
                        CASE WHEN ((@ysnTaxExempt = 1 AND ISNULL(@dblExemptionPercent, 0) = 0.00) OR @ysnCheckoffTax = 1) THEN 0.00 
                        ELSE ((@dblQuantity * @dblPrice) - ((@dblQuantity * @dblPrice) * (ISNULL(@dblDiscount, 0) / 100.00))) * (@dblRate / 100)
                        END
                END
                ELSE
                BEGIN
                    SET @dblOtherTaxes = @dblOtherTaxes + 
                        CASE WHEN ((@ysnTaxExempt = 1 AND ISNULL(@dblExemptionPercent, 0) = 0.00) OR @ysnCheckoffTax = 1) THEN 0.00 
                        ELSE @dblRate * @dblQuantity
                        END
                END
            END
        END
    END

    FETCH NEXT FROM cur INTO
          @strTaxableByOtherTaxes
        , @dblAdjustedTax
        , @strCalculationMethod
        , @ysnTaxExempt
        , @dblExemptionPercent
        , @ysnCheckoffTax
        , @dblRate
END

CLOSE cur
DEALLOCATE cur

RETURN ROUND(ISNULL(@dblTaxableAmount, 0) + ISNULL(@dblOtherTaxes, 0), 2)

END