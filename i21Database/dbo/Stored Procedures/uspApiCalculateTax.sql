CREATE PROCEDURE dbo.uspApiCalculateTax (
	  @UniqueId UNIQUEIDENTIFIER
	, @TransactionType NVARCHAR(20) -- Sale/Purchase
	, @ItemId INT
	, @UOMId INT
	, @LocationId INT
	, @CustomerId INT
	, @CustomerLocationId INT
	, @TransactionDate DATETIME
	, @TaxGroupId INT
	, @CurrencyId INT
	, @Amount NUMERIC(18, 6)
	, @Price NUMERIC(18, 6)
	, @FreightTermId INT
	, @ItemTaxIdentifier UNIQUEIDENTIFIER
	, @Tax NUMERIC(18, 6) OUTPUT
)
AS

DECLARE @guiTaxesUniqueId UNIQUEIDENTIFIER = @UniqueId
DECLARE @ItemUOMId INT

DECLARE @strUnitMeasure NVARCHAR(200)

SELECT @ItemUOMId = i.intItemUOMId, @strUnitMeasure = u.strUnitMeasure
FROM tblICItemUOM i
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = i.intUnitMeasureId
WHERE i.intItemId = @ItemId
	AND u.intUnitMeasureId = @UOMId

DECLARE @tblRestApiItemTaxes TABLE (
	  intTransactionDetailTaxId INT NULL
	, intInvoiceDetailId INT NULL
	, intTaxGroupMasterId INT NULL
	, intTaxGroupId INT  NULL
	, intTaxCodeId INT  NULL
	, intTaxClassId INT  NULL
	, strTaxableByOtherTaxes NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, strCalculationMethod NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dblRate NUMERIC(18, 6) NULL
	, dblBaseRate NUMERIC(18, 6) NULL
	, dblExemptionPercent NUMERIC(18, 6) NULL
	, dblTax NUMERIC(18, 6) NULL
	, dblAdjustedTax NUMERIC(18, 6) NULL
	, dblBaseAdjustedTax NUMERIC(18, 6) NULL
	, intSalesTaxAccountId INT NULL
	, intSalesTaxExemptionAccountId INT NULL
	, ysnSeparateOnInvoice BIT NULL
	, ysnCheckoffTax BIT NULL
	, strTaxCode NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, ysnTaxExempt BIT NULL
	, ysnTaxOnly BIT NULL
	, ysnInvalidSetup  BIT NULL
	, strTaxGroup NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strNotes NVARCHAR(400) COLLATE Latin1_General_CI_AS NULL
	, intUnitMeasureId INT NULL
	, strUnitMeasure NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL
	, strTaxClass NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, ysnAddToCost BIT NULL
	, ysnTaxAdjusted BIT NULL
	, ysnOverrideTaxGroup BIT NULL
)

INSERT INTO @tblRestApiItemTaxes (
	  intTransactionDetailTaxId
	, intInvoiceDetailId
	, intTaxGroupMasterId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, strTaxableByOtherTaxes
	, strCalculationMethod
	, dblRate
	, dblBaseRate
	, dblExemptionPercent
	, dblTax
	, dblAdjustedTax
	, dblBaseAdjustedTax
	, intSalesTaxAccountId
	, intSalesTaxExemptionAccountId
	, ysnSeparateOnInvoice
	, ysnCheckoffTax
	, strTaxCode
	, ysnTaxExempt
	, ysnTaxOnly
	, ysnInvalidSetup
	, strTaxGroup
	, strNotes
	, intUnitMeasureId
	, strUnitMeasure
	, strTaxClass
	, ysnAddToCost
	, ysnOverrideTaxGroup)
EXEC [dbo].[uspApiGetItemTaxes]
	@ItemId= @ItemId,
	@LocationId= @LocationId,
	@EntityId= @CustomerId,
	@EntityLocationId= @CustomerLocationId,
	@TransactionDate= @TransactionDate,
	@TransactionType = @TransactionType,
	@TaxGroupId= @TaxGroupId,
	@SiteId= default,
	@FreightTermId= @FreightTermId,
	@CardId= default,
	@VehicleId= default,
	@UOMId= @UOMId,
	@CurrencyId= @CurrencyId,
	@CurrencyExchangeRateTypeId= default,
	@CurrencyExchangeRate= 1

