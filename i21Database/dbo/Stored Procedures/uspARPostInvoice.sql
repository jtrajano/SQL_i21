﻿CREATE PROCEDURE [dbo].[uspARPostInvoice]
	@batchId			AS NVARCHAR(40)		= NULL
	,@post				AS BIT				= 0
	,@recap				AS BIT				= 0
	,@param				AS NVARCHAR(MAX)	= NULL
	,@userId			AS INT				= 1
	,@beginDate			AS DATE				= NULL
	,@endDate			AS DATE				= NULL
	,@beginTransaction	AS NVARCHAR(50)		= NULL
	,@endTransaction	AS NVARCHAR(50)		= NULL
	,@exclude			AS NVARCHAR(MAX)	= NULL
	,@successfulCount	AS INT				= 0 OUTPUT
	,@invalidCount		AS INT				= 0 OUTPUT
	,@success			AS BIT				= 0 OUTPUT
	,@batchIdUsed		AS NVARCHAR(40)		= NULL OUTPUT
	,@recapId			AS NVARCHAR(250)	= NEWID OUTPUT
	,@transType			AS NVARCHAR(25)		= 'all'
	,@raiseError		AS BIT				= 0
AS
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
--------------------------------------------------------------------------------------------  
-- Initialize   
--------------------------------------------------------------------------------------------   
-- Create a unique transaction name. 
DECLARE @TransactionName AS VARCHAR(500) = 'Invoice Transaction' + CAST(NEWID() AS NVARCHAR(100));
IF @raiseError = 0
	--BEGIN TRAN @TransactionName
	BEGIN TRANSACTION
DECLARE @totalRecords INT = 0
DECLARE @totalInvalid INT = 0
 
DECLARE @PostInvoiceData TABLE  (
	intInvoiceId int PRIMARY KEY,
	strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	UNIQUE (intInvoiceId)
);

DECLARE @InvalidInvoiceData TABLE  (
	strError NVARCHAR(100),
	strTransactionType NVARCHAR(50),
	strTransactionId NVARCHAR(50),
	strBatchNumber NVARCHAR(50),
	intTransactionId INT
);

DECLARE @PostDate AS DATETIME
SET @PostDate = CAST(GETDATE() AS DATE)

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'


DECLARE @UserEntityID				INT
		,@DiscountAccountId			INT
		,@ServiceChargesAccountId	INT
		,@DeferredRevenueAccountId	INT

SET @UserEntityID = ISNULL((SELECT [intEntityUserSecurityId] FROM tblSMUserSecurity WHERE [intEntityUserSecurityId] = @userId),@userId)
SET @DiscountAccountId = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)
SET @ServiceChargesAccountId = (SELECT TOP 1 intServiceChargeAccountId FROM tblARCompanyPreference WHERE intServiceChargeAccountId IS NOT NULL AND intServiceChargeAccountId <> 0)
SET @DeferredRevenueAccountId = (SELECT TOP 1 intDeferredRevenueAccountId FROM tblARCompanyPreference WHERE intDeferredRevenueAccountId IS NOT NULL AND intDeferredRevenueAccountId <> 0)

DECLARE @ErrorMerssage NVARCHAR(MAX)

SET @recapId = '1'
SET @success = 1

DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33

SELECT	@INVENTORY_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType 
WHERE	strName = @SCREEN_NAME

DECLARE @ZeroDecimal decimal(18,6)
SET @ZeroDecimal = 0.000000	

-- Ensure @post and @recap is not NULL  
SET @post = ISNULL(@post, 0)
SET @recap = ISNULL(@recap, 0)  
 
-- Get Transaction to Post
IF (@transType IS NULL OR RTRIM(LTRIM(@transType)) = '')
	SET @transType = 'all'

IF (@param IS NOT NULL) 
	BEGIN
		IF(@param = 'all')
		BEGIN
			INSERT INTO @PostInvoiceData SELECT intInvoiceId, strInvoiceNumber FROM tblARInvoice WHERE ysnPosted = 0 AND (strTransactionType = @transType OR @transType = 'all')
		END
		ELSE
		BEGIN
			INSERT INTO @PostInvoiceData SELECT intInvoiceId, strInvoiceNumber FROM tblARInvoice WHERE intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@param))
		END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData
		SELECT intInvoiceId, strInvoiceNumber FROM tblARInvoice
		WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate
		AND (strTransactionType = @transType OR @transType = 'all')
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData
		SELECT intInvoiceId, strInvoiceNumber FROM tblARInvoice
		WHERE intInvoiceId BETWEEN @beginTransaction AND @endTransaction
		AND (strTransactionType = @transType OR @transType = 'all')
	END

--Removed excluded Invoices to post/unpost
IF(@exclude IS NOT NULL)
	BEGIN
		DECLARE @InvoicesExclude TABLE  (
			intInvoiceId INT
		);

		INSERT INTO @InvoicesExclude
		SELECT intID FROM fnGetRowsFromDelimitedValues(@exclude)


		DELETE FROM A
		FROM @PostInvoiceData A
		WHERE EXISTS(SELECT * FROM @InvoicesExclude B WHERE A.intInvoiceId = B.intInvoiceId)
	END
	
---- Get the next batch number
--IF(@batchId IS NULL AND @param IS NOT NULL AND @param <> 'all')
--	BEGIN
--		SELECT TOP 1
--			@batchId = GL.strBatchId
--		FROM
--			tblGLDetailRecap GL
--		INNER JOIN 
--			@PostInvoiceData I
--				ON GL.intTransactionId = I.intInvoiceId 
--				AND GL.strTransactionId = I.strTransactionId
--		WHERE
--			GL.strTransactionType IN ('Credit Memo', 'Invoice', 'Overpayment', 'Prepayment')
--			AND	GL.strModuleName = @MODULE_NAME
--	END

IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId


--Process Split Invoice
BEGIN TRY
	IF @post = 1 AND @recap = 0
	BEGIN
		DECLARE @SplitInvoiceData TABLE(intInvoiceId INT)

		INSERT INTO @SplitInvoiceData
		SELECT intInvoiceId FROM tblARInvoice 
		WHERE ysnSplitted = 0 
		  AND ISNULL(intSplitId, 0) > 0
		  AND intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)

		IF(SELECT COUNT(*) FROM @SplitInvoiceData) > 0
			BEGIN
				WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
					BEGIN
						DECLARE @invoicesToAdd NVARCHAR(MAX) = NULL, @intSplitInvoiceId INT

						SELECT TOP 1 @intSplitInvoiceId = intInvoiceId FROM @SplitInvoiceData ORDER BY intInvoiceId

						EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @userId, @invoicesToAdd OUT

						DELETE FROM @PostInvoiceData WHERE intInvoiceId = @intSplitInvoiceId

						IF (ISNULL(@invoicesToAdd, '') <> '')
							BEGIN
								INSERT INTO @PostInvoiceData 
								SELECT intInvoiceId, strInvoiceNumber FROM tblARInvoice 
								WHERE ysnPosted = 0 
								  AND intInvoiceId IN (SELECT intID FROM fnGetRowsFromDelimitedValues(@invoicesToAdd))


								EXEC uspARReComputeInvoiceAmounts @intSplitInvoiceId

								DECLARE @AddedInvoices AS [dbo].[Id]
								INSERT INTO @AddedInvoices([intId])
								SELECT intID FROM fnGetRowsFromDelimitedValues(@invoicesToAdd)
								DECLARE @AddedInvoiceId INT

								WHILE EXISTS (SELECT NULL FROM @AddedInvoices)
									BEGIN
										SELECT @AddedInvoiceId = [intId] FROM @AddedInvoices

										EXEC uspARReComputeInvoiceAmounts @AddedInvoiceId

										DELETE FROM @AddedInvoices WHERE [intId] = @AddedInvoiceId
									END
							END

						DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
					END
			END
	END
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			ROLLBACK TRANSACTION							
			BEGIN TRANSACTION
			--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			--SELECT @ErrorMerssage, @transType, @param, @batchId, 0							
			EXEC uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param							
			COMMIT TRANSACTION
			--COMMIT TRAN @TransactionName
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH


