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

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @OneDecimal DECIMAL(18,6)
SET @OneDecimal = 1.000000

DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
DECLARE @Invoices AS dbo.[InvoiceId]


--DECLARE @PostData [InvoicePostingTable]
--INSERT INTO @PostData
--SELECT * FROM #ARPostInvoiceData
--WHERE
--	[ysnPost] = 1
--	AND [strType] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')

IF @Post = 1
BEGIN
    --UPDATE ARI						
--SET
--		ARI.ysnPosted					= 1
--	,ARI.ysnPaid					= (CASE WHEN ARI.dblInvoiceTotal = @ZeroDecimal OR ARI.dblAmountDue = @ZeroDecimal OR ARI.strTransactionType IN ('Cash') OR ARI.dblInvoiceTotal = ARI.dblPayment THEN 1 ELSE 0 END)
--	,ARI.dblAmountDue				= (CASE WHEN ARI.strTransactionType IN ('Cash')
--											THEN @ZeroDecimal
--											ELSE (CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
--														THEN 
--															CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) > @ZeroDecimal
--																	THEN ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal))
--																	ELSE (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal)
--															END
--														ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
--													END) 
--										END)
--	,ARI.dblBaseAmountDue			= (CASE WHEN ARI.strTransactionType IN ('Cash')
--											THEN @ZeroDecimal 
--											ELSE (CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
--														THEN 
--															CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) > @ZeroDecimal
--																	THEN ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal))
--																	ELSE (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal)
--															END
--														ELSE ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)
--													END) 
--										END)
--	,ARI.dblDiscount				= @ZeroDecimal
--	,ARI.dblBaseDiscount			= @ZeroDecimal
--	,ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
--	,ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
--	,ARI.dblInterest				= @ZeroDecimal
--	,ARI.dblBaseInterest			= @ZeroDecimal
--	,ARI.dblPayment					= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblPayment, @ZeroDecimal) END)
--	,ARI.dblBasePayment				= (CASE WHEN ARI.strTransactionType IN ('Cash') THEN ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) ELSE ISNULL(ARI.dblBasePayment, @ZeroDecimal) END)
--	,ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
--	,ARI.ysnExcludeFromPayment		= PID.ysnExcludeInvoiceFromPayment
--	,ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1	
--FROM
--	(SELECT intInvoiceId, ysnExcludeInvoiceFromPayment FROM @PostInvoiceData ) PID
--INNER JOIN
--	(SELECT intInvoiceId, ysnPosted, ysnPaid, dblInvoiceTotal, dblBaseInvoiceTotal, dblAmountDue, dblBaseAmountDue, dblDiscount, dblBaseDiscount, dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest, dblPayment, dblBasePayment, dtmPostDate, intConcurrencyId, intSourceId, intOriginalInvoiceId, dblProvisionalAmount, dblBaseProvisionalAmount, strTransactionType, dtmDate, ysnExcludeFromPayment
--		FROM dbo.tblARInvoice WITH (NOLOCK))  ARI ON PID.intInvoiceId = ARI.intInvoiceId

--UPDATE ARPD
--SET
--		ARPD.dblInvoiceTotal		= ARI.dblInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
--	,ARPD.dblBaseInvoiceTotal	= ARI.dblBaseInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
--	,ARPD.dblAmountDue			= (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
--	,ARPD.dblBaseAmountDue		= (ARI.dblBaseInvoiceTotal + ISNULL(ARPD.dblBaseInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblBasePayment, @ZeroDecimal) + ISNULL(ARPD.dblBaseDiscount, @ZeroDecimal))
--FROM
--	(SELECT intInvoiceId FROM @PostInvoiceData ) PID
--INNER JOIN
--	(SELECT intInvoiceId, dblInvoiceTotal, dblBaseInvoiceTotal, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
--		ON PID.intInvoiceId = ARI.intInvoiceId
--INNER JOIN
--	(SELECT intInvoiceId, dblInterest, dblBaseInterest, dblDiscount, dblBaseDiscount, dblAmountDue, dblBaseAmountDue, dblInvoiceTotal, dblBaseInvoiceTotal, dblPayment, dblBasePayment FROM dbo.tblARPaymentDetail WITH (NOLOCK)) ARPD
--		ON ARI.intInvoiceId = ARPD.intInvoiceId 

----Insert Successfully posted transactions.
--INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
--SELECT 
--	@PostSuccessfulMsg
--	,PID.strTransactionType
--	,PID.strInvoiceNumber
--	,@batchIdUsed
--	,PID.intInvoiceId
--FROM
--	@PostInvoiceData PID
--WHERE
--	PID.[intInvoiceDetailId] IS NULL
					
----Update tblHDTicketHoursWorked ysnBilled					
--UPDATE HDTHW						
--SET
--		HDTHW.ysnBilled = 1
--	,HDTHW.dtmBilled = (case when HDTHW.dtmBilled is null then GETDATE() else HDTHW.dtmBilled end)
--FROM
--	(SELECT intInvoiceId FROM @PostInvoiceData ) PID
--INNER JOIN
--	(SELECT intInvoiceId, dtmBilled, ysnBilled FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)) HDTHW
--		ON PID.intInvoiceId = HDTHW.intInvoiceId
						
--BEGIN TRY
--	DECLARE @TankDeliveryForSync TABLE (
--			intInvoiceId INT,
--			UNIQUE (intInvoiceId));
								
--	INSERT INTO @TankDeliveryForSync					
--	SELECT DISTINCT
--		I.intInvoiceId
--	FROM
--		(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK)) I
--	INNER JOIN
--		(SELECT intInvoiceId, intSiteId FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) D
--			ON I.intInvoiceId = D.intInvoiceId		
--	INNER JOIN
--		(SELECT intSiteID FROM dbo.tblTMSite WITH (NOLOCK)) TMS
--			ON D.intSiteId = TMS.intSiteID 
--	INNER JOIN 
--		(SELECT intInvoiceId FROM @PostInvoiceData) B
--			ON I.intInvoiceId = B.intInvoiceId
								
--	WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForSync ORDER BY intInvoiceId)
--		BEGIN
							
--			DECLARE  @intInvoiceForSyncId INT
--					,@ResultLogForSync NVARCHAR(MAX)
										
								
--			SELECT TOP 1 @intInvoiceForSyncId = intInvoiceId FROM @TankDeliveryForSync ORDER BY intInvoiceId

--			EXEC dbo.uspTMSyncInvoiceToDeliveryHistory @intInvoiceForSyncId, @userId, @ResultLogForSync OUT
												
--			DELETE FROM @TankDeliveryForSync WHERE intInvoiceId = @intInvoiceForSyncId
																												
--		END 							
						
--	--CREATE PAYMENT FOR PREPAIDS/CREDIT MEMO TAB
--	DECLARE @InvoicesWithPrepaids AS TABLE (intInvoiceId INT, strTransactionType NVARCHAR(100))
						
