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
	strError NVARCHAR(max),
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
		,@DeferredRevenueAccountId	INT

SET @UserEntityID = ISNULL((SELECT [intEntityUserSecurityId] FROM dbo.tblSMUserSecurity WHERE [intEntityUserSecurityId] = @userId),@userId)
SET @DiscountAccountId = (SELECT TOP 1 [intDiscountAccountId] FROM dbo.tblARCompanyPreference WHERE ISNULL([intDiscountAccountId],0) <> 0)
SET @DeferredRevenueAccountId = (SELECT TOP 1 [intDeferredRevenueAccountId] FROM dbo.tblARCompanyPreference WHERE ISNULL([intDeferredRevenueAccountId],0) <> 0)

DECLARE @ErrorMerssage NVARCHAR(MAX)

SET @recapId = '1'
SET @success = 1

DECLARE @ACCOUNT_CATEGORY_TO_COUNTER_INVENTORY AS NVARCHAR(255) = 'Cost of Goods'
DECLARE @INVENTORY_SHIPMENT_TYPE AS INT = 5
SELECT @INVENTORY_SHIPMENT_TYPE = [intTransactionTypeId] FROM dbo.tblICInventoryTransactionType WHERE [strName] = @SCREEN_NAME

DECLARE @INVENTORY_INVOICE_TYPE AS INT = 33

SELECT	@INVENTORY_INVOICE_TYPE = intTransactionTypeId 
FROM	tblICInventoryTransactionType 
WHERE	strName = @SCREEN_NAME

DECLARE @ZeroDecimal DECIMAL(18,6)
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
			INSERT INTO @PostInvoiceData SELECT [intInvoiceId], [strInvoiceNumber] FROM dbo.tblARInvoice WHERE [ysnPosted] = 0 AND ([strTransactionType] = @transType OR @transType = 'all')
		END
		ELSE
		BEGIN
			INSERT INTO @PostInvoiceData SELECT ARI.[intInvoiceId], ARI.[strInvoiceNumber] FROM dbo.tblARInvoice ARI WHERE EXISTS(SELECT NULL FROM dbo.fnGetRowsFromDelimitedValues(@param) DV WHERE DV.[intID] = ARI.[intInvoiceId])
		END
	END

IF(@beginDate IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData
		SELECT intInvoiceId, strInvoiceNumber FROM dbo.tblARInvoice
		WHERE DATEADD(dd, DATEDIFF(dd, 0, dtmDate), 0) BETWEEN @beginDate AND @endDate
		AND (strTransactionType = @transType OR @transType = 'all')
	END

IF(@beginTransaction IS NOT NULL)
	BEGIN
		INSERT INTO @PostInvoiceData
		SELECT intInvoiceId, strInvoiceNumber FROM dbo.tblARInvoice
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
		SELECT [intID] FROM dbo.fnGetRowsFromDelimitedValues(@exclude)


		DELETE FROM A
		FROM @PostInvoiceData A
		WHERE EXISTS(SELECT NULL FROM @InvoicesExclude B WHERE A.[intInvoiceId] = B.[intInvoiceId])
	END
	

IF(@batchId IS NULL)
	EXEC dbo.uspSMGetStartingNumber 3, @batchId OUT

SET @batchIdUsed = @batchId


--Process Split Invoice
BEGIN TRY
	IF @post = 1 AND @recap = 0
	BEGIN
		DECLARE @SplitInvoiceData TABLE([intInvoiceId] INT)

		INSERT INTO @SplitInvoiceData
		SELECT 
			intInvoiceId
		FROM
			dbo.tblARInvoice ARI
		WHERE
			ARI.[ysnSplitted] = 0 
			AND ISNULL(ARI.[intSplitId], 0) > 0
			AND EXISTS(SELECT NULL FROM @PostInvoiceData PID WHERE PID.[intInvoiceId] = ARI.[intInvoiceId])

		WHILE EXISTS(SELECT NULL FROM @SplitInvoiceData)
			BEGIN
				DECLARE @invoicesToAdd NVARCHAR(MAX) = NULL, @intSplitInvoiceId INT

				SELECT TOP 1 @intSplitInvoiceId = intInvoiceId FROM @SplitInvoiceData ORDER BY intInvoiceId

				EXEC dbo.uspARProcessSplitInvoice @intSplitInvoiceId, @userId, @invoicesToAdd OUT

				DELETE FROM @PostInvoiceData WHERE intInvoiceId = @intSplitInvoiceId

				IF (ISNULL(@invoicesToAdd, '') <> '')
					BEGIN
						INSERT INTO @PostInvoiceData 
						SELECT ARI.[intInvoiceId], ARI.[strInvoiceNumber] 
						FROM dbo.tblARInvoice ARI
						WHERE ARI.[ysnPosted] = 0 
							AND intInvoiceId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd))


						EXEC dbo.uspARReComputeInvoiceAmounts @intSplitInvoiceId

						DECLARE @AddedInvoices AS [dbo].[Id]
						INSERT INTO @AddedInvoices([intId])
						SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@invoicesToAdd)
						DECLARE @AddedInvoiceId INT

						WHILE EXISTS(SELECT NULL FROM @AddedInvoices)
							BEGIN
								SELECT @AddedInvoiceId = [intId] FROM @AddedInvoices

								EXEC dbo.uspARReComputeInvoiceAmounts @AddedInvoiceId

								DELETE FROM @AddedInvoices WHERE [intId] = @AddedInvoiceId
							END
					END

				DELETE FROM @SplitInvoiceData WHERE intInvoiceId = @intSplitInvoiceId
			END
	END
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()					
	IF @raiseError = 0
		BEGIN
			ROLLBACK TRANSACTION							
			BEGIN TRANSACTION						
			EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param
			COMMIT TRANSACTION
		END						
	IF @raiseError = 1
		RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

