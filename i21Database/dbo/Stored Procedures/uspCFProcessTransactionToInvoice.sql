CREATE PROCEDURE [dbo].[uspCFProcessTransactionToInvoice]
	 @TransactionId				INT
	,@UserId					INT	
	,@Post						BIT	= NULL
	,@Recap						BIT	= NULL
	,@InvoiceId					INT = NULL
	,@ErrorMessage				NVARCHAR(250) OUTPUT
	,@CreatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdatedIvoices			NVARCHAR(MAX)  = NULL OUTPUT
	,@UpdateAvailableDiscount	BIT = NULL
	,@Discount					NUMERIC(18,6) = 0.0
AS	

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @UserEntityId INT
SET @UserEntityId = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @UserId),@UserId)

DECLARE @LogId INT

DECLARE @EntriesForInvoice AS InvoiceStagingTable
DECLARE @ysnRemoteTransaction INT
DECLARE @strItemTermDiscountBy NVARCHAR(MAX)

DECLARE @companyConfigTermId	INT = NULL
DECLARE @invalid				BIT = 0
DECLARE @transactionDate		DATETIME
DECLARE @intCardId				INT

SELECT TOP 1 @companyConfigTermId = intTermsCode FROM tblCFCompanyPreference
IF(ISNULL(@companyConfigTermId,0) = 0)
BEGIN
	SET @ErrorMessage = 'Term code is required.'
	SET @CreatedIvoices = NULL
	SET @UpdatedIvoices = NULL

	RETURN
END


SELECT TOP 1 
@invalid = ysnInvalid, 
@transactionDate = dtmTransactionDate,
@intCardId = intCardId
FROM tblCFTransaction where intTransactionId = @TransactionId
IF(@invalid = 1)
BEGIN
	SET @ErrorMessage = 'Unable to post invalid transaction'
	SET @CreatedIvoices = NULL
	SET @UpdatedIvoices = NULL

	RETURN
END

IF (@UpdateAvailableDiscount = 1)
BEGIN
	SET @ysnRemoteTransaction = 0
	SET @Post = NULL
	SET @strItemTermDiscountBy = 'Amount'
END
ELSE
BEGIN
	SELECT @ysnRemoteTransaction = (CASE 
								WHEN strTransactionType = 'Extended Remote' OR strTransactionType = 'Remote'
								THEN 1
								ELSE 0
							END
							)
	from tblCFTransaction 
	where intTransactionId = @TransactionId

	SET @Discount = 0.0
END

