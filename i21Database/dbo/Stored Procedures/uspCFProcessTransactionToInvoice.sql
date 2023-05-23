﻿CREATE PROCEDURE [dbo].[uspCFProcessTransactionToInvoice]
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
--SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId)
SET @UserEntityId = @UserId

DECLARE @LogId INT

DECLARE @EntriesForInvoice AS InvoiceStagingTable
DECLARE @ysnRemoteTransaction INT
DECLARE @strItemTermDiscountBy NVARCHAR(MAX)

DECLARE @companyConfigTermId	INT = NULL
DECLARE @companyConfigFreightTermId	INT = NULL
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

SELECT TOP 1 @companyConfigFreightTermId = intFreightTermId FROM tblCFCompanyPreference
IF(ISNULL(@companyConfigFreightTermId,0) = 0)
BEGIN
	SET @ErrorMessage = 'Freight Terms needs setup on Company Configuration for Card Fueling.'
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

DECLARE @ysnPostForeignSales BIT = 0
DECLARE @intForeignInvoiceId INT = 0
DECLARE @strTransactionType NVARCHAR(MAX)
--DECLARE @intForeignCustomerId NVARCHAR(MAX)

SELECT 
@ysnPostForeignSales = (SELECT TOP 1 ysnPostForeignSales FROM tblCFNetwork WHERE intNetworkId = cfT.intNetworkId)
,@intForeignInvoiceId =cfT.intInvoiceId
,@strTransactionType = cfT.strTransactionType
FROM tblCFTransaction cfT
WHERE cfT.intTransactionId = @TransactionId

