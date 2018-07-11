CREATE PROCEDURE [dbo].[uspCCTransactionToARInvoice]
	 @intSiteHeaderId	INT
	,@UserId			INT	
	,@Post				BIT
	,@Recap				BIT = NULL
	,@ErrorMessage		NVARCHAR(250) = NULL OUTPUT
	,@CreatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@success			BIT = NULL OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

BEGIN

	DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable;
	DECLARE @EntriesForInvoicePerSite AS InvoiceIntegrationStagingTable;
	DECLARE @TaxDetails AS LineItemTaxDetailStagingTable;
	DECLARE @EntriesForInvoiceCount INT;
	DECLARE @EntriesForInvoiceActiveId INT;

    DECLARE @CCRItemToARItem TABLE
    (
        intSiteHeaderId int,
		intItemId int,
        strItem nvarchar(100)
    )
    DECLARE @intDealerSiteCreditItem INT, @intDealerSiteFeeItem INT, @intSalesAccountCategory INT;
    SELECT TOP 1 @intDealerSiteCreditItem = intDealerSiteCreditItem, @intDealerSiteFeeItem = intDealerSiteFeeItem FROM tblCCCompanyPreferenceOption
	SELECT TOP 1 @intSalesAccountCategory = intAccountCategoryId FROM tblGLAccountCategory WHERE strAccountCategory = 'Sales Account'

	IF(@intDealerSiteCreditItem IS NULL OR @intDealerSiteFeeItem IS NULL)
	BEGIN
		SET @ErrorMessage = 'Please setup Dealer Site Credit & Fee Item from Company Configuration.';
		SET @success = 0;
		RAISERROR(@ErrorMessage, 16, 1);
	END

	if not exists (select * from tblICItemAccount where intItemId = @intDealerSiteCreditItem AND intAccountCategoryId = @intSalesAccountCategory)
	begin
		SET @ErrorMessage = 'Please setup GL Sales Account category for Dealer Site Credit item.';
		SET @success = 0;
		RAISERROR(@ErrorMessage, 16, 1);
	end

	if not exists (select * from tblICItemAccount where intItemId = @intDealerSiteFeeItem AND intAccountCategoryId = @intSalesAccountCategory)
	begin
		SET @ErrorMessage = 'Please setup GL Sales Account category for Dealer Site Fee item.';
		SET @success = 0;
		RAISERROR(@ErrorMessage, 16, 1);
	end

    INSERT INTO @CCRItemToARItem VALUES (@intSiteHeaderId, @intDealerSiteCreditItem, 'Dealer Site Credits');
    INSERT INTO @CCRItemToARItem VALUES (@intSiteHeaderId, @intDealerSiteFeeItem, 'Dealer Site Fees');

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
        ,[ysnInventory]
		,[intSalesAccountId]
		,[strComments]
    )
    SELECT [strTransactionType] = 'Credit Memo' 
        ,[strSourceTransaction] = 'Credit Card Reconciliation'
        ,[intSourceId] = null
        ,[strSourceId] = ccSiteDetail.intSiteDetailId
        ,[intEntityCustomerId] = ccSite.intCustomerId
        ,[intCompanyLocationId] = ccSiteHeader.intCompanyLocationId
        ,[intCurrencyId] = ccVendor.intCurrencyId
        ,[intTermId] = ccCustomer.intTermsId
        ,[dtmDate] = ccSiteHeader.dtmDate
        ,[dtmShipDate]  = ccSiteHeader.dtmDate
        ,[intEntitySalespersonId] = ccCustomer.intSalespersonId
        ,[intEntityId] = @UserId
        ,[ysnPost] = @Post
        ,[intItemId] = CASE WHEN ccItem.strItem = 'Dealer Site Credits' THEN @intDealerSiteCreditItem ELSE (CASE WHEN ccSite.ysnPostNetToArCustomer = 0 THEN @intDealerSiteFeeItem ELSE -1 END) END
        ,[strItemDescription] = ccItem.strItem
        ,[dblQtyShipped] = 1 --CASE WHEN ccItem.strItem = 'Dealer Site Fees' THEN -1 ELSE 1 END
        ,[dblPrice] = CASE WHEN ccItem.strItem = 'Dealer Site Credits' AND ccSite.ysnPostNetToArCustomer = 1 AND ccSite.strSiteType != 'Dealer Site Shared Fees' THEN ccSiteDetail.dblNet 
			WHEN ccItem.strItem = 'Dealer Site Credits' AND ccSite.ysnPostNetToArCustomer = 0 AND ccSite.strSiteType != 'Dealer Site Shared Fees' THEN ccSiteDetail.dblGross
			WHEN ccItem.strItem = 'Dealer Site Credits' AND ccSite.ysnPostNetToArCustomer = 1 AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblNet + (ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100))
			WHEN ccItem.strItem = 'Dealer Site Credits' AND ccSite.ysnPostNetToArCustomer = 0 AND ccSite.strSiteType = 'Dealer Site Shared Fees' THEN ccSiteDetail.dblGross - (ccSiteDetail.dblFees * (ccSite.dblSharedFeePercentage / 100))
			ELSE (CASE WHEN ccSite.ysnPostNetToArCustomer = 0 THEN ccSiteDetail.dblFees ELSE 0 END) END
		,[intTaxGroupId] = null
        ,[ysnRecomputeTax] = 0
        ,[intSiteDetailId] = ccSiteDetail.intSiteDetailId
        ,[ysnInventory] = 1
		,[intSalesAccountId] = ItemAcc.intAccountId
		,[strComments] = ccSiteHeader.strCcdReference
    FROM tblCCSiteHeader ccSiteHeader 
    INNER JOIN vyuCCVendor ccVendor ON ccSiteHeader.intVendorDefaultId = ccVendor.intVendorDefaultId 
    INNER JOIN @CCRItemToARItem ccItem ON ccItem.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
    LEFT JOIN tblCCSiteDetail ccSiteDetail ON  ccSiteDetail.intSiteHeaderId = ccSiteHeader.intSiteHeaderId
    LEFT JOIN vyuCCSite ccSite ON ccSite.intSiteId = ccSiteDetail.intSiteId
    LEFT JOIN vyuCCCustomer ccCustomer ON ccCustomer.intCustomerId = ccSite.intCustomerId AND ccCustomer.intSiteId = ccSite.intSiteId
	INNER JOIN tblICItemAccount ItemAcc ON ItemAcc.intItemId = ccItem.intItemId AND ItemAcc.intAccountCategoryId = @intSalesAccountCategory
    WHERE ccSiteHeader.intSiteHeaderId = @intSiteHeaderId AND ccSite.intSiteId IS NOT NULL and ccSite.intCustomerId is not null
		--Fixes for CCR-315
		-- and ccSite.ysnPostNetToArCustomer = 1


    --REMOVE -1 items
	--and those sites that does not have customer
    DELETE FROM @EntriesForInvoice WHERE intItemId = -1	or intEntityCustomerId is null;

	set @EntriesForInvoiceCount = (select count(*) from @EntriesForInvoice);

	if (@EntriesForInvoiceCount > 0)
	begin

		IF(@Post = 1)
		BEGIN

			While (Select Count(*) From @EntriesForInvoice) > 0
			Begin
				Select Top 1 @EntriesForInvoiceActiveId = intId From @EntriesForInvoice;
				delete from @EntriesForInvoicePerSite;
				insert into @EntriesForInvoicePerSite
				(
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
					,[ysnInventory]
					,[intSalesAccountId]
					,[strComments]
				)
				select top 1
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
					,[ysnInventory]
					,[intSalesAccountId]
					,[strComments]
				from @EntriesForInvoice;

				EXEC [dbo].[uspARProcessInvoices]
						 @InvoiceEntries	= @EntriesForInvoicePerSite
						,@LineItemTaxEntries = @TaxDetails
						,@UserId			= @UserId
						,@GroupingOption	= 7
						,@RaiseError		= 1
						,@ErrorMessage		= @ErrorMessage OUTPUT
						,@CreatedIvoices	= @CreatedIvoices OUTPUT
						,@UpdatedIvoices	= @UpdatedIvoices OUTPUT

				IF(ISNULL(@ErrorMessage,'') = '') SET @success = 1

				Delete @EntriesForInvoice Where intId = @EntriesForInvoiceActiveId;
			End

		END
		ELSE IF (@Post = 0)
		BEGIN		
			DECLARE @intInvoiceId1 INT = NULL
		
			SELECT @intInvoiceId1 = arInvoiceDetail.intInvoiceId FROM tblCCSiteDetail ccSiteDetail 
				INNER JOIN tblARInvoiceDetail arInvoiceDetail ON arInvoiceDetail.intSiteDetailId = ccSiteDetail.intSiteDetailId
			WHERE ccSiteDetail.intSiteHeaderId = @intSiteHeaderId
			GROUP BY arInvoiceDetail.intInvoiceId
			IF(@intInvoiceId1 IS NOT NULL)
			BEGIN
				UPDATE @EntriesForInvoice SET intInvoiceId = @intInvoiceId1

				EXEC [dbo].[uspARProcessInvoices]
						 @InvoiceEntries	= @EntriesForInvoice
						,@LineItemTaxEntries = @TaxDetails
						,@UserId			= @UserId
						,@GroupingOption	= 7
						,@RaiseError		= 1
						,@ErrorMessage		= @ErrorMessage OUTPUT
						,@CreatedIvoices	= @CreatedIvoices OUTPUT
						,@UpdatedIvoices	= @UpdatedIvoices OUTPUT

				--DELETE Invoice Transaction
				DELETE FROM tblARInvoice WHERE intInvoiceId IN (
					SELECT DISTINCT C.intInvoiceId 
						FROM tblCCSiteHeader A 
					JOIN tblCCSiteDetail B ON B.intSiteHeaderId = A.intSiteHeaderId
					JOIN tblARInvoiceDetail C ON C.intSiteDetailId = B.intSiteDetailId
						WHERE A.intSiteHeaderId = @intSiteHeaderId)

			END

		END

	end
END