--------------------------------------------------------------------------------------------  
-- Validations  
----------------------------------------------------------------------------------------------  
--IF @recap = 0
--	BEGIN
		--Posting
		IF @post = 1
			BEGIN
				-- Tank consumption site
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType,strTransactionId, strBatchNumber, intTransactionId)
				SELECT TOP 1 
					'Unable to find a tank consumption site for item no. ' + item.strItemNo,
					invoice.strTransactionType,
					invoice.strInvoiceNumber,
					@batchId,
					invoice.intInvoiceId
				from tblARInvoice invoice 
				INNER JOIN @PostInvoiceData B ON invoice.intInvoiceId = B.intInvoiceId
				INNER JOIN tblARInvoiceDetail detail on invoice.intInvoiceId = detail.intInvoiceId
				INNER JOIN tblICItem item on item.intItemId = detail.intItemId
				WHERE detail.intSiteId is null
				AND item.ysnTankRequired = 1 
				AND invoice.strType = 'Tank Delivery' 
				

				--Fiscal Year
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					ISNULL(dbo.isOpenAccountingDate(ISNULL(A.dtmPostDate, A.dtmDate)), 0) = 0

				--zero amount
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'You cannot post an ' + A.strTransactionType + ' with zero amount.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId				
				WHERE  
					A.dblInvoiceTotal = 0.00			
					AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE tblARInvoiceDetail.dblTotal <> @ZeroDecimal AND tblARInvoiceDetail.intInvoiceId = A.intInvoiceId)		
					
					
				--negative amount
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'You cannot post an ' + A.strTransactionType + ' with negative amount.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					A.dblInvoiceTotal < 0.00
				
				--UOM is required
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'UOM is required for item ' + Detail.strItemDescription + '.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId					
				FROM 
					tblARInvoiceDetail Detail
				INNER JOIN
					tblARInvoice A
						ON Detail.intInvoiceId = A.intInvoiceId
						AND A.strTransactionType = 'Invoice'
				INNER JOIN
					@PostInvoiceData P
						ON A.intInvoiceId = P.intInvoiceId	
				LEFT OUTER JOIN
					vyuICGetItemStock IST
						ON Detail.intItemId = IST.intItemId 
						AND A.intCompanyLocationId = IST.intLocationId 
				WHERE 
					(Detail.intItemUOMId IS NULL OR Detail.intItemUOMId = 0) 
					AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)
					AND (Detail.intSalesOrderDetailId IS NULL OR Detail.intSalesOrderDetailId = 0)
					AND (Detail.intShipmentPurchaseSalesContractId IS NULL OR Detail.intShipmentPurchaseSalesContractId = 0)
					AND (Detail.intItemId IS NOT NULL OR Detail.intItemId <> 0)
					AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
					
				--Dsicount Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'Receivable Discount account was not set up for item ' + IT.strItemNo,
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId					
				FROM 
					tblARInvoiceDetail Detail
				INNER JOIN
					tblARInvoice A
						ON Detail.intInvoiceId = A.intInvoiceId
				INNER JOIN
					@PostInvoiceData P
						ON A.intInvoiceId = P.intInvoiceId	
				LEFT OUTER JOIN
					vyuARGetItemAccount IST
						ON Detail.intItemId = IST.intItemId 
						AND A.intCompanyLocationId = IST.intLocationId 
				LEFT OUTER JOIN
					tblICItem IT
						ON Detail.intItemId = IT.intItemId
				WHERE 
					((IST.intDiscountAccountId IS NULL OR IST.intDiscountAccountId = 0) AND  (@DiscountAccountId IS NULL OR @DiscountAccountId = 0)) 
					AND Detail.dblDiscount <> 0					

				--Currency is required
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'No currency has been specified.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					ISNULL(A.intCurrencyId, 0) = 0

				--No Terms specified
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'No terms has been specified.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					0 = A.intTermId

				--NOT BALANCE
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'The debit and credit amounts are not balanced.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					A.dblInvoiceTotal <> ((SELECT SUM(dblTotal) FROM tblARInvoiceDetail WHERE intInvoiceId = A.intInvoiceId) + ISNULL(A.dblShipping,0.0) + ISNULL(A.dblTax,0.0))

				--ALREADY POSTED
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'The transaction is already posted.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					A.ysnPosted = 1

				--Header Account ID
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The AR account is not specified.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					A.intAccountId IS NULL 
					OR A.intAccountId = 0
					
				--Company Location
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'Company location of ' + A.strInvoiceNumber + ' was not set.'
					,A.strTransactionType
					,A.strInvoiceNumber
					,@batchId
					,A.intInvoiceId
				FROM
					tblARInvoice A
				INNER JOIN
					@PostInvoiceData P
						ON A.intInvoiceId = P.intInvoiceId						 
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intCompanyLocationId = L.intCompanyLocationId
				WHERE L.intCompanyLocationId IS NULL
				
				--Freight Expenses Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'The Freight Income account of Company Location ' + L.strLocationName + ' was not set.'
					,A.strTransactionType
					,A.strInvoiceNumber
					,@batchId
					,A.intInvoiceId
				FROM
					tblARInvoice A
				INNER JOIN
					@PostInvoiceData P
						ON A.intInvoiceId = P.intInvoiceId						 
				INNER JOIN
					tblSMCompanyLocation L
						ON A.intCompanyLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN
					tblGLAccount G
						ON L.intFreightIncome = G.intAccountId						
				WHERE
					G.intAccountId IS NULL	
					AND A.dblShipping <> 0.0	
				
				--Service Charge Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Service Charge account in the Company Configuration was not set.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				WHERE
					(D.intAccountId IS NULL OR D.intAccountId = 0)
					AND (D.intItemId IS NULL OR D.intItemId = 0)
					AND (@ServiceChargesAccountId IS NULL OR @ServiceChargesAccountId = 0)
					AND D.dblTotal <> @ZeroDecimal

				-- Accrual Not in Fiscal Year					
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					A.strInvoiceNumber + ' has an Accrual setup up to ' + CONVERT(NVARCHAR(30),DATEADD(mm, (ISNULL(A.intPeriodsToAccrue,1) - 1), ISNULL(A.dtmPostDate, A.dtmDate)), 101) + ' which does not fall into a valid Fiscal Period.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE
					ISNULL(A.intPeriodsToAccrue,0) > 1  
					AND ISNULL(dbo.isOpenAccountingDate(DATEADD(mm, (ISNULL(A.intPeriodsToAccrue,1) - 1), ISNULL(A.dtmPostDate, A.dtmDate))), 0) = 0

				--Service Deferred Revenue Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Deferred Revenue account in the Company Configuration was not set.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE
					ISNULL(A.intPeriodsToAccrue,0) > 1
					AND (@DeferredRevenueAccountId IS NULL OR @DeferredRevenueAccountId = 0)

				--Invoice for accrual with Inventory Items				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'Invoice : ' + A.strInvoiceNumber + ' is for accrual and must not include an inventory item : ' + I.strItemNo + '.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId	 				
				WHERE
					ISNULL(A.intPeriodsToAccrue,0) > 1
					AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
								
				--General Account				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The General Account of item - ' + I.strItemNo + ' was not specified.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intCompanyLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN
					vyuARGetItemAccount Acct
						ON A.intCompanyLocationId = Acct.intLocationId 
						AND D.intItemId = Acct.intItemId 		 				
				WHERE
					(Acct.intGeneralAccountId IS NULL OR Acct.intGeneralAccountId = 0)
					AND I.strType IN ('Non-Inventory','Service')
					
				--Software - Maintenance Sales / General Account				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Maintenance Sales and General Accounts of item - ' + I.strItemNo + ' were not specified.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intCompanyLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN
					vyuARGetItemAccount Acct
						ON A.intCompanyLocationId = Acct.intLocationId 
						AND D.intItemId = Acct.intItemId 		 				
				WHERE
					ISNULL(ISNULL(Acct.intMaintenanceSalesAccountId, Acct.intGeneralAccountId), 0) = 0
					AND I.strType = 'Software'				
					
				--Other Charge Income Account	
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Other Charge Income Account of item - ' + I.strItemNo + ' was not specified.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId
				LEFT OUTER JOIN
					tblSMCompanyLocation L
						ON A.intCompanyLocationId = L.intCompanyLocationId
				LEFT OUTER JOIN
					vyuARGetItemAccount Acct
						ON A.intCompanyLocationId = Acct.intLocationId 
						AND D.intItemId = Acct.intItemId 		 				
				WHERE
					(Acct.intOtherChargeIncomeAccountId IS NULL OR Acct.intOtherChargeIncomeAccountId = 0)
					AND I.strType = 'Other Charge'	
					
				
				--Zero Contract Item Price	
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The contract item - ' + I.strItemNo + ' price can not be of zero value.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId
				INNER JOIN
					vyuCTContractDetailView CT
						ON D.intContractHeaderId = CT.intContractHeaderId 
						AND D.intContractDetailId = CT.intContractDetailId 		 				
				WHERE
					D.dblPrice = @ZeroDecimal
					AND CT.strPricingType <> 'Index'
					
				--Contract Item Price not Equal to Contract Sequence Cash Price
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The contract item - ' + I.strItemNo + ' price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(D.dblPrice,@ZeroDecimal) AS MONEY),2) + ') is not equal to the contract sequence cash price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(CT.dblCashPrice,@ZeroDecimal) AS MONEY),2) + ').',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				INNER JOIN
					tblARInvoiceDetail D
						ON A.intInvoiceId = D.intInvoiceId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId
				INNER JOIN
					vyuCTContractDetailView CT
						ON D.intContractHeaderId = CT.intContractHeaderId 
						AND D.intContractDetailId = CT.intContractDetailId 		 				
				WHERE
					D.dblPrice <> @ZeroDecimal				
					AND ISNULL(CT.dblCashPrice,0.00) <> D.dblPrice 
					AND CT.strPricingType <> 'Index'
					
					
				BEGIN TRY
					DECLARE @TankDelivery TABLE (
							intInvoiceId INT,
							UNIQUE (intInvoiceId));
							
					INSERT INTO @TankDelivery					
					SELECT DISTINCT
						I.intInvoiceId
					FROM
						tblARInvoice I
					INNER JOIN
						tblARInvoiceDetail D
							ON I.intInvoiceId = D.intInvoiceId		
					INNER JOIN
						tblTMSite TMS
							ON D.intSiteId = TMS.intSiteID 
					INNER JOIN 
						@PostInvoiceData B
							ON I.intInvoiceId = B.intInvoiceId
							
					WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDelivery ORDER BY intInvoiceId)
						BEGIN
						
							DECLARE  @intInvoiceId INT
									,@ResultLog NVARCHAR(MAX)
									
							SET @ResultLog = 'OK'
							
							SELECT TOP 1 @intInvoiceId = intInvoiceId FROM @TankDelivery ORDER BY intInvoiceId

							EXEC dbo.uspTMValidateInvoiceForSync @intInvoiceId, @ResultLog OUT
											
							DELETE FROM @TankDelivery WHERE intInvoiceId = @intInvoiceId
							
							IF NOT(@ResultLog = 'OK' OR RTRIM(LTRIM(@ResultLog)) = '')
								BEGIN
									INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
									SELECT
										@ResultLog,
										A.strTransactionType,
										A.strInvoiceNumber,
										@batchId,
										A.intInvoiceId
									FROM 
										tblARInvoice A 
									INNER JOIN 
										@PostInvoiceData B
											ON A.intInvoiceId = B.intInvoiceId
									WHERE
										A.intInvoiceId = @intInvoiceId									
								END														
						END 							
							
															
				END TRY
				BEGIN CATCH
					SELECT @ErrorMerssage = ERROR_MESSAGE()					
					IF @raiseError = 0
						BEGIN
							ROLLBACK TRANSACTION							
							BEGIN TRANSACTION
							--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
							--SELECT @ErrorMerssage, @transType, @param, @batchId, 0							
							EXEC uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param							
							COMMIT TRANSACTION
							--COMMIT TRAN @TransactionName
						END						
					IF @raiseError = 1
						RAISERROR(@ErrorMerssage, 11, 1)
						
					GOTO Post_Exit
				END CATCH


			END 

		--unposting
		IF @post = 0 And @recap = 0
			BEGIN
				--ALREADY HAVE PAYMENTS
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					A.strRecordNumber + ' payment was already made on this ' + C.strTransactionType + '.',
					C.strTransactionType,
					C.strInvoiceNumber,
					@batchId,
					C.intInvoiceId
				FROM
					tblARPayment A
				INNER JOIN 
					tblARPaymentDetail B 
						ON A.intPaymentId = B.intPaymentId
				INNER JOIN 
					tblARInvoice C
						ON B.intInvoiceId = C.intInvoiceId
				INNER JOIN 
					@PostInvoiceData D
						ON C.intInvoiceId = D.intInvoiceId

				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE
					ISNULL(dbo.isOpenAccountingDate(ISNULL(A.dtmPostDate, A.dtmDate)), 0) = 0
					
				--NOT POSTED
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'The transaction has not been posted yet.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				WHERE  
					A.ysnPosted = 0

			END			
		
		SELECT @totalInvalid = COUNT(*) FROM @InvalidInvoiceData

		IF(@totalInvalid > 0)
			BEGIN

				--Insert Invalid Post transaction result
				INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 	
					strError
					,strTransactionType
					,strTransactionId
					,strBatchNumber
					,intTransactionId
				FROM
					@InvalidInvoiceData

				SET @invalidCount = @totalInvalid

				--DELETE Invalid Transaction From temp table
				DELETE @PostInvoiceData
					FROM @PostInvoiceData A
						INNER JOIN @InvalidInvoiceData B
							ON A.intInvoiceId = B.intTransactionId
				
				IF @raiseError = 1
					BEGIN
						SELECT TOP 1 @ErrorMerssage = strError FROM @InvalidInvoiceData
						RAISERROR(@ErrorMerssage, 11, 1)							
						GOTO Post_Exit
					END					
			END

		SELECT @totalRecords = COUNT(*) FROM @PostInvoiceData
			
		IF(@totalInvalid >= 1 AND @totalRecords <= 0)
			BEGIN
				IF @raiseError = 0 
					COMMIT TRANSACTION
					--COMMIT TRAN @TransactionName
				IF @raiseError = 1
					BEGIN
						SELECT TOP 1 @ErrorMerssage = strError FROM @InvalidInvoiceData
						RAISERROR(@ErrorMerssage, 11, 1)							
						GOTO Post_Exit
					END				
				GOTO Post_Exit	
			END

	--END


