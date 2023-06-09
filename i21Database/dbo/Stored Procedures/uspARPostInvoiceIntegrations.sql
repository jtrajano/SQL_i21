CREATE PROCEDURE [dbo].[uspARPostInvoiceIntegrations]
     @Post              BIT				= 0
	,@BatchId           NVARCHAR(40)
    ,@UserId            INT
	,@IntegrationLogId	INT             = NULL
	,@raiseError  		BIT   = 0
	,@strSessionId		NVARCHAR(50) 	= NULL
AS  

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF

--PARAMETER SNIFFING
DECLARE @PostTemp           	BIT				= @Post
	  , @BatchIdTemp           	NVARCHAR(40) 	= @BatchId
      , @UserIdTemp            	INT				= @UserId
	  , @IntegrationLogIdTemp	INT             = @IntegrationLogId
	  , @raiseErrorTemp  		BIT   			= @raiseError

DECLARE @ZeroDecimal	DECIMAL(18,6) = 0.000000
DECLARE @OneDecimal		DECIMAL(18,6) = 1.000000

DECLARE  @InitTranCount				INT
		,@CurrentTranCount			INT
		,@Savepoint					NVARCHAR(32)
		,@CurrentSavepoint			NVARCHAR(32)

SET @InitTranCount = @@TRANCOUNT
SET @Savepoint = SUBSTRING(('ARPostInvoice' + CONVERT(VARCHAR, @InitTranCount)), 1, 32)

IF ISNULL(@raiseErrorTemp,0) = 0
BEGIN
	IF @InitTranCount = 0
		BEGIN TRANSACTION
	ELSE
		SAVE TRANSACTION @Savepoint
END

BEGIN TRY

DECLARE @tblInvoicesToUpdate	AS InvoiceId

INSERT INTO @tblInvoicesToUpdate (intHeaderId, ysnPost, strTransactionType)
SELECT DISTINCT intHeaderId			= intInvoiceId
			  , ysnPost 			= @Post
			  , strTransactionType	= (CASE WHEN @Post = 1 THEN 'Posted' ELSE 'Unposted' END)
FROM tblARPostInvoiceHeader
WHERE strSessionId = @strSessionId

