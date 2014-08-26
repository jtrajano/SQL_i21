GO

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

	--CREATE TEMP TABLE TO BYPASS EXECUTING FIXING STARTING NUMBERS
	SELECT @@ROWCOUNT AS TestColumn INTO #tblTempAPByPassFixStartingNumber

	DECLARE @InsertedData TABLE (intBillId INT, strBillId NVARCHAR(100), ysnPosted BIT, ysnPaid BIT, strVendorOrderNumber NVARCHAR(50))
	DECLARE @insertedBillBatch TABLE(intBillBatchId INT, intBillId INT)
	DECLARE @totalBills INT
	DECLARE @BillId INT
	DECLARE @BillBatchId INT
	DECLARE @ImportedRecords INT
	DECLARE @IsPosted BIT
	DECLARE @IsPaid BIT

	--Validation
	--Check if there is a payment method with a type of ''Check''
	IF NOT EXISTS(SELECT 1 FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Check'')
	BEGIN
		RAISERROR(''Please create Check payment method before importing bills.'', 16, 1);
		RETURN;
	END

	--Check if there is check book that was not exists on tblCMBankAccount
	IF EXISTS(SELECT 1 FROM apchkmst A 
				LEFT JOIN tblCMBankAccount B
					ON A.apchk_cbk_no COLLATE Latin1_General_CI_AS = B.strCbkNo COLLATE Latin1_General_CI_AS
				WHERE B.strCbkNo IS NULL)
	BEGIN
		RAISERROR(''There is a check book number that was not imported.'', 16, 1);
		RETURN;
	END

	--Payment variable
	DECLARE @bankAccount INT,
				@paymentMethod INT,
				@intVendorId INT,
				@paymentInfo NVARCHAR(10),
				@notes NVARCHAR(500),
				@payment DECIMAL(18, 6) = NULL,
				@datePaid DATETIME = NULL,
				@post BIT = 0,
				@discount DECIMAL(18,6) = 0,
				@interest DECIMAL(18,6) = 0,
				@withHeld DECIMAL(18,6) = 0,
				@billIds NVARCHAR(MAX)

	--Create table that holds all the imported transaction
