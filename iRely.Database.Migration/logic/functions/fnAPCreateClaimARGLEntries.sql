--liquibase formatted sql

-- changeset Von:fnAPCreateClaimARGLEntries.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER FUNCTION [dbo].[fnAPCreateClaimARGLEntries]
(
	@transactionIds		AS Id READONLY
	,@intUserId			INT
	,@batchId			NVARCHAR(50)
)
RETURNS @returntable TABLE
(
	[dtmDate]                   DATETIME         NOT NULL,
	[strBatchId]                NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]              INT              NULL,
	[dblDebit]                  NUMERIC (18, 6)  NULL,
	[dblCredit]                 NUMERIC (18, 6)  NULL,
	[dblDebitUnit]              NUMERIC (18, 6)  NULL,
	[dblCreditUnit]             NUMERIC (18, 6)  NULL,
	[strDescription]            NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strCode]                   NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,    
	[strReference]              NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intCurrencyId]             INT              NULL,
	[dblExchangeRate]           NUMERIC (38, 20) DEFAULT 1 NOT NULL,
	[dtmDateEntered]            DATETIME         NOT NULL,
	[dtmTransactionDate]        DATETIME         NULL,
	[strJournalLineDescription] NVARCHAR (250)   COLLATE Latin1_General_CI_AS NULL,
	[intJournalLineNo]			INT              NULL,
	[ysnIsUnposted]             BIT              NOT NULL,    
	[intUserId]                 INT              NULL,
	[intEntityId]				INT              NULL,
	[strTransactionId]          NVARCHAR (40)    COLLATE Latin1_General_CI_AS NULL,
	[intTransactionId]          INT              NULL,
	[strTransactionType]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strTransactionForm]        NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[strModuleName]             NVARCHAR (255)   COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId]			INT NOT NULL DEFAULT(0),
	[dblDebitForeign]           NUMERIC (18, 6)	NULL,
    [dblDebitReport]            NUMERIC (18, 6) NULL,
    [dblCreditForeign]          NUMERIC (18, 6) NULL,
    [dblCreditReport]           NUMERIC (18, 6) NULL,
    [dblReportingRate]          NUMERIC (18, 6) NULL,
    [dblForeignRate]            NUMERIC (18, 6) NULL,
	[strRateType]				NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL
)
AS
BEGIN

	INSERT INTO @returntable (
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
			,[strRateType]
		)
		SELECT
			[dtmDate]						=	CAST(arPay.dtmDatePaid AS DATE)
			,[strBatchId]					=	@batchId	
			,[intAccountId]					=	voucher.intAccountId
			,[dblDebit]						=	0
			,[dblCredit]					=	arPayDetail.dblBasePayment + ISNULL(claimDetail.dblFranchiseAmount,0.000000)
			,[dblDebitUnit]					=	0
			,[dblCreditUnit]				=	0
			,[strDescription]				=	arPay.strNotes
			,[strCode]						=	'AP'
			,[strReference]					=	customer.strCustomerNumber
			,[intCurrencyId]				=	arPay.intCurrencyId
			,[dblExchangeRate]				=	1
			,[dtmDateEntered]				=	arPay.dtmDatePaid
			,[dtmTransactionDate]			=	GETDATE()
			,[strJournalLineDescription]	=	voucher.strBillId
			,[intJournalLineNo]				=	arPayDetail.intPaymentDetailId
			,[ysnIsUnposted]				=	0
			,[intUserId]					=	@intUserId
			,[intEntityId]					=	@intUserId
			,[strTransactionId]				=	arPay.strRecordNumber
			,[intTransactionId]				=	arPay.intPaymentId
			,[strTransactionType]			=	'Receive Payments'
			,[strTransactionForm]			=	'Receive Payments'
			,[strModuleName]				=	'Accounts Receivable'
			,[intConcurrencyId]				=	1
			,[dblDebitForeign]				=	0
			,[dblDebitReport]				=	0
			,[dblCreditForeign]				=	(arPayDetail.dblBasePayment + ISNULL(claimDetail.dblFranchiseAmount,0.000000))  * ISNULL(arPayDetail.dblCurrencyExchangeRate,1.000000)
			,[dblCreditReport]				=	arPayDetail.dblBasePayment + ISNULL(claimDetail.dblFranchiseAmount,0.000000)
			,[dblReportingRate]				=	arPayDetail.dblCurrencyExchangeRate
			,[dblForeignRate]				=	arPayDetail.dblCurrencyExchangeRate
			,[strRateType]					=	SMCERT.strCurrencyExchangeRateType	 	
		FROM tblARPayment arPay
		INNER JOIN @transactionIds ids ON arPay.intPaymentId = ids.intId
		INNER JOIN (
			SELECT Emet.intEntityId, Emet.strCustomerNumber, EME.strName from 
					(	SELECT intEntityId, strCustomerNumber FROM tblARCustomer UNION
					SELECT intEntityId, strCustomerNumber = strVendorId  FROM tblAPVendor ) Emet
			JOIN tblEMEntity EME ON EME.intEntityId = Emet.intEntityId
		)  customer ON arPay.intEntityCustomerId = customer.intEntityId
		INNER JOIN tblARPaymentDetail arPayDetail ON arPay.intPaymentId = arPayDetail.intPaymentId AND arPayDetail.dblPayment <> 0
		INNER JOIN tblAPBill voucher ON voucher.intBillId = arPayDetail.intBillId and voucher.intTransactionType = 11
		LEFT OUTER JOIN
		(
			SELECT
				intCurrencyExchangeRateTypeId 
				,strCurrencyExchangeRateType 
			FROM
				tblSMCurrencyExchangeRateType
		)	SMCERT
			ON arPayDetail.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		OUTER APPLY (
			SELECT TOP 1
				dblFranchiseAmount
			FROM tblAPBillDetail voucherDetail
			WHERE voucherDetail.intBillId = voucher.intBillId
		) claimDetail
		UNION ALL
		SELECT
			[dtmDate]						=	CAST(arPay.dtmDatePaid AS DATE)
			,[strBatchId]					=	@batchId	
			,[intAccountId]					=	claimDetail.intAccountId
			,[dblDebit]						=	ISNULL(claimDetail.dblFranchiseAmount,0)
			,[dblCredit]					=	0
			,[dblDebitUnit]					=	0
			,[dblCreditUnit]				=	0
			,[strDescription]				=	arPay.strNotes
			,[strCode]						=	'AP'
			,[strReference]					=	'Franchise Amount'
			,[intCurrencyId]				=	arPay.intCurrencyId
			,[dblExchangeRate]				=	1
			,[dtmDateEntered]				=	arPay.dtmDatePaid
			,[dtmTransactionDate]			=	GETDATE()
			,[strJournalLineDescription]	=	voucher.strBillId
			,[intJournalLineNo]				=	arPayDetail.intPaymentDetailId
			,[ysnIsUnposted]				=	0
			,[intUserId]					=	@intUserId
			,[intEntityId]					=	@intUserId
			,[strTransactionId]				=	arPay.strRecordNumber
			,[intTransactionId]				=	arPay.intPaymentId
			,[strTransactionType]			=	'Receive Payments'
			,[strTransactionForm]			=	'Receive Payments'
			,[strModuleName]				=	'Accounts Receivable'
			,[intConcurrencyId]				=	1
			,[dblDebitForeign]				=	ISNULL(claimDetail.dblFranchiseAmount,0.000000) * ISNULL(arPayDetail.dblCurrencyExchangeRate,1.000000) --Please review -- voucherDetail.dblFranchiseAmount * ISNULL(arPayDetail.dblCurrencyExchangeRate,1)
			,[dblDebitReport]				=	ISNULL(claimDetail.dblFranchiseAmount,0.000000) * ISNULL(arPayDetail.dblCurrencyExchangeRate,1.000000) --Please review -- voucherDetail.dblFranchiseAmount * ISNULL(arPayDetail.dblCurrencyExchangeRate,1)
			,[dblCreditForeign]				=	0
			,[dblCreditReport]				=	0
			,[dblReportingRate]				=	arPayDetail.dblCurrencyExchangeRate
			,[dblForeignRate]				=	arPayDetail.dblCurrencyExchangeRate
			,[strRateType]					=	SMCERT.strCurrencyExchangeRateType	 	
		FROM tblARPayment arPay
		INNER JOIN @transactionIds ids ON arPay.intPaymentId = ids.intId
		INNER JOIN (
			SELECT Emet.intEntityId, Emet.strCustomerNumber, EME.strName from 
					(	SELECT intEntityId, strCustomerNumber FROM tblARCustomer UNION
					SELECT intEntityId, strCustomerNumber = strVendorId  FROM tblAPVendor ) Emet
			JOIN tblEMEntity EME ON EME.intEntityId = Emet.intEntityId
		)   customer ON arPay.intEntityCustomerId = customer.intEntityId
		INNER JOIN tblARPaymentDetail arPayDetail ON arPay.intPaymentId = arPayDetail.intPaymentId  AND arPayDetail.dblPayment <> 0
		INNER JOIN tblAPBill voucher ON voucher.intBillId = arPayDetail.intBillId and voucher.intTransactionType = 11
		-- INNER JOIN tblCTContractHeader contractData ON voucherDetail.intContractHeaderId = contractData.intContractHeaderId
		-- INNER JOIN tblCTWeightGrade weightGrade ON weightGrade.intWeightGradeId = contractData.intWeightId
		LEFT OUTER JOIN
		(
			SELECT
				intCurrencyExchangeRateTypeId 
				,strCurrencyExchangeRateType 
			FROM
				tblSMCurrencyExchangeRateType
		)	SMCERT
			ON arPayDetail.intCurrencyExchangeRateTypeId = SMCERT.intCurrencyExchangeRateTypeId
		OUTER APPLY (
			SELECT TOP 1
				weightGrade.intAccountId
				,dblFranchiseAmount
			FROM tblAPBillDetail voucherDetail
			INNER JOIN tblCTContractHeader ct ON voucherDetail.intContractHeaderId = ct.intContractHeaderId
			INNER JOIN tblCTWeightGrade weightGrade ON weightGrade.intWeightGradeId = ct.intWeightId
			WHERE voucherDetail.intBillId = voucher.intBillId
		) claimDetail

		RETURN;

END