IF @Post = 1
BEGIN
	--UPDATE INVOICE FIELDS
    UPDATE ARI						
    SET ARI.ysnPosted					= 1
	  , ARI.ysnProcessed				= CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ARI.strType = 'POS' THEN 1 ELSE 0 END
      , ARI.ysnPaid						= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') OR ARI.dblAmountDue = @ZeroDecimal THEN 1 ELSE 0 END)
      , ARI.dblAmountDue				= (CASE WHEN ARI.strTransactionType IN ('Cash')
											THEN @ZeroDecimal
											ELSE (
												CASE WHEN ARI.intSourceId = 2 AND ISNULL(ARI.intOriginalInvoiceId, 0) > 0 
												THEN 
													CASE WHEN PID.ysnExcludeInvoiceFromPayment = 1
													THEN ABS(ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal))
													ELSE CASE WHEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) > ISNULL(PROVISIONALPAYMENT.dblPayment, @ZeroDecimal) THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(PROVISIONALPAYMENT.dblPayment, @ZeroDecimal) ELSE @ZeroDecimal END
													END
												ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
												END) 
											END)
       , ARI.dblBaseAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash')
											THEN @ZeroDecimal 
											ELSE (
												CASE WHEN ARI.intSourceId = 2 AND ISNULL(ARI.intOriginalInvoiceId, 0) > 0 
												THEN 
													CASE WHEN PID.ysnExcludeInvoiceFromPayment = 1
													THEN ABS(ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal))
													ELSE CASE WHEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) > ISNULL(PROVISIONALPAYMENT.dblBasePayment, @ZeroDecimal) THEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(PROVISIONALPAYMENT.dblBasePayment, @ZeroDecimal) ELSE @ZeroDecimal END
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
    FROM tblARPostInvoiceHeader PID
    INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON PID.intInvoiceId = ARI.intInvoiceId
	LEFT JOIN (
		SELECT  intInvoiceId, PD.dblPayment, dblBasePayment, P.ysnPosted
		FROM tblARPaymentDetail PD
		INNER JOIN tblARPayment P
		ON PD.intPaymentId = P.intPaymentId
	) PROVISIONALPAYMENT ON PROVISIONALPAYMENT.intInvoiceId = ARI.intOriginalInvoiceId AND PROVISIONALPAYMENT.ysnPosted = 1
	WHERE PID.strSessionId = @strSessionId

	UPDATE ARI
	SET intPeriodId = GL.intGLFiscalYearPeriodId
	FROM tblARInvoice ARI 
	INNER JOIN tblARPostInvoiceHeader PIH ON ARI.intInvoiceId = PIH.intInvoiceId
	CROSS APPLY (
		SELECT TOP 1 P.intGLFiscalYearPeriodId 
		FROM tblGLFiscalYearPeriod P
		WHERE ARI.dtmPostDate BETWEEN dtmStartDate AND dtmEndDate
		ORDER BY intGLFiscalYearPeriodId DESC
	) GL 
	WHERE PIH.strSessionId = @strSessionId

	--UPDATE INVOICE TOTALS
    UPDATE ARPD
    SET ARPD.dblInvoiceTotal		= ARI.dblInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
      , ARPD.dblBaseInvoiceTotal	= ARI.dblBaseInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
      , ARPD.dblAmountDue			= (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
      , ARPD.dblBaseAmountDue		= (ARI.dblBaseInvoiceTotal + ISNULL(ARPD.dblBaseInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblBasePayment, @ZeroDecimal) + ISNULL(ARPD.dblBaseDiscount, @ZeroDecimal))
    FROM tblARPostInvoiceHeader PID
    INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON PID.intInvoiceId = ARI.intInvoiceId
    INNER JOIN tblARPaymentDetail ARPD WITH (NOLOCK) ON ARI.intInvoiceId = ARPD.intInvoiceId
	WHERE PID.strSessionId = @strSessionId

	--CREATE PAYMENT FOR PREPAIDS/CREDIT MEMO TAB
	EXEC dbo.uspARCreateRCVForCreditMemo @intUserId = @UserId, @strSessionId = @strSessionId

	--UPDATE PREPAIDS/CREDIT MEMO FOR CASH REFUND
	UPDATE I
	SET 
		 dblAmountDue		= dblAmountDue - dblAppliedInvoiceAmount
		,dblBaseAmountDue	= dblBaseAmountDue - dblAppliedInvoiceAmount
		,dblPayment			= dblPayment + dblAppliedInvoiceAmount
		,dblBasePayment		= dblBasePayment + dblAppliedInvoiceAmount
		,ysnPaid			= CASE WHEN dblInvoiceTotal = dblPayment + dblAppliedInvoiceAmount THEN 1 ELSE 0 END
		,ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment + dblAppliedInvoiceAmount THEN 1 ELSE 0 END
	FROM tblARInvoice I
	INNER JOIN (										
		SELECT 
			 intPrepaymentId		= PC.intPrepaymentId
			,dblAppliedInvoiceAmount= PC.dblAppliedInvoiceDetailAmount
		FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK)
		INNER JOIN (
			SELECT DISTINCT intInvoiceId 
			FROM tblARPostInvoiceHeader I
			CROSS APPLY (
				SELECT TOP 1 intPrepaymentId
				FROM tblARPrepaidAndCredit WITH (NOLOCK)
				WHERE intInvoiceId = I.intInvoiceId 
				  AND ysnApplied = 1
				  AND dblAppliedInvoiceDetailAmount > 0
			) PREPAIDS
			WHERE I.strTransactionType = 'Cash Refund'
			  AND I.strSessionId = @strSessionId
		) CR ON PC.intInvoiceId = CR.intInvoiceId
		WHERE PC.ysnApplied = 1
		  AND PC.dblAppliedInvoiceDetailAmount > 0
	) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId
	
	--AUTO APPLY PREPAIDS
	EXEC dbo.uspARAutoApplyPrepaids @intEntityUserId = @UserId, @strSessionId = @strSessionId
END

