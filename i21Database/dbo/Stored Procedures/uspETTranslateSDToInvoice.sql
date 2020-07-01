CREATE  PROCEDURE [uspETTranslateSDToInvoice]
	@StagingTable ETTranslateSDToInvoiceTable READONLY
	,@EntityUserId			INT
	,@strAllErrorMessage	NVARCHAR(MAX) = '' OUTPUT	
	
AS
BEGIN

	DECLARE @strCustomerNumber						NVARCHAR(100)
	DECLARE @strInvoiceNumber						NVARCHAR(25)
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
	DECLARE	@strSalesTaxId							NVARCHAR(50)
	DECLARE	@strDriverNumber						NVARCHAR(100)
	DECLARE	@strType								NVARCHAR(10)
	DECLARE	@dblQuantity							NUMERIC(18, 6)
	DECLARE	@dblTotal								NUMERIC(18, 6)
	DECLARE	@intLineItem							INT
	DECLARE	@intTaxKey							    INT
	DECLARE	@dblPrice								NUMERIC(18, 6)
	DECLARE	@strComment								NVARCHAR(MAX)
	DECLARE @strDetailType							NVARCHAR(2)
	DECLARE @strContractNumber						NVARCHAR(50)
	DECLARE @intImportSDToInvoiceId					INT
	DECLARE @intContractSequence						INT

	DECLARE @strCustomerNumberTax						NVARCHAR(100)
	DECLARE @strInvoiceNumberTax						NVARCHAR(25)
	DECLARE @dtmInvoiceDateTax							DATETIME
	DECLARE	@strSiteNumberTax							NVARCHAR(5)
	DECLARE	@strUOMTax									NVARCHAR(50)
	DECLARE	@dblUnitPriceTax							NUMERIC(18,6)
	DECLARE	@strItemDescriptionTax						NVARCHAR(250)
	DECLARE	@dblPercentFullAfterDeliveryTax			NUMERIC(18,6)
	DECLARE	@strLocationTax							NVARCHAR(50)
	DECLARE	@strTermCodeTax							NVARCHAR(100)
	DECLARE	@strSalesAccountTax						NVARCHAR(40)
	DECLARE	@strItemNumberTax							NVARCHAR(50)
	DECLARE	@strSalesTaxIdTax							NVARCHAR(50)
	DECLARE	@strDriverNumberTax						NVARCHAR(100)
	DECLARE	@strTypeTax								NVARCHAR(10)
	DECLARE	@dblQuantityTax							NUMERIC(18, 6)
	DECLARE	@dblTotalTax								NUMERIC(18, 6)
	DECLARE	@intLineItemTax							INT
	DECLARE	@dblPriceTax								NUMERIC(18, 6)
	DECLARE	@strCommentTax								NVARCHAR(MAX)
	DECLARE @strDetailTypeTax							NVARCHAR(2)
	DECLARE @strContractNumberTax						NVARCHAR(50)
	DECLARE @intImportSDToInvoiceIdTax					INT
	DECLARE @intCustomerEntityId					INT
	DECLARE @intLocationId							INT
	DECLARE @intCntIdUniqueInvoiceCustomerDate		INT
	DECLARE @intNewInvoiceId						INT
	DECLARE @intItemId								INT
	DECLARE @intSiteId								INT
	DECLARE @strErrorMessage						NVARCHAR(MAX) 
	DECLARE @strTransactionType						NVARCHAR(25)
	DECLARE @intTermCode							INT
	DECLARE @intDriverEntityId						INT					
	DECLARE @intTaxGroupId							INT		
	DECLARE @strSiteBillingBy						NVARCHAR(10)
	DECLARE @intItemUOMId							INT		
	DECLARE @intUnitMeasureId						INT	
	DECLARE @ysnHeader								BIT
	DECLARE @intNewInvoiceDetailId					INT
	DECLARE @strNewInvoiceNumber					NVARCHAR(25)
	--DECLARE @ysnProcessNextAsHeader					BIT
	DECLARE @intContractDetailId					INT
	DECLARE @intTaxCodeId							INT
	DECLARE @ysnTaxExempt							BIT
	DECLARE @intTaxClassId							INT
	DECLARE	@strPONumber						    NVARCHAR(50)
	DECLARE @ShipViaId INT

	DECLARE @ContractAvailableQuantity	NUMERIC(18, 6)
	DECLARE @ContractOverFillQuantity	NUMERIC(18, 6)
	DECLARE @getARPrice	BIT
	DECLARE @strStatus					NVARCHAR(50)
	DECLARE @intEntitySalespersonId INT

	
	DECLARE @ResultTableLog TABLE(
		strCustomerNumber			NVARCHAR(100)
		,strInvoiceNumber			NVARCHAR(25)
		,strSiteNumber				NVARCHAR(5)
		,dtmDate					DATETIME
		,intLineItem				INT
		,strFileName				NVARCHAR(300)
		,strStatus					NVARCHAR(MAX)
		,ysnSuccessful				BIT
		,intInvoiceId				INT
		,strTransactionType 		NVARCHAR(25)
	)

	SET @strAllErrorMessage = ''

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpSDToInvoice')) 
	BEGIN
		DROP TABLE #tmpSDToInvoice
	END
	SELECT intImportSDToInvoiceId = IDENTITY(INT, 1, 1), * INTO #tmpSDToInvoice 
	FROM @StagingTable

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpUniqueInvoiceList')) 
	BEGIN
		DROP TABLE #tmpUniqueInvoiceList
	END
	--Get the unique list of Customer, Invoice Number and date
	SELECT DISTINCT 
		strCustomerNumber
		,strInvoiceNumber
		,dtmDate
		,intCntId = ROW_NUMBER() OVER (ORDER BY strCustomerNumber)
	INTO #tmpUniqueInvoiceList
	FROM #tmpSDToInvoice
	

	
	---Loop through the unique customer invoice date
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUniqueInvoiceList) 
	BEGIN
		--BEGIN TRANSACTION
		SET @strStatus = ''
		
		SELECT TOP 1
			@strCustomerNumber = strCustomerNumber
			,@strInvoiceNumber = strInvoiceNumber
			,@dtmInvoiceDate = dtmDate
			,@intCntIdUniqueInvoiceCustomerDate = intCntId
		FROM #tmpUniqueInvoiceList		
				
		IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCustomerInvoiceDetail')) 
		BEGIN
			DROP TABLE #tmpCustomerInvoiceDetail
		END

		--Get the Details 
		SELECT *
		INTO #tmpCustomerInvoiceDetail
		FROM  #tmpSDToInvoice
		WHERE strCustomerNumber = @strCustomerNumber
			AND strInvoiceNumber = @strInvoiceNumber
			AND dtmDate = @dtmInvoiceDate
			AND strDetailType = 'D'
		
		
		/*TaxDetail*/
		------------------------------------------------------------------------------------------------------------------
		IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCustomerInvoiceTaxDetail')) 
		BEGIN
			DROP TABLE #tmpCustomerInvoiceTaxDetail
		END
		
		
		SELECT *
		INTO #tmpCustomerInvoiceTaxDetail
		FROM  #tmpSDToInvoice
		WHERE strCustomerNumber = @strCustomerNumber
			AND strInvoiceNumber = @strInvoiceNumber
			AND dtmDate = @dtmInvoiceDate
			AND strDetailType <> 'D'

		DECLARE @ysnARCompute AS BIT
		--Check if has negative taxcode id (workaround) for tagging that ET app not sending yet taxcode id
		select TOP 1 @intTaxCodeId = intTaxCodeId FROM #tmpCustomerInvoiceTaxDetail where ISNULL(intTaxCodeId,0) = -1
		
		IF @intTaxCodeId = -1 
		set @ysnARCompute  = 1 
		ELSE 
		set @ysnARCompute = 0
		------------------------------------------------------------------------------------------------------------------

		--BEGIN TRANSACTION
		SET @ysnHeader = 1
		--Loop through the details 
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomerInvoiceDetail)
		BEGIN
			SET @strErrorMessage = ''
			SET @ContractOverFillQuantity = 0
			
			SET @strContractNumber = ''
			SET @intContractDetailId = NULL
			SET @dblQuantity = 0
			SET @getARPrice = 0
			--SET @ysnProcessNextAsHeader = 0
			--Get the first Record and create Invoice
			SELECT TOP 1 
				@strCustomerNumber			  = strCustomerNumber
				,@strInvoiceNumber			  = strInvoiceNumber
				,@dtmInvoiceDate			  = dtmDate
				,@intLineItem				  = intLineItem
				,@strSiteNumber				  = strSiteNumber	
				,@strUOM					  =	strUOM
				,@dblUnitPrice				  = dblUnitPrice
				,@strItemDescription		  = strItemDescription
				,@dblPercentFullAfterDelivery = dblPercentFullAfterDelivery
				,@strLocation				  =	strLocation
				,@strTermCode				  =	strTermCode
				,@strSalesAccount			  =	strSalesAccount
				,@strItemNumber				  =	strItemNumber
				,@strSalesTaxId				  =	strSalesTaxId
				,@strDriverNumber			  =	strDriverNumber
				,@strType					  =	strType
				,@dblQuantity				  =	dblQuantity
				,@dblTotal					  =	dblTotal
				,@intLineItem				  =	intLineItem
				,@dblPrice					  =	dblPrice
				,@strComment				  =	strComment
				,@intImportSDToInvoiceId	  = intImportSDToInvoiceId
				,@strDetailType				  = strDetailType
				,@strContractNumber			  = strContractNumber
				,@intContractSequence		  = intContractSequence
				,@strPONumber				  = strPONumber
				,@intTaxKey				  = intKey
			FROM #tmpCustomerInvoiceDetail
			ORDER BY intLineItem ASC

			--Get Customer Entity Id
			SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)
			--Get Location Id
			SET @intLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @strLocation)
			--Get Item id
			SET @intItemId = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = @strItemNumber)
			---Set TransactionType
			SET @strTransactionType = (SELECT (CASE	WHEN @strType = 'B' THEN 'Invoice'
													WHEN @strType = 'A' THEN 'Cash'
													ELSE
														'Invoice'
												END))
			--Get Term Code
			SET @intTermCode = (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTermCode = @strTermCode)
			--Get Entity ID of the Driver
			--SET @intDriverEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strDriverNumber)
			SET @intDriverEntityId = (SELECT TOP 1 intEntityId FROM tblARSalesperson where strType = 'Driver' and strDriverNumber COLLATE Latin1_General_CI_AS = @strDriverNumber)
			/*----------------------------------------------------------------------------    
			 --Default Salesperson to the Salesperson from Customer Setup (IET-359)    
			 --If Customer Setup for Salesperson is blank    
			 --Then Set to Driver Number    
			 */----------------------------------------------------------------------------    
			 SET @intEntitySalespersonId = ISNULL((SELECT TOP 1 intSalespersonId FROM tblARCustomer where intEntityId = @intCustomerEntityId),@intDriverEntityId)    
			
			---GEt Tax Group Id
					--SET @intTaxGroupId = (SELECT TOP 1 B.intTaxGroupId 
					--						FROM tblSMTaxCode A
					--						INNER JOIN  tblSMTaxGroupCode B
					--							ON A.intTaxCodeId = B.intTaxCodeId
					--						WHERE A.strTaxCode = @strSalesTaxId)
			IF(LEN(@strSalesTaxId) > 2) 
			SET @intTaxGroupId = (SELECT SUBSTRING(@strSalesTaxId,3,LEN(@strSalesTaxId)-2))
			
			--get Item Unit Measure Id = ()
			SET @intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol = @strUOM)
			---Get Uom ID
			SET	@intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)
			
			
			IF(LTRIM(RTRIM(@strContractNumber)) <> '')
			BEGIN
			--Get contract ID
			--SET @intContractDetailId = (SELECT TOP 1 B.intContractDetailId 
			--								FROM tblCTContractHeader A
			--								INNER JOIN tblCTContractDetail B
			--									ON A.intContractHeaderId = B.intContractHeaderId
			--								WHERE A.strContractNumber = @strContractNumber
			--								AND A.intEntityId = @intCustomerEntityId
			--								AND B.intContractSeq = @intContractSequence)
			
			SELECT TOP 1 @intContractDetailId	= ARCC.[intContractDetailId]
						,@ContractAvailableQuantity = ARCC.[dblAvailableQty]
			FROM
				[vyuCTCustomerContract] ARCC
			WHERE
				ARCC.[intEntityCustomerId] = @intCustomerEntityId
				AND ARCC.[intItemId] = @intItemId
				AND CAST(@dtmInvoiceDate AS DATE) BETWEEN CAST(ARCC.[dtmStartDate] AS DATE) AND 
													CAST(ISNULL(ARCC.[dtmEndDate], @dtmInvoiceDate) AS DATE) 
				AND ARCC.[strContractStatus] NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
				AND (ARCC.[dblAvailableQty] > 0) 

				AND ARCC.strContractNumber = @strContractNumber
				--AND ARCC.intEntityId = @intCustomerEntityId
				AND ARCC.intContractSeq = @intContractSequence
			ORDER BY
					dtmStartDate
				,intContractSeq

			--get another contract if contract number from file does not available
			IF(@intContractDetailId IS NULL)
				BEGIN
				
				SELECT TOP 1 @intContractDetailId	= ARCC.[intContractDetailId]
							,@ContractAvailableQuantity = ARCC.[dblAvailableQty]
				FROM
					[vyuCTCustomerContract] ARCC
				WHERE
					ARCC.[intEntityCustomerId] = @intCustomerEntityId
					AND ARCC.[intItemId] = @intItemId
					AND CAST(@dtmInvoiceDate AS DATE) BETWEEN CAST(ARCC.[dtmStartDate] AS DATE) AND 
														CAST(ISNULL(ARCC.[dtmEndDate], @dtmInvoiceDate) AS DATE) 
					AND ARCC.[strContractStatus] NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
					AND (ARCC.[dblAvailableQty] > 0) 				
				ORDER BY
						dtmStartDate
					,intContractSeq

				SET @getARPrice = 1
				SET @strStatus = @strStatus + ', Has Contract Discrepancy' --Has contract number from file - but contract does not have available qty

					IF(NOT @intContractDetailId IS NULL)
						BEGIN
							SET @ContractOverFillQuantity = (@dblQuantity - @ContractAvailableQuantity )
								
							IF(@ContractOverFillQuantity > 0) 
							BEGIN
								SET @dblQuantity = @ContractAvailableQuantity
								--SET @strStatus = @strStatus + ', Has Contract Discrepancy'
							END
						END
      --              ELSE
						--BEGIN
						--	--SET @strStatus = @strStatus + ', Has Contract Discrepancy'
						--END
		
				END
			ELSE
				BEGIN
					SET @ContractOverFillQuantity = (@dblQuantity - @ContractAvailableQuantity )
								
					IF(@ContractOverFillQuantity > 0) -- Has contract number from file - but it overfills the contract.
					BEGIN
						SET @dblQuantity = @ContractAvailableQuantity
						SET @strStatus = @strStatus + ', Has Contract Discrepancy'
					END

					SET @getARPrice = 0
				END
			--IF(NOT @intContractDetailId IS NULL) 
			--BEGIN 
				
			--END
			--ELSE
			--BEGIN
			--	SET @strStatus = @strStatus + ', Has Contract Discrepancy' -- Has contract number from file - but no available contract found upon import.
			--END

			END

				--TM----------------------------------------------------------------------------------------------------------------------------
				--Get Site Id 
				SET @intSiteId = ( SELECT TOP 1 intSiteID	FROM tblTMCustomer A INNER JOIN tblTMSite B ON A.intCustomerID = B.intCustomerID
															WHERE intCustomerNumber = @intCustomerEntityId AND B.intSiteNumber = CAST( REPLACE(@strSiteNumber, '.', '') AS INT)
															)
				----------------------------------------------------------------------------------------------------------------------------

			---Insert/Create Invoice 
			IF(@ysnHeader = 1)
				BEGIN
				
				SET @ShipViaId =  (SELECT TOP 1 intEntityId FROM tblSMShipVia WHERE ysnCompanyOwnedCarrier = 1)
				BEGIN TRANSACTION

					EXEC [dbo].[uspARCreateCustomerInvoice]
						@EntityCustomerId          = @intCustomerEntityId
						,@InvoiceDate              = @dtmInvoiceDate
						,@CompanyLocationId        = @intLocationId
						,@EntityId                 = @EntityUserId
						,@NewInvoiceId             = @intNewInvoiceId OUTPUT
						,@ErrorMessage             = @strErrorMessage OUTPUT
						,@ItemId                   = @intItemId
						,@ItemQtyShipped           = @dblQuantity
						,@ItemPrice                = @dblPrice
						,@ItemSiteId               = @intSiteId
						,@TransactionType	       = @strTransactionType
						,@Type					   = 'Tank Delivery'
						,@TermId				   = @intTermCode
						,@ShipDate				   = @dtmInvoiceDate
						,@EntitySalespersonId	   = @intEntitySalespersonId		
						,@Comment				   = @strComment	
						,@ItemPercentFull		   = @dblPercentFullAfterDelivery
						,@ItemTaxGroupId		   = NULL--@intTaxGroupId	
						,@ItemDescription		   = @strItemDescription
						,@ItemUOMId				   = @intItemUOMId
						,@BOLNumber				   = @strInvoiceNumber
						,@ItemContractDetailId     = @intContractDetailId
						,@RaiseError			   = 0
						,@UseOriginIdAsInvoiceNumber = 1
						,@InvoiceOriginId         = @strInvoiceNumber
						,@PONumber				   =@strPONumber
						,@RefreshPrice = @getARPrice
						,@RecomputeTax	= @ysnARCompute
						,@ShipViaId = @ShipViaId
						,@TruckDriverId = @intDriverEntityId

					--GEt the created invoice number
					SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 
					SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId)
					--SELECT * FROM tblARInvoiceDetailTax WHERE intInvoiceDetailId = @intNewInvoiceDetailId
					--Check if any error in creating invoice 
					--Log Entry
					LOGHEADERENTRY:
					IF 	LTRIM(@strErrorMessage) != ''
						BEGIN		
							ROLLBACK TRANSACTION
					
							-- Insert the header to log table 	
							INSERT INTO @ResultTableLog ( strCustomerNumber ,strInvoiceNumber ,strSiteNumber ,dtmDate ,intLineItem ,strFileName ,strStatus ,ysnSuccessful ,intInvoiceId ,strTransactionType )
							SELECT strCustomerNumber = @strCustomerNumber ,strInvoiceNumber = @strInvoiceNumber ,strSiteNumber = @strSiteNumber, dtmDate = @dtmInvoiceDate ,intLineItem = @intLineItem ,strFileName = '' ,strStatus = @strErrorMessage ,ysnSuccessful = 0 ,intInvoiceId = @intNewInvoiceId							,strTransactionType = 'Invoice'										
							GOTO CONTINUELOOP
						END
				END
			ELSE
				BEGIN
			ADDITEM:
				IF ISNULL(@intNewInvoiceId, 0) <> 0
				BEGIN			
					EXEC [dbo].[uspARInsertTransactionDetail] @InvoiceId = @intNewInvoiceId, @UserId = @EntityUserId
				END	
				---- Add as line Item to Existing Invoice
				EXEC [dbo].[uspARAddInventoryItemToInvoice]
						@InvoiceId = @intNewInvoiceId
						,@NewInvoiceDetailId = @intNewInvoiceDetailId OUTPUT
						,@ErrorMessage = @strErrorMessage OUTPUT
						,@ItemId                   = @intItemId
						,@ItemQtyShipped           = @dblQuantity
						,@ItemPrice                = @dblPrice
						,@ItemSiteId               = @intSiteId
						,@ItemPercentFull		   = @dblPercentFullAfterDelivery
						,@ItemTaxGroupId		   = NULL	
						,@ItemDescription		   = @strItemDescription
						,@ItemUOMId				   = @intItemUOMId
						,@ItemContractDetailId     = @intContractDetailId
						,@ItemCurrencyExchangeRateTypeId = NULL            
                        ,@ItemCurrencyExchangeRateId = NULL            
						,@RecomputeTax			   = @ysnARCompute
						,@RefreshPrice = @getARPrice

				LOGDETAILENTRY:
				IF 	LTRIM(@strErrorMessage) != ''
					BEGIN		
						ROLLBACK TRANSACTION

						---insert log table
						INSERT INTO @ResultTableLog ( strCustomerNumber ,strInvoiceNumber ,strSiteNumber ,dtmDate ,intLineItem ,strFileName ,strStatus ,ysnSuccessful ,intInvoiceId ,strTransactionType )
						SELECT strCustomerNumber = @strCustomerNumber ,strInvoiceNumber = @strInvoiceNumber ,strSiteNumber = @strSiteNumber ,dtmDate = @dtmInvoiceDate ,intLineItem = @intLineItem ,strFileName = '' ,strStatus = @strErrorMessage ,ysnSuccessful = 0 ,intInvoiceId = @intNewInvoiceId ,strTransactionType = 'Invoice'
						GOTO CONTINUELOOP
					END
			END

			/*Insert Taxes*/
			------------------------------------
			IF EXISTS(SELECT TOP 1 1 FROM #tmpCustomerInvoiceTaxDetail) AND @ysnARCompute = 0
			BEGIN
				--Check for Detail Tax
				IF(@intLineItem <> 0)
				BEGIN
					IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpLineTax')) 
					BEGIN
						DROP TABLE #tmpLineTax
					END
					
					--Get Tax detail for the line item
					SELECT * INTO #tmpLineTax
					FROM #tmpCustomerInvoiceTaxDetail
					WHERE (( intKey - 100 ) = @intTaxKey)

					--SELECT * from #tmpLineTax

					
					WHILE EXISTS(SELECT TOP 1 1 FROM #tmpLineTax)
					BEGIN
						SELECT TOP 1 
							@strCustomerNumberTax			  = strCustomerNumber
							,@strInvoiceNumberTax			  = strInvoiceNumber
							,@dtmInvoiceDateTax				  = dtmDate
							,@intLineItemTax				  = intLineItem
							,@strSiteNumberTax				  = strSiteNumber	
							,@strUOMTax						  =	strUOM
							,@dblUnitPriceTax				  = dblUnitPrice
							,@strItemDescriptionTax		      = strItemDescription
							,@dblPercentFullAfterDeliveryTax  = dblPercentFullAfterDelivery
							,@strLocationTax				  =	strLocation
							,@strTermCodeTax				  =	strTermCode
							,@strSalesAccountTax			  =	strSalesAccount
							,@strItemNumberTax				  =	strItemNumber
							,@strSalesTaxIdTax				  =	strSalesTaxId
							,@strDriverNumberTax			  =	strDriverNumber
							,@strTypeTax					  =	strType
							,@dblQuantityTax				  =	dblQuantity
							,@dblTotalTax					  =	dblTotal
							,@intLineItemTax				  =	intLineItem
							,@dblPriceTax					  =	dblPrice
							,@strCommentTax					  =	strComment
							,@intImportSDToInvoiceIdTax		  = intImportSDToInvoiceId
							,@strDetailTypeTax				  = strDetailType
							,@strContractNumberTax			  = strContractNumber
							,@intTaxCodeId  = intTaxCodeId
							,@ysnTaxExempt = ysnTaxExempt
						FROM #tmpLineTax
						
						ORDER BY intLineItem ASC
						
						----GetTaxcode detail
						--SET @intTaxCodeId = NULL
						--SET @intTaxClassId = NULL
						--SET @intTaxGroupId = NULL
						IF(ISNULL(@intTaxCodeId,0) <> -1)
						BEGIN
							SELECT TOP 1 
								@intTaxCodeId = intTaxCodeId 
							--	,@intTaxClassId = intTaxClassId
							FROM tblSMTaxCode 
							WHERE intTaxCodeId = @intTaxCodeId
						END

						IF (ISNULL(@intTaxCodeId,0) = 0)
							BEGIN
								SET @strErrorMessage = 'Tax Code does not Exists!'
								delete from #tmpLineTax where intImportSDToInvoiceId =  @intImportSDToInvoiceIdTax
								
								IF(@ysnHeader = 1)
								BEGIN
									GOTO LOGHEADERENTRY
								END
								ELSE
								BEGIN
									GOTO LOGDETAILENTRY
								END
				
							END
					    ELSE
							BEGIN
							EXEC [uspARAddInvoiceTaxDetail]
								 @InvoiceDetailId		= @intNewInvoiceDetailId
								,@TaxGroupId			= @intTaxGroupId
								,@TaxCodeId				= @intTaxCodeId
								,@TaxClassId			= @intTaxClassId
								,@Tax					= @dblTotalTax
								,@AdjustedTax			= @dblTotalTax
								,@Notes					= @strItemDescriptionTax
								,@TaxAdjusted		    = 0
								,@TaxExempt				= @ysnTaxExempt
								,@ErrorMessage			= @strErrorMessage OUTPUT

							delete from #tmpLineTax where intImportSDToInvoiceId =  @intImportSDToInvoiceIdTax
							
							IF (ISNULL(@strErrorMessage,'') != '')
							BEGIN
								IF(@ysnHeader = 1)
								BEGIN
									GOTO LOGHEADERENTRY
								END
								ELSE
								BEGIN
									GOTO LOGDETAILENTRY
								END
				
							END
						END

						
					END

				END
			END
		
						
			BEGIN TRY
			    UPDATE tblARInvoiceDetail SET intTaxGroupId = @intTaxGroupId WHERE intInvoiceDetailId = @intNewInvoiceDetailId --WORKAROUND : AR currently dont have way to set tax group id when doing manual insert of tax details.
				EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @intNewInvoiceId, @ForDelete = 0, @UserId = @EntityUserId	
				EXEC uspARReComputeInvoiceAmounts @intNewInvoiceId

				--Contract overfill
				----------------------------------------------------------------------------------------------------------------------------------------
				IF (@ContractOverFillQuantity > 0) 
				BEGIN
				SET @getARPrice = 1
				--EXEC [dbo].[uspARUpdateInvoiceIntegrations] @InvoiceId = @intNewInvoiceId, @ForDelete = 0, @UserId = @EntityUserId	
				--EXEC uspARReComputeInvoiceAmounts @intNewInvoiceId
			
				SET @intContractDetailId = NULL
				SET @ContractAvailableQuantity = NULL
				--Check if there is other available contract to apply.
				SELECT TOP 1 @intContractDetailId	= ARCC.[intContractDetailId]
											,@ContractAvailableQuantity = ARCC.[dblAvailableQty]
											FROM
												[vyuCTCustomerContract] ARCC
											WHERE
												ARCC.[intEntityCustomerId] = @intCustomerEntityId
												AND ARCC.[intItemId] = @intItemId
												AND CAST(@dtmInvoiceDate AS DATE) BETWEEN CAST(ARCC.[dtmStartDate] AS DATE) AND 
																					CAST(ISNULL(ARCC.[dtmEndDate], @dtmInvoiceDate) AS DATE) 
												AND ARCC.[strContractStatus] NOT IN ('Cancelled', 'Unconfirmed', 'Complete')
												AND (ARCC.[dblAvailableQty] > 0) 
											ORDER BY
													dtmStartDate
												,intContractSeq
				--

					IF (NOT @intContractDetailId IS NULL)
					BEGIN
						IF (@ContractOverFillQuantity > @ContractAvailableQuantity )
						BEGIN
							SET @dblQuantity = @ContractAvailableQuantity
							SET @ContractOverFillQuantity = (@ContractOverFillQuantity - @ContractAvailableQuantity )	
						END
						ELSE
						BEGIN
							SET @dblQuantity = @ContractOverFillQuantity
							SET @ContractOverFillQuantity = 0
						END
					END
					ELSE
					BEGIN
						SET @dblQuantity = @ContractOverFillQuantity
						SET @ContractOverFillQuantity = 0
						
					END

					GOTO ADDITEM									
				END							
				----------------------------------------------------------------------------------------------------------------------------------------

				IF((SELECT COUNT(1) FROM #tmpCustomerInvoiceDetail) = 1)
				BEGIN
					-- Insert the succes log to table 	
					INSERT INTO @ResultTableLog (
						strCustomerNumber			
						,strInvoiceNumber			
						,strSiteNumber				
						,dtmDate	
						,intLineItem				
						,strFileName				
						,strStatus
						,ysnSuccessful
						,intInvoiceId 
						,strTransactionType 
				)
				SELECT
						strCustomerNumber = @strCustomerNumber		
						,strInvoiceNumber =	@strNewInvoiceNumber		
						,strSiteNumber = @strSiteNumber				
						,dtmDate = @dtmInvoiceDate
						,intLineItem = 0						
						,strFileName = ''				
						,strStatus = 'Successfully created ' + @strNewInvoiceNumber  +
						-- Tank consumption site
						ISNULL((SELECT  TOP 1 '<br>' + 'Unable to find a tank consumption site for item no. ' + ICI.strItemNo
						FROM
							tblARInvoice ARI
						INNER JOIN tblARInvoiceDetail ARID
							ON ARI.intInvoiceId = ARID.intInvoiceId
						INNER JOIN tblICItem ICI
							ON ARID.intItemId = ICI.intItemId
						WHERE
							ARI.strType = 'Tank Delivery'
							AND ARID.intSiteId IS NULL
							AND ICI.ysnTankRequired = 1
							AND ICI.strType <> 'Comment'
							AND ARI.intInvoiceId =  @intNewInvoiceId),'') + ' ' + @strStatus

						,ysnSuccessful = 1
						,intInvoiceId = @intNewInvoiceId
							,strTransactionType = 'Invoice'
				END
			END TRY
			BEGIN CATCH
				--ROLLBACK TRANSACTION 

				--DELETE FROM #tmpCustomerInvoiceDetail WHERE intImportSDToInvoiceId = @intImportSDToInvoiceId
				INSERT INTO @ResultTableLog ( strCustomerNumber ,strInvoiceNumber ,strSiteNumber ,dtmDate ,intLineItem ,strFileName ,strStatus ,ysnSuccessful ,intInvoiceId ,strTransactionType )
						SELECT strCustomerNumber = @strCustomerNumber ,strInvoiceNumber = @strInvoiceNumber ,strSiteNumber = @strSiteNumber ,dtmDate = @dtmInvoiceDate ,intLineItem = @intLineItem ,strFileName = '' ,strStatus = ERROR_MESSAGE() ,ysnSuccessful = 0 ,intInvoiceId = @intNewInvoiceId ,strTransactionType = 'Invoice'
						GOTO CONTINUELOOP
			END CATCH

			--Delete the processed detail list
			DELETE FROM #tmpCustomerInvoiceDetail WHERE intImportSDToInvoiceId = @intImportSDToInvoiceId
			
			SET @ysnHeader = 0
		END

		COMMIT TRANSACTION
	
		CONTINUELOOP:

		--Delete processed record
		DELETE FROM #tmpUniqueInvoiceList 
		WHERE strCustomerNumber = @strCustomerNumber 
			AND strInvoiceNumber = @strInvoiceNumber
			AND dtmDate = @dtmInvoiceDate 

	END
			
	SELECT * FROM @ResultTableLog

END
GO