--	INSERT INTO @InvoicesWithPrepaids
--	SELECT intInvoiceId, strTransactionType 
--	FROM @PostInvoiceData I
--	CROSS APPLY (										
--		SELECT TOP 1 intPrepaymentId
--		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
--		WHERE intInvoiceId = I.intInvoiceId 
--			AND ysnApplied = 1
--			AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
--	) PREPAIDS

--	WHILE EXISTS(SELECT TOP 1 1 FROM @InvoicesWithPrepaids)
--		BEGIN
--			DECLARE @intInvoiceIdWithPrepaid INT = NULL
--					, @strTransactionTypePrepaid NVARCHAR(100) = NULL

--			SELECT TOP 1 @intInvoiceIdWithPrepaid = intInvoiceId
--						, @strTransactionTypePrepaid = strTransactionType
--			FROM @InvoicesWithPrepaids
							
--			IF @strTransactionTypePrepaid <> 'Cash Refund'
--				EXEC dbo.uspARCreateRCVForCreditMemo @intInvoiceId = @intInvoiceIdWithPrepaid, @intUserId = @userId
--			ELSE
--				BEGIN
--					UPDATE I
--					SET dblAmountDue		= dblAmountDue - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--						, dblBaseAmountDue	= dblBaseAmountDue - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--						, dblPayment			= dblPayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--						, dblBasePayment		= dblBasePayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--						, ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
--						, ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
--					FROM tblARInvoice I
--					INNER JOIN (										
--						SELECT intPrepaymentId			= intPrepaymentId
--								, dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal)
--						FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
--						WHERE intInvoiceId = @intInvoiceIdWithPrepaid 
--							AND ysnApplied = 1
--							AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
--					) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId
--				END
								
--			DELETE FROM @InvoicesWithPrepaids WHERE intInvoiceId = @intInvoiceIdWithPrepaid
--		END
																
--END TRY
--BEGIN CATCH
--	SELECT @ErrorMerssage = ERROR_MESSAGE()										
--	GOTO Do_Rollback
--END CATCH
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
    FROM
        #ARPostInvoiceHeader PID
    INNER JOIN
        (SELECT intInvoiceId, ysnPosted, ysnPaid, dblInvoiceTotal, dblBaseInvoiceTotal, dblAmountDue, dblBaseAmountDue, dblDiscount, dblBaseDiscount, dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest, dblPayment, dblBasePayment, dtmPostDate, intConcurrencyId, intSourceId, intOriginalInvoiceId, dblProvisionalAmount, dblBaseProvisionalAmount, strTransactionType, dtmDate, ysnExcludeFromPayment
			FROM dbo.tblARInvoice WITH (NOLOCK))  ARI ON PID.intInvoiceId = ARI.intInvoiceId

    UPDATE ARPD
    SET
         ARPD.dblInvoiceTotal		= ARI.dblInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
        ,ARPD.dblBaseInvoiceTotal	= ARI.dblBaseInvoiceTotal * dbo.[fnARGetInvoiceAmountMultiplier](ARI.strTransactionType)
        ,ARPD.dblAmountDue			= (ARI.dblInvoiceTotal + ISNULL(ARPD.dblInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblPayment, @ZeroDecimal) + ISNULL(ARPD.dblDiscount, @ZeroDecimal))
        ,ARPD.dblBaseAmountDue		= (ARI.dblBaseInvoiceTotal + ISNULL(ARPD.dblBaseInterest, @ZeroDecimal))  - (ISNULL(ARPD.dblBasePayment, @ZeroDecimal) + ISNULL(ARPD.dblBaseDiscount, @ZeroDecimal))
    FROM
        #ARPostInvoiceHeader PID
    INNER JOIN
        (SELECT intInvoiceId, dblInvoiceTotal, dblBaseInvoiceTotal, strTransactionType FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
            ON PID.intInvoiceId = ARI.intInvoiceId
    INNER JOIN
        (SELECT intInvoiceId, dblInterest, dblBaseInterest, dblDiscount, dblBaseDiscount, dblAmountDue, dblBaseAmountDue, dblInvoiceTotal, dblBaseInvoiceTotal, dblPayment, dblBasePayment FROM dbo.tblARPaymentDetail WITH (NOLOCK)) ARPD
            ON ARI.intInvoiceId = ARPD.intInvoiceId 
					
	--Update tblHDTicketHoursWorked ysnBilled					
	UPDATE HDTHW						
	SET
		 HDTHW.[ysnBilled] = 1
		,HDTHW.[dtmBilled] = (CASE WHEN HDTHW.[dtmBilled] IS NULL THEN GETDATE() ELSE HDTHW.[dtmBilled] END)
	FROM
		#ARPostInvoiceHeader PID
	INNER JOIN
		(SELECT [intInvoiceId], [dtmBilled], [ysnBilled] FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)) HDTHW
			ON PID.[intInvoiceId] = HDTHW.[intInvoiceId]
						

    DECLARE @TankDeliveryForSync TABLE 
		([intInvoiceId] INT
        ,UNIQUE (intInvoiceId));
								
	INSERT INTO @TankDeliveryForSync
		([intInvoiceId])
	SELECT DISTINCT
		 [intInvoiceId] = PID.[intInvoiceId]
	FROM
		#ARPostInvoiceDetail PID
	INNER JOIN
		(SELECT [intSiteID] FROM dbo.tblTMSite WITH (NOLOCK)) TMS
			ON PID.[intSiteId] = TMS.[intSiteID] 
								
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
	--Prepaids

	--EXEC dbo.[uspARUpdatePrepaymentAndCreditMemo] @intTransactionId, @ysnPost
	--Auto Apply
	--IF @ysnPost = 1
	--BEGIN
	--	DECLARE @tblInvoiceIds Id
	--	INSERT INTO @tblInvoiceIds
	--	SELECT @intTransactionId

	--	EXEC dbo.uspARAutoApplyPrepaids @tblInvoiceIds = @tblInvoiceIds
	--END
	--ELSE
	--BEGIN
	--	DELETE CF 
	--	FROM tblCMUndepositedFund CF
	--	INNER JOIN tblARInvoice I ON CF.intSourceTransactionId = I.intInvoiceId AND CF.strSourceTransactionId = I.strInvoiceNumber
	--	WHERE CF.strSourceSystem = 'AR'
	--	AND I.intInvoiceId = @intTransactionId
	--END

	DECLARE @Ids Id
	INSERT INTO @Ids
	SELECT [intInvoiceId] FROM #ARPostInvoiceHeader

	EXEC dbo.uspARAutoApplyPrepaids @tblInvoiceIds = @Ids

	----UPDATE tblARCustomer.dblARBalance
	--UPDATE CUSTOMER
	--SET dblARBalance = dblARBalance + (CASE WHEN @post = 1 THEN ISNULL(dblTotalInvoice, @ZeroDecimal) ELSE ISNULL(dblTotalInvoice, @ZeroDecimal) * -1 END)
	--FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	--INNER JOIN (SELECT intEntityCustomerId
	--					, dblTotalInvoice = SUM(CASE WHEN strTransactionType IN ('Invoice', 'Debit Memo') THEN dblInvoiceTotal ELSE dblInvoiceTotal * -1 END)
	--			FROM dbo.tblARInvoice WITH (NOLOCK)
	--			WHERE intInvoiceId IN (SELECT intInvoiceId FROM @InvoiceToUpdate)
	--			GROUP BY intEntityCustomerId
	--) INVOICE ON CUSTOMER.intEntityId = INVOICE.intEntityCustomerId

	--UPDATE tblARCustomer.dblARBalance
	UPDATE CUSTOMER
	SET CUSTOMER.dblARBalance = CUSTOMER.dblARBalance + ISNULL(dblTotalInvoice, @ZeroDecimal)
	FROM 
		dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	INNER JOIN 
		(SELECT
			 [intEntityCustomerId] = [intEntityCustomerId]
			,[dblTotalInvoice]     = SUM(CASE WHEN [ysnIsInvoicePositive] = 1 THEN [dblInvoiceTotal] ELSE -[dblInvoiceTotal] END)
		FROM
			#ARPostInvoiceHeader
		GROUP BY
			[intEntityCustomerId]
		) INVOICE
			 ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]

	----Patronage
	--DECLARE	@successfulCount INT
	--	   ,@strTransactionId NVARCHAR(MAX)

	--SET @strTransactionId = CONVERT(NVARCHAR(MAX), @intTransactionId)

	--EXEC [dbo].[uspPATGatherVolumeForPatronage]
	--	 @transactionIds	= @strTransactionId
	--	,@post				= @ysnPost
	--	,@type				= 2
	--	,@successfulCount	= @successfulCount OUTPUT
	--Patronage
	DECLARE @IdsP TABLE([intInvoiceId] INT, [intLoadId] INT, [ysnFromProvisional] BIT, [ysnProvisionalWithGL] BIT)
	INSERT INTO @IdsP([intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL])
	SELECT [intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL] FROM #ARPostInvoiceHeader
	DECLARE	@successfulCountP INT
		,@strId NVARCHAR(MAX)

	SELECT @strId = COALESCE(@strId + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250)) FROM @IdsP

	EXEC [dbo].[uspPATGatherVolumeForPatronage]
		 @transactionIds	= @strId
		,@post				= 1
		,@type				= 2
		,@successfulCount	= @successfulCountP OUTPUT


	DELETE FROM @Invoices
	INSERT INTO @Invoices([intHeaderId]) SELECT [intInvoiceId] FROM @IdsP
    EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @Invoices, 1

	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsP)
	BEGIN
		DECLARE @InvoiceIDP INT
		DECLARE @LoadIDP INT
        DECLARE @FromProvisionalP BIT
        DECLARE @ProvisionalWithGLP BIT
		SELECT TOP 1 @InvoiceIDP = [intInvoiceId], @LoadIDP = [intLoadId], @FromProvisionalP = [ysnFromProvisional], @ProvisionalWithGLP = [ysnProvisionalWithGL] FROM @IdsP ORDER BY [intInvoiceId]
		
        -- Update CT - Sequence Balance
		EXEC dbo.[uspARInvoiceUpdateSequenceBalance] @TransactionId = @InvoiceIDP, @ysnDelete = 0, @UserId = @UserId

		--Committed QUatities
		EXEC dbo.[uspARUpdateCommitted] @InvoiceIDP, 1, @UserId, 1

		--Reserved QUatities
		-- EXEC dbo.[uspARUpdateReservedStock] @intTransactionId, 0, @intUserId, 1, @ysnPost

		--In Transit Outbound Quantities 
		EXEC dbo.[uspARUpdateInTransit] @InvoiceIDP, 1, 0

		--In Transit Direct Quantities
		EXEC dbo.[uspARUpdateInTransitDirect] @InvoiceIDP, 1

		--DECLARE	@EntityCustomerId INT
		--		,@LoadId INT

		--SELECT TOP 1 
		--	@EntityCustomerId	= intEntityCustomerId
		--	,@LoadId			= intLoadId
		--FROM
		--	tblARInvoice WITH (NOLOCK)
		--WHERE
		--	intInvoiceId = @intTransactionId

		----Update LG - Load Shipment
		--EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
		--	@InvoiceId	= @intTransactionId
		--	,@Post		= @ysnPost
		--	,@LoadId	= @LoadId
		--	,@UserId	= @intUserId

		--Update LG - Load Shipment
        IF @FromProvisionalP = 0 OR @ProvisionalWithGLP = 0
		EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost] 
			@InvoiceId	= @InvoiceIDP
			,@Post		= 1
			,@LoadId	= @LoadIDP
			,@UserId	= @UserId

		DELETE FROM @IdsP WHERE [intInvoiceId] = @InvoiceIDP
	END

