CREATE FUNCTION [dbo].[fnRestApiCalculateItemtax] (
      @dblContracted NUMERIC(18, 6)
    ,  @dblPrice NUMERIC(18, 6)
    , @intItemUnitMeasureId INT
    , @strItemUnitMeasure NVARCHAR(50)
    , @guiTaxesSessionUniqueId UNIQUEIDENTIFIER
    , @intReferenceRestApiItemTaxesId INT
)
RETURNS NUMERIC(18, 6)
AS
BEGIN
    DECLARE @intRestApiItemTaxesId INT
    DECLARE @dblTotalItemTax NUMERIC(18, 6) = 0
    DECLARE @dblTotalItemBaseTax NUMERIC(18, 6) = 0    
    DECLARE @dblTotalExempt NUMERIC(18, 6) = 0 
    DECLARE @dblTaxableAmount NUMERIC(18, 6) = 0
    DECLARE @dblTaxAmount NUMERIC(18, 6) = 0
    DECLARE @dblTaxToExempt NUMERIC(18, 6) = 0

    DECLARE @strTaxableByOtherTaxes NVARCHAR(1000)
    DECLARE @strCalculationMethod NVARCHAR(50)
    DECLARE @strUnitMeasure NVARCHAR(50)
    DECLARE @ysnTaxExempt BIT
    DECLARE @dblExemptionPercent BIT
    DECLARE @ysnCheckoffTax BIT
    DECLARE @dblAdjustedTax NUMERIC(18, 6)
    DECLARE @dblBaseAdjustedTax NUMERIC(18, 6)
    DECLARE @dblRate NUMERIC(18, 6)
    DECLARE @dblTax NUMERIC(18, 6) = 0
    DECLARE @dblQuantity NUMERIC(18, 6)
    DECLARE @dblDiscount NUMERIC(18, 6)
    DECLARE @ysnTaxOnly BIT
    DECLARE @intTaxCodeId INT
    DECLARE @intUnitMeasureId INT

    DECLARE @dblPreviousTax NUMERIC(18, 6)
    DECLARE @dblPreviousAdjustedTax NUMERIC(18, 6)

    DECLARE cur CURSOR LOCAL FAST_FORWARD
    FOR
    SELECT
          intRestApiItemTaxesId
        , strTaxableByOtherTaxes
        , dblAdjustedTax
        , strCalculationMethod
        , ysnTaxExempt
        , dblExemptionPercent
        , ysnCheckoffTax
        , dblRate
        , intUnitMeasureId
        , strUnitMeasure
        , dblTax
        , dblBaseAdjustedTax
        , intTaxCodeId
    FROM tblRestApiItemTaxes
    WHERE guiTaxesUniqueId = @guiTaxesSessionUniqueId
        AND intRestApiItemTaxesId = @intReferenceRestApiItemTaxesId

    OPEN cur

    FETCH NEXT FROM cur INTO
          @intRestApiItemTaxesId
        , @strTaxableByOtherTaxes
        , @dblAdjustedTax
        , @strCalculationMethod
        , @ysnTaxExempt
        , @dblExemptionPercent
        , @ysnCheckoffTax
        , @dblRate
        , @intUnitMeasureId
        , @strUnitMeasure
        , @dblTax
        , @dblBaseAdjustedTax
        , @intTaxCodeId

    WHILE @@FETCH_STATUS = 0
    BEGIN
        SET @dblTaxableAmount = 0
        SET @dblTaxAmount = 0
        SET @dblTaxToExempt = 0

        SET @dblTaxableAmount = dbo.fnRestApiGetTaxableAmount(@dblContracted, @dblPrice, ISNULL(@dblDiscount, 0), @ysnTaxOnly, @intTaxCodeId, @guiTaxesSessionUniqueId)

        IF @strCalculationMethod = 'Percentage'
            SET @dblTaxAmount = @dblTaxableAmount * (@dblRate / 100);
        ELSE
        BEGIN
            IF (@intItemUnitMeasureId = @intUnitMeasureId OR @strItemUnitMeasure = @strUnitMeasure) OR @intUnitMeasureId IS NULL
                SET @dblTaxAmount = @dblContracted * @dblRate
            ELSE
                SET @dblTaxAmount = 0.0
        END

        IF @ysnCheckoffTax = 1
            SET @dblTaxAmount = 0.0

        SET @dblTaxToExempt = @dblTaxAmount
        SET @dblTaxAmount = ROUND(@dblTaxAmount, 2)

        IF @dblTax = @dblAdjustedTax
        BEGIN
            IF @ysnTaxExempt = 1
            BEGIN
                IF @dblExemptionPercent = 0
                    SET @dblTaxAmount = 0.0
                ELSE
                BEGIN
                    SET @dblTaxToExempt = @dblTaxToExempt - (@dblTaxAmount * (@dblExemptionPercent / 100.0))
                    SET @dblTaxAmount = @dblTaxAmount - (@dblExemptionPercent / 100.0)
                END

                SET @dblTaxToExempt = @dblTotalExempt + @dblTaxToExempt
            END

            SET @dblTax = ROUND(@dblTaxAmount, 2)
            SET @dblAdjustedTax = ROUND(@dblTaxAmount, 2)
        END
        ELSE
        BEGIN
            SET @dblTax = @dblTaxAmount
            SET @dblAdjustedTax = ROUND(@dblAdjustedTax, 2)
        END

        SET @dblTotalItemTax = @dblTotalItemTax + @dblAdjustedTax
        SET @dblTotalItemBaseTax = @dblTotalItemBaseTax + @dblBaseAdjustedTax

        FETCH NEXT FROM cur INTO
            @intRestApiItemTaxesId
        , @strTaxableByOtherTaxes
        , @dblAdjustedTax
        , @strCalculationMethod
        , @ysnTaxExempt
        , @dblExemptionPercent
        , @ysnCheckoffTax
        , @dblRate
        , @intUnitMeasureId
        , @strUnitMeasure
        , @dblTax
        , @dblBaseAdjustedTax
        , @intTaxCodeId
    END

    CLOSE cur
    DEALLOCATE cur

    RETURN ROUND(@dblTotalItemTax, 2)
END
