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


			GOTO CONTINUELOOP
		END

		----Update Tax Details
		SELECT TOP 1 
			@intTaxCategory1	=   category01
			,@intTaxCategory2	=   category02
			,@intTaxCategory3	=   category03
			,@intTaxCategory4	=   category04
			,@intTaxCategory5	=   category05
			,@intTaxCategory6	=   category06
			,@intTaxCategory7	=   category07
			,@intTaxCategory8	=   category08
			,@intTaxCategory9	=   category09
			,@intTaxCategory10	=  category10
			,@intTaxCategory11	=  category11
			,@intTaxCategory12	=  category12
			,@intTaxCategory13	=  category13
			,@intTaxCategory14	=  category14
			,@intTaxCategory15	=  category15
			,@intTaxCategory16	=  category16
			,@intTaxCategory17	=  category17
			,@intTaxCategory18	=  category18
			,@intTaxCategory19	=  category19
			,@intTaxCategory20	=  category20
			,@intTaxCategory21	=  category21
			,@intTaxCategory22	=  category22
			,@intTaxCategory23	=  category23
			,@intTaxCategory24	=  category24
			,@intTaxCategory25	=  category25
			,@intTaxCategory26	=  category26
			,@intTaxCategory27	=  category27
			,@intTaxCategory28	=  category28
			,@intTaxCategory29	=  category29
			,@intTaxCategory30	=  category30
		FROM vyuSMBEExportTax

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory1
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory1,0)
			AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory2
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory2,0)
			AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory3
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory3,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory4
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory4,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory5
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory5,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory6
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory6,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory7
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory7,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory8
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory8,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory9
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory9,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory10
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory10,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory11
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory11,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory12
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory12,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory13
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory13,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory14
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory14,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory15
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory15,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory16
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory16,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory17
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory17,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory18
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory18,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory19
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory19,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory20
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory20,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory21
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory21,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory22
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory22,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory23
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory23,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory24
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory24,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory25
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory25,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory26
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory26,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory27
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory27,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory28
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory28,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory29
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory29,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		UPDATE tblARInvoiceDetailTax
		SET dblAdjustedTax = @dblTaxCategory30
			,ysnTaxAdjusted = 1
		WHERE intTaxCodeId = ISNULL(@intTaxCategory30,0)
		AND intInvoiceDetailId = @intNewInvoiceDetailId

		EXEC uspARReComputeInvoiceAmounts @intNewInvoiceId

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