CREATE PROCEDURE [dbo].[uspETTranslateRPToRecievePayment]
	@StagingTable ETTranslateSDToInvoiceTable READONLY
	,@EntityUserId			INT
	,@strAllErrorMessage	NVARCHAR(MAX) = '' OUTPUT	
	
AS
BEGIN

	DECLARE @strCustomerNumber						NVARCHAR(100)
	DECLARE @strPaymentNumber						NVARCHAR(25)
	DECLARE @dtmPaymentDate							DATETIME
	DECLARE	@dblPaymentAmount						NUMERIC(18, 6)
	DECLARE @strCheckNumOrDesc						NVARCHAR(25)
	DECLARE @strRecordType							NVARCHAR(2)
	DECLARE	@strLocation							NVARCHAR(50)
	DECLARE @strPaymentType							NVARCHAR(25)
	
	DECLARE @intCntIdUniqueInvoiceCustomerDate		INT
	DECLARE @strErrorMessage						NVARCHAR(MAX) 
	DECLARE @ysnHeader								BIT

	DECLARE @intCustomerEntityId					INT
	DECLARE @intLocationId							INT
	DECLARE @intNewPaymentId						INT
	DECLARE @strNewPaymentNumber					NVARCHAR(25)

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
	)

	SET @strAllErrorMessage = ''

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpSDToInvoice')) 
	BEGIN
		DROP TABLE #tmpSDToInvoice
	END
	SELECT * INTO #tmpSDToInvoice 
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
			,@strPaymentNumber = strInvoiceNumber
			,@dtmPaymentDate = dtmDate
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
			AND strInvoiceNumber = @dtmPaymentDate
			AND dtmDate = @dtmPaymentDate
			AND strDetailType = 'D'

		IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpCustomerInvoiceTaxDetail')) 
		BEGIN
			DROP TABLE #tmpCustomerInvoiceTaxDetail
		END

		SELECT *
		INTO #tmpCustomerInvoiceTaxDetail
		FROM  #tmpSDToInvoice
		WHERE strCustomerNumber = @strCustomerNumber
			AND strInvoiceNumber = @dtmPaymentDate
			AND dtmDate = @dtmPaymentDate
			
		BEGIN TRANSACTION
		--Loop through the details 
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomerInvoiceDetail)
		BEGIN
			SET @strErrorMessage = ''
			--SET @ysnProcessNextAsHeader = 0
			--Get the first Record and create Invoice
			SELECT TOP 1 
				@strCustomerNumber	 = strCustomerNumber
				,@strPaymentNumber		  = strPaymentNumber
				,@dtmPaymentDate		  = dtmDate
				--@dblPaymentAmount	= strLocation
				--@strCheckNumOrDesc	
				--@strRecordType		
				--@strLocation		
				--@strPaymentType		
			FROM #tmpCustomerInvoiceDetail
			ORDER BY intLineItem ASC

			--Get Customer Entity Id
			SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)
			--Get Location Id
			SET @intLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @strLocation)
		
			---Insert/Create Payment Header 
			IF(@ysnHeader = 1)
			BEGIN
				
				EXEC [uspARCreateCustomerPayment]
					--@EntityCustomerId          = @intCustomerEntityId
					--,@InvoiceDate              = @dtmInvoiceDate
					--,@CompanyLocationId        = @intLocationId
					--,@EntityId                 = @EntityUserId
					--,@NewInvoiceId             = @intNewInvoiceId OUTPUT
					--,@ErrorMessage             = @strErrorMessage OUTPUT
					--,@ItemId                   = @intItemId
					--,@ItemQtyShipped           = @dblQuantity
					--,@ItemPrice                = @dblPrice
					--,@ItemSiteId               = @intSiteId
					--,@TransactionType	       = @strTransactionType
					--,@Type					   = 'Tank Delivery'
					--,@TermId				   = @intTermCode
					--,@ShipDate				   = @dtmInvoiceDate
					--,@EntitySalespersonId	   = @intDriverEntityId		
					--,@Comment				   = @strComment	
					--,@ItemPercentFull		   = @dblPercentFullAfterDelivery
					--,@ItemTaxGroupId		   = @intTaxGroupId	
					--,@ItemDescription		   = @strItemDescription
					--,@ItemUOMId				   = @intItemUOMId
					--,@BOLNumber				   = @strInvoiceNumber
					--,@ItemContractDetailId     = @intContractDetailId
					--,@RaiseError			   = 0
					--,@UseOriginIdAsInvoiceNumber = 1
					--,@InvoiceOriginId         = @strInvoiceNumber

				--GEt the created invoice number
				SET @strNewPaymentNumber = (SELECT TOP 1 strRecordNumber FROM tblARPayment WHERE intPaymentId  = @intNewPaymentId) 
				--SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARPaymentDetail WHERE intPaymentId = @intNewPaymentId)
			
				
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
					)
					SELECT
							strCustomerNumber = @strCustomerNumber		
							,strInvoiceNumber =	@strPaymentNumber
							,strSiteNumber = ''		
							,dtmDate = @dtmPaymentDate					
							,intLineItem = 0--@intLineItem		
							,strFileName = ''				
							,strStatus = @strErrorMessage
							,ysnSuccessful = 0
							,intInvoiceId = @intNewPaymentId--@intNewInvoiceId
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
				)
				SELECT
						strCustomerNumber = @strCustomerNumber		
						,strInvoiceNumber =	@strNewPaymentNumber		
						,strSiteNumber = 0
						,dtmDate = @dtmPaymentDate
						,intLineItem = 0						
						,strFileName = ''				
						,strStatus = 'Successfully created ' + @strNewPaymentNumber
						,ysnSuccessful = 1
						,intInvoiceId = @intNewPaymentId
			END

			--Delete the processed detail list
			--DELETE FROM #tmpCustomerInvoiceDetail WHERE intImportSDToInvoiceId = @intImportSDToInvoiceId
			
			
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
			AND strInvoiceNumber = @strNewPaymentNumber
			AND dtmDate = @dtmPaymentDate 
	END

	SELECT * FROM @ResultTableLog
END
GO