END


IF @Post = 0
BEGIN
--BEGIN
--	--Reverse Blend for Finished Goods
--	BEGIN TRY
--		WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
--			BEGIN
--				DECLARE @intInvoiceDetailIdToUnblend		INT
			
--				SELECT TOP 1 @intInvoiceDetailIdToUnblend = intInvoiceDetailId FROM @FinishedGoodItems

--				EXEC dbo.uspMFReverseAutoBlend
--					@intSalesOrderDetailId	= NULL,
--					@intInvoiceDetailId		= @intInvoiceDetailIdToUnblend,
--					@intUserId				= @userId 

--				UPDATE tblARInvoiceDetail SET ysnBlended = 0 WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
--				DELETE FROM @FinishedGoodItems WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
--			END
--	END TRY
--	BEGIN CATCH
--		SELECT @ErrorMerssage = ERROR_MESSAGE()
--		GOTO Do_Rollback
--	END CATCH

--	UPDATE ARI
--	SET
--			ARI.ysnPosted					= 0
--		,ARI.ysnPaid					= 0
--		,ARI.dblAmountDue				= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
--												THEN 
--													CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) > 0
--															THEN ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal))
--															ELSE (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)) - ISNULL(ARI.dblProvisionalAmount, @ZeroDecimal)
--													END
--												ELSE 
--													CASE WHEN (ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) = ISNULL(ARI.dblPayment, @ZeroDecimal))
--															THEN ISNULL(ARI.dblPayment, @ZeroDecimal)
--															ELSE ISNULL(ARI.dblInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblPayment, @ZeroDecimal)
--														END
--											END
--		,ARI.dblBaseAmountDue			= CASE WHEN ARI.intSourceId = 2 AND ARI.intOriginalInvoiceId IS NOT NULL
--												THEN 
--													CASE WHEN ARI.strTransactionType = 'Credit Memo' AND ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) > 0
--															THEN ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal))
--															ELSE (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)) - ISNULL(ARI.dblBaseProvisionalAmount, @ZeroDecimal)
--													END
--												ELSE 
--													CASE WHEN (ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) = ISNULL(ARI.dblBasePayment, @ZeroDecimal))
--															THEN ISNULL(ARI.dblBasePayment, @ZeroDecimal)
--															ELSE ISNULL(ARI.dblBaseInvoiceTotal, @ZeroDecimal) - ISNULL(ARI.dblBasePayment, @ZeroDecimal)
--														END
--											END												
--		,ARI.dblDiscount				= @ZeroDecimal
--		,ARI.dblBaseDiscount			= @ZeroDecimal
--		,ARI.dblDiscountAvailable		= ISNULL(ARI.dblDiscountAvailable, @ZeroDecimal)
--		,ARI.dblBaseDiscountAvailable	= ISNULL(ARI.dblBaseDiscountAvailable, @ZeroDecimal)
--		,ARI.dblInterest				= @ZeroDecimal
--		,ARI.dblBaseInterest			= @ZeroDecimal
--		,ARI.dblPayment					= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(dblPayment, @ZeroDecimal) END
--		,ARI.dblBasePayment				= CASE WHEN ARI.strTransactionType = 'Cash' THEN @ZeroDecimal ELSE ISNULL(dblBasePayment, @ZeroDecimal) END
--		,ARI.dtmPostDate				= CAST(ISNULL(ARI.dtmPostDate, ARI.dtmDate) AS DATE)
--		,ARI.ysnExcludeFromPayment		= 0
--		,ARI.intConcurrencyId			= ISNULL(ARI.intConcurrencyId,0) + 1
--	FROM
--		(SELECT intInvoiceId FROM @PostInvoiceData ) PID
--	INNER JOIN
--		(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblBaseAmountDue, dblDiscount, dblBaseDiscount, dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest, dblPayment, dblBasePayment, dtmPostDate, intConcurrencyId, strTransactionType, intSourceId, intOriginalInvoiceId, dblProvisionalAmount, dblBaseProvisionalAmount, dblInvoiceTotal, dblBaseInvoiceTotal, dtmDate, ysnExcludeFromPayment
--			FROM dbo.tblARInvoice WITH (NOLOCK)) ARI ON PID.intInvoiceId = ARI.intInvoiceId 					
--	CROSS APPLY (SELECT COUNT(intPrepaidAndCreditId) PPC FROM tblARPrepaidAndCredit WHERE intInvoiceId = PID.intInvoiceId AND ysnApplied = 1) PPC
--	--Insert Successfully unposted transactions.
--	INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
--	SELECT 
--		@PostSuccessfulMsg
--		,PID.strTransactionType
--		,PID.strInvoiceNumber
--		,@batchIdUsed
--		,PID.intInvoiceId
--	FROM
--		@PostInvoiceData PID					
												
