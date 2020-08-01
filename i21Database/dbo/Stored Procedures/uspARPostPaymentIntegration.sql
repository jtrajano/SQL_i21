CREATE PROCEDURE [dbo].[uspARPostPaymentIntegration]
	 @Post                  BIT
    ,@PostDate              DATE
    ,@BatchId               NVARCHAR(40)
	,@UserId                INT
	,@IntegrationLogId      INT = NULL
AS
BEGIN

SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET ANSI_WARNINGS OFF  

DECLARE @ZeroDecimal DECIMAL(18,6)
SET @ZeroDecimal = 0.000000
DECLARE @ZeroBit BIT
SET @ZeroBit = CAST(0 AS BIT)
DECLARE @OneBit BIT
SET @OneBit = CAST(1 AS BIT)

DECLARE @PaymentIds AS Id
DELETE FROM @PaymentIds
INSERT INTO @PaymentIds
SELECT DISTINCT [intTransactionId] FROM #ARPostPaymentHeader WHERE [intTransactionId] IS NOT NULL

DECLARE @NonZeroPaymentIds AS Id
DELETE FROM @NonZeroPaymentIds
INSERT INTO @NonZeroPaymentIds
SELECT DISTINCT
    [intId] 
FROM
    @PaymentIds
WHERE
    [intId] NOT IN (SELECT [intTransactionId] FROM #ARPostZeroPayment)

IF ISNULL(@IntegrationLogId,0) <> 0
BEGIN
    UPDATE ILD
    SET
        ILD.[ysnPosted]               = CASE WHEN ILD.[ysnPost] = 1 THEN 1 ELSE ILD.[ysnPosted] END
        ,ILD.[ysnUnPosted]            = CASE WHEN ILD.[ysnPost] = 1 THEN ILD.[ysnUnPosted] ELSE 1 END
        ,ILD.[strPostingMessage]      = CASE WHEN ILD.[ysnPost] = 1 THEN 'Transaction successfully posted.' ELSE 'Transaction successfully unposted.' END
        ,ILD.[strBatchId]             = @BatchId
        ,ILD.[strPostedTransactionId] = PID.[strTransactionId] 
    FROM
        tblARPaymentIntegrationLogDetail ILD WITH (NOLOCK)
    INNER JOIN
        #ARPostPaymentHeader PID
            ON ILD.[intPaymentId] = PID.[intTransactionId]
    WHERE
        ILD.[intIntegrationLogId] = @IntegrationLogId
        AND ILD.[ysnPost] IS NOT NULL
        AND ILD.[ysnHeader] = 1
END

IF @Post = 0
BEGIN

	UPDATE A
	SET
		A.intCurrentStatus = 5
	FROM
		tblARPayment A
	INNER JOIN
		@PaymentIds P
			ON A.[intPaymentId] = P.[intId] 

    UPDATE 
        tblARInvoice
    SET 
         tblARInvoice.[dblPayment]        =   ISNULL(tblARInvoice.[dblPayment], @ZeroDecimal) - P.[dblPayment]  
        ,tblARInvoice.[dblBasePayment]    =  ISNULL(tblARInvoice.[dblBasePayment], @ZeroDecimal) - P.[dblBasePayment] 
        ,tblARInvoice.[dblDiscount]       = ISNULL(tblARInvoice.[dblDiscount], @ZeroDecimal) - P.[dblDiscount]			
        ,tblARInvoice.[dblBaseDiscount]	= ISNULL(tblARInvoice.[dblBaseDiscount], @ZeroDecimal) - P.[dblBaseDiscount]			
        ,tblARInvoice.[dblInterest]       = ISNULL(tblARInvoice.[dblInterest], @ZeroDecimal) - P.[dblInterest]				
        ,tblARInvoice.[dblBaseInterest]   = ISNULL(tblARInvoice.[dblBaseInterest], @ZeroDecimal) - P.[dblBaseInterest]				
    FROM
        (
        SELECT 
             [dblPayment]      = SUM((A.[dblPayment] + A.[dblWriteOffAmount]) * [dbo].[fnARGetInvoiceAmountMultiplier](C.[strTransactionType])) 
            ,[dblBasePayment]  = SUM((A.[dblBasePayment] + A.[dblBaseWriteOffAmount]) * [dbo].[fnARGetInvoiceAmountMultiplier](C.[strTransactionType])) 
            ,[dblDiscount]     = SUM(A.[dblDiscount]) 
            ,[dblBaseDiscount] = SUM(A.[dblBaseDiscount]) 
            ,[dblInterest]     = SUM(A.[dblInterest]) 						
            ,[dblBaseInterest] = SUM(A.[dblBaseInterest]) 						
            ,[intInvoiceId]    = A.[intInvoiceId] 
        FROM
            tblARPaymentDetail A
        INNER JOIN
            tblARPayment B
                ON A.intPaymentId = B.intPaymentId
        INNER JOIN
            @PaymentIds P
                ON B.[intPaymentId] = P.[intId] 					
        INNER JOIN
            tblARInvoice C
                ON A.intInvoiceId = C.intInvoiceId
        WHERE
            ISNULL(B.[ysnInvoicePrepayment],0) = 0	
        GROUP BY
            A.intInvoiceId			
        ) P
    WHERE
        tblARInvoice.intInvoiceId = P.intInvoiceId

    UPDATE 
        tblARInvoice
    SET 
         tblARInvoice.dblAmountDue      = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
                                                THEN 
                                                    CASE C.strTransactionType 
														WHEN 'Credit Memo'
															THEN ISNULL(C.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal)))
														WHEN 'Invoice'
															THEN (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal)))
																- ISNULL((SELECT dblPayment FROM tblARInvoice WHERE intInvoiceId = C.intOriginalInvoiceId), @ZeroDecimal)
															ELSE (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))) - ISNULL(C.dblProvisionalAmount, @ZeroDecimal)
                                                    END
                                                ELSE ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))
                                          END				
        ,tblARInvoice.dblBaseAmountDue  = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
                                                THEN 
                                                    CASE C.strTransactionType 
														WHEN 'Credit Memo'
															THEN ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal)))
														WHEN 'Invoice'
															THEN (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal)))
																- ISNULL((SELECT dblBasePayment FROM tblARInvoice WHERE intInvoiceId = C.intOriginalInvoiceId), @ZeroDecimal)
															ELSE (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))) - ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal)
                                                    END
                                                ELSE ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))
                                          END
    FROM tblARPayment A
    INNER JOIN @PaymentIds P ON A.[intPaymentId] = P.[intId] 
    INNER JOIN tblARPaymentDetail B ON A.intPaymentId = B.intPaymentId
    INNER JOIN tblARInvoice C ON B.intInvoiceId = C.intInvoiceId
    WHERE ISNULL(A.[ysnInvoicePrepayment],0) = 0

			-- UPDATE tblARPaymentDetail
			-- SET dblPayment = 0,
			-- 	dblBasePayment = 0,
			-- 	dblBaseAmountDue = 	dblBaseInvoiceTotal + ((ISNULL(dblBaseAmountDue, 0.00) + ISNULL(dblBaseInterest,0.00)) - ISNULL(dblBaseDiscount,0.00)),
			-- 	dblAmountDue = 	dblInvoiceTotal + ((ISNULL(dblAmountDue, 0.00) + ISNULL(dblInterest,0.00)) - ISNULL(dblDiscount,0.00))
			-- WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData)
			
			-- UPDATE ARP
			-- SET ARP.dblAmountPaid = @ZeroDecimal
			--   , ARP.dblBaseAmountPaid = @ZeroDecimal
			--   , ARP.dblUnappliedAmount = APD.dblPayment
			--   , ARP.dblBaseUnappliedAmount = APD.dblBasePayment
			-- FROM tblARPayment ARP
			-- INNER JOIN (SELECT APD.intPaymentId, SUM(APD.dblPayment) dblPayment, SUM(APD.dblBasePayment) dblBasePayment FROM tblARPaymentDetail APD WHERE intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData) GROUP BY APD.intPaymentId ) APD
			-- 	ON ARP.intPaymentId = APD.intPaymentId
			-- WHERE APD.intPaymentId IN(SELECT [intTransactionId] FROM @ARReceivablePostData)

    UPDATE
        tblGLDetail
    SET
        tblGLDetail.ysnIsUnposted = 1
    FROM
        tblARPayment A
    INNER JOIN
        @PaymentIds P
            ON A.[intPaymentId] = P.[intId] 
    INNER JOIN
        tblGLDetail B
            ON A.intPaymentId = B.intTransactionId
			AND A.[strRecordNumber] = B.[strTransactionId]
		  
     ---- Delete zero payment temporarily
     --DELETE FROM A
     --FROM @ARReceivablePostData A
     --WHERE EXISTS(SELECT * FROM @ZeroPayment B WHERE A.[intTransactionId] = B.[intTransactionId])						
					
     -- Creating the temp table:
    DECLARE @isSuccessful BIT
    CREATE TABLE #tmpCMBankTransaction
        (strTransactionId NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL
        ,UNIQUE (strTransactionId))

    INSERT INTO #tmpCMBankTransaction
    SELECT DISTINCT
        strRecordNumber
    FROM
        tblARPayment A
    INNER JOIN
        @NonZeroPaymentIds P
            ON A.[intPaymentId] = P.[intId]


    -- Calling the stored procedure
    DECLARE @ReverseDate AS DATETIME
    SET @ReverseDate = @PostDate
    EXEC uspCMBankTransactionReversal @UserId, @ReverseDate, @isSuccessful OUTPUT
	
			
    --update payment record based on record from tblCMBankTransaction
    UPDATE tblARPayment
    SET
        strPaymentInfo     = CASE WHEN B.dtmCheckPrinted IS NOT NULL AND ISNULL(A.strPaymentInfo,'') <> '' THEN B.strReferenceNo ELSE A.strPaymentInfo END
    FROM
        tblARPayment A 
    INNER JOIN
        @NonZeroPaymentIds P
            ON A.[intPaymentId] = P.[intId]
    INNER JOIN
        tblCMBankTransaction B
            ON A.strRecordNumber = B.strTransactionId

    ----DELETE IF NOT CHECK PAYMENT AND DOESN'T HAVE CHECK NUMBER
    --DELETE FROM tblCMBankTransaction
    --WHERE
    --    strTransactionId IN	(
    --                        SELECT strRecordNumber 
    --                        FROM tblARPayment
    --                        INNER JOIN
    --                            @NonZeroPaymentIds P
    --                                ON tblARPayment.[intPaymentId] = P.[intId]
    --                        INNER JOIN
    --                            tblSMPaymentMethod
    --                                ON tblARPayment.intPaymentMethodId = tblSMPaymentMethod.intPaymentMethodID
    --                        WHERE
    --                            tblSMPaymentMethod.strPaymentMethod != 'Check' 
    --                            OR (ISNULL(tblARPayment.strPaymentInfo,'') = '' AND tblSMPaymentMethod.strPaymentMethod = 'Check')
    --                        )

    DELETE FROM tblCMUndepositedFund
    WHERE
        intUndepositedFundId IN (
                                SELECT 
                                    B.intUndepositedFundId
                                FROM
                                    tblARPayment A
                                INNER JOIN
                                    @NonZeroPaymentIds P
                                        ON A.[intPaymentId] = P.[intId]
                                INNER JOIN
                                    tblCMUndepositedFund B 
                                        ON A.intPaymentId = B.intSourceTransactionId 
                                        AND A.strRecordNumber = B.strSourceTransactionId
                                LEFT OUTER JOIN
                                    tblCMBankTransactionDetail TD
                                    ON B.intUndepositedFundId = TD.intUndepositedFundId
                                WHERE 
                                    B.strSourceSystem = 'AR'
                                    AND TD.intUndepositedFundId IS NULL
                                )

	----VOID IF CHECK PAYMENT
	--UPDATE tblCMBankTransaction
	--SET ysnCheckVoid = 1,
	--	ysnPosted = 0
	--WHERE strTransactionId IN (
	--	SELECT strRecordNumber 
	--	FROM tblARPayment
	--	 WHERE intPaymentId IN (SELECT intPaymentId FROM @ARReceivablePostData) 
	--)
		
	---- Insert Zero Payments for updating
	--INSERT INTO @ARReceivablePostData
	--SELECT * FROM @ZeroPayment Z
	--WHERE NOT EXISTS(SELECT NULL FROM @ARReceivablePostData WHERE [intTransactionId] = Z.[intTransactionId])	
	
	
    ----update payment record
    --UPDATE A
    --SET
    --    A.ysnPosted = 0
    --FROM
    --    tblARPayment A
    --INNER JOIN
    --    @PaymentIds P
    --        ON  A.[intPaymentId] = P.[intId]


    --UPDATE 
    --    tblARPayment
    --SET 
    --    intAccountId = NULL			
    --WHERE
    --    intPaymentId IN (SELECT [intTransactionId] FROM @ARReceivablePostData WHERE [intTransactionDetailId] IS NULL)		


	EXEC uspAPUpdateBillPaymentFromAR @paymentIds = @PaymentIds, @post = 0

						
