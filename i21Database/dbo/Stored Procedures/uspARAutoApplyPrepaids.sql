﻿CREATE PROCEDURE [dbo].[uspARAutoApplyPrepaids]
	  @intEntityUserId	INT
	, @strSessionId		NVARCHAR(50) = NULL
AS

DECLARE @tblPaymentEntries	PaymentIntegrationStagingTable

DECLARE @ysnAutoApplyPrepaids	BIT = 0
	  , @intPaymentMethodId		INT = NULL
	  , @intDefaultCurrencyId	INT = NULL
	  , @strPaymentMethod		NVARCHAR(50)

IF(OBJECT_ID('tempdb..#AAPPREPAIDS') IS NOT NULL) DROP TABLE #AAPPREPAIDS
IF(OBJECT_ID('tempdb..#AAPINVOICES') IS NOT NULL) DROP TABLE #AAPINVOICES

CREATE TABLE #AAPINVOICES (
	  intInvoiceId			INT PRIMARY KEY
	, intEntityCustomerId	INT NOT NULL
	, intCompanyLocationId	INT NOT NULL
	, intCurrencyId			INT NOT NULL
	, intTermId				INT NULL
	, intAccountId			INT NULL
	, intEntityUserId		INT NULL
	, dblAmountDue			NUMERIC(18,6) DEFAULT 0
	, dblInvoiceTotal		NUMERIC(18,6) DEFAULT 0
	, dblBaseInvoiceTotal	NUMERIC(18,6) DEFAULT 0
	, dblAppliedPayment		NUMERIC(18,6) DEFAULT 0
	, dtmPostDate			DATETIME NULL
	, strInvoiceNumber		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType	NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, ysnProcessed			BIT NULL DEFAULT 0
)
CREATE TABLE #AAPPREPAIDS (
	  intInvoiceId			INT PRIMARY KEY
	, intEntityCustomerId	INT NOT NULL
	, intCompanyLocationId	INT NOT NULL
	, intCurrencyId			INT NOT NULL
	, intTermId				INT NULL
	, intAccountId			INT NULL
	, intEntityUserId		INT NULL
	, dblAmountDue			NUMERIC(18,6) DEFAULT 0
	, dblInvoiceTotal		NUMERIC(18,6) DEFAULT 0
	, dblBaseInvoiceTotal	NUMERIC(18,6) DEFAULT 0
	, dblAppliedPayment		NUMERIC(18,6) DEFAULT 0
	, dtmPostDate			DATETIME NULL
	, strInvoiceNumber		NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, strTransactionType	NVARCHAR(25) COLLATE Latin1_General_CI_AS NULL
	, ysnProcessed			BIT NULL DEFAULT 0
	, dblRunningTotal		NUMERIC(18,6) DEFAULT 0
	, intContractDetailId	INT NULL	
)

SELECT TOP 1 @ysnAutoApplyPrepaids = ysnAutoApplyPrepaids 
FROM dbo.tblARCompanyPreference 
ORDER BY intCompanyPreferenceId

IF @ysnAutoApplyPrepaids <> 1
	RETURN;

SELECT TOP 1 @intDefaultCurrencyId = intDefaultCurrencyId 
FROM tblSMCompanyPreference 
WHERE intDefaultCurrencyId IS NOT NULL
ORDER BY intCompanyPreferenceId

--GET DEFAULT PAYMENT METHOD
SELECT TOP 1 @intPaymentMethodId 	= intPaymentMethodID
		   , @strPaymentMethod		= strPaymentMethod
FROM tblSMPaymentMethod 
WHERE strPaymentMethod = 'Manual Credit Card'

IF ISNULL(@intPaymentMethodId, 0) = 0
	BEGIN
		INSERT INTO tblSMPaymentMethod (
			strPaymentMethod
			, intNumber
			, ysnActive
			, intSort
			, intConcurrencyId
		)
		SELECT strPaymentMethod = 'Manual Credit Card'
			, intNumber		 	= 1
			, ysnActive			= 1
			, intSort			= 0
			, intConcurrencyId	= 1

		SELECT TOP 1 @intPaymentMethodId 	= intPaymentMethodID
					, @strPaymentMethod		= strPaymentMethod
		FROM tblSMPaymentMethod 
		WHERE strPaymentMethod = 'Manual Credit Card'
	END

