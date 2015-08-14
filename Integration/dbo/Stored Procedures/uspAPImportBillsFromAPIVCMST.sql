GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportBillsFromAPTRXMST')
	DROP PROCEDURE uspAPImportBillsFromAPTRXMST
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC('
		CREATE PROCEDURE [dbo].[uspAPImportBillsFromAPIVCMST]
		(
			@UserId INT,
			@DateFrom DATETIME = NULL,
			@DateTo DATETIME = NULL,
			@totalImported INT OUTPUT
		)
		AS
		BEGIN

		SET QUOTED_IDENTIFIER OFF
		SET ANSI_NULLS ON
		SET NOCOUNT ON
		SET XACT_ABORT ON
		SET ANSI_WARNINGS OFF

		BEGIN TRY
		DECLARE @totalDeletedAPIVCMST INT;
		DECLARE @totalDeletedAPHGLMST INT;
		DECLARE @totalInsertedBill INT;
		DECLARE @totalInsertedBillDetail INT;
		DECLARE @totalInsertedTBLAPIVCMST INT;
		DECLARE @totalInsertedTBLAPHGLMST INT;
		DECLARE @transCount INT = @@TRANCOUNT;
		IF @transCount = 0 BEGIN TRANSACTION

			--CREATE TEMPORARY TABLE TO TRACK INSERTED AND ORIGINAL RECORDS
			CREATE TABLE #InsertedPostedBill(intBillId INT PRIMARY KEY CLUSTERED
					, strBillId NVARCHAR(100)
					, ysnPosted BIT, ysnPaid BIT
					, strVendorOrderNumber NVARCHAR(50)
					, intTransactionType INT
					, A4GLIdentity INT)
			CREATE NONCLUSTERED INDEX [IX_tmpInsertedPostedBill_intBillId] ON #InsertedPostedBill([intBillId]);
			CREATE TABLE #InsertedPostedBillDetail(intBillDetailId INT PRIMARY KEY CLUSTERED, A4GLIdentity INT)
			CREATE NONCLUSTERED INDEX [IX_tmpInsertedPostedBillDetail_intBillDetailId] ON #InsertedPostedBillDetail([intBillDetailId]);

			--removed first the constraint
			ALTER TABLE tblAPBill DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

			MERGE INTO tblAPBill AS destination
			USING (
				SELECT
					[intEntityVendorId]		=	D.intEntityVendorId, 
					[strVendorOrderNumber] 	=	(CASE WHEN DuplicateData.apivc_ivc_no IS NOT NULL
														THEN dbo.fnTrim(A.apivc_ivc_no) + ''-DUP'' 
														ELSE A.apivc_ivc_no END),
					[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation 
													WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor 
														WHERE strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
					[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmDateCreated] 		=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
					[strReference] 			=	A.apivc_comment,
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
					[ysnOrigin]				=	1,
					[A4GLIdentity]			=	A.[A4GLIdentity]
				FROM apivcmst A
					LEFT JOIN apcbkmst B
						ON A.apivc_cbk_no = B.apcbk_no
					INNER JOIN tblAPVendor D
						ON A.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
					OUTER APPLY (
						SELECT E.* FROM apivcmst E
						WHERE EXISTS(
							SELECT 1 FROM tblAPBill F
							INNER JOIN tblAPVendor G ON F.intEntityVendorId = G.intEntityVendorId
							WHERE E.apivc_ivc_no = F.strVendorOrderNumber COLLATE Latin1_General_CS_AS
							AND E.apivc_vnd_no = G.strVendorId COLLATE Latin1_General_CS_AS
						)
						AND A.apivc_vnd_no = E.apivc_vnd_no
						AND A.apivc_ivc_no = E.apivc_ivc_no
					) DuplicateData
					WHERE A.apivc_trans_type IN (''I'',''C'',''A'')
					AND A.apivc_orig_amt != 0
					AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
								ELSE 1 END)
			) AS sourceData
			ON  (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT (
				[intEntityVendorId],
				[strVendorOrderNumber], 
				[intTermsId], 
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
				[ysnOrigin]
			)
			VALUES (
				[intEntityVendorId],
				[strVendorOrderNumber], 
				[intTermsId], 
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
			OUTPUT inserted.intBillId
				, inserted.strBillId
				, inserted.ysnPosted
				, inserted.ysnPaid
				, inserted.strVendorOrderNumber
				, inserted.intTransactionType 
				, sourceData.A4GLIdentity INTO #InsertedPostedBill;

			SET @totalInsertedBill = (SELECT COUNT(*) FROM #InsertedPostedBill)
	
			--IMPORT BILL DETAILS FROM aphglmst
			MERGE INTO tblAPBillDetail AS destination
			USING (
				SELECT TOP 100 PERCENT
					[intBillId]				=	A.intBillId,
					[strMiscDescription]	=	A.strReference,
					[dblQtyOrdered]			=	1,
					[dblQtyReceived]		=	1,
					[intAccountId]			=	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.aphgl_gl_acct AS NVARCHAR(MAX))), 0),
					[dblTotal]				=	CASE WHEN C2.apivc_trans_type IN (''C'',''A'') THEN 
														(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END)
													ELSE C.aphgl_gl_amt END,
					[dblCost]				=	CASE WHEN C2.apivc_trans_type IN (''C'',''A'') THEN 
														(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END)
													ELSE C.aphgl_gl_amt END,
					[intLineNo]				=	C.aphgl_dist_no,
					[A4GLIdentity]			=	C.[A4GLIdentity]
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
				WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(C2.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
								ELSE 1 END)
				AND C2.apivc_trans_type IN (''I'',''C'',''A'')
				AND C2.apivc_orig_amt != 0
				ORDER BY C.aphgl_dist_no
			) AS sourceData
			ON (1 = 0)
			WHEN NOT MATCHED THEN
			INSERT (
				[intBillId],
				[strMiscDescription],
				[dblQtyOrdered],
				[dblQtyReceived],
				[intAccountId],
				[dblTotal],
				[dblCost],
				[intLineNo]
			)
			VALUES(
				[intBillId],
				[strMiscDescription],
				[dblQtyOrdered],
				[dblQtyReceived],
				[intAccountId],
				[dblTotal],
				[dblCost],
				[intLineNo]
			)
			OUTPUT inserted.intBillDetailId
			,sourceData.A4GLIdentity
			INTO #InsertedPostedBillDetail;

			SET @totalInsertedBillDetail = (SELECT COUNT(*) FROM #InsertedPostedBillDetail)

			--BACK UP apivcmst
			SET IDENTITY_INSERT tblAPapivcmst ON
			INSERT INTO tblAPapivcmst(
				[apivc_vnd_no],
				[apivc_ivc_no],
				[apivc_status_ind],
				[apivc_cbk_no],
				[apivc_chk_no],
				[apivc_trans_type],
				[apivc_pay_ind],
				[apivc_ap_audit_no],
				[apivc_pur_ord_no],
				[apivc_po_rcpt_seq],
				[apivc_ivc_rev_dt],
				[apivc_disc_rev_dt],
				[apivc_due_rev_dt],
				[apivc_chk_rev_dt],
				[apivc_gl_rev_dt],
				[apivc_orig_amt],
				[apivc_disc_avail],
				[apivc_disc_taken],
				[apivc_wthhld_amt],
				[apivc_net_amt],
				[apivc_1099_amt],
				[apivc_comment],
				[apivc_adv_chk_no],
				[apivc_recur_yn],
				[apivc_currency],
				[apivc_currency_rt],
				[apivc_currency_cnt],
				[apivc_user_id],
				[apivc_user_rev_dt],
				[A4GLIdentity],
				[intBillId]
			)
			SELECT
				[apivc_vnd_no]			=	A.[apivc_vnd_no]		,
				[apivc_ivc_no]			=	CASE WHEN DuplicateDataBackup.apivc_ivc_no IS NOT NULL THEN dbo.fnTrim(A.[apivc_ivc_no]) + ''-DUP'' ELSE A.apivc_ivc_no END,
				[apivc_status_ind]		=	A.[apivc_status_ind]	,
				[apivc_cbk_no]			=	A.[apivc_cbk_no]		,
				[apivc_chk_no]			=	A.[apivc_chk_no]		,
				[apivc_trans_type]		=	A.[apivc_trans_type]	,
				[apivc_pay_ind]			=	A.[apivc_pay_ind]		,
				[apivc_ap_audit_no]		=	A.[apivc_ap_audit_no]	,
				[apivc_pur_ord_no]		=	A.[apivc_pur_ord_no]	,
				[apivc_po_rcpt_seq]		=	A.[apivc_po_rcpt_seq]	,
				[apivc_ivc_rev_dt]		=	A.[apivc_ivc_rev_dt]	,
				[apivc_disc_rev_dt]		=	A.[apivc_disc_rev_dt]	,
				[apivc_due_rev_dt]		=	A.[apivc_due_rev_dt]	,
				[apivc_chk_rev_dt]		=	A.[apivc_chk_rev_dt]	,
				[apivc_gl_rev_dt]		=	A.[apivc_gl_rev_dt]		,
				[apivc_orig_amt]		=	A.[apivc_orig_amt]		,
				[apivc_disc_avail]		=	A.[apivc_disc_avail]	,
				[apivc_disc_taken]		=	A.[apivc_disc_taken]	,
				[apivc_wthhld_amt]		=	A.[apivc_wthhld_amt]	,
				[apivc_net_amt]			=	A.[apivc_net_amt]		,
				[apivc_1099_amt]		=	A.[apivc_1099_amt]		,
				[apivc_comment]			=	A.[apivc_comment]		,
				[apivc_adv_chk_no]		=	A.[apivc_adv_chk_no]	,
				[apivc_recur_yn]		=	A.[apivc_recur_yn]		,
				[apivc_currency]		=	A.[apivc_currency]		,
				[apivc_currency_rt]		=	A.[apivc_currency_rt]	,
				[apivc_currency_cnt]	=	A.[apivc_currency_cnt]	,
				[apivc_user_id]			=	A.[apivc_user_id]		,
				[apivc_user_rev_dt]		=	A.[apivc_user_rev_dt]	,
				[A4GLIdentity]			=	A.[A4GLIdentity]		,
				[intBillId]				=	B.intBillId
			FROM apivcmst A
			INNER JOIN #InsertedPostedBill B
				ON A.A4GLIdentity = B.A4GLIdentity
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			OUTER APPLY (
				SELECT E.* FROM apivcmst E
				WHERE EXISTS(
					SELECT 1 FROM tblAPapivcmst F
					WHERE A.apivc_ivc_no = F.apivc_ivc_no
					AND A.apivc_vnd_no = F.apivc_vnd_no
				)
				AND A.apivc_vnd_no = E.apivc_vnd_no
				AND A.apivc_ivc_no = E.apivc_ivc_no
			) DuplicateDataBackup
			WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
				AND A.apivc_trans_type IN (''I'',''C'',''A'')
				AND A.apivc_orig_amt != 0
		
			SET @totalInsertedTBLAPIVCMST = @@ROWCOUNT;
			SET IDENTITY_INSERT tblAPapivcmst OFF

			--BACK UP aphglmst
			SET IDENTITY_INSERT tblAPaphglmst ON
			MERGE INTO tblAPaphglmst AS destination
			USING (
				SELECT
					[aphgl_cbk_no]		=	A.[aphgl_cbk_no]		,
					[aphgl_trx_ind]		=	A.[aphgl_trx_ind]		,
					[aphgl_vnd_no]		=	A.[aphgl_vnd_no]		,
					[aphgl_ivc_no]		=	B.[apivc_ivc_no]		,
					[aphgl_dist_no]		=	A.[aphgl_dist_no]		,
					[aphgl_alt_cbk_no]	=	A.[aphgl_alt_cbk_no]	,
					[aphgl_gl_acct]		=	A.[aphgl_gl_acct]		,
					[aphgl_gl_amt]		=	A.[aphgl_gl_amt]		,
					[aphgl_gl_un]		=	A.[aphgl_gl_un]			,
					[A4GLIdentity]		=	A.[A4GLIdentity]		,
					[intBillDetailId]	=	C.intBillDetailId
				FROM aphglmst A 
				INNER JOIN apivcmst B 
							ON B.apivc_ivc_no = A.aphgl_ivc_no 
							AND B.apivc_vnd_no = A.aphgl_vnd_no
							AND B.apivc_cbk_no = A.aphgl_cbk_no
							AND B.apivc_trans_type = A.aphgl_trx_ind
				INNER JOIN #InsertedPostedBillDetail C
					ON A.[A4GLIdentity] = C.[A4GLIdentity]
				WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
				AND B.apivc_trans_type IN (''I'',''C'',''A'')
				AND B.apivc_orig_amt != 0
			) AS sourceData
			ON (1=0)
			WHEN NOT MATCHED THEN
			INSERT(
				[aphgl_cbk_no]		,
				[aphgl_trx_ind]		,
				[aphgl_vnd_no]		,
				[aphgl_ivc_no]		,
				[aphgl_dist_no]		,
				[aphgl_alt_cbk_no]	,
				[aphgl_gl_acct]		,
				[aphgl_gl_amt]		,
				[aphgl_gl_un]		,
				[A4GLIdentity]		,
				[intBillDetailId]	
			)
			VALUES(
				[aphgl_cbk_no]		,
				[aphgl_trx_ind]		,
				[aphgl_vnd_no]		,
				[aphgl_ivc_no]		,
				[aphgl_dist_no]		,
				[aphgl_alt_cbk_no]	,
				[aphgl_gl_acct]		,
				[aphgl_gl_amt]		,
				[aphgl_gl_un]		,
				[A4GLIdentity]		,
				[intBillDetailId]	
			);

			SET @totalInsertedTBLAPHGLMST = @@ROWCOUNT; --This should get before identity_insert as it gets 0 after
			SET IDENTITY_INSERT tblAPaphglmst OFF
	
			SET @totalImported = (SELECT COUNT(*) FROM #InsertedPostedBill)


			--DELETE A
			--FROM apivcmst A
			--INNER JOIN #InsertedPostedBill B
			--	ON A.A4GLIdentity = B.A4GLIdentity

			--SET @totalDeletedAPIVCMST = @@ROWCOUNT

			--DELETE A
			--FROM aphglmst A
			--INNER JOIN #InsertedPostedBillDetail B
			--	ON A.A4GLIdentity = B.A4GLIdentity

			--SET @totalDeletedAPHGLMST = @@ROWCOUNT

			DECLARE @error NVARCHAR(1000);
			SET @error = ''Unexpected number of rows inserted in tblAPapivcmst: Bill='' + CAST(@totalInsertedBill AS NVARCHAR(100)) + '',tblAPapivcmst='' + CAST(@totalInsertedTBLAPIVCMST AS NVARCHAR(100))
			IF @totalInsertedBill != @totalInsertedTBLAPIVCMST RAISERROR(@error, 16, 1);
			SET @error = ''Unexpected number of rows inserted in tblAPaphglmst: Bill='' + CAST(@totalInsertedBill AS NVARCHAR(100)) + '',tblAPaphglmst='' + CAST(@totalInsertedTBLAPHGLMST AS NVARCHAR(100))
			IF @totalInsertedBillDetail != @totalInsertedTBLAPHGLMST RAISERROR(@error, 16, 1);
			--SET @error = ''Unexpected number of rows deleted in apivcmst: Bill='' + CAST(@totalInsertedBill AS NVARCHAR(100)) + '',apivcmst='' + CAST(@totalDeletedAPIVCMST AS NVARCHAR(100))
			--IF @totalInsertedBill != @totalDeletedAPIVCMST RAISERROR(@error, 16, 1);
			--SET @error = ''Unexpected number of rows deleted in aphglmst: Bill='' + CAST(@totalInsertedBillDetail AS NVARCHAR(100)) + '',aphglmst='' + CAST(@totalDeletedAPHGLMST AS NVARCHAR(100))
			--IF @totalInsertedBillDetail != @totalDeletedAPHGLMST RAISERROR(@error, 16, 1);

			--UPDATE strBillId
			DECLARE @totalBills INT
			DECLARE @BillId INT
			DECLARE @IsPosted BIT
			DECLARE @IsPaid BIT
			DECLARE @type INT
			DECLARE @GeneratedBillId NVARCHAR(50)
			WHILE((SELECT TOP 1 1 FROM #InsertedPostedBill) IS NOT NULL)
			BEGIN
				SELECT TOP 1 @BillId = intBillId, @IsPosted = ysnPosted, @IsPaid = ysnPaid, @type = intTransactionType 
				FROM #InsertedPostedBill

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
					SET strBillId = @GeneratedBillId
				FROM tblAPBill
				WHERE intBillId = @BillId
				
				DELETE FROM #InsertedPostedBill WHERE intBillId = @BillId
			END;

			ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

			IF @transCount = 0 COMMIT TRANSACTION
		END TRY
		BEGIN CATCH
			DECLARE @ErrorSeverity INT,
					@ErrorNumber   INT,
					@ErrorMessage NVARCHAR(4000),
					@ErrorState INT,
					@ErrorLine  INT,
					@ErrorProc NVARCHAR(200);
			-- Grab error information from SQL functions
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorNumber   = ERROR_NUMBER()
			SET @ErrorMessage  = ERROR_MESSAGE()
			SET @ErrorState    = ERROR_STATE()
			SET @ErrorLine     = ERROR_LINE()
			SET @ErrorMessage  = ''Failed to import bills from apivcmst.'' + CHAR(13) + 
					''SQL Server Error Message is: '' + CAST(@ErrorNumber AS VARCHAR(10)) + 
					'' Line: '' + CAST(@ErrorLine AS VARCHAR(10)) + '' Error text: '' + @ErrorMessage
			IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
			RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		END CATCH
		END
	')
END
