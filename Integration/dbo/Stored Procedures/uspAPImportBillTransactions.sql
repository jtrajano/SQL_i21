IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'uspAPImportBillTransactions')
	DROP VIEW uspAPImportBillTransactions

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

	DECLARE @InsertedData TABLE (intBillId INT, strBillId NVARCHAR(100), ysnPosted BIT)
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
			[strVendorId], 
			[strBillId],
			[strVendorOrderNumber], 
			[intTermsId], 
			[intTaxCodeId], 
			[dtmDate], 
			[dtmBillDate], 
			[dtmDueDate], 
			[intAccountId], 
			[strDescription], 
			[dblTotal], 
			[ysnPaid], 
			[dblAmountDue],
			[intUserId],
			[ysnPosted])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted INTO @InsertedData
		--Unposted
		SELECT 
			[strVendorId]			=	A.aptrx_vnd_no,
			[strBillId] 			=	A.aptrx_ivc_no,
			[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
			[intTermsId] 			=	0,
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112),
			[dtmBillDate] 			=	CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112),
			[dtmDueDate] 			=	CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112),
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.aptrx_comment,
			[dblTotal] 				=	A.aptrx_orig_amt,
			[ysnPaid] 				=	0, --CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.aptrx_orig_amt THEN 1 ELSE 0 END,
			[dblAmountDue]			=	A.aptrx_orig_amt,--CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
			[intUserId]				=	@UserId,
			[ysnPosted]				=	0
		FROM aptrxmst A
			--LEFT JOIN apeglmst B
			--	ON A.aptrx_ivc_no = B.apegl_ivc_no
			LEFT JOIN apcbkmst B
				ON A.aptrx_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.aptrx_ivc_no = C.aptrx_ivc_no

			WHERE C.aptrx_ivc_no IS NULL

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
			[strVendorId]			=	A.apivc_vnd_no,
			[strBillId] 			=	A.apivc_ivc_no,
			[strVendorOrderNumber] 	=	A.apivc_ivc_no,
			[intTermsId] 			=	0,
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112),
			[dtmBillDate] 			=	CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112),
			[dtmDueDate] 			=	CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112),
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.apivc_comment,
			[dblTotal] 				=	A.apivc_orig_amt,
			[ysnPaid] 				=	0, --CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.apivc_orig_amt THEN 1 ELSE 0 END,
			[dblAmountDue]			=	A.apivc_orig_amt,--CASE WHEN B.apegl_ivc_no IS NULL THEN A.apivc_orig_amt ELSE A.apivc_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
			[intUserId]				=	@UserId,
			[ysnPosted]				=	1
		FROM apivcmst A
			LEFT JOIN apcbkmst B
				ON A.apivc_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.apivc_ivc_no = C.aptrx_ivc_no

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
			(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.apegl_gl_acct),
			C.apegl_gl_amt
		FROM tblAPBill A
			INNER JOIN apeglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS

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

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END

		SET @Total = @ImportedRecords;
	END
	ELSE
	BEGIN
		INSERT [dbo].[tblAPBill] (
			[strVendorId], 
			[strBillId],
			[strVendorOrderNumber], 
			[intTermsId], 
			[intTaxCodeId], 
			[dtmDate], 
			[dtmBillDate], 
			[dtmDueDate], 
			[intAccountId], 
			[strDescription], 
			[dblTotal], 
			[ysnPaid], 
			[dblAmountDue],
			[intUserId],
			[ysnPosted])
		OUTPUT inserted.intBillId, inserted.strBillId, inserted.ysnPosted INTO @InsertedData
		--Unposted
		SELECT 
			[strVendorId]			=	A.aptrx_vnd_no,
			[strBillId] 			=	A.aptrx_ivc_no,
			[strVendorOrderNumber] 	=	A.aptrx_ivc_no,
			[intTermsId] 			=	0,
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112),
			[dtmBillDate] 			=	CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112),
			[dtmDueDate] 			=	CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112),
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.aptrx_comment,
			[dblTotal] 				=	A.aptrx_orig_amt,
			[ysnPaid] 				=	0, --CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.aptrx_orig_amt THEN 1 ELSE 0 END,
			[dblAmountDue]			=	A.aptrx_orig_amt,--CASE WHEN B.apegl_ivc_no IS NULL THEN A.aptrx_orig_amt ELSE A.aptrx_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
			[intUserId]				=	@UserId,
			[ysnPosted]				=	0
		FROM aptrxmst A
			--LEFT JOIN apeglmst B
			--	ON A.aptrx_ivc_no = B.apegl_ivc_no
			LEFT JOIN apcbkmst B
				ON A.aptrx_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.aptrx_ivc_no = C.aptrx_ivc_no
		
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
			[strVendorId]			=	A.apivc_vnd_no,
			[strBillId] 			=	A.apivc_ivc_no,
			[strVendorOrderNumber] 	=	A.apivc_ivc_no,
			[intTermsId] 			=	0,
			[intTaxCodeId] 			=	NULL,
			[dtmDate] 				=	CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112),
			[dtmBillDate] 			=	CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112),
			[dtmDueDate] 			=	CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112),
			[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = B.apcbk_gl_ap),
			[strDescription] 		=	A.apivc_comment,
			[dblTotal] 				=	A.apivc_orig_amt,
			[ysnPaid] 				=	0, --CASE WHEN SUM(ISNULL(B.apegl_gl_amt,0)) = A.apivc_orig_amt THEN 1 ELSE 0 END,
			[dblAmountDue]			=	A.apivc_orig_amt,--CASE WHEN B.apegl_ivc_no IS NULL THEN A.apivc_orig_amt ELSE A.apivc_orig_amt - SUM(ISNULL(B.apegl_gl_amt,0)) END
			[intUserId]				=	@UserId,
			[ysnPosted]				=	1
		FROM apivcmst A
			LEFT JOIN apcbkmst B
				ON A.apivc_cbk_no = B.apcbk_no
			LEFT JOIN tblAPTempBill C
				ON A.apivc_ivc_no = C.aptrx_ivc_no
		
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
			(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = C.apegl_gl_acct),
			C.apegl_gl_amt
			FROM tblAPBill A
			INNER JOIN apeglmst C
				ON A.strVendorOrderNumber COLLATE Latin1_General_CI_AS = C.apegl_ivc_no COLLATE Latin1_General_CI_AS

				
		----Create Bill Batch transaction
		--INSERT INTO tblAPBillBatch(intAccountId, ysnPosted, dblTotal, intUserId)
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

			DELETE FROM @InsertedData WHERE intBillId = @BillId
		END
	
		SET @Total = @ImportedRecords;
	END


	END

	')
END
