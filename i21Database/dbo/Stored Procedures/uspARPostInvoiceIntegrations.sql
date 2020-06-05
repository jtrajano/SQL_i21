CREATE PROCEDURE [dbo].[uspARPostInvoiceIntegrations]
     @Post              BIT				= 0
	,@BatchId           NVARCHAR(40)
    ,@UserId            INT
	,@IntegrationLogId	INT             = NULL
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

DECLARE @ZeroDecimal	DECIMAL(18,6) = 0.000000
DECLARE @OneDecimal		DECIMAL(18,6) = 1.000000
DECLARE @ysnImposeReversalTransaction BIT = 0

DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
DECLARE @Invoices AS dbo.[InvoiceId]

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

SELECT TOP 1 @ysnImposeReversalTransaction  = ISNULL(ysnImposeReversalTransaction, 0)
FROM tblRKCompanyPreference

SET @ysnImposeReversalTransaction = ISNULL(@ysnImposeReversalTransaction, 0)

IF @InitTranCount = 0
	BEGIN TRANSACTION
ELSE
	SAVE TRANSACTION @Savepoint

BEGIN TRY

IF @Post = 1
BEGIN
    UPDATE ARI						
    SET ARI.ysnPosted					= 1
	  , ARI.ysnProcessed				= CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ARI.strType = 'POS' THEN 1 ELSE 0 END
      , ARI.ysnPaid						= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.dblAmountDue = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
      , ARI.dblAmountDue				= (CASE WHEN ARI.strTransactionType IN ('Cash')
												THEN @ZeroDecimal
												ELSE (CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
															THEN 
																CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) > @ZeroDecimal
																		THEN ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal))
																		ELSE (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal)
																END
															ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
														END) 
											END)
       , ARI.dblBaseAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash')
												THEN @ZeroDecimal 
												ELSE (CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
															THEN 
																CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) > @ZeroDecimal
																		THEN ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal))
																		ELSE (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal)
																END
															ELSE ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)
														END) 
											END)
       , ARI.dblDiscount				= @ZeroDecimal
       , ARI.dblBaseDiscount			= @ZeroDecimal
       , ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
       , ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
       , ARI.dblInterest				= @ZeroDecimal
       , ARI.dblBaseInterest			= @ZeroDecimal
       , ARI.dblPayment					= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
       , ARI.dblBasePayment				= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END)
       , ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
       , ARI.ysnExcludeFromPayment		= PID.ysnExcludeInvoiceFromPayment
       , ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1	
	   , ARI.intPeriodId       		    = ACCPERIOD.intGLFiscalYearPeriodId
									  
    FROM #ARPostInvoiceHeader PID
    INNER JOIN (
		SELECT intInvoiceId
			 , strType
			 , ysnProcessed
			 , ysnPosted
			 , ysnPaid
			 , dblInvoiceTotal
			 , dblBaseInvoiceTotal
			 , dblAmountDue
			 , dblBaseAmountDue
			 , dblDiscount
			 , dblBaseDiscount
			 , dblDiscountAvailable
			 , dblBaseDiscountAvailable
			 , dblInterest
			 , dblBaseInterest
			 , dblPayment
			 , dblBasePayment
			 , dtmPostDate
			 , intConcurrencyId
			 , intSourceId
			 , intOriginalInvoiceId
			 , dblProvisionalAmount
			 , dblBaseProvisionalAmount
			 , strTransactionType
			 , dtmDate
			 , ysnExcludeFromPayment
			 , intPeriodId
		FROM dbo.tblARInvoice WITH (NOLOCK)
	) ARI ON PID.intInvoiceId = ARI.intInvoiceId
	Outer Apply (
		SELECT P.intGLFiscalYearPeriodId FROM tblGLFiscalYearPeriod P
		WHERE DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, P.dtmEndDate) + 1, 0)) = DATEADD(d, -1, DATEADD(m, DATEDIFF(m, 0, ARI.dtmPostDate) + 1, 0))
	) ACCPERIOD

    UPDATE ARPD
    SET ARPD.dblInvoiceTotal		= ARI.dblInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
      , ARPD.dblBaseInvoiceTotal	= ARI.dblBaseInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
      , ARPD.dblAmountDue			= (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
      , ARPD.dblBaseAmountDue		= (ARI.dblBaseInvoiceTotal + ISNULL(ARPD.dblBaseInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblBasePayment, @ZeroDecimal) + ISNULL(ARPD.dblBaseDiscount, @ZeroDecimal))
    FROM #ARPostInvoiceHeader PID
    INNER JOIN (
		SELECT intInvoiceId
			 , dblInvoiceTotal
			 , dblBaseInvoiceTotal
			 , strTransactionType 
		FROM dbo.tblARInvoice WITH (NOLOCK)
	) ARI ON PID.intInvoiceId = ARI.intInvoiceId
    INNER JOIN (
		SELECT intInvoiceId
			 , dblInterest
			 , dblBaseInterest
			 , dblDiscount
			 , dblBaseDiscount
			 , dblAmountDue
			 , dblBaseAmountDue
			 , dblInvoiceTotal
			 , dblBaseInvoiceTotal
			 , dblPayment
			 , dblBasePayment 
		FROM dbo.tblARPaymentDetail WITH (NOLOCK)
	) ARPD ON ARI.intInvoiceId = ARPD.intInvoiceId 
					
	--UPDATE HD TICKET HOURS
	UPDATE HDTHW						
	SET HDTHW.[ysnBilled] = 1
      , HDTHW.[dtmBilled] = (CASE WHEN HDTHW.[dtmBilled] IS NULL THEN GETDATE() ELSE HDTHW.[dtmBilled] END)
	FROM #ARPostInvoiceHeader PID
	INNER JOIN (
		SELECT [intInvoiceId]
			 , [dtmBilled]
			 , [ysnBilled] 
		FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)
	) HDTHW ON PID.[intInvoiceId] = HDTHW.[intInvoiceId]

	--TANK DELIVERY SYNC
    DECLARE @TankDeliveryForSync TABLE (
		  [intInvoiceId] INT
        , UNIQUE (intInvoiceId)
	)
								
	INSERT INTO @TankDeliveryForSync ([intInvoiceId])
	SELECT DISTINCT [intInvoiceId] = PID.[intInvoiceId]
	FROM #ARPostInvoiceDetail PID
	INNER JOIN dbo.tblTMSite TMS WITH (NOLOCK) ON PID.[intSiteId] = TMS.[intSiteID] 
								
	WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForSync)
	BEGIN
		DECLARE @intInvoiceForSyncId INT
			  , @ResultLogForSync NVARCHAR(MAX)
															
		SELECT TOP 1 @intInvoiceForSyncId = [intInvoiceId] 
		FROM @TankDeliveryForSync 
		ORDER BY [intInvoiceId]

		EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @UserId, @ResultLogForSync OUT
												
		DELETE FROM @TankDeliveryForSync WHERE [intInvoiceId] = @intInvoiceForSyncId																												
	END 							
						
	--CREATE PAYMENT FOR PREPAIDS/CREDIT MEMO TAB
	DECLARE @InvoicesWithPrepaids AS TABLE (
		  intInvoiceId INT
		, strTransactionType NVARCHAR(100)
	)
						
	INSERT INTO @InvoicesWithPrepaids
	SELECT intInvoiceId
	     , strTransactionType 
	FROM #ARPostInvoiceHeader I
	CROSS APPLY (										
		SELECT TOP 1 intPrepaymentId
		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
		WHERE intInvoiceId = I.intInvoiceId 
		  AND ysnApplied = 1
		  AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
	) PREPAIDS

	WHILE EXISTS(SELECT TOP 1 1 FROM @InvoicesWithPrepaids)
	BEGIN
		DECLARE @intInvoiceIdWithPrepaid	INT = NULL
			  , @strTransactionTypePrepaid	NVARCHAR(100) = NULL

		SELECT TOP 1 @intInvoiceIdWithPrepaid = intInvoiceId
				   , @strTransactionTypePrepaid = strTransactionType
		FROM @InvoicesWithPrepaids
							
		IF @strTransactionTypePrepaid <> 'Cash Refund'
			EXEC dbo.uspARCreateRCVForCreditMemo @intInvoiceId = @intInvoiceIdWithPrepaid, @intUserId = @UserId
		ELSE
			BEGIN

			    --Insert Audit log to credit memo for cash refund
				DECLARE @KeyValueId int,
						@EntityId int,
						@ScreenName	nvarchar(50) = 'AccountsReceivable.view.Invoice',
						@ActionType nvarchar(50) = 'Processed',
						@ToValueChild nvarchar(50)

				SELECT @ToValueChild = strInvoiceNumber from   tblARInvoice WHERE intInvoiceId = @intInvoiceIdWithPrepaid 
				SELECT TOP 1 @KeyValueId = I.intInvoiceId, @EntityId = I.intEntityId
				FROM tblARInvoice I
				INNER JOIN (										
					SELECT    intPrepaymentId			= intPrepaymentId
							, dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal)
					FROM dbo.tblARPrepaidAndCredit P WITH (NOLOCK)
					
					WHERE intInvoiceId = @intInvoiceIdWithPrepaid 
						AND ysnApplied = 1
						AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
				) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId



				EXEC dbo.uspSMAuditLog 
					 @screenName		 = @ScreenName	                    -- Screen Namespace
					,@keyValue			 = @KeyValueId						-- Primary Key Value of the Invoice. 
					,@entityId			 = @EntityId							-- Entity Id.
					,@actionType	     = @ActionType						-- Action Type
					,@changeDescription  = 'Cash Refund on'
					,@fromValue			 = ''
					,@toValue			 = @ToValueChild
					,@details			 = ''
					 

				UPDATE I
				SET dblAmountDue		= dblAmountDue - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
				  , dblBaseAmountDue	= dblBaseAmountDue - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
				  , dblPayment			= dblPayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
				  , dblBasePayment		= dblBasePayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
				  , ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				  , ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
				FROM tblARInvoice I
				INNER JOIN (										
					SELECT intPrepaymentId			= intPrepaymentId
						 , dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal)
					FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
					WHERE intInvoiceId = @intInvoiceIdWithPrepaid 
					  AND ysnApplied = 1
					  AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
				) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId



			END
								
		DELETE FROM @InvoicesWithPrepaids WHERE intInvoiceId = @intInvoiceIdWithPrepaid
	END
	
	--PREPAIDS
	DECLARE @Ids Id
	INSERT INTO @Ids
	SELECT [intInvoiceId] FROM #ARPostInvoiceHeader

	EXEC dbo.uspARAutoApplyPrepaids @tblInvoiceIds = @Ids

	--UPDATE CUSTOMER AR BALANCE
	UPDATE CUSTOMER
	SET CUSTOMER.dblARBalance = CUSTOMER.dblARBalance + ISNULL(dblTotalInvoice, @ZeroDecimal)
	FROM 
		dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	INNER JOIN 
		(SELECT
			 [intEntityCustomerId] = [intEntityCustomerId]
			, [dblTotalInvoice]     = SUM(CASE WHEN [ysnIsInvoicePositive] = 1 THEN [dblInvoiceTotal] - ISNULL(REFUND.dblRefundTotal, 0) ELSE -[dblInvoiceTotal] - ISNULL(REFUND.dblRefundTotal, 0) END)
		FROM #ARPostInvoiceHeader IH
		OUTER APPLY (
			SELECT dblRefundTotal = SUM(CM.dblInvoiceTotal)
			FROM tblARInvoiceDetail CR
			INNER JOIN tblARInvoice CM ON CR.strDocumentNumber = CM.strInvoiceNumber
			INNER JOIN tblARInvoice R ON CM.intOriginalInvoiceId = R.intInvoiceId AND CM.strInvoiceOriginId = R.strInvoiceNumber 
			WHERE CR.intInvoiceId = IH.intInvoiceId
				AND CM.ysnRefundProcessed = 1
				AND CM.ysnPosted = 1
				AND R.ysnReturned = 1
				AND CM.strTransactionType = 'Credit Memo'
				AND IH.strTransactionType = 'Cash Refund'
		) REFUND
		WHERE IH.strTransactionType <> 'Cash'
		GROUP BY [intEntityCustomerId]
	) INVOICE ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]

	--PATRONAGE
	DECLARE	@successfulCountP	INT
		  , @strId				NVARCHAR(MAX)

	DECLARE @IdsP TABLE (
		  [intInvoiceId]			INT
		, [intLoadId]				INT
		, [intPurchaseSale]			INT
		, [ysnFromProvisional]		BIT
		, [ysnProvisionalWithGL]	BIT
		, [ysnFromReturn]			BIT
	)

	INSERT INTO @IdsP(
		  [intInvoiceId]
		, [intLoadId]
		, [intPurchaseSale]
		, [ysnFromProvisional]
		, [ysnProvisionalWithGL]
		, [ysnFromReturn]
	)
	SELECT [intInvoiceId]			= I.[intInvoiceId]
		 , [intLoadId]				= I.[intLoadId]
		 , [intPurchaseSale]		= LG.[intPurchaseSale]
		 , [ysnFromProvisional]		= I.[ysnFromProvisional]
		 , [ysnProvisionalWithGL]	= I.[ysnProvisionalWithGL]
		 , [ysnFromReturn] 			= CASE WHEN I.[strTransactionType] = 'Credit Memo' AND RI.[intInvoiceId] IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM #ARPostInvoiceHeader I
	LEFT JOIN tblLGLoad LG ON I.intLoadId = LG.intLoadId
	OUTER APPLY (
		SELECT TOP 1 intInvoiceId 
		FROM tblARInvoice RET
		WHERE RET.strTransactionType = 'Invoice'
		AND RET.ysnReturned = 1
		AND I.strInvoiceOriginId = RET.strInvoiceNumber
		AND I.intOriginalInvoiceId = RET.intInvoiceId
	) RI

	SELECT @strId = COALESCE(@strId + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250)) FROM @IdsP

	EXEC [dbo].[uspPATGatherVolumeForPatronage]
		 @transactionIds	= @strId
		,@post				= 1
		,@type				= 2
		,@successfulCount	= @successfulCountP OUTPUT

	--UPDATE INVOICE TRANSACTION HISTORY
	DELETE FROM @Invoices
	
	INSERT INTO @Invoices([intHeaderId]) 
	SELECT [intInvoiceId] FROM @IdsP

    EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @Invoices, 1

	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsP)
	BEGIN
		DECLARE @InvoiceIDP 		INT
			  , @LoadIDP 			INT
			  , @intPurchaseSaleIDP INT
        	  , @FromProvisionalP 	BIT
        	  , @ProvisionalWithGLP BIT
			  , @ysnFromReturnP 	BIT

		SELECT TOP 1 @InvoiceIDP			= [intInvoiceId]
				   , @LoadIDP				= [intLoadId]
				   , @intPurchaseSaleIDP	= [intPurchaseSale]
				   , @FromProvisionalP		= [ysnFromProvisional]
				   , @ProvisionalWithGLP 	= [ysnProvisionalWithGL]
				   , @ysnFromReturnP		= [ysnFromReturn]
		FROM @IdsP 
		ORDER BY [intInvoiceId]

		--COMMITTED QTY
		EXEC dbo.[uspARUpdateCommitted] @InvoiceIDP, 1, @UserId, 1

		--IN TRANSIT OUTBOUND QTY
		EXEC dbo.[uspARUpdateInTransit] @InvoiceIDP, 1

		--IN TRANSIT DIRECT QTY
		EXEC dbo.[uspARUpdateInTransitDirect] @InvoiceIDP, 1

		--LOAD SHIPMENT
        IF @FromProvisionalP = 0 OR @ProvisionalWithGLP = 0
			EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost] @InvoiceId	= @InvoiceIDP
														  , @Post		= 1
														  , @LoadId		= @LoadIDP
														  , @UserId		= @UserId
		
		--UNPOST AND CANCEL LOAD SHIPMENT FROM CREDIT MEMO RETURN
		IF ISNULL(@ysnFromReturnP, 0) = 1 AND @LoadIDP IS NOT NULL
			BEGIN
				IF @ysnImposeReversalTransaction = 0
					BEGIN
						EXEC dbo.[uspLGPostLoadSchedule] @intLoadId 				= @LoadIDP
													   , @ysnPost				 	= 0
													   , @intEntityUserSecurityId  	= @UserId
					END
				IF ISNULL(@intPurchaseSaleIDP, 0) <> 3
					BEGIN
						EXEC dbo.[uspLGCancelLoadSchedule] @intLoadId 				 = @LoadIDP
														 , @ysnCancel				 = 1
														 , @intEntityUserSecurityId  = @UserId
														 , @intShipmentType			 = 1
					END
			END

		DELETE FROM @IdsP WHERE [intInvoiceId] = @InvoiceIDP
	END
