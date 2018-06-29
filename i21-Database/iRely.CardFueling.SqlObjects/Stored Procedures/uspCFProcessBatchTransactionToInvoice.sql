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


AS	

DECLARE @intRecordKey INT
DECLARE @strRecord INT
DECLARE @UserEntityId INT
DECLARE @EntriesForInvoice AS InvoiceStagingTable
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 
DECLARE @ysnRemoteTransaction INT

DECLARE @companyConfigTermId	INT = NULL
DECLARE @companyConfigFreightTermId	INT = NULL

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


--SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId)
SET @UserEntityId = @UserId


SELECT 
DISTINCT RecordKey = intTransactionId 
INTO #tmpTransactionId 
FROM vyuCFBatchPostTransactions 
WHERE strTransType != 'Foreign Sale' OR ISNULL(ysnPostForeignSales,0) != 0

SELECT 
 RecordKey = intTransactionId
,ysnPostForeignSales
,strTransType
,dtmTransactionDate
,strTransactionId
,strTransactionType
,ysnPosted
,strDescription
,dblAmount
,intTransactionId
,intEntityId
INTO #tmpForeignTransactionId 
FROM vyuCFBatchPostTransactions 
WHERE strTransType = 'Foreign Sale' AND ISNULL(ysnPostForeignSales,0) = 0



--ORDER BY intTransactionId
--OFFSET     0 ROWS       
--FETCH NEXT 1000 ROWS ONLY


IF @TransactionId != 'ALL'
BEGIN
	DELETE FROM #tmpTransactionId WHERE RecordKey NOT IN (SELECT Record FROM [fnCFSplitString](@TransactionId,',') )
	DELETE FROM #tmpForeignTransactionId WHERE RecordKey NOT IN (SELECT Record FROM [fnCFSplitString](@TransactionId,',') )
	
END

SELECT * FROM #tmpTransactionId
SELECT * FROM #tmpForeignTransactionId
		
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
					[intId]						= TI.RecordKey
					,[strTransactionType]		= (case
												when (cfTrans.dblQuantity < 0 OR cfTransPrice.dblCalculatedAmount < 0)  then 'Credit Memo'
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
					,[dtmShipDate]							= cfTrans.dtmTransactionDate
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
					,[intTransactionId]						= TI.RecordKey
					,[intEntityId]							= @UserEntityId
					,[ysnResetDetails]						= 0
					,[ysnPost]								= @Post
					,[ysnRecap]								= @Recap
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
				INNER JOIN #tmpTransactionId TI
					ON cfTrans.intTransactionId = TI.RecordKey
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
				LEFT OUTER JOIN
	tblARInvoice I
		ON cfTrans.intInvoiceId = I.intInvoiceId
				--LEFT JOIN vyuCTContractDetailView ctContracts
				--ON cfTrans.intContractId = ctContracts.intContractHeaderId AND cfTrans.intContractDetailId =  ctContracts.intContractDetailId
				--WHERE cfTrans.intTransactionId = @strRecord


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
						,[ysnTaxOnly]
						,[strNotes]
						,[intTempDetailIdForTaxes]
						,[ysnClearExisting])
					SELECT
					[intDetailId]				= NULL
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
					,[ysnTaxOnly]				= cfTaxCode.[ysnTaxOnly]
					,[strNotes]					= ''
					,[intTempDetailIdForTaxes]	= TI.RecordKey
					,[ysnClearExisting]			= 1
					FROM 
					tblCFTransaction cfTransaction
					INNER JOIN #tmpTransactionId TI
						ON cfTransaction.intTransactionId = TI.RecordKey
					INNER JOIN tblCFTransactionTax cfTransactionTax
					ON cfTransaction.intTransactionId = cfTransactionTax.intTransactionId
					INNER JOIN tblSMTaxCode  cfTaxCode
					ON cfTransactionTax.intTaxCodeId = cfTaxCode.intTaxCodeId
					--INNER JOIN tblSMTaxCodeRate cfTaxCodeRate
					--ON cfTaxCode.intTaxCodeId = cfTaxCodeRate.intTaxCodeId
					--WHERE cfTransaction.intTransactionId = @strRecord

	DROP TABLE #tmpTransactionId
		
	--BEGIN TRANSACTION