END
ELSE
BEGIN

     UPDATE A
     SET
          A.intCurrentStatus = 4
     FROM
          tblARPayment A
    INNER JOIN
        #ARPostPaymentHeader P
            ON  A.[intPaymentId] = P.[intTransactionId]
	WHERE
		P.[ysnPost] = @OneBit

	-- Delete Invoice with Zero Payment
    DELETE FROM tblARPaymentDetail
    WHERE
        [dblPayment] = @ZeroDecimal
        AND [dblWriteOffAmount] = @ZeroDecimal
        AND [dblDiscount] = @ZeroDecimal
        AND (
            [intInvoiceId] IN (SELECT [intInvoiceId] FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit)
            OR
            [intBillId] IN (SELECT [intBillId] FROM #ARPostPaymentDetail WHERE [ysnPost] = @OneBit)
            OR
            ([intInvoiceId] IS NULL AND [intBillId] IS NULL AND [dblPayment] = @ZeroDecimal)
            )

    -- Update the posted flag in the transaction table
    UPDATE ARP
    SET
         ARP.[intAccountId]			= P.[intUndepositedFundsId]
        ,ARP.[intWriteOffAccountId]	= P.[intWriteOffAccountId]
    FROM
        tblARPayment ARP
    INNER JOIN
        #ARPostPaymentHeader P
            ON ARP.[intPaymentId] = P.[intTransactionId]
	WHERE
		P.[ysnPost] = @OneBit

    UPDATE 
        tblARInvoice
    SET 
        tblARInvoice.dblPayment =  ISNULL(tblARInvoice.dblPayment,0.00) + P.dblPayment 
        ,tblARInvoice.dblBasePayment =  ISNULL(tblARInvoice.dblBasePayment,0.00) + P.dblBasePayment 
	    ,tblARInvoice.dblDiscount = ISNULL(tblARInvoice.dblDiscount,0.00) + P.dblDiscount				
        ,tblARInvoice.dblBaseDiscount = ISNULL(tblARInvoice.dblBaseDiscount,0.00) + P.dblBaseDiscount				
        ,tblARInvoice.dblInterest = ISNULL(tblARInvoice.dblInterest,0.00) + P.dblInterest
        ,tblARInvoice.dblBaseInterest = ISNULL(tblARInvoice.dblBaseInterest,0.00) + P.dblBaseInterest
    FROM
        (
        SELECT 
             dblPayment        =  SUM((A.dblPayment + A.dblWriteOffAmount) * [dbo].[fnARGetInvoiceAmountMultiplier](A.[strTransactionType])) 
            ,dblBasePayment     = SUM((A.dblBasePayment + A.dblBaseWriteOffAmount) * [dbo].[fnARGetInvoiceAmountMultiplier](A.[strTransactionType]))
            ,dblDiscount        = SUM(A.dblDiscount) 
            ,dblBaseDiscount    = SUM(A.dblBaseDiscount) 
            ,dblInterest        = SUM(A.dblInterest) 
            ,dblBaseInterest    = SUM(A.dblBaseInterest)
		    ,intInvoiceId       = A.intInvoiceId 			
        FROM
            #ARPostPaymentDetail A
        WHERE
            A.[ysnInvoicePrepayment] = @ZeroBit
			AND A.[ysnPost] = @OneBit
             AND NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.[intInvoiceId] = ARI.[intInvoiceId] WHERE ARID.[intPrepayTypeId] > 0 AND ARID.[intInvoiceId] = A.[intInvoiceId] AND ARI.[intPaymentId] = A.[intTransactionId])						
        GROUP BY
            A.intInvoiceId,
			A.strTransactionType
        ) P	
    WHERE
        tblARInvoice.intInvoiceId = P.intInvoiceId

    UPDATE 
        C
    SET 
        C.dblAmountDue = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
							THEN 
								CASE C.strTransactionType
                                    WHEN 'Credit Memo'
										THEN ISNULL(C.dblProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal)))
							        WHEN 'Invoice'
										THEN ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))
											- ISNULL((SELECT dblPayment FROM tblARInvoice WHERE intInvoiceId = C.intOriginalInvoiceId), @ZeroDecimal)
								END
							ELSE ISNULL(C.dblInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblPayment, @ZeroDecimal) - ISNULL(C.dblInterest, @ZeroDecimal)) + ISNULL(C.dblDiscount, @ZeroDecimal))
						END				
        ,C.dblBaseAmountDue = CASE WHEN C.intSourceId = 2 AND C.intOriginalInvoiceId IS NOT NULL
							THEN 
								CASE C.strTransactionType 
                                    WHEN 'Credit Memo'
										THEN ISNULL(C.dblBaseProvisionalAmount, @ZeroDecimal) - (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal)))
									WHEN 'Invoice'
										THEN (ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal)))
											- ISNULL((SELECT dblBasePayment FROM tblARInvoice WHERE intInvoiceId = C.intOriginalInvoiceId), @ZeroDecimal)
								END
							ELSE ISNULL(C.dblBaseInvoiceTotal, @ZeroDecimal) - ((ISNULL(C.dblBasePayment, @ZeroDecimal) - ISNULL(C.dblBaseInterest, @ZeroDecimal)) + ISNULL(C.dblBaseDiscount, @ZeroDecimal))
						END	
    FROM 
        #ARPostPaymentDetail B 
    INNER JOIN
        tblARInvoice C
            ON B.intInvoiceId = C.intInvoiceId
    WHERE
        NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId WHERE ARID.intPrepayTypeId > 0 AND ARID.intInvoiceId = B.intInvoiceId AND ARI.intPaymentId = B.[intTransactionId])						
        AND ISNULL(B.[ysnInvoicePrepayment],0) = 0
        AND B.[ysnPost] = @OneBit


    UPDATE
        C
    SET 
        C.ysnPaid = (CASE WHEN (C.dblAmountDue) = @ZeroDecimal THEN 1 ELSE 0 END)
    FROM 
        #ARPostPaymentDetail B
    INNER JOIN
        tblARInvoice C
            ON B.intInvoiceId = C.intInvoiceId
    WHERE
        NOT EXISTS(SELECT NULL FROM tblARInvoiceDetail ARID INNER JOIN tblARInvoice ARI ON ARID.intInvoiceId = ARI.intInvoiceId WHERE ARID.intPrepayTypeId > 0 AND ARID.intInvoiceId = B.intInvoiceId AND ARI.intPaymentId = B.[intTransactionId])
        AND ISNULL(B.[ysnInvoicePrepayment],0) = 0	
		AND B.[ysnPost] = @OneBit	

	--Paid if prepayment
	UPDATE
        C
    SET 
        C.ysnPaidCPP = 1
    FROM 
        #ARPostPaymentDetail B
    INNER JOIN
        tblARInvoice C
            ON B.intInvoiceId = C.intInvoiceId
    WHERE
        C.strTransactionType = 'Customer Prepayment'	
		AND B.[ysnPost] = @OneBit

		
    UPDATE 
        ARPD
    SET 
         ARPD.dblAmountDue     = (((((ISNULL(C.dblInvoiceTotal, 0.00) * [dbo].[fnARGetInvoiceAmountMultiplier](C.[strTransactionType])) + ISNULL(ARPD.dblInterest,0.00)) - ISNULL(ARPD.dblDiscount,0.00))) - (C.dblPayment * [dbo].[fnARGetInvoiceAmountMultiplier](C.[strTransactionType])))
        ,ARPD.dblBaseAmountDue = (((((ISNULL(C.dblBaseInvoiceTotal, 0.00) * [dbo].[fnARGetInvoiceAmountMultiplier](C.[strTransactionType])) + ISNULL(ARPD.dblBaseInterest,0.00)) - ISNULL(ARPD.dblBaseDiscount,0.00))) - (C.dblBasePayment * [dbo].[fnARGetInvoiceAmountMultiplier](C.[strTransactionType])))
    FROM
        tblARPaymentDetail ARPD
    INNER JOIN 
    	#ARPostPaymentDetail P
            ON ARPD.[intPaymentDetailId] = P.[intTransactionDetailId] 
    INNER JOIN 
        tblARInvoice C
            ON P.intInvoiceId = C.intInvoiceId
    WHERE
        ISNULL(P.[ysnInvoicePrepayment],0) = 0	


    EXEC uspAPUpdateBillPaymentFromAR @paymentIds = @PaymentIds, @post = 1
