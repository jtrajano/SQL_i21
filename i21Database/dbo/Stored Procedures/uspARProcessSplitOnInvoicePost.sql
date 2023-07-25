﻿CREATE PROCEDURE [dbo].[uspARProcessSplitOnInvoicePost]
      @ysnPost			BIT = 1
	, @ysnRecap			BIT = 0
	, @dtmDatePost		DATETIME = NULL
	, @strBatchId		NVARCHAR(40) = NULL
	, @intUserId		INT = 1
	, @strSessionId		NVARCHAR(50) = NULL
AS
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF
SET XACT_ABORT ON  

BEGIN TRY
	DECLARE @InvoiceEntries					AS InvoiceStagingTable
	DECLARE @LineItemTaxEntries				AS LineItemTaxDetailStagingTable
	DECLARE @InvoiceIds						AS InvoiceId
	DECLARE @intLogId						INT = NULL
	DECLARE @ysnRetainSplitItemContractQty	BIT = 0

	SELECT TOP 1 @ysnRetainSplitItemContractQty = ysnRetainSplitItemContractQty
	FROM tblARCompanyPreference

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
	IF(OBJECT_ID('tempdb..#SPLITITEMCONTRACT') IS NOT NULL) DROP TABLE #SPLITITEMCONTRACT
	CREATE TABLE #SPLITITEMCONTRACT (
		  intInvoiceDetailId		INT NOT NULL		
		, intItemContractDetailId	INT NOT NULL
		, dblQty					NUMERIC(18,6) NULL DEFAULT 0
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
	FROM tblARPostInvoiceHeader I 
	INNER JOIN tblEMEntitySplitDetail SD ON I.intSplitId = SD.intSplitId
	INNER JOIN tblARCustomer C ON SD.intEntityId = C.intEntityId
	WHERE I.intSplitId IS NOT NULL
	  AND I.intDistributionHeaderId IS NULL 
	  AND I.strType <> 'Transport Delivery'
	  AND ((I.strTransactionType IN ('Invoice', 'Credit Memo') AND I.strType = 'Standard') OR I.strTransactionType NOT IN ('Invoice', 'Credit Memo'))
	  AND I.strSessionId = @strSessionId
	  AND I.ysnSplitted = 0

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
	INNER JOIN tblARPostInvoiceHeader I ON SD.intSplitEntityId = I.intEntityCustomerId AND I.intInvoiceId = SD.intInvoiceId
	WHERE I.strSessionId = @strSessionId

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
		, ysnSplitted

		, intItemId
		, intItemUOMId
		, strItemDescription
		, dblQtyOrdered
		, dblQtyShipped
		, dblDiscount
		, dblPrice
		, ysnRecomputeTax
		, intCustomerStorageId
		, intStorageScheduleTypeId
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
		, ysnSplitted            = 1

		, intItemId				= I.intItemId
		, intItemUOMId			= I.intItemUOMId
		, strItemDescription	= I.strItemDescription
		, dblQtyOrdered			= CASE WHEN I.intInventoryShipmentItemId IS NOT NULL OR I.intSalesOrderDetailId IS NOT NULL THEN I.dblQtyShipped * SD.dblSplitPercent ELSE 0 END
		, dblQtyShipped			= I.dblQtyShipped * SD.dblSplitPercent
		, dblDiscount			= I.dblDiscount
		, dblPrice				= I.dblPrice
		, ysnRecomputeTax		= 1
		, intCustomerStorageId	= I.intCustomerStorageId
		, intStorageScheduleTypeId	= GCS.intStorageTypeId
	FROM #SPLITINVOICEDETAILS SD
	INNER JOIN tblARPostInvoiceDetail I ON I.intInvoiceId = SD.intInvoiceId
	LEFT JOIN tblGRCustomerStorage GCS ON I.intStorageScheduleTypeId = GCS.intStorageTypeId
									  AND SD.intSplitEntityId = GCS.intEntityId 
									  AND I.intItemId = GCS.intItemId 
									  AND I.intCompanyLocationId = GCS.intCompanyLocationId
	WHERE I.intContractDetailId IS NULL
	  AND I.strSessionId = @strSessionId
	
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
	  , intEntityContactId		= SPLITENTITY.intEntityContactId
	  , intEntitySalespersonId	= SPLITENTITY.intSalespersonId
	  , dtmDueDate              = dbo.fnGetDueDateBasedOnTerm(I.dtmDate, I.intTermId)	
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
	WHERE (ID.intItemContractDetailId IS NOT NULL AND @ysnRetainSplitItemContractQty = 0) OR ID.intItemContractDetailId IS NULL
	
	--UPDATE CURRENT INVOICE DETAIL TAX FROM #EXCLUDEDSPLIT			
	UPDATE IDT 
	SET dblTax			= IDT.dblTax * II.dblSplitPercent
	  , dblAdjustedTax	= IDT.dblAdjustedTax * II.dblSplitPercent
	FROM tblARInvoiceDetailTax IDT
	INNER JOIN tblARInvoiceDetail ID ON IDT.intInvoiceDetailId = ID.intInvoiceDetailId
	INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
	INNER JOIN #EXCLUDEDSPLIT II ON I.intInvoiceId = II.intInvoiceId
	WHERE (ID.intItemContractDetailId IS NOT NULL AND @ysnRetainSplitItemContractQty = 0) OR ID.intItemContractDetailId IS NULL

	IF @ysnRetainSplitItemContractQty = 0
		BEGIN
			INSERT INTO #SPLITITEMCONTRACT (
				  intItemContractDetailId
				, intInvoiceDetailId
				, dblQty
			)
			SELECT intItemContractDetailId	= ID.intItemContractDetailId
				 , intInvoiceDetailId		= ID.intInvoiceDetailId
				 , dblQty					= ICH.dblNewScheduled - ID.dblQtyShipped
			FROM tblARInvoiceDetail ID
			INNER JOIN tblARInvoice I ON ID.intInvoiceId = I.intInvoiceId
			INNER JOIN #EXCLUDEDSPLIT II ON I.intInvoiceId = II.intInvoiceId
			INNER JOIN tblCTItemContractHistory ICH ON ID.intItemContractDetailId = ICH.intItemContractDetailId AND I.strInvoiceNumber = ICH.strTransactionId AND I.intInvoiceId = ICH.intTransactionId AND ID.intInvoiceDetailId = ICH.intTransactionDetailId
			WHERE ID.intItemContractDetailId IS NOT NULL

			WHILE EXISTS (SELECT TOP 1 1 FROM #SPLITITEMCONTRACT)
				BEGIN 
					DECLARE @intInvoiceDetailId			INT = NULL
						  , @intItemContractDetailId	INT = NULL
						  , @dblQty						NUMERIC(18, 6) = 0

					SELECT TOP 1 @intInvoiceDetailId		= intInvoiceDetailId
							  , @intItemContractDetailId	= intItemContractDetailId
							  , @dblQty						= -dblQty
					FROM #SPLITITEMCONTRACT

					EXEC dbo.uspCTItemContractUpdateScheduleQuantity @intItemContractDetailId	= @intItemContractDetailId
													               , @dblQuantityToUpdate		= @dblQty
													               , @intUserId					= @intUserId
													               , @intTransactionDetailId	= @intInvoiceDetailId
													               , @strScreenName				= 'Invoice'

					DELETE FROM #SPLITITEMCONTRACT WHERE intInvoiceDetailId = @intInvoiceDetailId

				
				END
		END

	--DELETE UPDATED INVOICE FROM CURRENT POSTING DETAILS AND HEADER
	DELETE IH
	FROM tblARPostInvoiceHeader IH
	INNER JOIN #EXCLUDEDSPLIT ES ON IH.intInvoiceId = ES.intInvoiceId
	WHERE IH.strSessionId = @strSessionId

	DELETE ID
	FROM tblARPostInvoiceDetail ID 	
	INNER JOIN #EXCLUDEDSPLIT ES ON ID.intInvoiceId = ES.intInvoiceId
	WHERE ID.strSessionId = @strSessionId

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
			
	EXEC dbo.uspARPopulateInvoiceDetailForPosting @InvoiceIds = @InvoiceIds, @Post = @ysnPost, @Recap = @ysnRecap, @PostDate = @dtmDatePost, @BatchId = @strBatchId, @strSessionId = @strSessionId

END TRY
BEGIN CATCH
    DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
    											
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

Post_Exit:
	RETURN 0;