CREATE FUNCTION [dbo].fnApiCalculateTaxOnTax(
      @strCalculationMethod NVARCHAR(100)
    , @intTaxCodeId INT
    , @dblRate NUMERIC(18, 6)
    , @dblQty NUMERIC(38, 20)
    , @dblPrice NUMERIC(18, 6)
    , @dblDiscount NUMERIC(18, 6)
    , @guiTaxesSessionUniqueId UNIQUEIDENTIFIER
)
RETURNS NUMERIC(18, 6)
AS
BEGIN

DECLARE @strTaxableByOtherTaxes NVARCHAR(1000)
DECLARE @ysnTaxExempt BIT
DECLARE @dblExemptionPercent BIT
DECLARE @ysnCheckoffTax BIT
DECLARE @ysnTaxOnly BIT
DECLARE @dblAdjustedTax NUMERIC(18, 6)
DECLARE @dblTaxRate NUMERIC(18, 6)
DECLARE @dblTaxableAmount NUMERIC(18, 6) = 0.00
DECLARE @dblTaxOntaxTaxableAmount NUMERIC(18, 6) = 0.00
DECLARE @dblAdjustedRate NUMERIC(18, 6)
DECLARE @strTaxCalculationMethod NVARCHAR(100)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
      strTaxableByOtherTaxes
    , dblAdjustedTax
    , strCalculationMethod
    , ysnTaxExempt
    , dblExemptionPercent
    , ysnCheckoffTax
    , ysnTaxOnly
    , dblRate
FROM tblRestApiItemTaxes
WHERE guiTaxesUniqueId = @guiTaxesSessionUniqueId

OPEN cur

FETCH NEXT FROM cur INTO
      @strTaxableByOtherTaxes
    , @dblAdjustedTax
    , @strTaxCalculationMethod
    , @ysnTaxExempt
    , @dblExemptionPercent
    , @ysnCheckoffTax
    , @ysnTaxOnly
    , @dblTaxRate

WHILE @@FETCH_STATUS = 0
BEGIN
    IF (NULLIF(@strTaxableByOtherTaxes, '') IS NOT NULL)
    BEGIN
        IF (CHARINDEX(CAST(@intTaxCodeId AS NVARCHAR(50)), @strTaxableByOtherTaxes) <> 0)
        BEGIN
            SET @dblAdjustedTax = 0.0
            SET @dblTaxableAmount = dbo.fnRestApiGetTaxableAmount(@dblQty, @dblPrice, @dblDiscount, @ysnTaxOnly, @intTaxCodeId, @guiTaxesSessionUniqueId)
            
            IF (@strTaxCalculationMethod = 'Percentage')
              SET @dblAdjustedTax = ROUND(@dblTaxableAmount * @dblTaxRate / 100, 6)
            ELSE
              SET @dblAdjustedTax = ROUND(@dblQty * @dblTaxRate, 6)

            IF @strCalculationMethod = 'Percentage'
              SET @dblAdjustedRate = @dblRate / 100.0
            ELSE
              SET @dblAdjustedRate = @dblRate

            SET @dblTaxOntaxTaxableAmount = @dblTaxOntaxTaxableAmount + ROUND((@dblAdjustedTax * @dblAdjustedRate / 100.00), 6)
        END
    END

    FETCH NEXT FROM cur INTO
          @strTaxableByOtherTaxes
        , @dblAdjustedTax
        , @strTaxCalculationMethod
        , @ysnTaxExempt
        , @dblExemptionPercent
        , @ysnCheckoffTax
        , @ysnTaxOnly
        , @dblTaxRate
END

CLOSE cur
DEALLOCATE cur

RETURN ROUND(@dblTaxOntaxTaxableAmount, 6)

END