END



UPDATE 
    ARPD
SET 
     ARPD.dblAmountDue     = -((C.dblTotal + ABS(ARPD.dblInterest)) - (ABS(ARPD.dblPayment) + ABS(ARPD.dblDiscount) + ABS(ARPD.dblWriteOffAmount)))
    ,ARPD.dblBaseAmountDue = [dbo].fnRoundBanker((-((C.dblTotal + ABS(ARPD.dblInterest)) - (ABS(ARPD.dblPayment) + ABS(ARPD.dblDiscount) + ABS(ARPD.dblWriteOffAmount))) * (CASE WHEN ISNULL(ARPD.[dblCurrencyExchangeRate], 0) =  0 THEN 1.000000 ELSE ARPD.[dblCurrencyExchangeRate] END)), [dbo].[fnARGetDefaultDecimal]())
FROM
    tblARPaymentDetail ARPD
INNER JOIN 
	#ARPostPaymentDetail P
        ON ARPD.[intPaymentDetailId] = P.[intTransactionDetailId] 
INNER JOIN 
    tblAPBill C
        ON P.intBillId = C.intBillId
WHERE
    ISNULL(P.[ysnInvoicePrepayment],0) = 0

UPDATE
    ARP 
SET
     ARP.strBatchId         = CASE WHEN @Post = ARPH.[ysnPost] THEN @BatchId ELSE NULL END
    ,ARP.dtmBatchDate       = CASE WHEN @Post = ARPH.[ysnPost] THEN @PostDate ELSE NULL END
    ,ARP.intPostedById      = CASE WHEN @Post = ARPH.[ysnPost] THEN @UserId ELSE NULL END
	,ARP.intCurrentStatus   = NULL
    ,ARP.ysnPosted          = ARPH.[ysnPost]