END

IF @Post = 0
BEGIN
	--REVERSE BLEND FOR FINISHED GOODS
	DECLARE @FinishedGoodItems AS TABLE (
		  [intInvoiceDetailId]	INT
		, [intUserId]			INT
	)

	INSERT INTO @FinishedGoodItems
	SELECT DISTINCT [intInvoiceDetailId] = UPD.[intInvoiceDetailId]
			      , [intUserId]          = UPD.[intUserId]
	FROM #ARPostInvoiceDetail UPD
	INNER JOIN tblMFWorkOrder MFWO ON UPD.[intInvoiceDetailId] = MFWO.[intInvoiceDetailId]
	WHERE UPD.[ysnBlended] = 1

	WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
		BEGIN
			DECLARE @intInvoiceDetailIdToUnblend	INT
				  , @intUserIdToUnblend				INT
			
			SELECT TOP 1 @intInvoiceDetailIdToUnblend	= intInvoiceDetailId
					   , @intUserIdToUnblend			= [intUserId] 
			FROM @FinishedGoodItems

			EXEC dbo.uspMFReverseAutoBlend @intSalesOrderDetailId	= NULL
										 , @intInvoiceDetailId		= @intInvoiceDetailIdToUnblend
										 , @intUserId				= @intUserIdToUnblend 

			UPDATE tblARInvoiceDetail 
			SET ysnBlended = 0 
			WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend

			DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
		END

	UPDATE ARI
	SET ARI.ysnPosted					= 0
	  , ARI.ysnPaid						= 0
	  , ARI.dblAmountDue				= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
												THEN 
													CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) > 0
															THEN ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal))
															ELSE (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal)
													END
												ELSE 
													CASE WHEN (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) = ISNULL(ARI.dblPayment, @ZeroDecimal))
															THEN ISNULL(ARI.dblPayment, @ZeroDecimal)
															ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
														END
											END
	  , ARI.dblBaseAmountDue			= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
												THEN 
													CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) > 0
															THEN ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal))
															ELSE (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal)
													END
												ELSE 
													CASE WHEN (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) = ISNULL(ARI.dblBasePayment, @ZeroDecimal))
															THEN ISNULL(ARI.dblBasePayment, @ZeroDecimal)
															ELSE ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)
														END
											END												
		, ARI.dblDiscount				= @ZeroDecimal
		, ARI.dblBaseDiscount			= @ZeroDecimal
		, ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
		, ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
		, ARI.dblInterest				= @ZeroDecimal
		, ARI.dblBaseInterest			= @ZeroDecimal
		, ARI.dblPayment				= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END
		, ARI.dblBasePayment			= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END
		, ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
		, ARI.ysnExcludeFromPayment		= 0
		, ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1
		, ARI.intPeriodId				= NULL
	FROM #ARPostInvoiceHeader PID
	INNER JOIN (
		SELECT intInvoiceId
			 , ysnPosted
			 , ysnPaid
			 , dblAmountDue
			 , dblBaseAmountDue
			 , dblDiscount
			 , dblBaseDiscount
			 , dblDiscountAvailable
			 , dblBaseDiscountAvailable
			 , dblInterest
			 , dblBaseInterest
			 , dblPayment
			 , dblBasePayment
			 , dtmPostDate
			 , intConcurrencyId
			 , strTransactionType
			 , intSourceId
			 , intOriginalInvoiceId
			 , dblProvisionalAmount
			 , dblBaseProvisionalAmount
			 , dblInvoiceTotal
			 , dblBaseInvoiceTotal
			 , dtmDate
			 , ysnExcludeFromPayment
			 , intPeriodId
		FROM dbo.tblARInvoice WITH (NOLOCK)
	) ARI ON PID.intInvoiceId = ARI.intInvoiceId 					
	CROSS APPLY (
		SELECT COUNT(intPrepaidAndCreditId) PPC 
		FROM tblARPrepaidAndCredit 
		WHERE intInvoiceId = PID.intInvoiceId AND ysnApplied = 1
	) PPC
	
												
	--UPDATE HD TICKET HOURS
	UPDATE HDTHW						
	SET HDTHW.ysnBilled = 0
	  , HDTHW.dtmBilled = NULL
	FROM #ARPostInvoiceHeader PID
	INNER JOIN (
		SELECT intInvoiceId
			 , dtmBilled
			 , ysnBilled 
		FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)
	) HDTHW ON PID.intInvoiceId = HDTHW.intInvoiceId	
															
	DELETE PD
	FROM tblARPaymentDetail PD
	INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 0
	WHERE PD.intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM #ARPostInvoiceHeader WHERE [ysnPost] = 0)
						
	DECLARE @TankDeliveryForUnSync TABLE (
		  [intInvoiceId] INT
        , UNIQUE (intInvoiceId)
	)
	
	--TANK DELIVERY SYNC							
	INSERT INTO @TankDeliveryForUnSync
	SELECT DISTINCT [intInvoiceId] = PID.[intInvoiceId]
	FROM #ARPostInvoiceDetail PID
	INNER JOIN dbo.tblTMSite TMS WITH (NOLOCK) ON PID.[intSiteId] = TMS.[intSiteID]				
															
	WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForUnSync ORDER BY intInvoiceId)
		BEGIN							
			DECLARE @intInvoiceForUnSyncId	INT
				  , @ResultLogForUnSync		NVARCHAR(MAX)
										
			SELECT TOP 1 @intInvoiceForUnSyncId = intInvoiceId FROM @TankDeliveryForUnSync ORDER BY intInvoiceId

			EXEC dbo.uspTMUnSyncInvoiceFromDeliveryHistory @intInvoiceForUnSyncId, @ResultLogForUnSync OUT
												
			DELETE FROM @TankDeliveryForUnSync WHERE intInvoiceId = @intInvoiceForUnSyncId																		
		END 							
								
	--UPDATE PREPAIDS/CREDIT MEMO FOR CASH REFUND
	DECLARE @CashRefunds AS TABLE (intInvoiceId INT)

	INSERT INTO @CashRefunds
	SELECT intInvoiceId FROM #ARPostInvoiceHeader I
	CROSS APPLY (										
		SELECT TOP 1 intPrepaymentId
		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
		WHERE intInvoiceId = I.intInvoiceId 
		  AND ysnApplied = 1
		  AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
	) PREPAIDS
	WHERE I.strTransactionType = 'Cash Refund'

	WHILE EXISTS(SELECT TOP 1 1 FROM @CashRefunds)
		BEGIN
			DECLARE @intInvoiceIdCashRefund INT = NULL

			SELECT TOP 1 @intInvoiceIdCashRefund = intInvoiceId
			FROM @CashRefunds
							
			UPDATE I
			SET dblAmountDue		= dblAmountDue + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
			  , dblBaseAmountDue	= dblBaseAmountDue + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
			  , dblPayment			= dblPayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
			  , dblBasePayment		= dblBasePayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
			  , ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			  , ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
			FROM tblARInvoice I
			INNER JOIN (										
				SELECT intPrepaymentId			= intPrepaymentId
					 , dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal)
				FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
				WHERE intInvoiceId = @intInvoiceIdCashRefund 
				  AND ysnApplied = 1
				  AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
			) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId
								
			DELETE FROM @CashRefunds WHERE intInvoiceId = @intInvoiceIdCashRefund
		END	

	--DELETE UNDEPOSITED FUND FOR CASH
	DELETE CF 
	FROM tblCMUndepositedFund CF
	INNER JOIN
		#ARPostInvoiceHeader I
			ON CF.intSourceTransactionId = I.intInvoiceId 
			AND CF.strSourceTransactionId = I.strInvoiceNumber
	WHERE CF.strSourceSystem = 'AR'

	--UPDATE CUSTOMER AR BALANCE
	UPDATE CUSTOMER
	SET CUSTOMER.dblARBalance = CUSTOMER.dblARBalance - ISNULL(dblTotalInvoice, @ZeroDecimal)
	FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	INNER JOIN (
		SELECT [intEntityCustomerId] = [intEntityCustomerId]
			 , [dblTotalInvoice]     = SUM(CASE WHEN [ysnIsInvoicePositive] = 1 THEN [dblInvoiceTotal] - ISNULL(REFUND.dblRefundTotal, 0) ELSE -[dblInvoiceTotal] - ISNULL(REFUND.dblRefundTotal, 0) END)
		FROM #ARPostInvoiceHeader IH
		OUTER APPLY (
			SELECT dblRefundTotal = SUM(CM.dblInvoiceTotal)
			FROM tblARInvoiceDetail CR
			INNER JOIN tblARInvoice CM ON CR.strDocumentNumber = CM.strInvoiceNumber
			INNER JOIN tblARInvoice R ON CM.intOriginalInvoiceId = R.intInvoiceId AND CM.strInvoiceOriginId = R.strInvoiceNumber 
			WHERE CR.intInvoiceId = IH.intInvoiceId
				AND CM.ysnRefundProcessed = 1
				AND CM.ysnPosted = 1
				AND R.ysnReturned = 1
				AND CM.strTransactionType = 'Credit Memo'
				AND IH.strTransactionType = 'Cash Refund'
		) REFUND
		WHERE IH.strTransactionType <> 'Cash'
		GROUP BY [intEntityCustomerId]
		) INVOICE ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]

	--PATRONAGE
	DECLARE	@successfulCountU	INT
		  , @strIdU				NVARCHAR(MAX)

	DECLARE @IdsU TABLE (
		  [intInvoiceId]			INT
		, [intLoadId]				INT
		, [intPurchaseSale]			INT
		, [ysnFromProvisional]		BIT
		, [ysnProvisionalWithGL]	BIT
		, [ysnFromReturn]			BIT
	)

	INSERT INTO @IdsU (
		  [intInvoiceId]
		, [intLoadId]
		, [intPurchaseSale]
		, [ysnFromProvisional]
		, [ysnProvisionalWithGL]
		, [ysnFromReturn]
	)
	SELECT [intInvoiceId]			= I.[intInvoiceId]
		 , [intLoadId]				= I.[intLoadId]
		 , [intPurchaseSale]		= LG.[intPurchaseSale]
		 , [ysnFromProvisional]		= I.[ysnFromProvisional]
		 , [ysnProvisionalWithGL] 	= I.[ysnProvisionalWithGL]
		 , [ysnFromReturn] 			= CASE WHEN I.[strTransactionType] = 'Credit Memo' AND RI.[intInvoiceId] IS NOT NULL THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
	FROM #ARPostInvoiceHeader I
	LEFT JOIN tblLGLoad LG ON I.intLoadId = LG.intLoadId
	OUTER APPLY (
		SELECT TOP 1 intInvoiceId 
		FROM tblARInvoice RET
		WHERE RET.strTransactionType = 'Invoice'
		AND RET.ysnReturned = 1
		AND I.strInvoiceOriginId = RET.strInvoiceNumber
		AND I.intOriginalInvoiceId = RET.intInvoiceId
	) RI


	SELECT @strIdU = COALESCE(@strIdU + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250)) FROM @IdsU

	EXEC [dbo].[uspPATGatherVolumeForPatronage] @transactionIds		= @strIdU
											  , @post				= 0
											  , @type				= 2
											  , @successfulCount	= @successfulCountU OUTPUT

	--UPDATE INVOICE TRANSACTION HISTORY
	DELETE FROM @Invoices
	
	INSERT INTO @Invoices([intHeaderId]) 
	SELECT [intInvoiceId] FROM @IdsU

    EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @Invoices, 0

	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsU)
	BEGIN
		DECLARE @InvoiceIDU				INT
			  , @LoadIDU				INT
			  , @intPurchaseSaleIDU		INT
			  , @FromProvisionalU		BIT
			  , @ProvisionalWithGLU		BIT
			  , @ysnFromReturnU			BIT			  

		SELECT TOP 1 @InvoiceIDU			= [intInvoiceId]
				   , @LoadIDU				= [intLoadId]
				   , @intPurchaseSaleIDU	= [intPurchaseSale]
				   , @FromProvisionalU		= [ysnFromProvisional]
				   , @ProvisionalWithGLU 	= [ysnProvisionalWithGL]
				   , @ysnFromReturnU		= [ysnFromReturn]
		FROM @IdsU 
		ORDER BY [intInvoiceId]
		
		--COMMITTED QTY
		EXEC dbo.[uspARUpdateCommitted] @InvoiceIDU, 1, @UserId, 1

		--IN TRANSIT OUTBOUND QTY
		EXEC dbo.[uspARUpdateInTransit] @InvoiceIDU, 0

		--IN TRANSIT DIRECT QTY
		EXEC dbo.[uspARUpdateInTransitDirect] @InvoiceIDU, 0

		--LOAD SHIPMENT
        IF @FromProvisionalU = 0 OR @ProvisionalWithGLU = 0
			EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost] @InvoiceId	= @InvoiceIDU
														  , @Post		= 0
														  , @LoadId		= @LoadIDU
														  , @UserId		= @UserId

		--POST AND UN-CANCEL LOAD SHIPMENT FROM CREDIT MEMO RETURN
		IF ISNULL(@ysnFromReturnU, 0) = 1 AND @LoadIDU IS NOT NULL
			BEGIN
				IF ISNULL(@intPurchaseSaleIDU, 0) <> 3
					BEGIN
						EXEC dbo.[uspLGCancelLoadSchedule] @intLoadId 				 = @LoadIDU
														 , @ysnCancel				 = 0
														 , @intEntityUserSecurityId  = @UserId
														 , @intShipmentType			 = 1
					END
												 
				EXEC dbo.[uspLGPostLoadSchedule] @intLoadId 				= @LoadIDP
											   , @ysnPost				 	= 1
											   , @intEntityUserSecurityId  	= @UserId
				
			END	

		DELETE FROM @IdsU WHERE [intInvoiceId] = @InvoiceIDU
	END
																	
