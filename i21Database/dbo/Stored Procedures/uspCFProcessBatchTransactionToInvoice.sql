

CREATE PROCEDURE [dbo].[uspCFProcessBatchTransactionToInvoice]
	  @TransactionId		NVARCHAR(MAX)
	 ,@UserId				INT 
	 ,@Post					BIT
	 ,@Recap				BIT
	 ,@BatchId				NVARCHAR(MAX)
	 ,@SuccessfulCount		INT						OUTPUT
	 ,@ErrorMessage			NVARCHAR(250)  = NULL	OUTPUT
	 ,@CreatedIvoices		NVARCHAR(MAX)  = NULL	OUTPUT
	 ,@UpdatedIvoices		NVARCHAR(MAX)  = NULL	OUTPUT
	 ,@LogId				INT			   = NULL	OUTPUT
	 

AS	

DECLARE @intRecordKey INT
DECLARE @strRecord INT
DECLARE @UserEntityId INT
DECLARE @EntriesForInvoice AS InvoiceStagingTable
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 
DECLARE @ysnRemoteTransaction INT
DECLARE @companyConfigTermId	INT = NULL
DECLARE @companyConfigFreightTermId	INT = NULL
DECLARE @tmpTransactionId TABLE
(
	intTransactionId	INT
)
DECLARE @tmpForeignTransactionId TABLE
(
	 ysnPostForeignSales		BIT
	,ysnPosted					BIT
	,intTransactionId			INT
	,intEntityId				INT
	,intCustomerEntityId		INT
	,intARLocationId			INT
	,dtmTransactionDate			DATETIME
	,dblAmount					NUMERIC(18,6)
	,strEntityName				NVARCHAR(MAX)
	,strLocationName			NVARCHAR(MAX)
	,strDescription				NVARCHAR(MAX)
	,strTransactionId			NVARCHAR(MAX)
	,strTransactionType			NVARCHAR(MAX)
	,strTransType				NVARCHAR(MAX)
)
DECLARE @tmpProcessedInvoice TABLE
(
	 intInvoiceId	INT
	,intSourceId	INT
	,ysnPosted		BIT
	,strMessage		NVARCHAR(MAX)
)


SELECT TOP 1 @companyConfigTermId = intTermsCode FROM tblCFCompanyPreference
IF(ISNULL(@companyConfigTermId,0) = 0)
BEGIN
	SET @ErrorMessage = 'Term code is required.'
	SET @CreatedIvoices = NULL
	SET @UpdatedIvoices = NULL

	RETURN
END

SELECT TOP 1 @companyConfigFreightTermId = intFreightTermId FROM tblCFCompanyPreference
IF(ISNULL(@companyConfigFreightTermId,0) = 0)
BEGIN
	SET @ErrorMessage = 'Freight Terms needs setup on Company Configuration for Card Fueling.'
	SET @CreatedIvoices = NULL
	SET @UpdatedIvoices = NULL

	RETURN
END

SET @UserEntityId = @UserId

IF(ISNULL(@Post,0) = 1)
BEGIN

	INSERT INTO @tmpTransactionId
	(
		intTransactionId
	)
	SELECT 
	DISTINCT RecordKey = intTransactionId 
	FROM vyuCFBatchPostTransactions 
	WHERE strTransType != 'Foreign Sale' OR ISNULL(ysnPostForeignSales,0) != 0

	INSERT INTO @tmpForeignTransactionId
	(
		 intTransactionId
		,ysnPostForeignSales
		,strTransType
		,dtmTransactionDate
		,strTransactionId
		,strTransactionType
		,ysnPosted
		,strDescription
		,dblAmount
		,intEntityId	
	)
	SELECT 
		 intTransactionId
		,ysnPostForeignSales
		,strTransType
		,dtmTransactionDate
		,strTransactionId
		,strTransactionType
		,ysnPosted
		,strDescription
		,dblAmount
		,intEntityId
	FROM vyuCFBatchPostTransactions 
	WHERE strTransType = 'Foreign Sale' AND ISNULL(ysnPostForeignSales,0) = 0

	
	IF @TransactionId != 'ALL'
	BEGIN
		DELETE FROM @tmpTransactionId WHERE intTransactionId NOT IN (SELECT Record FROM [fnCFSplitString](@TransactionId,',') )
		DELETE FROM @tmpForeignTransactionId WHERE intTransactionId NOT IN (SELECT Record FROM [fnCFSplitString](@TransactionId,',') )
	
	END