FROM
	tblARPayment ARP
INNER JOIN
	#ARPostPaymentHeader ARPH
		ON ARP.[intPaymentId] = ARPH.[intTransactionId]

--UPDATE CUSTOMER AR BALANCE
--UPDATE CUSTOMER
--SET dblARBalance = dblARBalance - (CASE WHEN @Post = 1 THEN ISNULL(PAYMENT.dblTotalPayment, 0) ELSE ISNULL(PAYMENT.dblTotalPayment, 0) * -1 END)
--FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
--INNER JOIN (
--    SELECT intEntityCustomerId
--        , dblTotalPayment = ABS(SUM(ISNULL(PD.dblTotalPayment, 0) + CASE WHEN P.ysnInvoicePrepayment = 0 THEN ISNULL(P.dblUnappliedAmount, 0)ELSE 0 END))
--    FROM dbo.tblARPayment P WITH (NOLOCK)
--    LEFT JOIN (
--        SELECT dblTotalPayment    = (SUM(PD.dblPayment) + SUM(PD.dblDiscount)) - SUM(PD.dblInterest)
--            , intPaymentId
--        FROM dbo.tblARPaymentDetail PD WITH (NOLOCK)
--        GROUP BY intPaymentId
--    ) PD ON PD.intPaymentId = P.intPaymentId
--    WHERE P.intPaymentId IN (SELECT intId FROM @PaymentIds)
--    GROUP BY intEntityCustomerId
--) PAYMENT ON CUSTOMER.intEntityId = PAYMENT.intEntityCustomerId
UPDATE CUSTOMER
SET dblARBalance = dblARBalance - (CASE WHEN @Post = 1 THEN ISNULL(PAYMENT.dblTotalPayment, 0) ELSE ISNULL(PAYMENT.dblTotalPayment, 0) * -1 END)
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
INNER JOIN (
    SELECT intEntityCustomerId
        , dblTotalPayment = SUM(ISNULL(PD.dblTotalPayment, 0) + CASE WHEN P.ysnInvoicePrepayment = 0 THEN ISNULL(P.dblUnappliedAmount, 0)ELSE 0 END)
    FROM dbo.#ARPostPaymentHeader P WITH (NOLOCK)
    LEFT JOIN (
        SELECT dblTotalPayment    = (SUM(PD.dblPayment) + SUM(PD.dblDiscount) + SUM(PD.dblWriteOffAmount)) - SUM(PD.dblInterest)
            , [intTransactionId]
        FROM dbo.#ARPostPaymentDetail PD WITH (NOLOCK)
        GROUP BY [intTransactionId]
    ) PD ON PD.[intTransactionId] = P.[intTransactionId]
    GROUP BY intEntityCustomerId
) PAYMENT ON CUSTOMER.intEntityId = PAYMENT.intEntityCustomerId