--	IF(OBJECT_ID(''dbo.tblAPTempBill'') IS NULL)
--	BEGIN
--        EXEC(''
--        --SELECT aptrx_vnd_no, aptrx_ivc_no INTO tblAPTempBill FROM aptrxmst WHERE aptrx_trans_type IN (''''I'''',''''C'''')
--
--		--INSERT INTO tblAPTempBill
--		--SELECT apivc_vnd_no, apivc_ivc_no FROM apivcmst WHERE apivc_trans_type IN (''''I'''',''''C'''')
--		SELECT apivc_vnd_no, apivc_ivc_no INTO tblAPTempBill FROM apivcmst WHERE apivc_trans_type IN (''''I'''',''''C'''')
--		'')
--
--	END

	IF(@DateFrom IS NULL AND @PeriodFrom IS NULL)
	BEGIN
		INSERT INTO [dbo].[tblAPBill] (
			[intVendorId],
			--[strVendorId], 
			--[strBillId],
			[strVendorOrderNumber], 
			[intTermsId], 
			[intTaxId], 
			[dtmDate], 
			[dtmBillDate],
			[dtmDueDate], 
			[intAccountId], 
			[strDescription], 
			[dblTotal], 
			[dblAmountDue],
			[intEntityId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType],
			[dblDiscount],
			[dblWithheld],
			[ysnOrigin])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid, inserted.strVendorOrderNumber INTO @InsertedData
		--Unposted
		SELECT
			[intVendorId]			=	D.intVendorId,
			--[strVendorId]			=	A.aptrx_vnd_no,
			--[strBillId] 			=	A.aptrx_ivc_no,
			[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.aptrx_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.aptrx_comment,
			[dblTotal] 				=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
            [intEntityId]				=	@UserId,
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
				ON A.aptrx_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
			WHERE A.aptrx_trans_type IN (''I'',''C'',''A'')


		--Posted
		UNION
		SELECT
			[intVendorId]			=	D.intVendorId, 
			--[strVendorId]			=	A.apivc_vnd_no,
			--[strBillId] 			=	A.apivc_ivc_no,
			[strVendorOrderNumber] 	=	A.apivc_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.apivc_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.apivc_comment,
			[dblTotal] 				=	CASE WHEN A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'' THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
												CASE WHEN A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'' THEN A.apivc_orig_amt * -1
														ELSE A.apivc_orig_amt END
											END,
			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.apivc_user_id) COLLATE Latin1_General_CI_AS),@UserId),
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
				ON A.apivc_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
			WHERE A.apivc_trans_type IN (''I'',''C'',''A'')
				
		SELECT @ImportedRecords = @@ROWCOUNT

		--add detail
		INSERT INTO tblAPBillDetail(
			[intBillId],
			[strDescription],
			[intAccountId],
			[dblTotal]
		)
		SELECT 
			A.intBillId,
			A.strDescription,
			ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.apegl_gl_acct), 0),
			C.apegl_gl_amt
		FROM tblAPBill A
			INNER JOIN tblAPVendor B
				ON A.intVendorId = B.intVendorId
			INNER JOIN apeglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS
				AND B.strVendorId COLLATE Latin1_General_CI_AS = C.apegl_vnd_no COLLATE Latin1_General_CI_AS
		UNION
		SELECT 
			A.intBillId,
			A.strDescription,
			ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
			C.aphgl_gl_amt
			FROM tblAPBill A
			INNER JOIN tblAPVendor B
				ON A.intVendorId = B.intVendorId
			INNER JOIN aphglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aphgl_ivc_no COLLATE Latin1_General_CI_AS
				AND B.strVendorId COLLATE Latin1_General_CI_AS = C.aphgl_vnd_no COLLATE Latin1_General_CI_AS

		--Create Bill Batch transaction
		--SELECT @totalBills = COUNT(*) FROM @InsertedData

		WHILE((SELECT TOP 1 1 FROM @InsertedData) IS NOT NULL)
		BEGIN

			SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid FROM @InsertedData

			INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId)
			--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
			SELECT 
				A.intAccountId,
				@IsPosted,
				A.dblTotal,
				@UserId
			FROM tblAPBill A
			WHERE A.intBillId = @BillId

			SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

			--UPDATE billbatch of Bill
			UPDATE tblAPBill
				SET intBillBatchId = @BillBatchId
			FROM tblAPBill
			WHERE intBillId = @BillId

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END;

		--CREATE PAYMENT

		WITH CTE (apchk_cbk_no, apchk_vnd_no, apchk_chk_amt, apchk_rev_dt, apchk_chk_no, apchk_disc_amt, intBillId)
		AS (
			SELECT
			A.apchk_cbk_no
			,A.apchk_vnd_no
			,A.apchk_chk_amt
			,A.apchk_rev_dt
			,A.apchk_chk_no
			,A.apchk_disc_amt
			,C.intBillId
			--,B.apivc_orig_amt
			FROM apchkmst A
			LEFT JOIN apivcmst B
			ON A.apchk_vnd_no = B.apivc_vnd_no
			AND A.apchk_chk_no = B.apivc_chk_no
			AND A.apchk_rev_dt = B.apivc_chk_rev_dt
			AND A.apchk_cbk_no = B.apivc_cbk_no
		AND A.apchk_trx_ind <> ''O''
			INNER JOIN (tblAPBill C INNER JOIN tblAPVendor D ON C.intVendorId = D.intVendorId)
				ON B.apivc_ivc_no COLLATE Latin1_General_CI_AS = C.strVendorOrderNumber COLLATE Latin1_General_CI_AS
				AND B.apivc_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
			--ORDER BY A.apchk_rev_dt, A.apchk_cbk_no, A.apchk_chk_no
		)
		SELECT
			A.apchk_cbk_no
			,A.apchk_vnd_no
			,A.apchk_chk_amt
			,A.apchk_rev_dt
			,A.apchk_chk_no
			,A.apchk_disc_amt
			,STUFF((SELECT '', '' + CAST(B.intBillId AS VARCHAR(10))
				   FROM CTE B
				   WHERE A.apchk_vnd_no = B.apchk_vnd_no
					AND A.apchk_chk_no = B.apchk_chk_no
					AND A.apchk_rev_dt = B.apchk_rev_dt
					AND A.apchk_cbk_no = B.apchk_cbk_no
				   --ORDER BY B.apchk_rev_dt, B.apchk_cbk_no, B.apchk_chk_no
				  FOR XML PATH('''')), 1, 2, '''') AS BillIds
		INTO #tmpBillsPayment
		FROM CTE A
		GROUP BY A.apchk_cbk_no
			,A.apchk_vnd_no
			,A.apchk_chk_amt
			,A.apchk_rev_dt
			,A.apchk_chk_no
			,A.apchk_disc_amt
		--ORDER BY A.apchk_rev_dt, A.apchk_cbk_no, A.apchk_chk_no

		DECLARE @paymentId INT

		WHILE EXISTS(SELECT 1 FROM #tmpBillsPayment)
		BEGIN

			SELECT TOP 1
				@bankAccount = C.intBankAccountId,
				@intVendorId = B.intVendorId,
				@paymentInfo = A.apchk_chk_no,
				@payment = A.apchk_chk_amt,
				@datePaid = CASE WHEN ISDATE(A.apchk_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apchk_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
				@paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Check''),
				@billIds = A.BillIds
			FROM #tmpBillsPayment A
				INNER JOIN tblAPVendor B
					ON A.apchk_vnd_no COLLATE Latin1_General_CI_AS = B.strVendorId COLLATE Latin1_General_CI_AS
				INNER JOIN tblCMBankAccount C
					ON A.apchk_cbk_no COLLATE Latin1_General_CI_AS = C.strCbkNo COLLATE Latin1_General_CI_AS

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

			DELETE TOP(1) FROM #tmpBillsPayment

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

		--UPDATE strTransactionId from tblCMBankTransaction
		UPDATE tblCMBankTransaction
		SET strTransactionId = B.strPaymentRecordNum,
			intPayeeId = C.intEntityId
		FROM tblCMBankTransaction A
		INNER JOIN tblAPPayment B
			ON A.dblAmount = B.dblAmountPaid
			AND A.dtmDate = B.dtmDatePaid
			AND A.intBankAccountId = B.intBankAccountId
			AND A.strReferenceNo = B.strPaymentInfo
		INNER JOIN tblAPVendor C
			ON B.intVendorId = C.intVendorId

		SET @Total = @ImportedRecords;
	END
	ELSE
	BEGIN
		INSERT [dbo].[tblAPBill] (
			[intVendorId], 
			--[strBillId],
			[strVendorOrderNumber], 
			[intTermsId], 
			[intTaxId], 
			[dtmDate], 
			[dtmBillDate], 
			[dtmDueDate], 
			[intAccountId], 
			[strDescription], 
			[dblTotal], 
			[dblAmountDue],
			[intEntityId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType],
			[dblDiscount],
			[dblWithheld],
			[ysnOrigin])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid, inserted.strVendorOrderNumber INTO @InsertedData
		--Unposted
		SELECT
			[intVendorId]			=	D.intVendorId,
			--[strVendorId]			=	A.aptrx_vnd_no,
			--[strBillId] 			=	A.aptrx_ivc_no,
			[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.aptrx_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.aptrx_comment,
			[dblTotal] 				=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.aptrx_user_id) COLLATE Latin1_General_CI_AS),@UserId),
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
				ON A.aptrx_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
            LEFT JOIN tblAPaptrxmst C
                ON A.aptrx_ivc_no = C.aptrx_ivc_no
		WHERE CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
			 AND A.aptrx_trans_type IN (''I'',''C'',''A'')
			 AND C.aptrx_ivc_no IS NULL

			--Posted
--		UNION
--		SELECT
--			[intVendorId]			=	D.intVendorId,
--			--[strVendorId]			=	A.apivc_vnd_no,
--			--[strBillId] 			=	A.apivc_ivc_no,
--			[strVendorOrderNumber] 	=	A.apivc_ivc_no,
--			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation
--												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor
--													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.apivc_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
--			[intTaxId] 			=	NULL,
--			[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
--			[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
--			[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
--			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
--			[strDescription] 		=	A.apivc_comment,
--			[dblTotal] 				=	(CASE WHEN A.apivc_trans_type = ''C'' THEN (A.apivc_orig_amt * -1) ELSE A.apivc_orig_amt END),
--			[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE
--										(CASE WHEN A.apivc_trans_type = ''C'' THEN (A.apivc_orig_amt * -1) ELSE A.apivc_orig_amt END)
--										END,
--			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.apivc_user_id) COLLATE Latin1_General_CI_AS),@UserId),
--			[ysnPosted]				=	1,
--			[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
--			[intTransactionType]	=	(CASE WHEN A.apivc_trans_type = ''C'' THEN 3 ELSE 1 END),
--			[dblDiscount]			=	A.apivc_disc_avail,
--			[dblWithheld]			=	A.apivc_wthhld_amt
--		FROM apivcmst A
--			LEFT JOIN apcbkmst B
--				ON A.apivc_cbk_no = B.apcbk_no
--			INNER JOIN tblAPVendor D
--				ON A.apivc_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
--			LEFT JOIN tblAPBill E
--				ON D.intVendorId  = E.intVendorId
--				AND A.apivc_ivc_no COLLATE Latin1_General_CI_AS = E.strVendorOrderNumber COLLATE Latin1_General_CI_AS
--
--		WHERE CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
--			 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
--			 AND A.apivc_trans_type IN (''I'',''C'')
--			 AND E.strVendorOrderNumber IS NULL
		
			SELECT @ImportedRecords = @@ROWCOUNT

		--add detail
		INSERT INTO tblAPBillDetail(
			[intBillId],
			[strDescription],
			[intAccountId],
			[dblTotal]
		)
		SELECT 
			A.intBillId,
			A.strDescription,
			ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.apegl_gl_acct), 0),
			C.apegl_gl_amt
			FROM tblAPBill A
				INNER JOIN tblAPVendor B
					ON A.intVendorId = B.intVendorId
				INNER JOIN apeglmst C
					ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS
					AND B.strVendorId COLLATE Latin1_General_CI_AS = C.apegl_vnd_no COLLATE Latin1_General_CI_AS
		--UNION
		--SELECT 
		--	A.intBillId,
		--	A.strDescription,
		--	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
		--	C.aphgl_gl_amt
		--	FROM tblAPBill A
		--	INNER JOIN aphglmst C
		--		ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aphgl_ivc_no COLLATE Latin1_General_CI_AS
				
		----Create Bill Batch transaction
		--INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId)
		--SELECT 
		--	A.intAccountId,
		--	@IsPosted,
		--	A.dblTotal,
		--	@UserId
		--	FROM tblAPBill A
		--	INNER JOIN @InsertedData B
		--		ON A.intBillId = B.intBillId

		--Add already imported bill
		--SET IDENTITY_INSERT tblAPTempBill ON

		--INSERT INTO tblAPTempBill([apivc_vnd_no], [apivc_ivc_no])
		----SELECT
		----	A.aptrx_vnd_no
		----	,aptrx_ivc_no
		----FROM aptrxmst A
		----INNER JOIN @InsertedData B
		----	ON A.aptrx_ivc_no = B.strBillId
		----UNION
		--SELECT 
		--	A.apivc_vnd_no
		--	,apivc_ivc_no
		--FROM apivcmst A
		--INNER JOIN @InsertedData B
		--	ON A.apivc_ivc_no = B.strVendorOrderNumber
		--SET IDENTITY_INSERT tblAPTempBill OFF
	
			--Create Bill Batch transaction
		SELECT @totalBills = COUNT(*) FROM @InsertedData

		WHILE((SELECT TOP 1 1 FROM @InsertedData) IS NOT NULL)
		BEGIN

			SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid FROM @InsertedData

			INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId)
			--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
			SELECT 
				A.intAccountId,
				@IsPosted,
				A.dblTotal,
				@UserId
			FROM tblAPBill A
			WHERE A.intBillId = @BillId

			SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

			--UPDATE billbatch of Bill
			UPDATE tblAPBill
				SET intBillBatchId = @BillBatchId
			FROM tblAPBill
			WHERE intBillId = @BillId

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END;
		
		SET @Total = @ImportedRecords;
	END
END
	')
END