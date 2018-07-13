CREATE PROCEDURE [uspETTranslateDigitalDispatcher]
	@StagingTable ETTranslateSDToInvoiceTable READONLY
	,@EntityUserId			INT
	,@ErrorMessage	NVARCHAR(MAX) = '' OUTPUT	
	
AS
BEGIN

	DECLARE @strCustomerNumber						NVARCHAR(100)
	DECLARE @strInvoiceNumber						NVARCHAR(25)
	DECLARE @stri21InvoiceNumber 						NVARCHAR(25)
	
	DECLARE @dtmInvoiceDate							DATETIME
	DECLARE	@strSiteNumber							NVARCHAR(5)
	DECLARE	@strUOM									NVARCHAR(50)
	DECLARE	@dblUnitPrice							NUMERIC(18,6)
	DECLARE	@strItemDescription						NVARCHAR(250)
	DECLARE	@dblPercentFullAfterDelivery			NUMERIC(18,6)
	DECLARE	@strLocation							NVARCHAR(50)
	DECLARE	@strTermCode							NVARCHAR(100)
	DECLARE	@strSalesAccount						NVARCHAR(40)
	DECLARE	@strItemNumber							NVARCHAR(50)
	DECLARE	@strTaxGroup							NVARCHAR(50)
	DECLARE	@strDriverNumber						NVARCHAR(100)
	DECLARE	@strType								NVARCHAR(10)
	DECLARE	@dblQuantity							NUMERIC(18, 6)
	DECLARE	@dblTotal								NUMERIC(18, 6)
	DECLARE	@intLineItem							INT
	DECLARE	@dblPrice								NUMERIC(18, 6)
	DECLARE	@strComment								NVARCHAR(MAX)
	DECLARE @strDetailType							NVARCHAR(2)
	DECLARE @strContractNumber						NVARCHAR(50)
	DECLARE @intContractSequence						INT
	DECLARE @intImportDDToInvoiceId					INT
	DECLARE @intCustomerEntityId					INT
	DECLARE @intDriverEntityId						INT					
	DECLARE @intLocationId							INT
	DECLARE @intItemId								INT
	DECLARE @intSiteId								INT
	DECLARE @intTaxGroupId							INT		
	DECLARE @LogId									INT
	DECLARE @intLocation INT
	DECLARE @strStatus NVARCHAR(50)
	
	--DECLARE @TransactionType						NVARCHAR(25)
	--DECLARE @intTermCode							INT
	--DECLARE @strErrorMessage						NVARCHAR(MAX) 
	--SET @strAllErrorMessage = ''
	
	DECLARE @WarningTableLog TABLE(
		strCustomerNumber			NVARCHAR(100)
		,strSiteNumber				NVARCHAR(5)
		,intLineItem				INT
		,strWarning					NVARCHAR(MAX)
	)

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpDDToInvoice')) 
	BEGIN
		DROP TABLE #tmpDDToInvoice
	END
	
	SELECT intImportDDToInvoiceId = IDENTITY(INT, 1, 1), * INTO #tmpDDToInvoice 
	FROM @StagingTable
	
	DECLARE @EntriesForInvoice AS InvoiceStagingTable

	---Loop through the unique customer invoice date
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpDDToInvoice) 
	BEGIN
					
		SELECT TOP 1 
				@strCustomerNumber			  = strCustomerNumber
				,@strInvoiceNumber			  = strInvoiceNumber
				,@dtmInvoiceDate			  = dtmDate
				,@intLineItem				  = intLineItem
				,@strSiteNumber				  = strSiteNumber	
				,@strUOM					  =	NULL --strUOM no UOM as of this writing. (02022018)
				,@dblUnitPrice				  = dblUnitPrice
				,@strItemDescription		  = strItemDescription
				,@dblPercentFullAfterDelivery = dblPercentFullAfterDelivery
				,@strLocation				  =	strLocation --Company Location
				,@strTermCode				  =	NULL --strTermCode no TERM as of this writing. (02022018)
				,@strSalesAccount			  =	NULL --strSalesAccount no SALES ACCOUNT as of this writing. (02022018)
				,@strItemNumber				  =	strItemNumber
				,@strTaxGroup				  =	strSalesTaxId
				,@strDriverNumber			  =	strDriverNumber
				,@strType					  =	'Invoice'--strType no other type as of this writing 02022018
				,@dblQuantity				  =	dblQuantity
				,@dblTotal					  =	NULL --dblTotal
				,@intLineItem				  =	intLineItem
				,@dblPrice					  =	dblPrice
				,@strComment				  =	strComment
				,@intImportDDToInvoiceId	  = intImportDDToInvoiceId
				,@strDetailType				  = '' --strDetailType not in use as of this writing
				,@strContractNumber			  = '' --strContractNumber no contract
				,@intContractSequence		  = NULL --intContractSequence
			FROM #tmpDDToInvoice
			--ORDER BY intLineItem ASC

			--SET @TransactionType = 'Invoice'

			--Get Customer Entity Id
			SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)

			--TM - Get Site Id
			-------------------------------------------------------------------------------------------------------------------------------------------------
			--SET @intSiteId = ( SELECT TOP 1 intSiteID	FROM tblTMCustomer A INNER JOIN tblTMSite B ON A.intCustomerID = B.intCustomerID
			--											WHERE intCustomerNumber = @intCustomerEntityId AND B.intSiteNumber = CAST(@strSiteNumber AS INT))

			DECLARE @intSiteItemTaxId INT
			DECLARE @intSiteProductId INT
			DECLARE @dblSiteProductPrice NUMERIC(18,6)
			SELECT TOP 1 @intSiteId = B.intSiteID
						,@intSiteItemTaxId = intTaxStateID	
						,@dblSiteProductPrice = dblPrice
						,@intSiteProductId = intProduct
			FROM tblTMCustomer A
					INNER JOIN tblTMSite B ON A.intCustomerID = B.intCustomerID
					LEFT JOIN tblTMDispatch C ON B.intSiteID = C.intSiteID
			WHERE intCustomerNumber = @intCustomerEntityId AND B.intSiteNumber = CAST(@strSiteNumber AS INT)

			SET @intTaxGroupId = (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = @strTaxGroup)
			--Tax Mismatch Checking...
			IF ISNULL(@intSiteItemTaxId,0) <> ISNULL(@intTaxGroupId,0)
					BEGIN
						INSERT INTO @WarningTableLog (strCustomerNumber ,strSiteNumber,intLineItem ,strWarning)
						SELECT strCustomerNumber = @strCustomerNumber 
								,strSiteNumber = @strSiteNumber 
								,intLineItem = @intImportDDToInvoiceId 
								,strStatus = 'Tax Mismatch'
					END
		
			--Get Item id
			SET @intItemId = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = @strItemNumber)
			SET @intItemId = ISNULL(@intItemId,0)
			--Item Mismatch Checking...
			IF ISNULL(@intSiteProductId,0) <> ISNULL(@intItemId,0)
					BEGIN
						
						INSERT INTO @WarningTableLog (strCustomerNumber ,strSiteNumber,intLineItem ,strWarning)
						SELECT strCustomerNumber = @strCustomerNumber 
								,strSiteNumber = @strSiteNumber 
								,intLineItem = @intImportDDToInvoiceId 
								,strStatus = 'Product Mismatch'
					END

			
			 SET @dblSiteProductPrice =  (SELECT TOP 1 dblPrice   FROM tblTMDispatch  WHERE intSiteID = @intSiteId)
			--Price Mismatch Checking...
			IF ISNULL(@dblPrice,0) <> ISNULL(@dblSiteProductPrice ,0)
					BEGIN
						
						INSERT INTO @WarningTableLog (strCustomerNumber ,strSiteNumber,intLineItem ,strWarning)
						SELECT strCustomerNumber = @strCustomerNumber 
								,strSiteNumber = @strSiteNumber 
								,intLineItem = @intImportDDToInvoiceId 
								,strStatus = 'Price Mismatch'
					END

				--Invoice Number
			SET @stri21InvoiceNumber =  ISNULL((SELECT TOP 1 strPrefix COLLATE Latin1_General_CI_AS FROM tblSMStartingNumber  WHERE strTransactionType COLLATE Latin1_General_CI_AS = 'Truck Billing' AND strModule COLLATE Latin1_General_CI_AS = 'Energy Trac') , '')
									+	REPLACE(@strInvoiceNumber COLLATE Latin1_General_CI_AS,'-', '')   
			 
						
			--Get Entity ID of the Driver
			SET @intDriverEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo COLLATE Latin1_General_CI_AS = @strDriverNumber )
			
			--Get Location Id  
			/*Convert to Numeric DIGITAL DISPATCH send divisionNUm as numeric(int)*/
   			SET @intLocation  = (SELECT CASE WHEN ISNUMERIC(@strLocation) = 1 THEN CAST(@strLocation AS INT) ELSE NULL END)
			SET @intLocationId = ISNULL((SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation 
								WHERE (CASE WHEN ISNUMERIC(strLocationNumber) = 1 THEN CAST(strLocationNumber  AS INT) ELSE 0 END) = @intLocation),0)  
			
			--------Get Item Unit Measure Id = ()
			------SET @intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol = @strUOM)
			---------Get Uom ID
			------SET	@intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)
			
			--------Get Term Code
			------SET @intTermCode = (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTermCode = @strTermCode)


			INSERT INTO @EntriesForInvoice(
							 [strSourceTransaction]
							 ,[intEntityCustomerId]
							 ,[intSiteId]
							 ,[strInvoiceOriginId]
							 ,[ysnUseOriginIdAsInvoiceNumber]
							 ,[intTaxGroupId]
							 ,[intItemId]
							 ,[strType] 
							--,[strTransactionType]
							,[ysnRecomputeTax]
							,[intInvoiceId]
							,[intCompanyLocationId]
							,[dtmDate]
							,[intEntitySalespersonId]
							,[intFreightTermId]
							,[intPaymentMethodId]
							--,[strDeliverPickup]
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
							,[intInvoiceDetailId]
							,[intOrderUOMId]
							,[dblQtyOrdered]
							,[dblQtyShipped]
							,[intItemUOMId]
							
							,[dblPrice]
							,[ysnRefreshPrice]
							,[strMaintenanceType]
							,[strFrequency]
							,[dtmMaintenanceDate]
							,[dblMaintenanceAmount]
							,[dblLicenseAmount]
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
							,[intId]
							,[strSourceId]
							--,[intSourceId]
							--,[strBillingBy]
							--,[dblPercentFull]
							--,[dblNewMeterReading]
							--,[dblPreviousMeterReading]
							--,[dblConversionFactor]
							--,[intPerformerId]
							--,[ysnLeaseBilling]
							--,[ysnVirtualMeterReading]
							--,[strImportFormat]
							--,[dblCOGSAmount]
							--,[intTempDetailIdForTaxes]
							--,[intConversionAccountId]
							--,[intCurrencyExchangeRateTypeId]
							--,[intCurrencyExchangeRateId]
							--,[dblCurrencyExchangeRate]
							--,[intSubCurrencyId]
							--,[dblSubCurrencyRate]
							--,[ysnInventory]
							
							
							--,[intCurrencyId]
							--,[intTermId]
							--,[dtmDueDate]
							--,[dtmShipDate]
							--,[dtmPostDate]
							--,[intShipViaId]
							--,[strPONumber]
							--,[strBOLNumber]
							--,[strComments]
							--,[ysnPost]
							--,[strItemDescription]
							--,[dblDiscount]
						)
						SELECT 
							 [strSourceTransaction]		= 'Direct'
							 ,[intEntityCustomerId]		= ISNULL(@intCustomerEntityId,0)
							 ,[intSiteId]				= @intSiteId
							 ,[strInvoiceOriginId]		= @stri21InvoiceNumber
							 ,[ysnUseOriginIdAsInvoiceNumber] = 1
							 ,[intTaxGroupId]			= @intTaxGroupId
							 ,[intItemId]				= @intItemId
							 ,[strType] = 'Tank Delivery'
							--,[strTransactionType]		= 'Tank Delivery'
							,[ysnRecomputeTax]			= 1
							,[intInvoiceId]				= NULL
							,[intCompanyLocationId]		= ISNULL(@intLocationId,0)
							,[dtmDate]					= @dtmInvoiceDate
							,[intEntitySalespersonId]	= @intDriverEntityId
							,[intFreightTermId]			= NULL
							
							,[intPaymentMethodId]		= NULL
							
							
							--,[strDeliverPickup]			= NULL
							
							,[intShipToLocationId]		= NULL
							,[intBillToLocationId]		= NULL
							,[ysnTemplate]				= 0
							,[ysnForgiven]				= 0
							,[ysnCalculated]			= 0
							,[ysnSplitted]				= 0
							,[intPaymentId]				= NULL
							,[intSplitId]				= NULL
							,[intLoadDistributionHeaderId]	= NULL
							,[strActualCostId]			= NULL
							,[intShipmentId]			= NULL
							,[intTransactionId]			= NULL
							,[intEntityId]				= @EntityUserId
							,[ysnResetDetails]			= 1
							,[intInvoiceDetailId]		= NULL
							,[intOrderUOMId]			= NULL
							,[dblQtyOrdered]			= @dblQuantity
							,[dblQtyShipped]			= @dblQuantity
							,[intItemUOMId]				= NULL
							
							,[dblPrice]					= @dblPrice
							,[ysnRefreshPrice]			= 0
							,[strMaintenanceType]		= NULL
							,[strFrequency]				= NULL
							,[dtmMaintenanceDate]		= NULL
							,[dblMaintenanceAmount]		= NULL
							,[dblLicenseAmount]			= NULL
							,[intSCInvoiceId]			= NULL
							,[strSCInvoiceNumber]		= NULL
							,[intInventoryShipmentItemId] = NULL
							,[strShipmentNumber]		= NULL
							,[intSalesOrderDetailId]	= NULL
							,[strSalesOrderNumber]		= NULL
							,[intContractHeaderId]		= NULL
							,[intContractDetailId]		= NULL
							,[intShipmentPurchaseSalesContractId]	= NULL
							,[intTicketId]				= NULL
							,[intTicketHoursWorkedId]	= NULL
							,[intId] = @intImportDDToInvoiceId
							,[strSourceId]				= @strInvoiceNumber
							--,[intSourceId]				= @intImportDDToInvoiceId
							--,[strBillingBy]				= @BillingBy
							--,[dblPercentFull]			= @PercentFull
							--,[dblNewMeterReading]		= @NewMeterReading
							--,[dblPreviousMeterReading]	= @PreviousMeterReading
							--,[dblConversionFactor]		= @ConversionFactor
							--,[intPerformerId]			= @PerformerId
							--,[ysnLeaseBilling]			= NULL
							--,[ysnVirtualMeterReading]	= CASE WHEN @BillingBy = 'Virtual Meter' THEN 1 ELSE 0 END
							--,[strImportFormat]			= @ImportFormat
							--,[dblCOGSAmount]			= CASE WHEN @ImportFormat = @IMPORTFORMAT_CARQUEST THEN @COGSAmount ELSE NULL END
							--,[intTempDetailIdForTaxes]  = @ImportLogDetailId
							--,[intConversionAccountId]	= @ConversionAccountId
							--,[intCurrencyExchangeRateTypeId]	= NULL
							--,[intCurrencyExchangeRateId]		= NULL
							--,[dblCurrencyExchangeRate]	= 1.000000
							--,[intSubCurrencyId]			= NULL
							--,[dblSubCurrencyRate]		= 1.000000
							--,[ysnInventory]				= CASE WHEN @IsTank = 1 OR @ImportFormat = @IMPORTFORMAT_CARQUEST AND ISNULL(@ItemId, 0) > 0 THEN 
							--								CASE WHEN (SELECT TOP 1 strType FROM tblICItem WHERE intItemId = @ItemId) = 'Inventory' THEN 1 ELSE 0 END
							--							  ELSE 0 END
							
							
							--,[intCurrencyId]			= @DefaultCurrencyId
							--,[intTermId]				= @TermId
							--,[dtmDueDate]				= @DueDate
							--,[dtmShipDate]				= @ShipDate
							--,[dtmPostDate]				= @PostDate
							--,[intShipViaId]				= @ShipViaId
							--,[strPONumber]				= @PONumber
							--,[strBOLNumber]				= @BOLNumber
							--,[strComments]				= @Comment
							--,[ysnPost]					= NULL
							--,[strItemDescription]		= @ItemDescription
							--,[dblDiscount]				= @DiscountPercentage
							
			--Delete 
			DELETE FROM #tmpDDToInvoice WHERE intImportDDToInvoiceId = @intImportDDToInvoiceId		
	END

	--SELECT * FROM @EntriesForInvoice
	--(AR)Process
	-------------------------------------------------------------------------------------------------------------------------------------------------------
	DECLARE	 @LineItemTaxEntries	LineItemTaxDetailStagingTable
	EXEC [dbo].[uspARProcessInvoicesByBatch]
					@InvoiceEntries	 = @EntriesForInvoice
					,@LineItemTaxEntries =  @LineItemTaxEntries
					,@UserId			 = @EntityUserId
		 			,@GroupingOption	 = 15
					,@RaiseError		 = 0
					,@ErrorMessage		 = @ErrorMessage OUTPUT
					,@LogId				 = @LogId OUTPUT		 

					--,@CreatedIvoices	 = @CreatedIvoices OUTPUT
					--SET @NewTransactionId = (SELECT TOP 1 intID FROM fnGetRowsFromDelimitedValues(@CreatedIvoices))

	-------------------------------------------------------------------------------------------------------------------------------------------------------
		
	 SELECT * FROM ( SELECT  NULL AS strCustomerNumber    
		 ,ISNULL(tblARInvoice.strInvoiceNumber, '') AS strInvoiceNumber    
		 ,'' AS strSiteNumber     
		 ,null AS dtmDate      
		 ,0 AS intLineItem     
		 ,'' AS strFileName     
		 ,strMessage  AS strStatus      
		 ,ysnSuccess AS ysnSuccessful     
		 ,ISNULL(tblARInvoiceIntegrationLogDetail.intInvoiceId,0) AS intInvoiceId  
		 ,tblARInvoiceIntegrationLogDetail.strTransactionType AS strTransactionType  
		 FROM tblARInvoiceIntegrationLogDetail    
		 LEFT JOIN tblARInvoice ON tblARInvoiceIntegrationLogDetail.intInvoiceId = tblARInvoice.intInvoiceId  
    
		 WHERE ysnHeader = 1 AND ysnSuccess = 1 AND intIntegrationLogId = @LogId 
		 --AND NOT EXISTS(SELECT TOP 1 1 FROM tblARInvoiceIntegrationLogDetail WHERE ysnHeader = 0 AND ysnSuccess = 0 AND intIntegrationLogId = @LogId )  
		 UNION  
		 SELECT   NULL AS strCustomerNumber    
		   ,'' AS strInvoiceNumber    
		   ,'' AS strSiteNumber     
		   ,null AS dtmDate      
		   ,0 AS intLineItem     
		   ,'' AS strFileName     
		   ,strMessage  AS strStatus      
		   ,ysnSuccess AS ysnSuccessful     
		   ,ISNULL(intInvoiceId,0) AS intInvoiceId  
		   ,strTransactionType AS strTransactionType  
		 FROM tblARInvoiceIntegrationLogDetail   
		 WHERE ysnSuccess = 0 AND intIntegrationLogId = @LogId  
		 ) ResultTableLog
		--SELECT * FROM @ResultTableLog

END
GO