IF(@strTransactionType = 'Foreign Sale')
BEGIN
	IF(ISNULL(@Post,0) = 1)
	BEGIN
		IF(ISNULL(@ysnPostForeignSales,0) = 0)
		BEGIN

			UPDATE tblCFTransaction 
			SET ysnPosted = 1 
			WHERE intTransactionId = @TransactionId
			RETURN 1;
		END
	END
	ELSE IF(ISNULL(@Post,0) = 0)
	BEGIN
		IF(ISNULL(@ysnPostForeignSales,0) = 0 AND ISNULL(@intForeignInvoiceId,0) = 0)
		BEGIN

			UPDATE tblCFTransaction SET ysnPosted = 0 WHERE intTransactionId = @TransactionId
			RETURN 1;
		END
	END
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
	,[ysnImpactInventory]
)
SELECT
	 [strTransactionType]					= (case
												when (cfTrans.dblQuantity < 0 OR cfTrans.dblCalculatedNetPrice < 0)  then 'Credit Memo'
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
	,[dtmShipDate]							= cfTrans.dtmPostedDate
	,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
	,[intFreightTermId]						= @companyConfigFreightTermId --I.[intFreightTermId]
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
	,[strActualCostId]						= NULL
	,[intShipmentId]						= NULL
	,[intTransactionId]						= cfTrans.intTransactionId
	,[intEntityId]							= @UserEntityId
	,[ysnResetDetails]						= 0
	,[ysnPost]								= @Post
	
	,[intInvoiceDetailId]					= ISNULL((SELECT TOP 1 intInvoiceDetailId 
												FROM tblARInvoiceDetail 
												WHERE intInvoiceId = cfTrans.intInvoiceId
												ORDER BY dblQtyShipped DESC),@TransactionId)
	,[intItemId]							= cfSiteItem.intARItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= cfSiteItem.strDescription 
	,[intItemUOMId]							= cfSiteItem.intIssueUOMId
	,[dblQtyOrdered]						= ABS(cfTrans.dblQuantity)
	,[dblQtyShipped]						= ABS(cfTrans.dblQuantity)
	,[dblDiscount]							= 0
	,[dblPrice]								= ABS(cfTrans.dblCalculatedGrossPrice)
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
	,[ysnImpactInventory]					= 															
											(case
											when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Remote' 
											OR  RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Extended Remote'
											OR ISNULL((SELECT TOP 1 ysnCaptiveSite FROM tblCFSite where intSiteId = cfTrans.intSiteId),0) = 1
											then 0
											else 1
											end)
	
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
--INNER JOIN (SELECT * 
--			FROM tblCFTransactionPrice
--			WHERE strTransactionPriceId = 'Net Price')
--			AS cfTransPrice
--ON 	cfTrans.intTransactionId = cfTransPrice.intTransactionId
--LEFT JOIN vyuCTContractDetailView ctContracts
--ON cfTrans.intContractId = ctContracts.intContractHeaderId AND cfTrans.intContractDetailId =  ctContracts.intContractDetailId
LEFT OUTER JOIN
	tblARInvoice I
		ON cfTrans.intInvoiceId = I.intInvoiceId
WHERE cfTrans.intTransactionId = @TransactionId

----------INSERT ENTRIES FOR EXPENSED TRANS-----------
IF(ISNULL(@Post,0) = 1) 
BEGIN
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
	,[ysnImpactInventory]
)
SELECT
	 [strTransactionType]					= (case
												when (cfTrans.dblQuantity < 0 OR cfTrans.dblCalculatedNetPrice < 0)  then 'Credit Memo'
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
	,[intCompanyLocationId]					= cfTrans.intARLocationId
	,[intCurrencyId]						= I.intCurrencyId
	,[intTermId]							= @companyConfigTermId
	,[dtmDate]								= cfTrans.dtmTransactionDate
	,[dtmDueDate]							= NULL
	,[dtmShipDate]							= cfTrans.dtmTransactionDate
	,[intEntitySalespersonId]				= cfCardAccount.intSalesPersonId
	,[intFreightTermId]						= @companyConfigFreightTermId --I.[intFreightTermId]
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
	,[strActualCostId]						= NULL
	,[intShipmentId]						= NULL
	,[intTransactionId]						= cfTrans.intTransactionId
	,[intEntityId]							= @UserEntityId
	,[ysnResetDetails]						= 0
	,[ysnPost]								= @Post
	
	,[intInvoiceDetailId]					= ISNULL((SELECT TOP 1 intInvoiceDetailId 
												FROM tblARInvoiceDetail 
												WHERE intInvoiceId = cfTrans.intInvoiceId AND ISNULL(dblQtyShipped,0) < 0),@TransactionId+1)
	,[intItemId]							= cfTrans.intExpensedItemId
	,[ysnInventory]							= 1
	,[strItemDescription]					= icItem.strDescription 
	,[intItemUOMId]							= iicItemLoc.intIssueUOMId
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
	,[intTempDetailIdForTaxes]				= @TransactionId + 1
	,[strType]								= 'CF Tran'
	,[ysnUpdateAvailableDiscount]			= ISNULL(@UpdateAvailableDiscount,0)
	,[strItemTermDiscountBy]				= @strItemTermDiscountBy
	,[dblItemTermDiscount]					= @Discount
	,[dtmPostedDate]						= cfTrans.dtmPostedDate
	,[ysnImpactInventory]					= 															
											(case
											when RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Remote' 
											OR  RTRIM(LTRIM(cfTrans.strTransactionType)) = 'Extended Remote'
											OR ISNULL((SELECT TOP 1 ysnCaptiveSite FROM tblCFSite where intSiteId = cfTrans.intSiteId),0) = 1
											then 0
											else 1
											end)
	
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

INNER JOIN tblICItem as icItem 
ON cfTrans.intExpensedItemId = icItem.intItemId

LEFT JOIN tblICItemLocation iicItemLoc
ON iicItemLoc.intLocationId = cfTrans.intARLocationId
AND iicItemLoc.intItemId = cfTrans.intExpensedItemId

LEFT OUTER JOIN
	tblARInvoice I
		ON cfTrans.intInvoiceId = I.intInvoiceId
WHERE cfTrans.intTransactionId = @TransactionId AND ISNULL(ysnExpensed,0) = 1
END
----------INSERT ENTRIES FOR EXPENSED TRANS-----------


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
,[ysnImpactInventory])
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
,[ysnImpactInventory]
FROM @EntriesForInvoice


DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 
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
[intDetailId]				= ISNULL((SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId ORDER BY dblQtyShipped DESC),@TransactionId)
,[intTaxGroupId]			= NULL
,[intTaxCodeId]				= cfTaxCode.intTaxCodeId
,[intTaxClassId]			= cfTaxCode.intTaxClassId
,[strTaxableByOtherTaxes]	= cfTaxCode.strTaxableByOtherTaxes
,[strCalculationMethod]		= (select top 1 strCalculationMethod from tblSMTaxCodeRate where dtmEffectiveDate < cfTransaction.dtmTransactionDate AND intTaxCodeId = cfTransactionTax.intTaxCodeId order by dtmEffectiveDate desc)
,[dblRate]					= cfTransactionTax.dblTaxRate
,[intTaxAccountId]			= cfTaxCode.intSalesTaxAccountId
,[dblTax]					= (case
								when (cfTransaction.dblQuantity < 0 OR cfTransaction.dblCalculatedNetPrice < 0)  then cfTransactionTax.dblTaxCalculatedAmount * -1
								else cfTransactionTax.dblTaxCalculatedAmount
								end)
,[dblAdjustedTax]			= (case
								when (cfTransaction.dblQuantity < 0 OR cfTransaction.dblCalculatedNetPrice < 0)  then cfTransactionTax.dblTaxCalculatedAmount * -1
								else cfTransactionTax.dblTaxCalculatedAmount
								end)--(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE--(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE--(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE
,[ysnTaxAdjusted]			= 0
,[ysnSeparateOnInvoice]		= 0 
,[ysnCheckoffTax]			= cfTaxCode.ysnCheckoffTax
,[ysnTaxExempt]				= cfTransactionTax.ysnTaxExempt
,[ysnTaxOnly]				= cfTaxCode.ysnTaxOnly 
,[strNotes]					= ''
,[intTempDetailIdForTaxes]	= @TransactionId 
,[ysnClearExisting]			= 1
FROM 
tblCFTransaction cfTransaction
INNER JOIN tblCFTransactionTax cfTransactionTax
ON cfTransaction.intTransactionId = cfTransactionTax.intTransactionId
INNER JOIN tblSMTaxCode  cfTaxCode
ON cfTransactionTax.intTaxCodeId = cfTaxCode.intTaxCodeId
--INNER JOIN tblSMTaxCodeRate cfTaxCodeRate
--ON cfTaxCode.intTaxCodeId = cfTaxCodeRate.intTaxCodeId
WHERE cfTransaction.intTransactionId = @TransactionId

----------INSERT TAX ENTRIES FOR EXPENSED TRANS-----------
--IF(ISNULL(@Post,0) = 1)
--BEGIN
--	INSERT INTO @TaxDetails
--	(
--	[intDetailId] 
--	,[intTaxGroupId]
--	,[intTaxCodeId]
--	,[intTaxClassId]
--	,[strTaxableByOtherTaxes]
--	,[strCalculationMethod]
--	,[dblRate]
--	,[intTaxAccountId]
--	,[dblTax]
--	,[dblAdjustedTax]
--	,[ysnTaxAdjusted]
--	,[ysnSeparateOnInvoice]
--	,[ysnCheckoffTax]
--	,[ysnTaxExempt]
--	,[ysnTaxOnly]
--	,[strNotes]
--	,[intTempDetailIdForTaxes]
--	,[ysnClearExisting])
--SELECT
--[intDetailId]				= ISNULL((SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @InvoiceId AND ISNULL(dblQtyShipped,0) < 0),@TransactionId +1)
--,[intTaxGroupId]			= NULL
--,[intTaxCodeId]				= cfTaxCode.intTaxCodeId
--,[intTaxClassId]			= cfTaxCode.intTaxClassId
--,[strTaxableByOtherTaxes]	= cfTaxCode.strTaxableByOtherTaxes
--,[strCalculationMethod]		= (select top 1 strCalculationMethod from tblSMTaxCodeRate where dtmEffectiveDate < cfTransaction.dtmTransactionDate AND intTaxCodeId = cfTransactionTax.intTaxCodeId order by dtmEffectiveDate desc)
--,[dblRate]					= cfTransactionTax.dblTaxRate
--,[intTaxAccountId]			= cfTaxCode.intSalesTaxAccountId
--,[dblTax]					= ABS(cfTransactionTax.dblTaxCalculatedAmount) *-1
--,[dblAdjustedTax]			= ABS(cfTransactionTax.dblTaxCalculatedAmount) *-1 --(cfTransactionTax.dblTaxCalculatedAmount * cfTransaction.dblQuantity) -- REMOTE TAXES ARE NOT RECOMPUTED ON INVOICE
--,[ysnTaxAdjusted]			= 0
--,[ysnSeparateOnInvoice]		= 0 
--,[ysnCheckoffTax]			= cfTaxCode.ysnCheckoffTax
--,[ysnTaxExempt]				= 0
--,[ysnTaxOnly]				= cfTaxCode.ysnTaxOnly 
--,[strNotes]					= ''
--,[intTempDetailIdForTaxes]	= @TransactionId + 1
--,[ysnClearExisting]			= 1
--FROM 
--tblCFTransaction cfTransaction
--INNER JOIN tblCFTransactionTax cfTransactionTax
--ON cfTransaction.intTransactionId = cfTransactionTax.intTransactionId
--INNER JOIN tblSMTaxCode  cfTaxCode
--ON cfTransactionTax.intTaxCodeId = cfTaxCode.intTaxCodeId
----INNER JOIN tblSMTaxCodeRate cfTaxCodeRate
----ON cfTaxCode.intTaxCodeId = cfTaxCodeRate.intTaxCodeId
--WHERE cfTransaction.intTransactionId = @TransactionId AND ISNULL(ysnExpensed,0) = 1
--END
----------INSERT TAX ENTRIES FOR EXPENSED TRANS-----------


--SELECT intInvoiceDetailId,intInvoiceId,dblQtyOrdered,dblQtyShipped,* FROM @InvoiceEntriesTEMP

--SELECT SUM([dblPrice]) AS dblTotalAmount , SUM([dblQtyOrdered]) AS dblTotalQtyOrdered , SUM(dblQtyShipped) AS dblTotalQtyShipped , [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId], [intPaymentMethodId], [strInvoiceOriginId]
--FROM @InvoiceEntriesTEMP
--GROUP BY [intEntityCustomerId], [intSourceId], [intCompanyLocationId], [intCurrencyId], [dtmDate], [intTermId], [intShipViaId], [intEntitySalespersonId], [strPONumber], [strBOLNumber], [strComments], [intAccountId], [intFreightTermId], [intPaymentMethodId], [strInvoiceOriginId]


SELECT '@InvoiceEntriesTEMP',intInvoiceId,intInvoiceDetailId,intTempDetailIdForTaxes,* FROM @InvoiceEntriesTEMP
SELECT '@TaxDetails',intTempDetailIdForTaxes,* FROM @TaxDetails

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
		IF (@ErrorMessage IS NULL OR @ErrorMessage = '')
		BEGIN

		DECLARE @intInvoiceId INT

		--SELECT TOP 1 @intInvoiceId = intInvoiceId FROM tblARInvoiceIntegrationLogDetail where intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1

		--UPDATE tblCFTransaction SET intInvoiceId = @intInvoiceId, ysnPosted = @Post 
		--WHERE intTransactionId = @TransactionId

			UPDATE CFTran
			SET 
				 CFTran.ysnPosted	 = ARL.ysnPosted
				,CFTran.intInvoiceId = ARL.intInvoiceId
			FROM
			tblCFTransaction CFTran
			INNER JOIN tblARInvoice ARL
			ON CFTran.intTransactionId = ARL.intTransactionId
			WHERE CFTran.intTransactionId = @TransactionId


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

		IF((SELECT COUNT(1) FROM tblCFTransaction WHERE intTransactionId =  @TransactionId AND ISNULL(intInvoiceId,0) != 0) > 0 )
		BEGIN
			COMMIT TRANSACTION
		END
		ELSE
		BEGIN
			SET @ErrorMessage = 'Failed to link cf transaction and invoice'
			ROLLBACK TRANSACTION
		END
		
	END
ELSE
	BEGIN
		ROLLBACK TRANSACTION
	END



