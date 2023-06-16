CREATE PROCEDURE dbo.uspApiCalculatePOTaxes (
	  @UniqueId UNIQUEIDENTIFIER
)
AS

DECLARE @PurchaseId INT
DECLARE @PurchaseDetailId INT
DECLARE @TransactionType NVARCHAR(50)
DECLARE @ItemId INT
DECLARE @ItemUOMId INT
DECLARE @UOMId INT
DECLARE @LocationId INT
DECLARE @CustomerId INT
DECLARE @CustomerLocationId INT
DECLARE @TransactionDate DATETIME
DECLARE @TaxGroupId INT
DECLARE @CurrencyId INT
DECLARE @Amount NUMERIC(18, 6)
DECLARE @Price NUMERIC(18, 6)
DECLARE @FreightTermId INT
DECLARE @ItemTaxIdentifier UNIQUEIDENTIFIER
DECLARE @Tax NUMERIC(18, 6)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT 
    po.intPurchaseId,
    pd.intPurchaseDetailId,
    'Purchase',
    pd.intItemId,
    iu.intUnitMeasureId,
    po.intLocationId,
    po.intEntityId,
    po.intShipFromId,
    po.dtmDate,
    pd.intTaxGroupId,
    po.intCurrencyId,
    pd.dblQtyOrdered,
    pd.dblCost,
    po.intFreightTermId,
    pd.guiApiItemTaxIdentifier
FROM tblPOPurchase po
JOIN tblPOPurchaseDetail pd ON pd.intPurchaseId = po.intPurchaseId
LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = pd.intUnitOfMeasureId
WHERE po.guiApiUniqueId = @UniqueId

OPEN cur

FETCH NEXT FROM cur INTO
      @PurchaseId
    , @PurchaseDetailId
    , @TransactionType
    , @ItemId
    , @UOMId
    , @LocationId
    , @CustomerId
    , @CustomerLocationId
    , @TransactionDate
    , @TaxGroupId
    , @CurrencyId
    , @Amount
    , @Price
    , @FreightTermId
    , @ItemTaxIdentifier

WHILE @@FETCH_STATUS = 0
BEGIN
    EXEC dbo.uspApiCalculateTax 
        @UniqueId, @TransactionType, @ItemId, @UOMId, @LocationId, @CustomerId, @CustomerLocationId, 
        @TransactionDate, @TaxGroupId, @CurrencyId, @Amount, @Price, @FreightTermId, @ItemTaxIdentifier, @Tax OUTPUT

    UPDATE tblPOPurchaseDetail
    SET dblTax = @Tax
    WHERE intPurchaseDetailId = @PurchaseDetailId

    FETCH NEXT FROM cur INTO
          @PurchaseId
        , @PurchaseDetailId
        , @TransactionType
        , @ItemId
        , @UOMId
        , @LocationId
        , @CustomerId
        , @CustomerLocationId
        , @TransactionDate
        , @TaxGroupId
        , @CurrencyId
        , @Amount
        , @Price
        , @FreightTermId
        , @ItemTaxIdentifier
END

CLOSE cur
DEALLOCATE cur

-- Update summary
UPDATE po
SET po.dblTax = details.dblTax, 
    po.dblTotalWeight = details.dblWeight, 
    po.dblSubtotal = details.dblTotal,
    po.dblTotal = details.dblTotal + details.dblTax
FROM tblPOPurchase po
OUTER APPLY (
    SELECT SUM(d.dblTax) dblTax, SUM(d.dblWeight) dblWeight, SUM(d.dblTotal) dblTotal
    FROM tblPOPurchaseDetail d
    WHERE d.intPurchaseId = po.intPurchaseId
) details
WHERE po.guiApiUniqueId = @UniqueId