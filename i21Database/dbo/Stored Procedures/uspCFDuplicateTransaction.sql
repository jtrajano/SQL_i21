CREATE PROCEDURE [dbo].[uspCFDuplicateTransaction]
	@TransactionId	NVARCHAR(MAX),
	@UserId INT
AS
BEGIN

--Transaction duplicated from CFDT-XXXXXXX
BEGIN TRANSACTION

	BEGIN TRY

	DECLARE @dblAuditOriginalTotalPrice	    NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditOriginalGrossPrice		NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditOriginalNetPrice		NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditCalculatedTotalPrice	NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditCalculatedGrossPrice	NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditCalculatedNetPrice		NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditCalculatedTotalTax		NVARCHAR(MAX) = 0.000000
	DECLARE @dblAuditOriginalTotalTax		NVARCHAR(MAX) = 0.000000
	DECLARE @strAuditPriceMethod			NVARCHAR(MAX) = ''
	DECLARE @strAuditPriceBasis				NVARCHAR(MAX) = ''
	DECLARE @strAuditPriceProfileId			NVARCHAR(MAX) = ''
	DECLARE @strAuditPriceIndexId			NVARCHAR(MAX) = ''
	DECLARE @strTransactionId				NVARCHAR(MAX) = ''
	

	
	SELECT TOP 1
		@dblAuditOriginalTotalPrice	     =		ISNULL(dblOriginalTotalPrice,0)		
	, @dblAuditOriginalGrossPrice		 =		ISNULL(dblOriginalGrossPrice,0)
	, @dblAuditOriginalNetPrice			 =		ISNULL(dblOriginalNetPrice,0) 
	, @dblAuditCalculatedTotalPrice		 =		ISNULL(dblCalculatedTotalPrice,0) 
	, @dblAuditCalculatedGrossPrice		 =		ISNULL(dblCalculatedGrossPrice,0) 
	, @dblAuditCalculatedNetPrice		 =		ISNULL(dblCalculatedNetPrice,0)
	, @dblAuditCalculatedTotalTax		 =		ISNULL(dblCalculatedTotalTax,0)
	, @dblAuditOriginalTotalTax			 =		ISNULL(dblOriginalTotalTax,0)
	, @strAuditPriceMethod				 =		ISNULL(strPriceMethod,'')
	, @strAuditPriceBasis				 =		ISNULL(strPriceBasis,'')
	, @strAuditPriceProfileId			 =		ISNULL(strPriceProfileId,'')
	, @strAuditPriceIndexId				 =		ISNULL(strPriceIndexId,'')
	, @strTransactionId					 =		ISNULL(strTransactionId,'')
	FROM tblCFTransaction
	WHERE intTransactionId = @TransactionId 

	DECLARE @newId INT
	DECLARE @strOldId NVARCHAR(MAX)
	DECLARE @newDate DATETIME = GETDATE()
	DECLARE @strAuditLogTilte NVARCHAR(MAX)

	SELECT TOP 1 @strOldId = ISNULL(strTransactionId,'') FROM tblCFTransaction WHERE intTransactionId = @TransactionId
	SET @strAuditLogTilte = 'Transaction duplicated from ' + @strOldId

	INSERT INTO tblCFTransaction
	(
		 intPriceIndexId
		,intPriceProfileId
		,intSiteGroupId
		,strPriceProfileId
		,strPriceIndexId
		,strSiteGroup
		,dblPriceProfileRate
		,dblPriceIndexRate
		,dtmPriceIndexDate
		,intContractDetailId
		,intContractId
		,dblQuantity
		,dtmBillingDate
		,dtmTransactionDate
		,intTransTime
		,strSequenceNumber
		,strPONumber
		,strMiscellaneous
		,intOdometer
		,intPumpNumber
		,dblTransferCost
		,strPriceMethod
		,strPriceBasis
		,strTransactionType
		,strDeliveryPickupInd
		,intNetworkId
		,intSiteId
		,intCardId
		,intVehicleId
		,intProductId
		,intARItemId
		,intARLocationId
		,dblOriginalTotalPrice
		,dblCalculatedTotalPrice
		,dblOriginalGrossPrice
		,dblCalculatedGrossPrice
		,dblCalculatedNetPrice
		,dblOriginalNetPrice
		,dblCalculatedPumpPrice
		,dblOriginalPumpPrice
		,dblCalculatedTotalTax
		,dblOriginalTotalTax
		,intSalesPersonId
		,ysnInvalid
		,ysnCreditCardUsed
		,ysnOriginHistory
		,strPrintTimeStamp
		,strInvoiceReportNumber
		,strTempInvoiceReportNumber
		,intInvoiceId
		,intConcurrencyId
		,strForeignCardId
		,ysnDuplicate
		,dtmInvoiceDate
		,dtmCreatedDate
		,strOriginalProductNumber
		,intOverFilledTransactionId
		,dblInventoryCost
		,dblMargin
		,dblAdjustmentRate
		,dblGrossTransferCost
		,dblNetTransferCost
		,ysnOnHold
		,intFreightTermId
		,intForDeleteTransId
		,intCustomerId
		,ysnInvoiced
		,intImportCardId
		,ysnExpensed
		,intExpensedItemId
		,dtmPostedDate
		,ysnPosted
		,ysnPostedCSV
	)
	SELECT TOP 1
		 intPriceIndexId
		,intPriceProfileId
		,intSiteGroupId
		,strPriceProfileId
		,strPriceIndexId
		,strSiteGroup
		,dblPriceProfileRate
		,dblPriceIndexRate
		,dtmPriceIndexDate
		,intContractDetailId
		,intContractId
		,dblQuantity
		,dtmBillingDate
		,dtmTransactionDate
		,intTransTime
		,strSequenceNumber
		,strPONumber
		,strMiscellaneous
		,intOdometer
		,intPumpNumber
		,dblTransferCost
		,strPriceMethod
		,strPriceBasis
		,strTransactionType
		,strDeliveryPickupInd
		,intNetworkId
		,intSiteId
		,intCardId
		,intVehicleId
		,intProductId
		,intARItemId
		,intARLocationId
		,dblOriginalTotalPrice
		,dblCalculatedTotalPrice
		,dblOriginalGrossPrice
		,dblCalculatedGrossPrice
		,dblCalculatedNetPrice
		,dblOriginalNetPrice
		,dblCalculatedPumpPrice
		,dblOriginalPumpPrice
		,dblCalculatedTotalTax
		,dblOriginalTotalTax
		,intSalesPersonId
		,ysnInvalid
		,ysnCreditCardUsed
		,ysnOriginHistory
		,strPrintTimeStamp
		,''
		,''
		,0
		,intConcurrencyId
		,strForeignCardId
		,ysnDuplicate
		,dtmInvoiceDate
		,@newDate
		,strOriginalProductNumber
		,intOverFilledTransactionId
		,dblInventoryCost
		,dblMargin
		,dblAdjustmentRate
		,dblGrossTransferCost
		,dblNetTransferCost
		,ysnOnHold
		,intFreightTermId
		,intForDeleteTransId
		,intCustomerId
		,0
		,intImportCardId
		,ysnExpensed
		,intExpensedItemId
		,GETDATE()
		,0
		,0
	FROM tblCFTransaction
	WHERE ISNULL(intTransactionId,0) = ISNULL(@TransactionId,0)

	SET @newId = SCOPE_IDENTITY()

	INSERT INTO tblCFTransactionTax
	(
		 intTransactionId
		,dblTaxOriginalAmount
		,dblTaxCalculatedAmount
		,intTaxCodeId
		,dblTaxRate
	)
	SELECT
		 @newId
		,dblTaxOriginalAmount
		,dblTaxCalculatedAmount
		,intTaxCodeId
		,dblTaxRate
	FROM tblCFTransactionTax
	WHERE ISNULL(intTransactionId,0) = ISNULL(@TransactionId,0)

	INSERT INTO tblCFTransactionNote
	(
		 intTransactionId
		,strProcess
		,dtmProcessDate
		,strNote
		,strGuid
	)
	SELECT
		 @newId
		,strProcess
		,dtmProcessDate
		,strNote
		,strGuid
	FROM tblCFTransactionNote
	WHERE ISNULL(intTransactionId,0) = ISNULL(@TransactionId,0)

	DECLARE @processName nvarchar(max) = ('Duplicated from ' + @strTransactionId)

	EXEC [uspCFTransactionAuditLog] 
		@processName					= @processName
		,@keyValue						= @newId
		,@entityId						= @UserId
		,@action						= ''
		,@dblFromOriginalTotalPrice		= @dblAuditOriginalTotalPrice	
		,@dblFromOriginalGrossPrice		= @dblAuditOriginalGrossPrice	
		,@dblFromOriginalNetPrice		= @dblAuditOriginalNetPrice		
		,@dblFromCalculatedTotalPrice	= @dblAuditCalculatedTotalPrice	
		,@dblFromCalculatedGrossPrice	= @dblAuditCalculatedGrossPrice	
		,@dblFromCalculatedNetPrice		= @dblAuditCalculatedNetPrice	
		,@dblFromCalculatedTotalTax		= @dblAuditCalculatedTotalTax	
		,@dblFromOriginalTotalTax		= @dblAuditOriginalTotalTax		
		,@strFromPriceMethod			= @strAuditPriceMethod			
		,@strFromPriceBasis				= @strAuditPriceBasis			
		,@strFromPriceProfileId			= @strAuditPriceProfileId		
		,@strFromPriceIndexId			= @strAuditPriceIndexId			


	EXEC dbo.uspSMAuditLog 
	 @keyValue			= @newId							-- Primary Key Value of the Invoice. 
	,@screenName		= 'CardFueling.view.Transaction'	-- Screen Namespace
	,@entityId			= @UserId									-- Entity Id.
	,@actionType		= 'Add'							    -- Action Type
	,@changeDescription	= @strAuditLogTilte							-- Description
	,@fromValue			= ''								-- Previous Value
	,@toValue			= ''	

	COMMIT TRANSACTION

	SELECT TOP 1
	 intTransactionId
	,strTransactionId
	,CAST(1 as BIT) as ysnResult
	FROM tblCFTransaction
	WHERE intTransactionId = @newId
	

	END TRY
	BEGIN CATCH

	ROLLBACK TRANSACTION

	SELECT TOP 1
	 0 as intTransactionId
	,'' as strTransactionId
	,CAST(0 as BIT) as ysnResult

	END CATCH
	
END