END

--UPDATE CUSTOMER CREDIT LIMIT REACHED
UPDATE CUSTOMER
SET [dtmCreditLimitReached] =  CASE WHEN ISNULL(CUSTOMER.[dblARBalance], 0) >= ISNULL(CUSTOMER.[dblCreditLimit], 0) THEN ISNULL(CUSTOMER.[dtmCreditLimitReached], INVOICE.[dtmPostDate]) ELSE NULL END
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
CROSS APPLY (
	SELECT TOP 1 I.[dtmPostDate]
	FROM #ARPostInvoiceHeader I
	WHERE I.[intEntityCustomerId] = CUSTOMER.[intEntityId]
	ORDER BY I.[dtmPostDate] DESC
) INVOICE
WHERE ISNULL(CUSTOMER.[dblCreditLimit], @ZeroDecimal) > @ZeroDecimal

--UPDATE BATCH ID
UPDATE INV
SET INV.[strBatchId]	 = CASE WHEN PID.[ysnPost] = 1 THEN PID.[strBatchId] ELSE NULL END
  , INV.[dtmBatchDate]  = CASE WHEN PID.[ysnPost] = 1 THEN PID.[dtmPostDate] ELSE NULL END
  , INV.[intPostedById] = CASE WHEN PID.[ysnPost] = 1 THEN PID.[intUserId] ELSE NULL END
