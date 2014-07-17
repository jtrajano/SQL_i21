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

	DECLARE @InsertedData TABLE (intBillId INT, strBillId NVARCHAR(100), ysnPosted BIT, ysnPaid BIT)
	DECLARE @insertedBillBatch TABLE(intBillBatchId INT, intBillId INT)
	DECLARE @totalBills INT
	DECLARE @BillId INT
	DECLARE @BillBatchId INT
	DECLARE @ImportedRecords INT
	DECLARE @IsPosted BIT
	DECLARE @IsPaid BIT
	
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
				@billId int

	--Create table that holds all the imported transaction
	IF(OBJECT_ID(''dbo.tblAPTempBill'') IS NULL)
	BEGIN

		EXEC(''
		SELECT aptrx_vnd_no, aptrx_ivc_no INTO tblAPTempBill FROM aptrxmst WHERE aptrx_trans_type IN (''''I'''',''''C'''')

		INSERT INTO tblAPTempBill
		SELECT apivc_vnd_no, apivc_ivc_no FROM apivcmst WHERE apivc_trans_type IN (''''I'''',''''C'''')
		'')
		
	END
	
	IF(@DateFrom IS NULL AND @PeriodFrom IS NULL)
	BEGIN
		INSERT INTO [dbo].[tblAPBill] (
			[strVendorId], 
			--[strBillId],
			[strVendorOrderNumber], 
			[intTermsId], 
			[intTaxCodeId], 
			[dtmDate], 
			[dtmBillDate],
			[dtmDueDate], 
			[intAccountId], 
			[strDescription], 
			[dblTotal], 
			[dblAmountDue],
			[intUserId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid INTO @InsertedData
		--Unposted
		SELECT 
			[strVendorId]			=	A.aptrx_vnd_no,
			[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.aptrx_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.aptrx_comment,
			[dblTotal] 				=	CASE WHEN A.aptrx_trans_type = ''C'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.aptrx_trans_type = ''C'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[intUserId]				=	@UserId,
			[ysnPosted]				=	0,
			[ysnPaid]				=	0,
			[intTransactionType]	=	CASE WHEN A.aptrx_trans_type = ''I'' THEN 1 
											WHEN A.aptrx_trans_type = ''C'' THEN 3
											ELSE 0 END
		FROM aptrxmst A
			LEFT JOIN apcbkmst B
				ON A.aptrx_cbk_no = B.apcbk_no
		WHERE A.aptrx_trans_type IN (''I'',''C'')
		--Posted
		UNION
		SELECT 
			[strVendorId]			=	A.apivc_vnd_no,
			[strVendorOrderNumber] 	=	A.apivc_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.apivc_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.apivc_comment,
			[dblTotal] 				=	CASE WHEN A.apivc_trans_type = ''C'' THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
												CASE WHEN A.apivc_trans_type = ''C'' THEN A.apivc_orig_amt * -1 
														ELSE A.apivc_orig_amt END 
											END,
			[intUserId]				=	@UserId,
			[ysnPosted]				=	1,
			[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
			[intTransactionType]	=	CASE WHEN A.apivc_trans_type = ''I'' THEN 1 
											WHEN A.apivc_trans_type = ''C'' THEN 3
											ELSE 0 END
		FROM apivcmst A
			LEFT JOIN apcbkmst B
				ON A.apivc_cbk_no = B.apcbk_no
		WHERE A.apivc_trans_type IN (''I'',''C'')

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
			INNER JOIN apeglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS
		UNION
		SELECT 
			A.intBillId,
			A.strDescription,
			ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
			C.aphgl_gl_amt
			FROM tblAPBill A
			INNER JOIN aphglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aphgl_ivc_no COLLATE Latin1_General_CI_AS

		--Create Bill Batch transaction
		--SELECT @totalBills = COUNT(*) FROM @InsertedData

		WHILE((SELECT TOP 1 1 FROM @InsertedData) IS NOT NULL)
		BEGIN

			SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid FROM @InsertedData

			INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intUserId)
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
			
			--CREATE PAYMENT
			IF (@IsPaid = 1)
			BEGIN
				
				SELECT 
					@bankAccount = D.intBankAccountId,
					@intVendorId = E.intEntityId,
					@paymentInfo = B.apivc_chk_no,
					@payment = A.dblTotal,
					@datePaid = A.dtmDatePaid,
					@billId = A.intBillId,
					@paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Check'')
          		FROM tblAPBill A
					INNER JOIN tblAPVendor E
						ON A.strVendorId = E.strVendorId
					INNER JOIN apivcmst B
						ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
					LEFT JOIN apcbkmst C
						ON B.apivc_cbk_no = C.apcbk_no
					LEFT JOIN tblCMBankAccount D
						ON C.apcbk_no COLLATE Latin1_General_CI_AS = D.strCbkNo COLLATE Latin1_General_CI_AS
				WHERE intBillId = @BillId

				EXEC uspAPCreatePayment @userId = @UserId, 
						@bankAccount = @bankAccount, 
						@paymentMethod = @paymentMethod, 
						@intVendorId = @intVendorId, 
						@paymentInfo = @paymentInfo,
						@notes = @notes,
						@payment = @payment,
						@datePaid = @datePaid,
						@isPost = 1,
						@post = @post,
						@discount = @discount,
						@interest =@interest,
						@withHeld = @withHeld,
						@billId = @billId
			END

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END

		SET @Total = @ImportedRecords;
	END
	ELSE
	BEGIN
		INSERT [dbo].[tblAPBill] (
			[strVendorId], 
			--[strBillId],
			[strVendorOrderNumber], 
			[intTermsId], 
			[intTaxCodeId], 
			[dtmDate], 
			[dtmBillDate], 
			[dtmDueDate], 
			[intAccountId], 
			[strDescription], 
			[dblTotal], 
			[dblAmountDue],
			[intUserId],
			[ysnPosted],
			[ysnPaid],
			[intTransactionType])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid INTO @InsertedData
		--Unposted
		SELECT 
			[strVendorId]			=	A.aptrx_vnd_no,
			--[strBillId] 			=	A.aptrx_ivc_no,
			[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.aptrx_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.aptrx_comment,
			[dblTotal] 				=	CASE WHEN A.aptrx_trans_type = ''C'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.aptrx_trans_type = ''C'' THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END,
			[intUserId]				=	@UserId,
			[ysnPosted]				=	0,
			[ysnPaid] 				=	0,
			[intTransactionType]	=	CASE WHEN A.aptrx_trans_type = ''I'' THEN 1 
											WHEN A.aptrx_trans_type = ''C'' THEN 3
											ELSE NULL END
		FROM aptrxmst A
			LEFT JOIN apcbkmst B
				ON A.aptrx_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.aptrx_ivc_no = C.aptrx_ivc_no
			
		WHERE CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
			 AND A.aptrx_trans_type IN (''I'',''C'')
			 AND C.aptrx_ivc_no IS NULL
			--Posted
		UNION
		SELECT 
			[strVendorId]			=	A.apivc_vnd_no,
			[strVendorOrderNumber] 	=	A.apivc_ivc_no,
			[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
												WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
													WHERE strVendorId COLLATE Latin1_General_CI_AS = A.apivc_vnd_no COLLATE Latin1_General_CI_AS)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.apivc_comment,
			[dblTotal] 				=	CASE WHEN A.apivc_trans_type = ''C'' THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END,
			[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
												CASE WHEN A.apivc_trans_type = ''C'' THEN A.apivc_orig_amt * -1 
														ELSE A.apivc_orig_amt END 
											END,
			[intUserId]				=	@UserId,
			[ysnPosted]				=	1,
			[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
			[intTransactionType]	=	CASE WHEN A.apivc_trans_type = ''I'' THEN 1 
											WHEN A.apivc_trans_type = ''C'' THEN 3
											ELSE NULL END
		FROM apivcmst A
			LEFT JOIN apcbkmst B
				ON A.apivc_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.apivc_ivc_no = C.aptrx_ivc_no

		WHERE CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
			 AND A.apivc_trans_type IN (''I'',''C'')
			 AND C.aptrx_ivc_no IS NULL
		
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
			INNER JOIN apeglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS
		UNION
		SELECT 
			A.intBillId,
			A.strDescription,
			ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.aphgl_gl_acct), 0),
			C.aphgl_gl_amt
			FROM tblAPBill A
			INNER JOIN aphglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.aphgl_ivc_no COLLATE Latin1_General_CI_AS
				
		--Add already imported bill
		SET IDENTITY_INSERT tblAPTempBill ON
		INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no])
		SELECT 
			A.aptrx_vnd_no
			,aptrx_ivc_no	 
		FROM aptrxmst A
		INNER JOIN @InsertedData B
			ON A.aptrx_ivc_no = B.strBillId
		UNION
		SELECT 
			A.apivc_vnd_no
			,apivc_ivc_no	 
		FROM apivcmst A
		INNER JOIN @InsertedData B
			ON A.apivc_ivc_no = B.strBillId
		SET IDENTITY_INSERT tblAPTempBill OFF

		--Create Bill Batch transaction
		SELECT @totalBills = COUNT(*) FROM @InsertedData

		WHILE((SELECT TOP 1 1 FROM @InsertedData) IS NOT NULL)
		BEGIN

			SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid FROM @InsertedData

			INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal)
			--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
			SELECT 
				A.intAccountId,
				@IsPosted,
				A.dblTotal
			FROM tblAPBill A
			WHERE A.intBillId = @BillId

			SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

			--UPDATE billbatch of Bill
			UPDATE tblAPBill
				SET intBillBatchId = @BillBatchId
			FROM tblAPBill
			WHERE intBillId = @BillId

			--CREATE PAYMENT
			IF (@IsPaid = 1)
			BEGIN
				
				SELECT 
					@bankAccount = D.intBankAccountId,
					@intVendorId = E.intEntityId,
					@paymentInfo = B.apivc_chk_no,
					@payment = A.dblTotal,
					@datePaid = A.dtmDatePaid,
					@billId = A.intBillId,
					@paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE strPaymentMethod = ''Check'')
          		FROM tblAPBill A
					INNER JOIN tblAPVendor E
						ON A.strVendorId = E.strVendorId
					INNER JOIN apivcmst B
						ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = B.apivc_ivc_no COLLATE Latin1_General_CI_AS
					LEFT JOIN apcbkmst C
						ON B.apivc_cbk_no = C.apcbk_no
					LEFT JOIN tblCMBankAccount D
						ON C.apcbk_no COLLATE Latin1_General_CI_AS = D.strCbkNo COLLATE Latin1_General_CI_AS
				WHERE intBillId = @BillId

				EXEC uspAPCreatePayment @userId = @UserId, 
						@bankAccount = @bankAccount, 
						@paymentMethod = @paymentMethod, 
						@intVendorId = @intVendorId, 
						@paymentInfo = @paymentInfo,
						@notes = @notes,
						@payment = @payment,
						@datePaid = @datePaid,
						@isPost = 1,
						@post = @post,
						@discount = @discount,
						@interest =@interest,
						@withHeld = @withHeld,
						@billId = @billId
			END

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END
	
		SET @Total = @ImportedRecords;
	END


	END

	')
END