--UPDATE CUSTOMER CREDIT LIMIT REACHED DATE
--UPDATE CUSTOMER
--SET dtmCreditLimitReached = CASE WHEN CUSTOMER.dblARBalance >= CUSTOMER.dblCreditLimit THEN PAYMENT.dtmDatePaid ELSE NULL END
--FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
--CROSS APPLY (
--    SELECT TOP 1 P.dtmDatePaid
--    FROM dbo.tblARPayment P
--    INNER JOIN @PaymentIds U ON P.intPaymentId = U.intId
--    WHERE P.intEntityCustomerId = CUSTOMER.intEntityId
--    ORDER BY P.dtmDatePaid DESC
--) PAYMENT
--WHERE ISNULL(CUSTOMER.dblCreditLimit, 0) > 0
UPDATE CUSTOMER
SET dtmCreditLimitReached = CASE WHEN CUSTOMER.dblARBalance >= CUSTOMER.dblCreditLimit THEN PAYMENT.dtmDatePaid ELSE NULL END
FROM dbo.tblARCustomer CUSTOMER WITH (NOLOCK)
CROSS APPLY (
    SELECT TOP 1 P.dtmDatePaid
    FROM dbo.#ARPostPaymentHeader P
    WHERE P.intEntityCustomerId = CUSTOMER.intEntityId
    ORDER BY P.dtmDatePaid DESC
) PAYMENT
WHERE ISNULL(CUSTOMER.dblCreditLimit, 0) > 0

