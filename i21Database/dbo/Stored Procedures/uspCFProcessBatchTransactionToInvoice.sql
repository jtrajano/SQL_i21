﻿CREATE PROCEDURE [dbo].[uspCFProcessBatchTransactionToInvoice]
	 @TransactionId		NVARCHAR(MAX)
	,@UserId			INT	
	,@Post				BIT
	,@Recap				BIT
	,@ErrorMessage		NVARCHAR(250) OUTPUT
	,@CreatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices	NVARCHAR(MAX)  = NULL OUTPUT
AS	

DECLARE @intRecordKey INT
DECLARE @strRecord INT
DECLARE @UserEntityId INT
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable

SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserId),@UserId)

SELECT DISTINCT RecordKey INTO #tmpTransactionId
FROM [fnCFSplitString](@TransactionId,',') 

	WHILE (EXISTS(SELECT 1 FROM #tmpTransactionId ))
			BEGIN
				SELECT @intRecordKey = RecordKey FROM #tmpTransactionId
				SELECT @strRecord = CAST(Record AS INT) FROM [fnCFSplitString](@TransactionId,',') WHERE RecordKey = @intRecordKey
		
				INSERT INTO @EntriesForInvoice(
					 [strSourceTransaction]
					,[intSourceId]
					,[strSourceId]
					,[intInvoiceId]
					,[intEntityCustomerId]
					,[intCompanyLocationId]
					,[intCurrencyId]
					,[intTermId]
					,[dtmDate]
					,[dtmDueDate]
					,[dtmShipDate]
					,[intEntitySalespersonId]
					,[intFreightTermId]
					,[intShipViaId]
					,[intPaymentMethodId]
					,[strInvoiceOriginId]
					,[strPONumber]
					,[strBOLNumber]
					,[strDeliverPickup]
					,[strComments]
					,[intShipToLocationId]
					,[intBillToLocationId]
					,[ysnTemplate]
					,[ysnForgiven]
					,[ysnCalculated]
					,[ysnSplitted]
					,[intPaymentId]
					,[intSplitId]
					,[intDistributionHeaderId]
					,[strActualCostId]
					,[intShipmentId]
					,[intTransactionId]
					,[intEntityId]
					,[ysnResetDetails]
					,[ysnPost]
					,[intInvoiceDetailId]
					,[intItemId]
					,[ysnInventory]
					,[strItemDescription]
					,[intItemUOMId]
					,[dblQtyOrdered]
					,[dblQtyShipped]
					,[dblDiscount]
					,[dblPrice]
					,[ysnRefreshPrice]
					,[strMaintenanceType]
					,[strFrequency]
					,[dtmMaintenanceDate]
					,[dblMaintenanceAmount]
					,[dblLicenseAmount]
					,[intTaxGroupId]
					,[ysnRecomputeTax]
					,[intSCInvoiceId]
					,[strSCInvoiceNumber]
					,[intInventoryShipmentItemId]
					,[strShipmentNumber]
					,[intSalesOrderDetailId]
					,[strSalesOrderNumber]
					,[intContractHeaderId]
					,[intContractDetailId]
					,[intShipmentPurchaseSalesContractId]
					,[intTicketId]
					,[intTicketHoursWorkedId]
					,[intSiteId]
					,[strBillingBy]
					,[dblPercentFull]
					,[dblNewMeterReading]
					,[dblPreviousMeterReading]
					,[dblConversionFactor]
					,[intPerformerId]
					,[ysnLeaseBilling]
					,[ysnVirtualMeterReading]
				)
				SELECT
					 [strSourceTransaction]					= 'Card Fueling Transaction'
					,[intSourceId]							= cfTrans.intTransactionId
					,[strSourceId]							= ''
					,[intInvoiceId]							= cfTrans.intInvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= cfCardAccount.intCustomerId
					,[intCompanyLocationId]					= cfSiteItem.intARLocationId
					,[intCurrencyId]						= 1
					,[intTermId]							= cfCardAccount.intTermsCode
					,[dtmDate]								= cfTrans.dtmTransactionDate
					,[dtmDueDate]							= NULL
					,[dtmShipDate]							= cfTrans.dtmTransactionDate
					,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
					,[intFreightTermId]						= NULL 
					,[intShipViaId]							= NULL 
					,[intPaymentMethodId]					= NULL
					,[strInvoiceOriginId]					= ''
					,[strPONumber]							= ''
					,[strBOLNumber]							= ''
					,[strDeliverPickup]						= cfTrans.strDeliveryPickupInd
					,[strComments]							= ''
					,[intShipToLocationId]					= NULL
					,[intBillToLocationId]					= NULL
					,[ysnTemplate]							= 0
					,[ysnForgiven]							= 0
					,[ysnCalculated]						= 1
					,[ysnSplitted]							= 0
					,[intPaymentId]							= NULL
					,[intSplitId]							= NULL
					,[intDistributionHeaderId]				= NULL
					,[strActualCostId]						= ''
					,[intShipmentId]						= NULL
					,[intTransactionId]						= cfTrans.intTransactionId
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= @Post
	
					,[intInvoiceDetailId]					= NULL
					,[intItemId]							= cfSiteItem.intARItemId
					,[ysnInventory]							= 1
					,[strItemDescription]					= cfSiteItem.strDescription 
					,[intItemUOMId]							= cfSiteItem.intIssueUOMId
					,[dblQtyOrdered]						= cfTrans.dblQuantity
					,[dblQtyShipped]						= cfTrans.dblQuantity 
					,[dblDiscount]							= 0
					,[dblPrice]								= cfTransPrice.dblCalculatedAmount
					,[ysnRefreshPrice]						= 0
					,[strMaintenanceType]					= ''
					,[strFrequency]							= ''
					,[dtmMaintenanceDate]					= NULL
					,[dblMaintenanceAmount]					= NULL
					,[dblLicenseAmount]						= NULL
					,[intTaxGroupId]						= cfSiteItem.intTaxGroupMaster
					,[ysnRecomputeTax]						= 1
					,[intSCInvoiceId]						= NULL
					,[strSCInvoiceNumber]					= ''
					,[intInventoryShipmentItemId]			= NULL
					,[strShipmentNumber]					= ''
					,[intSalesOrderDetailId]				= NULL
					,[strSalesOrderNumber]					= ''
					,[intContractHeaderId]					= ctContracts.intContractHeaderId
					,[intContractDetailId]					= ctContracts.intContractDetailId
					,[intShipmentPurchaseSalesContractId]	= NULL
					,[intTicketId]							= NULL
					,[intTicketHoursWorkedId]				= NULL
					,[intSiteId]							= NULL
					,[strBillingBy]							= ''
					,[dblPercentFull]						= NULL
					,[dblNewMeterReading]					= NULL
					,[dblPreviousMeterReading]				= NULL
					,[dblConversionFactor]					= NULL
					,[intPerformerId]						= NULL
					,[ysnLeaseBilling]						= NULL
					,[ysnVirtualMeterReading]				= NULL
				FROM tblCFTransaction cfTrans
				INNER JOIN (SELECT icfCards.intCardId
								   ,icfAccount.intAccountId
								   ,icfAccount.intSalesPersonId
								   ,icfAccount.intCustomerId
								   ,icfAccount.intTermsCode	 
							FROM tblCFCard icfCards
							INNER JOIN tblCFAccount icfAccount
							ON icfCards.intAccountId = icfAccount.intAccountId)
							AS cfCardAccount
				ON cfTrans.intCardId = cfCardAccount.intCardId
				INNER JOIN (SELECT icfSite.* 
								   ,icfItem.intItemId
								   ,icfItem.intARItemId
								   ,icfItem.intTaxGroupMaster
								   ,iicItemLoc.intItemLocationId
								   ,iicItemLoc.intIssueUOMId
								   ,iicItem.strDescription
							FROM tblCFSite icfSite
							INNER JOIN tblCFItem icfItem
							ON icfSite.intSiteId = icfItem.intSiteId
							INNER JOIN tblICItem iicItem
							ON icfItem.intARItemId = iicItem.intItemId
							INNER JOIN tblICItemLocation iicItemLoc
							ON iicItemLoc.intItemLocationId = icfSite.intARLocationId)
							AS cfSiteItem
				ON cfTrans.intSiteId = cfSiteItem.intSiteId
				INNER JOIN (SELECT * 
							FROM tblCFTransactionPrice
							WHERE strTransactionPriceId = 'Net Price')
							AS cfTransPrice
				ON 	cfTrans.intTransactionId = cfTransPrice.intTransactionId
				INNER JOIN tblCFNetwork cfNetwork
				ON cfTrans.intNetworkId = cfNetwork.intNetworkId
				LEFT JOIN vyuCTContractDetailView ctContracts
				ON cfTrans.intContractId = ctContracts.intContractDetailId
				WHERE cfTrans.intTransactionId = @strRecord

				DELETE FROM #tmpTransactionId WHERE RecordKey = @intRecordKey
			
			END

	DROP TABLE #tmpTransactionId
	
	BEGIN TRANSACTION
	EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries	= @EntriesForInvoice
		,@UserId			= @UserId
		,@GroupingOption	= 0
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@CreatedIvoices	= @CreatedIvoices OUTPUT
		,@UpdatedIvoices	= @UpdatedIvoices OUTPUT


	IF (@ErrorMessage IS NULL)
		BEGIN
			COMMIT TRANSACTION
		END
	ELSE
		BEGIN
			ROLLBACK TRANSACTION
		END

	--IF (@CreatedIvoices IS NOT NULL AND @ErrorMessage IS NULL)
	--BEGIN
	--	UPDATE tblCFTransaction 
	--	SET intInvoiceId = @CreatedIvoices,
	--		ysnPosted = 1 
	--	WHERE intTransactionId = @TransactionId
	--END