IF @PostTemp = 0
BEGIN
	--REVERSE BLEND FOR FINISHED GOODS
	BEGIN
		DECLARE @FinishedGoodItems AS TABLE (
				[intInvoiceDetailId]	INT
			, [intUserId]			INT
		)

		INSERT INTO @FinishedGoodItems
		SELECT DISTINCT [intInvoiceDetailId] = UPD.[intInvoiceDetailId]
						, [intUserId]          = UPD.[intUserId]
		FROM tblARPostInvoiceDetail UPD
		INNER JOIN tblMFWorkOrder MFWO ON UPD.[intInvoiceDetailId] = MFWO.[intInvoiceDetailId]
		WHERE UPD.[ysnBlended] = 1
		  AND UPD.strSessionId = @strSessionId

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
	END

	--UPDATE INVOICE FIELDS
	BEGIN
		UPDATE ARI
		SET ARI.ysnPosted					= 0
			, ARI.ysnPaid					= 0
			, ARI.dblAmountDue				= (CASE WHEN ARI.strTransactionType IN ('Cash')
												THEN @ZeroDecimal
												ELSE (
													CASE WHEN ARI.intSourceId = 2 AND ISNULL(ARI.intOriginalInvoiceId, 0) > 0 
													THEN 
														CASE WHEN PID.ysnExcludeInvoiceFromPayment = 1
														THEN ABS(ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal))
														ELSE CASE WHEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) > ISNULL(PROVISIONALPAYMENT.dblPayment, @ZeroDecimal) THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(PROVISIONALPAYMENT.dblPayment, @ZeroDecimal) ELSE @ZeroDecimal END
														END
													ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
													END) 
												END)
			, ARI.dblBaseAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash')
												THEN @ZeroDecimal 
												ELSE (
													CASE WHEN ARI.intSourceId = 2 AND ISNULL(ARI.intOriginalInvoiceId, 0) > 0 
													THEN 
														CASE WHEN PID.ysnExcludeInvoiceFromPayment = 1
														THEN ABS(ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal))
														ELSE CASE WHEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) > ISNULL(PROVISIONALPAYMENT.dblBasePayment, @ZeroDecimal) THEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(PROVISIONALPAYMENT.dblBasePayment, @ZeroDecimal) ELSE @ZeroDecimal END
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
			, ARI.dblPayment				= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END
			, ARI.dblBasePayment			= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END
			, ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
			, ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1
			, ARI.intPeriodId				= NULL
		FROM tblARPostInvoiceHeader PID
		INNER JOIN tblARInvoice ARI WITH (NOLOCK) ON PID.intInvoiceId = ARI.intInvoiceId 					
		LEFT OUTER JOIN (
			SELECT  intInvoiceId, PD.dblPayment, dblBasePayment, P.ysnPosted
			FROM	tblARPaymentDetail PD
			INNER JOIN tblARPayment P
			ON PD.intPaymentId = P.intPaymentId
		) PROVISIONALPAYMENT ON PROVISIONALPAYMENT.intInvoiceId = ARI.intOriginalInvoiceId AND PROVISIONALPAYMENT.ysnPosted = 1
		WHERE PID.strSessionId = @strSessionId
	END
																
	DELETE PD
	FROM tblARPaymentDetail PD
	INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 0
	WHERE PD.intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM tblARPostInvoiceHeader WHERE [ysnPost] = 0 AND strSessionId = @strSessionId)
								
	--UPDATE PREPAIDS/CREDIT MEMO FOR CASH REFUND
	UPDATE I
	SET dblAmountDue		= dblAmountDue + dblAppliedInvoiceAmount
	  , dblBaseAmountDue	= dblBaseAmountDue + dblAppliedInvoiceAmount
	  , dblPayment			= dblPayment - dblAppliedInvoiceAmount
	  , dblBasePayment		= dblBasePayment - dblAppliedInvoiceAmount
	  , ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment - dblAppliedInvoiceAmount THEN 1 ELSE 0 END
	  , ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment - dblAppliedInvoiceAmount THEN 1 ELSE 0 END
	FROM tblARInvoice I
	INNER JOIN (										
		SELECT intPrepaymentId			= PC.intPrepaymentId
			 , dblAppliedInvoiceAmount	= PC.dblAppliedInvoiceDetailAmount
		FROM dbo.tblARPrepaidAndCredit PC WITH (NOLOCK)
		INNER JOIN (
			SELECT DISTINCT intInvoiceId 
			FROM tblARPostInvoiceHeader I
			CROSS APPLY (
				SELECT TOP 1 intPrepaymentId
				FROM tblARPrepaidAndCredit WITH (NOLOCK)
				WHERE intInvoiceId = I.intInvoiceId 
				  AND ysnApplied = 1
				  AND dblAppliedInvoiceDetailAmount > 0
			) PREPAIDS
			WHERE I.strTransactionType = 'Cash Refund'
			  AND I.strSessionId = @strSessionId
		) CR ON PC.intInvoiceId = CR.intInvoiceId
		WHERE PC.ysnApplied = 1
		  AND PC.dblAppliedInvoiceDetailAmount > 0
	) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId

	--DELETE UNDEPOSITED FUND FOR CASH
	DELETE CF 
	FROM tblCMUndepositedFund CF
	INNER JOIN tblARPostInvoiceHeader I ON CF.intSourceTransactionId = I.intInvoiceId AND CF.strSourceTransactionId = I.strInvoiceNumber
	WHERE CF.strSourceSystem = 'AR'
	  AND I.strSessionId = @strSessionId
END