--	--Update tblHDTicketHoursWorked ysnBilled					
--	UPDATE HDTHW						
--	SET
--			HDTHW.ysnBilled = 0
--		,HDTHW.dtmBilled = NULL
--	FROM
--		(SELECT intInvoiceId FROM @PostInvoiceData) PID
--	INNER JOIN
--		(SELECT intInvoiceId, dtmBilled, ysnBilled FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)) HDTHW ON PID.intInvoiceId = HDTHW.intInvoiceId														
--	DELETE PD
--	FROM tblARPaymentDetail PD
--		INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 0
--	WHERE PD.intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @PostInvoiceData)
						
--	BEGIN TRY
--		DECLARE @TankDeliveryForUnSync TABLE (
--				intInvoiceId INT,
--				UNIQUE (intInvoiceId));
								
--		INSERT INTO @TankDeliveryForUnSync					
--		SELECT DISTINCT
--			ARI.intInvoiceId
--		FROM
--			(SELECT intInvoiceId FROM @PostInvoiceData ) PID
--		INNER JOIN 															
--			(SELECT intInvoiceId FROM dbo.tblARInvoice WITH (NOLOCK)) ARI
--				ON PID.intInvoiceId = ARI.intInvoiceId
--		INNER JOIN
--			(SELECT intInvoiceId, intSiteId  FROM dbo.tblARInvoiceDetail WITH (NOLOCK)) ARID
--				ON ARI.intInvoiceId = ARID.intInvoiceId		
--		INNER JOIN
--			(SELECT intSiteID FROM dbo.tblTMSite WITH (NOLOCK)) TMS
--				ON ARID.intSiteId = TMS.intSiteID 						
															
--		WHILE EXISTS(SELECT TOP 1 NULL FROM @TankDeliveryForUnSync ORDER BY intInvoiceId)
--			BEGIN
							
--				DECLARE  @intInvoiceForUnSyncId INT
--						,@ResultLogForUnSync NVARCHAR(MAX)
										
								
--				SELECT TOP 1 @intInvoiceForUnSyncId = intInvoiceId FROM @TankDeliveryForUnSync ORDER BY intInvoiceId

--				EXEC dbo.uspTMUnSyncInvoiceFromDeliveryHistory  @intInvoiceForUnSyncId, @ResultLogForUnSync OUT
												
--				DELETE FROM @TankDeliveryForUnSync WHERE intInvoiceId = @intInvoiceForUnSyncId
																												
--			END 							
								
--		--UPDATE PREPAIDS/CREDIT MEMO FOR CASH REFUND
--		DECLARE @CashRefunds AS TABLE (intInvoiceId INT)

--		INSERT INTO @CashRefunds
--		SELECT intInvoiceId FROM @PostInvoiceData I
--		CROSS APPLY (										
--			SELECT TOP 1 intPrepaymentId
--			FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
--			WHERE intInvoiceId = I.intInvoiceId 
--				AND ysnApplied = 1
--				AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
--		) PREPAIDS
--		WHERE strTransactionType = 'Cash Refund'

--		WHILE EXISTS(SELECT TOP 1 1 FROM @CashRefunds)
--			BEGIN
--				DECLARE @intInvoiceIdCashRefund INT = NULL

--				SELECT TOP 1 @intInvoiceIdCashRefund = intInvoiceId
--				FROM @CashRefunds
							
--				UPDATE I
--				SET dblAmountDue		= dblAmountDue + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--					, dblBaseAmountDue	= dblBaseAmountDue + ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--					, dblPayment			= dblPayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--					, dblBasePayment		= dblBasePayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal)
--					, ysnPaid				= CASE WHEN dblInvoiceTotal = dblPayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
--					, ysnRefundProcessed	= CASE WHEN dblInvoiceTotal = dblPayment - ISNULL(dblAppliedInvoiceAmount, @ZeroDecimal) THEN CAST(1 AS BIT) ELSE CAST(0 AS BIT) END
--				FROM tblARInvoice I
--				INNER JOIN (										
--					SELECT intPrepaymentId			= intPrepaymentId
--							, dblAppliedInvoiceAmount	= ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal)
--					FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
--					WHERE intInvoiceId = @intInvoiceIdCashRefund 
--						AND ysnApplied = 1
--						AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
--				) PREPAIDS ON I.intInvoiceId = PREPAIDS.intPrepaymentId
								
--				DELETE FROM @CashRefunds WHERE intInvoiceId = @intInvoiceIdCashRefund
--			END
																
--	END TRY
--	BEGIN CATCH
--		SELECT @ErrorMerssage = ERROR_MESSAGE()										
--		GOTO Do_Rollback
--	END CATCH	

