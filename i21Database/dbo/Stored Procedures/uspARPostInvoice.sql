CREATE PROCEDURE [dbo].[uspARPostInvoice]
	@batchId			AS NVARCHAR(20)		= NULL,
	@post				AS BIT				= 0,
	@recap				AS BIT				= 0,
	@param				AS NVARCHAR(MAX)	= NULL,
	@userId				AS INT				= 1,
	@beginDate			AS DATE				= NULL,
	@endDate			AS DATE				= NULL,
	@beginTransaction	AS NVARCHAR(50)		= NULL,
	@endTransaction		AS NVARCHAR(50)		= NULL,
	@exclude			AS NVARCHAR(MAX)	= NULL,
	@successfulCount	AS INT				= 0 OUTPUT,
	@invalidCount		AS INT				= 0 OUTPUT,
	@success			AS BIT				= 0 OUTPUT,
	@batchIdUsed		AS NVARCHAR(20)		= NULL OUTPUT,
	@recapId			AS NVARCHAR(250)	= NEWID OUTPUT,
	@transType			AS NVARCHAR(25)		= 'all'
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
BEGIN TRAN @TransactionName
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

-- Create the gl entries variable 
DECLARE @GLEntries AS RecapTableType


DECLARE @PostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully posted.'
DECLARE @UnpostSuccessfulMsg NVARCHAR(50) = 'Transaction successfully unposted.'
DECLARE @MODULE_NAME NVARCHAR(25) = 'Accounts Receivable'
DECLARE @SCREEN_NAME NVARCHAR(25) = 'Invoice'
DECLARE @CODE NVARCHAR(25) = 'AR'


DECLARE @UserEntityID int
		,@DiscountAccountId int
SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE intUserSecurityID = @userId),@userId)
SET @DiscountAccountId = (SELECT TOP 1 intDiscountAccountId FROM tblARCompanyPreference WHERE intDiscountAccountId IS NOT NULL AND intDiscountAccountId <> 0)

SET @recapId = '1'
SET @success = 1

DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
SELECT @INVENTORY_SHIPMENT_TYPE = intTransactionTypeId FROM tblICInventoryTransactionType WHERE strName = @SCREEN_NAME

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
		WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate AND ysnPosted = 0
		AND (strTransactionType = @transType OR @transType = 'all')
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData
		SELECT intInvoiceId, strInvoiceNumber FROM tblARInvoice
		WHERE intInvoiceId BETWEEN @beginTransaction AND @endTransaction AND ysnPosted = 0
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

--IF(@batchId IS NULL)
	EXEC uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId

--------------------------------------------------------------------------------------------  
-- Validations  
--------------------------------------------------------------------------------------------  
IF @recap = 0
	BEGIN
		--Posting
		IF @post = 1
			BEGIN
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
					ISNULL(dbo.isOpenAccountingDate(A.dtmDate), 0) = 0

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

				--No Freight specified
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'No freight term has been specified.',
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
				INNER JOIN
					tblICItemUOM ItemUOM 
						ON ItemUOM.intItemUOMId = Detail.intItemUOMId
				LEFT OUTER JOIN
					vyuICGetItemStock IST
						ON Detail.intItemId = IST.intItemId 
						AND A.intCompanyLocationId = IST.intLocationId 
				WHERE 
					(A.intFreightTermId IS NULL OR A.intFreightTermId = 0) 
					AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)
					AND (Detail.intSalesOrderDetailId IS NULL OR Detail.intSalesOrderDetailId = 0)
					AND (Detail.intItemId IS NOT NULL OR Detail.intItemId <> 0)
					AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')
					
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
					AND (Detail.intItemId IS NOT NULL OR Detail.intItemId <> 0)
					AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')
					
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
					ROUND(A.dblInvoiceTotal,2) <> ROUND(((SELECT SUM(ROUND(dblTotal,2)) FROM tblARInvoiceDetail WHERE intInvoiceId = A.intInvoiceId) + ISNULL(ROUND(A.dblShipping,2),0.0) + ISNULL(ROUND(A.dblTax,2),0.0)),2)

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
				
				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Service Charge account of Company Location - ' + L.strLocationName + ' was not set.',
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
					tblSMCompanyLocation L
						ON A.intCompanyLocationId = L.intCompanyLocationId				 				
				WHERE
					(D.intAccountId IS NULL OR D.intAccountId = 0)
					AND (D.intItemId IS NULL OR D.intItemId = 0)
					AND (L.intServiceCharges  IS NULL OR L.intServiceCharges  = 0)
								
								
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Service Charge Account of item - ' + I.strItemNo + ' was not specified.',
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
					(D.intAccountId IS NULL OR D.intAccountId = 0)
					AND I.strType IN ('Non-Inventory','Service','Other Charge')


			END 

		--unposting
		IF @post = 0
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
					ISNULL(dbo.isOpenAccountingDate(A.dtmDate), 0) = 0

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

			END

		SELECT @totalRecords = COUNT(*) FROM @PostInvoiceData
			
		IF(@totalInvalid >= 1 AND @totalRecords <= 0)  
			GOTO Post_Exit	

	END


