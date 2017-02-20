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

DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
DECLARE @ysnRemoteTransaction INT
DECLARE @strItemTermDiscountBy NVARCHAR(MAX)

DECLARE @companyConfigTermId	INT = NULL

SELECT TOP 1 @companyConfigTermId = intTermsCode FROM tblCFCompanyPreference
IF(ISNULL(@companyConfigTermId,0) = 0)
BEGIN
	SET @ErrorMessage = 'Term code is required.'
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
)
SELECT
	 [strSourceTransaction]					= 'CF Tran'
	,[intSourceId]							= cfTrans.intTransactionId
	,[strSourceId]							= cfTrans.strTransactionId
	,[intInvoiceId]							= @InvoiceId --NULL Value will create new invoice
	,[intEntityCustomerId]					= (case
												when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Foreign Sale' then cfNetwork.intCustomerId
												else cfCardAccount.intCustomerId
											  end)
	,[intCompanyLocationId]					= cfSiteItem.intARLocationId
	,[intCurrencyId]						= NULL
	,[intTermId]							= @companyConfigTermId
	,[dtmDate]								= cfTrans.dtmTransactionDate
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= cfTrans.dtmTransactionDate
	,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
	,[intFreightTermId]						= NULL 
	,[intShipViaId]							= NULL 
	,[intPaymentMethodId]					= NULL
	,[strInvoiceOriginId]					= cfTrans.strTransactionId
	,[ysnUseOriginIdAsInvoiceNumber]		= 1
	,[strPONumber]							= cfTrans.strPONumber
	,[strBOLNumber]							= ''
	,[strDeliverPickup]						= cfTrans.strDeliveryPickupInd
	,[strComments]							= ''
	,[intShipToLocationId]					= NULL
	,[intBillToLocationId]					= NULL
	,[ysnTemplate]							= 0
	,[ysnForgiven]							= 0
	,[ysnCalculated]						= 0  --0 OS
	,[ysnSplitted]							= 0
	,[intPaymentId]							= NULL
	,[intSplitId]							= NULL
	,[intLoadDistributionHeaderId]			= NULL
	,[strActualCostId]						= ''
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
	,[ysnClearDetailTaxes]					= 0
	,[intTempDetailIdForTaxes]				= @TransactionId
	,[strType]								= 'CF Tran'
	,[ysnUpdateAvailableDiscount]			= @UpdateAvailableDiscount
	,[strItemTermDiscountBy]				= @strItemTermDiscountBy
	,[dblItemTermDiscount]					= @Discount
	
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
LEFT JOIN vyuCTContractDetailView ctContracts
ON cfTrans.intContractId = ctContracts.intContractHeaderId AND cfTrans.intContractDetailId =  ctContracts.intContractDetailId
WHERE cfTrans.intTransactionId = @TransactionId


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
	,[dblTax]					= cfTransactionTax.dblTaxCalculatedAmount
	,[dblAdjustedTax]			= cfTransactionTax.dblTaxCalculatedAmount--(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE
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
EXEC [dbo].[uspARProcessInvoices]
		 @InvoiceEntries	= @EntriesForInvoice
		,@LineItemTaxEntries = @TaxDetails
		,@UserId			= @UserId
		,@GroupingOption	= 11
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

IF (@CreatedIvoices IS NOT NULL AND @ErrorMessage IS NULL)
BEGIN
	UPDATE tblCFTransaction 
	SET intInvoiceId = @CreatedIvoices,
		ysnPosted = @Post 
	WHERE intTransactionId = @TransactionId
END

IF (@UpdatedIvoices IS NOT NULL AND @ErrorMessage IS NULL)
BEGIN
	UPDATE tblCFTransaction 
	SET ysnPosted = @Post 
	WHERE intTransactionId = @TransactionId 
END