--UPDATE HD TICKET HOURS
UPDATE HDTHW
SET HDTHW.[ysnBilled]  	= CASE WHEN PID.[ysnPost] = 1 THEN 1 ELSE 0 END
	, HDTHW.[dtmBilled] = CASE WHEN PID.[ysnPost] = 1 THEN ISNULL(HDTHW.[dtmBilled], GETDATE()) ELSE NULL END
FROM tblARPostInvoiceHeader PID
INNER JOIN tblHDTicketHoursWorked HDTHW WITH (NOLOCK) ON PID.[intInvoiceId] = HDTHW.[intInvoiceId]
WHERE PID.strSessionId = @strSessionId

--HELPDESK SYNC
IF EXISTS (
 SELECT TOP 1 ''
 FROM tblARPostInvoiceHeader PID
 INNER JOIN tblHDTicketHoursWorked HDTHW WITH (NOLOCK) ON PID.[intInvoiceId] = HDTHW.[intInvoiceId]
 WHERE PID.strSessionId = @strSessionId
)
BEGIN
	EXEC [dbo].[uspHDUpdateTimeEntryPeriodDetailStatus] @strSessionId
END

--TANK DELIVERY SYNC
BEGIN
DECLARE @TankDeliveryForSync TABLE ([intInvoiceId] INT, UNIQUE (intInvoiceId))
							
INSERT INTO @TankDeliveryForSync ([intInvoiceId])
SELECT DISTINCT [intInvoiceId] = PID.[intInvoiceId]
FROM tblARPostInvoiceDetail PID
INNER JOIN dbo.tblTMSite TMS WITH (NOLOCK) ON PID.[intSiteId] = TMS.[intSiteID] 
WHERE PID.strSessionId = @strSessionId

IF(@Post = 1)
BEGIN
	DECLARE @InvoicesToSyncTable Id

	INSERT INTO @InvoicesToSyncTable (intId)
	SELECT DISTINCT intInvoiceId FROM @TankDeliveryForSync

	EXEC uspTMBatchSyncInvoiceToDeliveryHistory @InvoicesToSyncTable, @UserId  
END
ELSE
BEGIN
	WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForSync)
	BEGIN
		DECLARE @intInvoiceForSyncId INT
			, @ResultLogForSync NVARCHAR(MAX)
															
		SELECT TOP 1 @intInvoiceForSyncId = [intInvoiceId] 
		FROM @TankDeliveryForSync 
		ORDER BY [intInvoiceId]

		
		EXEC dbo.uspTMUnSyncInvoiceFromDeliveryHistory 
					@InvoiceId = @intInvoiceForSyncId
					,@intUserId = @UserId  
					,@ResultLog = @ResultLogForSync OUT
												
		DELETE FROM @TankDeliveryForSync WHERE [intInvoiceId] = @intInvoiceForSyncId
	END
END
END

--UPDATE CUSTOMER AR BALANCE
UPDATE CUSTOMER
SET CUSTOMER.dblARBalance = CUSTOMER.dblARBalance + CASE WHEN @Post = 1 THEN dblTotalInvoice ELSE -dblTotalInvoice END
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
INNER JOIN (
	SELECT [intEntityCustomerId] = [intEntityCustomerId]
		 , [dblTotalInvoice]     = SUM(CASE WHEN [ysnIsInvoicePositive] = 1 THEN [dblInvoiceTotal] - ISNULL(REFUND.dblRefundTotal, 0) ELSE -[dblInvoiceTotal] - ISNULL(REFUND.dblRefundTotal, 0) END)
	FROM tblARPostInvoiceHeader IH
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
	  AND IH.strSessionId = @strSessionId
	GROUP BY [intEntityCustomerId]
) INVOICE ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]	

--UPDATE INVOICE TRANSACTION HISTORY
EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @InvoiceIds = @tblInvoicesToUpdate, @Post = @Post, @strSessionId = @strSessionId

--PATRONAGE
BEGIN
DECLARE	@strInvoiceIds	NVARCHAR(MAX)	
SELECT @strInvoiceIds = COALESCE(@strInvoiceIds + ',' ,'') + CAST([intHeaderId] AS NVARCHAR(250)) FROM @tblInvoicesToUpdate

EXEC [dbo].[uspPATGatherVolumeForPatronage] @transactionIds	= @strInvoiceIds
										  , @post			= @Post
										  , @type			= 2
END

--LOAD SHIPMENT POST
BEGIN
DECLARE @tblLoadShipment TABLE (
	  [intInvoiceId]			INT
	, [intLoadId]				INT
	, [intPurchaseSale]			INT
	, [ysnFromProvisional]		BIT
	, [ysnProvisionalWithGL]	BIT
	, [ysnFromReturn]			BIT
)