--Process Finished Good Items
BEGIN TRY
	IF @recap = 0
		BEGIN
			DECLARE @FinishedGoodItems TABLE(intInvoiceDetailId		INT
										   , intItemId				INT
										   , dblQuantity			NUMERIC(18,6)
										   , intItemUOMId			INT
										   , intLocationId			INT
										   , intSublocationId		INT
										   , intStorageLocationId	INT)

			INSERT INTO @FinishedGoodItems
			SELECT ID.intInvoiceDetailId
				 , ID.intItemId
				 , ID.dblQtyShipped
				 , ID.intItemUOMId
				 , I.intCompanyLocationId
				 , ICL.intSubLocationId
				 , ID.intStorageLocationId 
			FROM tblARInvoice I
				INNER JOIN tblARInvoiceDetail ID ON I.intInvoiceId = ID.intInvoiceId
				INNER JOIN tblICItem ICI ON ID.intItemId = ICI.intItemId
				INNER JOIN tblICItemLocation ICL ON ID.intItemId = ICL.intItemId AND I.intCompanyLocationId = ICL.intLocationId
			WHERE I.intInvoiceId IN (SELECT intInvoiceId FROM @PostInvoiceData)
			AND ID.ysnBlended <> @post
			AND ICI.ysnAutoBlend = 1
			AND ICI.strType = 'Finished Good'

			WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
				BEGIN
					DECLARE @intInvoiceDetailId		INT
						  , @intItemId				INT
						  , @dblQuantity			NUMERIC(18,6)
						  , @dblMaxQuantity			NUMERIC(18,6) = 0
						  , @intItemUOMId			INT
						  , @intLocationId			INT
						  , @intSublocationId		INT
						  , @intStorageLocationId	INT
			
					SELECT TOP 1 
						  @intInvoiceDetailId	= intInvoiceDetailId
						, @intItemId			= intItemId
						, @dblQuantity			= dblQuantity				
						, @intItemUOMId			= intItemUOMId
						, @intLocationId		= intLocationId
						, @intSublocationId		= intSublocationId
						, @intStorageLocationId	= intStorageLocationId
					FROM @FinishedGoodItems 
				  
					BEGIN TRY
					IF @post = 1
						BEGIN
							EXEC dbo.uspMFAutoBlend
								@intSalesOrderDetailId	= NULL,
								@intInvoiceDetailId		= @intInvoiceDetailId,
								@intItemId				= @intItemId,
								@dblQtyToProduce		= @dblQuantity,
								@intItemUOMId			= @intItemUOMId,
								@intLocationId			= @intLocationId,
								@intSubLocationId		= @intSublocationId,
								@intStorageLocationId	= @intStorageLocationId,
								@intUserId				= @userId,
								@dblMaxQtyToProduce		= @dblMaxQuantity OUT		

							IF ISNULL(@dblMaxQuantity, 0) > 0
								BEGIN
									EXEC dbo.uspMFAutoBlend
										@intSalesOrderDetailId	= NULL,
										@intInvoiceDetailId		= @intInvoiceDetailId,
										@intItemId				= @intItemId,
										@dblQtyToProduce		= @dblMaxQuantity,
										@intItemUOMId			= @intItemUOMId,
										@intLocationId			= @intLocationId,
										@intSubLocationId		= @intSublocationId,
										@intStorageLocationId	= @intStorageLocationId,
										@intUserId				= @userId,
										@dblMaxQtyToProduce		= @dblMaxQuantity OUT
								END
						END
					ELSE
						BEGIN
							EXEC dbo.uspMFReverseAutoBlend
								@intSalesOrderDetailId	= NULL,
								@intInvoiceDetailId		= @intInvoiceDetailId,
								@intUserId				= @userId 
						END						
					END TRY
					BEGIN CATCH
						SELECT @ErrorMerssage = ERROR_MESSAGE()
						IF @raiseError = 0
							BEGIN
								IF (XACT_STATE()) = -1
									ROLLBACK TRANSACTION							
								BEGIN TRANSACTION						
								EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param
								COMMIT TRANSACTION
							END						
						IF @raiseError = 1
							RAISERROR(@ErrorMerssage, 11, 1)
		
						GOTO Post_Exit
					END CATCH
					UPDATE tblARInvoiceDetail SET ysnBlended = @post WHERE intInvoiceDetailId = @intInvoiceDetailId

					DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailId
				END	
		END	