FROM tblARInvoice INV
INNER JOIN #ARPostInvoiceHeader PID ON INV.[intInvoiceId] = PID.[intInvoiceId]

--UPDATE CONTRACT BALANCE
DELETE FROM @ItemsFromInvoice
INSERT INTO @ItemsFromInvoice
	([intInvoiceId]
	,[strInvoiceNumber]
	,[intEntityCustomerId]
	,[strTransactionType]
	,[dtmDate]
	,[intCurrencyId]
	,[intCompanyLocationId]
	,[intDistributionHeaderId]
	-- Detail 
	,[intInvoiceDetailId]
	,[intItemId]
	,[strItemNo]
	,[strItemDescription]
	,[intItemUOMId]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	,[dblTotal]
	,[intServiceChargeAccountId]
	,[intInventoryShipmentItemId]
	,[intSalesOrderDetailId]
	,[intSiteId]
	,[intPerformerId]
	,[intContractHeaderId]
	,[strContractNumber]
	,[strMaintenanceType]
	,[strFrequency]
	,[dtmMaintenanceDate]
	,[dblMaintenanceAmount]
	,[dblLicenseAmount]
	,[intContractDetailId]
	,[intTicketId]
	,[intCustomerStorageId]
	,[intLoadDetailId]
	,[ysnLeaseBilling])
