﻿GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportBillTransactions')
	DROP PROCEDURE uspAPImportBillTransactions
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
		EXEC ('
		CREATE PROCEDURE [dbo].[uspAPImportBillTransactions]
			@DateFrom	DATE = NULL,
			@DateTo	DATE = NULL,
			@PeriodFrom	INT = NULL,
			@PeriodTo	INT = NULL,
			@UserId INT,
			@Total INT OUTPUT
		AS
		BEGIN

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF

		--TODO Add Validation
		--1. All account that will use in importing should exists in tblAGLAccount
		--2. Validate Balance after importing

		--CREATE TEMP TABLE TO BYPASS EXECUTING FIXING STARTING NUMBERS
		SELECT @@ROWCOUNT AS TestColumn INTO #tblTempAPByPassFixStartingNumber

		--DECLARE #InsertedData TABLE (intBillId INT, strBillId NVARCHAR(100), ysnPosted BIT, ysnPaid BIT, strVendorOrderNumber NVARCHAR(50))
		CREATE TABLE #InsertedData(intBillId INT PRIMARY KEY CLUSTERED, strBillId NVARCHAR(100), ysnPosted BIT, ysnPaid BIT, strVendorOrderNumber NVARCHAR(50), intTransactionType INT)
		CREATE NONCLUSTERED INDEX [IX_tmpInsertedData_intBillId] ON #InsertedData([intBillId]);
		DECLARE @insertedBillBatch TABLE(intBillBatchId INT, intBillId INT)
		DECLARE @totalBills INT
		DECLARE @BillId INT
		DECLARE @BillBatchId INT
		DECLARE @ImportedRecords INT
		DECLARE @IsPosted BIT
		DECLARE @IsPaid BIT
		DECLARE @type INT
		DECLARE @GeneratedBillId NVARCHAR(50)

		--Validation
		--Check if there is a payment method with a type of ''Check''
		IF NOT EXISTS(SELECT 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Check'')
		BEGIN
			--RAISERROR(''Please create Check payment method before importing bills.'', 16, 1);
			--RETURN;
			INSERT INTO tblSMPaymentMethod(strPaymentMethod, ysnActive)
			SELECT ''Check'', 1
		END

		--Check if there is a payment method with a type of ''Refund''
		IF NOT EXISTS(SELECT 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Refund'')
		BEGIN
			--RAISERROR(''Please create Check payment method before importing bills.'', 16, 1);
			--RETURN;
			INSERT INTO tblSMPaymentMethod(strPaymentMethod, ysnActive)
			SELECT ''Refund'', 1
		END

		--Check if there is check book that was not exists on tblCMBankAccount
		IF EXISTS(SELECT 1 FROM apchkmst A 
					LEFT JOIN tblCMBankAccount B
						ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
					WHERE B.strCbkNo IS NULL)
		BEGIN
			RAISERROR(''There is a check book number that was not imported.'', 16, 1);
			RETURN;
		END

		--CREATE AP ACCOUNT CATEGORY
		EXEC uspGLUpdateAPAccountCategory

		IF(@UserId <= 0)
		BEGIN
			RAISERROR(''You cannot import without user.'', 16, 1);
			RETURN;
		END

		--Payment variable
		DECLARE @bankAccount INT,
					@paymentMethod INT,
					@intEntityVendorId INT,
					@paymentInfo NVARCHAR(10),
					@notes NVARCHAR(500),
					@payment DECIMAL(18, 6) = NULL,
					@datePaid DATETIME = NULL,
					@post BIT = 0,
					@discount DECIMAL(18,6) = 0,
					@interest DECIMAL(18,6) = 0,
					@withHeld DECIMAL(18,6) = 0,
					@billIds NVARCHAR(MAX)

		--removed first the constraint
		ALTER TABLE tblAPBill
			DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

		IF(@DateFrom IS NULL AND @PeriodFrom IS NULL)
		BEGIN

			INSERT INTO [dbo].[tblAPBill] (
				[intEntityVendorId],
				--[strVendorId], 
				--[strBillId],
				[strVendorOrderNumber], 
				[intTermsId], 
				[intTaxId], 
				[dtmDate], 
				[dtmDateCreated], 
				[dtmBillDate],
				[dtmDueDate], 
				[intAccountId], 
				[strReference], 
				[strPONumber],
				[dblTotal], 
				[dblAmountDue],
				[intEntityId],
				[ysnPosted],
				[ysnPaid],
				[intTransactionType],
				[dblDiscount],
				[dblWithheld],
				[ysnOrigin])
			OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid, inserted.strVendorOrderNumber, inserted.intTransactionType INTO #InsertedData
			--Unposted
			SELECT
				[intEntityVendorId]			=	D.intEntityVendorId,
				--[strVendorId]			=	A.aptrx_vnd_no,
				--[strBillId] 			=	A.aptrx_ivc_no,
				[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
				[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation
													WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor
														WHERE strVendorId COLLATE Latin1_General_CS_AS = A.aptrx_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
				[intTaxId] 				=	NULL,
				[dtmDate] 				=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmDateCreated] 		=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmBillDate] 			=	CASE WHEN ISDATE(A.aptrx_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmDueDate] 			=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
				[strReference] 		=	A.aptrx_comment,
				[strPONumber]			=	A.aptrx_pur_ord_no,
				[dblTotal] 				=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt 
												ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
				[dblAmountDue]			=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt 
												ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
				[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.aptrx_user_id)),@UserId),
				[ysnPosted]				=	0,
				[ysnPaid]				=	0,
				[intTransactionType]	=	CASE WHEN A.aptrx_trans_type = ''I'' THEN 1
												WHEN A.aptrx_trans_type = ''A'' THEN 2
												WHEN A.aptrx_trans_type = ''C'' THEN 3
												ELSE 0 END,
				[dblDiscount]			=	A.aptrx_disc_amt,
				[dblWithheld]			=	A.aptrx_wthhld_amt,
				[ysnOrigin]				=	1
			FROM aptrxmst A
				LEFT JOIN apcbkmst B
					ON A.aptrx_cbk_no = B.apcbk_no
				INNER JOIN tblAPVendor D
					ON A.aptrx_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
				WHERE A.aptrx_trans_type IN (''I'',''C'',''A'')
				AND aptrx_orig_amt != 0


			--Posted
			UNION
			SELECT
				[intEntityVendorId]			=	D.intEntityVendorId, 
				--[strVendorId]			=	A.apivc_vnd_no,
				--[strBillId] 			=	A.apivc_ivc_no,
				[strVendorOrderNumber] 	=	A.apivc_ivc_no,
				[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
												WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor 
													WHERE strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
				[intTaxId] 			=	NULL,
				[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmDateCreated] 		=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
				[strReference] 		=	A.apivc_comment,
				[strPONumber]			=	A.apivc_pur_ord_no,
				[dblTotal] 				=	CASE WHEN A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'' THEN A.apivc_orig_amt
												ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END,
				[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
													CASE WHEN A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'' THEN A.apivc_orig_amt
														ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
												END,
				[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.apivc_user_id)),@UserId),
				[ysnPosted]				=	1,
				[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
				[intTransactionType]	=	CASE WHEN A.apivc_trans_type = ''I'' THEN 1
												WHEN A.apivc_trans_type = ''A'' THEN 2
												WHEN A.apivc_trans_type = ''C'' THEN 3
												ELSE 0 END,
				[dblDiscount]			=	A.apivc_disc_avail,
				[dblWithheld]			=	A.apivc_wthhld_amt,
				[ysnOrigin]				=	1
			FROM apivcmst A
				LEFT JOIN apcbkmst B
					ON A.apivc_cbk_no = B.apcbk_no
				INNER JOIN tblAPVendor D
					ON A.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
				WHERE A.apivc_trans_type IN (''I'',''C'',''A'')
				AND A.apivc_orig_amt != 0
				
			SELECT @ImportedRecords = @@ROWCOUNT

			--add detail
			INSERT INTO tblAPBillDetail(
				[intBillId],
				[strMiscDescription],
				[dblQtyOrdered],
				[dblQtyReceived],
				[intAccountId],
				[dblTotal],
				[dblCost],
				[intLineNo]
			)
			SELECT 
				A.intBillId,
				A.strReference,
				1,
				1,
				ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.apegl_gl_acct AS NVARCHAR(MAX))), 0),
				C.apegl_gl_amt,
				C.apegl_gl_amt,
				C.apegl_dist_no
			FROM tblAPBill A
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityVendorId
				INNER JOIN (aptrxmst C2 INNER JOIN apeglmst C 
								ON C2.aptrx_ivc_no = C.apegl_ivc_no 
								AND C2.aptrx_vnd_no = C.apegl_vnd_no
								AND C2.aptrx_cbk_no = C.apegl_cbk_no
								AND C2.aptrx_trans_type = C.apegl_trx_ind)
					ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.aptrx_ivc_no
					AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.aptrx_vnd_no
				ORDER BY C.apegl_dist_no
		
			INSERT INTO tblAPBillDetail(
				[intBillId],
				[strMiscDescription],
				[dblQtyOrdered],
				[dblQtyReceived],
				[intAccountId],
				[dblTotal],
				[dblCost],
				[intLineNo]
			)
			SELECT 
				A.intBillId,
				A.strReference,
				1,
				1,
				ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.aphgl_gl_acct AS NVARCHAR(MAX))), 0),
				C.aphgl_gl_amt,
				C.aphgl_gl_amt,
				C.aphgl_dist_no
				FROM tblAPBill A
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityVendorId
				INNER JOIN (apivcmst C2 INNER JOIN aphglmst C 
							ON C2.apivc_ivc_no = C.aphgl_ivc_no 
							AND C2.apivc_vnd_no = C.aphgl_vnd_no
							AND C2.apivc_cbk_no = C.aphgl_cbk_no
							AND C2.apivc_trans_type = C.aphgl_trx_ind)
					ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.apivc_ivc_no
					AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.apivc_vnd_no
					ORDER BY C.aphgl_dist_no
			--Create Bill Batch transaction
			--SELECT @totalBills = COUNT(*) FROM #InsertedData
			--SELECT * FROM tblAPBill

			WHILE((SELECT TOP 1 1 FROM #InsertedData) IS NOT NULL)
			BEGIN

				SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid, @type = intTransactionType FROM #InsertedData

				
				INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId, dtmBatchDate)
				--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
				SELECT 
					A.intAccountId,
					@IsPosted,
					A.dblTotal,
					@UserId,
					GETDATE()
				FROM tblAPBill A
				WHERE A.intBillId = @BillId

				SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

				IF @type = 1
					EXEC uspSMGetStartingNumber 9, @GeneratedBillId OUT
				ELSE IF @type = 3
					EXEC uspSMGetStartingNumber 18, @GeneratedBillId OUT
				ELSE IF @type = 2
					EXEC uspSMGetStartingNumber 20, @GeneratedBillId OUT
				ELSE
					EXEC uspSMGetStartingNumber 9, @GeneratedBillId OUT

				--UPDATE billbatch of Bill
				UPDATE tblAPBill
					SET intBillBatchId = @BillBatchId, strBillId = @GeneratedBillId
				FROM tblAPBill
				WHERE intBillId = @BillId
				

				DELETE FROM #InsertedData WHERE intBillId = @BillId
			END;

			--SELECT * FROM tblAPBill
			--CREATE PAYMENT

			CREATE TABLE #tmpBillsPayment
			(
				[id] INT IDENTITY(1,1),
				[strCheckBookNo] NVARCHAR(4),
				[strVendorId] NVARCHAR(10),
				[dblAmount] DECIMAL(18,6),
				[dtmDate] DATETIME,
				[strCheckNo] NVARCHAR(16),
				[dblDiscount] DECIMAL(18,6),
				[strPaymentMethod] NVARCHAR(20),
				[strBills] NVARCHAR(MAX),
				CONSTRAINT [PK_dbo.tblAPBill] PRIMARY KEY CLUSTERED ([id] ASC)
			);
		
			CREATE NONCLUSTERED INDEX [IX_tmpBillsPayment_strVendorId] ON #tmpBillsPayment([strVendorId]);

			WITH CTE (apchk_cbk_no, apchk_vnd_no, apchk_chk_amt, apchk_rev_dt, apchk_chk_no, apchk_disc_amt, tranType, intBillId)
			AS (
				SELECT
				A.apchk_cbk_no
				,A.apchk_vnd_no
				,A.apchk_chk_amt
				,A.apchk_rev_dt
				,A.apchk_chk_no
				,A.apchk_disc_amt
				,CASE
					WHEN A.apchk_chk_amt > 0 THEN 
						CASE 
							WHEN LEFT(A.apchk_chk_no, 1) = ''E'' THEN 1
							WHEN LEFT(A.apchk_chk_no, 1) = ''W'' THEN 2
							WHEN A.apchk_trx_ind = ''C'' THEN 3
							ELSE 4
						END
					WHEN A.apchk_chk_amt < 0 THEN 5
				END
				,C.intBillId
				FROM apchkmst A
				LEFT JOIN apivcmst B
				ON A.apchk_vnd_no = B.apivc_vnd_no
				AND A.apchk_chk_no = B.apivc_chk_no
				AND A.apchk_rev_dt = B.apivc_chk_rev_dt
				AND A.apchk_cbk_no = B.apivc_cbk_no
			AND A.apchk_trx_ind <> ''O'' AND A.apchk_chk_amt <> 0
				INNER JOIN (tblAPBill C INNER JOIN tblAPVendor D ON C.intEntityVendorId = D.intEntityVendorId)
					ON B.apivc_ivc_no = C.strVendorOrderNumber COLLATE Latin1_General_CS_AS
					AND B.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
			)
			INSERT INTO #tmpBillsPayment
			SELECT
				A.apchk_cbk_no
				,A.apchk_vnd_no
				,A.apchk_chk_amt
				,CASE WHEN ISDATE(A.apchk_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apchk_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END
				,A.apchk_chk_no
				,A.apchk_disc_amt
				,CASE
					WHEN A.tranType = 1 THEN ''EFT''
					WHEN A.tranType = 2 THEN ''Wire''
					WHEN A.tranType = 3 THEN ''Check''
					WHEN A.tranType = 4 THEN ''Withdrawal''
					WHEN A.tranType = 5 THEN ''Deposit''	
				END
				,STUFF((SELECT '', '' + CAST(B.intBillId AS VARCHAR(10))
					   FROM CTE B
					   WHERE A.apchk_vnd_no = B.apchk_vnd_no
						AND A.apchk_chk_no = B.apchk_chk_no
						AND A.apchk_rev_dt = B.apchk_rev_dt
						AND A.apchk_cbk_no = B.apchk_cbk_no
					   --ORDER BY B.apchk_rev_dt, B.apchk_cbk_no, B.apchk_chk_no
					  FOR XML PATH('''')), 1, 2, '''') AS BillIds
			FROM CTE A
			GROUP BY A.apchk_cbk_no
				,A.apchk_vnd_no
				,A.apchk_chk_amt
				,A.apchk_rev_dt
				,A.apchk_chk_no
				,A.apchk_disc_amt
				,A.tranType
			--ORDER BY A.apchk_rev_dt, A.apchk_cbk_no, A.apchk_chk_no

			--Create Payment Method if not yet exists		
			INSERT INTO tblSMPaymentMethod(strPaymentMethod, ysnActive)
			SELECT 
				DISTINCT
				strPaymentMethod,
				1
			FROM #tmpBillsPayment A
				WHERE NOT EXISTS(SELECT * FROM tblSMPaymentMethod B WHERE B.strPaymentMethod = A.strPaymentMethod COLLATE Latin1_General_CS_AS)
	
			DECLARE @paymentId INT, @paymentKey INT

			WHILE EXISTS(SELECT 1 FROM #tmpBillsPayment)
			BEGIN

				SELECT TOP(1)
					@bankAccount = C.intBankAccountId,
					@intEntityVendorId = B.intEntityVendorId,
					@paymentInfo = A.strCheckNo,
					@payment = A.dblAmount,
					@datePaid = A.dtmDate,
					@paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = A.strPaymentMethod COLLATE Latin1_General_CS_AS),
					@billIds = A.strBills,
					@paymentKey = A.id
				FROM #tmpBillsPayment A
					INNER JOIN tblAPVendor B
						ON A.strVendorId = B.strVendorId COLLATE Latin1_General_CS_AS
					INNER JOIN tblCMBankAccount C
						ON A.strCheckBookNo = C.strCbkNo COLLATE Latin1_General_CS_AS

				EXEC uspAPCreatePayment @userId = @UserId,
						@bankAccount = @bankAccount,
						@paymentMethod = @paymentMethod,
						@paymentInfo = @paymentInfo,
						@notes = @notes,
						@payment = @payment,
						@datePaid = @datePaid,
						@isPost = 1,
						@post = @post,
						@billId = @billIds

				SET @paymentId = IDENT_CURRENT(''tblAPPayment'')

				UPDATE tblAPPayment
				SET ysnOrigin = 1
				WHERE intPaymentId = @paymentId

				DELETE FROM #tmpBillsPayment WHERE id = @paymentKey
			END

			--backup data from aptrxmst on one time synchronization
			INSERT INTO tblAPaptrxmst
			SELECT
				A.[aptrx_vnd_no]       ,
				A.[aptrx_ivc_no]       ,
				A.[aptrx_sys_rev_dt]   ,
				A.[aptrx_sys_time]     ,
				A.[aptrx_cbk_no]       ,
				A.[aptrx_chk_no]       ,
				A.[aptrx_trans_type]   ,
				A.[aptrx_batch_no]     ,
				A.[aptrx_pur_ord_no]   ,
				A.[aptrx_po_rcpt_seq]  ,
				A.[aptrx_ivc_rev_dt]   ,
				A.[aptrx_disc_rev_dt]  ,
				A.[aptrx_due_rev_dt]   ,
				A.[aptrx_chk_rev_dt]   ,
				A.[aptrx_gl_rev_dt]    ,
				A.[aptrx_disc_pct]     ,
				A.[aptrx_orig_amt]     ,
				A.[aptrx_disc_amt]     ,
				A.[aptrx_wthhld_amt]   ,
				A.[aptrx_net_amt]      ,
				A.[aptrx_1099_amt]     ,
				A.[aptrx_comment]      ,
				A.[aptrx_orig_type]    ,
				A.[aptrx_name]         ,
				A.[aptrx_recur_yn]     ,
				A.[aptrx_currency]     ,
				A.[aptrx_currency_rt]  ,
				A.[aptrx_currency_cnt] ,
				A.[aptrx_user_id]      ,
				A.[aptrx_user_rev_dt]
			 FROM aptrxmst A
			DELETE FROM aptrxmst

			--SELECT * FROM tblAPPayment

			--UPDATE strTransactionId from tblCMBankTransaction
			UPDATE tblCMBankTransaction
			SET strTransactionId = B.strPaymentRecordNum,
				intPayeeId = C.intEntityVendorId
			FROM tblCMBankTransaction A
			INNER JOIN tblAPPayment B
				ON A.dblAmount = (CASE WHEN A.intBankTransactionTypeId = 11 THEN (B.dblAmountPaid) * -1 ELSE B.dblAmountPaid END)
				AND A.dtmDate = B.dtmDatePaid
				AND A.intBankAccountId = B.intBankAccountId
				AND A.strReferenceNo = B.strPaymentInfo
			INNER JOIN (tblAPVendor C INNER JOIN tblEntity D ON C.intEntityVendorId = D.intEntityId)
				ON B.intEntityVendorId = C.intEntityVendorId 
				--AND A.strPayee = D.strName
			WHERE A.strSourceSystem = ''AP''
		
			--SELECT * FROM tblCMBankTransaction

			SET @Total = @ImportedRecords;
		END
		ELSE
		BEGIN

			----VALIDATE IF THERE ARE DUPLICATE VENDOR ORDER NUMBER
			--DECLARE @duplicateVendorNumber NVARCHAR(100);
			--SELECT TOP 1 @duplicateVendorNumber = A.aptrx_ivc_no
			--			FROM aptrxmst A
			--			WHERE CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			--			AND A.aptrx_trans_type IN (''I'',''C'',''A'')
			--			AND A.aptrx_orig_amt != 0
			--			AND EXISTS (
			--				SELECT 1
			--				FROM tblAPBill A1
			--				INNER JOIN (tblAPVendor B INNER JOIN tblEntity B1 ON B.intEntityVendorId = B1.intEntityId) ON A1.intEntityVendorId = B.intEntityVendorId
			--				WHERE A.aptrx_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
			--				AND A.aptrx_ivc_no = A1.strVendorOrderNumber COLLATE Latin1_General_CS_AS
			--			)
			--IF @duplicateVendorNumber IS NOT NULL
			--BEGIN
			--	DECLARE @error NVARCHAR(200);
			--	SET @error = ''Duplicate vendor number exists ('' + @duplicateVendorNumber + '')''
			--	RAISERROR(@error, 16, 1);
			--	RETURN;
			--END

			INSERT [dbo].[tblAPBill] (
				[intEntityVendorId], 
				--[strBillId],
				[strVendorOrderNumber], 
				[intTermsId], 
				[intTaxId], 
				[dtmDate], 
				[dtmDateCreated],
				[dtmBillDate], 
				[dtmDueDate], 
				[intAccountId], 
				[strReference], 
				[strPONumber],
				[dblTotal], 
				[dblAmountDue],
				[intEntityId],
				[ysnPosted],
				[ysnPaid],
				[intTransactionType],
				[dblDiscount],
				[dblWithheld],
				[ysnOrigin])
			OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid, inserted.strVendorOrderNumber, inserted.intTransactionType INTO #InsertedData
			--Unposted
			SELECT
				[intEntityVendorId]			=	D.intEntityVendorId,
				--[strVendorId]			=	A.aptrx_vnd_no,
				--[strBillId] 			=	A.aptrx_ivc_no,
				[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
				[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation
													WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor
														WHERE strVendorId COLLATE Latin1_General_CS_AS = A.aptrx_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
				[intTaxId] 			=	NULL,
				[dtmDate] 				=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmDateCreated] 		=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmBillDate] 			=	CASE WHEN ISDATE(A.aptrx_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[dtmDueDate] 			=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
				[strReference] 		=	A.aptrx_comment,
				[strPONumber]			=	A.aptrx_pur_ord_no,
				[dblTotal] 				=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt
												ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
				[dblAmountDue]			=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt
												ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
				[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.aptrx_user_id)),@UserId),
				[ysnPosted]				=	0,
				[ysnPaid] 				=	0,
				[intTransactionType]	=	CASE WHEN A.aptrx_trans_type = ''I'' THEN 1
            												WHEN A.aptrx_trans_type = ''A'' THEN 3
            												WHEN A.aptrx_trans_type = ''C'' THEN 3
            												ELSE NULL END,
				[dblDiscount]			=	A.aptrx_disc_amt,
				[dblWithheld]			=	A.aptrx_wthhld_amt,
				[ysnOrigin]				=	1
			FROM aptrxmst A
				LEFT JOIN apcbkmst B
					ON A.aptrx_cbk_no = B.apcbk_no
				INNER JOIN tblAPVendor D
					ON A.aptrx_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
				--LEFT JOIN tblAPaptrxmst C
				--	ON A.aptrx_ivc_no = C.aptrx_ivc_no
			WHERE CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
				 --AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
				 AND A.aptrx_trans_type IN (''I'',''C'',''A'')
				 AND A.aptrx_orig_amt != 0
		
			SELECT @ImportedRecords = @@ROWCOUNT

			--add detail
			INSERT INTO tblAPBillDetail(
				[intBillId],
				[strMiscDescription],
				[dblQtyOrdered],
				[dblQtyReceived],
				[intAccountId],
				[dblTotal],
				[dblCost],
				[intLineNo]
			)
			SELECT 
				A.intBillId,
				A.strReference,
				1,
				1,
				ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.apegl_gl_acct AS NVARCHAR(MAX))), 0),
				C.apegl_gl_amt,
				C.apegl_gl_amt,
				C.apegl_dist_no
				FROM tblAPBill A
					INNER JOIN tblAPVendor B
						ON A.intEntityVendorId = B.intEntityVendorId
					INNER JOIN (aptrxmst C2 INNER JOIN apeglmst C 
								ON C2.aptrx_ivc_no = C.apegl_ivc_no 
								AND C2.aptrx_vnd_no = C.apegl_vnd_no
								AND C2.aptrx_cbk_no = C.apegl_cbk_no
								AND C2.aptrx_trans_type = C.apegl_trx_ind)
					ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.aptrx_ivc_no
					AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.aptrx_vnd_no
				WHERE CONVERT(DATE, CAST(C2.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
				 AND C2.aptrx_trans_type IN (''I'',''C'',''A'')
				 AND C2.aptrx_orig_amt != 0
				 AND A.ysnPosted = 0
				ORDER BY C.apegl_dist_no
			--UNION
			--SELECT 
			--	A.intBillId,
			--	A.strDescription,
			--	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
			--	C.aphgl_gl_amt
			--	FROM tblAPBill A
			--	INNER JOIN aphglmst C
			--		ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C.aphgl_ivc_no COLLATE Latin1_General_CS_AS
				
			----Create Bill Batch transaction
			--INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId)
			--SELECT 
			--	A.intAccountId,
			--	@IsPosted,
			--	A.dblTotal,
			--	@UserId
			--	FROM tblAPBill A
			--	INNER JOIN #InsertedData B
			--		ON A.intBillId = B.intBillId

			--Add already imported bill
			--SET IDENTITY_INSERT tblAPTempBill ON

			--INSERT INTO tblAPTempBill([apivc_vnd_no], [apivc_ivc_no])
			----SELECT
			----	A.aptrx_vnd_no
			----	,aptrx_ivc_no
			----FROM aptrxmst A
			----INNER JOIN #InsertedData B
			----	ON A.aptrx_ivc_no = B.strBillId
			----UNION
			--SELECT 
			--	A.apivc_vnd_no
			--	,apivc_ivc_no
			--FROM apivcmst A
			--INNER JOIN #InsertedData B
			--	ON A.apivc_ivc_no = B.strVendorOrderNumber
			--SET IDENTITY_INSERT tblAPTempBill OFF
	
				--Create Bill Batch transaction
			SELECT @totalBills = COUNT(*) FROM #InsertedData

			WHILE((SELECT TOP 1 1 FROM #InsertedData) IS NOT NULL)
			BEGIN

				SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid, @type = intTransactionType FROM #InsertedData

				INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId, dtmBatchDate)
				--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
				SELECT 
					A.intAccountId,
					@IsPosted,
					A.dblTotal,
					@UserId,
					GETDATE()
				FROM tblAPBill A
				WHERE A.intBillId = @BillId

				SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

				IF @type = 1
					EXEC uspSMGetStartingNumber 9, @GeneratedBillId OUT
				ELSE IF @type = 3
					EXEC uspSMGetStartingNumber 18, @GeneratedBillId OUT
				ELSE IF @type = 2
					EXEC uspSMGetStartingNumber 20, @GeneratedBillId OUT

				--UPDATE billbatch of Bill
				UPDATE tblAPBill
					SET intBillBatchId = @BillBatchId, strBillId = @GeneratedBillId
				FROM tblAPBill
				WHERE intBillId = @BillId

				DELETE FROM #InsertedData WHERE intBillId = @BillId
			END;
		
			SET @Total = @ImportedRecords;
		END

		ALTER TABLE tblAPBill
			ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

		--backup data from aptrxmst on one time synchronization
			INSERT INTO tblAPaptrxmst
			SELECT
				A.[aptrx_vnd_no]       ,
				A.[aptrx_ivc_no]       ,
				A.[aptrx_sys_rev_dt]   ,
				A.[aptrx_sys_time]     ,
				A.[aptrx_cbk_no]       ,
				A.[aptrx_chk_no]       ,
				A.[aptrx_trans_type]   ,
				A.[aptrx_batch_no]     ,
				A.[aptrx_pur_ord_no]   ,
				A.[aptrx_po_rcpt_seq]  ,
				A.[aptrx_ivc_rev_dt]   ,
				A.[aptrx_disc_rev_dt]  ,
				A.[aptrx_due_rev_dt]   ,
				A.[aptrx_chk_rev_dt]   ,
				A.[aptrx_gl_rev_dt]    ,
				A.[aptrx_disc_pct]     ,
				A.[aptrx_orig_amt]     ,
				A.[aptrx_disc_amt]     ,
				A.[aptrx_wthhld_amt]   ,
				A.[aptrx_net_amt]      ,
				A.[aptrx_1099_amt]     ,
				A.[aptrx_comment]      ,
				A.[aptrx_orig_type]    ,
				A.[aptrx_name]         ,
				A.[aptrx_recur_yn]     ,
				A.[aptrx_currency]     ,
				A.[aptrx_currency_rt]  ,
				A.[aptrx_currency_cnt] ,
				A.[aptrx_user_id]      ,
				A.[aptrx_user_rev_dt]
			 FROM aptrxmst A
			 WHERE CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
				 --AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
				 AND A.aptrx_trans_type IN (''I'',''C'',''A'')

			DELETE FROM aptrxmst
			WHERE CONVERT(DATE, CAST(aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
				 --AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
				 AND aptrx_trans_type IN (''I'',''C'',''A'')
	END
	')
END