END TRY
BEGIN CATCH
	SELECT @ErrorMerssage = ERROR_MESSAGE()
	IF @raiseError = 0
		BEGIN
			IF (XACT_STATE()) = -1
				ROLLBACK TRANSACTION							
			BEGIN TRANSACTION						
			EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param
			COMMIT TRANSACTION
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

				--ALREADY POSTED
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'The transaction is already posted.',
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM 
					@PostInvoiceData PID
				INNER JOIN 
					tblARInvoice ARI
						ON PID.intInvoiceId = ARI.intInvoiceId
				WHERE  
					ARI.ysnPosted = 1
					
								
				-- Tank consumption site
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType,strTransactionId, strBatchNumber, intTransactionId)
				SELECT TOP 1 
					'Unable to find a tank consumption site for item no. ' + ICI.strItemNo,
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM
					@PostInvoiceData PID
				INNER JOIN
					 dbo.tblARInvoice ARI 
						ON PID.intInvoiceId = ARI.intInvoiceId						
				INNER JOIN
					dbo.tblARInvoiceDetail ARID 
						ON ARI.intInvoiceId = ARID.intInvoiceId
				INNER JOIN 
					dbo.tblICItem ICI 
						ON ARID.intItemId = ICI.intItemId						
				WHERE
					ARI.strType = 'Tank Delivery'
					AND ARID.intSiteId IS NULL
					AND ICI.ysnTankRequired = 1
				 							
				--zero amount
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					CASE WHEN ARI.strTransactionType = 'Invoice ' THEN 'You cannot post an ' + ARI.strTransactionType + ' with zero amount.' 
					ELSE 'You cannot post a ' + ARI.strTransactionType + ' with zero amount.' END,
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM 
					@PostInvoiceData PID
				INNER JOIN 
					dbo.tblARInvoice ARI
						ON PID.intInvoiceId = ARI.intInvoiceId						
				WHERE
					ARI.dblInvoiceTotal = @ZeroDecimal
					AND ISNULL(ARI.strImportFormat, '') <> 'CarQuest'
					AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail WHERE tblARInvoiceDetail.dblTotal <> @ZeroDecimal AND tblARInvoiceDetail.intInvoiceId = ARI.intInvoiceId)
								
					
				--negative amount
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					CASE WHEN ARI.strTransactionType = 'Invoice' THEN 'You cannot post an ' + ARI.strTransactionType + ' with negative amount.' 
					ELSE 'You cannot post a ' + ARI.strTransactionType + ' with negative amount.' END ,
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM 
					@PostInvoiceData PID
				INNER JOIN 
					dbo.tblARInvoice ARI 
						ON PID.intInvoiceId = ARI.intInvoiceId
				WHERE
					ARI.dblInvoiceTotal < @ZeroDecimal						
					
					
				--Inactive Customer
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'Customer - ' + ARC.strCustomerNumber + ' is not active!',
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM 
					@PostInvoiceData PID				
				INNER JOIN 
					dbo.tblARInvoice ARI
						ON PID.intInvoiceId = ARI.intInvoiceId				
				INNER JOIN
					dbo.tblARCustomer ARC
						ON ARI.intEntityCustomerId = ARC.intEntityCustomerId 
				WHERE
					ARC.ysnActive = 0
					
				
				--UOM is required
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'UOM is required for item ' + Detail.strItemDescription + '.',
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId					
				FROM 
					dbo.tblARInvoiceDetail Detail
				INNER JOIN
					dbo.tblARInvoice A
						ON Detail.intInvoiceId = A.intInvoiceId
						AND A.strTransactionType = 'Invoice'
				INNER JOIN
					@PostInvoiceData P
						ON A.intInvoiceId = P.intInvoiceId	
				LEFT OUTER JOIN
					dbo.vyuICGetItemStock IST
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
					CASE WHEN GLA.intAccountId IS NULL THEN ' The Receivable Discount account assigned to item ' + IT.strItemNo + ' is not valid.' ELSE 'Receivable Discount account was not set up for item ' + IT.strItemNo END,
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId					
				FROM 
					dbo.tblARInvoiceDetail Detail
				INNER JOIN
					dbo.tblARInvoice A
						ON Detail.intInvoiceId = A.intInvoiceId
				INNER JOIN
					@PostInvoiceData P
						ON A.intInvoiceId = P.intInvoiceId	
				LEFT OUTER JOIN
					dbo.vyuARGetItemAccount IST
						ON Detail.intItemId = IST.intItemId 
						AND A.intCompanyLocationId = IST.intLocationId 
				LEFT OUTER JOIN
					dbo.tblICItem IT
						ON Detail.intItemId = IT.intItemId
				LEFT OUTER JOIN
					dbo.tblGLAccount GLA
						ON ISNULL(IST.intDiscountAccountId, @DiscountAccountId) = GLA.intAccountId
				WHERE 
					((ISNULL(IST.intDiscountAccountId,0) = 0  AND  ISNULL(@DiscountAccountId,0) = 0) OR GLA.intAccountId IS NULL)
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

				--Header Account ID
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The AR account is not valid.' ELSE 'The AR account is not specified.' END,				
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM 
					tblARInvoice A 
				INNER JOIN 
					@PostInvoiceData B
						ON A.intInvoiceId = B.intInvoiceId
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ISNULL(A.intAccountId, 0) = GLA.intAccountId
				WHERE  
					ISNULL(A.intAccountId, 0) = 0
					OR GLA.intAccountId IS NULL
					
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
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Freight Income account is not valid.' ELSE 'The Freight Income account of Company Location ' + SMCL.strLocationName + ' was not set.' END
					,ARI.strTransactionType
					,ARI.strInvoiceNumber
					,@batchId
					,ARI.intInvoiceId
				FROM
					tblARInvoice ARI
				INNER JOIN
					@PostInvoiceData P
						ON ARI.intInvoiceId = P.intInvoiceId						 
				INNER JOIN
					tblSMCompanyLocation SMCL
						ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON SMCL.intFreightIncome = GLA.intAccountId						
				WHERE
					(ISNULL(SMCL.intFreightIncome, 0) = 0 OR GLA.intAccountId IS NULL)
					AND ISNULL(ARI.dblShipping,0) <> 0.0


				--Undeposited Funds Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Undeposited Funds account of Company Location ' + SMCL.strLocationName + ' is not valid.' ELSE 'The Undeposited Funds account of Company Location ' + SMCL.strLocationName + ' was not set.' END
					,ARI.strTransactionType
					,ARI.strInvoiceNumber
					,@batchId
					,ARI.intInvoiceId
				FROM
					tblARInvoice ARI
				INNER JOIN
					@PostInvoiceData P
						ON ARI.intInvoiceId = P.intInvoiceId						 
				INNER JOIN
					tblSMCompanyLocation SMCL
						ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON SMCL.intUndepositedFundsId = GLA.intAccountId						
				WHERE
					(ISNULL(SMCL.intUndepositedFundsId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND (
						ARI.strTransactionType IN ('Cash','Cash Refund')
						OR
						(EXISTS(SELECT NULL FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.intInvoiceId = ARI.intInvoiceId AND tblARPrepaidAndCredit.ysnApplied = 1 AND tblARPrepaidAndCredit.dblAppliedInvoiceDetailAmount <> 0 ))
						)


				--Sales Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Sales account of Company Location ' + SMCL.strLocationName + ' is not valid.' ELSE 'The Sales account of Company Location ' + SMCL.strLocationName + ' was not set.' END
					,ARI.strTransactionType
					,ARI.strInvoiceNumber
					,@batchId
					,ARI.intInvoiceId
				FROM
					tblARInvoice ARI
				INNER JOIN
					tblARInvoiceDetail ARID
						ON ARI.intInvoiceId = ARID.intInvoiceId 
				INNER JOIN
					@PostInvoiceData P
						ON ARI.intInvoiceId = P.intInvoiceId						 
				INNER JOIN
					tblSMCompanyLocation SMCL
						ON ARI.intCompanyLocationId = SMCL.intCompanyLocationId
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON SMCL.intSalesAccount = GLA.intAccountId						
				WHERE
					(ISNULL(SMCL.intSalesAccount, 0) = 0 OR GLA.intAccountId IS NULL)
					AND ISNULL(ARID.intServiceChargeAccountId,0) = 0
					AND ISNULL(ARID.intSalesAccountId, 0) = 0
					AND ISNULL(ARID.intItemId,0) = 0
					AND ARID.dblTotal <> @ZeroDecimal
	
					
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
					AND ISNULL(@DeferredRevenueAccountId, 0) = 0

				--Service Deferred Revenue Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The Deferred Revenue account is not valid.',
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
					AND ISNULL(@DeferredRevenueAccountId, 0) <> 0
					AND NOT EXISTS(SELECT NULL FROM tblGLAccount WHERE intAccountId = @DeferredRevenueAccountId)

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
					CASE WHEN GLA.intAccountId IS NULL THEN 'The General Account of item - ' + I.strItemNo + ' is not valid.' ELSE 'The General Account of item - ' + I.strItemNo + ' was not specified.' END,
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON Acct.intGeneralAccountId = GLA.intAccountId
				WHERE
					(ISNULL(Acct.intGeneralAccountId,0) = 0 OR GLA.intAccountId IS NULL)
					AND I.strType IN ('Non-Inventory','Service')
					
				--Software - Maintenance Sales / General Account				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'Either the Maintenance Sales and General account of item - ' + I.strItemNo + ' is not valid.' ELSE 'The Maintenance Sales and General Accounts of item - ' + I.strItemNo + ' were not specified.' END,				
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ISNULL(Acct.intMaintenanceSalesAccountId, Acct.intGeneralAccountId) = GLA.intAccountId	 				
				WHERE
					(ISNULL(ISNULL(Acct.intMaintenanceSalesAccountId, Acct.intGeneralAccountId), 0) = 0 OR GLA.intAccountId IS NULL)
					AND I.strType = 'Software'				
					
				--Other Charge Income Account	
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Other Charge Income account of item - ' + I.strItemNo + ' is not valid.' ELSE 'The Other Charge Income Account of item - ' + I.strItemNo + ' was not specified.' END,					
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON Acct.intOtherChargeIncomeAccountId = GLA.intAccountId										
				WHERE
					(ISNULL(Acct.intOtherChargeIncomeAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND I.strType = 'Other Charge'	


				--Sales Account				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Sales Account of item - ' + I.strItemNo + ' is not valid.' ELSE 'The Sales Account of item - ' + I.strItemNo + ' was not specified.' END,
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON Acct.intSalesAccountId = GLA.intAccountId	 				
				WHERE
					D.dblTotal <> @ZeroDecimal 
					AND (D.intItemId IS NOT NULL OR D.intItemId <> 0)
					AND I.strType NOT IN ('Non-Inventory','Service','Other Charge','Software')
					AND (ISNULL(Acct.intSalesAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND A.strTransactionType <> 'Debit Memo'
					AND ISNULL(A.intPeriodsToAccrue,0) <= 1

				--Sales Account				
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Sales Account of line item - ' + D.strItemDescription + ' is not valid.' ELSE 'The Sales Account of line item - ' + D.strItemDescription + ' was not specified.' END,
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON D.intSalesAccountId = GLA.intAccountId
				WHERE
					D.dblTotal <> @ZeroDecimal 
					AND (ISNULL(D.intSalesAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND A.strTransactionType = 'Debit Memo'
					AND ISNULL(A.intPeriodsToAccrue,0) <= 1


                --Sales Tax Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Sales Tax account of Tax Code - ' + TC.strTaxCode + ' is not valid.' ELSE 'The Sales Tax account of Tax Code - ' + TC.strTaxCode + ' was not set.' END,					
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ISNULL(DT.intSalesTaxAccountId, TC.intSalesTaxAccountId) = GLA.intAccountId	
				WHERE
					DT.dblAdjustedTax <> @ZeroDecimal
					AND (ISNULL(ISNULL(DT.intSalesTaxAccountId, TC.intSalesTaxAccountId), 0) = 0 OR GLA.intAccountId IS NULL)

                --COGS Account -- SHIPPED
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The COGS Account of item - ' + I.strItemNo + ' is not valid.' ELSE 'The COGS Account of item - ' + I.strItemNo + ' was not specified.' END,
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM
					tblARInvoiceDetail D
				INNER JOIN			
					tblARInvoice A 
						ON D.intInvoiceId = A.intInvoiceId
						AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId 
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON IST.intCOGSAccountId = GLA.intAccountId
				WHERE
					D.dblTotal <> @ZeroDecimal
					AND (ISNULL(D.intInventoryShipmentItemId,0) <> 0 OR ISNULL(D.intShipmentPurchaseSalesContractId,0) <> 0)
					AND (ISNULL(IST.intCOGSAccountId,0) = 0 OR GLA.intAccountId IS NULL)
					AND ISNULL(D.intItemId, 0) <> 0
					AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
					AND A.strTransactionType <> 'Debit Memo'


				--Inventory In-Transit Account Account -- SHIPPED
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Inventory In-Transit Account of item - ' + I.strItemNo + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + I.strItemNo + ' was not specified.' END,
					A.strTransactionType,
					A.strInvoiceNumber,
					@batchId,
					A.intInvoiceId
				FROM
					tblARInvoiceDetail D
				INNER JOIN			
					tblARInvoice A 
						ON D.intInvoiceId = A.intInvoiceId
						AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				INNER JOIN
					tblICItemUOM ItemUOM 
						ON ItemUOM.intItemUOMId = D.intItemUOMId
				INNER JOIN
					tblICItem I
						ON D.intItemId = I.intItemId
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
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON IST.intInventoryInTransitAccountId = GLA.intAccountId				
				WHERE
					D.dblTotal <> @ZeroDecimal
					AND (ISNULL(D.intInventoryShipmentItemId,0) <> 0 OR ISNULL(D.intShipmentPurchaseSalesContractId,0) <> 0)
					AND ISNULL(D.intItemId, 0) <> 0
					AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
					AND A.strTransactionType <> 'Debit Memo'	
					AND (ISNULL(IST.intInventoryInTransitAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					
					
				--COGS Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The COGS Account of item - ' + ICI.strItemNo + ' is not valid.' ELSE 'The COGS Account of item - ' + ICI.strItemNo + ' was not specified.' END,
					Header.strTransactionType,
					Header.strInvoiceNumber,
					@batchId,
					Header.intInvoiceId
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
					tblICItem ICI
						ON Detail.intItemId = ICI.intItemId 
				LEFT OUTER JOIN
					vyuARGetItemAccount ARIA
						ON Detail.intItemId = ARIA.intItemId 
						AND Header.intCompanyLocationId = ARIA.intLocationId 
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ARIA.intCOGSAccountId = GLA.intAccountId	
				WHERE
					Detail.dblTotal <> @ZeroDecimal
					AND (ISNULL(Detail.intInventoryShipmentItemId,0) <> 0 OR ISNULL(Detail.intShipmentPurchaseSalesContractId,0) <> 0)
					AND ISNULL(Detail.intItemId, 0) <> 0
					AND (ISNULL(ARIA.intCOGSAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND ICI.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
					AND Header.strTransactionType <> 'Debit Memo'
					
					
				--COGS Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The COGS Account of item - ' + ICI.strItemNo + ' is not valid.' ELSE 'The COGS Account of item - ' + ICI.strItemNo + ' was not specified.' END,
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM
					vyuARGetItemComponents ARIC
				INNER JOIN
					tblARInvoiceDetail ARID
						ON ARIC.[intItemId] = ARID.[intItemId]
				INNER JOIN
					tblARInvoice ARI
						ON ARID.[intInvoiceId] = ARI.[intInvoiceId] AND ARIC.[intCompanyLocationId] = ARI.[intCompanyLocationId]
				INNER JOIN
					@PostInvoiceData P
						ON ARI.[intInvoiceId] = P.[intInvoiceId]		
				INNER JOIN
					tblICItem ICI
						ON ARIC.[intComponentItemId] = ICI.[intItemId]
				LEFT OUTER JOIN
					tblICItemUOM ICIUOM
						ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
				LEFT OUTER JOIN
					vyuARGetItemAccount ARIA
						ON ARID.intItemId = ARIA.intItemId 
						AND ARI.intCompanyLocationId = ARIA.intLocationId 	
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ARIA.intCOGSAccountId = GLA.intAccountId	 
				WHERE
					ARID.[dblTotal] <> 0
					AND (ISNULL(ARID.intInventoryShipmentItemId,0) <> 0 OR ISNULL(ARID.intShipmentPurchaseSalesContractId,0) <> 0)
					AND ISNULL(ARID.[intItemId],0) <> 0
					AND ISNULL(ARIC.[intComponentItemId],0) <> 0
					AND (ISNULL(ARIA.intCOGSAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND ARI.[strTransactionType] <> 'Debit Memo'		
					AND ARIC.strType <> 'Finished Good'

				--Inventory In-Transit Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.strItemNo + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.strItemNo + ' was not specified.' END,
					Header.strTransactionType,
					Header.strInvoiceNumber,
					@batchId,
					Header.intInvoiceId
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
					tblICItem ICI
						ON Detail.intItemId = ICI.intItemId 
				LEFT OUTER JOIN
					vyuARGetItemAccount ARIA
						ON Detail.intItemId = ARIA.intItemId 
						AND Header.intCompanyLocationId = ARIA.intLocationId 
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ARIA.intInventoryInTransitAccountId = GLA.intAccountId
				WHERE
					Detail.dblTotal <> @ZeroDecimal
					AND (ISNULL(Detail.intInventoryShipmentItemId,0) <> 0 OR ISNULL(Detail.intShipmentPurchaseSalesContractId,0) <> 0)
					AND ISNULL(Detail.intItemId, 0) <> 0
					AND (ISNULL(ARIA.intInventoryInTransitAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND ICI.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
					AND Header.strTransactionType <> 'Debit Memo'
					
					
				--Inventory In-Transit Account
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					CASE WHEN GLA.intAccountId IS NULL THEN 'The Inventory In-Transit Account of item - ' + ICI.strItemNo + ' is not valid.' ELSE 'The Inventory In-Transit Account of item - ' + ICI.strItemNo + ' was not specified.' END,
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM
					vyuARGetItemComponents ARIC
				INNER JOIN
					tblARInvoiceDetail ARID
						ON ARIC.[intItemId] = ARID.[intItemId]
				INNER JOIN
					tblARInvoice ARI
						ON ARID.[intInvoiceId] = ARI.[intInvoiceId] AND ARIC.[intCompanyLocationId] = ARI.[intCompanyLocationId]
				INNER JOIN
					@PostInvoiceData P
						ON ARI.[intInvoiceId] = P.[intInvoiceId]		
				INNER JOIN
					tblICItem ICI
						ON ARIC.[intComponentItemId] = ICI.[intItemId]
				LEFT OUTER JOIN
					tblICItemUOM ICIUOM
						ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
				LEFT OUTER JOIN
					vyuARGetItemAccount ARIA
						ON ARID.intItemId = ARIA.intItemId 
						AND ARI.intCompanyLocationId = ARIA.intLocationId
				LEFT OUTER JOIN
					tblGLAccount GLA
						ON ARIA.intInventoryInTransitAccountId = GLA.intAccountId 		 
				WHERE
					ARID.[dblTotal] <> 0
					AND (ISNULL(ARID.intInventoryShipmentItemId,0) <> 0 OR ISNULL(ARID.intShipmentPurchaseSalesContractId,0) <> 0)
					AND ISNULL(ARID.[intItemId],0) <> 0
					AND ISNULL(ARIC.[intComponentItemId],0) <> 0
					AND (ISNULL(ARIA.intInventoryInTransitAccountId, 0) = 0 OR GLA.intAccountId IS NULL)
					AND ARI.[strTransactionType] <> 'Debit Memo'																		
					AND ARIC.strType <> 'Finished Good'
				
				--Zero Contract Item Price	
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT
					'The contract item - ' + I.strItemNo + ' price cannot be zero.',
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
					'The contract item - ' + I.strItemNo + ' price(' + CONVERT(NVARCHAR(100),CAST(ISNULL(D.dblPrice,@ZeroDecimal) AS MONEY),2) + ') is not equal to the contract sequence cash price(' + CONVERT(NVARCHAR(100),CAST((ISNULL([dbo].[fnCalculateQtyBetweenUOM](CT.[intItemUOMId],CT.[intPriceItemUOMId],1) * [dbo].[fnConvertToBaseCurrency](CT.[intSeqCurrencyId], CT.[dblCashPrice]), CT.[dblCashPrice])) AS MONEY),2) + ').',
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
					AND CAST((ISNULL([dbo].[fnCalculateQtyBetweenUOM](CT.[intItemUOMId],CT.[intPriceItemUOMId],1) * [dbo].[fnConvertToBaseCurrency](CT.[intSeqCurrencyId], CT.[dblCashPrice]), CT.[dblCashPrice])) AS MONEY) <> CAST(ISNULL(D.dblPrice,0) AS MONEY)
					AND CT.strPricingType <> 'Index'


				--Fiscal Year
				INSERT INTO @InvalidInvoiceData(strError, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
				SELECT 
					'Unable to find an open fiscal year period to match the transaction date.',
					ARI.strTransactionType,
					ARI.strInvoiceNumber,
					@batchId,
					ARI.intInvoiceId
				FROM
					@PostInvoiceData PID
				INNER JOIN 
					tblARInvoice ARI 
						ON PID.intInvoiceId = ARI.intInvoiceId
				WHERE  
					ISNULL(dbo.isOpenAccountingDate(ISNULL(ARI.dtmPostDate, ARI.dtmDate)), 0) = 0
					
					
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
							IF (XACT_STATE()) = -1
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
						AND ISNULL(A.ysnPosted,0) = 1
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
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblInvoiceTotal ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblInvoiceTotal END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
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
				,dblCreditUnit				=  CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  
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
			

			UNION ALL

			--Debit Payment
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= SMCL.intUndepositedFundsId 
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  A.dblPayment ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  0 ELSE A.dblPayment END
				,dblDebitUnit				= @ZeroDecimal
				,dblCreditUnit				= @ZeroDecimal		
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
			INNER JOIN
				tblSMCompanyLocation SMCL
					ON A.intCompanyLocationId = SMCL.intCompanyLocationId
			WHERE
				ISNULL(A.intPeriodsToAccrue,0) <= 1
				AND A.dblPayment <> @ZeroDecimal
			
			UNION ALL
			--Credit Prepaids
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ARI1.intAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  @ZeroDecimal ELSE ARPAC.[dblAppliedInvoiceDetailAmount] END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN  ARPAC.[dblAppliedInvoiceDetailAmount] ELSE @ZeroDecimal END
				,dblDebitUnit				= @ZeroDecimal 
				,dblCreditUnit				= @ZeroDecimal
				,strDescription				= A.strComments
				,strCode					= @CODE
				,strReference				= C.strCustomerNumber
				,intCurrencyId				= A.intCurrencyId 
				,dblExchangeRate			= 1
				,dtmDateEntered				= @PostDate
				,dtmTransactionDate			= A.dtmDate
				,strJournalLineDescription	= 'Applied Prepaid - ' + ARI1.[strInvoiceNumber] 
				,intJournalLineNo			= ARPAC.[intPrepaidAndCreditId]
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
				tblARPrepaidAndCredit ARPAC
			INNER JOIN
				tblARInvoice A
					ON ARPAC.[intInvoiceId] = A.[intInvoiceId] 
					AND ISNULL(ARPAC.[ysnApplied],0) = 1
					AND ARPAC.[dblAppliedInvoiceDetailAmount] <> @ZeroDecimal
			INNER JOIN
				tblARInvoice ARI1
					ON ARPAC.[intPrepaymentId] = ARI1.[intInvoiceId] 
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
														ISNULL(ISNULL(B.intServiceChargeAccountId, B.intSalesAccountId), SMCL.intSalesAccount)
												END)
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00)))  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) ELSE 0  END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, 0.00)) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL([dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped),ISNULL(B.dblQtyShipped, 0.00)) ELSE 0 END				
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
			LEFT OUTER JOIN
				tblSMCompanyLocation SMCL
					ON A.intCompanyLocationId = SMCL.intCompanyLocationId 						
			WHERE
				B.dblTotal <> @ZeroDecimal 
				AND ((B.intItemId IS NULL OR B.intItemId = 0)
					OR (EXISTS(SELECT NULL FROM tblICItem WHERE intItemId = B.intItemId AND strType IN ('Non-Inventory','Service','Other Charge','Software'))))
				AND A.strTransactionType <> 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT SALES
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) ELSE 0 END				
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
				AND A.strTransactionType <> 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT SALES - Debit Memo
			UNION ALL 
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= B.intSalesAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ISNULL(B.dblTotal, 0.00) + ((ISNULL(B.dblDiscount, 0.00)/100.00) * (ISNULL(B.dblQtyShipped, 0.00) * ISNULL(B.dblPrice, 0.00))) ELSE  0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN [dbo].[fnCalculateQtyBetweenUOM](B.intItemUOMId, ICIS.intStockUOMId, B.dblQtyShipped) ELSE 0 END				
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
				AND A.strTransactionType = 'Debit Memo'
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1

			--CREDIT Shipping
			UNION ALL 
			SELECT
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= L.intFreightIncome
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE A.dblShipping END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN A.dblShipping ELSE 0  END
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
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblAdjustedTax < 0 THEN ABS(DT.dblAdjustedTax) ELSE 0 END 
											  ELSE 
													CASE WHEN DT.dblAdjustedTax < 0 THEN 0 ELSE DT.dblAdjustedTax END
											  END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 
													CASE WHEN DT.dblAdjustedTax < 0 THEN 0 ELSE DT.dblAdjustedTax END 
											  ELSE 
													CASE WHEN DT.dblAdjustedTax < 0 THEN ABS(DT.dblAdjustedTax) ELSE 0 END 
											  END
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
				AND ISNULL(A.intPeriodsToAccrue,0) <= 1
				
			UNION ALL 
			--DEBIT Discount
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) END
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

			--Credit Discount
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= ISNULL(IST.intDiscountAccountId, @DiscountAccountId)
				,dblDebit					= CASE WHEN A.intPeriodsToAccrue > 1 THEN  CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN 0 ELSE ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) END
												ELSE 0 END
				,dblCredit					= CASE WHEN A.intPeriodsToAccrue > 1 THEN CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) ELSE 0 END
												ELSE 0 END
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
				(CASE WHEN A.intPeriodsToAccrue > 1 THEN CASE WHEN A.strTransactionType IN ('Invoice', 'Debit Memo', 'Cash') THEN ((D.dblDiscount/100.00) * (D.dblQtyShipped * D.dblPrice)) ELSE 0 END ELSE 0 END) <> @ZeroDecimal

			UNION ALL 
			--DEBIT COGS - SHIPPED
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intCOGSAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICT.dblQty) * ICT.dblCost) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblCost) END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICT.dblQty) * ICT.dblUOMQty) ELSE 0 END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblUOMQty) END				
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
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
				AND A.strTransactionType <> 'Debit Memo'
				
			UNION ALL 
			--CREDIT Inventory In-Transit - SHIPPED
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intInventoryInTransitAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblCost) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICT.dblQty) * ICT.dblCost) ELSE 0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ABS(ICT.dblQty) * ICT.dblUOMQty) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ABS(ICT.dblQty) * ICT.dblUOMQty) ELSE 0 END				
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
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
				AND A.strTransactionType <> 'Debit Memo'	
				
			UNION ALL 
			--DEBIT COGS - Inbound Shipment
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intCOGSAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ICT.dblCashPrice * D.dblQtyShipped) ELSE 0 END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ICT.dblCashPrice * D.dblQtyShipped) END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) ELSE 0 END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) END				
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
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
				AND A.strTransactionType <> 'Debit Memo'
				
			UNION ALL 
			--CREDIT Inventory In-Transit - Inbound Shipment
			SELECT			
				 dtmDate					= CAST(ISNULL(A.dtmPostDate, A.dtmDate) AS DATE)
				,strBatchID					= @batchId
				,intAccountId				= IST.intInventoryInTransitAccountId
				,dblDebit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE (ICT.dblCashPrice * D.dblQtyShipped) END
				,dblCredit					= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN (ICT.dblCashPrice * D.dblQtyShipped) ELSE 0 END
				,dblDebitUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN 0 ELSE [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) END
				,dblCreditUnit				= CASE WHEN A.strTransactionType IN ('Invoice', 'Cash') THEN [dbo].[fnCalculateQtyBetweenUOM](D.intItemUOMId, ICIS.intStockUOMId, D.dblQtyShipped) ELSE 0 END				
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
				AND IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle')
				AND A.strTransactionType <> 'Debit Memo'
		END TRY
		BEGIN CATCH
			SELECT @ErrorMerssage = ERROR_MESSAGE()										
			GOTO Do_Rollback
		END CATCH

		DECLARE @AVERAGECOST AS INT = 1
				,@FIFO AS INT = 2
				,@LIFO AS INT = 3
				,@LOTCOST AS INT = 4
				,@ACTUALCOST AS INT = 5

		--Update onhand
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
				 intItemId					= Detail.intItemId  
				,intItemLocationId			= IST.intItemLocationId
				,intItemUOMId				= Detail.intItemUOMId  
				,dtmDate					= Header.dtmShipDate
				,dblQty						= (Detail.dblQtyShipped * (CASE WHEN Header.strTransactionType IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN @post = 0 THEN -1 ELSE 1 END
				,dblUOMQty					= ItemUOM.dblUnitQty
				-- If item is using average costing, it must use the average cost. 
				-- Otherwise, it must use the last cost value of the item. 
				,dblCost					= ISNULL(dbo.fnMultiply (	CASE WHEN IST.strType = 'Finished Good' AND Detail.ysnBlended = 1 
																			THEN (
																				SELECT SUM(ICIT.[dblCost]) 
																				FROM
																					tblICInventoryTransaction ICIT
																				INNER JOIN
																					tblMFWorkOrder MFWO
																						ON ICIT.[strTransactionId] = MFWO.[strWorkOrderNo]
																						AND ICIT.[intTransactionId] = MFWO.[intBatchID] 
																				WHERE
																					MFWO.[intWorkOrderId] = (SELECT MAX(tblMFWorkOrder.intWorkOrderId)FROM tblMFWorkOrder WHERE tblMFWorkOrder.intInvoiceDetailId = Detail.intInvoiceDetailId)
																					AND ICIT.[ysnIsUnposted] = 0
																					AND ICIT.[strTransactionForm] = 'Produce'
																			)
																			ELSE
																				CASE	WHEN dbo.fnGetCostingMethod(Detail.intItemId, IST.intItemLocationId) = @AVERAGECOST THEN 
																							dbo.fnGetItemAverageCost(Detail.intItemId, IST.intItemLocationId, Detail.intItemUOMId) 
																						ELSE 
																							IST.dblLastCost  
																				END 
																		END
																		,ItemUOM.dblUnitQty
																	),@ZeroDecimal)
				,dblSalesPrice				= Detail.dblPrice 
				,intCurrencyId				= Header.intCurrencyId
				,dblExchangeRate			= 1.00
				,intTransactionId			= Header.intInvoiceId
				,intTransactionDetailId		= Detail.intInvoiceDetailId
				,strTransactionId			= Header.strInvoiceNumber 
				,intTransactionTypeId		= @INVENTORY_SHIPMENT_TYPE
				,intLotId					= NULL 
				,intSubLocationId			= Detail.intCompanyLocationSubLocationId 
				,intStorageLocationId		= Detail.intStorageLocationId
				,strActualCostId			= CASE WHEN (ISNULL(Header.intDistributionHeaderId,0) <> 0 OR ISNULL(Header.intLoadDistributionHeaderId,0) <> 0) THEN Header.strActualCostId ELSE NULL END
			FROM 
				tblARInvoiceDetail Detail
			INNER JOIN
				tblARInvoice Header
					ON Detail.intInvoiceId = Header.intInvoiceId
					AND Header.strTransactionType  IN ('Invoice', 'Credit Memo', 'Cash', 'Cash Refund')
					AND ISNULL(Header.intPeriodsToAccrue,0) <= 1
					and 1 = CASE	
								WHEN Header.strTransactionType = 'Credit Memo'
									THEN Header.ysnImpactInventory
									ELSE 1
								END

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
				((ISNULL(Header.strImportFormat, '') <> 'CarQuest' AND Detail.dblTotal <> 0) OR ISNULL(Header.strImportFormat, '') = 'CarQuest') 
				AND (Detail.intInventoryShipmentItemId IS NULL OR Detail.intInventoryShipmentItemId = 0)
				AND (Detail.intShipmentPurchaseSalesContractId IS NULL OR Detail.intShipmentPurchaseSalesContractId = 0)
				AND Detail.intItemId IS NOT NULL AND Detail.intItemId <> 0
				AND (IST.strType NOT IN ('Non-Inventory','Service','Other Charge','Software','Bundle') OR (IST.strType = 'Finished Good' AND Detail.ysnBlended = 1))
				AND Header.strTransactionType <> 'Debit Memo'
				

			UNION ALL

			SELECT
				 intItemId					= ARIC.[intComponentItemId]
				,intItemLocationId			= IST.intItemLocationId
				,intItemUOMId				= ARIC.[intItemUnitMeasureId] 
				,dtmDate					= ARI.[dtmShipDate]
				,dblQty						= ((ARID.[dblQtyShipped] * ARIC.[dblQuantity]) * (CASE WHEN ARI.[strTransactionType] IN ('Invoice', 'Cash') THEN -1 ELSE 1 END)) * CASE WHEN @post = 0 THEN -1 ELSE 1 END
				,dblUOMQty					= ICIUOM.[dblUnitQty]
				-- If item is using average costing, it must use the average cost. 
				-- Otherwise, it must use the last cost value of the item. 
				,dblCost					= ISNULL(dbo.fnMultiply (	CASE	WHEN dbo.fnGetCostingMethod(ARIC.[intComponentItemId], IST.intItemLocationId) = @AVERAGECOST THEN 
																					dbo.fnGetItemAverageCost(ARIC.[intComponentItemId], IST.intItemLocationId, ARIC.[intItemUnitMeasureId]) 
																				ELSE 
																					IST.dblLastCost  
																		END 
																		,ICIUOM.dblUnitQty
																),@ZeroDecimal)
				,dblSalesPrice				= ARID.[dblPrice]
				,intCurrencyId				= ARI.[intCurrencyId]
				,dblExchangeRate			= 1.00
				,intTransactionId			= ARI.[intInvoiceId]
				,intTransactionDetailId		= ARID.[intInvoiceDetailId]
				,strTransactionId			= ARI.[strInvoiceNumber]
				,intTransactionTypeId		= @INVENTORY_SHIPMENT_TYPE
				,intLotId					= NULL 
				,intSubLocationId			= ARID.intCompanyLocationSubLocationId
				,intStorageLocationId		= ARID.intStorageLocationId
				,strActualCostId			= CASE WHEN (ISNULL(ARI.intDistributionHeaderId,0) <> 0 OR ISNULL(ARI.intLoadDistributionHeaderId,0) <> 0) THEN ARI.strActualCostId ELSE NULL END
			FROM
				vyuARGetItemComponents ARIC
			INNER JOIN
				tblARInvoiceDetail ARID
					ON ARIC.[intItemId] = ARID.[intItemId]
			INNER JOIN
				tblARInvoice ARI
					ON ARID.[intInvoiceId] = ARI.[intInvoiceId] AND ARIC.[intCompanyLocationId] = ARI.[intCompanyLocationId]
			INNER JOIN
				@PostInvoiceData P
					ON ARI.[intInvoiceId] = P.[intInvoiceId]		
			INNER JOIN
				tblICItem ICI
					ON ARIC.[intComponentItemId] = ICI.[intItemId]
			LEFT OUTER JOIN
				tblICItemUOM ICIUOM
					ON ARIC.[intItemUnitMeasureId] = ICIUOM.[intItemUOMId]
			LEFT OUTER JOIN
				vyuICGetItemStock IST
					ON ARIC.[intComponentItemId] = IST.intItemId 
					AND ARI.[intCompanyLocationId] = IST.intLocationId 			 
			WHERE
				((ISNULL(ARI.[strImportFormat], '') <> 'CarQuest' AND ARID.[dblTotal] <> @ZeroDecimal) OR ISNULL(ARI.[strImportFormat], '') = 'CarQuest')
				AND ISNULL(ARID.[intInventoryShipmentItemId],0) = 0
				AND ISNULL(ARID.[intShipmentPurchaseSalesContractId],0) = 0
				AND ISNULL(ARID.[intItemId],0) <> 0
				AND ISNULL(ARIC.[intComponentItemId],0) <> 0
				AND ARI.[strTransactionType] <> 'Debit Memo'
				AND ARIC.strType <> 'Finished Good'
			
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

		BEGIN TRY 
			EXEC dbo.uspGLBookEntries @GLEntries, @post
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
				 GLD.dtmDate 
				,@batchId
				,GLD.intAccountId
				,dblDebit						= GLD.dblCredit
				,dblCredit						= GLD.dblDebit
				,dblDebitUnit					= GLD.dblCreditUnit
				,dblCreditUnit					= GLD.dblDebitUnit
				,GLD.strDescription
				,GLD.strCode
				,GLD.strReference
				,GLD.intCurrencyId
				,GLD.dblExchangeRate
				,dtmDateEntered					= GETDATE()
				,GLD.dtmTransactionDate
				,GLD.strJournalLineDescription
				,GLD.intJournalLineNo 
				,ysnIsUnposted					= 1
				,intUserId						= @userId
				,intEntityId					= @UserEntityID
				,GLD.strTransactionId
				,GLD.intTransactionId
				,GLD.strTransactionType
				,GLD.strTransactionForm
				,GLD.strModuleName
				,GLD.intConcurrencyId
			FROM
				@PostInvoiceData PID
			INNER JOIN
				dbo.tblGLDetail GLD
					ON PID.intInvoiceId = GLD.intTransactionId
					AND PID.strTransactionId = GLD.strTransactionId
			WHERE
				GLD.ysnIsUnposted = 0
				--AND GL.strCode = 'AR'
			ORDER BY
				GLD.intGLDetailId		
						
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
				 PID.intInvoiceId
				,PID.strTransactionId
			FROM
				@PostInvoiceData PID
			INNER JOIN
				dbo.tblARInvoiceDetail ARID
					ON PID.intInvoiceId = ARID.intInvoiceId					
			INNER JOIN
				dbo.tblARInvoice ARI
					ON ARID.intInvoiceId = ARI.intInvoiceId
					AND ARI.strTransactionType IN ('Invoice', 'Credit Memo', 'Cash', 'Cash Refund')			
			INNER JOIN
				dbo.tblICItemUOM ItemUOM 
					ON ItemUOM.intItemUOMId = ARID.intItemUOMId
			LEFT OUTER JOIN
				dbo.vyuICGetItemStock IST
					ON ARID.intItemId = IST.intItemId 
					AND ARI.intCompanyLocationId = IST.intLocationId 
			WHERE 
				(ARID.intInventoryShipmentItemId IS NULL OR ARID.intInventoryShipmentItemId = 0)
				--AND (Detail.intSalesOrderDetailId IS NULL OR Detail.intSalesOrderDetailId = 0)
				--AND (Detail.intShipmentPurchaseSalesContractId IS NULL OR Detail.intShipmentPurchaseSalesContractId = 0)
				AND (ARID.intItemId IS NOT NULL OR ARID.intItemId <> 0)
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

		DELETE GLDR  
		FROM 
			@PostInvoiceData PID  
		INNER JOIN 
			dbo.tblGLDetailRecap GLDR 
				ON (PID.strTransactionId = GLDR.strTransactionId OR PID.intInvoiceId = GLDR.intTransactionId)  
				AND GLDR.strCode = @CODE  
		   
		   
		BEGIN TRY		
			INSERT INTO dbo.tblGLDetailRecap (  
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
					EXEC dbo.uspARInsertPostResult @batchId, 'Invoice', @ErrorMerssage, @param		
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
			IF @post = 0
				BEGIN

					UPDATE ARI
					SET
						ARI.dblPayment	= ARI.dblPayment - ISNULL((SELECT SUM(tblARPrepaidAndCredit.dblAppliedInvoiceDetailAmount) FROM tblARPrepaidAndCredit WHERE tblARPrepaidAndCredit.intInvoiceId = ARI.intInvoiceId AND tblARPrepaidAndCredit.ysnApplied = 1), @ZeroDecimal)
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblARInvoice ARI
							ON PID.intInvoiceId = ARI.intInvoiceId 

					UPDATE ARI
					SET
						 ARI.ysnPosted				= 0
						,ARI.ysnPaid				= 0
						,ARI.dblAmountDue			= ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
						,ARI.dblDiscount			= @ZeroDecimal
						,ARI.dblDiscountAvailable	= @ZeroDecimal
						,ARI.dblInterest			= @ZeroDecimal
						,ARI.dblPayment				= ISNULL(dblPayment, @ZeroDecimal)
						,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
						,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblARInvoice ARI
							ON PID.intInvoiceId = ARI.intInvoiceId 					

					UPDATE GLD						
					SET
						GLD.ysnIsUnposted = 1
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblGLDetail GLD
							ON PID.intInvoiceId = GLD.intTransactionId
							AND PID.strTransactionId = GLD.strTransactionId

					--Insert Successfully unposted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,ARI.strTransactionType
						,ARI.strInvoiceNumber
						,@batchId
						,ARI.intInvoiceId
					FROM
						@PostInvoiceData PID
					INNER JOIN						
						dbo.tblARInvoice ARI
							ON PID.intInvoiceId = ARI.intInvoiceId
						
					--Update tblHDTicketHoursWorked ysnBilled					
					UPDATE HDTHW						
					SET
						 HDTHW.ysnBilled = 0
						,HDTHW.dtmBilled = NULL
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblHDTicketHoursWorked HDTHW
							ON PID.intInvoiceId = HDTHW.intInvoiceId
						
					BEGIN TRY
						DECLARE @TankDeliveryForUnSync TABLE (
								intInvoiceId INT,
								UNIQUE (intInvoiceId));
								
						INSERT INTO @TankDeliveryForUnSync					
						SELECT DISTINCT
							ARI.intInvoiceId
						FROM
							@PostInvoiceData PID
						INNER JOIN 															
							dbo.tblARInvoice ARI
								ON PID.intInvoiceId = ARI.intInvoiceId
						INNER JOIN
							dbo.tblARInvoiceDetail ARID
								ON ARI.intInvoiceId = ARID.intInvoiceId		
						INNER JOIN
							dbo.tblTMSite TMS
								ON ARID.intSiteId = TMS.intSiteID 						
								
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

					UPDATE ARI						
					SET
						 ARI.ysnPosted				= 1
						,ARI.ysnPaid				= (CASE WHEN ARI.dblInvoiceTotal = 0.00 OR ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN 1 ELSE 0 END)
						,ARI.dblInvoiceTotal		= ARI.dblInvoiceTotal
						,ARI.dblAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN @ZeroDecimal ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) END) - (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
						,ARI.dblDiscount			= @ZeroDecimal
						,ARI.dblDiscountAvailable	= @ZeroDecimal
						,ARI.dblInterest			= @ZeroDecimal
						,ARI.dblPayment				= (CASE WHEN ARI.strTransactionType IN ('Cash', 'Cash Refund' ) THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
						,ARI.dtmPostDate			= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
						,ARI.intConcurrencyId		= ISNULL(ARI.intConcurrencyId,0) + 1	
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblARInvoice ARI
							ON PID.intInvoiceId = ARI.intInvoiceId


					UPDATE ARPD
					SET
						ARPD.dblInvoiceTotal = ARI.dblInvoiceTotal 
						,ARPD.dblAmountDue = (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblARInvoice ARI
							ON PID.intInvoiceId = ARI.intInvoiceId
					INNER JOIN
						dbo.tblARPaymentDetail ARPD
							ON ARI.intInvoiceId = ARPD.intInvoiceId 


					--Insert Successfully posted transactions.
					INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
					SELECT 
						@PostSuccessfulMsg
						,ARI.strTransactionType
						,ARI.strInvoiceNumber
						,@batchId
						,ARI.intInvoiceId
					FROM
						@PostInvoiceData PID
					INNER JOIN						
						dbo.tblARInvoice ARI
							ON PID.intInvoiceId = ARI.intInvoiceId
					
					--Update tblHDTicketHoursWorked ysnBilled					
					UPDATE HDTHW						
					SET
						 HDTHW.ysnBilled = 1
						,HDTHW.dtmBilled = GETDATE()
					FROM
						@PostInvoiceData PID
					INNER JOIN
						dbo.tblHDTicketHoursWorked HDTHW
							ON PID.intInvoiceId = HDTHW.intInvoiceId
						
					BEGIN TRY
						DECLARE @TankDeliveryForSync TABLE (
								intInvoiceId INT,
								UNIQUE (intInvoiceId));
								
						INSERT INTO @TankDeliveryForSync					
						SELECT DISTINCT
							I.intInvoiceId
						FROM
							dbo.tblARInvoice I
						INNER JOIN
							dbo.tblARInvoiceDetail D
								ON I.intInvoiceId = D.intInvoiceId		
						INNER JOIN
							dbo.tblTMSite TMS
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

		DELETE dbo.tblARPrepaidAndCredit  
		FROM 
			dbo.tblARPrepaidAndCredit A 
		INNER JOIN @PostInvoiceData B  
		   ON A.intInvoiceId = B.intInvoiceId
		   AND (ISNULL(A.ysnApplied,0) = 0 OR @post = 0)
																
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