END
ELSE
BEGIN

	INSERT INTO @tmpTransactionId
	(
		intTransactionId
	)
	SELECT 
	DISTINCT RecordKey = tblCFBatchUnpostStagingTable.intTransactionId 
	FROM tblCFBatchUnpostStagingTable
	INNER JOIN tblCFTransaction 
	ON tblCFBatchUnpostStagingTable.intTransactionId = tblCFTransaction.intTransactionId
	WHERE tblCFTransaction.strTransactionType != 'Foreign Sale' 

	INSERT INTO @tmpForeignTransactionId
	(
		 intTransactionId
		,ysnPostForeignSales
		,strTransType
		,dtmTransactionDate
		,strTransactionId
		,strTransactionType
		,ysnPosted
		,strDescription
		,dblAmount
		,intEntityId	
	)
	SELECT 
		 tblCFBatchUnpostStagingTable.intTransactionId
		,0
		,tblCFTransaction.strTransactionType
		,tblCFBatchUnpostStagingTable.dtmTransactionDate
		,tblCFBatchUnpostStagingTable.strTransactionId
		,tblCFTransaction.strTransactionType
		,tblCFTransaction.ysnPosted
		,''
		,0
		,tblCFTransaction.intCustomerId
	FROM tblCFBatchUnpostStagingTable
	INNER JOIN tblCFTransaction 
	ON tblCFBatchUnpostStagingTable.intTransactionId = tblCFTransaction.intTransactionId
	WHERE tblCFTransaction.strTransactionType = 'Foreign Sale' 
END