--END
	--Reverse Blend for Finished Goods
	DECLARE @FinishedGoodItems AS TABLE
		([intInvoiceDetailId] INT
		,[intUserId] INT
		)
	INSERT INTO @FinishedGoodItems
	SELECT DISTINCT
		 [intInvoiceDetailId] = UPD.[intInvoiceDetailId]
		,[intUserId]          = UPD.[intUserId]
	FROM
		#ARPostInvoiceDetail UPD
	INNER JOIN
		(SELECT intInvoiceDetailId FROM tblMFWorkOrder) MFWO
			ON UPD.[intInvoiceDetailId] = MFWO.[intInvoiceDetailId]
	WHERE
		UPD.[ysnBlended] = 1

	WHILE EXISTS (SELECT NULL FROM @FinishedGoodItems)
		BEGIN
			DECLARE @intInvoiceDetailIdToUnblend INT
					,@intUserIdToUnblend INT
			
			SELECT TOP 1 @intInvoiceDetailIdToUnblend = intInvoiceDetailId, @intUserIdToUnblend = [intUserId] FROM @FinishedGoodItems

			EXEC dbo.uspMFReverseAutoBlend
				@intSalesOrderDetailId	= NULL,
				@intInvoiceDetailId		= @intInvoiceDetailIdToUnblend,
				@intUserId				= @intUserIdToUnblend 

			UPDATE tblARInvoiceDetail SET ysnBlended = 0 WHERE intInvoiceDetailId = @intInvoiceDetailIdToUnblend
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
	FROM
		#ARPostInvoiceHeader PID
	INNER JOIN
		(SELECT intInvoiceId, ysnPosted, ysnPaid, dblAmountDue, dblBaseAmountDue, dblDiscount, dblBaseDiscount, dblDiscountAvailable, dblBaseDiscountAvailable, dblInterest, dblBaseInterest, dblPayment, dblBasePayment, dtmPostDate, intConcurrencyId, strTransactionType, intSourceId, intOriginalInvoiceId, dblProvisionalAmount, dblBaseProvisionalAmount, dblInvoiceTotal, dblBaseInvoiceTotal, dtmDate, ysnExcludeFromPayment
			FROM dbo.tblARInvoice WITH (NOLOCK)) ARI ON PID.intInvoiceId = ARI.intInvoiceId 					
	CROSS APPLY (SELECT COUNT(intPrepaidAndCreditId) PPC FROM tblARPrepaidAndCredit WHERE intInvoiceId = PID.intInvoiceId AND ysnApplied = 1) PPC
		
												
	--Update tblHDTicketHoursWorked ysnBilled					
	UPDATE HDTHW						
	SET
		HDTHW.ysnBilled = 0
		,HDTHW.dtmBilled = NULL
	FROM
		#ARPostInvoiceHeader PID
	INNER JOIN
		(SELECT intInvoiceId, dtmBilled, ysnBilled FROM dbo.tblHDTicketHoursWorked WITH (NOLOCK)) HDTHW ON PID.intInvoiceId = HDTHW.intInvoiceId	
															
	DELETE PD
	FROM tblARPaymentDetail PD
		INNER JOIN tblARPayment P ON P.intPaymentId = PD.intPaymentId AND P.ysnPosted = 0
	WHERE PD.intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM #ARPostInvoiceHeader WHERE [ysnPost] = 0)
						
	DECLARE @TankDeliveryForUnSync TABLE 
		([intInvoiceId] INT
        ,UNIQUE (intInvoiceId));
								
	INSERT INTO @TankDeliveryForUnSync
	SELECT DISTINCT
		 [intInvoiceId] = PID.[intInvoiceId]
	FROM
		#ARPostInvoiceDetail PID
	INNER JOIN
		(SELECT [intSiteID] FROM dbo.tblTMSite WITH (NOLOCK)) TMS
			ON PID.[intSiteId] = TMS.[intSiteID]				
															
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
	SELECT intInvoiceId FROM #ARPostInvoiceHeader I
	CROSS APPLY (										
		SELECT TOP 1 intPrepaymentId
		FROM dbo.tblARPrepaidAndCredit WITH (NOLOCK)
		WHERE intInvoiceId = I.intInvoiceId 
			AND ysnApplied = 1
			AND ISNULL(dblAppliedInvoiceDetailAmount, @ZeroDecimal) > @ZeroDecimal
	) PREPAIDS
	WHERE
		I.strTransactionType = 'Cash Refund'


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

	--IF @ysnPost = 1
	--BEGIN
	--	DECLARE @tblInvoiceIds Id
	--	INSERT INTO @tblInvoiceIds
	--	SELECT @intTransactionId

	--	EXEC dbo.uspARAutoApplyPrepaids @tblInvoiceIds = @tblInvoiceIds
	--END
	--ELSE
	--BEGIN
	--	DELETE CF 
	--	FROM tblCMUndepositedFund CF
	--	INNER JOIN tblARInvoice I ON CF.intSourceTransactionId = I.intInvoiceId AND CF.strSourceTransactionId = I.strInvoiceNumber
	--	WHERE CF.strSourceSystem = 'AR'
	--	AND I.intInvoiceId = @intTransactionId
	--END
	DELETE CF 
	FROM
		tblCMUndepositedFund CF
	INNER JOIN
		#ARPostInvoiceHeader I
			ON CF.intSourceTransactionId = I.intInvoiceId 
			AND CF.strSourceTransactionId = I.strInvoiceNumber
	WHERE
		CF.strSourceSystem = 'AR'

	----UPDATE tblARCustomer.dblARBalance
	--UPDATE CUSTOMER
	--SET dblARBalance = dblARBalance + (CASE WHEN @post = 1 THEN ISNULL(dblTotalInvoice, @ZeroDecimal) ELSE ISNULL(dblTotalInvoice, @ZeroDecimal) * -1 END)
	--FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	--INNER JOIN (SELECT intEntityCustomerId
	--					, dblTotalInvoice = SUM(CASE WHEN strTransactionType IN ('Invoice', 'Debit Memo') THEN dblInvoiceTotal ELSE dblInvoiceTotal * -1 END)
	--			FROM dbo.tblARInvoice WITH (NOLOCK)
	--			WHERE intInvoiceId IN (SELECT intInvoiceId FROM @InvoiceToUpdate)
	--			GROUP BY intEntityCustomerId
	--) INVOICE ON CUSTOMER.intEntityId = INVOICE.intEntityCustomerId

	--UPDATE tblARCustomer.dblARBalance
	UPDATE CUSTOMER
	SET CUSTOMER.dblARBalance = CUSTOMER.dblARBalance - ISNULL(dblTotalInvoice, @ZeroDecimal)
	FROM 
		dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
	INNER JOIN 
		(SELECT
			 [intEntityCustomerId] = [intEntityCustomerId]
			,[dblTotalInvoice]     = SUM(CASE WHEN [ysnIsInvoicePositive] = 1 THEN [dblInvoiceTotal] ELSE -[dblInvoiceTotal] END)
		FROM
			#ARPostInvoiceHeader
		GROUP BY
			[intEntityCustomerId]
		) INVOICE
			 ON CUSTOMER.intEntityId = INVOICE.[intEntityCustomerId]

	----Patronage
	--DECLARE	@successfulCount INT
	--	   ,@strTransactionId NVARCHAR(MAX)

	--SET @strTransactionId = CONVERT(NVARCHAR(MAX), @intTransactionId)

	--EXEC [dbo].[uspPATGatherVolumeForPatronage]
	--	 @transactionIds	= @strTransactionId
	--	,@post				= @ysnPost
	--	,@type				= 2
	--	,@successfulCount	= @successfulCount OUTPUT
	--Patronage
	DECLARE @IdsU TABLE([intInvoiceId] INT, [intLoadId] INT, [ysnFromProvisional] BIT, [ysnProvisionalWithGL] BIT)
	INSERT INTO @IdsU([intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL])
	SELECT [intInvoiceId], [intLoadId], [ysnFromProvisional], [ysnProvisionalWithGL] FROM #ARPostInvoiceHeader
	DECLARE	@successfulCountU INT
		,@strIdU NVARCHAR(MAX)

	SELECT @strIdU = COALESCE(@strIdU + ',' ,'') + CAST([intInvoiceId] AS NVARCHAR(250)) FROM @IdsU

	EXEC [dbo].[uspPATGatherVolumeForPatronage]
		 @transactionIds	= @strIdU
		,@post				= 0
		,@type				= 2
		,@successfulCount	= @successfulCountU OUTPUT

	DELETE FROM @Invoices
	INSERT INTO @Invoices([intHeaderId]) SELECT [intInvoiceId] FROM @IdsU
    EXEC dbo.[uspARUpdateInvoiceTransactionHistory] @Invoices, 0

	WHILE EXISTS(SELECT TOP 1 NULL FROM @IdsU)
	BEGIN
		DECLARE @InvoiceIDU INT
		DECLARE @LoadIDU INT
		DECLARE @FromProvisionalU BIT
		DECLARE @ProvisionalWithGLU BIT
		SELECT TOP 1 @InvoiceIDU = [intInvoiceId], @LoadIDU = [intLoadId], @FromProvisionalU = [ysnFromProvisional], @ProvisionalWithGLU = [ysnProvisionalWithGL] FROM @IdsU ORDER BY [intInvoiceId]
		
        -- Update CT - Sequence Balance
		EXEC dbo.[uspARInvoiceUpdateSequenceBalance] @TransactionId = @InvoiceIDP, @ysnDelete = 1, @UserId = @UserId
		
		--Committed QUatities
		EXEC dbo.[uspARUpdateCommitted] @InvoiceIDU, 1, @UserId, 1

		--Reserved QUatities
		-- EXEC dbo.[uspARUpdateReservedStock] @intTransactionId, 0, @intUserId, 1, @ysnPost

		--In Transit Outbound Quantities 
		EXEC dbo.[uspARUpdateInTransit] @InvoiceIDU, 0, 0

		--In Transit Direct Quantities
		EXEC dbo.[uspARUpdateInTransitDirect] @InvoiceIDU, 0

		--DECLARE	@EntityCustomerId INT
		--		,@LoadId INT

		--SELECT TOP 1 
		--	@EntityCustomerId	= intEntityCustomerId
		--	,@LoadId			= intLoadId
		--FROM
		--	tblARInvoice WITH (NOLOCK)
		--WHERE
		--	intInvoiceId = @intTransactionId

		----Update LG - Load Shipment
		--EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
		--	@InvoiceId	= @intTransactionId
		--	,@Post		= @ysnPost
		--	,@LoadId	= @LoadId
		--	,@UserId	= @intUserId

		--Update LG - Load Shipment
        IF @FromProvisionalU = 0 OR @ProvisionalWithGLU = 0
		EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
			@InvoiceId	= @InvoiceIDU
			,@Post		= 0
			,@LoadId	= @LoadIDU
			,@UserId	= @UserId

		DELETE FROM @IdsU WHERE [intInvoiceId] = @InvoiceIDU
	END
																	
