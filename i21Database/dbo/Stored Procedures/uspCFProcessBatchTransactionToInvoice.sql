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
DECLARE @EntriesForInvoice AS InvoiceIntegrationStagingTable
DECLARE @TaxDetails AS LineItemTaxDetailStagingTable 
DECLARE @ysnRemoteTransaction INT

DECLARE @companyConfigTermId	INT = NULL

SELECT TOP 1 @companyConfigTermId = intTermsCode FROM tblCFCompanyPreference
IF(ISNULL(@companyConfigTermId,0) = 0)
BEGIN
	SET @ErrorMessage = 'Term code is required.'
	SET @CreatedIvoices = NULL
	SET @UpdatedIvoices = NULL

	RETURN
END

SET @UserEntityId = ISNULL((SELECT [intEntityId] FROM tblSMUserSecurity WHERE [intEntityId] = @UserId),@UserId)


SELECT DISTINCT RecordKey = intTransactionId INTO #tmpTransactionId FROM vyuCFBatchPostTransactions
--ORDER BY intTransactionId
--OFFSET     0 ROWS       
--FETCH NEXT 500 ROWS ONLY


IF @TransactionId != 'ALL'
BEGIN
	DELETE FROM #tmpTransactionId WHERE RecordKey NOT IN (SELECT Record FROM [fnCFSplitString](@TransactionId,',') )