INSERT INTO @tblLoadShipment (
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
	 , [ysnFromReturn] 			= CASE WHEN I.[strTransactionType] = 'Credit Memo' AND RI.[intInvoiceId] IS NOT NULL THEN 1 ELSE 0 END
FROM tblARPostInvoiceHeader I
INNER JOIN tblLGLoad LG ON I.intLoadId = LG.intLoadId
OUTER APPLY (
	SELECT TOP 1 intInvoiceId 
	FROM tblARInvoice RET
	WHERE RET.strTransactionType = 'Invoice'
	  AND RET.ysnReturned = 1
	  AND I.strInvoiceOriginId = RET.strInvoiceNumber
	  AND I.intOriginalInvoiceId = RET.intInvoiceId
) RI
WHERE I.strSessionId = @strSessionId

WHILE EXISTS(SELECT TOP 1 NULL FROM @tblLoadShipment)
BEGIN
	DECLARE @intInvoiceId 			INT = NULL
		  , @intLoadId 				INT = NULL
		  , @intPurchaseSaleId		INT = NULL
		  , @ysnFromProvisional 	BIT = 0
		  , @ysnProvisionalWithGL	BIT = 0
		  , @ysnFromReturn 			BIT = 0				

	SELECT TOP 1 @intInvoiceId			= [intInvoiceId]
			   , @intLoadId				= [intLoadId]
			   , @intPurchaseSaleId		= [intPurchaseSale]
			   , @ysnFromProvisional	= [ysnFromProvisional]
			   , @ysnProvisionalWithGL 	= [ysnProvisionalWithGL]
			   , @ysnFromReturn			= [ysnFromReturn]
	FROM @tblLoadShipment 
	ORDER BY [intInvoiceId]

	--LOAD SHIPMENT
	IF @ysnFromProvisional = 0 OR @ysnProvisionalWithGL = 0
		EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost] @InvoiceId = @intInvoiceId, @Post = @Post, @LoadId = @intLoadId, @UserId = @UserId

	DELETE FROM @tblLoadShipment WHERE [intInvoiceId] = @intInvoiceId
END
END

--UPDATE THE STOCK USAGE
BEGIN 
	DECLARE @UsageItems AS ItemCostingTableType
	INSERT INTO @UsageItems (
		  intTransactionId
		, strTransactionId
		, intItemId
		, intItemLocationId
		, intItemUOMId
		, dtmDate
		, dblQty
		, dblUOMQty
		, intSubLocationId
		, intStorageLocationId
		, intTransactionTypeId
	)
	SELECT intTransactionId		= Inv.intInvoiceId
		, strTransactionId		= Inv.strInvoiceNumber
		, intItemId				= InvDet.intItemId
		, intItemLocationId		= ItemLocation.intItemLocationId
		, intItemUOMId			= iu.intItemUOMId
		, dtmDate				= Inv.dtmDate
		, dblQty				= CASE WHEN Inv.strTransactionType = 'Credit Memo' THEN -InvDet.dblQtyShipped ELSE InvDet.dblQtyShipped END
		, dblUOMQty				= iu.dblUnitQty
		, intSubLocationId		= InvDet.intSubLocationId
		, intStorageLocationId	= InvDet.intStorageLocationId
		, intTransactionTypeId	= CASE WHEN Inv.strTransactionType = 'Credit Memo' THEN 45 ELSE 33 END
	FROM tblARPostInvoiceHeader I 
	INNER JOIN tblARInvoice Inv ON I.strInvoiceNumber = Inv.strInvoiceNumber
	INNER JOIN tblARInvoiceDetail InvDet ON InvDet.intInvoiceId = Inv.intInvoiceId
	INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = InvDet.intItemId AND ItemLocation.intLocationId = Inv.intCompanyLocationId
	INNER JOIN tblICItemUOM iu ON iu.intItemId = InvDet.intItemId AND iu.intItemUOMId = InvDet.intItemUOMId
	WHERE Inv.strTransactionType IN('Invoice', 'Cash', 'Credit Memo', 'Debit Memo')
	  AND I.strSessionId = @strSessionId

	INSERT INTO @UsageItems (
		  intTransactionId
		, strTransactionId
		, intItemId
		, intItemLocationId
		, intItemUOMId
		, dtmDate
		, dblQty
		, dblUOMQty
		, intSubLocationId
		, intStorageLocationId
		, intTransactionTypeId
	)
	SELECT intTransactionId		= Inv.intInvoiceId
		, strTransactionId		= Inv.strInvoiceNumber
		, intItemId				= PrepaidDetail.intItemId
		, intItemLocationId		= ItemLocation.intItemLocationId
		, intItemUOMId			= iu.intItemUOMId
		, dtmDate				= Inv.dtmDate
		, dblQty				= -PrepaidDetail.dblQtyShipped
		, dblUOMQty				= iu.dblUnitQty
		, intSubLocationId		= PrepaidDetail.intSubLocationId
		, intStorageLocationId	= PrepaidDetail.intStorageLocationId
		, intTransactionTypeId	= CASE WHEN Inv.strTransactionType = 'Credit Memo' THEN 45 ELSE 33 END
	FROM tblARPostInvoiceHeader I 
	INNER JOIN tblARInvoice Inv ON I.strInvoiceNumber = Inv.strInvoiceNumber
	INNER JOIN tblARPrepaidAndCredit Prepaid ON Prepaid.intInvoiceId = Inv.intInvoiceId
	INNER JOIN tblARInvoiceDetail PrepaidDetail ON PrepaidDetail.intInvoiceId = Prepaid.intPrepaymentId
	INNER JOIN tblICItemLocation ItemLocation ON ItemLocation.intItemId = PrepaidDetail.intItemId AND ItemLocation.intLocationId = Inv.intCompanyLocationId
	INNER JOIN tblICItemUOM iu ON iu.intItemId = PrepaidDetail.intItemId AND iu.intItemUOMId = PrepaidDetail.intItemUOMId
	WHERE Inv.strTransactionType IN ('Cash Refund')
	  AND I.strSessionId = @strSessionId

	UPDATE u
	SET u.dblQty = CASE WHEN @PostTemp = 1 THEN u.dblQty ELSE -u.dblQty END 
	FROM @UsageItems u

	EXEC uspICIncreaseUsageQty @UsageItems, @UserId