--------------------------------------------------------------------------------------------  
-- Begin a transaction and immediately create a save point 
--------------------------------------------------------------------------------------------  
--BEGIN TRAN @TransactionName
--SAVE TRAN @TransactionName

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
				,strTransactionId  
				,intTransactionTypeId  
				,intLotId 
				,intSubLocationId
				,intStorageLocationId
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
				,Header.strInvoiceNumber 
				,@INVENTORY_SHIPMENT_TYPE
				,NULL 
				,NULL
				,NULL
			FROM 
				tblARInvoiceDetail Detail
			INNER JOIN
				tblARInvoice Header
					ON Detail.intInvoiceId = Header.intInvoiceId
					AND Header.strTransactionType  IN ('Invoice', 'Credit Memo')
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
				AND Detail.intItemId IS NOT NULL AND Detail.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')
			
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
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
			)
			EXEC	dbo.uspICPostCosting  
					@ItemsForPost  
					,@batchId  
					,@ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY
					,@UserEntityID

		END TRY
		BEGIN CATCH
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
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
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  ROUND(A.dblInvoiceTotal,2) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE ROUND(A.dblInvoiceTotal,2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
					
			--CREDIT MISC
			UNION ALL 
			SELECT
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))) 
													AND B.intSalesAccountId IS NOT NULL
													AND B.intSalesAccountId <> 0
													THEN
														B.intSalesAccountId
													ELSE
														(CASE WHEN B.intAccountId IS NOT NULL AND B.intAccountId <> 0 THEN B.intAccountId ELSE CL.intServiceCharges END)
												END)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2)  END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) ELSE 0  END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail B
					ON A.intInvoiceId = B.intInvoiceId
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId		
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				tblSMCompanyLocation CL
					ON A.intCompanyLocationId = CL.intCompanyLocationId			
			WHERE 
				(B.intItemId IS NULL OR B.intItemId = 0)
				OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge')))

			--CREDIT SALES
			UNION ALL 
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) ELSE  0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail B
					ON A.intInvoiceId = B.intInvoiceId
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId			
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
				tblICItem I
					ON B.intItemId = I.intItemId 
			WHERE 
				(B.intItemId IS NOT NULL OR B.intItemId <> 0)
				AND I.strType NOT IN ('Non-Inventory','Service','Other Charge')
			--CREDIT Shipping
			UNION ALL 
			SELECT
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= L.intFreightIncome
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND(A.dblShipping,2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND(A.dblShipping,2) ELSE 0  END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				A.dblShipping <> 0.0		
				
		UNION ALL 
			--CREDIT Tax
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND(DT.dblAdjustedTax,2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND(DT.dblAdjustedTax,2) ELSE 0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				DT.dblAdjustedTax <> 0.0
				
			UNION ALL 
			--DEBIT Discount
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND(((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)),2) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND(((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)),2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) <> 0.0


			UNION ALL 
			--DEBIT COGS - SHIPPED
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= IST.intCOGSAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
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
				D.intInventoryShipmentItemId IS NOT NULL AND D.intInventoryShipmentItemId <> 0
				AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')
				
			UNION ALL 
			--CREDIT Inventory In-Transit - SHIPPED
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= IST.intInventoryInTransitAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) ELSE 0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
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
				D.intInventoryShipmentItemId IS NOT NULL AND D.intInventoryShipmentItemId <> 0
				AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')		
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
		END CATCH
	END   

--------------------------------------------------------------------------------------------  
-- If UNPOST, call the Unpost routines  
--------------------------------------------------------------------------------------------  
IF @post = 0   
	BEGIN   
		
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
				AND (Detail.intItemId IS NOT NULL OR Detail.intItemId <> 0)
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')

			WHILE EXISTS(SELECT TOP 1 NULL FROM @UnPostInvoiceData ORDER BY intInvoiceId)
				BEGIN
				
					DECLARE @intTransactionId INT
							,@strTransactionId NVARCHAR(80);
					
					SELECT TOP 1 @intTransactionId = intInvoiceId, @strTransactionId = strTransactionId FROM @UnPostInvoiceData ORDER BY intInvoiceId

					-- Call the post routine 
					INSERT INTO @GLEntries (
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
					EXEC	dbo.uspICUnpostCosting
							@intTransactionId
							,@strTransactionId
							,@batchId
							,@UserEntityID
							
					--IF(@@ERROR <> 0)  
					--	BEGIN			
					--		SET @success = 0 
					--		GOTO Post_Exit
					--	END	
			
					DELETE FROM @UnPostInvoiceData WHERE intInvoiceId = @intTransactionId AND strTransactionId = @strTransactionId 
												
				END 
																
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
		END CATCH		
		
		--BEGIN 
		--	INSERT INTO @GLEntries(
		--		 dtmDate
		--		,strBatchId
		--		,intAccountId
		--		,dblDebit
		--		,dblCredit
		--		,dblDebitUnit
		--		,dblCreditUnit
		--		,strDescription
		--		,strCode
		--		,strReference
		--		,intCurrencyId
		--		,dblExchangeRate
		--		,dtmDateEntered
		--		,dtmTransactionDate
		--		,strJournalLineDescription
		--		,intJournalLineNo
		--		,ysnIsUnposted
		--		,intUserId
		--		,intEntityId
		--		,strTransactionId
		--		,intTransactionId
		--		,strTransactionType
		--		,strTransactionForm
		--		,strModuleName
		--		,intConcurrencyId
		--	)
		--	SELECT	
		--		 GL.dtmDate
		--		,@batchId
		--		,GL.intAccountId
		--		,dblDebit						= GL.dblCredit
		--		,dblCredit						= GL.dblDebit
		--		,dblDebitUnit					= GL.dblCreditUnit
		--		,dblCreditUnit					= GL.dblDebitUnit
		--		,GL.strDescription
		--		,GL.strCode
		--		,GL.strReference
		--		,GL.intCurrencyId
		--		,GL.dblExchangeRate
		--		,dtmDateEntered					= GETDATE()
		--		,GL.dtmTransactionDate
		--		,GL.strJournalLineDescription
		--		,GL.intJournalLineNo 
		--		,ysnIsUnposted					= 1
		--		,intUserId						= @userId
		--		,intEntityId					= @UserEntityID
		--		,GL.strTransactionId
		--		,GL.intTransactionId
		--		,GL.strTransactionType
		--		,GL.strTransactionForm
		--		,GL.strModuleName
		--		,GL.intConcurrencyId
		--	FROM
		--		tblGLDetail GL
		--	INNER JOIN
		--		@PostInvoiceData P
		--			ON GL.intTransactionId = P.intInvoiceId 
		--			AND GL.strTransactionId = P.strTransactionId
		--	WHERE
		--		GL.ysnIsUnposted = 0
		--	ORDER BY
		--		GL.intGLDetailId		
						
		--END
		
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
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= A.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  0 ELSE ROUND(A.dblInvoiceTotal,2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN  ROUND(A.dblInvoiceTotal,2) ELSE 0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
					
			--CREDIT MISC
			UNION ALL 
			SELECT
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= (CASE WHEN (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge'))) 
													AND B.intSalesAccountId IS NOT NULL
													AND B.intSalesAccountId <> 0
													THEN
														B.intSalesAccountId
													ELSE
														(CASE WHEN B.intAccountId IS NOT NULL AND B.intAccountId <> 0 THEN B.intAccountId ELSE CL.intServiceCharges END)
												END)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) ELSE 0  END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail B
					ON A.intInvoiceId = B.intInvoiceId
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId		
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			LEFT OUTER JOIN
				tblSMCompanyLocation CL
					ON A.intCompanyLocationId = CL.intCompanyLocationId			
			WHERE 
				(B.intItemId IS NULL OR B.intItemId = 0)
				OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge')))

			--CREDIT SALES
			UNION ALL 
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) ELSE  0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ISNULL(ROUND(B.dblTotal,2), 0.00) + ROUND(((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))),2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail B
					ON A.intInvoiceId = B.intInvoiceId
			LEFT JOIN 
				tblARCustomer C
					ON A.[intEntityCustomerId] = C.intEntityCustomerId			
			INNER JOIN 
				@PostInvoiceData	P
					ON A.intInvoiceId = P.intInvoiceId
			INNER JOIN
				tblICItem I
					ON B.intItemId = I.intItemId 
			WHERE 
				(B.intItemId IS NOT NULL OR B.intItemId <> 0)
				AND I.strType NOT IN ('Non-Inventory','Service','Other Charge')

			UNION ALL 
			--CREDIT Shipping
			SELECT
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= L.intFreightIncome
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND(A.dblShipping,2) ELSE 0  END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND(A.dblShipping,2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				A.dblShipping <> 0.0		
				
			UNION ALL 
			--CREDIT Tax
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(DT.intSalesTaxAccountId,TC.intSalesTaxAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND(DT.dblAdjustedTax,2) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND(DT.dblAdjustedTax,2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				DT.dblAdjustedTax <> 0.0	


			UNION ALL 
			--DEBIT Discount
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND(((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)),2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND(((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)),2) ELSE 0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) <> 0.0


			UNION ALL 
			--DEBIT COGS - SHIPPED
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= IST.intCOGSAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) ELSE 0 END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
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
				D.intInventoryShipmentItemId IS NOT NULL AND D.intInventoryShipmentItemId <> 0
				AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')
				
			UNION ALL 
			--CREDIT Inventory In-Transit - SHIPPED
			SELECT			
				 dtmDate					= DATEADD(dd, DATEDIFF(dd, 0, A.dtmDate), 0)
				,strBatchID					= @batchId
				,intAccountId				= IST.intInventoryInTransitAccountId
				,dblDebit					= CASE WHEN A.strTransactionType = 'Invoice' THEN ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType = 'Invoice' THEN 0 ELSE ROUND((ABS(ICT.dblQty) * ICT.dblCost),2) END
				,dblDebitUnit				= 0
				,dblCreditUnit				= 0				
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= GETDATE()
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
				tblARInvoiceDetail D
			INNER JOIN			
				tblARInvoice A 
					ON D.intInvoiceId = A.intInvoiceId
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
				D.intInventoryShipmentItemId IS NOT NULL AND D.intInventoryShipmentItemId <> 0
				AND D.intSalesOrderDetailId IS NOT NULL AND D.intSalesOrderDetailId <> 0
				AND D.intItemId IS NOT NULL AND D.intItemId <> 0
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge')									
		
		
		END TRY
		BEGIN CATCH
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
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
	--BEGIN 
	--	ROLLBACK TRAN @TransactionName
	--	EXEC dbo.uspCMPostRecap @GLEntries
	--	--IF(@@ERROR <> 0)  
	--	--	BEGIN			
	--	--		SET @success = 0 
	--	--		GOTO Post_Exit
	--	--	END	
	--	COMMIT TRAN @TransactionName
	--END 
	BEGIN 

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
		FROM 
			@GLEntries
			
	END TRY
	BEGIN CATCH
		ROLLBACK TRAN @TransactionName
		BEGIN TRANSACTION
		INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
		SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
		COMMIT TRANSACTION
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
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
		END CATCH
		 
		BEGIN TRY 
		IF @post = 0
			BEGIN

				UPDATE 
					tblARInvoice
				SET
					ysnPosted = 0
					,ysnPaid = 0
					,dblAmountDue = ISNULL(ROUND(dblInvoiceTotal,2), 0.000000)
					,dblDiscount = ISNULL(dblDiscount, 0.000000)
					,dblPayment = 0.000000
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

			END
		ELSE
			BEGIN

				UPDATE 
					tblARInvoice
				SET
					ysnPosted = 1
					,dblInvoiceTotal = ROUND(dblInvoiceTotal,2)
					,dblAmountDue = ISNULL(ROUND(dblInvoiceTotal,2), 0.000000)
					,dblDiscount = ISNULL(dblDiscount, 0.000000)
					,dblPayment = 0.000000
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
				
			END
		END TRY
		BEGIN CATCH	
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
		END CATCH
			
		BEGIN TRY			
			DECLARE @OrderToUpdate TABLE (intSalesOrderId INT);
			
			INSERT INTO @OrderToUpdate(intSalesOrderId)
			SELECT DISTINCT
				 SODetail.intSalesOrderId
			FROM
				tblSOSalesOrderDetail SODetail
			INNER JOIN 
				tblARInvoiceDetail Detail
					ON SODetail.intSalesOrderDetailId = Detail.intSalesOrderDetailId 
			INNER JOIN
				tblARInvoice Header
					ON Detail.intInvoiceId = Header.intInvoiceId
					AND Header.strTransactionType IN ('Invoice', 'Credit Memo')
			INNER JOIN
				@PostInvoiceData P
					ON Header.intInvoiceId = P.intInvoiceId	
			WHERE 
				Detail.intSalesOrderDetailId IS NOT NULL 
				AND Detail.intSalesOrderDetailId <> 0
				

			WHILE EXISTS(SELECT TOP 1 NULL FROM @OrderToUpdate ORDER BY intSalesOrderId)
				BEGIN
				
					DECLARE @intSalesOrderId INT;
					
					SELECT TOP 1 @intSalesOrderId = intSalesOrderId FROM @OrderToUpdate ORDER BY intSalesOrderId

					EXEC dbo.uspSOUpdateOrderShipmentStatus @intSalesOrderId
									
					DELETE FROM @OrderToUpdate WHERE intSalesOrderId = @intSalesOrderId AND intSalesOrderId = @intSalesOrderId 
												
				END 
																
		END TRY
		BEGIN CATCH	
			ROLLBACK TRAN @TransactionName
			BEGIN TRANSACTION
			INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
			SELECT ERROR_MESSAGE(), @transType, @param, @batchId, 0
			COMMIT TRANSACTION
			GOTO Post_Exit
		END CATCH				
			
	END
	
SET @successfulCount = @totalRecords
SET @invalidCount = @totalInvalid	
COMMIT TRAN @TransactionName
RETURN 1;	
	    
-- This is our immediate exit in case of exceptions controlled by this stored procedure
Post_Exit:
	SET @successfulCount = 0	
	SET @invalidCount = @totalInvalid + @totalRecords
	SET @success = 0	
	RETURN 0;
	