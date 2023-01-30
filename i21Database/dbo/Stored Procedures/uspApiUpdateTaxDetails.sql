CREATE PROCEDURE [dbo].[uspApiUpdateTaxDetails] (@UniqueId UNIQUEIDENTIFIER, @SalesOrderId INT)
AS

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
	, ysnOverrideTaxGroup BIT NULL
)

DECLARE @ItemId INT
DECLARE @UOMId INT
DECLARE @LocationId INT
DECLARE @CustomerLocationId INT
DECLARE @CustomerId INT
DECLARE @TransactionDate DATETIME
DECLARE @TaxGroupId INT
DECLARE @CurrencyId INT
DECLARE @Amount NUMERIC(18, 6)
DECLARE @Price NUMERIC(18, 6)
DECLARE @FreightTermId INT
DECLARE @SalesOrderDetailId INT
DECLARE @ItemTaxIdentifier UNIQUEIDENTIFIER
DECLARE @guiTaxesUniqueId UNIQUEIDENTIFIER

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT
	  i.intSalesOrderDetailId
    , i.intItemId
    , u.intUnitMeasureId
    , o.intCompanyLocationId
	, o.intEntityId
	, o.dtmDate
	, i.intTaxGroupId
	, o.intCurrencyId
	, i.dblQtyOrdered
	, i.dblPrice
	, o.intFreightTermId
	, o.intShipToLocationId
	, i.guiApiItemTaxIdentifier
FROM tblSOSalesOrderDetail i
JOIN tblSOSalesOrder o ON o.intSalesOrderId = i.intSalesOrderId
LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = i.intItemUOMId
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
WHERE i.intSalesOrderId = @SalesOrderId

OPEN cur

FETCH NEXT FROM cur INTO @SalesOrderDetailId, @ItemId, @UOMId, @LocationId, @CustomerId, @TransactionDate, @TaxGroupId, @CurrencyId, @Amount, @Price, @FreightTermId, @CustomerLocationId, @ItemTaxIdentifier

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @guiTaxesUniqueId = NEWID()

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
    EXEC [dbo].[uspARGetItemTaxes]
		@ItemId= @ItemId,
		@LocationId= @LocationId,
		@CustomerId= @CustomerId,
		@CustomerLocationId= @CustomerLocationId,
		@TransactionDate= @TransactionDate,
		@TaxGroupId= @TaxGroupId,
		@SiteId= default,
		@FreightTermId= @FreightTermId,
		@CardId= default,
		@VehicleId= default,
		@ItemUOMId= @UOMId,
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
		, NULLIF(it.intUnitMeasureId, 0)
		, it.strUnitMeasure
		, it.strTaxClass
		, it.ysnAddToCost
		, CAST(CASE WHEN (adj.dblAdjustedTax IS NOT NULL AND it.dblTax != adj.dblAdjustedTax) THEN 1 ELSE 0 END AS BIT)
	FROM @tblRestApiItemTaxes it
	OUTER APPLY(
		SELECT TOP 1 a.dblAdjustedTax, a.ysnExempt
		FROM tblApiTaxAdjustment a
		WHERE a.guiItemTaxIdentifier = @ItemTaxIdentifier
			AND a.guiUniqueId = @UniqueId
			AND a.intItemId = @ItemId
			AND a.intTaxCodeId = it.intTaxCodeId
	) adj

    DELETE FROM tblSOSalesOrderDetailTax WHERE intSalesOrderDetailId = @SalesOrderDetailId

	INSERT INTO tblSOSalesOrderDetailTax (
		  intSalesOrderDetailId
		, intTaxGroupId
		, intTaxCodeId
		, intTaxClassId
		, strTaxableByOtherTaxes
		, strCalculationMethod
		, dblRate
		, dblBaseRate
		, dblExemptionPercent
		, intSalesTaxAccountId
		, dblTax
		, dblAdjustedTax
		, dblBaseAdjustedTax
		, ysnSeparateOnInvoice
		, ysnCheckoffTax
		, ysnTaxExempt
		, ysnInvalidSetup
		, ysnTaxOnly
		, strNotes
		, intUnitMeasureId
		, ysnTaxAdjusted
		, intConcurrencyId
	)
	SELECT 
		  @SalesOrderDetailId
		, x.intTaxGroupId
		, x.intTaxCodeId
		, x.intTaxClassId
		, x.strTaxableByOtherTaxes
		, x.strCalculationMethod
		, x.dblRate
		, x.dblBaseRate
		, x.dblExemptionPercent
		, x.intSalesTaxAccountId
		, dblTax = dbo.fnRestApiCalculateItemtax(@Amount, @Price, @UOMId, NULL, @guiTaxesUniqueId, x.intRestApiItemTaxesId)
		, dblAdjustedTax = CASE WHEN x.ysnTaxExempt = 1 THEN 0.00 ELSE CASE WHEN x.ysnTaxAdjusted = 1 THEN x.dblAdjustedTax ELSE dbo.fnRestApiCalculateItemtax(@Amount, @Price, @UOMId, NULL, @guiTaxesUniqueId, x.intRestApiItemTaxesId) END END
		, dblBaseAdjustedTax = CASE WHEN x.ysnTaxExempt = 1 THEN 0.00 ELSE CASE WHEN x.ysnTaxAdjusted = 1 THEN x.dblAdjustedTax ELSE dbo.fnRestApiCalculateItemtax(@Amount, @Price, @UOMId, NULL, @guiTaxesUniqueId, x.intRestApiItemTaxesId) END END
		, x.ysnSeparateOnInvoice
		, x.ysnCheckoffTax
		, x.ysnTaxExempt
		, x.ysnInvalidSetup
		, x.ysnTaxOnly
		, x.strNotes
		, x.intUnitMeasureId
		, CASE WHEN x.ysnTaxExempt = 1 THEN 1 ELSE x.ysnTaxAdjusted END
		, 1
	FROM tblRestApiItemTaxes x
    WHERE x.guiTaxesUniqueId = @guiTaxesUniqueId

    DELETE FROM tblRestApiItemTaxes WHERE guiTaxesUniqueId = @guiTaxesUniqueId
   
   FETCH NEXT FROM cur INTO @SalesOrderDetailId, @ItemId, @UOMId, @LocationId, @CustomerId, @TransactionDate, @TaxGroupId, @CurrencyId, @Amount, @Price, @FreightTermId, @CustomerLocationId, @ItemTaxIdentifier
END

CLOSE cur
DEALLOCATE cur