END 

--UPDATE CUSTOMER CREDIT LIMIT REACHED
UPDATE CUSTOMER
SET [dtmCreditLimitReached] =  CASE WHEN ISNULL(CUSTOMER.[dblARBalance], 0) >= ISNULL(CUSTOMER.[dblCreditLimit], 0) THEN ISNULL(CUSTOMER.[dtmCreditLimitReached], INVOICE.[dtmPostDate]) ELSE NULL END
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
INNER JOIN (
	SELECT [dtmPostDate]	 		= MAX(I.[dtmPostDate])
		 , [intEntityCustomerId]	= I.intEntityCustomerId
	FROM tblARPostInvoiceHeader I WITH (NOLOCK)
	INNER JOIN tblARCustomer C WITH (NOLOCK) ON I.intEntityCustomerId = C.intEntityId
	WHERE I.strSessionId = @strSessionId
	  AND C.dblCreditLimit > 0	
	GROUP BY I.intEntityCustomerId
) INVOICE ON CUSTOMER.intEntityId = INVOICE.intEntityCustomerId
WHERE CUSTOMER.[dblCreditLimit] > @ZeroDecimal

--UPDATE HIGHEST AR
UPDATE CUSTOMER
SET dblHighestAR		= CUSTOMER.dblARBalance
  , dtmHighestARDate	= CAST(GETDATE() AS DATE)
FROM dbo.tblARCustomer CUSTOMER
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM tblARPostInvoiceHeader WITH (NOLOCK)
	WHERE strSessionId = @strSessionId
) INVOICE ON CUSTOMER.intEntityId = INVOICE.intEntityCustomerId
WHERE CUSTOMER.dblARBalance > ISNULL(CUSTOMER.dblHighestAR, 0)

--UPDATE HIGHEST DUE AR
UPDATE CUSTOMER
SET dblHighestDueAR		= DUE.dblPastDue
  , dtmHighestDueARDate	= CAST(GETDATE() AS DATE)
FROM dbo.tblARCustomer CUSTOMER
INNER JOIN (
    SELECT intEntityCustomerId	= I.intEntityCustomerId
         , dblPastDue			= SUM(CASE WHEN DATEDIFF(DAYOFYEAR, I.dtmDueDate, I.dtmPostDate) > 0
                                        THEN 
                                                CASE WHEN I.strTransactionType NOT IN ('Credit Memo', 'Customer Prepayment', 'Overpayment') 
                                                    THEN I.dblAmountDue
                                                    ELSE -I.dblAmountDue
                                                END 
                                        ELSE 0 
                                    END) 
    FROM tblARInvoice I
    INNER JOIN (
        SELECT DISTINCT intEntityCustomerId
        FROM tblARPostInvoiceHeader
		WHERE strSessionId = @strSessionId
    ) INVOICE ON I.intEntityCustomerId = INVOICE.intEntityCustomerId
    WHERE I.ysnPosted = 1
      AND I.ysnForgiven = 0
      AND I.ysnPaid = 0
      AND I.dblAmountDue <> 0
      AND I.strTransactionType <> 'Cash Refund'
      AND I.dtmPostDate <= GETDATE()
    GROUP BY I.intEntityCustomerId
) DUE ON CUSTOMER.intEntityId = DUE.intEntityCustomerId
     AND DUE.dblPastDue > 0
     AND DUE.dblPastDue > CUSTOMER.dblHighestDueAR