--	Foreign Sale

	DECLARE @intForeignTransCount INT = 0
	DECLARE @dtmDate DATETIME

	SET @dtmDate = GETDATE();
	SELECT @intForeignTransCount = COUNT(*) FROM #tmpForeignTransactionId
	UPDATE tblCFTransaction SET ysnPosted = 1 WHERE intTransactionId IN (SELECT RecordKey FROM #tmpForeignTransactionId)
	
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
	,RecordKey
	,strTransactionId
	,strTransactionType
	,'Transaction successfully posted.'
	,@dtmDate
	,intEntityId
	FROM 
	#tmpForeignTransactionId

--	Foreign Sale

	
	DECLARE @LogId INT

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


	SET @SuccessfulCount = 0;

	SELECT DISTINCT intInvoiceId, intSourceId, ysnPosted  INTO #tmpCreatedInvoice FROM tblARInvoiceIntegrationLogDetail WHERE intIntegrationLogId = @LogId AND ISNULL(ysnSuccess,0) = 1 AND ISNULL(ysnHeader,0) = 1 --AND ISNULL(ysnPosted,0) = 1

	SELECT @SuccessfulCount = Count(intInvoiceId) FROM #tmpCreatedInvoice WHERE ISNULL(ysnPosted,0) = 1

	--IF ((@ErrorMessage IS NULL OR @ErrorMessage = '') AND @SuccessfulCount > 0)
	--	BEGIN

			IF ((@Recap = 0 OR @Recap IS NULL) AND (@Post = 1))
			BEGIN
							
				UPDATE CFTran
				SET 
					CFTran.ysnPosted	 = ARL.ysnPosted
					,CFTran.intInvoiceId = ARL.intInvoiceId
				FROM
					tblCFTransaction CFTran
				INNER JOIN
					#tmpCreatedInvoice ARL
						ON CFTran.intTransactionId = ARL.intSourceId
						--AND ARL.ysnPosted = 1

				IF (@Post = 1)
				BEGIN
					UPDATE CFC
						SET CFC.dtmLastUsedDated = CFT.dtmTransactionDate
					FROM
						tblCFCard CFC
					INNER JOIN
						(	SELECT CFTran.intCardId, MAX(CFTran.dtmTransactionDate) AS dtmTransactionDate
							FROM
								tblCFTransaction CFTran
							INNER JOIN
								#tmpCreatedInvoice ARL
									ON CFTran.intTransactionId = ARL.intSourceId 
									AND ARL.ysnPosted = 1
								GROUP BY  CFTran.intCardId
						) CFT
							ON CFC.intCardId = CFT.intCardId					
					WHERE 
						(CFC.dtmLastUsedDated < CFT.dtmTransactionDate OR CFC.dtmLastUsedDated IS NULL)
				END
				ELSE
				BEGIN
					UPDATE CFC
						SET CFC.dtmLastUsedDated = CFT.dtmTransactionDate
					FROM
						tblCFCard CFC
					INNER JOIN
						(	SELECT CFTran.intCardId, MAX(CFTran.dtmTransactionDate) AS dtmTransactionDate
							FROM
								tblCFTransaction CFTran
							INNER JOIN
								#tmpCreatedInvoice ARL
									ON CFTran.intTransactionId = ARL.intSourceId 
								GROUP BY CFTran.intCardId
						) CFT
							ON CFC.intCardId = CFT.intCardId					
				END

			END 
			ELSE IF (@Recap = 1)
			BEGIN
				UPDATE CFTran
				SET 
					CFTran.intInvoiceId = ARL.intInvoiceId
				FROM
					tblCFTransaction CFTran
				INNER JOIN
					#tmpCreatedInvoice ARL
						ON CFTran.intTransactionId = ARL.intSourceId 
			END

		--TRANSACTION COUNT + FOREIGN TRANSACTION COUNT (ysnPostForeignTrans = 0)
		SET @SuccessfulCount = @SuccessfulCount + @intForeignTransCount

		--COMMIT TRANSACTION
	--END
	--ELSE
	--	BEGIN
	--		IF(@intForeignTransCount > 0)
	--		BEGIN
	--			SET @SuccessfulCount = @SuccessfulCount + @intForeignTransCount
	--			COMMIT TRANSACTION
	--		END
	--		ELSE
	--		BEGIN
	--			ROLLBACK TRANSACTION
	--		END
	--	END

	IF OBJECT_ID('tempdb..#tmpCreatedInvoice') IS NOT NULL DROP TABLE #tmpCreatedInvoice
	IF OBJECT_ID('tempdb..##tmpForeignTransactionId') IS NOT NULL DROP TABLE #tmpForeignTransactionId