BEGIN TRANSACTION
INSERT INTO @EntriesForInvoice(
	 [strTransactionType]
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
	,[intLoadDistributionHeaderId]
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
	,[ysnClearDetailTaxes]					
	,[intTempDetailIdForTaxes]
	,[strType]
	,[ysnUpdateAvailableDiscount]
	,[strItemTermDiscountBy]
	,[dblItemTermDiscount]
	,[dtmPostDate]
)
SELECT
	 [strTransactionType]					= (case
												when (cfTrans.dblQuantity < 0 OR cfTransPrice.dblCalculatedAmount < 0)  then 'Credit Memo'
												else 'Invoice'
											  end)
	,[strSourceTransaction]					= 'CF Tran'
	,[intSourceId]							= cfTrans.intTransactionId
	,[strSourceId]							= cfTrans.strTransactionId
	,[intInvoiceId]							= I.intInvoiceId--@InvoiceId --NULL Value will create new invoice
	,[intEntityCustomerId]					= (case
												when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Foreign Sale' then cfNetwork.intCustomerId
												else cfCardAccount.intCustomerId
											  end)
	,[intCompanyLocationId]					= cfSiteItem.intARLocationId
	,[intCurrencyId]						= I.intCurrencyId
	,[intTermId]							= @companyConfigTermId
	,[dtmDate]								= cfTrans.dtmTransactionDate
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= cfTrans.dtmTransactionDate
	,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
	,[intFreightTermId]						= I.[intFreightTermId]
	,[intShipViaId]							= I.[intShipViaId]
	,[intPaymentMethodId]					= I.[intPaymentMethodId]
	,[strInvoiceOriginId]					= cfTrans.strTransactionId
	,[ysnUseOriginIdAsInvoiceNumber]		= 1
	,[strPONumber]							= cfTrans.strPONumber
	,[strBOLNumber]							= ''
	,[strDeliverPickup]						= cfTrans.strDeliveryPickupInd
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
	,[strActualCostId]						= NULL
	,[intShipmentId]						= NULL
	,[intTransactionId]						= cfTrans.intTransactionId
	,[intEntityId]							= @UserEntityId
	,[ysnResetDetails]						= 0
	,[ysnPost]								= @Post
	
	,[intInvoiceDetailId]					= (SELECT TOP 1 intInvoiceDetailId 
												FROM tblARInvoiceDetail 
												WHERE intInvoiceId = cfTrans.intInvoiceId)
	,[intItemId]							= cfSiteItem.intARItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= cfSiteItem.strDescription 
	,[intItemUOMId]							= cfSiteItem.intIssueUOMId
	,[dblQtyOrdered]						= ABS(cfTrans.dblQuantity)
	,[dblQtyShipped]						= ABS(cfTrans.dblQuantity)
	,[dblDiscount]							= 0
	,[dblPrice]								= ABS(cfTransPrice.dblCalculatedAmount)
	,[ysnRefreshPrice]						= 0
	,[strMaintenanceType]					= ''
    ,[strFrequency]							= ''
    ,[dtmMaintenanceDate]					= NULL
    ,[dblMaintenanceAmount]					= NULL
    ,[dblLicenseAmount]						= NULL
	,[intTaxGroupId]						= cfSiteItem.intTaxGroupId
	,[ysnRecomputeTax]						= 0 
											  -- (CASE 
													--WHEN @ysnRemoteTransaction = 1 OR @UpdateAvailableDiscount = 1 OR cfSiteItem.intTaxGroupId IS NULL
													--THEN 0
													--ELSE 1
											  -- END)
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
	,[intTempDetailIdForTaxes]				= @TransactionId
	,[strType]								= 'CF Tran'
	,[ysnUpdateAvailableDiscount]			= ISNULL(@UpdateAvailableDiscount,0)
	,[strItemTermDiscountBy]				= @strItemTermDiscountBy
	,[dblItemTermDiscount]					= @Discount
	,[dtmPostedDate]						= cfTrans.dtmPostedDate
	
FROM tblCFTransaction cfTrans
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
INNER JOIN (SELECT * 
			FROM tblCFTransactionPrice
			WHERE strTransactionPriceId = 'Net Price')
			AS cfTransPrice
ON 	cfTrans.intTransactionId = cfTransPrice.intTransactionId
--LEFT JOIN vyuCTContractDetailView ctContracts
--ON cfTrans.intContractId = ctContracts.intContractHeaderId AND cfTrans.intContractDetailId =  ctContracts.intContractDetailId
LEFT OUTER JOIN
	tblARInvoice I
		ON cfTrans.intInvoiceId = I.intInvoiceId
WHERE cfTrans.intTransactionId = @TransactionId


DECLARE @InvoiceEntriesTEMP	InvoiceStagingTable


INSERT INTO @InvoiceEntriesTEMP(
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
,[intLoadDistributionHeaderId]
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
,[ysnClearDetailTaxes]					
,[intTempDetailIdForTaxes]
,[strType]
,[ysnUpdateAvailableDiscount]
,[strItemTermDiscountBy]
,[dblItemTermDiscount]
,[dtmPostDate])
SELECT 
ROW_NUMBER() OVER(ORDER BY intEntityCustomerId ASC)
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
,[intLoadDistributionHeaderId]
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
,[ysnClearDetailTaxes]					
,[intTempDetailIdForTaxes]
,[strType]
,[ysnUpdateAvailableDiscount]
,[strItemTermDiscountBy]
,[dblItemTermDiscount]
,[dtmPostDate]
FROM @EntriesForInvoice