--UPDATE BATCH ID
UPDATE INV
SET INV.[strBatchId]	 = CASE WHEN PID.[ysnPost] = 1 THEN PID.[strBatchId] ELSE NULL END
  , INV.[dtmBatchDate]  = CASE WHEN PID.[ysnPost] = 1 THEN CAST(GETDATE() AS DATE) ELSE NULL END
  , INV.[intPostedById] = CASE WHEN PID.[ysnPost] = 1 THEN PID.[intUserId] ELSE NULL END
FROM tblARInvoice INV
INNER JOIN tblARPostInvoiceHeader PID ON INV.[intInvoiceId] = PID.[intInvoiceId]
WHERE PID.strSessionId = @strSessionId

--UPDATE CONTRACT BALANCE
EXEC dbo.uspARUpdateContractOnPost @UserIdTemp, @Post, @strSessionId

--UPDATE CONTRACTS FINANCIAL STATUS
BEGIN
UPDATE CD 
SET strFinancialStatus = FS.strFinancialStatus
FROM tblARPostInvoiceDetail ID
INNER JOIN tblCTContractDetail CD ON CD.intContractDetailId = ID.intContractDetailId
CROSS APPLY dbo.fnCTGetFinancialStatus(ID.intContractDetailId) FS
WHERE ID.intContractDetailId IS NOT NULL
  AND ID.strSessionId = @strSessionId
END

--UPDATE ITEM CONTRACT BALANCE
BEGIN
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
FROM tblARPostInvoiceDetail PID
INNER JOIN tblARInvoiceDetail ID ON PID.intInvoiceDetailId = ID.intInvoiceDetailId
INNER JOIN tblCTItemContractDetail ICD ON ID.intItemContractDetailId = ICD.intItemContractDetailId
WHERE ID.intItemContractDetailId IS NOT NULL
  AND ISNULL(ID.strPricing, 'Inventory - Standard Pricing') <> 'Subsystem - Direct'
  AND PID.strSessionId = @strSessionId

EXEC dbo.uspCTItemContractInvoicePosted @tblItemContracts, @UserId
END

--UPDATE INVENTORY ITEM COMMITTED
EXEC dbo.[uspARUpdateCommitted] @strSessionId = @strSessionId

--IN TRANSIT OUTBOUND QTY
EXEC dbo.[uspARUpdateInTransit] @strSessionId = @strSessionId

--IN TRANSIT DIRECT QTY
EXEC dbo.[uspARUpdateInTransitDirect] @strSessionId = @strSessionId

DELETE A
FROM tblARPrepaidAndCredit A
INNER JOIN tblARPostInvoiceHeader B ON A.intInvoiceId = B.intInvoiceId 
WHERE ysnApplied = 0
  AND B.strSessionId = @strSessionId

--POST RESULT
IF @IntegrationLogIdTemp IS NULL
	BEGIN
		INSERT INTO tblARPostResult(
			  strMessage
			, strTransactionType
			, strTransactionId
			, strBatchNumber
			, intTransactionId
		)
		SELECT CASE WHEN [ysnPost] = 1 THEN 'Transaction successfully posted.'  ELSE 'Transaction successfully unposted.' END
			, [strTransactionType] = CASE strTransactionType WHEN 'Debit Memo' THEN 'Debit Memo (Sales)' ELSE strTransactionType END
			, [strInvoiceNumber]
			, [strBatchId]
			, [intInvoiceId]
		FROM tblARPostInvoiceHeader
		WHERE strSessionId = @strSessionId
	END

--SALES ANALYSIS REPORT
EXEC dbo.uspARSalesAnalysisReport @tblTransactionIds 	= @tblInvoicesToUpdate
							    , @ysnInvoice 			= 1
								, @ysnRebuild 			= 0
								, @ysnPost 				= @Post
								
--UPDATE GROSS MARGIN SUMMARY
EXEC dbo.uspARInvoiceGrossMarginSummary @ysnRebuild = 0
									  , @InvoiceId	= @tblInvoicesToUpdate