END

----UPDATE tblARCustomer.dtmCreditLimitReached
--UPDATE CUSTOMER
--SET dtmCreditLimitReached =  CASE WHEN dtmCreditLimitReached IS NULL THEN CASE WHEN CUSTOMER.dblARBalance >= CUSTOMER.dblCreditLimit THEN INVOICE.dtmPostDate ELSE NULL END ELSE dtmCreditLimitReached END
--FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
--CROSS APPLY (
--	SELECT TOP 1 I.dtmPostDate
--	FROM dbo.tblARInvoice I
--	INNER JOIN @InvoiceToUpdate U ON I.intInvoiceId = U.intInvoiceId
--	WHERE I.intEntityCustomerId = CUSTOMER.intEntityId
--	ORDER BY I.dtmPostDate DESC
--) INVOICE
--WHERE ISNULL(CUSTOMER.dblCreditLimit, @ZeroDecimal) > @ZeroDecimal
--UPDATE tblARCustomer.dtmCreditLimitReached
UPDATE CUSTOMER
SET [dtmCreditLimitReached] =  CASE WHEN ISNULL(CUSTOMER.[dblARBalance], 0) >= ISNULL(CUSTOMER.[dblCreditLimit], 0) THEN ISNULL(CUSTOMER.[dtmCreditLimitReached], INVOICE.[dtmPostDate]) ELSE NULL END
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
CROSS APPLY (
	SELECT TOP 1 I.[dtmPostDate]
	FROM
		#ARPostInvoiceHeader I
	WHERE 
		I.[intEntityCustomerId] = CUSTOMER.[intEntityId]
	ORDER BY
		I.[dtmPostDate] DESC
) INVOICE
WHERE ISNULL(CUSTOMER.[dblCreditLimit], @ZeroDecimal) > @ZeroDecimal

----UPDATE BatchIds Used
--UPDATE tblARInvoice 
--SET strBatchId		= CASE WHEN @post = 1 THEN @batchIdUsed ELSE NULL END
--	, dtmBatchDate	= CASE WHEN @post = 1 THEN @PostDate ELSE NULL END
--	, intPostedById	= CASE WHEN @post = 1 THEN @userId ELSE NULL END
--WHERE intInvoiceId IN (SELECT DISTINCT intInvoiceId FROM @InvoiceToUpdate)
--UPDATE BatchIds Used
UPDATE INV
SET  INV.[strBatchId]	 = CASE WHEN PID.[ysnPost] = 1 THEN PID.[strBatchId] ELSE NULL END
	,INV.[dtmBatchDate]  = CASE WHEN PID.[ysnPost] = 1 THEN PID.[dtmPostDate] ELSE NULL END
	,INV.[intPostedById] = CASE WHEN PID.[ysnPost] = 1 THEN PID.[intUserId] ELSE NULL END
FROM
	tblARInvoice INV
