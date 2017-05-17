
CREATE PROCEDURE [uspETTranslateSDToInvoice]
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
	DECLARE @intTaxClassId							INT
	
	
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
		,strRecordId                NVARCHAR(5)
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

		BEGIN TRANSACTION
		SET @ysnHeader = 1
		--Loop through the details 
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomerInvoiceDetail)
		BEGIN
			SET @strErrorMessage = ''
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
			FROM #tmpCustomerInvoiceDetail
			ORDER BY intLineItem ASC

			--Get Customer Entity Id
			SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)
	
			--Get Location Id
			SET @intLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @strLocation)

			--Get Item id
			SET @intItemId = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = @strItemNumber)

			--Get Site Id 
			SET @intSiteId = ( 
				SELECT TOP 1 intSiteID
				FROM tblTMCustomer A
				INNER JOIN tblTMSite B
					ON A.intCustomerID = B.intCustomerID
				WHERE intCustomerNumber = @intCustomerEntityId
					AND B.intSiteNumber = CAST(@strSiteNumber AS INT)
			)

			IF (ISNULL(@intSiteId,0) = 0)
			BEGIN
				SET @strErrorMessage = 'Invalid Site.'
				IF(@ysnHeader = 1)
				BEGIN
					GOTO LOGHEADERENTRY
				END
				ELSE
				BEGIN
					GOTO LOGDETAILENTRY
				END
				
			END

			--Get other Site Info
			SELECT TOP 1
				@strSiteBillingBy = strBillingBy
			FROM tblTMSite
			WHERE intSiteID = @intSiteId

			---Set TransactionType
			SET @strTransactionType = (SELECT (CASE	WHEN @strType = 'B' THEN 'Invoice'
													WHEN @strType = 'A' THEN 'Cash'
													ELSE
														'Invoice'
												END))

			--Get Term Code
			SET @intTermCode = (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTermCode = @strTermCode)

			--Get Entity ID of the Driver
			SET @intDriverEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strDriverNumber)

			---GEt Tax Group Id
			SET @intTaxGroupId = (SELECT TOP 1 B.intTaxGroupId 
									FROM tblSMTaxCode A
									INNER JOIN  tblSMTaxGroupCode B
										ON A.intTaxCodeId = B.intTaxCodeId
									WHERE A.strTaxCode = @strSalesTaxId)

			--get Item Unit Measure Id = ()
			SET @intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol = @strUOM)

			---Get Uom ID
			SET	@intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)

			--Get contract ID
			SET @intContractDetailId = (SELECT TOP 1 B.intContractDetailId 
											FROM tblCTContractHeader A
											INNER JOIN tblCTContractDetail B
												ON A.intContractHeaderId = B.intContractHeaderId
											WHERE A.strContractNumber = @strContractNumber
											AND A.intEntityId = @intCustomerEntityId
											AND B.intContractSeq = @intContractSequence)

			---Insert/Create Invoice 
			IF(@ysnHeader = 1)
			BEGIN
				
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
					,@EntitySalespersonId	   = @intDriverEntityId		
					,@Comment				   = @strComment	
					,@ItemPercentFull		   = @dblPercentFullAfterDelivery
					,@ItemTaxGroupId		   = @intTaxGroupId	
					,@ItemDescription		   = @strItemDescription
					,@ItemUOMId				   = @intItemUOMId
					,@BOLNumber				   = @strInvoiceNumber
					,@ItemContractDetailId     = @intContractDetailId
					,@RaiseError			   = 0
					,@UseOriginIdAsInvoiceNumber = 1
					,@InvoiceOriginId         = @strInvoiceNumber

				--GEt the created invoice number
				SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 
				SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId)

				--Check if any error in creating invoice 
				--Log Entry
				LOGHEADERENTRY:
				IF 	LTRIM(@strErrorMessage) != ''
				BEGIN		
					ROLLBACK TRANSACTION
					
					-- Insert the header to log table 	
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
							,strRecordId       
							,strTransactionType	
					)
					SELECT
							strCustomerNumber = @strCustomerNumber		
							,strInvoiceNumber =	@strInvoiceNumber		
							,strSiteNumber = @strSiteNumber				
							,dtmDate = @dtmInvoiceDate					
							,intLineItem = @intLineItem		
							,strFileName = ''				
							,strStatus = @strErrorMessage
							,ysnSuccessful = 0
							,intInvoiceId = @intNewInvoiceId
							,strRecordId  = @intNewInvoiceId     
							,strTransactionType = 'Invoice'
					
					GOTO CONTINUELOOP

					/*
					--Proceed to next customer invoice list if header insertion failed and not a skipped tax record 
					IF(@ysnProcessNextAsHeader = 0)
					BEGIN
						--Delete the Header record from the detail table
						DELETE FROM #tmpCustomerInvoiceDetail WHERE intImportSDToInvoiceId = @intImportSDToInvoiceId

						---insert the remaining details to the log table
						INSERT INTO @ResultTableLog (
								strCustomerNumber			
								,strInvoiceNumber			
								,strSiteNumber				
								,dtmDate					
								,intLineItem				
								,strFileName				
								,strStatus
								,ysnSuccessful
						)
						SELECT
								strCustomerNumber = strCustomerNumber		
								,strInvoiceNumber =	strInvoiceNumber		
								,strSiteNumber = strSiteNumber				
								,dtmDate = dtmDate					
								,intLineItem = intLineItem		
								,strFileName = ''				
								,strStatus = 'Header Record not Created'
								,ysnSuccessful = 0
						FROM #tmpCustomerInvoiceDetail
						
					
						GOTO CONTINUELOOP
					END */
				END
			END
			ELSE
			BEGIN
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
						--,@ItemTaxGroupId		   = @intTaxGroupId	
						,@ItemDescription		   = @strItemDescription
						,@ItemUOMId				   = @intItemUOMId
						,@ItemContractDetailId     = @intContractDetailId
						,@ItemCurrencyExchangeRateTypeId = NULL            
                        ,@ItemCurrencyExchangeRateId = NULL            
						,@RecomputeTax			   = 0

				LOGDETAILENTRY:
				IF 	LTRIM(@strErrorMessage) != ''
				BEGIN		
					ROLLBACK TRANSACTION
					

					---insert log table
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
							,strRecordId 
							,strTransactionType

					)
					SELECT
							strCustomerNumber = @strCustomerNumber		
							,strInvoiceNumber =	@strInvoiceNumber		
							,strSiteNumber = @strSiteNumber				
							,dtmDate = @dtmInvoiceDate					
							,intLineItem = @intLineItem		
							,strFileName = ''				
							,strStatus = @strErrorMessage
							,ysnSuccessful = 0
							,intInvoiceId = @intNewInvoiceId
							,strRecordId  = @intNewInvoiceId     
							,strTransactionType = 'Invoice'
					GOTO CONTINUELOOP
				END
				/*
				ELSE
				BEGIN
					-- Insert the detail to log table 	
					INSERT INTO @ResultTableLog (
							strCustomerNumber			
							,strInvoiceNumber			
							,strSiteNumber				
							,dtmDate					
							,intLineItem				
							,strFileName				
							,strStatus
							,ysnSuccessful
					)
					SELECT
							strCustomerNumber = @strCustomerNumber		
							,strInvoiceNumber =	@strInvoiceNumber		
							,strSiteNumber = @strSiteNumber				
							,dtmDate = @dtmInvoiceDate					
							,intLineItem = @intLineItem		
							,strFileName = ''				
							,strStatus = 'Added as line item to ' + @strNewInvoiceNumber
							,ysnSuccessful = 1
				END*/
			END
			
			--CHECK  for taxes
			IF EXISTS(SELECT TOP 1 1 FROM #tmpCustomerInvoiceTaxDetail)
			BEGIN
				--Check for Detail Tax
				IF(@intLineItem <> 0)
				BEGIN
					IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpLineTax')) 
					BEGIN
						DROP TABLE #tmpLineTax
					END

					--Get Tax detail for the line item
					SELECT * 
					INTO #tmpLineTax
					FROM #tmpCustomerInvoiceTaxDetail
					WHERE ((intLineItem / 100) = @intLineItem)

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
						FROM #tmpCustomerInvoiceDetail
						ORDER BY intLineItem ASC
						
						--GetTaxcode detail
						SET @intTaxCodeId = NULL
						SET @intTaxClassId = NULL
						SET @intTaxGroupId = NULL
						
						SELECT TOP 1 
							@intTaxCodeId = intTaxCodeId 
							,@intTaxClassId = intTaxClassId
						FROM tblSMTaxCode 
						WHERE strTaxCode = @strSalesTaxIdTax

						IF (ISNULL(@intSiteId,0) = 0)
						BEGIN
							SET @strErrorMessage = 'Tax Code does not Exists!'
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
								,@AdjustedTax			= @dblQuantityTax
								,@Notes					= @strItemDescriptionTax
								,@TaxAdjusted		    = 1
								,@ErrorMessage			= @strErrorMessage OUTPUT

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

			-- Check if there are more details left
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
						,strRecordId  
							,strTransactionType 
				)
				SELECT
						strCustomerNumber = @strCustomerNumber		
						,strInvoiceNumber =	@strNewInvoiceNumber		
						,strSiteNumber = @strSiteNumber				
						,dtmDate = @dtmInvoiceDate
						,intLineItem = 0						
						,strFileName = ''				
						,strStatus = 'Successfully created ' + @strNewInvoiceNumber
						,ysnSuccessful = 1
						,intInvoiceId = @intNewInvoiceId
						,strRecordId  = @intNewInvoiceId     
							,strTransactionType = 'Invoice'
			END

			--Delete the processed detail list
			DELETE FROM #tmpCustomerInvoiceDetail WHERE intImportSDToInvoiceId = @intImportSDToInvoiceId
			
			
			
			--IF(@ysnProcessNextAsHeader = 0)
			--BEGIN
				SET @ysnHeader = 0
			--END
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