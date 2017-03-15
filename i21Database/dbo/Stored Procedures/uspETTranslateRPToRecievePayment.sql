CREATE PROCEDURE [uspETTranslateRPToRecievePayment]
	@StagingTable ETTranslateRPToReceivePaymentTable READONLY
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
	DECLARE @strPaymentMethod						NVARCHAR(25)
	
	DECLARE @intCntIdUniqueInvoiceCustomerDate		INT
	DECLARE @strErrorMessage						NVARCHAR(MAX) 
	DECLARE @ysnHeader								BIT

	DECLARE @intCustomerEntityId					INT
	DECLARE @intLocationId							INT
	DECLARE @intNewPaymentId						INT
	DECLARE @strNewPaymentNumber					NVARCHAR(25)
	DECLARE @intPaymentMethodId						INT

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
	)

	SET @strAllErrorMessage = ''

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpSDToInvoice')) 
		BEGIN
			DROP TABLE #tmpSDToInvoice
		END
	
	SELECT * INTO #tmpSDToInvoice 
	FROM @StagingTable
	WHERE strRecordType = 'C'

	--SELECT * 	FROM #tmpSDToInvoice tmp--debug

	IF EXISTS (SELECT TOP 1 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#tmpUniqueInvoiceList')) 
		BEGIN
			DROP TABLE #tmpUniqueInvoiceList
		END
	
	--Get the unique list of Customer, Invoice Number and date
	SELECT DISTINCT 
		strCustomerNumber
		,strInvoiceNumber
		,dtmPaymentDate
		,intCntId = ROW_NUMBER() OVER (ORDER BY strCustomerNumber)
	INTO #tmpUniqueInvoiceList
	FROM #tmpSDToInvoice

	---Loop through the unique customer invoice date
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUniqueInvoiceList) 
	BEGIN
		SELECT TOP 1
			@strCustomerNumber = strCustomerNumber
			,@strPaymentNumber = strInvoiceNumber
			,@dtmPaymentDate = dtmPaymentDate
			,@strPaymentMethod = (CASE LTRIM(RTRIM(strPaymentType)) WHEN  '1' THEN 'Cash' WHEN '2' THEN 'Check' WHEN '3'  THEN 'Credit Card'  ELSE '' END)
			,@dblPaymentAmount = dblPaymentAmount
			,@strLocation = strLocation
		FROM @StagingTable
			WHERE strCustomerNumber = (SELECT TOP 1 strCustomerNumber FROM #tmpUniqueInvoiceList)
			AND strInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM #tmpUniqueInvoiceList)
			AND dtmPaymentDate =  (SELECT TOP 1 dtmPaymentDate FROM #tmpUniqueInvoiceList)
			AND strRecordType = 'C'
	
		----Get check number if exists
		SELECT TOP 1 @strCheckNumOrDesc = strDescriptionCheckNum
		FROM  @StagingTable 
				WHERE strCustomerNumber = (SELECT TOP 1 strCustomerNumber FROM #tmpUniqueInvoiceList)
			AND strInvoiceNumber = (SELECT TOP 1 strInvoiceNumber FROM #tmpUniqueInvoiceList)
			AND dtmPaymentDate =  (SELECT TOP 1 dtmPaymentDate FROM #tmpUniqueInvoiceList)
		
			AND strRecordType = 'Z'
	
			SET @strErrorMessage = ''

				------Get equivalent Ids---------
				--Get Customer Entity Id
				SET @intCustomerEntityId = (SELECT TOP 1 intEntityId FROM tblEMEntity WHERE strEntityNo = @strCustomerNumber)
				--Get Location Id
				SET @intLocationId = (SELECT TOP 1 intCompanyLocationId FROM tblSMCompanyLocation WHERE strLocationNumber = @strLocation)
				--Get Payment Method Id
				SET @intPaymentMethodId = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = @strPaymentMethod)
					
			BEGIN TRANSACTION
			EXEC uspARCreateCustomerPayment
					@EntityCustomerId	= @intCustomerEntityId	--INT
					,@CompanyLocationId	= @intLocationId		--INT
					,@DatePaid			= @dtmPaymentDate--DATETIME
					,@AmountPaid		= @dblPaymentAmount--NUMERIC(18,6)	= 0.000000
					,@PaymentMethodId	= @intPaymentMethodId--INT
					,@PaymentInfo		= @strCheckNumOrDesc --NVARCHAR(50)	= NULL
					,@EntityId			= @EntityUserId				--INT
					,@ErrorMessage		= @strErrorMessage OUTPUT	--NVARCHAR(250)	= NULL			OUTPUT
					,@NewPaymentId	= @intNewPaymentId OUTPUT		--INT				= NULL			OUTPUT 		
					,@RaiseError = 0									--BIT				= 0
					--,@Payment									--NUMERIC(18,6)	= 0.000000
					--,@CurrencyId		--INT				= NULL
					--,@AccountId			--INT				= NULL
					--,@BankAccountId		--INT				= NULL
					--,@InvoiceId									--INT				= NULL
					--,@ApplytoBudget		--BIT				= 0
					--,@ApplyOnAccount	--BIT				= 0
					--,@Notes				--NVARCHAR(250)	= ''
					--,@ApplyTermDiscount	--BIT				= 1
					--,@Discount			--NUMERIC(18,6)	= 0.000000	
					--,@Interest			--NUMERIC(18,6)	= 0.000000			
					--,@InvoicePrepayment	--BIT				= 0
					--,@WriteOffAccountId	--INT				= NULL
					,@AllowPrepayment								= 1--BIT				= 0
					--,@AllowOverpayment								--BIT				= 0
			
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
							,strRecordId
					)
					SELECT
							strCustomerNumber = @strCustomerNumber		
							,strInvoiceNumber =	@strPaymentNumber
							,strSiteNumber = ''		
							,dtmDate = @dtmPaymentDate					
							,intLineItem = 0--@intLineItem		
							,strFileName = ''				
							,strStatus = 'Importing Failed'
							,ysnSuccessful = 0
							,intInvoiceId = @intNewPaymentId--@intNewInvoiceId
							,strRecordId = @intNewPaymentId
				END

			ELSE
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
				)

				SELECT
						strCustomerNumber = @strCustomerNumber		
						,strInvoiceNumber =	@strNewPaymentNumber		
						,strSiteNumber = 0
						,dtmDate = @dtmPaymentDate
						,intLineItem = 0						
						,strFileName = ''				
						,strStatus = 'Successfully created '-- + @strNewPaymentNumber
						,ysnSuccessful = 1
						,intInvoiceId = @intNewPaymentId
						,strRecordId = @intNewPaymentId

						--select * from @ResultTableLog--debug
				END
			
			COMMIT TRANSACTION

			CONTINUELOOP:
			--Delete processed record
					DELETE FROM #tmpUniqueInvoiceList 
			WHERE strCustomerNumber = @strCustomerNumber 
			AND strInvoiceNumber = @strPaymentNumber
			AND dtmPaymentDate = @dtmPaymentDate 

		END
			
	SELECT * FROM @ResultTableLog

END
GO