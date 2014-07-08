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

	--Create table that holds all the imported transaction
	IF(OBJECT_ID(''dbo.tblAPTempBill'') IS NULL)
		SELECT * INTO tblAPTempBill FROM aptrxmst WHERE aptrxmst.aptrx_ivc_no IS NULL

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
			[dblWithheld])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid INTO @InsertedData
		--Unposted
		SELECT 
			[intVendorId]			=	D.intEntityId,
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
			[dblTotal] 				=	(CASE WHEN A.aptrx_trans_type = ''C'' THEN (A.aptrx_orig_amt * -1) ELSE A.aptrx_orig_amt END),
			[dblAmountDue]			=	(CASE WHEN A.aptrx_trans_type = ''C'' THEN (A.aptrx_orig_amt * -1) ELSE A.aptrx_orig_amt END),
			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.aptrx_user_id) COLLATE Latin1_General_CI_AS),@UserId),
			[ysnPosted]				=	0,
			[ysnPaid]				=	0,
			[intTransactionType]	=	(CASE WHEN A.aptrx_trans_type = ''C'' THEN 3 ELSE 1 END),
			[dblDiscount]			=	A.aptrx_disc_amt,
			[dblWithheld]			=	A.aptrx_wthhld_amt
		FROM aptrxmst A
			--LEFT JOIN apeglmst B
			--	ON A.aptrx_ivc_no = B.apegl_ivc_no
			LEFT JOIN apcbkmst B
				ON A.aptrx_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.aptrx_ivc_no = C.aptrx_ivc_no
			INNER JOIN tblAPVendor D
				ON A.aptrx_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
			WHERE C.aptrx_ivc_no IS NULL AND A.aptrx_trans_type IN (''I'',''C'')

			--GROUP BY A.aptrx_ivc_no, 
			--A.aptrx_vnd_no, 
			--A.aptrx_sys_rev_dt,
			--A.aptrx_gl_rev_dt,
			--A.aptrx_due_rev_dt,
			--A.aptrx_comment,
			--A.aptrx_orig_amt,
			--B.apcbk_gl_ap
		--Posted
		UNION
		SELECT
			[intVendorId]			=	D.intEntityId, 
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
			[dblTotal] 				=	(CASE WHEN A.apivc_trans_type = ''C'' THEN (A.apivc_orig_amt * -1) ELSE A.apivc_orig_amt END),
			[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
										(CASE WHEN A.apivc_trans_type = ''C'' THEN (A.apivc_orig_amt * -1) ELSE A.apivc_orig_amt END)
										 END,
			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.apivc_user_id) COLLATE Latin1_General_CI_AS),@UserId),
			[ysnPosted]				=	1,
			[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
			[intTransactionType]	=	(CASE WHEN A.apivc_trans_type = ''C'' THEN 3 ELSE 1 END),
			[dblDiscount]			=	A.apivc_disc_avail,
			[dblWithheld]			=	A.apivc_wthhld_amt
		FROM apivcmst A
			LEFT JOIN apcbkmst B
				ON A.apivc_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.apivc_ivc_no = C.aptrx_ivc_no
			INNER JOIN tblAPVendor D
				ON A.apivc_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
			WHERE C.aptrx_ivc_no IS NULL AND A.apivc_trans_type IN (''I'',''C'')
				
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
		INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no], [aptrx_sys_rev_dt], [aptrx_sys_time], [aptrx_cbk_no], [aptrx_chk_no], [aptrx_trans_type], [aptrx_batch_no],
		[aptrx_pur_ord_no], [aptrx_po_rcpt_seq], [aptrx_ivc_rev_dt], [aptrx_disc_rev_dt], [aptrx_due_rev_dt], [aptrx_chk_rev_dt], [aptrx_gl_rev_dt], [aptrx_disc_pct], [aptrx_orig_amt],
		[aptrx_disc_amt], [aptrx_wthhld_amt], [aptrx_net_amt], [aptrx_1099_amt], [aptrx_comment], [aptrx_orig_type], [aptrx_name], [aptrx_recur_yn], [aptrx_currency], [aptrx_currency_rt],
		[aptrx_currency_cnt], [aptrx_user_id], [aptrx_user_rev_dt], [A4GLIdentity])
		SELECT 
			A.* 
		FROM aptrxmst A
		INNER JOIN @InsertedData B
			ON A.aptrx_ivc_no = B.strBillId
		SET IDENTITY_INSERT tblAPTempBill OFF

			
		--Create Bill Batch transaction
		--SELECT @totalBills = COUNT(*) FROM @InsertedData

		WHILE((SELECT TOP 1 1 FROM @InsertedData) IS NOT NULL)
		BEGIN

			SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted FROM @InsertedData

			INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId)
			--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
			SELECT 
				A.intAccountId,
				@IsPosted,
				A.dblTotal,
				A.intEntityId
			FROM tblAPBill A
			WHERE A.intBillId = @BillId

			SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

			--UPDATE billbatch of Bill
			UPDATE tblAPBill
				SET intBillBatchId = @BillBatchId
			FROM tblAPBill
			WHERE intBillId = @BillId

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END

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
			[dblWithheld])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted, inserted.ysnPaid INTO @InsertedData
		--Unposted
		SELECT
			[intVendorId]			=	D.intEntityId,  
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
			[dblTotal] 				=	A.aptrx_orig_amt,
			[dblAmountDue]			=	A.aptrx_orig_amt,--CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.aptrx_user_id) COLLATE Latin1_General_CI_AS),@UserId),
			[ysnPosted]				=	0,
			[ysnPaid] 				=	0,
			[intTransactionType]	=	(CASE WHEN A.aptrx_trans_type = ''C'' THEN 3 ELSE 1 END),
			[dblDiscount]			=	A.aptrx_disc_amt,
			[dblWithheld]			=	A.aptrx_wthhld_amt
		FROM aptrxmst A
			--LEFT JOIN apeglmst B
			--	ON A.aptrx_ivc_no = B.apegl_ivc_no
			LEFT JOIN apcbkmst B
				ON A.aptrx_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.aptrx_ivc_no = C.aptrx_ivc_no
			INNER JOIN tblAPVendor D
				ON A.aptrx_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
		WHERE --CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			 CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			 AND CONVERT(INT,SUBSTRING(CONVERT(VARCHAR(8), CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112), 3), 4, 2)) BETWEEN @PeriodFrom AND @PeriodTo
			 AND A.aptrx_trans_type IN (''I'',''C'')
			 AND C.aptrx_ivc_no IS NULL

			--GROUP BY A.aptrx_ivc_no, 
			--A.aptrx_vnd_no, 
			--A.aptrx_sys_rev_dt,
			--A.aptrx_gl_rev_dt,
			--A.aptrx_due_rev_dt,
			--A.aptrx_comment,
			--A.aptrx_orig_amt,
			--B.apcbk_gl_ap
			--Posted
		UNION
		SELECT
			[intVendorId]			=	D.intEntityId,  
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
			[dblTotal] 				=	(CASE WHEN A.apivc_trans_type = ''C'' THEN (A.apivc_orig_amt * -1) ELSE A.apivc_orig_amt END),
			[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
										(CASE WHEN A.apivc_trans_type = ''C'' THEN (A.apivc_orig_amt * -1) ELSE A.apivc_orig_amt END)
										END,
			[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CI_AS = RTRIM(A.apivc_user_id) COLLATE Latin1_General_CI_AS),@UserId),
			[ysnPosted]				=	1,
			[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
			[intTransactionType]	=	(CASE WHEN A.apivc_trans_type = ''C'' THEN 3 ELSE 1 END),
			[dblDiscount]			=	A.apivc_disc_avail,
			[dblWithheld]			=	A.apivc_wthhld_amt
		FROM apivcmst A
			LEFT JOIN apcbkmst B
				ON A.apivc_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.apivc_ivc_no = C.aptrx_ivc_no
			INNER JOIN tblAPVendor D
				ON A.apivc_vnd_no COLLATE Latin1_General_CI_AS = D.strVendorId COLLATE Latin1_General_CI_AS
		WHERE --CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
			 CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo
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
		SET IDENTITY_INSERT tblAPTempBill ON

		INSERT INTO tblAPTempBill([aptrx_vnd_no], [aptrx_ivc_no], [aptrx_sys_rev_dt], [aptrx_sys_time], [aptrx_cbk_no], [aptrx_chk_no], [aptrx_trans_type], [aptrx_batch_no],
		[aptrx_pur_ord_no], [aptrx_po_rcpt_seq], [aptrx_ivc_rev_dt], [aptrx_disc_rev_dt], [aptrx_due_rev_dt], [aptrx_chk_rev_dt], [aptrx_gl_rev_dt], [aptrx_disc_pct], [aptrx_orig_amt],
		[aptrx_disc_amt], [aptrx_wthhld_amt], [aptrx_net_amt], [aptrx_1099_amt], [aptrx_comment], [aptrx_orig_type], [aptrx_name], [aptrx_recur_yn], [aptrx_currency], [aptrx_currency_rt],
		[aptrx_currency_cnt], [aptrx_user_id], [aptrx_user_rev_dt], [A4GLIdentity])
		SELECT 
			A.* 
		FROM aptrxmst A
		INNER JOIN @InsertedData B
			ON A.aptrx_ivc_no = B.strBillId
		SET IDENTITY_INSERT tblAPTempBill OFF
	
			--Create Bill Batch transaction
		SELECT @totalBills = COUNT(*) FROM @InsertedData

		WHILE((SELECT TOP 1 1 FROM @InsertedData) IS NOT NULL)
		BEGIN

			SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted FROM @InsertedData

			INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intEntityId)
			--OUTPUT inserted.intBillBatchId, @BillId INTO @insertedBillBatch
			SELECT 
				A.intAccountId,
				@IsPosted,
				A.dblTotal,
				A.intEntityId
			FROM tblAPBill A
			WHERE A.intBillId = @BillId

			SET @BillBatchId = SCOPE_IDENTITY() --GET Last identity value of bill batch

			--UPDATE billbatch of Bill
			UPDATE tblAPBill
				SET intBillBatchId = @BillBatchId
			FROM tblAPBill
			WHERE intBillId = @BillId

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END
	
		SET @Total = @ImportedRecords;
	END


	END
	')
END