SELECT
	-- Header
	 [intInvoiceId]					= ID.[intInvoiceId]
	,[strInvoiceNumber]				= ID.[strInvoiceNumber]
	,[intEntityCustomerId]			= ID.[intEntityCustomerId]
	,[strTransactionType]           = ID.[strTransactionType]
	,[dtmDate]						= ID.[dtmDate]
	,[intCurrencyId]				= ID.[intCurrencyId]
	,[intCompanyLocationId]			= ID.[intCompanyLocationId]
	,[intDistributionHeaderId]		= ID.[intDistributionHeaderId]
	-- Detail 
	,[intInvoiceDetailId]			= ID.[intInvoiceDetailId]			
	,[intItemId]					= ID.[intItemId]		
	,[strItemNo]					= ID.[strItemNo]
	,[strItemDescription]			= ID.[strItemDescription]			
	,[intItemUOMId]					= ID.[intItemUOMId]					
	,[dblQtyShipped]				= CASE WHEN ID.[strTransactionType] = 'Credit Memo' AND ID.[intLoadDetailId] IS NOT NULL AND ISNULL(CH.[ysnLoad], 0) = 1 
										   THEN 1 
										   ELSE 
												CASE WHEN ID.intInventoryShipmentItemId IS NOT NULL AND ISI.[intDestinationGradeId] IS NOT NULL AND ISI.[intDestinationWeightId] IS NOT NULL AND ID.[dblQtyShipped] > ISNULL(ISI.dblQuantity, 0) AND ISNULL(CD.dblBalance, 0) = 0
												     THEN ID.[dblQtyShipped] - ISNULL(ISI.dblQuantity, 0)
													 ELSE ID.[dblQtyShipped] 
												END
									  END * (CASE WHEN ID.[ysnPost] = 0 THEN -@OneDecimal ELSE @OneDecimal END) * (CASE WHEN ID.[ysnIsInvoicePositive] = 0 THEN -@OneDecimal ELSE @OneDecimal END)
	,[dblDiscount]					= ID.[dblDiscount]					
	,[dblPrice]						= ID.[dblPrice]						
	,[dblTotal]						= ID.[dblTotal]						
	,[intServiceChargeAccountId]	= ID.[intServiceChargeAccountId]	
	,[intInventoryShipmentItemId]	= ID.[intInventoryShipmentItemId]	
	,[intSalesOrderDetailId]		= ID.[intSalesOrderDetailId]
	,[intSiteId]					= ID.[intSiteId]					
	,[intPerformerId]				= ID.[intPerformerId]				
	,[intContractHeaderId]			= ID.[intContractHeaderId]
	,[strContractNumber]			= CH.[strContractNumber]
	,[strMaintenanceType]           = ID.[strMaintenanceType]           
	,[strFrequency]                 = ID.[strFrequency]                 
	,[dtmMaintenanceDate]           = ID.[dtmMaintenanceDate]           
	,[dblMaintenanceAmount]         = ID.[dblMaintenanceAmount]         
	,[dblLicenseAmount]             = ID.[dblLicenseAmount]             
	,[intContractDetailId]			= ID.[intContractDetailId]			
	,[intTicketId]     				= (CASE WHEN ID.strTransactionType = 'Credit Memo' AND @Post = CONVERT(BIT, 1) THEN NULL ELSE ID.[intTicketId] END)
	,[intCustomerStorageId]			= ID.[intCustomerStorageId]
	,[intLoadDetailId]				= ID.[intLoadDetailId]
	,[ysnLeaseBilling]				= ID.[ysnLeaseBilling]				