select intCurrencyId, * from @EntriesForInvoice


--SELECT * FROM @InvoiceEntriesTEMP


--SELECT * FROM @EntriesForInvoice

DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 

--IF (@ysnRemoteTransaction = 1)
--BEGIN
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
		,[strNotes]
		,[intTempDetailIdForTaxes])
	SELECT
	[intDetailId]				= (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId)
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
	,[ysnTaxExempt]				= 0
	,[strNotes]					= ''
	,[intTempDetailIdForTaxes]	= @TransactionId
	FROM 
	tblCFTransaction cfTransaction
	INNER JOIN tblCFTransactionTax cfTransactionTax
	ON cfTransaction.intTransactionId = cfTransactionTax.intTransactionId
	INNER JOIN tblSMTaxCode  cfTaxCode
	ON cfTransactionTax.intTaxCodeId = cfTaxCode.intTaxCodeId
	--INNER JOIN tblSMTaxCodeRate cfTaxCodeRate
	--ON cfTaxCode.intTaxCodeId = cfTaxCodeRate.intTaxCodeId
	WHERE cfTransaction.intTransactionId = @TransactionId

--END

--SELECT * FROM @EntriesForInvoice
--SELECT * FROM @TaxDetails

--SELECT * FROM @EntriesForInvoice


EXEC [dbo].[uspARProcessInvoicesByBatch]
		 @InvoiceEntries	= @InvoiceEntriesTEMP
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= @UserId
		,@GroupingOption	= 11
		,@RaiseError		= 1
		,@ErrorMessage		= @ErrorMessage OUTPUT
		,@LogId = @LogId OUTPUT


IF (@ErrorMessage IS NULL)
	BEGIN
		COMMIT TRANSACTION
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END


IF (@ErrorMessage IS NULL OR @ErrorMessage = '')
BEGIN

DECLARE @intInvoiceId INT

SELECT TOP 1 @intInvoiceId = intInvoiceId FROM tblARInvoiceIntegrationLogDetail where intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1

UPDATE tblCFTransaction SET intInvoiceId = @intInvoiceId, ysnPosted = @Post 
WHERE intTransactionId = @TransactionId


	IF (@Post = 1)
		BEGIN
			UPDATE tblCFCard SET dtmLastUsedDated = @transactionDate WHERE intCardId = @intCardId AND ( dtmLastUsedDated < @transactionDate OR dtmLastUsedDated IS NULL)
		END
		ELSE
		BEGIN
			select top 1 @transactionDate = dtmTransactionDate from tblCFTransaction where intCardId = @intCardId AND ysnPosted = 1 order by dtmTransactionDate desc 
			UPDATE tblCFCard SET dtmLastUsedDated = @transactionDate WHERE intCardId = @intCardId
		END

END


--IF (@CreatedIvoices IS NOT NULL AND @ErrorMessage IS NULL)
--BEGIN
--	UPDATE tblCFTransaction 
--	SET intInvoiceId = @CreatedIvoices,
--		ysnPosted = @Post 
--	WHERE intTransactionId = @TransactionId

	

--END

--IF (@UpdatedIvoices IS NOT NULL AND @ErrorMessage IS NULL)
--BEGIN
--	UPDATE tblCFTransaction 
--	SET ysnPosted = @Post 
--	WHERE intTransactionId = @TransactionId 


--	IF (@Post = 1)
--	BEGIN
--		UPDATE tblCFCard SET dtmLastUsedDated = @transactionDate WHERE intCardId = @intCardId AND ( dtmLastUsedDated < @transactionDate OR dtmLastUsedDated IS NULL)
--	END
--	ELSE
--	BEGIN
--		select top 1 @transactionDate = dtmTransactionDate from tblCFTransaction where intCardId = @intCardId AND ysnPosted = 1 order by dtmTransactionDate desc 
--		UPDATE tblCFCard SET dtmLastUsedDated = @transactionDate WHERE intCardId = @intCardId
--	END

--END