INNER JOIN
	#ARPostInvoiceHeader PID
		ON INV.[intInvoiceId] = PID.[intInvoiceId]

-- Get the details from the invoice 
--BEGIN 
--DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
--INSERT INTO @ItemsFromInvoice 	
--EXEC dbo.[uspARGetItemsFromInvoice] @intInvoiceId = @intTransactionId, @forContract = 1

---- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
--UPDATE @ItemsFromInvoice SET [dblQtyShipped] = [dblQtyShipped] * CASE WHEN @ysnPost = 1 THEN 1 ELSE -1 END 
--END

----Contracts 
--EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @intUserId
DELETE FROM @ItemsFromInvoice
INSERT INTO @ItemsFromInvoice
	([intInvoiceId]
	,[strInvoiceNumber]
	,[intEntityCustomerId]
	,[dtmDate]
	,[intCurrencyId]
	,[intCompanyLocationId]
	,[intDistributionHeaderId]
	-- Detail 
	,[intInvoiceDetailId]
	,[intItemId]
	,[strItemNo]
	,[strItemDescription]
	--,[intSCInvoiceId]
	--,[strSCInvoiceNumber]
	,[intItemUOMId]
	--,[dblQtyOrdered]
	,[dblQtyShipped]
	,[dblDiscount]
	,[dblPrice]
	--,[dblTotalTax]
	,[dblTotal]
	,[intServiceChargeAccountId]
	,[intInventoryShipmentItemId]
	,[intSalesOrderDetailId]
	,[intSiteId]
	--,[strBillingBy]
	--,[dblPercentFull]
	--,[dblNewMeterReading]
	--,[dblPreviousMeterReading]
	--,[dblConversionFactor]
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
	--,[intTicketHoursWorkedId]
	,[intCustomerStorageId]
	--,[intSiteDetailId]
	,[intLoadDetailId]
	,[ysnLeaseBilling])
SELECT
	-- Header
	 [intInvoiceId]					= ID.[intInvoiceId]
	,[strInvoiceNumber]				= ID.[strInvoiceNumber]
	,[intEntityCustomerId]			= ID.[intEntityCustomerId]
	,[dtmDate]						= ID.[dtmDate]
	,[intCurrencyId]				= ID.[intCurrencyId]
	,[intCompanyLocationId]			= ID.[intCompanyLocationId]
	,[intDistributionHeaderId]		= ID.[intDistributionHeaderId]
	-- Detail 
	,[intInvoiceDetailId]			= ID.[intInvoiceDetailId]			
	,[intItemId]					= ID.[intItemId]		
	,[strItemNo]					= ID.[strItemNo]
	,[strItemDescription]			= ID.[strItemDescription]			
	--,[intSCInvoiceId]				= ID.[intSCInvoiceId]				
	--,[strSCInvoiceNumber]			= ID.[strSCInvoiceNumber]			
	,[intItemUOMId]					= ID.[intItemUOMId]					
	--,[dblQtyOrdered]				= ID.[dblQtyOrdered]				
	,[dblQtyShipped]				= ID.[dblQtyShipped] * (CASE WHEN ID.[ysnPost] = 0 THEN -@OneDecimal ELSE @OneDecimal END) * (CASE WHEN ID.[ysnIsInvoicePositive] = 0 THEN -@OneDecimal ELSE @OneDecimal END)
	,[dblDiscount]					= ID.[dblDiscount]					
	,[dblPrice]						= ID.[dblPrice]						
	--,[dblTotalTax]					= ID.[dblTotalTax]					
	,[dblTotal]						= ID.[dblTotal]						
	,[intServiceChargeAccountId]	= ID.[intServiceChargeAccountId]	
	,[intInventoryShipmentItemId]	= ID.[intInventoryShipmentItemId]	
	,[intSalesOrderDetailId]		= ID.[intSalesOrderDetailId]
	,[intSiteId]					= ID.[intSiteId]					
	--,[strBillingBy]                 = ID.[strBillingBy]                 
	--,[dblPercentFull]				= ID.[dblPercentFull]				
	--,[dblNewMeterReading]			= ID.[dblNewMeterReading]			
	--,[dblPreviousMeterReading]		= ID.[dblPreviousMeterReading]		
	--,[dblConversionFactor]			= ID.[dblConversionFactor]			
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
	--,[intTicketHoursWorkedId]		= ID.[intTicketHoursWorkedId]
	,[intCustomerStorageId]			= ID.[intCustomerStorageId]
	--,[intSiteDetailId]				= ID.[intSiteDetailId]
	,[intLoadDetailId]				= ID.[intLoadDetailId]
	,[ysnLeaseBilling]				= ID.[ysnLeaseBilling]				
FROM
	#ARPostInvoiceDetail ID
JOIN
	tblCTContractDetail CD
		ON ID.[intContractDetailId] = CD.[intContractDetailId]	
LEFT JOIN
	tblCTContractHeader CH
		ON CD.intContractHeaderId = CH.intContractHeaderId
WHERE
	--ID.[intInventoryShipmentItemId] IS NULL AND
	ID.[intInventoryShipmentChargeId] IS NULL
	AND	(ID.strTransactionType <> 'Credit Memo' OR (ID.[ysnIsInvoicePositive] = 0 AND ID.[intInventoryShipmentItemId] IS NOT NULL))
	AND ID.[strType] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')
    AND ISNULL(ID.[strItemType], '') <> 'Other Charge'

EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @UserId

--UPDATE ARID
--SET
--	ARID.dblContractBalance = CTCD.dblBalance
--FROM
--	(SELECT intInvoiceId, dblContractBalance, intContractDetailId FROM dbo.tblARInvoiceDetail WITH (NOLOCK) ) ARID
--INNER JOIN
--	(SELECT intContractDetailId, dblBalance FROM dbo.tblCTContractDetail WITH (NOLOCK))  CTCD
--	ON ARID.intContractDetailId = CTCD.intContractDetailId
--WHERE 
--	ARID.intInvoiceId = @intTransactionId
--	AND ARID.dblContractBalance <> CTCD.dblBalance
UPDATE ARID
SET
	ARID.dblContractBalance = CTCD.dblBalance
FROM
	(SELECT intInvoiceDetailId, dblContractBalance, intContractDetailId FROM dbo.tblARInvoiceDetail WITH (NOLOCK) ) ARID
INNER JOIN
	#ARPostInvoiceDetail PID
		ON ARID.[intInvoiceDetailId] = PID.[intInvoiceDetailId]
INNER JOIN
	(SELECT intContractDetailId, dblBalance FROM dbo.tblCTContractDetail WITH (NOLOCK))  CTCD
		ON ARID.intContractDetailId = CTCD.intContractDetailId
WHERE 
	ARID.dblContractBalance <> CTCD.dblBalance
	AND PID.[strType] NOT IN ('Card Fueling Transaction','CF Tran','CF Invoice')

DELETE A
FROM
	tblARPrepaidAndCredit A