END

	WHILE (EXISTS(SELECT 1 FROM #tmpTransactionId ))
			BEGIN

				
				
				SELECT @intRecordKey = RecordKey FROM #tmpTransactionId
				SET @strRecord = @intRecordKey

				SELECT 
				@ysnRemoteTransaction = (CASE 
											WHEN strTransactionType = 'Extended Remote' OR strTransactionType = 'Remote'
											THEN 1
											ELSE 0
										END)
				from tblCFTransaction 
				where intTransactionId = @strRecord
		
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
				)
				SELECT
					[strTransactionType]		= (case
												when (cfTrans.dblQuantity < 0 OR cfTransPrice.dblCalculatedAmount < 0)  then 'Credit Memo'
												else 'Invoice'
											  end)
					,[strSourceTransaction]					= 'CF Tran'
					,[intSourceId]							= cfTrans.intTransactionId
					,[strSourceId]							= cfTrans.strTransactionId
					,[intInvoiceId]							= cfTrans.intInvoiceId --NULL Value will create new invoice
					,[intEntityCustomerId]					= cfCardAccount.intCustomerId
					,[intCompanyLocationId]					= cfSiteItem.intARLocationId
					,[intCurrencyId]						= 1
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
					,[strPONumber]							= ''
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
					,[intTempDetailIdForTaxes]				= @strRecord
					,[strType]								= 'CF Tran'
					,[dtmPostDate]							= cfTrans.dtmPostedDate
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
				WHERE cfTrans.intTransactionId = @strRecord


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
					,[strNotes]					= ''
					,[intTempDetailIdForTaxes]	= @strRecord
					FROM 
					tblCFTransaction cfTransaction
					INNER JOIN tblCFTransactionTax cfTransactionTax
					ON cfTransaction.intTransactionId = cfTransactionTax.intTransactionId
					INNER JOIN tblSMTaxCode  cfTaxCode
					ON cfTransactionTax.intTaxCodeId = cfTaxCode.intTaxCodeId
					--INNER JOIN tblSMTaxCodeRate cfTaxCodeRate
					--ON cfTaxCode.intTaxCodeId = cfTaxCodeRate.intTaxCodeId
					WHERE cfTransaction.intTransactionId = @strRecord

			--	END

				DELETE FROM #tmpTransactionId WHERE RecordKey = @intRecordKey
			
			END

	DROP TABLE #tmpTransactionId

	--Select * from @EntriesForInvoice
	--return
	
	BEGIN TRANSACTION

	--select * from @TaxDetails

	EXEC [dbo].[uspARProcessInvoices]
	@InvoiceEntries	= @EntriesForInvoice
	,@LineItemTaxEntries = @TaxDetails
	,@UserId					= @UserId
	,@GroupingOption			= 11
	,@RaiseError				= 1
	,@ErrorMessage				= @ErrorMessage OUTPUT
	,@CreatedIvoices			= @CreatedIvoices OUTPUT
	,@UpdatedIvoices			= @UpdatedIvoices OUTPUT
	,@BatchIdForNewPost			= @BatchId OUTPUT
	,@BatchIdForExistingPost	= @BatchId OUTPUT
	,@BatchIdForNewPostRecap	= @BatchId OUTPUT
	,@BatchIdForExistingRecap	= @BatchId OUTPUT


	DECLARE @intCreatedRecordKey INT
	DECLARE @intCreatedInvoiceId INT
	SET @SuccessfulCount = 0;

	IF (@ErrorMessage IS NULL)
	BEGIN
		IF (@ErrorMessage IS NULL AND @CreatedIvoices IS NOT NULL)
			BEGIN

				IF ((@Recap = 0 OR @Recap IS NULL) AND (@Post = 1))
				BEGIN
					SELECT * INTO #tmpCreatedInvoice
					FROM [fnCFSplitString](@CreatedIvoices,',') 

					SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
					FROM #tmpCreatedInvoice


					WHILE (EXISTS(SELECT 1 FROM #tmpCreatedInvoice ))
					BEGIN
						SELECT @intCreatedRecordKey = RecordKey FROM #tmpCreatedInvoice
						SELECT @intCreatedInvoiceId = CAST(Record AS INT) FROM #tmpCreatedInvoice WHERE RecordKey = @intCreatedRecordKey
				
						UPDATE tblCFTransaction 
						SET ysnPosted = 1, intInvoiceId = @intCreatedInvoiceId
						WHERE intTransactionId = (SELECT intTransactionId 
													FROM tblARInvoice 
													WHERE intInvoiceId = @intCreatedInvoiceId)
				
						DELETE FROM #tmpCreatedInvoice WHERE RecordKey = @intCreatedRecordKey

					END

					DROP TABLE #tmpCreatedInvoice
				END 
				ELSE IF (@Recap = 1)
				BEGIN
					SELECT * INTO #tmpCreatedInvoice2
					FROM [fnCFSplitString](@CreatedIvoices,',') 

					SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
					FROM #tmpCreatedInvoice2


					WHILE (EXISTS(SELECT 1 FROM #tmpCreatedInvoice2 ))
					BEGIN
						SELECT @intCreatedRecordKey = RecordKey FROM #tmpCreatedInvoice2
						SELECT @intCreatedInvoiceId = CAST(Record AS INT) FROM #tmpCreatedInvoice2 WHERE RecordKey = @intCreatedRecordKey
				
						UPDATE tblCFTransaction 
						SET intInvoiceId = @intCreatedInvoiceId
						WHERE intTransactionId = (SELECT intTransactionId 
													FROM tblARInvoice 
													WHERE intInvoiceId = @intCreatedInvoiceId)
				
						DELETE FROM #tmpCreatedInvoice2 WHERE RecordKey = @intCreatedRecordKey

					END

					DROP TABLE #tmpCreatedInvoice2
				END
			
			END

			IF (@ErrorMessage IS NULL AND @UpdatedIvoices IS NOT NULL)
			BEGIN
			
				IF ((@Recap = 0 OR @Recap IS NULL) AND (@Post = 1))
				BEGIN
					SELECT * INTO #tmpUpdatedInvoice
					FROM [fnCFSplitString](@UpdatedIvoices,',') 

					SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
					FROM #tmpUpdatedInvoice


					WHILE (EXISTS(SELECT 1 FROM #tmpUpdatedInvoice ))
					BEGIN
						SELECT @intCreatedRecordKey = RecordKey FROM #tmpUpdatedInvoice
						SELECT @intCreatedInvoiceId = CAST(Record AS INT) FROM #tmpUpdatedInvoice WHERE RecordKey = @intCreatedRecordKey
				
						UPDATE tblCFTransaction 
						SET ysnPosted = 1, intInvoiceId = @intCreatedInvoiceId
						WHERE intTransactionId = (SELECT intTransactionId 
													FROM tblARInvoice 
													WHERE intInvoiceId = @intCreatedInvoiceId)
				
						DELETE FROM #tmpUpdatedInvoice WHERE RecordKey = @intCreatedRecordKey

					END

					DROP TABLE #tmpUpdatedInvoice
				END
				IF (@Recap = 1)
				BEGIN
					SELECT * INTO #tmpUpdatedInvoice2
					FROM [fnCFSplitString](@UpdatedIvoices,',') 

					SELECT @SuccessfulCount = @SuccessfulCount + COUNT(*) 
					FROM #tmpUpdatedInvoice2


					WHILE (EXISTS(SELECT 1 FROM #tmpUpdatedInvoice2 ))
					BEGIN
						SELECT @intCreatedRecordKey = RecordKey FROM #tmpUpdatedInvoice2
						SELECT @intCreatedInvoiceId = CAST(Record AS INT) FROM #tmpUpdatedInvoice2 WHERE RecordKey = @intCreatedRecordKey
				
						UPDATE tblCFTransaction 
						SET intInvoiceId = @intCreatedInvoiceId
						WHERE intTransactionId = (SELECT intTransactionId 
													FROM tblARInvoice 
													WHERE intInvoiceId = @intCreatedInvoiceId)
				
						DELETE FROM #tmpUpdatedInvoice2 WHERE RecordKey = @intCreatedRecordKey

					END

					DROP TABLE #tmpUpdatedInvoice2
				END
			
			END

			COMMIT TRANSACTION
		END
	ELSE
		BEGIN
			--COMMIT TRANSACTION
			ROLLBACK TRANSACTION
		END