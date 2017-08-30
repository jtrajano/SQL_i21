﻿CREATE PROCEDURE [dbo].[uspETImportBaseEngineeringToInvoice]
	@EntityUserId			INT
	,@strDateSession        NVARCHAR(25) = NULL
	,@strAllErrorMessage	NVARCHAR(MAX) = '' OUTPUT	
AS
BEGIN

--DEBUG
--DECLARE @EntityUserId INT
--SET @EntityUserId = 1
--DECLARE  @strDateSession NVARCHAR(25) = NULL 
--set @strDateSession  = '2017-08-01 11:46:16.237'

--DECLARE @strAllErrorMessage NVARCHAR(MAX)
--set @strAllErrorMessage = '' 
--

	DECLARE @intImportBaseEngineeringId INT 
	DECLARE @intRecordId INT 
    DECLARE @strCustomerNumber NVARCHAR(100) 
    DECLARE @strSiteNumber NVARCHAR(5) 
	DECLARE @dblPercentFullAfterDelivery NUMERIC(18, 6) 
	DECLARE @strLocation NVARCHAR(50) 
	DECLARE @strItemNumber NVARCHAR(50) 
    DECLARE @dtmDate DATETIME 
	DECLARE @intTaxGroupId INT 
	DECLARE @dblQuantity NUMERIC(18, 6) 
	DECLARE @dblPrice NUMERIC(18, 6) 
	DECLARE @strOriginInvoiceNumber NVARCHAR(50) 
	DECLARE @dblPrebuyPrice NUMERIC(18, 6)
    DECLARE @dblPrebuyQuantity NUMERIC(18, 6)
    DECLARE @dblContractPrice NUMERIC(18, 6)
    DECLARE @dblContractQuantity NUMERIC(18, 6)
	DECLARE @intRecordType INT
	

	DECLARE @intCustomerEntityId					INT
	DECLARE @intLocationId							INT
	DECLARE @intNewInvoiceId						INT
	DECLARE @intItemId								INT
	DECLARE @intSiteId								INT
	DECLARE @strErrorMessage						NVARCHAR(MAX) 
	DECLARE @strTransactionType						NVARCHAR(25)
	DECLARE @strSiteBillingBy						NVARCHAR(10)
	DECLARE @intNewInvoiceDetailId					INT
	DECLARE @strNewInvoiceNumber					NVARCHAR(25)
	DECLARE @dblNonContractQuantity					NUMERIC(18, 6)
	DECLARE @intContractDetailId					INT

	--DECLARE @intSiteTaxId							INT
	DECLARE @intLineItemTaxId						INT
	DECLARE @strStatus								NVARCHAR(50)
	DECLARE @ysnRecomputeTax						BIT
	
	DECLARE @ResultTableLog TABLE(
		strCustomerNumber			NVARCHAR(100)
		,strRecordId				NVARCHAR(25)
		,strSiteNumber				NVARCHAR(5)
		,dtmDate					DATETIME
		,intLineItem				INT
		,strFileName				NVARCHAR(300)
		,strStatus					NVARCHAR(MAX)
		,ysnSuccessful				BIT
		,strInvoiceNumber			NVARCHAR(50)
		,strItemNumber				NVARCHAR(50)
		,intInvoiceId				INT
	)



	SET @strAllErrorMessage = ''

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpBaseToInvoice')) 
	BEGIN
		DROP TABLE #tmpBaseToInvoice
	END

	--IF(@strDateSession IS NULL)
	--BEGIN
	--	SELECT * INTO #tmpBaseToInvoice 
	--	FROM tblETImportBaseEngineering
	--	WHERE ysnProcessed = 0
	--END
	--ELSE
	--BEGIN
	SELECT * INTO #tmpBaseToInvoice 
	FROM tblETImportBaseEngineering
	WHERE ysnProcessed = 0
		AND dtmDateSession = CONVERT(DATETIME,@strDateSession,121)
	--END

	SET @strTransactionType = 'Invoice'
	
	--Loop through the details 
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpBaseToInvoice)
	BEGIN
		SET @strErrorMessage = ''
		SET @intContractDetailId = NULL
		------------------------------------------------------------------------------------------------------------------------------------------------
		SELECT TOP 1 @strOriginInvoiceNumber = strInvoiceNumber FROM #tmpBaseToInvoice ORDER BY intImportBaseEngineeringId ASC

		DECLARE Cursor_LineItems CURSOR LOCAL FAST_FORWARD
		FOR SELECT 
				  intImportBaseEngineeringId
				 ,intRecordId 
				 ,strCustomerNumber
				 ,strSiteNumber
				 ,dblPercentFullAfterDelivery
				 ,strLocation
				 ,strItemNumber
				 ,dtmDate 
				 ,intTaxGroupId 
				 ,dblQuantity
				 ,dblPrice
				 ,strInvoiceNumber
				 ,dblPrebuyPrice
				 ,dblPrebuyQuantity
				 ,dblContractPrice
				 ,dblContractQuantity
				 ,intRecordType
			FROM #tmpBaseToInvoice
			WHERE strInvoiceNumber = @strOriginInvoiceNumber
			ORDER BY intImportBaseEngineeringId ASC

			OPEN Cursor_LineItems

			FETCH NEXT FROM Cursor_LineItems
			INTO @intImportBaseEngineeringId  
				 ,@intRecordId 
				 ,@strCustomerNumber 
				 ,@strSiteNumber 
				 ,@dblPercentFullAfterDelivery 
				 ,@strLocation 
				 ,@strItemNumber 
				 ,@dtmDate 
				 ,@intTaxGroupId 
				 ,@dblQuantity
				 ,@dblPrice
				 ,@strOriginInvoiceNumber
				 ,@dblPrebuyPrice
				 ,@dblPrebuyQuantity 
				 ,@dblContractPrice
				 ,@dblContractQuantity 
				 ,@intRecordType

			SET @strNewInvoiceNumber = ''-- re-initialize invoice number
			--Get Customer Entity Id
			SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)
			--Get Location Id
			SET @intLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @strLocation)
			----------------------------------------------------------------------------------------------------------------------------------------------------------
			WHILE (@@FETCH_STATUS <> - 1)
		    BEGIN
			
			BEGIN TRANSACTION
			
			--Get Item id
			SET @intItemId = (SELECT TOP 1 intItemId FROM tblICItem WHERE strItemNo = @strItemNumber)

		    --Get Site Info
			-- Tax id  Mismatch - IET-99 JAN192017
			SET @intSiteId = NULL
			--SET @intSiteTaxId = NULL
			SET @intLineItemTaxId = NULL

			IF (@intRecordType = 5)
			BEGIN
				SELECT TOP 1 @intSiteId = intSiteID
							,@intLineItemTaxId = intTaxStateID	
							,@strSiteBillingBy = strBillingBy
				FROM tblTMCustomer A
					INNER JOIN tblTMSite B ON A.intCustomerID = B.intCustomerID
				WHERE intCustomerNumber = @intCustomerEntityId AND B.intSiteNumber = CAST(@strSiteNumber AS INT)
			END
			ELSE
				BEGIN
					SELECT @intLineItemTaxId =  dbo.fnGetTaxGroupIdForCustomer(@intCustomerEntityId,@intLocationId,@intItemId,null,null,null)
				END

			---------------------------------------------------------------------------------------------------------------------------------------------------------------------
			IF (ISNULL(@dtmDate,0) = 0) 
			 BEGIN
				SET @strErrorMessage = REPLACE(@strErrorMessage,'.',', ') + 'Invalid Date.'
				END
			IF (ISNULL(@dblPrice,0) = 0) 
 			BEGIN
 			    SET @strErrorMessage = REPLACE(@strErrorMessage,'.',', ') + 'Price must have a value.'
 			END
			IF (ISNULL(@dblQuantity,0) = 0) 
 			BEGIN
 				SET @strErrorMessage = REPLACE(@strErrorMessage,'.',', ') + 'Quantity must have a value.'
 			END
			IF (ISNULL(@intCustomerEntityId,0) = 0)
			BEGIN
				SET @strErrorMessage =  REPLACE(@strErrorMessage,'.',', ') + 'Invalid Customer.'
			END
			IF (ISNULL(@intItemId ,0) = 0)
 			BEGIN
 				SET @strErrorMessage =  REPLACE(@strErrorMessage,'.',', ') + 'Invalid Item.'
 			END

			IF (ISNULL(@intSiteId,0) = 0)
 			BEGIN
				SET @strErrorMessage =  REPLACE(@strErrorMessage,'.',', ') + 'Invalid Site.'
 			END

			IF LTRIM(@strErrorMessage) != ''
			BEGIN		
				GOTO LOGERROR
			END

			IF (@intRecordType = 5 AND ISNULL(@intSiteId,0) = 0)
				BEGIN
					SET @strErrorMessage = 'Invalid Site.'
					GOTO LOGERROR
				END
		
			IF ISNULL(@intTaxGroupId,0) = 0
				BEGIN 
					SET @ysnRecomputeTax = 0
				END
			ELSE
				BEGIN
					SET @ysnRecomputeTax = 1
				END
		
			---Check Contracts
			IF(@dblPrebuyQuantity > 0 OR @dblContractQuantity > 0)
				BEGIN 
				--IF Contract is used
					SET @dblNonContractQuantity = 0
					IF(@dblPrebuyQuantity > 0)
					    BEGIN 
						--GEt Contracts				
						SELECT TOP 1 @intContractDetailId = intContractDetailId FROM vyuETBEContract WHERE intEntityId = @intCustomerEntityId AND intItemId = @intItemId

							---Insert/Create Invoice 
							
							IF (@strNewInvoiceNumber = '')
								BEGIN
								----------------------------------------------------------------------------------------------------------------------------------------
								----Create Invoice with one item BEGIN
								----------------------------------------------------------------------------------------------------------------------------------------
								EXEC [dbo].[uspARCreateCustomerInvoice]
								@EntityCustomerId          = @intCustomerEntityId
								,@InvoiceDate              = @dtmDate
								,@CompanyLocationId        = @intLocationId
								,@EntityId                 = @EntityUserId
								,@NewInvoiceId             = @intNewInvoiceId OUTPUT
								,@ErrorMessage             = @strErrorMessage OUTPUT
								,@ItemId                   = @intItemId
								,@ItemQtyShipped           = @dblPrebuyQuantity
								,@ItemPrice                = @dblPrebuyPrice
								,@ItemSiteId               = @intSiteId
								,@TransactionType	       = @strTransactionType
								,@Type					   = 'Tank Delivery'
								,@ShipDate				   = @dtmDate
								,@ItemPercentFull		   = @dblPercentFullAfterDelivery
								,@ItemTaxGroupId		   = @intTaxGroupId	
								,@RaiseError			   = 1 
								,@UseOriginIdAsInvoiceNumber = 1
								,@InvoiceOriginId         = @strOriginInvoiceNumber
								,@ItemContractDetailId		= @intContractDetailId
								,@RecomputeTax = @ysnRecomputeTax

								--GEt the created invoice number
								SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 
								SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId)

								----Update Tax Details
								EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId, @intImportBaseEngineeringId, @intTaxGroupId
				
								IF 	LTRIM(@strErrorMessage) != ''
								BEGIN		
									--ROLLBACK TRANSACTION
									GOTO LOGERROR
								END
								----------------------------------------------------------------------------------------------------------------------------------------
								----Create Invoice with one item END
								----------------------------------------------------------------------------------------------------------------------------------------
								END
							ELSE
								BEGIN
									---- Add as line Item to Existing Invoice
									EXEC [dbo].[uspARAddInventoryItemToInvoice]
									@InvoiceId = @intNewInvoiceId
									,@NewInvoiceDetailId = @intNewInvoiceDetailId OUTPUT
									,@ErrorMessage = @strErrorMessage OUTPUT
									,@ItemId                   = @intItemId
									,@ItemQtyShipped           = @dblNonContractQuantity
									,@ItemPrice                = @dblPrice
									,@ItemSiteId               = @intSiteId
									,@ItemPercentFull		   = 0
									,@ItemTaxGroupId		   = @intTaxGroupId	
									,@ItemContractDetailId     = @intContractDetailId
									,@RaiseError			   = 1 			
									,@ItemCurrencyExchangeRateTypeId = NULL			
									,@ItemCurrencyExchangeRateId = NULL			
									,@RecomputeTax = @ysnRecomputeTax
									----Update Tax Details
									EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId, @intImportBaseEngineeringId, @intTaxGroupId
				
									IF 	LTRIM(@strErrorMessage) != ''
										BEGIN		
											--ROLLBACK TRANSACTION
											GOTO LOGERROR
										END
								END

							----------------------------------------------------------------------------------------------------------------------------------------
							----Contract overfill
							----------------------------------------------------------------------------------------------------------------------------------------
							SET @dblNonContractQuantity = @dblQuantity - @dblPrebuyQuantity
							IF(@dblNonContractQuantity > 0)
								BEGIN
									---- Add as line Item to Existing Invoice
									EXEC [dbo].[uspARAddInventoryItemToInvoice]
											@InvoiceId = @intNewInvoiceId
											,@NewInvoiceDetailId = @intNewInvoiceDetailId OUTPUT
											,@ErrorMessage = @strErrorMessage OUTPUT
											,@ItemId                   = @intItemId
											,@ItemQtyShipped           = @dblNonContractQuantity
											,@ItemPrice                = @dblPrice
											,@ItemSiteId               = @intSiteId
											,@ItemPercentFull		   = 0
											,@ItemTaxGroupId		   = @intTaxGroupId	
											,@ItemContractDetailId     = @intContractDetailId
											,@RaiseError			   = 1 			
											,@ItemCurrencyExchangeRateTypeId = NULL			
											,@ItemCurrencyExchangeRateId = NULL			
											,@RecomputeTax = @ysnRecomputeTax
								END
							EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId, @intImportBaseEngineeringId, @intTaxGroupId
							----------------------------------------------------------------------------------------------------------------------------------------
						
						IF 	LTRIM(@strErrorMessage) != ''
							BEGIN		
								--ROLLBACK TRANSACTION
								GOTO LOGERROR
							END

						EXEC uspARReComputeInvoiceAmounts @intNewInvoiceId
						COMMIT TRANSACTION
						GOTO LOGSUCCESS
					END
				    ELSE
						BEGIN 
							SET @strErrorMessage = 'Non-Prebuy contracts are not implemented yet'
							GOTO LOGERROR
						END
			    END
			ELSE
				BEGIN 
			    ---Insert/Create Invoice 
				IF (@strNewInvoiceNumber = '')
					BEGIN
						EXEC [dbo].[uspARCreateCustomerInvoice]
						@EntityCustomerId          = @intCustomerEntityId
						,@InvoiceDate              = @dtmDate
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
						,@ShipDate				   = @dtmDate
						,@ItemPercentFull		   = @dblPercentFullAfterDelivery
						,@ItemTaxGroupId		   = @intTaxGroupId	
						,@RaiseError			   = 1 
						,@UseOriginIdAsInvoiceNumber = 1
						,@InvoiceOriginId         = @strOriginInvoiceNumber
						,@RecomputeTax = @ysnRecomputeTax
						IF 	LTRIM(@strErrorMessage) != ''
						BEGIN 
							--ROLLBACK TRANSACTION
							GOTO LOGERROR
						END

						--GEt the created invoice number
						SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 
						SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId)
					END
					
				ELSE
				----------------------------------------------------------------------------------------------------------------------------------------
				----Add other item
				----------------------------------------------------------------------------------------------------------------------------------------
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
							,@ItemPercentFull		   = 0
							,@ItemTaxGroupId		   = @intTaxGroupId	
							,@ItemContractDetailId     = @intContractDetailId
							,@RaiseError			   = 1 			
							,@ItemCurrencyExchangeRateTypeId = NULL			
							,@ItemCurrencyExchangeRateId = NULL			
							,@RecomputeTax = @ysnRecomputeTax
						IF 	LTRIM(@strErrorMessage) != ''
						BEGIN		
							--ROLLBACK TRANSACTION
							GOTO LOGERROR
						END
					END
				----------------------------------------------------------------------------------------------------------------------------------------
				----Add other item
				----------------------------------------------------------------------------------------------------------------------------------------
				
				----Update Tax Details
				EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId, @intImportBaseEngineeringId, @intTaxGroupId
				
                END

			

		--Check if any error in creating invoice 
		--Log Entry
			IF 	LTRIM(@strErrorMessage) != ''
						BEGIN 
							GOTO LOGERROR
						END
					ELSE
						BEGIN 
							----Update Tax Details
							EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId, @intImportBaseEngineeringId, @intTaxGroupId
							EXEC uspARReComputeInvoiceAmounts @intNewInvoiceId
							COMMIT TRANSACTION

							LOGSUCCESS:
							--NOTE: @intSiteTaxId is the current site setup 
							--NOTE: @intTaxGroupId is the tax from the file
							--DO NOT Recompute Tax when intTaxGroupId  is NULL
							IF ISNULL(@intLineItemTaxId,0) <> ISNULL(@intTaxGroupId,0)
								BEGIN
									SET @strStatus = 'Tax Mismatch'
								END
							Else
								BEGIN
									SET @strStatus = 'Created'
								END
		
							INSERT INTO @ResultTableLog (strCustomerNumber ,strRecordId	,strSiteNumber	,dtmDate ,intLineItem ,strFileName ,strStatus ,ysnSuccessful ,strInvoiceNumber ,strItemNumber ,intInvoiceId)
							SELECT strCustomerNumber = @strCustomerNumber ,strRecordId = CAST(@intRecordId AS NVARCHAR(15))	,strSiteNumber = @strSiteNumber ,dtmDate = @dtmDate		,intLineItem = @intRecordId ,strFileName = '' ,strStatus = @strStatus ,ysnSuccessful = 1,strInvoiceNumber = @strNewInvoiceNumber,strItemNumber = @strItemNumber ,intInvoiceId = @intNewInvoiceId

							--GOTO CONTINUELOOP
						END

			FETCH NEXT FROM Cursor_LineItems 
			INTO @intImportBaseEngineeringId  
					,@intRecordId 
					,@strCustomerNumber 
					,@strSiteNumber 
					,@dblPercentFullAfterDelivery 
					,@strLocation 
					,@strItemNumber 
					,@dtmDate 
					,@intTaxGroupId 
					,@dblQuantity
					,@dblPrice
					,@strOriginInvoiceNumber
					,@dblPrebuyPrice
					,@dblPrebuyQuantity 
					,@dblContractPrice
					,@dblContractQuantity 
					,@intRecordType						
		END
		------------------------------------------------------------------------------------------------------------------------------------------------

		GOTO CONTINUELOOP
		
		LOGERROR:		 
		INSERT INTO @ResultTableLog (
				strCustomerNumber			
				,strRecordId			
				,strSiteNumber				
				,dtmDate					
				,intLineItem				
				,strFileName				
				,strStatus
				,ysnSuccessful
				,strInvoiceNumber 
				,strItemNumber 
		)
		SELECT
				strCustomerNumber = @strCustomerNumber		
				,strRecordId =	CAST(@intRecordId AS NVARCHAR(15))	
				,strSiteNumber = @strSiteNumber				
				,dtmDate = @dtmDate					
				,intLineItem = @intRecordId		
				,strFileName = ''				
				,strStatus = @strErrorMessage
				,ysnSuccessful = 0
				,strInvoiceNumber = ''
				,strItemNumber = @strItemNumber
		ROLLBACK TRANSACTION
					
		GOTO CONTINUELOOP
		CONTINUELOOP:
		DELETE FROM #tmpBaseToInvoice WHERE strInvoiceNumber = @strOriginInvoiceNumber
		UPDATE tblETImportBaseEngineering
		SET ysnProcessed = 1 WHERE strInvoiceNumber = @strOriginInvoiceNumber
		CLOSE Cursor_LineItems
		DEALLOCATE Cursor_LineItems
	END

	SELECT * FROM @ResultTableLog

END
GO