CREATE PROCEDURE [dbo].[uspApiCreateItemContractPrepayment] (
	@guiUniqueId UNIQUEIDENTIFIER,
	@intItemContractHeaderId INT
)
AS

DECLARE @strInvoiceNumber NVARCHAR(200)
DECLARE @intInvoiceId INT
DECLARE @intCompanyLocationId INT
DECLARE @strContractCategoryId NVARCHAR(50)

SELECT TOP 1 @intCompanyLocationId = intCompanyLocationId, @strContractCategoryId = strContractCategoryId
FROM tblCTItemContractHeader
WHERE intItemContractHeaderId = @intItemContractHeaderId

DECLARE @intAccountId INT
DECLARE @strAccountId NVARCHAR(250)
DECLARE @strErrorMessage NVARCHAR(250)

exec uspARGetDefaultAccount 
	@strTransactionType = N'Customer Prepayment',
	@intCompanyLocationId = @intCompanyLocationId,
	@intAccountId = @intAccountId OUTPUT,
	@strAccountId = @strAccountId OUTPUT,
	@strErrorMsg = @strErrorMessage OUTPUT

EXEC dbo.uspSMGetStartingNumber 64, @strInvoiceNumber OUTPUT, @intCompanyLocationId


INSERT dbo.tblARInvoice
(
	  guiApiUniqueId
	, strInvoiceNumber
	, strTransactionType
	, strType
	, intEntityId
	, intEntityCustomerId
	, intCompanyLocationId
	, intAccountId
	, intCurrencyId
	, intTermId
	, intSourceId
	, dtmDate
	, dtmShipDate
	, dtmDueDate
	, intEntityContactId
	, intFreightTermId
	, intEntitySalespersonId
	, intShipViaId
	, intShipToLocationId
	, strShipToLocationName
	, strShipToAddress
	, strShipToCity
	, strShipToState
	, strShipToZipCode
	, strShipToCountry
	, intBillToLocationId
	, strBillToLocationName
	, strBillToAddress
	, strBillToCity
	, strBillToState
	, strBillToZipCode
	, strBillToCountry
	, ysnPosted
	, ysnPaid
	, ysnFromItemContract
	, intPeriodsToAccrue
	, strContractApplyTo
	, dtmPostDate
)
SELECT TOP 1
      @guiUniqueId
	, @strInvoiceNumber
	, 'Customer Prepayment'
	, 'Standard'
	, c.intEntityId
	, cpd.intEntityCustomerId
	, cpd.intCompanyLocationId
	, @intAccountId
	, cpd.intCurrencyId
	, COALESCE(cpd.intTermId, h.intTermId, c.intTermsId)
	, intSourceId = 0
	, GETDATE()
	, GETDATE()
	, cpd.dtmDueDate
	, cpd.intEntityContactId
	, cpd.intFreightTermId
	, COALESCE(cpd.intEntitySalespersonId, c.intSalespersonId)
	, cpd.intShipViaId
	, cpd.intShipToId
	, cpd.strShipToLocationName
	, cpd.strShipToAddress
	, cpd.strShipToCity
	, cpd.strShipToState
	, cpd.strShipToZipCode
	, cpd.strShipToCountry
	, cpd.intBillToId
	, cpd.strBillToLocationName
	, cpd.strBillToAddress
	, cpd.strBillToCity
	, cpd.strBillToState
	, cpd.strBillToZipCode
	, cpd.strBillToCountry
	, ysnPosted = 0
	, ysnPaid = 0
	, ysnFromItemContract = 1
	, intPeriodsToAccrue = 1
	, strContractApplyTo = 'Contract'
	, dtmPostDate = GETDATE()
FROM vyuARPrepaymentContractDefault cpd
LEFT JOIN tblCTItemContractHeader h ON h.intItemContractHeaderId = cpd.intItemContractHeaderId
LEFT JOIN tblARCustomer c ON c.intEntityId = h.intEntityId
WHERE cpd.intItemContractHeaderId = @intItemContractHeaderId

SET @intInvoiceId = SCOPE_IDENTITY()

INSERT INTO dbo.tblARInvoiceDetail
(
	  intInvoiceId
	, intItemCategoryId
	, intCategoryId
	, intItemId
	, strItemDescription
	, intOrderUOMId
	, dblQtyOrdered
	, intItemUOMId
	, dblContractBalance
	, dblContractAvailable
	, dblQtyShipped
	, dblPrice
	, intContractHeaderId
	, intContractDetailId
	, intPrepayTypeId
	, intSubCurrencyId
	, dblSubCurrencyRate
	, strPricing
	, intDestinationGradeId
	, intDestinationWeightId
)
SELECT
	  @intInvoiceId
	, cpd.intItemCategoryId
	, cpd.intCategoryId
	, cpd.intItemId
	, cpd.strItemDescription
	, cpd.intOrderUOMId
	, cpd.dblOrderQuantity
	, cpd.intItemUOMId
	, cpd.dblBalance
	, cpd.dblBalance - cpd.dblScheduleQty
	, cpd.dblShipQuantity
	, cpd.dblCashPrice
	, cpd.intContractHeaderId
	, cpd.intContractDetailId
	, intPrepayTypeId = 2
	, cpd.intSubCurrencyId
	, cpd.dblSubCurrencyRate
	, strPricing = 'Contracts - Customer Pricing'
	, cpd.intDestinationGradeId
	, cpd.intDestinationWeightId
FROM vyuARPrepaymentContractDefault cpd
WHERE cpd.intItemContractHeaderId = @intItemContractHeaderId

IF @strContractCategoryId = 'Item'
BEGIN
	exec uspARInsertTransactionDetail @InvoiceId = @intInvoiceId, @UserId = 1
	exec uspARUpdateInvoiceIntegrations @InvoiceId = 1807, @ForDelete = 0, @UserId = 1
END

DECLARE @Logs TABLE (strError NVARCHAR(500), strField NVARCHAR(100), strValue NVARCHAR(500), intLineNumber INT NULL, dblTotalAmount NUMERIC(18, 6) NULL, intLinePosition INT NULL, strLogLevel NVARCHAR(50))

SELECT * FROM @Logs