--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
--BEGIN TRAN @TransactionName
if @recap = 1 AND @raiseError = 0
	SAVE TRAN @TransactionName

--------------------------------------------------------------------------------------------  
-- If POST, call the post routines  
--------------------------------------------------------------------------------------------  
IF @post = 1  
	BEGIN  
	
		BEGIN TRY	
			-- Get the items to post  
			DECLARE @ItemsForPost AS ItemCostingTableType  
			INSERT INTO @ItemsForPost (  
				intItemId  
				,intItemLocationId 
				,intItemUOMId  
				,dtmDate  
				,dblQty  
				,dblUOMQty  
				,dblCost  
				,dblSalesPrice  
				,intCurrencyId  
				,dblExchangeRate  
				,intTransactionId 
				,intTransactionDetailId
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
				,strActualCostId
			) 
			SELECT 
				Detail.intItemId  
				,IST.intItemLocationId
				,Detail.intItemUOMId  
				,Header.dtmShipDate
				,Detail.dblQtyShipped * (CASE WHEN Header.strTransactionType = 'Invoice' THEN -1 ELSE 1 END)
				,ItemUOM.dblUnitQty
				,IST.dblLastCost
				,Detail.dblPrice 
				,Header.intCurrencyId
				,1.00
				,Header.intInvoiceId
				,Detail.intInvoiceDetailId
				,Header.strInvoiceNumber 
				,@INVENTORY_INVOICE_TYPE
				,NULL 
				,NULL
				,NULL
				,strActualCostId = Header.strActualCostId
			FROM 
				tblARInvoiceDetail Detail
			INNER JOIN
				tblARInvoice Header
					ON Detail.intInvoiceId = Header.intInvoiceId
					AND Header.strTransactionType  IN ('Invoice', 'Credit Memo')
					AND ISNULL(Header.intPeriodsToAccrue,0) <= 1
			INNER JOIN
				@PostInvoiceData P
					ON Header.intInvoiceId = P.intInvoiceId	
			INNER JOIN
				tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT OUTER JOIN
				vyuICGetItemStock IST
					ON Detail.intItemId = IST.intItemId 
					AND Header.intCompanyLocationId = IST.intLocationId 
			WHERE
				Detail.dblTotal <> @ZeroDecimal
				AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)
				AND (Detail.intSalesOrderDetailId IS NULL OR Detail.intSalesOrderDetailId = 0)
				AND (Detail.intShipmentPurchaseSalesContractId IS NULL OR Detail.intShipmentPurchaseSalesContractId = 0)
				AND Detail.intItemId IS NOT NULL AND Detail.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
				AND Header.strType <> 'Debit Memo'

			
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
	  
		-- Call the post routine 
		BEGIN TRY 
			-- Call the post routine 
			INSERT INTO @GLEntries (
				[dtmDate] 
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]
				,[strTransactionId]
				,[intTransactionId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
				,[intConcurrencyId]
				,[dblDebitForeign]
				,[dblDebitReport]
				,[dblCreditForeign]
				,[dblCreditReport]
				,[dblReportingRate]
				,[dblForeignRate]
			)
			EXEC	dbo.uspICPostCosting  
					@ItemsForPost  
					,@batchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@UserEntityID
					
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
		
		-- Accruals
		BEGIN TRY 
			DECLARE @Accruals AS Id
			INSERT INTO @Accruals(intId)
			SELECT I.intInvoiceId 
			FROM 
				tblARInvoice I 
			INNER JOIN 
				@PostInvoiceData IP 
					ON I.intInvoiceId = IP.intInvoiceId 
			WHERE ISNULL(I.intPeriodsToAccrue,0) > 1

			INSERT INTO @GLEntries 
			EXEC	dbo.uspARGenerateEntriesForAccrual  
						 @Invoices					= @Accruals
						,@DeferredRevenueAccountId	= @DeferredRevenueAccountId
						,@ServiceChargesAccountId	= @ServiceChargesAccountId
						,@BatchId					= @batchId
						,@Code						= @CODE
						,@UserId					= @userId
						,@UserEntityId				= @UserEntityID
						,@ScreenName				= @SCREEN_NAME
						,@ModuleName				= @MODULE_NAME

		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH		
		
		BEGIN TRY
			-- Call the post routine 
			INSERT INTO @GLEntries (
				[dtmDate] 
				,[strBatchId]
				,[intAccountId]
				,[dblDebit]
				,[dblCredit]
				,[dblDebitUnit]
				,[dblCreditUnit]
				,[strDescription]
				,[strCode]
				,[strReference]
				,[intCurrencyId]
				,[dblExchangeRate]
				,[dtmDateEntered]
				,[dtmTransactionDate]
				,[strJournalLineDescription]
				,[intJournalLineNo]
				,[ysnIsUnposted]
				,[intUserId]
				,[intEntityId]
				,[strTransactionId]
				,[intTransactionId]
				,[strTransactionType]
				,[strTransactionForm]
				,[strModuleName]
				,[intConcurrencyId]
			)
			--DEBIT Total
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  A.dblInvoiceTotal ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE A.dblInvoiceTotal END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																								(
																								SELECT
																									SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.00)))
																								FROM
																									tblARInvoiceDetail ARID 
																								INNER JOIN
																									tblARInvoice ARI
																										ON ARID.intInvoiceId = ARI.intInvoiceId	
																								LEFT OUTER JOIN
																									tblICItem I
																										ON ARID.intItemId = I.intItemId
																								LEFT OUTER JOIN
																									vyuARGetItemAccount IST
																										ON ARID.intItemId = IST.intItemId 
																										AND ARI.intCompanyLocationId = IST.intLocationId 
																								LEFT OUTER JOIN
																									vyuICGetItemStock ICIS
																										ON ARID.intItemId = ICIS.intItemId 
																										AND ARI.intCompanyLocationId = ICIS.intLocationId 
																								WHERE
																									ARI.intInvoiceId = A.intInvoiceId
																									AND ARID.dblTotal <> @ZeroDecimal  
																								)
																							ELSE 
																								0
																							END
				,dblCreditUnit				=  CASE WHEN A.strTransactionType = 'Invoice'	THEN  
																								0
																							ELSE 
																								(
																								SELECT
																									SUM(ISNULL([dbo].[fnCalculateQtyBetweenUOM](ARID.intItemUOMId, ICIS.intStockUOMId, ARID.dblQtyShipped),ISNULL(ARID.dblQtyShipped, 0.00)))
																								FROM
																									tblARInvoiceDetail ARID 
																								INNER JOIN
																									tblARInvoice ARI
																										ON ARID.intInvoiceId = ARI.intInvoiceId	
																								LEFT OUTER JOIN
																									tblICItem I
																										ON ARID.intItemId = I.intItemId
																								LEFT OUTER JOIN
																									vyuARGetItemAccount IST
																										ON ARID.intItemId = IST.intItemId 
																										AND ARI.intCompanyLocationId = IST.intLocationId 
																								LEFT OUTER JOIN
																									vyuICGetItemStock ICIS
																										ON ARID.intItemId = ICIS.intItemId 
																										AND ARI.intCompanyLocationId = ICIS.intLocationId 
																								WHERE
																									ARI.intInvoiceId = A.intInvoiceId
																									AND ARID.dblTotal <> @ZeroDecimal  
																								)
																							END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1				 
			FROM
				tblARInvoice A
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
					
			--CREDIT MISC
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service'))) 
													THEN
														IST.intGeneralAccountId
													WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType = 'Software')) 
													THEN
														ISNULL(IST.intMaintenanceSalesAccountId, IST.intGeneralAccountId)
													WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType = 'Other Charge')) 
													THEN
														IST.intOtherChargeIncomeAccountId
													ELSE
														(CASE WHEN B.intServiceChargeAccountId IS NOT NULL AND B.intServiceChargeAccountId <> 0 THEN B.intServiceChargeAccountId ELSE @ServiceChargesAccountId END)
												END)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00)))  END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) ELSE 0  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, 0.00)) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, 0.00)) ELSE 0 END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1	
			FROM
				tblARInvoiceDetail B
			INNER JOIN
				tblARInvoice A 
					ON B.intInvoiceId = A.intInvoiceId					
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId		
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON B.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId
			LEFT OUTER JOIN
				vyuICGetItemStock ICIS
					ON B.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId 						
			WHERE
				B.dblTotal <> @ZeroDecimal 
				AND ((B.intItemId IS NULL OR B.intItemId = 0)
					OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
				AND A.strType <> 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT SALES
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) ELSE 0 END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1	
			FROM
				tblARInvoiceDetail B
			INNER JOIN
				tblARInvoice A 
					ON B.intInvoiceId = A.intInvoiceId					
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId			
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
				tblICItem I
					ON B.intItemId = I.intItemId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON B.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			LEFT OUTER JOIN
				vyuICGetItemStock ICIS
					ON B.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId 
			WHERE
				B.dblTotal <> @ZeroDecimal  
				AND (B.intItemId IS NOT NULL OR B.intItemId <> 0)
				AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
				AND A.strType <> 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT SALES - Debit Memo
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) ELSE 0 END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= B.strItemDescription 
				,intJournalLineNo			= B.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1	
			FROM
				tblARInvoiceDetail B
			INNER JOIN
				tblARInvoice A 
					ON B.intInvoiceId = A.intInvoiceId					
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId			
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				tblICItem I
					ON B.intItemId = I.intItemId
			LEFT OUTER JOIN
				vyuICGetItemStock ICIS
					ON B.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId 
			WHERE
				B.dblTotal <> @ZeroDecimal  
				AND A.strType = 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT Shipping
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= L.intFreightIncome
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE A.dblShipping END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN A.dblShipping ELSE 0  END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
				,intJournalLineNo			= A.intInvoiceId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoice A 
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId	
			INNER JOIN
				tblSMCompanyLocation L
					ON A.intCompanyLocationId = L.intCompanyLocationId	
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId	
			WHERE
				A.dblShipping <> @ZeroDecimal		
				
		UNION ALL 
			--CREDIT Tax
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE DT.dblAdjustedTax END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN DT.dblAdjustedTax ELSE 0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
				,intJournalLineNo			= DT.intInvoiceDetailTaxId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoiceDetailTax DT
			INNER JOIN
				tblARInvoiceDetail D
					ON DT.intInvoiceDetailId = D.intInvoiceDetailId
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
			INNER JOIN
				tblARCustomer C
					ON A.intEntityCustomerId = C.intEntityCustomerId
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId				
			LEFT OUTER JOIN
				tblSMTaxCode TC
					ON DT.intTaxCodeId = TC.intTaxCodeId	
			WHERE
				DT.dblAdjustedTax <> @ZeroDecimal
				
			UNION ALL 
			--DEBIT Discount
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Posted ' + A.strTransactionType 
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON D.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			INNER JOIN
				tblARCustomer C
					ON A.intEntityCustomerId = C.intEntityCustomerId
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId					
			WHERE
				((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) <> @ZeroDecimal


			UNION ALL 
			--DEBIT COGS - SHIPPED
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intCOGSAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN (ABS(ICT.dblQty) * ICT.dblCost) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblCost) END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (ABS(ICT.dblQty) * ICT.dblUOMQty) ELSE 0 END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblUOMQty) END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= D.strItemDescription
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= @SCREEN_NAME
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
					AND ISNULL(A.intPeriodsToAccrue,0) <= 1
			INNER JOIN
			tblICItemUOM ItemUOM 
				ON ItemUOM.intItemUOMId = D.intItemUOMId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON D.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			INNER JOIN
				tblARCustomer C
					ON A.intEntityCustomerId = C.intEntityCustomerId					
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId				
			INNER JOIN
				tblICInventoryShipmentItem ISD
					ON 	D.intInventoryShipmentItemId = ISD.intInventoryShipmentItemId
			INNER JOIN
				tblICInventoryShipment ISH
					ON ISD.intInventoryShipmentId = ISH.intInventoryShipmentId
			INNER JOIN
				tblICInventoryTransaction ICT
					ON ISD.intInventoryShipmentItemId = ICT.intTransactionDetailId 
					AND ISH.intInventoryShipmentId = ICT.intTransactionId
					AND ISH.strShipmentNumber = ICT.strTransactionId
					AND ISNULL(ICT.ysnIsUnposted,0) = 0
			WHERE
				D.dblTotal <> @ZeroDecimal
				AND D.intInventoryShipmentItemId IS NOT NULL AND D.intInventoryShipmentItemId <> 0
				--AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
				AND A.strType <> 'Debit Memo'
				
			UNION ALL 
			--CREDIT Inventory In-Transit - SHIPPED
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intInventoryInTransitAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblCost) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN (ABS(ICT.dblQty) * ICT.dblCost) ELSE 0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblUOMQty) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN (ABS(ICT.dblQty) * ICT.dblUOMQty) ELSE 0 END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= D.strItemDescription
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= @SCREEN_NAME
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
					AND ISNULL(A.intPeriodsToAccrue,0) <= 1
			INNER JOIN
				tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = D.intItemUOMId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON D.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			INNER JOIN
				tblARCustomer C
					ON A.intEntityCustomerId = C.intEntityCustomerId					
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId				
			INNER JOIN
				tblICInventoryShipmentItem ISD
					ON 	D.intInventoryShipmentItemId = ISD.intInventoryShipmentItemId
			INNER JOIN
				tblICInventoryShipment ISH
					ON ISD.intInventoryShipmentId = ISH.intInventoryShipmentId
			INNER JOIN
				tblICInventoryTransaction ICT
					ON ISD.intInventoryShipmentItemId = ICT.intTransactionDetailId 
					AND ISH.intInventoryShipmentId = ICT.intTransactionId
					AND ISH.strShipmentNumber = ICT.strTransactionId
					AND ISNULL(ICT.ysnIsUnposted,0) = 0 
			WHERE
				D.dblTotal <> @ZeroDecimal
				AND D.intInventoryShipmentItemId IS NOT NULL AND D.intInventoryShipmentItemId <> 0
				--AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
				AND A.strType <> 'Debit Memo'	
				
			UNION ALL 
			--DEBIT COGS - Inbound Shipment
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intCOGSAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN (ICT.dblCashPrice * D.dblQtyShipped) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE (ICT.dblCashPrice * D.dblQtyShipped) END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) ELSE 0 END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= D.strItemDescription
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
					AND ISNULL(A.intPeriodsToAccrue,0) <= 1
			INNER JOIN
				tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = D.intItemUOMId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON D.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			INNER JOIN
				tblARCustomer C
					ON A.intEntityCustomerId = C.intEntityCustomerId					
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId				
			INNER JOIN
				vyuLGDropShipmentDetails ISD
					ON 	D.intShipmentPurchaseSalesContractId = ISD.intShipmentPurchaseSalesContractId
			INNER JOIN
				vyuLGShipmentHeader ISH
					ON ISD.intShipmentId = ISH.intShipmentId
			INNER JOIN
				vyuCTContractDetailView ICT
					ON ISD.intPContractDetailId = ICT.intContractDetailId  
			LEFT OUTER JOIN
				vyuICGetItemStock ICIS
					ON D.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId 
			WHERE
				D.dblTotal <> @ZeroDecimal
				AND D.intShipmentPurchaseSalesContractId IS NOT NULL AND D.intShipmentPurchaseSalesContractId <> 0
				--AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
				AND A.strType <> 'Debit Memo'
				
			UNION ALL 
			--CREDIT Inventory In-Transit - Inbound Shipment
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intInventoryInTransitAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE (ICT.dblCashPrice * D.dblQtyShipped) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN (ICT.dblCashPrice * D.dblQtyShipped) ELSE 0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType = 'Invoice' THEN [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) ELSE 0 END				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= D.strItemDescription
				,intJournalLineNo			= D.intInvoiceDetailId
				,ysnIsUnposted				= 0
				,intUserId					= @userId
				,intEntityId				= @UserEntityID				
				,strTransactionId			= A.strInvoiceNumber
				,intTransactionId			= A.intInvoiceId
				,strTransactionType			= A.strTransactionType
				,strTransactionForm			= @SCREEN_NAME
				,strModuleName				= @MODULE_NAME
				,intConcurrencyId			= 1
			FROM
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
					AND ISNULL(A.intPeriodsToAccrue,0) <= 1
			INNER JOIN
				tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = D.intItemUOMId
			LEFT OUTER JOIN
				vyuARGetItemAccount IST
					ON D.intItemId = IST.intItemId 
					AND A.intCompanyLocationId = IST.intLocationId 
			INNER JOIN
				tblARCustomer C
					ON A.intEntityCustomerId = C.intEntityCustomerId					
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId				
			INNER JOIN
				vyuLGDropShipmentDetails ISD
					ON 	D.intShipmentPurchaseSalesContractId = ISD.intShipmentPurchaseSalesContractId
			INNER JOIN
				vyuLGShipmentHeader ISH
					ON ISD.intShipmentId = ISH.intShipmentId
			INNER JOIN
				vyuCTContractDetailView ICT
					ON ISD.intPContractDetailId = ICT.intContractDetailId  
			LEFT OUTER JOIN
				vyuICGetItemStock ICIS
					ON D.intItemId = ICIS.intItemId 
					AND A.intCompanyLocationId = ICIS.intLocationId 
			WHERE
				D.dblTotal <> @ZeroDecimal
				AND D.intShipmentPurchaseSalesContractId IS NOT NULL AND D.intShipmentPurchaseSalesContractId <> 0
				--AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
				AND A.strType <> 'Debit Memo'
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

	END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @post = 0   
	BEGIN
	
		BEGIN TRY
			INSERT INTO @GLEntries(
				 dtmDate
				,strBatchId
				,intAccountId
				,dblDebit
				,dblCredit
				,dblDebitUnit
				,dblCreditUnit
				,strDescription
				,strCode
				,strReference
				,intCurrencyId
				,dblExchangeRate
				,dtmDateEntered
				,dtmTransactionDate
				,strJournalLineDescription
				,intJournalLineNo
				,ysnIsUnposted
				,intUserId
				,intEntityId
				,strTransactionId
				,intTransactionId
				,strTransactionType
				,strTransactionForm
				,strModuleName
				,intConcurrencyId
			)
			SELECT	
				 GL.dtmDate 
				,@batchId
				,GL.intAccountId
				,dblDebit						= GL.dblCredit
				,dblCredit						= GL.dblDebit
				,dblDebitUnit					= GL.dblCreditUnit
				,dblCreditUnit					= GL.dblDebitUnit
				,GL.strDescription
				,GL.strCode
				,GL.strReference
				,GL.intCurrencyId
				,GL.dblExchangeRate
				,dtmDateEntered					= GETDATE()
				,GL.dtmTransactionDate
				,GL.strJournalLineDescription
				,GL.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @userId
				,intEntityId					= @UserEntityID
				,GL.strTransactionId
				,GL.intTransactionId
				,GL.strTransactionType
				,GL.strTransactionForm
				,GL.strModuleName
				,GL.intConcurrencyId
			FROM
				tblGLDetail GL
			INNER JOIN
				@PostInvoiceData P
					ON GL.intTransactionId = P.intInvoiceId 
					AND GL.strTransactionId = P.strTransactionId
			WHERE
				GL.ysnIsUnposted = 0
				--AND GL.strCode = 'AR'
			ORDER BY
				GL.intGLDetailId		
						
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH	  
		
		BEGIN TRY			
			DECLARE @UnPostInvoiceData TABLE  (
				intInvoiceId int PRIMARY KEY,
				strTransactionId NVARCHAR(50) COLLATE Latin1_General_CI_AS,
				UNIQUE (intInvoiceId)
			);
			
			INSERT INTO @UnPostInvoiceData(intInvoiceId, strTransactionId)
			SELECT DISTINCT
				 P.intInvoiceId
				,P.strTransactionId
			FROM
				tblARInvoiceDetail Detail
			INNER JOIN
				tblARInvoice Header
					ON Detail.intInvoiceId = Header.intInvoiceId
					AND  Header.strTransactionType IN ('Invoice', 'Credit Memo')
			INNER JOIN
				@PostInvoiceData P
					ON Header.intInvoiceId = P.intInvoiceId	
			INNER JOIN
				tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = Detail.intItemUOMId
			LEFT OUTER JOIN
				vyuICGetItemStock IST
					ON Detail.intItemId = IST.intItemId 
					AND Header.intCompanyLocationId = IST.intLocationId 
			WHERE 
				(Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)
				AND (Detail.intSalesOrderDetailId IS NULL OR Detail.intSalesOrderDetailId = 0)
				--AND (Detail.intShipmentPurchaseSalesContractId IS NULL OR Detail.intShipmentPurchaseSalesContractId = 0)
				AND (Detail.intItemId IS NOT NULL OR Detail.intItemId <> 0)
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')

			WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostInvoiceData ORDER BY intInvoiceId)
				BEGIN
				
					DECLARE @intTransactionId INT
							,@strTransactionId NVARCHAR(80);
					
					SELECT TOP 1 @intTransactionId = intInvoiceId, @strTransactionId = strTransactionId FROM @UnPostInvoiceData ORDER BY intInvoiceId

					-- Call the post routine 
					--INSERT INTO @GLEntries (
					--	 dtmDate
					--	,strBatchId
					--	,intAccountId
					--	,dblDebit
					--	,dblCredit
					--	,dblDebitUnit
					--	,dblCreditUnit
					--	,strDescription
					--	,strCode
					--	,strReference
					--	,intCurrencyId
					--	,dblExchangeRate
					--	,dtmDateEntered
					--	,dtmTransactionDate
					--	,strJournalLineDescription
					--	,intJournalLineNo
					--	,ysnIsUnposted
					--	,intUserId
					--	,intEntityId
					--	,strTransactionId
					--	,intTransactionId
					--	,strTransactionType
					--	,strTransactionForm
					--	,strModuleName
					--	,intConcurrencyId
					--)
					EXEC	dbo.uspICUnpostCosting
							@intTransactionId
							,@strTransactionId
							,@batchId
							,@UserEntityID
							,@recap 
										
					DELETE FROM @UnPostInvoiceData WHERE intInvoiceId = @intTransactionId AND strTransactionId = @strTransactionId 
												
				END							 
																
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH										
				
	END   