INSERT INTO tblRestApiItemTaxes (
	  guiTaxesUniqueId
	, intItemContractDetailId
	, intTransactionDetailTaxId
	, intInvoiceDetailId
	, intTaxGroupMasterId
	, intTaxGroupId
	, intTaxCodeId
	, intTaxClassId
	, strTaxableByOtherTaxes
	, strCalculationMethod
	, dblRate
	, dblBaseRate
	, dblExemptionPercent
	, dblTax
	, dblAdjustedTax
	, dblBaseAdjustedTax
	, intSalesTaxAccountId
	, intSalesTaxExemptionAccountId
	, ysnSeparateOnInvoice
	, ysnCheckoffTax
	, strTaxCode
	, ysnTaxExempt
	, ysnTaxOnly
	, ysnInvalidSetup
	, strTaxGroup
	, strNotes
	, intUnitMeasureId
	, strUnitMeasure
	, strTaxClass
	, ysnAddToCost
	, ysnTaxAdjusted)
SELECT @guiTaxesUniqueId
    , NULL
	, it.intTransactionDetailTaxId
	, it.intInvoiceDetailId
	, it.intTaxGroupMasterId
	, it.intTaxGroupId
	, it.intTaxCodeId
	, it.intTaxClassId
	, it.strTaxableByOtherTaxes
	, it.strCalculationMethod
	, it.dblRate
	, it.dblBaseRate
	, it.dblExemptionPercent
	, it.dblTax
	, COALESCE(adj.dblAdjustedTax, it.dblAdjustedTax)
	, COALESCE(adj.dblAdjustedTax, it.dblAdjustedTax)
	, it.intSalesTaxAccountId
	, it.intSalesTaxExemptionAccountId
	, it.ysnSeparateOnInvoice
	, it.ysnCheckoffTax
	, it.strTaxCode
	, COALESCE(adj.ysnExempt, it.ysnTaxExempt)
	, it.ysnTaxOnly
	, it.ysnInvalidSetup
	, it.strTaxGroup
	, it.strNotes
	, ISNULL(NULLIF(it.intUnitMeasureId, 0), @UOMId)
	, ISNULL(NULLIF(it.strUnitMeasure, ''), @strUnitMeasure)
	, it.strTaxClass
	, it.ysnAddToCost
	, CASE WHEN COALESCE(adj.ysnExempt, it.ysnTaxExempt) = 1 THEN 1 ELSE CAST(CASE WHEN (adj.dblAdjustedTax IS NOT NULL AND it.dblTax != adj.dblAdjustedTax) THEN 1 ELSE 0 END AS BIT) END
FROM @tblRestApiItemTaxes it
OUTER APPLY(
	SELECT TOP 1 a.dblAdjustedTax, a.ysnExempt
	FROM tblApiTaxAdjustment a
	WHERE a.guiItemTaxIdentifier = @ItemTaxIdentifier
		AND a.guiUniqueId = @UniqueId
		AND a.intItemId = @ItemId
		AND a.intTaxCodeId = it.intTaxCodeId
) adj

DECLARE @dblTax NUMERIC(18, 6)

SELECT
	@dblTax = SUM(dbo.fnRestApiCalculateItemtax(@Amount, @Price, @UOMId, NULL, @guiTaxesUniqueId, t.intRestApiItemTaxesId))
FROM tblRestApiItemTaxes t
WHERE t.guiTaxesUniqueId = @guiTaxesUniqueId
SET @Tax = ISNULL(@dblTax, 0)
SELECT ISNULL(@dblTax, 0) as dblTax

DELETE FROM tblRestApiItemTaxes WHERE guiTaxesUniqueId = @guiTaxesUniqueId