FROM #ARPostInvoiceDetail ID
INNER JOIN tblCTContractDetail CD ON ID.[intContractDetailId] = CD.[intContractDetailId]	
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblICInventoryShipmentItem ISI ON ID.[intInventoryShipmentItemId] = ISI.[intInventoryShipmentItemId]
LEFT JOIN tblARInvoice PI ON ID.intOriginalInvoiceId = PI.intInvoiceId AND ID.ysnFromProvisional = 1 AND PI.strType = 'Provisional'
LEFT JOIN (
	SELECT intLoadDetailId
		 , intPurchaseSale 
	FROM tblLGLoadDetail LGD 
	INNER JOIN tblLGLoad LG ON LG.intLoadId = LGD.intLoadId	
) LG ON ID.intLoadDetailId = LG.intLoadDetailId
OUTER APPLY (
	SELECT TOP 1 intInvoiceId 
	FROM tblARInvoice I
	WHERE I.strTransactionType = 'Invoice'
	  AND I.ysnReturned = 1
	  AND ID.strInvoiceOriginId = I.strInvoiceNumber
	  AND ID.intOriginalInvoiceId = I.intInvoiceId
) RI
WHERE ID.[intInventoryShipmentChargeId] IS NULL
	AND	(
		(ID.strTransactionType <> 'Credit Memo' AND ((ID.[intInventoryShipmentItemId] IS NULL AND (ID.[intLoadDetailId] IS NULL OR (ID.intLoadDetailId IS NOT NULL AND LG.intPurchaseSale = 3))) OR (ISI.[intDestinationGradeId] IS NOT NULL AND ISI.[intDestinationWeightId] IS NOT NULL)))
		OR
		(ID.strTransactionType = 'Credit Memo' AND (ID.[intInventoryShipmentItemId] IS NOT NULL OR ID.[intLoadDetailId] IS NOT NULL OR ISNULL(RI.[intInvoiceId], 0) <> 0))
		)
    AND ISNULL(ID.[strItemType], '') <> 'Other Charge'
	AND (ISNULL(RI.[intInvoiceId], 0) = 0 OR (ISNULL(RI.[intInvoiceId], 0) <> 0 AND (ID.intLoadDetailId IS NULL OR ID.[intTicketId] IS NOT NULL)))
	AND ((ID.ysnFromProvisional = 1 AND PI.ysnPosted = 0) OR ID.ysnFromProvisional = 0)

EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @UserId

--UPDATE CONTRACTS FINANCIAL STATUS
DECLARE @tblContractsFinancial AS Id

INSERT INTO @tblContractsFinancial
SELECT DISTINCT intInvoiceId
FROM #ARPostInvoiceDetail 
WHERE intContractDetailId IS NOT NULL

WHILE EXISTS (SELECT TOP 1 NULL FROM @tblContractsFinancial)
	BEGIN
		DECLARE @intContractFinancialId INT
		SELECT TOP 1 @intContractFinancialId = intId FROM @tblContractsFinancial

		EXEC dbo.uspCTUpdateFinancialStatus @intContractFinancialId, 'Invoice'

		DELETE FROM @tblContractsFinancial WHERE intId = @intContractFinancialId
	END

--UPDATE ITEM CONTRACT BALANCE
DECLARE @tblItemContracts CTItemContractTable

INSERT INTO @tblItemContracts (
	  intTransactionId
	, strTransactionId
	, intEntityCustomerId
	, strTransactionType
	, dtmDate
	, intCurrencyId
	, intCompanyLocationId
	, intInvoiceDetailId
	, intItemId
	, strItemNo
	, strItemDescription
	, intItemUOMId
	, dblQtyOrdered
	, dblQtyShipped
	, dblDiscount
	, dblPrice
	, dblTotalTax
	, dblTotal
	, intItemContractHeaderId
	, intItemContractDetailId
	, intItemContractLineNo
)
SELECT intTransactionId			= PID.intInvoiceId
	, strTransactionId			= PID.strInvoiceNumber
	, intEntityCustomerId		= PID.intEntityCustomerId
	, strTransactionType		= PID.strTransactionType
	, dtmDate					= PID.dtmDate
	, intCurrencyId				= PID.intCurrencyId
	, intCompanyLocationId		= PID.intCompanyLocationId
	, intInvoiceDetailId		= PID.intInvoiceDetailId
	, intItemId					= PID.intItemId
	, strItemNo					= PID.strItemNo
	, strItemDescription		= ID.strItemDescription
	, intItemUOMId				= PID.intItemUOMId
	, dblQtyOrdered				= ID.dblQtyOrdered
	, dblQtyShipped				= PID.dblQtyShipped * (CASE WHEN PID.[ysnPost] = 0 THEN -@OneDecimal ELSE @OneDecimal END) * (CASE WHEN PID.[ysnIsInvoicePositive] = 0 THEN -@OneDecimal ELSE @OneDecimal END)
	, dblDiscount				= ID.dblDiscount
	, dblPrice					= PID.dblPrice
	, dblTotalTax				= ID.dblTotalTax
	, dblTotal					= PID.dblTotal
	, intItemContractHeaderId	= ID.intItemContractHeaderId
	, intItemContractDetailId	= ID.intItemContractDetailId
	, intItemContractLineNo		= ICD.intLineNo
