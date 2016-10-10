CREATE PROCEDURE [dbo].[uspETImportBaseEngineeringToInvoice]
	@EntityUserId			INT
	,@strDateSession        NVARCHAR(25) = NULL
	,@strAllErrorMessage	NVARCHAR(MAX) = '' OUTPUT	
AS
BEGIN

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
	DECLARE @dblTaxCategory1 NUMERIC(18, 6) 
	DECLARE @dblTaxCategory2 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory3 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory4 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory5 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory6 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory7 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory8 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory9 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory10 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory11 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory12 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory13 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory14 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory15 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory16 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory17 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory18 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory19 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory20 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory21 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory22 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory23 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory24 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory25 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory26 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory27 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory28 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory29 NUMERIC(18, 6)  
	DECLARE @dblTaxCategory30 NUMERIC(18, 6)
	DECLARE @strOriginInvoiceNumber NVARCHAR(50) 
	DECLARE @dblPrebuyPrice NUMERIC(18, 6)
    DECLARE @dblPrebuyQuantity NUMERIC(18, 6)
    DECLARE @dblContractPrice NUMERIC(18, 6)
    DECLARE @dblContractQuantity NUMERIC(18, 6)

	DECLARE @intTaxCategory1 INT 
	DECLARE @intTaxCategory2 INT
	DECLARE @intTaxCategory3 INT
	DECLARE @intTaxCategory4 INT
	DECLARE @intTaxCategory5 INT
	DECLARE @intTaxCategory6 INT
	DECLARE @intTaxCategory7 INT
	DECLARE @intTaxCategory8 INT
	DECLARE @intTaxCategory9 INT
	DECLARE @intTaxCategory10 INT
	DECLARE @intTaxCategory11 INT
	DECLARE @intTaxCategory12 INT
	DECLARE @intTaxCategory13 INT
	DECLARE @intTaxCategory14 INT
	DECLARE @intTaxCategory15 INT
	DECLARE @intTaxCategory16 INT
	DECLARE @intTaxCategory17 INT
	DECLARE @intTaxCategory18 INT
	DECLARE @intTaxCategory19 INT
	DECLARE @intTaxCategory20 INT
	DECLARE @intTaxCategory21 INT
	DECLARE @intTaxCategory22 INT
	DECLARE @intTaxCategory23 INT
	DECLARE @intTaxCategory24 INT
	DECLARE @intTaxCategory25 INT
	DECLARE @intTaxCategory26 INT
	DECLARE @intTaxCategory27 INT
	DECLARE @intTaxCategory28 INT
	DECLARE @intTaxCategory29 INT
	DECLARE @intTaxCategory30 INT  

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
		--SET @ysnProcessNextAsHeader = 0
		--Get the first Record and create Invoice
		SELECT TOP 1 
			 @intImportBaseEngineeringId  = intImportBaseEngineeringId
			 ,@intRecordId = intRecordId 
			 ,@strCustomerNumber = strCustomerNumber
			 ,@strSiteNumber = strSiteNumber
			 ,@dblPercentFullAfterDelivery = dblPercentFullAfterDelivery
			 ,@strLocation = strLocation
			 ,@strItemNumber = strItemNumber
			 ,@dtmDate = dtmDate 
			 ,@intTaxGroupId = intTaxGroupId 
			 ,@dblQuantity = dblQuantity
			 ,@dblPrice = dblPrice
			 ,@dblTaxCategory1 = dblTaxCategory1
			 ,@dblTaxCategory2 = dblTaxCategory2
			 ,@dblTaxCategory3 = dblTaxCategory3
			 ,@dblTaxCategory4 = dblTaxCategory4
			 ,@dblTaxCategory5 = dblTaxCategory5
			 ,@dblTaxCategory6 = dblTaxCategory6
			 ,@dblTaxCategory7 = dblTaxCategory7  
			 ,@dblTaxCategory8 = dblTaxCategory8  
			 ,@dblTaxCategory9 = dblTaxCategory9  
			 ,@dblTaxCategory10 = dblTaxCategory10  
			 ,@dblTaxCategory11 = dblTaxCategory11  
			 ,@dblTaxCategory12 = dblTaxCategory12  
			 ,@dblTaxCategory13 = dblTaxCategory13  
			 ,@dblTaxCategory14 = dblTaxCategory14  
			 ,@dblTaxCategory15 = dblTaxCategory15  
			 ,@dblTaxCategory16 = dblTaxCategory16  
			 ,@dblTaxCategory17 = dblTaxCategory17  
			 ,@dblTaxCategory18 = dblTaxCategory18  
			 ,@dblTaxCategory19 = dblTaxCategory19  
			 ,@dblTaxCategory20 = dblTaxCategory20  
			 ,@dblTaxCategory21 = dblTaxCategory21  
			 ,@dblTaxCategory22 = dblTaxCategory22  
			 ,@dblTaxCategory23 = dblTaxCategory23  
			 ,@dblTaxCategory24 = dblTaxCategory24  
			 ,@dblTaxCategory25 = dblTaxCategory25  
			 ,@dblTaxCategory26 = dblTaxCategory26  
			 ,@dblTaxCategory27 = dblTaxCategory27  
			 ,@dblTaxCategory28 = dblTaxCategory28  
			 ,@dblTaxCategory29 = dblTaxCategory29  
			 ,@dblTaxCategory30 = dblTaxCategory30 
			 ,@strOriginInvoiceNumber = strInvoiceNumber
			 ,@dblPrebuyPrice = dblPrebuyPrice
			 ,@dblPrebuyQuantity = dblPrebuyQuantity
			 ,@dblContractPrice = dblContractPrice
			 ,@dblContractQuantity = dblContractQuantity
		FROM #tmpBaseToInvoice
		ORDER BY intImportBaseEngineeringId ASC
			 
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
			GOTO LOGERROR
		END

		--Get other Site Info
		SELECT TOP 1
			@strSiteBillingBy = strBillingBy
		FROM tblTMSite
		WHERE intSiteID = @intSiteId

		---Check Contracts
		IF(@dblPrebuyQuantity > 0 OR @dblContractQuantity > 0)
		BEGIN
			--IF Contract is used
			SET @dblNonContractQuantity = 0
			IF(@dblPrebuyQuantity > 0)
			BEGIN
				SET @dblNonContractQuantity = @dblQuantity - @dblPrebuyQuantity

				--GEt Contracts				
				SELECT TOP 1 @intContractDetailId = intContractDetailId 
				FROM vyuETBEContract
				WHERE intEntityId = @intCustomerEntityId
					AND intItemId = @intItemId

				
				---Insert/Create Invoice 
				BEGIN TRANSACTION
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


				--GEt the created invoice number
				SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 
				SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId)


				----Update Tax Details
				EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId
				
				IF 	LTRIM(@strErrorMessage) != ''
				BEGIN		
					ROLLBACK TRANSACTION
					GOTO LOGERROR
				END

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
							,@RecomputeTax			   = 0
							,@RaiseError			   = 1 
				END
				IF 	LTRIM(@strErrorMessage) != ''
				BEGIN		
					ROLLBACK TRANSACTION
					GOTO LOGERROR
				END

				----Update Tax Details
				EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId

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
		END
		--GEt the created invoice number
		SET @strNewInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId = @intNewInvoiceId) 
		SET @intNewInvoiceDetailId = (SELECT TOP 1 intInvoiceDetailId FROM tblARInvoiceDetail WHERE intInvoiceId = @intNewInvoiceId)

		--Check if any error in creating invoice 
		--Log Entry
		IF 	LTRIM(@strErrorMessage) != ''
		BEGIN		
			GOTO LOGERROR
		END
		ELSE
		BEGIN
			LOGSUCCESS:
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
				,intInvoiceId
			)
			SELECT
					strCustomerNumber = @strCustomerNumber		
					,strRecordId =	CAST(@intRecordId AS NVARCHAR(15))	
					,strSiteNumber = @strSiteNumber				
					,dtmDate = @dtmDate					
					,intLineItem = @intRecordId		
					,strFileName = ''				
					,strStatus = 'Created ' + @strNewInvoiceNumber
					,ysnSuccessful = 1
					,strInvoiceNumber = @strNewInvoiceNumber
					,strItemNumber = @strItemNumber
					,intInvoiceId = @intNewInvoiceId

			
			----Update Tax Details
			EXEC uspETImportUpdateInvoiceDetailTaxById @intNewInvoiceDetailId
			EXEC uspARReComputeInvoiceAmounts @intNewInvoiceId

			GOTO CONTINUELOOP
		END

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
					
		GOTO CONTINUELOOP
		CONTINUELOOP:
		DELETE FROM #tmpBaseToInvoice WHERE intImportBaseEngineeringId = @intImportBaseEngineeringId
		UPDATE tblETImportBaseEngineering
		SET ysnProcessed = 1 WHERE intImportBaseEngineeringId = @intImportBaseEngineeringId
	END

	SELECT * FROM @ResultTableLog
END
GO