--GET INVOICES TO POST
INSERT INTO #AAPINVOICES WITH (TABLOCK) (
	  intInvoiceId
	, intEntityCustomerId
	, intCompanyLocationId
	, intCurrencyId
	, intTermId
	, intAccountId
	, intEntityUserId
	, dblAmountDue
	, dblInvoiceTotal
	, dblBaseInvoiceTotal
	, dtmPostDate
	, strInvoiceNumber
	, strTransactionType
)
SELECT intInvoiceId			= I.intInvoiceId
	, intEntityCustomerId	= I.intEntityCustomerId
	, intCompanyLocationId	= I.intCompanyLocationId
	, intCurrencyId			= I.intCurrencyId
	, intTermId				= I.intTermId
	, intAccountId			= I.intAccountId
	, intEntityUserId		= @intEntityUserId
	, dblAmountDue			= I.dblAmountDue
	, dblInvoiceTotal		= I.dblInvoiceTotal
	, dblBaseInvoiceTotal	= I.dblBaseInvoiceTotal
	, dtmPostDate			= I.dtmPostDate
	, strInvoiceNumber		= I.strInvoiceNumber
	, strTransactionType	= I.strTransactionType
FROM tblARPostInvoiceHeader I
WHERE I.ysnCancelled = 0
  AND I.ysnPaid = 0
  AND I.strTransactionType IN ('Invoice', 'Debit Memo')
  AND I.strSessionId = @strSessionId
  AND I.strType NOT IN ('CF Tran', 'CF Invoice')

--GET AVAILABLE CREDITS AND PREPAIDS FOR CUSTOMERS
INSERT INTO #AAPPREPAIDS WITH (TABLOCK) (
	  intInvoiceId
	, intEntityCustomerId
	, intCompanyLocationId
	, intCurrencyId
	, intTermId
	, intAccountId
	, intEntityUserId
	, dblAmountDue
	, dblInvoiceTotal
	, dblBaseInvoiceTotal
	, dtmPostDate
	, strInvoiceNumber
	, strTransactionType
	, intContractDetailId	
)
SELECT intInvoiceId			= C.intInvoiceId
	, intEntityCustomerId	= C.intEntityCustomerId
	, intCompanyLocationId	= C.intCompanyLocationId
	, intCurrencyId			= C.intCurrencyId
	, intTermId				= C.intTermId
	, intAccountId			= C.intAccountId
	, intEntityUserId		= @intEntityUserId
	, dblAmountDue			= C.dblAmountDue
	, dblInvoiceTotal		= C.dblInvoiceTotal
	, dblBaseInvoiceTotal	= C.dblBaseInvoiceTotal
	, dtmPostDate			= C.dtmPostDate
	, strInvoiceNumber		= C.strInvoiceNumber
	, strTransactionType	= C.strTransactionType
	, intContractDetailId   = ISNULL(CreditWithLinkContract.intContractDetailId , 0)
FROM tblARInvoice C WITH (NOLOCK)
INNER JOIN (
	SELECT DISTINCT intEntityCustomerId
	FROM #AAPINVOICES
) CUST ON C.intEntityCustomerId = CUST.intEntityCustomerId
LEFT JOIN (
	SELECT intPaymentId
	FROM dbo.tblARPayment WITH (NOLOCK)
	WHERE ysnPosted = 1
	AND ysnProcessedToNSF = 0
) PREPAY ON C.intPaymentId = PREPAY.intPaymentId
INNER JOIN tblARInvoice I ON I.intInvoiceId=C.intInvoiceId	
INNER JOIN tblARInvoiceDetail ID ON C.intInvoiceId=ID.intInvoiceId AND ID.intInvoiceId=I.intInvoiceId	
LEFT JOIN(	
SELECT intContractDetailId,intContractHeaderId FROM #AAPINVOICES AAPI	
INNER JOIN tblARInvoiceDetail ID ON AAPI.intInvoiceId=ID.intInvoiceId)	
CreditWithLinkContract ON CreditWithLinkContract.intContractDetailId =ID.intContractDetailId AND ID.intContractHeaderId=CreditWithLinkContract.intContractHeaderId
WHERE C.ysnPosted = 1
  AND C.ysnCancelled = 0
  AND C.ysnPaid = 0
  AND C.dblAmountDue > 0
  AND ((C.strTransactionType  IN ('Customer Prepayment', 'Overpayment') AND PREPAY.intPaymentId IS NOT NULL) OR C.strTransactionType = 'Credit Memo')
ORDER BY C.dtmPostDate, C.intInvoiceId

--REMOVE RESTRICTED CPP FROM AVAILABLE PREPAIDS
DELETE P
FROM #AAPPREPAIDS P
INNER JOIN tblARInvoiceDetail ID ON P.intInvoiceId = ID.intInvoiceId
WHERE P.strTransactionType = 'Customer Prepayment'
  AND ID.ysnRestricted = 1