INNER JOIN
	#ARPostInvoiceHeader B 
		ON A.intInvoiceId = B.intInvoiceId 
WHERE ysnApplied = 0

--Insert Successfully unposted transactions.
IF @IntegrationLogId IS NULL
	INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
	SELECT 
		  CASE WHEN [ysnPost] = 1 THEN 'Transaction successfully posted.'  ELSE 'Transaction successfully unposted.' END
		,[strTransactionType]
		,[strInvoiceNumber]
		,[strBatchId]
		,[intInvoiceId]
	FROM
		#ARPostInvoiceHeader


----Audit Log          
--EXEC dbo.uspSMAuditLog 
--	 @keyValue			= @intTransactionId					-- Primary Key Value of the Invoice. 
--	,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
--	,@entityId			= @UserEntityID						-- Entity Id.
--	,@actionType		= @actionType						-- Action Type
--	,@changeDescription	= ''								-- Description
--	,@fromValue			= ''								-- Previous Value
--	,@toValue			= ''								-- New Value
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
FROM
	#ARPostInvoiceHeader

EXEC [dbo].[uspSMInsertAuditLogs] @LogEntries = @InvoiceLog


--DECLARE @UserEntityID INT
--		,@actionType AS NVARCHAR(50)
--		,@ForDelete BIT = 0
--		,@intTransactionId INT
--		,@intUserId INT
--		,@ysnPost BIT
----THIS IS A HICCUP		
--SET @intTransactionId = @TransactionId
--SET @intUserId = @userId
--SET @ysnPost = @post
--SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WITH (NOLOCK) WHERE intEntityId = @intUserId), @intUserId) 
--SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
--SELECT @ForDelete = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END
  
  
--SET QUOTED_IDENTIFIER OFF  
--SET ANSI_NULLS ON  
--SET NOCOUNT ON  
--SET XACT_ABORT ON  
--SET ANSI_WARNINGS OFF


--DECLARE @UserEntityID INT
--		,@actionType AS NVARCHAR(50)
--		,@ForDelete BIT = 0
--		,@intTransactionId INT
--		,@intUserId INT
--		,@ysnPost BIT
----THIS IS A HICCUP		
--SET @intTransactionId = @TransactionId
--SET @intUserId = @userId
--SET @ysnPost = @post
--SET @UserEntityID = ISNULL((SELECT intEntityId FROM tblSMUserSecurity WITH (NOLOCK) WHERE intEntityId = @intUserId), @intUserId) 
--SELECT @actionType = CASE WHEN @ysnPost = 1 THEN 'Posted'  ELSE 'Unposted' END 
--SELECT @ForDelete = CASE WHEN @ysnPost = 1 THEN 0 ELSE 1 END

---- Get the details from the invoice 
--BEGIN 
--	DECLARE @ItemsFromInvoice AS dbo.[InvoiceItemTableType]
--	INSERT INTO @ItemsFromInvoice 	
--	EXEC dbo.[uspARGetItemsFromInvoice] @intInvoiceId = @intTransactionId, @forContract = 1

--	-- Change quantity to negative if doing a post. Otherwise, it should be the same value if doing an unpost. 
--	UPDATE @ItemsFromInvoice SET [dblQtyShipped] = [dblQtyShipped] * CASE WHEN @ysnPost = 1 THEN 1 ELSE -1 END 
--END

----Contracts 
--EXEC dbo.[uspCTInvoicePosted] @ItemsFromInvoice, @intUserId

----Prepaids

----EXEC dbo.[uspARUpdatePrepaymentAndCreditMemo] @intTransactionId, @ysnPost
----Auto Apply
--IF @ysnPost = 1
--	BEGIN
--		DECLARE @tblInvoiceIds Id
--		INSERT INTO @tblInvoiceIds
--		SELECT @intTransactionId

--		EXEC dbo.uspARAutoApplyPrepaids @tblInvoiceIds = @tblInvoiceIds
--	END
--ELSE
--	BEGIN
--		DELETE CF 
--		FROM tblCMUndepositedFund CF
--		INNER JOIN tblARInvoice I ON CF.intSourceTransactionId = I.intInvoiceId AND CF.strSourceTransactionId = I.strInvoiceNumber
--		WHERE CF.strSourceSystem = 'AR'
--		AND I.intInvoiceId = @intTransactionId
--	END

--UPDATE ARID
--SET
--	ARID.dblContractBalance = CTCD.dblBalance
--FROM
--	(SELECT intInvoiceId, dblContractBalance, intContractDetailId FROM dbo.tblARInvoiceDetail WITH (NOLOCK) ) ARID
--INNER JOIN
--	(SELECT intContractDetailId, dblBalance FROM dbo.tblCTContractDetail WITH (NOLOCK))  CTCD
--	ON ARID.intContractDetailId = CTCD.intContractDetailId
--WHERE 
--	ARID.intInvoiceId = @intTransactionId
--	AND ARID.dblContractBalance <> CTCD.dblBalance

----Committed QUatities
--EXEC dbo.[uspARUpdateCommitted] @intTransactionId, @ysnPost, @intUserId, 1

----Reserved QUatities
---- EXEC dbo.[uspARUpdateReservedStock] @intTransactionId, 0, @intUserId, 1, @ysnPost

----In Transit Outbound Quantities 
--EXEC dbo.[uspARUpdateInTransit] @intTransactionId, @ysnPost, 0

----In Transit Direct Quantities
--EXEC dbo.[uspARUpdateInTransitDirect] @intTransactionId, @ysnPost

--DECLARE	@EntityCustomerId INT
--		,@LoadId INT

--SELECT TOP 1 
--	@EntityCustomerId	= intEntityCustomerId
--	,@LoadId			= intLoadId
--FROM
--	tblARInvoice WITH (NOLOCK)
--WHERE
--	intInvoiceId = @intTransactionId

----Update LG - Load Shipment
--EXEC dbo.[uspLGUpdateLoadShipmentOnInvoicePost]
--	@InvoiceId	= @intTransactionId
--	,@Post		= @ysnPost
--	,@LoadId	= @LoadId
--	,@UserId	= @intUserId

----Patronage
--DECLARE	@successfulCount INT
--	   ,@strTransactionId NVARCHAR(MAX)

--SET @strTransactionId = CONVERT(NVARCHAR(MAX), @intTransactionId)

--EXEC [dbo].[uspPATGatherVolumeForPatronage]
--	 @transactionIds	= @strTransactionId
--	,@post				= @ysnPost
--	,@type				= 2
--	,@successfulCount	= @successfulCount OUTPUT

----Audit Log          
--EXEC dbo.uspSMAuditLog 
--	 @keyValue			= @intTransactionId					-- Primary Key Value of the Invoice. 
--	,@screenName		= 'AccountsReceivable.view.Invoice'	-- Screen Namespace
--	,@entityId			= @UserEntityID						-- Entity Id.
--	,@actionType		= @actionType						-- Action Type
--	,@changeDescription	= ''								-- Description
--	,@fromValue			= ''								-- Previous Value
--	,@toValue			= ''								-- New Value