--INTER COMPANY PRE-STAGE
EXEC dbo.uspIPInterCompanyPreStageInvoice @PreStageInvoice	= @tblInvoicesToUpdate
									    , @intUserId		= @UserIdTemp		

--CREATE INVENTORY RECEIPT TO ANOTHER COMPANY
EXEC dbo.uspARInterCompanyIntegrationSource @BatchId = @BatchId, @Post = @Post, @strSessionId = @strSessionId

-- --DELETE FROM POSTING QUEUE
-- DELETE PQ
-- FROM tblARPostingQueue PQ
-- INNER JOIN tblARPostInvoiceHeader II WITH (NOLOCK) ON II.strInvoiceNumber = PQ.strTransactionNumber AND II.intInvoiceId = PQ.intTransactionId
-- WHERE II.strSessionId = @strSessionId

--AUDIT LOG
BEGIN
DECLARE @InvoiceLog dbo.[AuditLogStagingTable]

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
FROM tblARPostInvoiceHeader
WHERE strSessionId = @strSessionId

EXEC [dbo].[uspARInsertAuditLogs] @LogEntries = @InvoiceLog, @intUserId = @UserId

UPDATE ILD
SET
	 ILD.[ysnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
	,ILD.[ysnUnPosted]				= CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
	,ILD.[strPostingMessage]		= CASE WHEN ILD.[ysnPost] = 1 THEN 'Transaction successfully posted.' ELSE 'Transaction successfully unposted.' END
	,ILD.[strBatchId]				= @BatchId
	,ILD.[strPostedTransactionId]	= PID.[strInvoiceNumber] 
FROM tblARInvoiceIntegrationLogDetail ILD
INNER JOIN tblARPostInvoiceHeader PID ON ILD.[intInvoiceId] = PID.[intInvoiceId]
WHERE ILD.[intIntegrationLogId] = @IntegrationLogId
	AND ILD.[ysnPost] IS NOT NULL
	--AND PID.strType = 'Store End of Day'
	AND PID.strSessionId = @strSessionId

DELETE FROM tblARPostInvoiceHeader WHERE strSessionId = @strSessionId
DELETE FROM tblARPostInvoiceDetail WHERE strSessionId = @strSessionId
DELETE FROM tblARPostInvoiceItemAccount WHERE strSessionId = @strSessionId
DELETE FROM tblARPostInvalidInvoiceData WHERE strSessionId = @strSessionId
DELETE FROM tblARPostItemsForCosting WHERE strSessionId = @strSessionId
DELETE FROM tblARPostItemsForInTransitCosting WHERE strSessionId = @strSessionId
DELETE FROM tblARPostItemsForContracts WHERE strSessionId = @strSessionId
DELETE FROM tblARPostItemsForStorageCosting WHERE strSessionId = @strSessionId
DELETE FROM tblARPostInvoiceGLEntries WHERE strSessionId = @strSessionId

END

--AUTO DEBIT MEMO VENDOR REBATE SALES
DECLARE @InvoicesForIntegration Id
DECLARE @strTransactionType NVARCHAR(200)

INSERT INTO @InvoicesForIntegration
SELECT intValue FROM fnCreateTableFromDelimitedValues(@strInvoiceIds, ',')

WHILE EXISTS(SELECT 1 FROM @InvoicesForIntegration)
BEGIN
	DECLARE @intInvoiceForIntegration INT
	SELECT @intInvoiceForIntegration = intId FROM @InvoicesForIntegration

	SELECT @strTransactionType = strTransactionType
	FROM tblARInvoice 
	WHERE intInvoiceId = @intInvoiceForIntegration

	IF @strTransactionType = 'Invoice'
		EXEC dbo.[uspVRCreateDebitMemoOrVoucher] @intInvoiceForIntegration, @Post, @UserId, 'Debit Memo'
	ELSE IF @strTransactionType = 'Credit Memo'
		EXEC dbo.[uspVRCreateDebitMemoOrVoucher] @intInvoiceForIntegration, @Post, @UserId, 'Voucher'

	DELETE FROM @InvoicesForIntegration WHERE intId = @intInvoiceForIntegration
END

END TRY
BEGIN CATCH
    DECLARE @ErrorMerssage NVARCHAR(MAX)
	SELECT @ErrorMerssage = ERROR_MESSAGE()

	IF @raiseErrorTemp = 0
	BEGIN
		IF @InitTranCount = 0
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION
		ELSE
			IF (XACT_STATE()) <> 0
				ROLLBACK TRANSACTION @Savepoint
	END
												
	RAISERROR(@ErrorMerssage, 11, 1)
		
	GOTO Post_Exit
END CATCH

Post_Exit:
	RETURN 0;