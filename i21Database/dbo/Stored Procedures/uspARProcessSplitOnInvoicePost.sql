CREATE PROCEDURE [dbo].[uspARProcessSplitOnInvoicePost]
      @ysnPost			BIT = 1
	, @ysnRecap			BIT = 0
	, @dtmDatePost		DATETIME = NULL
	, @strBatchId		NVARCHAR(40) = NULL
	, @intUserId		INT = 1
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON  

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF @InitTranCount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION @Savepoint

BEGIN TRY
	DECLARE @InvoiceEntries		AS InvoiceStagingTable
	DECLARE @LineItemTaxEntries	AS LineItemTaxDetailStagingTable
	DECLARE @InvoiceIds			AS InvoiceId
	DECLARE @intLogId			INT = NULL

	IF(OBJECT_ID('tempdb..#SPLITINVOICEDETAILS') IS NOT NULL) DROP TABLE #SPLITINVOICEDETAILS	
	CREATE TABLE #SPLITINVOICEDETAILS (
		  intInvoiceId			INT NOT NULL		
		, intUserId				INT NULL
		, intSplitEntityId		INT NULL
		, intSplitId			INT NOT NULL
		, dtmDate				DATETIME NULL
		, dblSplitPercent		NUMERIC(18,6) NULL DEFAULT 0
		, strTransactionType	NVARCHAR(25) NULL
	)
	IF(OBJECT_ID('tempdb..#EXCLUDEDSPLIT') IS NOT NULL) DROP TABLE #EXCLUDEDSPLIT
	CREATE TABLE #EXCLUDEDSPLIT (
		  intInvoiceId			INT NOT NULL		
		, intUserId				INT NULL
		, intSplitEntityId		INT NULL
		, intSplitId			INT NOT NULL
		, dtmDate				DATETIME NULL
		, dblSplitPercent		NUMERIC(18,6) NULL DEFAULT 0
		, strTransactionType	NVARCHAR(25) NULL
	)

	SET @ysnPost = 1	
	
	--GET ALL INVOICES TO SPLIT	
	INSERT INTO #SPLITINVOICEDETAILS (
		  intInvoiceId
		, intUserId
		, intSplitEntityId
		, intSplitId
		, dtmDate
		, dblSplitPercent
		, strTransactionType
	)
	SELECT intInvoiceId			= I.intInvoiceId
		 , intUserId			= I.intEntityId
		 , intSplitEntityId		= SD.intEntityId
		 , intSplitId			= I.intSplitId
		 , dtmDate				= I.dtmDate
		 , dblSplitPercent		= CASE WHEN SD.dblSplitPercent > 0 THEN SD.dblSplitPercent/100 ELSE 1 END
		 , strTransactionType	= I.strTransactionType
	FROM ##ARPostInvoiceHeader I 
	INNER JOIN tblEMEntitySplitDetail SD ON I.intSplitId = SD.intSplitId
	WHERE I.intSplitId IS NOT NULL
	  AND I.intDistributionHeaderId IS NULL 
	  AND I.strType <> 'Transport Delivery'
	  AND ((I.strTransactionType IN ('Invoice', 'Credit Memo') AND I.strType = 'Standard') OR I.strTransactionType NOT IN ('Invoice', 'Credit Memo'))

	IF NOT EXISTS(SELECT TOP 1 NULL FROM #SPLITINVOICEDETAILS)
		RETURN;

	--GET INVOICE FROM SPLIT TO UPDATE
	INSERT INTO #EXCLUDEDSPLIT (
		  intInvoiceId
		, intUserId
		, intSplitEntityId
		, intSplitId
		, dtmDate
		, dblSplitPercent
		, strTransactionType
	)
	SELECT intInvoiceId			= SD.intInvoiceId
		, intUserId				= SD.intUserId
		, intSplitEntityId		= SD.intSplitEntityId
		, intSplitId			= SD.intSplitId
		, dtmDate				= SD.dtmDate
		, dblSplitPercent		= SD.dblSplitPercent
		, strTransactionType	= SD.strTransactionType
	FROM #SPLITINVOICEDETAILS SD
	INNER JOIN (
		SELECT intInvoiceId		= SDD.intInvoiceId
			 , intSplitEntityId	= MIN(SDD.intSplitEntityId)
		FROM #SPLITINVOICEDETAILS SDD
		GROUP BY SDD.intInvoiceId
	) SDO ON SD.intInvoiceId = SDO.intInvoiceId AND SD.intSplitEntityId = SDO.intSplitEntityId

	--REMOVE INVOICE TO UPDATE
	DELETE SD
	FROM #SPLITINVOICEDETAILS SD
	INNER JOIN #EXCLUDEDSPLIT SP ON SD.intInvoiceId = SP.intInvoiceId AND SD.intSplitEntityId = SP.intSplitEntityId
	
	--CREATE INVOICES FROM #SPLITINVOICEDETAILS
	INSERT INTO @InvoiceEntries (
		  intId
		, intSourceId
		, strTransactionType
		, strType
		, strSourceTransaction
		, strSourceId
		, intEntityCustomerId
		, intCompanyLocationId
		, intEntityId
		, intTermId
		, dtmDate		
		, dtmShipDate
		, dtmPostDate
		, strInvoiceOriginId
		, strComments
		, ysnImpactInventory
		, intSplitId
		, intOriginalInvoiceId
		, strPONumber
		, strBOLNumber

		, intItemId
		, intItemUOMId
		, strItemDescription
		, dblQtyOrdered
		, dblQtyShipped
		, dblDiscount
		, dblPrice
		, ysnRecomputeTax
	)
	SELECT intId				= I.intInvoiceId
		, intSourceId			= I.intInvoiceId
		, strTransactionType	= I.strTransactionType
		, strType				= I.strType
		, strSourceTransaction	= 'Store Charge'
		, strSourceId			= I.strInvoiceNumber
		, intEntityCustomerId	= SD.intSplitEntityId
		, intCompanyLocationId	= I.intCompanyLocationId
		, intEntityId			= I.intEntityId
		, intTermId				= I.intTermId
		, dtmDate				= I.dtmDate		
		, dtmShipDate			= I.dtmShipDate
		, dtmPostDate			= I.dtmPostDate
		, strInvoiceOriginId	= I.strInvoiceNumber
		, strComments			= I.strComments + ' Split: ' + I.strInvoiceNumber
		, ysnImpactInventory	= I.ysnImpactInventory
		, intSplitId			= I.intSplitId
		, intOriginalInvoiceId	= I.intInvoiceId
		, strPONumber			= NULL--I.strPONumber
		, strBOLNumber			= I.strBOLNumber

		, intItemId				= I.intItemId
		, intItemUOMId			= I.intItemUOMId
		, strItemDescription	= I.strItemDescription
		, dblQtyOrdered			= CASE WHEN I.intInventoryShipmentItemId IS NOT NULL OR I.intSalesOrderDetailId IS NOT NULL THEN I.dblQtyShipped * SD.dblSplitPercent ELSE 0 END
		, dblQtyShipped			= I.dblQtyShipped * SD.dblSplitPercent
		, dblDiscount			= I.dblDiscount
		, dblPrice				= I.dblPrice
		, ysnRecomputeTax		= 1
	FROM #SPLITINVOICEDETAILS SD
	INNER JOIN ##ARPostInvoiceDetail I ON I.intInvoiceId = SD.intInvoiceId
	WHERE I.intContractDetailId IS NULL
	
	EXEC uspARProcessInvoicesByBatch @InvoiceEntries		= @InvoiceEntries
								   , @LineItemTaxEntries	= @LineItemTaxEntries
								   , @UserId				= @intUserId
								   , @GroupingOption		= 10
								   , @RaiseError			= 1
								   , @LogId					= @intLogId OUT
	
	--UPDATE CURRENT INVOICE FROM #EXCLUDEDSPLIT		
	UPDATE I 
	SET ysnSplitted				= 1
	  , intSplitId				= I.intSplitId
	  , strInvoiceOriginId		= I.strInvoiceNumber
	  , intEntityCustomerId		= II.intSplitEntityId
	  , intShipToLocationId		= SPLITENTITY.intShipToId
	  , intBillToLocationId		= SPLITENTITY.intBillToId
	  , intTermId				= SPLITENTITY.intTermsId
	  , intEntityContactId		= SPLITENTITY.intEntityContactId
	  , intEntitySalespersonId	= SPLITENTITY.intSalespersonId
	  , dtmDueDate				= dbo.fnGetDueDateBasedOnTerm(I.dtmDate, SPLITENTITY.intTermsId)
	  , dblAmountDue			= dblAmountDue * II.dblSplitPercent	  
	  , dblInvoiceSubtotal		= dblInvoiceSubtotal * II.dblSplitPercent
	  , dblInvoiceTotal			= dblInvoiceTotal * II.dblSplitPercent
	  , dblTax					= dblTax * II.dblSplitPercent
	  , dblSplitPercent			= II.dblSplitPercent
	  , strShipToLocationName	= SPLITENTITY.strShipToLocationName
	  , strShipToAddress		= SPLITENTITY.strShipToAddress
	  , strShipToCity			= SPLITENTITY.strShipToCity
	  , strShipToState			= SPLITENTITY.strShipToState
	  , strShipToZipCode		= SPLITENTITY.strShipToZipCode
	  , strShipToCountry		= SPLITENTITY.strShipToCountry
	  , strBillToLocationName	= SPLITENTITY.strBillToLocationName
	  , strBillToAddress		= SPLITENTITY.strBillToAddress
	  , strBillToCity			= SPLITENTITY.strBillToCity
	  , strBillToState			= SPLITENTITY.strBillToState
	  , strBillToZipCode		= SPLITENTITY.strBillToZipCode
	  , strBillToCountry		= SPLITENTITY.strBillToCountry
	FROM tblARInvoice I
	INNER JOIN #EXCLUDEDSPLIT II ON I.intInvoiceId = II.intInvoiceId
	INNER JOIN (
		SELECT intEntityCustomerId
			 , intTermsId
			 , intSalespersonId
			 , intBillToId
			 , intShipToId
			 , intFreightTermId
			 , intEntityContactId
			 , strShipToLocationName
			 , strShipToAddress
			 , strShipToCity
			 , strShipToState
			 , strShipToZipCode
			 , strShipToCountry
			 , strBillToLocationName
			 , strBillToAddress
			 , strBillToCity
			 , strBillToState
			 , strBillToZipCode
			 , strBillToCountry
		FROM vyuARCustomerSearch
	) SPLITENTITY ON SPLITENTITY.intEntityCustomerId = II.intSplitEntityId

	--UPDATE CURRENT INVOICE DETAILS FROM #EXCLUDEDSPLIT
	UPDATE ID 
	SET dblQtyOrdered	= CASE WHEN I.strTransactionType = 'Invoice' AND (intInventoryShipmentItemId IS NOT NULL OR intSalesOrderDetailId IS NOT NULL) THEN dblQtyShipped * II.dblSplitPercent  ELSE 0 END
	  , dblQtyShipped	= dblQtyShipped * II.dblSplitPercent
	FROM tblARInvoiceDetail ID
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN #EXCLUDEDSPLIT II ON I.intInvoiceId = II.intInvoiceId
	
	--UPDATE CURRENT INVOICE DETAIL TAX FROM #EXCLUDEDSPLIT			
	UPDATE IDT 
	SET dblTax			= IDT.dblTax * II.dblSplitPercent
	  , dblAdjustedTax	= IDT.dblAdjustedTax * II.dblSplitPercent
	FROM tblARInvoiceDetailTax IDT
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN #EXCLUDEDSPLIT II ON I.intInvoiceId = II.intInvoiceId

	--DELETE UPDATED INVOICE FROM CURRENT POSTING DETAILS AND HEADER
	DELETE IH
	FROM ##ARPostInvoiceHeader IH
	INNER JOIN #EXCLUDEDSPLIT ES ON IH.intInvoiceId = ES.intInvoiceId

	DELETE ID
	FROM ##ARPostInvoiceDetail ID 	
	INNER JOIN #EXCLUDEDSPLIT ES ON ID.intInvoiceId = ES.intInvoiceId

	INSERT INTO @InvoiceIds (
		  intHeaderId
		, strTransactionType
		, ysnPost
	)
	SELECT DISTINCT 
		  intHeaderId			= intInvoiceId
		, strTransactionType	= strTransactionType
		, ysnPost				= @ysnPost
	FROM #EXCLUDEDSPLIT

	--RECOMPUTE AMOUNTS AND TAXES
	EXEC dbo.uspARReComputeInvoicesTaxes @InvoiceIds	
	EXEC dbo.uspARInsertTransactionDetails @InvoiceIds

	--RE-POPULATE INVOICE DETAILS FOR POSTING
	INSERT INTO @InvoiceIds (
		  intHeaderId
		, strTransactionType
		, ysnPost
	)
	SELECT intHeaderId			= I.intInvoiceId
		 , strTransactionType	= I.strTransactionType
		 , ysnPost				= @ysnPost
	FROM tblARInvoice I	
	INNER JOIN tblARInvoiceIntegrationLogDetail L ON I.intInvoiceId = L.intInvoiceId
	WHERE intIntegrationLogId = @intLogId 
	  AND ysnSuccess = 1
      AND ysnHeader = 1
			
	EXEC dbo.uspARPopulateInvoiceDetailForPosting @InvoiceIds = @InvoiceIds, @Post = @ysnPost, @Recap = @ysnRecap, @PostDate = @dtmDatePost, @BatchId = @strBatchId

END TRY
BEGIN CATCH
    DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
    IF @InitTranCount = 0
        IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION
	ELSE
		IF (XACT_STATE()) <> 0
			ROLLBACK TRANSACTION @Savepoint
												
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH


IF @InitTranCount = 0
	BEGIN
		IF (XACT_STATE()) = -1
			ROLLBACK TRANSACTION
		IF (XACT_STATE()) = 1
			COMMIT TRANSACTION
		RETURN 1;
	END	


Post_Exit:
	RETURN 0;