--UPDATE CUSTOMER'S BUDGET
EXEC dbo.uspARUpdateCustomerBudget @tblPaymentsToUpdateBudget = @PaymentIds, @Post = @Post

--AUDIT LOG
DECLARE @IPaymentLog dbo.[AuditLogStagingTable]
DELETE FROM @IPaymentLog
INSERT INTO @IPaymentLog(
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
	 [strScreenName]			= 'AccountsReceivable.view.ReceivePaymentsDetail'
	,[intKeyValueId]			= [intTransactionId]
	,[intEntityId]				= [intUserId]
	,[strActionType]			= CASE WHEN [ysnPost] = 1 THEN 'Posted'  ELSE 'Unposted' END 
	,[strDescription]			= ''
	,[strActionIcon]			= NULL
	,[strChangeDescription]		= ''
	,[strFromValue]				= ''
	,[strToValue]				= [strTransactionId]
	,[strDetails]				= NULL
FROM
	#ARPostPaymentHeader

EXEC [dbo].[uspARInsertAuditLogs] @LogEntries = @IPaymentLog

--Insert Successfully unposted/posted transactions.
IF ISNULL(@IntegrationLogId, 0) = 0
    BEGIN
        INSERT INTO tblARPostResult(strMessage, strTransactionType, strTransactionId, strBatchNumber, intTransactionId)
        SELECT DISTINCT
            CASE WHEN [ysnPost] = 1 THEN 'Transaction successfully posted.'  ELSE 'Transaction successfully unposted.' END
            ,'Receive Payment'
            ,[strTransactionId]
            ,@BatchId
            ,[intTransactionId]
        FROM
            #ARPostPaymentHeader
    END

--Call integration 
			
DECLARE @PaymentStaging PaymentIntegrationStagingTable
DECLARE @InvoiceId InvoiceId

INSERT INTO @PaymentStaging(intId, intInvoiceId, dblBasePayment, strTransactionNumber, strSourceTransaction, strSourceId, intEntityCustomerId, intCompanyLocationId, intCurrencyId, dtmDatePaid, intPaymentMethodId, intEntityId)
--select intTransactionId, intInvoiceId,  dblBasePayment, strTransactionId, 'temp', '0', intEntityCustomerId, intCompanyLocationId, intCurrencyId, getdate(), 1, 1  from @ARReceivablePostData
SELECT A.[intTransactionId], A.[intInvoiceId], A.[dblBaseAmountPaid], A.[strTransactionId], '0', '0', 1, 1, 1, getdate(), 1, 1
FROM #ARPostPaymentDetail A 
--			

exec uspARPaymentIntegration @InvoiceId, @Post, @PaymentStaging
--


IF @Post = 0
	BEGIN			
					
	--DELETE Overpayment
	WHILE EXISTS(SELECT TOP 1 NULL FROM #ARPostOverPayment)
		BEGIN			
			DECLARE @PaymentIdToDelete int		
			SELECT TOP 1 @PaymentIdToDelete = [intTransactionId] FROM #ARPostOverPayment
					
			EXEC [dbo].[uspARDeleteOverPayment] @PaymentIdToDelete, 1, @BatchId ,@UserId 
					
			DELETE FROM #ARPostOverPayment WHERE [intTransactionId] = @PaymentIdToDelete
		END	
				
	----DELETE Prepayment
	--WHILE EXISTS(SELECT TOP 1 NULL FROM #ARPostPrePayment)
	--	BEGIN			
	--		DECLARE @PaymentIdToDeletePre int		
	--		SELECT TOP 1 @PaymentIdToDeletePre = [intTransactionId] FROM #ARPostPrePayment
					
	--		EXEC [dbo].[uspARDeletePrePayment] @PaymentIdToDeletePre, 1, @BatchId ,@UserId 
					
	--		DELETE FROM #ARPostPrePayment WHERE [intTransactionId] = @PaymentIdToDeletePre
					
	--	END												

	END
ELSE
	BEGIN
			
	--CREATE Overpayment
	WHILE EXISTS(SELECT TOP 1 NULL FROM #ARPostOverPayment)
		BEGIN
			DECLARE @PaymentIdToAdd int
			SELECT TOP 1 @PaymentIdToAdd = [intTransactionId] FROM #ARPostOverPayment
					
			EXEC [dbo].[uspARCreateOverPayment] @PaymentIdToAdd, 1, @BatchId ,@UserId 
					
			DELETE FROM #ARPostOverPayment WHERE [intTransactionId] = @PaymentIdToAdd
		END
				
	--CREATE Prepayment
	WHILE EXISTS(SELECT TOP 1 NULL FROM #ARPostPrePayment)
		BEGIN
			DECLARE @PaymentIdToAddPre int
			SELECT TOP 1 @PaymentIdToAddPre = [intTransactionId] FROM #ARPostPrePayment
					
			EXEC [dbo].[uspARCreatePrePayment] @PaymentIdToAddPre, 1, @BatchId ,@UserId, Null, 1, 1 
					
			DELETE FROM #ARPostPrePayment WHERE [intTransactionId] = @PaymentIdToAddPre
		END				
									
	END			


RETURN 1
END