IF NOT EXISTS(SELECT TOP 1 NULL FROM #AAPPREPAIDS) 
	RETURN;

WHILE EXISTS (SELECT TOP 1 NULL FROM #AAPINVOICES WHERE ysnProcessed = 0)
	BEGIN
		DECLARE  @intInvoiceId	INT
				,@dblAmountDue	NUMERIC(18, 6)

		SELECT TOP 1 @intInvoiceId = intInvoiceId, @dblAmountDue = dblAmountDue
		FROM #AAPINVOICES
		WHERE ysnProcessed = 0

		DECLARE @query AS NVARCHAR(MAX) = '
				UPDATE P
				 SET dblRunningTotal = CREDITS.dblRunningTotal
				FROM #AAPPREPAIDS P
				INNER JOIN (
					SELECT P.dtmPostDate, P.intInvoiceId,P.dblAmountDue,P.dblAppliedPayment
						 ,dblRunningTotal = SUM(P.dblAmountDue - dblAppliedPayment) OVER (ORDER BY P.intContractDetailId DESC, P.dtmPostDate,  P.intInvoiceId)
					FROM #AAPPREPAIDS P
					WHERE P.dblAppliedPayment <> P.dblAmountDue
				) CREDITS ON CREDITS.intInvoiceId = P.intInvoiceId
				WHERE P.dblAppliedPayment <> P.dblAmountDue
				'
		 EXEC sp_executesql @query

		--INSERT CREDITS
		INSERT INTO @tblPaymentEntries (
			  intId
			, strSourceTransaction
			, intSourceId
			, strSourceId
			, intEntityCustomerId
			, intCompanyLocationId
			, intCurrencyId
			, dtmDatePaid
			, intPaymentMethodId
			, strPaymentMethod
			, strNotes
			, strPaymentInfo
			, intBankAccountId
			, dblAmountPaid
			, intEntityId
			, intInvoiceId
			, strTransactionType
			, strTransactionNumber
			, intTermId
			, intInvoiceAccountId
			, dblInvoiceTotal
			, dblBaseInvoiceTotal
			, dblPayment
			, dblAmountDue
			, strInvoiceReportNumber
			, ysnPost
		)
		SELECT intId						= I.intInvoiceId
			, strSourceTransaction			= 'Direct'
			, intSourceId					= I.intInvoiceId
			, strSourceId					= I.strInvoiceNumber
			, intEntityCustomerId			= I.intEntityCustomerId
			, intCompanyLocationId			= I.intCompanyLocationId
			, intCurrencyId					= I.intCurrencyId
			, dtmDatePaid					= I.dtmPostDate
			, intPaymentMethodId			= @intPaymentMethodId
			, strPaymentMethod				= @strPaymentMethod
			, strNotes						= 'Auto Apply Prepaid and Credits for ' + I.strInvoiceNumber
			, strPaymentInfo				= NULL
			, intBankAccountId				= NULL
			, dblAmountPaid					= 0
			, intEntityId					= @intEntityUserId
			, intInvoiceId					= CREDITS.intInvoiceId
			, strTransactionType			= CREDITS.strTransactionType
			, strTransactionNumber			= CREDITS.strInvoiceNumber
			, intTermId						= CREDITS.intTermId
			, intInvoiceAccountId			= CREDITS.intAccountId
			, dblInvoiceTotal				= CREDITS.dblInvoiceTotal
			, dblBaseInvoiceTotal			= CREDITS.dblBaseInvoiceTotal
			, dblPayment					= CREDITS.dblAmountDue - CREDITS.dblAppliedPayment
			, dblAmountDue					= CREDITS.dblAmountDue
			, strInvoiceReportNumber		= CREDITS.strInvoiceNumber
			, ysnPost						= 1
		FROM #AAPINVOICES I
		INNER JOIN (
			SELECT P.*
			FROM #AAPPREPAIDS P
			WHERE P.dblAppliedPayment <> P.dblAmountDue
		) CREDITS
		ON CREDITS.intEntityCustomerId = I.intEntityCustomerId
		WHERE I.dtmPostDate >= CREDITS.dtmPostDate
		  AND I.dblInvoiceTotal >= CREDITS.dblRunningTotal
		  AND I.intInvoiceId = @intInvoiceId
		  
		UPDATE P
		SET dblAppliedPayment = dblAppliedPayment + E.dblPayment
		FROM #AAPPREPAIDS P 
		CROSS APPLY (
			SELECT intInvoiceId
				 , dblPayment		= SUM(dblPayment)
			FROM @tblPaymentEntries E
			WHERE P.intInvoiceId = E.intInvoiceId
			  AND E.intSourceId = @intInvoiceId
			  AND P.strTransactionType NOT IN ('Invoice', 'Debit Memo')
			GROUP BY intInvoiceId
		) E 
		
		UPDATE I
		SET dblAppliedPayment = E.dblPayment
		FROM #AAPINVOICES I
		CROSS APPLY (
			SELECT intSourceId	= intSourceId
				 , dblPayment	= SUM(dblPayment)
			FROM @tblPaymentEntries P
			WHERE I.intInvoiceId = P.intSourceId
			  AND I.intInvoiceId <> P.intInvoiceId
			  AND P.strTransactionType NOT IN ('Invoice', 'Debit Memo')
			GROUP BY intSourceId
		) E
		WHERE I.intInvoiceId = @intInvoiceId
		
		--INSERT CREDITS IF HAS AVAILABLE AND INVOICE AMOUNT DUE IS NOT YET ZERO
		IF EXISTS (SELECT TOP 1 NULL FROM #AAPPREPAIDS WHERE dblAmountDue <> dblAppliedPayment) AND EXISTS (SELECT TOP 1 NULL FROM #AAPINVOICES WHERE dblInvoiceTotal <> dblAppliedPayment)
			BEGIN
				INSERT INTO @tblPaymentEntries (
					  intId
					, strSourceTransaction
					, intSourceId
					, strSourceId
					, intEntityCustomerId
					, intCompanyLocationId
					, intCurrencyId
					, dtmDatePaid
					, intPaymentMethodId
					, strPaymentMethod
					, strNotes
					, strPaymentInfo
					, intBankAccountId
					, dblAmountPaid
					, intEntityId
					, intInvoiceId
					, strTransactionType
					, strTransactionNumber
					, intTermId
					, intInvoiceAccountId
					, dblInvoiceTotal
					, dblBaseInvoiceTotal
					, dblPayment
					, dblAmountDue
					, strInvoiceReportNumber
					, ysnPost
				)
				SELECT intId						= I.intInvoiceId
					, strSourceTransaction			= 'Direct'
					, intSourceId					= I.intInvoiceId
					, strSourceId					= I.strInvoiceNumber
					, intEntityCustomerId			= I.intEntityCustomerId
					, intCompanyLocationId			= I.intCompanyLocationId
					, intCurrencyId					= I.intCurrencyId
					, dtmDatePaid					= I.dtmPostDate
					, intPaymentMethodId			= @intPaymentMethodId
					, strPaymentMethod				= @strPaymentMethod
					, strNotes						= 'Auto Apply Prepaid and Credits for ' + I.strInvoiceNumber
					, strPaymentInfo				= NULL
					, intBankAccountId				= NULL
					, dblAmountPaid					= 0
					, intEntityId					= @intEntityUserId
					, intInvoiceId					= CREDITS.intInvoiceId
					, strTransactionType			= CREDITS.strTransactionType
					, strTransactionNumber			= CREDITS.strInvoiceNumber
					, intTermId						= CREDITS.intTermId
					, intInvoiceAccountId			= CREDITS.intAccountId
					, dblInvoiceTotal				= CREDITS.dblInvoiceTotal
					, dblBaseInvoiceTotal			= CREDITS.dblBaseInvoiceTotal
					, dblPayment					= I.dblInvoiceTotal - I.dblAppliedPayment
					, dblAmountDue					= CREDITS.dblAmountDue
					, strInvoiceReportNumber		= CREDITS.strInvoiceNumber
					, ysnPost						= 1
				FROM #AAPINVOICES I
				INNER JOIN #AAPPREPAIDS CREDITS ON CREDITS.intEntityCustomerId = I.intEntityCustomerId
				WHERE I.dtmPostDate >= CREDITS.dtmPostDate				  
				  AND I.intInvoiceId = @intInvoiceId
				  AND CREDITS.dblAppliedPayment <> CREDITS.dblAmountDue
				  AND I.dblInvoiceTotal <> I.dblAppliedPayment

				UPDATE P
				SET dblAppliedPayment = E.dblPayment
				FROM #AAPPREPAIDS P
				INNER JOIN @tblPaymentEntries E ON P.intInvoiceId = E.intInvoiceId

				DECLARE @queryRows AS NVARCHAR(MAX) = '
					UPDATE PP
					SET dblAppliedPayment = 0
					FROM #AAPPREPAIDS PP
					WHERE PP.intInvoiceId NOT IN (
						SELECT intInvoiceId
						FROM 
						(
							SELECT 
								 intInvoiceId
								,SUM(dblAppliedPayment) OVER(ORDER BY intContractDetailId DESC,intInvoiceId ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS dbldblAppliedPaymentTotal
							FROM  #AAPPREPAIDS
						) T
						WHERE T.dbldblAppliedPaymentTotal <= ' + CAST(@dblAmountDue AS NVARCHAR(MAX)) + '
					)
				'
				EXEC sp_executesql @queryRows


				DELETE FROM @tblPaymentEntries
				WHERE intInvoiceId IN (SELECT intInvoiceId FROM #AAPPREPAIDS WHERE dblAppliedPayment = 0)

				UPDATE I
				SET dblAppliedPayment = E.dblPayment
				FROM #AAPINVOICES I
				CROSS APPLY (
					SELECT intSourceId	= intSourceId
						 , dblPayment	= SUM(dblPayment)
					FROM @tblPaymentEntries P
					WHERE I.intInvoiceId = P.intSourceId
					  AND I.intInvoiceId <> P.intInvoiceId
					  AND P.strTransactionType NOT IN ('Invoice', 'Debit Memo')
					GROUP BY intSourceId
				) E
				WHERE I.intInvoiceId = @intInvoiceId
			END

		--INSERT INVOICE
		IF EXISTS (SELECT TOP 1 NULL FROM @tblPaymentEntries WHERE intId = @intInvoiceId)
            BEGIN                
                INSERT INTO @tblPaymentEntries (
                      intId
                    , strSourceTransaction
                    , intSourceId
                    , strSourceId
                    , intEntityCustomerId
                    , intCompanyLocationId
                    , intCurrencyId
                    , dtmDatePaid
                    , intPaymentMethodId
                    , strPaymentMethod
                    , strNotes
                    , strPaymentInfo
                    , intBankAccountId
                    , dblAmountPaid
                    , intEntityId
                    , intInvoiceId
                    , strTransactionType
                    , strTransactionNumber
                    , intTermId
                    , intInvoiceAccountId
                    , dblInvoiceTotal
                    , dblBaseInvoiceTotal
                    , dblPayment
                    , dblAmountDue
                    , strInvoiceReportNumber
                    , ysnPost
                )
                SELECT intId                        = I.intInvoiceId
                    , strSourceTransaction          = 'Direct'
                    , intSourceId                   = I.intInvoiceId
                    , strSourceId                   = I.strInvoiceNumber
                    , intEntityCustomerId           = I.intEntityCustomerId
                    , intCompanyLocationId          = I.intCompanyLocationId
                    , intCurrencyId                 = I.intCurrencyId
                    , dtmDatePaid                   = I.dtmPostDate
                    , intPaymentMethodId            = @intPaymentMethodId
                    , strPaymentMethod              = @strPaymentMethod
                    , strNotes                      = 'Auto Apply Prepaid and Credits for ' + I.strInvoiceNumber 
                    , strPaymentInfo                = NULL
                    , intBankAccountId              = NULL
                    , dblAmountPaid                 = 0
                    , intEntityId                   = @intEntityUserId
                    , intInvoiceId                  = I.intInvoiceId
                    , strTransactionType            = I.strTransactionType
                    , strTransactionNumber          = I.strInvoiceNumber
                    , intTermId                     = I.intTermId
                    , intInvoiceAccountId           = I.intAccountId
                    , dblInvoiceTotal               = I.dblInvoiceTotal
                    , dblBaseInvoiceTotal           = I.dblBaseInvoiceTotal
                    , dblPayment                    = I.dblAppliedPayment
                    , dblAmountDue                  = I.dblAmountDue
                    , strInvoiceReportNumber        = I.strInvoiceNumber
                    , ysnPost                       = 1
                FROM #AAPINVOICES I
                WHERE I.intInvoiceId = @intInvoiceId
            END

		IF NOT EXISTS (SELECT TOP 1 NULL FROM #AAPPREPAIDS WHERE dblAmountDue <> dblAppliedPayment)
			BEGIN
				UPDATE #AAPINVOICES SET ysnProcessed = 1
			END
		ELSE
			BEGIN
				UPDATE #AAPINVOICES
				SET ysnProcessed = 1
				WHERE intInvoiceId = @intInvoiceId
			END
	END

--CREATE AND POST PAYMENTS	
IF EXISTS (SELECT TOP 1 NULL FROM @tblPaymentEntries)
	BEGIN
		DECLARE @ErrorMessage NVARCHAR(500) = NULL, @LogId INT = NULL

		EXEC dbo.uspARProcessPayments @PaymentEntries	= @tblPaymentEntries
									, @UserId			= @intEntityUserId
									, @GroupingOption	= 7
									, @RaiseError		= 0
									, @ErrorMessage		= @ErrorMessage OUT
								    , @LogId			= @LogId OUT
	END