CREATE PROCEDURE dbo.uspApiCalculateTax (
	  @ItemId INT
	, @ItemUOMId INT
	, @LocationId INT
	, @CustomerId INT
	, @TransactionDate DATETIME
	, @TaxGroupId INT
	, @CurrencyId INT
	, @Amount NUMERIC(18, 6)
	, @Price NUMERIC(18, 6)
	, @FreightTermId INT
)
AS

DECLARE @guiTaxesUniqueId UNIQUEIDENTIFIER = NEWID()

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
	, ysnAddToCost)
EXEC [dbo].[uspARGetItemTaxes]
	@ItemId= @ItemId,
	@LocationId= @LocationId,
	@CustomerId= @CustomerId,
	@CustomerLocationId= default,
	@TransactionDate= @TransactionDate,
	@TaxGroupId= @TaxGroupId,
	@SiteId= default,
	@FreightTermId= @FreightTermId,
	@CardId= default,
	@VehicleId= default,
	@ItemUOMId= @ItemUOMId,
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
	, ysnAddToCost)
SELECT TOP 1 @guiTaxesUniqueId, 1, *
FROM @tblRestApiItemTaxes

DECLARE @dblTax NUMERIC(18, 6)

SELECT TOP 1 @dblTax = dbo.fnRestApiCalculateItemtax(@Amount, @Price, @ItemUOMId, NULL, @guiTaxesUniqueId, t.intRestApiItemTaxesId)
FROM tblRestApiItemTaxes t
WHERE t.guiTaxesUniqueId = @guiTaxesUniqueId

SELECT ISNULL(@dblTax, 0) as dblTax