--------------------------------------------------------------------------------------------  
-- If RECAP is TRUE, 
-- 1.	Store all the GL entries in a holding table. It will be used later as data  
--		for the recap screen.
--
-- 2.	Rollback the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 1		
	BEGIN
		IF @raiseError = 0
			ROLLBACK TRAN @TransactionName

		DELETE tblGLDetailRecap  
		FROM 
			tblGLDetailRecap A 
		INNER JOIN @PostInvoiceData B  
		   ON (A.strTransactionId = B.strTransactionId OR A.intTransactionId = B.intInvoiceId)  
		   AND  A.strCode = @CODE  
		   
		   
		BEGIN TRY		
			INSERT INTO tblGLDetailRecap (  
			  [dtmDate]  
			  ,[strBatchId]  
			  ,[intAccountId]  
			  ,[dblDebit]  
			  ,[dblCredit]  
			  ,[dblDebitUnit]  
			  ,[dblCreditUnit]  
			  ,[strDescription]  
			  ,[strCode]  
			  ,[strReference]  
			  ,[intCurrencyId]  
			  ,[dblExchangeRate]  
			  ,[dtmDateEntered]  
			  ,[dtmTransactionDate]  
			  ,[strJournalLineDescription]  
			  ,[intJournalLineNo]  
			  ,[ysnIsUnposted]  
			  ,[intUserId]  
			  ,[intEntityId]  
			  ,[strTransactionId]  
			  ,[intTransactionId]  
			  ,[strTransactionType]  
			  ,[strTransactionForm]  
			  ,[strModuleName]  
			  ,[intConcurrencyId]  
			)  
			-- RETRIEVE THE DATA FROM THE TABLE VARIABLE.   
			SELECT [dtmDate]  
			  ,@batchId  
			  ,[intAccountId]  
			  ,[dblDebit]  
			  ,[dblCredit]  
			  ,[dblDebitUnit]  
			  ,[dblCreditUnit]  
			  ,[strDescription]  
			  ,[strCode]  
			  ,[strReference]  
			  ,[intCurrencyId]  
			  ,[dblExchangeRate]  
			  ,[dtmDateEntered]  
			  ,[dtmTransactionDate]  
			  ,[strJournalLineDescription]  
			  ,[intJournalLineNo]  
			  ,[ysnIsUnposted]  
			  ,[intUserId]  
			  ,[intEntityId]  
			  ,[strTransactionId]  
			  ,[intTransactionId]  
			  ,[strTransactionType]  
			  ,[strTransactionForm]  
			  ,[strModuleName]  
			  ,[intConcurrencyId]  
			FROM 
				@GLEntries
				
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()
			IF @raiseError = 0
				BEGIN
					BEGIN TRANSACTION
					EXEC uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param		
					--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					--SELECT @ErrorMerssage, @transType, @param, @batchId, 0
					COMMIT TRANSACTION
				END			
			IF @raiseError = 1
				RAISERROR(@ErrorMerssage, 11, 1)
			GOTO Post_Exit
		END CATCH
	
	END 	

