
CREATE PROCEDURE [dbo].[uspETTranslateSDToInvoice]
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
	DECLARE @intImportSDToInvoiceId					INT
	DECLARE @ysnHeader								BIT
	DECLARE @intNewInvoiceDetailId					INT
	DECLARE @strNewInvoiceNumber					NVARCHAR(25)
	
	DECLARE @ResultTableLog TABLE(
		strCustomerNumber			NVARCHAR(100)
		,strInvoiceNumber			NVARCHAR(25)
		,strSiteNumber				NVARCHAR(5)
		,dtmDate					DATETIME
		,intLineItem				INT
		,strFileName				NVARCHAR(300)
		,strStatus					NVARCHAR(MAX)
		,ysnSuccessful				BIT
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

		SET @ysnHeader = 1

		--Loop through the details 
		WHILE EXISTS(SELECT TOP 1 1 FROM #tmpCustomerInvoiceDetail)
		BEGIN
			SET @strErrorMessage = ''

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
			SET @intTaxGroupId = (SELECT TOP 1 intTaxGroupId FROM tblSMTaxGroup WHERE strTaxGroup = @strSalesTaxId)

			--get Item Unit Measure Id = ()
			SET @intUnitMeasureId = (SELECT TOP 1 intUnitMeasureId FROM tblICUnitMeasure WHERE strSymbol = @strUOM)

			---Get Uom ID
			SET	@intItemUOMId = (SELECT TOP 1 intItemUOMId FROM tblICItemUOM WHERE intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)

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
					,@InvoiceOriginId		   = @strInvoiceNumber
					,@ItemDescription		   = @strItemDescription
					,@ItemUOMId				   = @intItemUOMId

				--GEt the created invoice number
				SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 

				--Check if any error in creating invoice 
				--Log Entry
				LOGHEADERENTRY:
				IF 	LTRIM(@strErrorMessage) != ''
				BEGIN		
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

					--Proceed to next customer invoice list if header insertion failed
					GOTO CONTINUELOOP
				END
				ELSE
				BEGIN
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
					)
					SELECT
							strCustomerNumber = @strCustomerNumber		
							,strInvoiceNumber =	@strInvoiceNumber		
							,strSiteNumber = @strSiteNumber				
							,dtmDate = @dtmInvoiceDate					
							,intLineItem = @intLineItem		
							,strFileName = ''				
							,strStatus = 'Successfully created ' + @strNewInvoiceNumber
							,ysnSuccessful = 1
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
						,@ItemTaxGroupId		   = @intTaxGroupId	
						,@ItemDescription		   = @strItemDescription
						,@ItemUOMId				   = @intItemUOMId

				LOGDETAILENTRY:
				IF 	LTRIM(@strErrorMessage) != ''
				BEGIN		
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
					)
					SELECT
							strCustomerNumber = strCustomerNumber		
							,strInvoiceNumber =	strInvoiceNumber		
							,strSiteNumber = strSiteNumber				
							,dtmDate = dtmDate					
							,intLineItem = intLineItem		
							,strFileName = ''				
							,strStatus = @strErrorMessage
							,ysnSuccessful = 0
					FROM #tmpCustomerInvoiceDetail
				END
				ELSE
				BEGIN
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
				END
			END
			

			--Delete the processed detail list
			DELETE FROM #tmpCustomerInvoiceDetail WHERE intImportSDToInvoiceId = @intImportSDToInvoiceId
			SET @ysnHeader = 0
		END

		--Delete processed record
		CONTINUELOOP:
		DELETE FROM #tmpUniqueInvoiceList 
		WHERE strCustomerNumber = @strCustomerNumber 
			AND strInvoiceNumber = @strInvoiceNumber
			AND dtmDate = @dtmInvoiceDate 
	END

	SELECT * FROM @ResultTableLog
END
GO