FROM #ARPostInvoiceDetail PID
INNER JOIN tblARInvoiceDetail ID ON PID.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblCTItemContractDetail ICD ON ID.intItemContractDetailId = ICD.intItemContractDetailId
WHERE ID.intItemContractDetailId IS NOT NULL
  AND ISNULL(ID.strPricing, 'Inventory - Standard Pricing') <> 'Subsystem - Direct'

EXEC dbo.uspCTItemContractInvoicePosted @tblItemContracts, @UserId

DELETE A
FROM tblARPrepaidAndCredit A
INNER JOIN #ARPostInvoiceHeader B ON A.intInvoiceId = B.intInvoiceId 
WHERE ysnApplied = 0

--POST RESULT
IF @IntegrationLogId IS NULL
	BEGIN
		INSERT INTO tblARPostResult(
			  strMessage
			, strTransactionType
			, strTransactionId
			, strBatchNumber
			, intTransactionId
		)
		SELECT CASE WHEN [ysnPost] = 1 THEN 'Transaction successfully posted.'  ELSE 'Transaction successfully unposted.' END
			, [strTransactionType]
			, [strInvoiceNumber]
			, [strBatchId]
			, [intInvoiceId]
		FROM #ARPostInvoiceHeader
	END

--INTER COMPANY PRE-STAGE
DECLARE @tblInterCompany 	AS Id
DECLARE @strRowState		NVARCHAR(50) = (CASE WHEN @Post = 1 THEN 'Posted' ELSE 'Unposted' END)

INSERT INTO @tblInterCompany
SELECT DISTINCT intInvoiceId
FROM #ARPostInvoiceHeader

WHILE EXISTS (SELECT TOP 1 NULL FROM @tblInterCompany)
	BEGIN
		DECLARE @intInterCompanyInvoiceId INT
		SELECT TOP 1 @intInterCompanyInvoiceId = intId FROM @tblInterCompany

		EXEC dbo.uspIPInterCompanyPreStageInvoice @intInterCompanyInvoiceId, @strRowState, @UserId

		DELETE FROM @tblInterCompany WHERE intId = @intInterCompanyInvoiceId
	END

--AUDIT LOG
DECLARE @InvoiceLog dbo.[AuditLogStagingTable]
DELETE FROM @InvoiceLog
INSERT INTO @InvoiceLog(
	 [strScreenName]
	,[intKeyValueId]
	,[intEntityId]
	,[strActionType]
	,[strDescription]
	,[strActionIcon]
	,[strChangeDescription]
	,[strFromValue]
	,[strToValue]
	,[strDetails]
)
SELECT DISTINCT
	 [strScreenName]			= 'AccountsReceivable.view.Invoice'
	,[intKeyValueId]			= [intInvoiceId]
	,[intEntityId]				= [intUserId]
	,[strActionType]			= CASE WHEN [ysnPost] = 1 THEN 'Posted'  ELSE 'Unposted' END 
	,[strDescription]			= ''
	,[strActionIcon]			= NULL
	,[strChangeDescription]		= ''
	,[strFromValue]				= ''
	,[strToValue]				= [strInvoiceNumber]
	,[strDetails]				= NULL
FROM #ARPostInvoiceHeader

EXEC [dbo].[uspARInsertAuditLogs] @LogEntries = @InvoiceLog

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