--SELECT * FROM @tmpTransactionId
--SELECT * FROM @tmpForeignTransactionId
		
				INSERT INTO @EntriesForInvoice(
					 [intId]
					,[strTransactionType]
					,[strSourceTransaction]
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
					,[ysnUseOriginIdAsInvoiceNumber]
					,[strPONumber]
					,[strBOLNumber]
					,[strComments]
					,[intShipToLocationId]
					,[intBillToLocationId]
					,[ysnTemplate]
					,[ysnForgiven]
					,[ysnCalculated]
					,[ysnSplitted]
					,[intPaymentId]
					,[intSplitId]
					,[intLoadDistributionHeaderId]
					,[strActualCostId]
					,[intShipmentId]
					,[intTransactionId]
					,[intEntityId]
					,[ysnResetDetails]
					,[ysnPost]
					,[ysnRecap]
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
					,[ysnClearDetailTaxes]					
					,[intTempDetailIdForTaxes]
					,[strType]	
					,[dtmPostDate]
					,[ysnImpactInventory]
				)
				SELECT
					[intId]						= TI.intTransactionId
					,[strTransactionType]		= (case
												when (cfTrans.dblQuantity < 0 OR cfTrans.dblCalculatedNetPrice < 0)  then 'Credit Memo'
												else 'Invoice'
											  end)
					,[strSourceTransaction]					= 'CF Tran'
					,[intSourceId]							= cfTrans.intTransactionId
					,[strSourceId]							= cfTrans.strTransactionId
					,[intInvoiceId]							= I.intInvoiceId --cfTrans.intInvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= (case
												when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Foreign Sale' then cfNetwork.intCustomerId
												else cfCardAccount.intCustomerId
											  end)
					,[intCompanyLocationId]					= cfSiteItem.intARLocationId
					,[intCurrencyId]						= I.intCurrencyId
					,[intTermId]							= @companyConfigTermId
					,[dtmDate]								= cfTrans.dtmTransactionDate
					,[dtmDueDate]							= NULL
					,[dtmShipDate]							= cfTrans.dtmPostedDate
					,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
					,[intFreightTermId]						= @companyConfigFreightTermId--I.[intFreightTermId] 
					,[intShipViaId]							= I.[intShipViaId] 
					,[intPaymentMethodId]					= I.[intPaymentMethodId]
					,[strInvoiceOriginId]					= cfTrans.strTransactionId
					,[ysnUseOriginIdAsInvoiceNumber]		= 1
					,[strPONumber]							= ''
					,[strBOLNumber]							= ''
					,[strComments]							= ''
					,[intShipToLocationId]					= I.[intShipToLocationId]
					,[intBillToLocationId]					= I.[intBillToLocationId]
					,[ysnTemplate]							= 0
					,[ysnForgiven]							= 0
					,[ysnCalculated]						= 0  --0 OS
					,[ysnSplitted]							= 0
					,[intPaymentId]							= NULL
					,[intSplitId]							= NULL
					,[intLoadDistributionHeaderId]			= NULL
					,[strActualCostId]						= ''
					,[intShipmentId]						= NULL
					,[intTransactionId]						= TI.intTransactionId
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= @Post
					,[ysnRecap]								= @Recap
					,[intInvoiceDetailId]					= ISNULL((SELECT TOP 1 intInvoiceDetailId 
																FROM tblARInvoiceDetail 
																WHERE intInvoiceId = cfTrans.intInvoiceId
																ORDER BY dblQtyShipped DESC),cfTrans.intTransactionId)
					,[intItemId]							= cfSiteItem.intARItemId
					,[ysnInventory]							= 1
					,[strItemDescription]					= cfSiteItem.strDescription 
					,[intItemUOMId]							= cfSiteItem.intIssueUOMId
					,[dblQtyOrdered]						= ABS(cfTrans.dblQuantity)
					,[dblQtyShipped]						= ABS(cfTrans.dblQuantity) 
					,[dblDiscount]							= 0
					,[dblPrice]								= ABS(cfTrans.dblCalculatedNetPrice)
					,[ysnRefreshPrice]						= 0
					,[strMaintenanceType]					= ''
					,[strFrequency]							= ''
					,[dtmMaintenanceDate]					= NULL
					,[dblMaintenanceAmount]					= NULL
					,[dblLicenseAmount]						= NULL
					,[intTaxGroupId]						= cfSiteItem.intTaxGroupId
					,[ysnRecomputeTax]						= 0 
					--(CASE 
					--												WHEN @ysnRemoteTransaction = 1 OR cfSiteItem.intTaxGroupId IS NULL
					--												THEN 0
					--												ELSE 1
					--										   END)
					,[intSCInvoiceId]						= NULL
					,[strSCInvoiceNumber]					= ''
					,[intInventoryShipmentItemId]			= NULL
					,[strShipmentNumber]					= ''
					,[intSalesOrderDetailId]				= NULL
					,[strSalesOrderNumber]					= ''
					,[intContractHeaderId]					= cfTrans.intContractId
					,[intContractDetailId]					= cfTrans.intContractDetailId
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
					,[ysnClearDetailTaxes]					= 0
					,[intTempDetailIdForTaxes]				= cfTrans.intTransactionId
					,[strType]								= 'CF Tran'
					,[dtmPostDate]							= cfTrans.dtmPostedDate
					,[ysnImpactInventory]					= 
															(case
															when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Remote' 
															OR  RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Extended Remote'
															OR ISNULL((SELECT TOP 1 ysnCaptiveSite FROM tblCFSite where intSiteId = cfTrans.intSiteId),0) = 1
															then 0
															else 1
															end)
				FROM tblCFTransaction cfTrans
				INNER JOIN @tmpTransactionId TI
					ON cfTrans.intTransactionId = TI.intTransactionId
				INNER JOIN tblCFNetwork cfNetwork
				ON cfTrans.intNetworkId = cfNetwork.intNetworkId
				LEFT JOIN (SELECT icfCards.intCardId
								   ,icfAccount.intAccountId
								   ,icfAccount.intSalesPersonId
								   ,icfAccount.intCustomerId
								   ,icfAccount.intTermsCode	 
							FROM tblCFCard icfCards
							INNER JOIN tblCFAccount icfAccount
							ON icfCards.intAccountId = icfAccount.intAccountId)
							AS cfCardAccount
				ON cfTrans.intCardId = cfCardAccount.intCardId
				INNER JOIN (SELECT  icfSite.* 
									,icfItem.intItemId
									,icfItem.intARItemId
									,iicItemLoc.intItemLocationId
									,iicItemLoc.intIssueUOMId
									,iicItem.strDescription
							FROM tblCFSite icfSite
							INNER JOIN tblCFNetwork icfNetwork
							ON icfNetwork.intNetworkId = icfSite.intNetworkId
							INNER JOIN tblCFItem icfItem
							ON icfSite.intSiteId = icfItem.intSiteId 
							OR icfNetwork.intNetworkId = icfItem.intNetworkId
							INNER JOIN tblICItem iicItem
							ON icfItem.intARItemId = iicItem.intItemId
							LEFT JOIN tblICItemLocation iicItemLoc
							ON iicItemLoc.intLocationId = icfSite.intARLocationId 
							AND iicItemLoc.intItemId = icfItem.intARItemId)
							AS cfSiteItem
				ON (cfTrans.intSiteId = cfSiteItem.intSiteId AND cfTrans.intNetworkId = cfSiteItem.intNetworkId)
				AND cfSiteItem.intItemId = cfTrans.intProductId
				--INNER JOIN (SELECT * 
				--			FROM tblCFTransactionPrice
				--			WHERE strTransactionPriceId = 'Net Price')
				--			AS cfTransPrice
				--ON 	cfTrans.intTransactionId = cfTransPrice.intTransactionId
				LEFT OUTER JOIN
	tblARInvoice I
		ON cfTrans.intInvoiceId = I.intInvoiceId
				---------------EXPENSE TRANS-------------
				INSERT INTO @EntriesForInvoice(
					 [intId]
					,[strTransactionType]
					,[strSourceTransaction]
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
					,[ysnUseOriginIdAsInvoiceNumber]
					,[strPONumber]
					,[strBOLNumber]
					,[strComments]
					,[intShipToLocationId]
					,[intBillToLocationId]
					,[ysnTemplate]
					,[ysnForgiven]
					,[ysnCalculated]
					,[ysnSplitted]
					,[intPaymentId]
					,[intSplitId]
					,[intLoadDistributionHeaderId]
					,[strActualCostId]
					,[intShipmentId]
					,[intTransactionId]
					,[intEntityId]
					,[ysnResetDetails]
					,[ysnPost]
					,[ysnRecap]
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
					,[ysnClearDetailTaxes]					
					,[intTempDetailIdForTaxes]
					,[strType]	
					,[dtmPostDate]
					,[ysnImpactInventory]
				)
				SELECT
					 [intId]						= TI.intTransactionId
					,[strTransactionType]		= (case
												when (cfTrans.dblQuantity < 0 OR cfTrans.dblCalculatedNetPrice < 0)  then 'Credit Memo'
												else 'Invoice'
											  end)
					,[strSourceTransaction]					= 'CF Tran'
					,[intSourceId]							= cfTrans.intTransactionId
					,[strSourceId]							= cfTrans.strTransactionId
					,[intInvoiceId]							= I.intInvoiceId --cfTrans.intInvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= (case
												when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Foreign Sale' then cfNetwork.intCustomerId
												else cfCardAccount.intCustomerId
											  end)
					,[intCompanyLocationId]					= cfTrans.intARLocationId
					,[intCurrencyId]						= I.intCurrencyId
					,[intTermId]							= @companyConfigTermId
					,[dtmDate]								= cfTrans.dtmTransactionDate
					,[dtmDueDate]							= NULL
					,[dtmShipDate]							= cfTrans.dtmTransactionDate
					,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
					,[intFreightTermId]						= @companyConfigFreightTermId--I.[intFreightTermId] 
					,[intShipViaId]							= I.[intShipViaId] 
					,[intPaymentMethodId]					= I.[intPaymentMethodId]
					,[strInvoiceOriginId]					= cfTrans.strTransactionId
					,[ysnUseOriginIdAsInvoiceNumber]		= 1
					,[strPONumber]							= cfTrans.strPONumber
					,[strBOLNumber]							= ''
					,[strComments]							= ''
					,[intShipToLocationId]					= I.[intShipToLocationId]
					,[intBillToLocationId]					= I.[intBillToLocationId]
					,[ysnTemplate]							= 0
					,[ysnForgiven]							= 0
					,[ysnCalculated]						= 0  --0 OS
					,[ysnSplitted]							= 0
					,[intPaymentId]							= NULL
					,[intSplitId]							= NULL
					,[intLoadDistributionHeaderId]			= NULL
					,[strActualCostId]						= ''
					,[intShipmentId]						= NULL
					,[intTransactionId]						= TI.intTransactionId
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= @Post
					,[ysnRecap]								= @Recap
					,[intInvoiceDetailId]					= ISNULL((SELECT TOP 1 intInvoiceDetailId 
																FROM tblARInvoiceDetail 
																WHERE intInvoiceId = cfTrans.intInvoiceId AND ISNULL(dblQtyShipped,0) < 0),cfTrans.intTransactionId+1)
					,[intItemId]							= cfTrans.intExpensedItemId
					,[ysnInventory]							= 1
					,[strItemDescription]					=  icItem.strDescription  
					,[intItemUOMId]							=  iicItemLoc.intIssueUOMId
					,[dblQtyOrdered]						= CASE WHEN cfTrans.dblQuantity < 0
																THEN 1
																ELSE -1
																END
					,[dblQtyShipped]						= CASE WHEN cfTrans.dblQuantity < 0
																THEN 1
																ELSE -1
																END
					,[dblDiscount]							= 0
					,[dblPrice]								= ABS(cfTrans.dblCalculatedTotalPrice)
					,[ysnRefreshPrice]						= 0
					,[strMaintenanceType]					= ''
					,[strFrequency]							= ''
					,[dtmMaintenanceDate]					= NULL
					,[dblMaintenanceAmount]					= NULL
					,[dblLicenseAmount]						= NULL
					,[intTaxGroupId]						= NULL
					,[ysnRecomputeTax]						= 0 
					--(CASE 
					--												WHEN @ysnRemoteTransaction = 1 OR cfSiteItem.intTaxGroupId IS NULL
					--												THEN 0
					--												ELSE 1
					--										   END)
					,[intSCInvoiceId]						= NULL
					,[strSCInvoiceNumber]					= ''
					,[intInventoryShipmentItemId]			= NULL
					,[strShipmentNumber]					= ''
					,[intSalesOrderDetailId]				= NULL
					,[strSalesOrderNumber]					= ''
					,[intContractHeaderId]					= cfTrans.intContractId
					,[intContractDetailId]					= cfTrans.intContractDetailId
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
					,[ysnClearDetailTaxes]					= 0
					,[intTempDetailIdForTaxes]				= 0
					,[strType]								= 'CF Tran'
					,[dtmPostDate]							= cfTrans.dtmPostedDate
					,[ysnImpactInventory]					= 
															(case
															when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Remote' 
															OR  RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Extended Remote'
															OR ISNULL((SELECT TOP 1 ysnCaptiveSite FROM tblCFSite where intSiteId = cfTrans.intSiteId),0) = 1
															then 0
															else 1
															end)
				FROM tblCFTransaction cfTrans
				INNER JOIN @tmpTransactionId TI
				ON cfTrans.intTransactionId = TI.intTransactionId
				INNER JOIN tblCFNetwork cfNetwork
				ON cfTrans.intNetworkId = cfNetwork.intNetworkId

				LEFT JOIN (SELECT icfCards.intCardId
								   ,icfAccount.intAccountId
								   ,icfAccount.intSalesPersonId
								   ,icfAccount.intCustomerId
								   ,icfAccount.intTermsCode	 
							FROM tblCFCard icfCards
							INNER JOIN tblCFAccount icfAccount
							ON icfCards.intAccountId = icfAccount.intAccountId)
							AS cfCardAccount
				ON cfTrans.intCardId = cfCardAccount.intCardId

				INNER JOIN tblICItem as icItem 
				ON cfTrans.intExpensedItemId = icItem.intItemId

				LEFT JOIN tblICItemLocation iicItemLoc
				ON iicItemLoc.intLocationId = cfTrans.intARLocationId
				AND iicItemLoc.intItemId = cfTrans.intExpensedItemId

				LEFT OUTER JOIN
					tblARInvoice I
						ON cfTrans.intInvoiceId = I.intInvoiceId
				WHERE ISNULL(ysnExpensed,0) = 1
				---------------EXPENSE TRANS-------------
				
				
				INSERT INTO @TaxDetails
					(
					[intDetailId] 
					,[intTaxGroupId]
					,[intTaxCodeId]
					,[intTaxClassId]
					,[strTaxableByOtherTaxes]
					,[strCalculationMethod]
					,[dblRate]
					,[intTaxAccountId]
					,[dblTax]
					,[dblAdjustedTax]
					,[ysnTaxAdjusted]
					,[ysnSeparateOnInvoice]
					,[ysnCheckoffTax]
					,[ysnTaxExempt]
					,[ysnTaxOnly]
					,[strNotes]
					,[intTempDetailIdForTaxes]
					,[ysnClearExisting])
				SELECT
				[intDetailId]				= ISNULL((SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = cfTransaction.intInvoiceId ORDER BY dblQtyShipped DESC),TI.intTransactionId)
				,[intTaxGroupId]			= NULL
				,[intTaxCodeId]				= cfTaxCode.intTaxCodeId
				,[intTaxClassId]			= cfTaxCode.intTaxClassId
				,[strTaxableByOtherTaxes]	= cfTaxCode.strTaxableByOtherTaxes
				,[strCalculationMethod]		= (select top 1 strCalculationMethod from tblSMTaxCodeRate where dtmEffectiveDate < cfTransaction.dtmTransactionDate AND intTaxCodeId = cfTransactionTax.intTaxCodeId order by dtmEffectiveDate desc)
				,[dblRate]					= cfTransactionTax.dblTaxRate
				,[intTaxAccountId]			= cfTaxCode.intSalesTaxAccountId
				,[dblTax]					= ABS(cfTransactionTax.dblTaxCalculatedAmount)
				,[dblAdjustedTax]			= ABS(cfTransactionTax.dblTaxCalculatedAmount)--(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE
				,[ysnTaxAdjusted]			= 0
				,[ysnSeparateOnInvoice]		= 0 
				,[ysnCheckoffTax]			= cfTaxCode.ysnCheckoffTax
				,[ysnTaxExempt]				= cfTransactionTax.ysnTaxExempt
				,[ysnTaxOnly]				= cfTaxCode.[ysnTaxOnly]
				,[strNotes]					= ''
				,[intTempDetailIdForTaxes]	= TI.intTransactionId
				,[ysnClearExisting]			= 1
				FROM 
				tblCFTransaction cfTransaction
				INNER JOIN @tmpTransactionId TI
					ON cfTransaction.intTransactionId = TI.intTransactionId
				INNER JOIN tblCFTransactionTax cfTransactionTax
				ON cfTransaction.intTransactionId = cfTransactionTax.intTransactionId
				INNER JOIN tblSMTaxCode  cfTaxCode
				ON cfTransactionTax.intTaxCodeId = cfTaxCode.intTaxCodeId
				
	DECLARE @intForeignTransCount INT = 0
	DECLARE @dtmDate DATETIME

	IF (ISNULL(@Recap,0) = 0 AND (@Post = 1))
	BEGIN
		SET @dtmDate = GETDATE();
		SELECT @intForeignTransCount = COUNT(*) FROM @tmpForeignTransactionId
		UPDATE tblCFTransaction SET ysnPosted = 1 WHERE intTransactionId IN (SELECT intTransactionId FROM @tmpForeignTransactionId)
	
		INSERT INTO tblCFPostForeignTransResult
		(
		 strBatchId
		,intTransactionId
		,strTransactionId
		,strTransactionType
		,strDescription
		,dtmDate
		,intEntityId
		)
		SELECT 
		 @BatchId
		,intTransactionId
		,strTransactionId
		,strTransactionType
		,'Transaction successfully posted.'
		,@dtmDate
		,intEntityId
		FROM 
		@tmpForeignTransactionId
	END
	ELSE IF (ISNULL(@Recap,0) = 0 AND (@Post = 0))
	BEGIN
		SET @dtmDate = GETDATE();
		SELECT @intForeignTransCount = COUNT(*) FROM @tmpForeignTransactionId
		UPDATE tblCFTransaction SET ysnPosted = 0 WHERE intTransactionId IN (SELECT intTransactionId FROM @tmpForeignTransactionId)
	
		INSERT INTO tblCFPostForeignTransResult
		(
		 strBatchId
		,intTransactionId
		,strTransactionId
		,strTransactionType
		,strDescription
		,dtmDate
		,intEntityId
		)
		SELECT 
		 @BatchId
		,intTransactionId
		,strTransactionId
		,strTransactionType
		,'Transaction successfully unposted.'
		,@dtmDate
		,intEntityId
		FROM 
		@tmpForeignTransactionId
	END

	
	--DECLARE @LogId INT

	SELECT * INTO #tblCFEntriesForInvoice FROM @EntriesForInvoice

	EXEC [dbo].[uspARProcessInvoicesByBatch]
		 --@InvoiceEntries	= @InvoiceEntriesTEMP
		 @InvoiceEntries	= @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= @UserId
		,@GroupingOption	= 11
		,@RaiseError		= 0
		,@BatchId			= @BatchId
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@LogId				= @LogId OUTPUT


	--================--
	SET @SuccessfulCount = 0;
	INSERT INTO @tmpProcessedInvoice
	(
		 intInvoiceId
		,intSourceId
		,ysnPosted 
		,strMessage
	)
	SELECT DISTINCT 
		intInvoiceId
		,intSourceId
		,ysnPosted
		,strMessage
	FROM tblARInvoiceIntegrationLogDetail
	WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ISNULL(ysnHeader,0) = 1 

	
	

	IF (ISNULL(@Recap,0) = 0 AND (@Post = 1))
	BEGIN

		--========SET TRANS POSTED INDICATOR AND INVOICE ID==========--

		SELECT @SuccessfulCount = Count(intInvoiceId) 
		FROM @tmpProcessedInvoice
		WHERE ISNULL(ysnPosted,0) = 1

		UPDATE CFTran
		SET 
			 CFTran.ysnPosted	 = ARL.ysnPosted
			,CFTran.intInvoiceId = ARL.intInvoiceId
		FROM
		tblCFTransaction CFTran
		INNER JOIN tblARInvoice ARL
		ON CFTran.intTransactionId = ARL.intTransactionId
		INNER JOIN #tblCFEntriesForInvoice EFI
		ON CFTran.intTransactionId = EFI.intSourceId


		--========SET CARD LAST USED DATE ==========--
		UPDATE CFC
		SET 
			CFC.dtmLastUsedDated = CFT.dtmTransactionDate
		FROM
			tblCFCard CFC
		INNER JOIN
			(	SELECT CFTran.intCardId, MAX(CFTran.dtmTransactionDate) AS dtmTransactionDate
				FROM
				tblCFTransaction CFTran
				INNER JOIN tblARInvoice ARL
				ON CFTran.intTransactionId = ARL.intTransactionId 
				INNER JOIN #tblCFEntriesForInvoice EFI
				ON CFTran.intTransactionId = EFI.intSourceId
				WHERE ARL.ysnPosted = 1
				GROUP BY  CFTran.intCardId
			) CFT
				ON CFC.intCardId = CFT.intCardId					
		WHERE 
			(CFC.dtmLastUsedDated < CFT.dtmTransactionDate OR CFC.dtmLastUsedDated IS NULL)

	END
	ELSE IF (ISNULL(@Recap,0) = 0 AND ISNULL(@Post,0) = 0)
	BEGIN

		SELECT @SuccessfulCount = Count(intInvoiceId) 
		FROM @tmpProcessedInvoice
		WHERE ISNULL(ysnPosted,0) = 0

		UPDATE CFTran
		SET 
			 CFTran.ysnPosted	 = ARL.ysnPosted
		FROM
		tblCFTransaction CFTran
		INNER JOIN tblARInvoice ARL
		ON CFTran.intTransactionId = ARL.intTransactionId
		INNER JOIN #tblCFEntriesForInvoice EFI
		ON CFTran.intTransactionId = EFI.intSourceId


		UPDATE CFC
		SET 
			CFC.dtmLastUsedDated = CFT.dtmTransactionDate
		FROM
			tblCFCard CFC
		INNER JOIN
			(	SELECT CFTran.intCardId, MAX(CFTran.dtmTransactionDate) AS dtmTransactionDate
				FROM
				tblCFTransaction CFTran
				INNER JOIN tblARInvoice ARL
				ON CFTran.intTransactionId = ARL.intTransactionId 
				INNER JOIN #tblCFEntriesForInvoice EFI
				ON CFTran.intTransactionId = EFI.intSourceId
				WHERE ARL.ysnPosted = 1
				GROUP BY  CFTran.intCardId
			) CFT
				ON CFC.intCardId = CFT.intCardId					
		WHERE 
			(CFC.dtmLastUsedDated < CFT.dtmTransactionDate OR CFC.dtmLastUsedDated IS NULL)

		
		
		UPDATE tblCFBatchUnpostStagingTable 
		SET strResult = CASE WHEN( ISNULL(tblCFTransaction.ysnPosted,0) = 0 AND ISNULL(tblARInvoice.ysnPosted,0) = 0 ) 
						THEN 'Successfully unposted transaction'
						ELSE 'Unable to unpost transaction'
						END
		FROM 
		tblCFBatchUnpostStagingTable as t1 
		INNER JOIN tblCFTransaction ON t1.intTransactionId = tblCFTransaction.intTransactionId
		INNER JOIN tblARInvoice ON t1.intTransactionId = tblARInvoice.intTransactionId

		--UPDATE tblCFBatchUnpostStagingTable SET strResult = 'Successfully unposted transaction'
		--WHERE intTransactionId IN (SELECT intSourceId FROM @tmpProcessedInvoice)

		--UPDATE tblCFBatchUnpostStagingTable 
		--SET strResult = 'Unable to unpost transaction > ' + strMessage
		--FROM tblARInvoiceIntegrationLogDetail
		--WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 0 AND ISNULL(ysnHeader,0) = 1 
		--AND intSourceId = tblCFBatchUnpostStagingTable.intTransactionId
		

	END


	SET @SuccessfulCount = @SuccessfulCount + @intForeignTransCount

	--================--