--------------------------------------------------------------------------------------------  
-- If RECAP is FALSE,
-- 1. Book the G/L entries
-- 2. Update the ysnPosted flag in the transaction. Increase the concurrency. 
-- 3. Commit the save point 
--------------------------------------------------------------------------------------------  
IF @recap = 0
	BEGIN
		BEGIN TRY 
			EXEC dbo.uspGLBookEntries @GLEntries, @post
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
		 
		BEGIN TRY 
			IF @post = 0
				BEGIN

					UPDATE 
						tblARInvoice
					SET
						ysnPosted = 0
						,ysnPaid = 0
						,dblAmountDue = ISNULL(dblInvoiceTotal, 0.000000)
						,dblDiscount = ISNULL(dblDiscount, 0.000000)
						,dblPayment = 0.000000
						,dtmPostDate = CAST(ISNULL(dtmPostDate, dtmDate) AS DATE)
						,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1
					FROM
						tblARInvoice 
					WHERE 
						intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)

					UPDATE
						tblGLDetail
					SET
						ysnIsUnposted = 1
					FROM
						@PostInvoiceData P
					WHERE
						tblGLDetail.intTransactionId = P.intInvoiceId
						AND tblGLDetail.strTransactionId = P.strTransactionId

					--Insert Successfully unposted transactions.
					INSERT INTO tblARPostResult(
						strMessage
						,strTransactionType
						,strTransactionId
						,strBatchNumber
						,intTransactionId)
					SELECT
						@UnpostSuccessfulMsg
						,A.strTransactionType
						,A.strInvoiceNumber
						,@batchId
						,A.intInvoiceId
					FROM
						tblARInvoice A
					WHERE
						intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
						
					--Update tblHDTicketHoursWorked ysnBilled
					UPDATE
						tblHDTicketHoursWorked
					SET
						 ysnBilled = 0
						,dtmBilled = NULL
					WHERE
						intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
						
					BEGIN TRY
						DECLARE @TankDeliveryForUnSync TABLE (
								intInvoiceId INT,
								UNIQUE (intInvoiceId));
								
						INSERT INTO @TankDeliveryForUnSync					
						SELECT DISTINCT
							I.intInvoiceId
						FROM
							tblARInvoice I
						INNER JOIN
							tblARInvoiceDetail D
								ON I.intInvoiceId = D.intInvoiceId		
						INNER JOIN
							tblTMSite TMS
								ON D.intSiteId = TMS.intSiteID 
						INNER JOIN 
							@PostInvoiceData B
								ON I.intInvoiceId = B.intInvoiceId
								
						WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForUnSync ORDER BY intInvoiceId)
							BEGIN
							
								DECLARE  @intInvoiceForUnSyncId INT
										,@ResultLogForUnSync NVARCHAR(MAX)
										
								
								SELECT TOP 1 @intInvoiceForUnSyncId = intInvoiceId FROM @TankDeliveryForUnSync ORDER BY intInvoiceId

								EXEC dbo.uspTMUnSyncInvoiceFromDeliveryHistory  @intInvoiceForUnSyncId, @ResultLogForUnSync OUT
												
								DELETE FROM @TankDeliveryForUnSync WHERE intInvoiceId = @intInvoiceForUnSyncId
																												
							END 							
								
																
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()										
						GOTO Do_Rollback
					END CATCH	

				END
			ELSE
				BEGIN

					UPDATE 
						tblARInvoice
					SET
						ysnPosted = 1
						,ysnPaid = (CASE WHEN tblARInvoice.dblInvoiceTotal = 0.00 THEN 1 ELSE 0 END)
						,dblInvoiceTotal = dblInvoiceTotal
						,dblAmountDue = ISNULL(dblInvoiceTotal, 0.000000)
						,dblDiscount = ISNULL(dblDiscount, 0.000000)
						,dblPayment = 0.000000
						,dtmPostDate = CAST(ISNULL(dtmPostDate, dtmDate) AS DATE)
						,intConcurrencyId = ISNULL(intConcurrencyId,0) + 1						
					WHERE
						tblARInvoice.intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)

					--Insert Successfully posted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,A.strTransactionType
						,A.strInvoiceNumber
						,@batchId
						,A.intInvoiceId
					FROM
						tblARInvoice A
					WHERE
						intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
					
					--Update tblHDTicketHoursWorked ysnBilled					
					UPDATE
						tblHDTicketHoursWorked
					SET
						ysnBilled = 1
						,dtmBilled = GETDATE()
					WHERE
						intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
						
					BEGIN TRY
						DECLARE @TankDeliveryForSync TABLE (
								intInvoiceId INT,
								UNIQUE (intInvoiceId));
								
						INSERT INTO @TankDeliveryForSync					
						SELECT DISTINCT
							I.intInvoiceId
						FROM
							tblARInvoice I
						INNER JOIN
							tblARInvoiceDetail D
								ON I.intInvoiceId = D.intInvoiceId		
						INNER JOIN
							tblTMSite TMS
								ON D.intSiteId = TMS.intSiteID 
						INNER JOIN 
							@PostInvoiceData B
								ON I.intInvoiceId = B.intInvoiceId
								
						WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForSync ORDER BY intInvoiceId)
							BEGIN
							
								DECLARE  @intInvoiceForSyncId INT
										,@ResultLogForSync NVARCHAR(MAX)
										
								
								SELECT TOP 1 @intInvoiceForSyncId = intInvoiceId FROM @TankDeliveryForSync ORDER BY intInvoiceId

								EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @userId, @ResultLogForSync OUT
												
								DELETE FROM @TankDeliveryForSync WHERE intInvoiceId = @intInvoiceForSyncId
																												
							END 							
								
																
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()										
						GOTO Do_Rollback
					END CATCH
					
				END
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH
			
		BEGIN TRY			
			DECLARE @InvoiceToUpdate TABLE (intInvoiceId INT);
			
			INSERT INTO @InvoiceToUpdate(intInvoiceId)
			SELECT DISTINCT intInvoiceId FROM @PostInvoiceData
				
			WHILE EXISTS(SELECT TOP 1 NULL FROM @InvoiceToUpdate ORDER BY intInvoiceId)
				BEGIN
				
					DECLARE @intInvoiceIntegractionId INT;
					
					SELECT TOP 1 @intInvoiceIntegractionId = intInvoiceId FROM @InvoiceToUpdate ORDER BY intInvoiceId

						EXEC dbo.uspARPostInvoiceIntegrations @post, @intInvoiceIntegractionId, @userId
									
					DELETE FROM @InvoiceToUpdate WHERE intInvoiceId = @intInvoiceIntegractionId AND intInvoiceId = @intInvoiceIntegractionId 
												
				END 
																
		END TRY
		BEGIN CATCH	
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH										
			
	END
	
SET @successfulCount = @totalRecords
SET @invalidCount = @totalInvalid	
IF @raiseError = 0
	COMMIT TRANSACTION
RETURN 1;

Do_Rollback:
	IF @raiseError = 0
		BEGIN
		    IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION

			--IF (XACT_STATE()) = 1
		 --       COMMIT TRANSACTION;
										
			BEGIN TRANSACTION
			EXEC uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param		
			--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			--SELECT @ErrorMerssage, @transType, @param, @batchId, 0							
			COMMIT TRANSACTION			
		END
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)	
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;	