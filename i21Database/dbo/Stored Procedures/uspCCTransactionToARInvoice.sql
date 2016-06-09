CREATE PROCEDURE [dbo].[uspCCTransactionToARInvoice]
	 @intSiteHeaderId	INT
	,@UserId			INT	
	,@Post				BIT	= NULL
	,@Recap				BIT	= NULL
	,@ErrorMessage		NVARCHAR(250) OUTPUT
	,@CreatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@success			BIT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
DECLARE @CCRItemToARItem TABLE
(
  intSiteHeaderId int, 
  strItem nvarchar(100)
)
DECLARE @intDealerSiteCreditItem INT, @intDealerSiteFeeItem INT
SELECT TOP 1 @intDealerSiteCreditItem = intDealerSiteCreditItem, @intDealerSiteFeeItem = intDealerSiteFeeItem FROM tblCCCompanyPreferenceOption

INSERT INTO @CCRItemToARItem VALUES (@intSiteHeaderId,'Dealer Site Credits')
INSERT INTO @CCRItemToARItem VALUES (@intSiteHeaderId,'Dealer Site Fees')

SET @success = 0

INSERT INTO @EntriesForInvoice(
	[strTransactionType]
	,[strSourceTransaction]
	,[intSourceId]
	,[strSourceId]
	,[intEntityCustomerId]
	,[intCompanyLocationId]
	,[intCurrencyId]
	,[intTermId]
	,[dtmDate]
	,[dtmShipDate]
	,[intEntitySalespersonId]
	,[intEntityId]
	,[ysnPost]
	,[intItemId]
	,[strItemDescription]
	,[dblQtyShipped]
	,[dblPrice]
	,[intTaxGroupId]
	,[ysnRecomputeTax]
	,[intSiteDetailId]
)
SELECT [strTransactionType] = 'Credit Memo' 
	,[strSourceTransaction] = 'Credit Card Reconciliation'
	,[intSourceId] = null
	,[strSourceId] = ccSiteDetail.intSiteDetailId
	,[intEntityCustomerId] = ccSite.intCustomerId
	,[intCompanyLocationId] = ccVendorDefault.intCompanyLocationId
	,[intCurrencyId] = 1
	,[intTermId] = ccCustomer.intTermsId
	,[dtmDate] = ccSiteHeader.dtmDate
	,[dtmShipDate]  = ccSiteHeader.dtmDate
	,[intEntitySalespersonId] = ccCustomer.intSalespersonId
	,[intEntityId] = @UserId
	,[ysnPost] = 1
	,[intItemId] =  CASE WHEN ccItem.strItem = 'Dealer Site Credits' THEN @intDealerSiteCreditItem ELSE (CASE WHEN ccSite.ysnPostNetToArCustomer = 0 THEN @intDealerSiteFeeItem ELSE -1 END) END
	,[strItemDescription] = ccItem.strItem
	,[dblQtyShipped] = CASE WHEN ccItem.strItem = 'Dealer Site Fees' THEN -1 ELSE 1 END
	,[dblPrice] = CASE WHEN ccItem.strItem = 'Dealer Site Credits' AND ccSite.ysnPostNetToArCustomer = 1 THEN ccSiteDetail.dblNet WHEN ccItem.strItem = 'Dealer Site Credits' AND ccSite.ysnPostNetToArCustomer = 0 THEN ccSiteDetail.dblGross ELSE (CASE WHEN ccSite.ysnPostNetToArCustomer = 0 THEN ccSiteDetail.dblFees ELSE 0 END) END
	,[intTaxGroupId] = null
	,[ysnRecomputeTax] = 0
	,[intSiteDetailId] = ccSiteDetail.intSiteDetailId
FROM tblCCSiteHeader ccSiteHeader 
INNER JOIN tblCCVendorDefault ccVendorDefault ON ccSiteHeader.intVendorDefaultId = ccVendorDefault.intVendorDefaultId 
INNER JOIN @CCRItemToARItem  ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
LEFT JOIN tblCCSiteDetail ccSiteDetail ON  ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
LEFT JOIN vyuCCCustomer ccCustomer ON ccCustomer.intCustomerId = ccSite.intCustomerId
WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId AND ccSite.intDealerSiteId IS NOT NULL

--REMOVE -1 items
DELETE FROM @EntriesForInvoice WHERE intItemId = -1

DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 

EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries	= @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= @UserId
		,@GroupingOption	= 7
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@CreatedIvoices	= @CreatedIvoices OUTPUT
		,@UpdatedIvoices	= @UpdatedIvoices OUTPUT

IF(ISNULL(@ErrorMessage,'') = '') SET @success = 1

END TRY

BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorState INT,
			@ErrorProc nvarchar(200);
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET	@success = 0
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
