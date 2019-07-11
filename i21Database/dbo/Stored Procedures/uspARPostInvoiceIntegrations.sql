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

DECLARE @ZeroDecimal DECIMAL(18,6) = 0.000000
DECLARE @OneDecimal DECIMAL(18,6) = 1.000000

DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
DECLARE @Invoices AS dbo.[InvoiceId]

IF @Post = 1
BEGIN    
    UPDATE ARI						
    SET
         ARI.ysnPosted					= 1
        ,ARI.ysnPaid					= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.dblAmountDue = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
        ,ARI.dblAmountDue				= (CASE WHEN ARI.strTransactionType IN ('Cash')
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
        ,ARI.dblBaseAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash')
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
        ,ARI.dblDiscount				= @ZeroDecimal
        ,ARI.dblBaseDiscount			= @ZeroDecimal
        ,ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
        ,ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
        ,ARI.dblInterest				= @ZeroDecimal
        ,ARI.dblBaseInterest			= @ZeroDecimal
        ,ARI.dblPayment					= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
        ,ARI.dblBasePayment				= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END)
        ,ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
        ,ARI.ysnExcludeFromPayment		= PID.ysnExcludeInvoiceFromPayment
        ,ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1	
    FROM #ARPostInvoiceHeader PID
    INNER JOIN (
		SELECT intInvoiceId
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
		FROM dbo.tblARInvoice WITH (NOLOCK)
	) ARI ON PID.intInvoiceId = ARI.intInvoiceId

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
        ,UNIQUE (intInvoiceId)
	);
								
	INSERT INTO @TankDeliveryForSync([intInvoiceId])
	SELECT DISTINCT [intInvoiceId] = PID.[intInvoiceId]
	FROM #ARPostInvoiceDetail PID
	INNER JOIN dbo.tblTMSite TMS WITH (NOLOCK) ON PID.[intSiteId] = TMS.[intSiteID] 
								
	WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForSync)
	BEGIN
		DECLARE  @intInvoiceForSyncId INT
				,@ResultLogForSync NVARCHAR(MAX)
															
		SELECT TOP 1 @intInvoiceForSyncId = [intInvoiceId] FROM @TankDeliveryForSync ORDER BY [intInvoiceId]

		EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @UserId, @ResultLogForSync OUT
												
		DELETE FROM @TankDeliveryForSync WHERE [intInvoiceId] = @intInvoiceForSyncId																												
	END 							
						
	--CREATE PAYMENT FOR PREPAIDS/CREDIT MEMO TAB
	DECLARE @InvoicesWithPrepaids AS TABLE (intInvoiceId INT, strTransactionType NVARCHAR(100))
						
	INSERT INTO @InvoicesWithPrepaids
	SELECT intInvoiceId, strTransactionType 
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
		DECLARE @intInvoiceIdWithPrepaid INT = NULL
				, @strTransactionTypePrepaid NVARCHAR(100) = NULL

		SELECT TOP 1 @intInvoiceIdWithPrepaid = intInvoiceId
					, @strTransactionTypePrepaid = strTransactionType
		FROM @InvoicesWithPrepaids
							
		IF @strTransactionTypePrepaid <> 'Cash Refund'
			EXEC dbo.uspARCreateRCVForCreditMemo @intInvoiceId = @intInvoiceIdWithPrepaid, @intUserId = @UserId
		ELSE
			BEGIN
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
		GROUP BY [intEntityCustomerId]
	) INVOICE ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]

	--PATRONAGE
	DECLARE	@successfulCountP INT
		  , @strId NVARCHAR(MAX)

	DECLARE @IdsP TABLE(
		  [intInvoiceId]			INT
		, [intLoadId]				INT
		, [ysnFromProvisional]		BIT
		, [ysnProvisionalWithGL]	BIT
	)

	INSERT INTO @IdsP([intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL])
	SELECT [intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL] FROM #ARPostInvoiceHeader	

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
		DECLARE @InvoiceIDP INT
		DECLARE @LoadIDP INT
        DECLARE @FromProvisionalP BIT
        DECLARE @ProvisionalWithGLP BIT
		SELECT TOP 1 @InvoiceIDP = [intInvoiceId], @LoadIDP = [intLoadId], @FromProvisionalP = [ysnFromProvisional], @ProvisionalWithGLP = [ysnProvisionalWithGL] FROM @IdsP ORDER BY [intInvoiceId]
		
        --UPDATE CONTRACT SEQUENCE BALANCE
		EXEC dbo.[uspARInvoiceUpdateSequenceBalance] @TransactionId = @InvoiceIDP, @ysnDelete = 0, @UserId = @UserId

		--COMMITTED QTY
		EXEC dbo.[uspARUpdateCommitted] @InvoiceIDP, 1, @UserId, 1

		--IN TRANSIT OUTBOUND QTY
		EXEC dbo.[uspARUpdateInTransit] @InvoiceIDP, 1, 0

		--IN TRANSIT DIRECT QTY
		EXEC dbo.[uspARUpdateInTransitDirect] @InvoiceIDP, 1

		--LOAD SHIPMENT
        IF @FromProvisionalP = 0 OR @ProvisionalWithGLP = 0
			EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost] @InvoiceId	= @InvoiceIDP
														  , @Post		= 1
														  , @LoadId		= @LoadIDP
														  , @UserId		= @UserId

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
	INNER JOIN (
		SELECT intInvoiceDetailId 
		FROM tblMFWorkOrder
	) MFWO ON UPD.[intInvoiceDetailId] = MFWO.[intInvoiceDetailId]
	WHERE UPD.[ysnBlended] = 1

	WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
		BEGIN
			DECLARE @intInvoiceDetailIdToUnblend INT
				  , @intUserIdToUnblend INT
			
			SELECT TOP 1 @intInvoiceDetailIdToUnblend = intInvoiceDetailId, @intUserIdToUnblend = [intUserId] FROM @FinishedGoodItems

			EXEC dbo.uspMFReverseAutoBlend @intSalesOrderDetailId	= NULL
										 , @intInvoiceDetailId		= @intInvoiceDetailIdToUnblend
										 , @intUserId				= @intUserIdToUnblend 

			UPDATE tblARInvoiceDetail 
			SET ysnBlended = 0 
			WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend

			DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
		END

	UPDATE ARI
	SET
		 ARI.ysnPosted					= 0
		,ARI.ysnPaid					= 0
		,ARI.dblAmountDue				= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
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
		,ARI.dblBaseAmountDue			= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
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
		,ARI.dblDiscount				= @ZeroDecimal
		,ARI.dblBaseDiscount			= @ZeroDecimal
		,ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
		,ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
		,ARI.dblInterest				= @ZeroDecimal
		,ARI.dblBaseInterest			= @ZeroDecimal
		,ARI.dblPayment					= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END
		,ARI.dblBasePayment				= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END
		,ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
		,ARI.ysnExcludeFromPayment		= 0
		,ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1
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
	);

	--TANK DELIVERY UNSYNC								
	INSERT INTO @TankDeliveryForUnSync
	SELECT DISTINCT [intInvoiceId] = PID.[intInvoiceId]
	FROM #ARPostInvoiceDetail PID
	INNER JOIN (
		SELECT [intSiteID] 
		FROM dbo.tblTMSite WITH (NOLOCK)
	) TMS ON PID.[intSiteId] = TMS.[intSiteID]				
															
	WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForUnSync ORDER BY intInvoiceId)
		BEGIN							
			DECLARE  @intInvoiceForUnSyncId INT
					,@ResultLogForUnSync NVARCHAR(MAX)
										
			SELECT TOP 1 @intInvoiceForUnSyncId = intInvoiceId FROM @TankDeliveryForUnSync ORDER BY intInvoiceId

			EXEC dbo.uspTMUnSyncInvoiceFromDeliveryHistory  @intInvoiceForUnSyncId, @ResultLogForUnSync OUT
												
			DELETE FROM @TankDeliveryForUnSync WHERE intInvoiceId = @intInvoiceForUnSyncId																		
		END 							
								
	--UPDATE PREPAIDS/CREDIT MEMO FOR CASH REFUND
	DECLARE @CashRefunds AS TABLE (intInvoiceId INT)

	INSERT INTO @CashRefunds
	SELECT intInvoiceId 
	FROM #ARPostInvoiceHeader I
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

	--DELETE FROM UNDEPOSITED FUND
	DELETE CF 
	FROM tblCMUndepositedFund CF
	INNER JOIN #ARPostInvoiceHeader I ON CF.intSourceTransactionId = I.intInvoiceId 
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
		GROUP BY [intEntityCustomerId]
	) INVOICE ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]

	--PATRONAGE
	DECLARE	@successfulCountU INT
		  , @strIdU NVARCHAR(MAX)

	DECLARE @IdsU TABLE(
		  [intInvoiceId]			INT
		, [intLoadId]				INT
		, [ysnFromProvisional]		BIT
		, [ysnProvisionalWithGL]	BIT
	)

	INSERT INTO @IdsU([intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL])
	SELECT [intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL] FROM #ARPostInvoiceHeader

	SELECT @strIdU = COALESCE(@strIdU + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250)) FROM @IdsU

	EXEC [dbo].[uspPATGatherVolumeForPatronage]
		 @transactionIds	= @strIdU
		,@post				= 0
		,@type				= 2
		,@successfulCount	= @successfulCountU OUTPUT

	--INVOICE TRANSACTION HISTORY
	DELETE FROM @Invoices
	INSERT INTO @Invoices([intHeaderId]) 
	SELECT [intInvoiceId] FROM @IdsU
    
	EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @Invoices, 0

	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsU)
	BEGIN
		DECLARE @InvoiceIDU			INT
			  , @LoadIDU			INT
			  , @FromProvisionalU	BIT
			  , @ProvisionalWithGLU BIT

		SELECT TOP 1 @InvoiceIDU = [intInvoiceId]
				   , @LoadIDU = [intLoadId]
				   , @FromProvisionalU = [ysnFromProvisional]
				   , @ProvisionalWithGLU = [ysnProvisionalWithGL] 
		FROM @IdsU 
		ORDER BY [intInvoiceId]
		
        --UPDATE CONTRACT SEQUENCE BALANCE
		EXEC dbo.[uspARInvoiceUpdateSequenceBalance] @TransactionId = @InvoiceIDP, @ysnDelete = 1, @UserId = @UserId
		
		--COMMITTED QTY
		EXEC dbo.[uspARUpdateCommitted] @InvoiceIDU, 1, @UserId, 1

		--IN TRANSIT OUTBOUND QTY
		EXEC dbo.[uspARUpdateInTransit] @InvoiceIDU, 0, 0

		--IN TRANSIT DIRECT QTY
		EXEC dbo.[uspARUpdateInTransitDirect] @InvoiceIDU, 0

		--LOAD SHIPMENT
        IF @FromProvisionalU = 0 OR @ProvisionalWithGLU = 0
			EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost] @InvoiceId	= @InvoiceIDU
														  , @Post		= 0
														  , @LoadId		= @LoadIDU
														  , @UserId		= @UserId

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

