CREATE PROCEDURE [dbo].[uspCCTransactionToARInvoice]
	 @intSiteHeaderId	INT
	,@UserId			INT	
	,@Post				BIT	= NULL
	,@Recap				BIT	= NULL
	,@InvoiceId			INT = NULL
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

SET @success = 0

INSERT INTO @EntriesForInvoice(
	 [strSourceTransaction]
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
	,[dblQtyShipped]
	,[dblPrice]
	,[intTaxGroupId]
	,[ysnRecomputeTax]
)
SELECT [strSourceTransaction] = 'Credit Card Reconciliation'
	,[intSourceId] = ccSiteHeader.intSiteHeaderId
	,[strSourceId] = ccSiteHeader.intSiteHeaderId
	,[intEntityCustomerId] = ccSite.intCustomerId
	,[intCompanyLocationId] = ccVendorDefault.intCompanyLocationId
	,[intCurrencyId] = 1
	,[intTermId] = ccCustomer.intTermsId
	,[dtmDate] = ccSiteHeader.dtmDate
	,[dtmShipDate]  = ccSiteHeader.dtmDate
	,[intEntitySalespersonId] = ccCustomer.intSalespersonId
	,[intEntityId] = @UserId
	,[dblQtyShipped] = 1
	,[dblPrice] = CASE WHEN ccSite.ysnPostNetToArCustomer = 1 THEN ccSiteDetail.dblNet ELSE ccSiteDetail.dblFees END
	,[intTaxGroupId] = null
	,[ysnRecomputeTax] = 0
FROM tblCCSiteHeader ccSiteHeader 
LEFT JOIN tblCCVendorDefault ccVendorDefault ON ccSiteHeader.intVendorDefaultId = ccVendorDefault.intVendorDefaultId 
LEFT JOIN tblCCSiteDetail ccSiteDetail ON  ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
LEFT JOIN vyuCCCustomer ccCustomer ON ccCustomer.intCustomerId = ccSite.intCustomerId
WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId

DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 

EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries	= @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= @UserId
		,@GroupingOption	= 11
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