--UPDATE BatchIds Used
UPDATE INV
SET INV.[strBatchId]	= CASE WHEN PID.[ysnPost] = 1 THEN PID.[strBatchId] ELSE NULL END
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
	,[dblQtyShipped]				= CASE WHEN ID.[strTransactionType] = 'Credit Memo' AND ID.[intLoadDetailId] IS NOT NULL AND ISNULL(CH.[ysnLoad], 0) = 1 THEN 1 ELSE ID.[dblQtyShipped] END * (CASE WHEN ID.[ysnPost] = 0 THEN -@OneDecimal ELSE @OneDecimal END) * (CASE WHEN ID.[ysnIsInvoicePositive] = 0 THEN -@OneDecimal ELSE @OneDecimal END)
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
	,[intTicketId]					= ID.[intTicketId]
	,[intCustomerStorageId]			= ID.[intCustomerStorageId]
	,[intLoadDetailId]				= ID.[intLoadDetailId]
	,[ysnLeaseBilling]				= ID.[ysnLeaseBilling]				
FROM #ARPostInvoiceDetail ID
INNER JOIN tblCTContractDetail CD ON ID.[intContractDetailId] = CD.[intContractDetailId]	
LEFT JOIN tblCTContractHeader CH ON CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblICInventoryShipmentItem ISI ON ID.[intInventoryShipmentItemId] = ISI.[intInventoryShipmentItemId]
WHERE ID.[intInventoryShipmentChargeId] IS NULL
	AND	(
		(ID.strTransactionType <> 'Credit Memo' AND ((ID.[intInventoryShipmentItemId] IS NULL AND ID.[intLoadDetailId] IS NULL) OR (ISI.[intDestinationGradeId] IS NOT NULL AND ISI.[intDestinationWeightId] IS NOT NULL)))
		OR
		(ID.strTransactionType = 'Credit Memo' AND (ID.[intInventoryShipmentItemId] IS NOT NULL OR ID.[intLoadDetailId] IS NOT NULL))
		)
	AND ID.[strType] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')
    AND ISNULL(ID.[strItemType], '') <> 'Other Charge'

EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @UserId

--UPDATE INVOICE CONTRACT BALANCE
UPDATE ARID
SET ARID.dblContractBalance = CTCD.dblBalance
FROM (
	SELECT intInvoiceDetailId
		 , dblContractBalance
		 , intContractDetailId 
	FROM dbo.tblARInvoiceDetail WITH (NOLOCK)
) ARID
INNER JOIN #ARPostInvoiceDetail PID ON ARID.[intInvoiceDetailId] = PID.[intInvoiceDetailId]
INNER JOIN (
	SELECT intContractDetailId
	     , dblBalance 
	FROM dbo.tblCTContractDetail WITH (NOLOCK)
) CTCD ON ARID.intContractDetailId = CTCD.intContractDetailId
WHERE ARID.dblContractBalance <> CTCD.dblBalance
  AND PID.[strType] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')

--DELETE PREPAID AND CREDIT NOT APPLIED
DELETE A
FROM tblARPrepaidAndCredit A
INNER JOIN #ARPostInvoiceHeader B ON A.intInvoiceId = B.intInvoiceId 
WHERE ysnApplied = 0

--INSERT POST RESULT
IF @IntegrationLogId IS NULL
	INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	SELECT CASE WHEN [ysnPost] = 1 THEN 'Transaction successfully posted.'  ELSE 'Transaction successfully unposted.' END
		 , [strTransactionType]
		 , [strInvoiceNumber]
		 , [strBatchId]
		 , [intInvoiceId]
	FROM #ARPostInvoiceHeader

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

EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @InvoiceLog