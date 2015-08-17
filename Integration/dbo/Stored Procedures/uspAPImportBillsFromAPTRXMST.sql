GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportBillsFromAPTRXMST')
	DROP PROCEDURE uspAPImportBillsFromAPTRXMST
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC('
		CREATE PROCEDURE [dbo].[uspAPImportBillsFromAPTRXMST]
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
		DECLARE @totalDeletedAPTRXMST INT;
		DECLARE @totalDeletedAPEGLMST INT;
		DECLARE @totalInsertedBill INT;
		DECLARE @totalInsertedBillDetail INT;
		DECLARE @totalInsertedTBLAPTRXMST INT;
		DECLARE @totalInsertedTBLAPEGLMST INT;
		DECLARE @userLocation INT;
		DECLARE @transCount INT = @@TRANCOUNT;

		IF @transCount = 0 BEGIN TRANSACTION

			--CREATE TEMPORARY TABLE TO TRACK INSERTED AND ORIGINAL RECORDS
			CREATE TABLE #InsertedUnpostedBill(intBillId INT PRIMARY KEY CLUSTERED
					, strBillId NVARCHAR(100)
					, ysnPosted BIT, ysnPaid BIT
					, strVendorOrderNumber NVARCHAR(50)
					, strVendorOrderNumberOrig NVARCHAR(50)
					, intTransactionType INT
					, A4GLIdentity INT)
			CREATE NONCLUSTERED INDEX [IX_tmpInsertedUnpostedBill_intBillId] ON #InsertedUnpostedBill([intBillId]);
			CREATE TABLE #InsertedUnpostedBillDetail(intBillDetailId INT PRIMARY KEY CLUSTERED, A4GLIdentity INT)
			CREATE NONCLUSTERED INDEX [IX_tmpInsertedUnpostedBillDetail_intBillDetailId] ON #InsertedUnpostedBillDetail([intBillDetailId]);

			SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
					INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
			WHERE intEntityId = @UserId

			--removed first the constraint
			ALTER TABLE tblAPBill DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

			MERGE INTO tblAPBill AS destination
			USING (
				SELECT
					[intEntityVendorId]			=	D.intEntityVendorId,
					[strVendorOrderNumber] 		=	(CASE WHEN DuplicateData.aptrx_ivc_no IS NOT NULL THEN dbo.fnTrim(A.aptrx_ivc_no) + ''-DUP'' ELSE A.aptrx_ivc_no END),
					[strVendorOrderNumberOrig] 	=	A.aptrx_ivc_no,
					[intTermsId] 				=	ISNULL((SELECT TOP 1 intTermsId FROM tblEntityLocation
															WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor
																WHERE strVendorId COLLATE Latin1_General_CS_AS = A.aptrx_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
					[dtmDate] 					=	CASE WHEN ISDATE(A.aptrx_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmDateCreated] 			=	CASE WHEN ISDATE(A.aptrx_sys_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_sys_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmBillDate] 				=	CASE WHEN ISDATE(A.aptrx_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmDueDate] 				=	CASE WHEN ISDATE(A.aptrx_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.aptrx_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[intAccountId] 				=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
					[strReference] 				=	A.aptrx_comment,
					[strPONumber]				=	A.aptrx_pur_ord_no,
					[dblTotal] 					=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt 
														ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
					[dblAmountDue]				=	CASE WHEN A.aptrx_trans_type = ''C'' OR A.aptrx_trans_type = ''A'' THEN A.aptrx_orig_amt 
														ELSE (CASE WHEN A.aptrx_orig_amt < 0 THEN A.aptrx_orig_amt * -1 ELSE A.aptrx_orig_amt END) END,
					[intEntityId]				=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.aptrx_user_id)),@UserId),
					[ysnPosted]					=	0,
					[ysnPaid]					=	0,
					[intTransactionType]		=	CASE WHEN A.aptrx_trans_type = ''I'' THEN 1
														WHEN A.aptrx_trans_type = ''A'' THEN 2
														WHEN A.aptrx_trans_type = ''C'' THEN 3
														ELSE 0 END,
					[dblDiscount]				=	A.aptrx_disc_amt,
					[dblWithheld]				=	A.aptrx_wthhld_amt,
					[ysnOrigin]					=	1,
					[intShipToId]				=	@userLocation,
					[intShipFromId]				=	loc.intEntityLocationId,
					[A4GLIdentity]				=	A.A4GLIdentity
				FROM aptrxmst A
					LEFT JOIN apcbkmst B
						ON A.aptrx_cbk_no = B.apcbk_no
					INNER JOIN tblAPVendor D
						ON A.aptrx_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
					LEFT JOIN tblEntityLocation loc
						ON D.intEntityVendorId = loc.intEntityId AND loc.ysnDefaultLocation = 1
					OUTER APPLY (
						SELECT E.* FROM aptrxmst E
						WHERE EXISTS(
							SELECT 1 FROM tblAPBill F
								INNER JOIN tblAPVendor G ON F.intEntityVendorId = G.intEntityVendorId
							WHERE E.aptrx_ivc_no = F.strVendorOrderNumber COLLATE Latin1_General_CS_AS
							AND E.aptrx_vnd_no = G.strVendorId COLLATE Latin1_General_CS_AS
						)
						AND A.aptrx_vnd_no = E.aptrx_vnd_no
						AND A.aptrx_ivc_no = E.aptrx_ivc_no
					) DuplicateData
					WHERE A.aptrx_trans_type IN (''I'',''C'',''A'')
					AND A.aptrx_orig_amt != 0
					AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
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
				[intShipToId],
				[intShipFromId],
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
				[intShipToId],
				[intShipFromId],
				[ysnOrigin])
			OUTPUT inserted.intBillId
				, inserted.strBillId
				, inserted.ysnPosted
				, inserted.ysnPaid
				, inserted.strVendorOrderNumber
				, sourceData.strVendorOrderNumberOrig
				, inserted.intTransactionType 
				, sourceData.A4GLIdentity INTO #InsertedUnpostedBill;

			SET @totalInsertedBill = (SELECT COUNT(*) FROM #InsertedUnpostedBill)

			--IMPORT BILL DETAILS FROM aphglmst
			MERGE INTO tblAPBillDetail AS destination
			USING (
				SELECT TOP 100 PERCENT
					[intBillId]				=	A.intBillId,
					[strMiscDescription]	=	A.strReference,
					[dblQtyOrdered]			=	1,
					[dblQtyReceived]		=	1,
					[intAccountId]			=	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.apegl_gl_acct AS NVARCHAR(MAX))), 0),
					[dblTotal]				=	CASE WHEN C2.aptrx_trans_type IN (''C'',''A'') THEN
														(CASE WHEN C.apegl_gl_amt < 0 THEN C.apegl_gl_amt * -1 ELSE C.apegl_gl_amt END)
													ELSE C.apegl_gl_amt END,
					[dblCost]				=	CASE WHEN C2.aptrx_trans_type IN (''C'',''A'') THEN
														(CASE WHEN C.apegl_gl_amt < 0 THEN C.apegl_gl_amt * -1 ELSE C.apegl_gl_amt END)
													ELSE C.apegl_gl_amt END,
					[intLineNo]				=	C.apegl_dist_no,
					[A4GLIdentity]			=	C.A4GLIdentity
				FROM tblAPBill A
					INNER JOIN #InsertedUnpostedBill A2
						ON A.intBillId  = A2.intBillId
					INNER JOIN tblAPVendor B
						ON A.intEntityVendorId = B.intEntityVendorId
					INNER JOIN (aptrxmst C2 INNER JOIN apeglmst C 
									ON C2.aptrx_ivc_no = C.apegl_ivc_no 
									AND C2.aptrx_vnd_no = C.apegl_vnd_no
									AND C2.aptrx_cbk_no = C.apegl_cbk_no
									AND C2.aptrx_trans_type = C.apegl_trx_ind)
						ON A2.strVendorOrderNumberOrig COLLATE Latin1_General_CS_AS = C2.aptrx_ivc_no
						AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.aptrx_vnd_no
				WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(C2.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
								ELSE 1 END)
				AND C2.aptrx_trans_type IN (''I'',''C'',''A'')
				AND C2.aptrx_orig_amt != 0
				ORDER BY C.apegl_dist_no
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
			INTO #InsertedUnpostedBillDetail;

			SET @totalInsertedBillDetail = (SELECT COUNT(*) FROM #InsertedUnpostedBillDetail)

			--BACK UP apivcmst
			SET IDENTITY_INSERT tblAPaptrxmst ON
			INSERT INTO tblAPaptrxmst(
				[aptrx_vnd_no]				,
				[aptrx_ivc_no]				,
				[aptrx_sys_rev_dt]   		,
				[aptrx_sys_time]     		,
				[aptrx_cbk_no]       		,
				[aptrx_chk_no]       		,
				[aptrx_trans_type]   		,
				[aptrx_batch_no]     		,
				[aptrx_pur_ord_no]   		,
				[aptrx_po_rcpt_seq]  		,
				[aptrx_ivc_rev_dt]   		,
				[aptrx_disc_rev_dt]  		,
				[aptrx_due_rev_dt]   		,
				[aptrx_chk_rev_dt]   		,
				[aptrx_gl_rev_dt]    		,
				[aptrx_disc_pct]     		,
				[aptrx_orig_amt]     		,
				[aptrx_disc_amt]     		,
				[aptrx_wthhld_amt]   		,
				[aptrx_net_amt]      		,
				[aptrx_1099_amt]     		,
				[aptrx_comment]      		,
				[aptrx_orig_type]    		,
				[aptrx_name]         		,
				[aptrx_recur_yn]     		,
				[aptrx_currency]     		,
				[aptrx_currency_rt]  		,
				[aptrx_currency_cnt] 		,
				[aptrx_user_id]      		,
				[aptrx_user_rev_dt]			,
				[A4GLIdentity]				,
				[intBillId]					
			)
			SELECT
				[aptrx_vnd_no]			=	A.[aptrx_vnd_no]		,
				[aptrx_ivc_no]			=	CASE WHEN DuplicateDataBackup.aptrx_ivc_no IS NOT NULL THEN dbo.fnTrim(A.[aptrx_ivc_no]) + ''-DUP'' ELSE A.aptrx_ivc_no END,
				[aptrx_sys_rev_dt]  	=	A.[aptrx_sys_rev_dt]	,
				[aptrx_sys_time]    	=	A.[aptrx_sys_time]		,
				[aptrx_cbk_no]      	=	A.[aptrx_cbk_no]		,
				[aptrx_chk_no]      	=	A.[aptrx_chk_no]		,
				[aptrx_trans_type]  	=	A.[aptrx_trans_type]	,
				[aptrx_batch_no]    	=	A.[aptrx_batch_no]		,
				[aptrx_pur_ord_no]  	=	A.[aptrx_pur_ord_no]	,
				[aptrx_po_rcpt_seq] 	=	A.[aptrx_po_rcpt_seq]	,
				[aptrx_ivc_rev_dt]  	=	A.[aptrx_ivc_rev_dt]	,
				[aptrx_disc_rev_dt] 	=	A.[aptrx_disc_rev_dt]	,
				[aptrx_due_rev_dt]  	=	A.[aptrx_due_rev_dt]	,
				[aptrx_chk_rev_dt]  	=	A.[aptrx_chk_rev_dt]	,
				[aptrx_gl_rev_dt]   	=	A.[aptrx_gl_rev_dt]		,
				[aptrx_disc_pct]    	=	A.[aptrx_disc_pct]		,
				[aptrx_orig_amt]    	=	A.[aptrx_orig_amt]		,
				[aptrx_disc_amt]    	=	A.[aptrx_disc_amt]		,
				[aptrx_wthhld_amt]  	=	A.[aptrx_wthhld_amt]	,
				[aptrx_net_amt]     	=	A.[aptrx_net_amt]		,
				[aptrx_1099_amt]    	=	A.[aptrx_1099_amt]		,
				[aptrx_comment]     	=	A.[aptrx_comment]		,
				[aptrx_orig_type]   	=	A.[aptrx_orig_type]		,
				[aptrx_name]        	=	A.[aptrx_name]			,
				[aptrx_recur_yn]    	=	A.[aptrx_recur_yn]		,
				[aptrx_currency]    	=	A.[aptrx_currency]		,
				[aptrx_currency_rt] 	=	A.[aptrx_currency_rt]	,
				[aptrx_currency_cnt]	=	A.[aptrx_currency_cnt]	,
				[aptrx_user_id]     	=	A.[aptrx_user_id]		,
				[aptrx_user_rev_dt]		=	A.[aptrx_user_rev_dt]	,	
				[A4GLIdentity]			=	A.[A4GLIdentity]		,
				[intBillId]				=	B.intBillId
			FROM aptrxmst A
			INNER JOIN #InsertedUnpostedBill B
				ON A.A4GLIdentity = B.A4GLIdentity
			INNER JOIN tblAPBill C
				ON B.intBillId = C.intBillId
			OUTER APPLY (
				SELECT E.* FROM aptrxmst E
				WHERE EXISTS(
					SELECT 1 FROM tblAPaptrxmst F
					WHERE A.aptrx_ivc_no = F.aptrx_ivc_no
					AND A.aptrx_vnd_no = F.aptrx_vnd_no
				)
				AND A.aptrx_vnd_no = E.aptrx_vnd_no
				AND A.aptrx_ivc_no = E.aptrx_ivc_no
			) DuplicateDataBackup
			WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(A.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
				AND A.aptrx_trans_type IN (''I'',''C'',''A'')
				AND A.aptrx_orig_amt != 0

			SET @totalInsertedTBLAPTRXMST = @@ROWCOUNT;
			SET IDENTITY_INSERT tblAPaptrxmst OFF

			--BACK UP apeglmst
			SET IDENTITY_INSERT tblAPapeglmst ON
			MERGE INTO tblAPapeglmst AS destination
			USING (
				SELECT
					[apegl_cbk_no]		=	A.[apegl_cbk_no]		,
					[apegl_trx_ind]		=	A.[apegl_trx_ind]		,
					[apegl_vnd_no]		=	A.[apegl_vnd_no]		,
					[apegl_ivc_no]		=	B.[aptrx_ivc_no]		,
					[apegl_dist_no]		=	A.[apegl_dist_no]		,
					[apegl_alt_cbk_no]	=	A.[apegl_alt_cbk_no]	,
					[apegl_gl_acct]		=	A.[apegl_gl_acct]		,
					[apegl_gl_amt]		=	A.[apegl_gl_amt]		,
					[apegl_gl_un]		=	A.[apegl_gl_un]			,
					[A4GLIdentity]		=	A.[A4GLIdentity]		,
					[intBillDetailId]	=	C.intBillDetailId
				FROM apeglmst A
				INNER JOIN aptrxmst  B
				ON B.aptrx_ivc_no = A.apegl_ivc_no 
					AND B.aptrx_vnd_no = A.apegl_vnd_no
					AND B.aptrx_cbk_no = A.apegl_cbk_no
					AND B.aptrx_trans_type = A.apegl_trx_ind
				INNER JOIN #InsertedUnpostedBillDetail C
					ON A.[A4GLIdentity] = C.[A4GLIdentity]
				WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(B.aptrx_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
								ELSE 1 END)
				AND B.aptrx_trans_type IN (''I'',''C'',''A'')
				AND B.aptrx_orig_amt != 0
			) AS sourceData
			ON (1=0)
			WHEN NOT MATCHED THEN
			INSERT(
				[apegl_cbk_no]		,
				[apegl_trx_ind]		,
				[apegl_vnd_no]		,
				[apegl_ivc_no]		,
				[apegl_dist_no]		,
				[apegl_alt_cbk_no]	,
				[apegl_gl_acct]		,
				[apegl_gl_amt]		,
				[apegl_gl_un]		,
				[A4GLIdentity]		,
				[intBillDetailId]	
			)
			VALUES(
				[apegl_cbk_no]		,
				[apegl_trx_ind]		,
				[apegl_vnd_no]		,
				[apegl_ivc_no]		,
				[apegl_dist_no]		,
				[apegl_alt_cbk_no]	,
				[apegl_gl_acct]		,
				[apegl_gl_amt]		,
				[apegl_gl_un]		,
				[A4GLIdentity]		,
				[intBillDetailId]	
			);
			SET @totalInsertedTBLAPEGLMST = @@ROWCOUNT;
			SET IDENTITY_INSERT tblAPapeglmst OFF

			SET @totalImported = (SELECT COUNT(*) FROM #InsertedUnpostedBill)

			DELETE A
			FROM aptrxmst A
			INNER JOIN #InsertedUnpostedBill B
				ON A.[A4GLIdentity] = B.[A4GLIdentity]

			SET @totalDeletedAPTRXMST = @@ROWCOUNT

			DELETE A
			FROM apeglmst A
			INNER JOIN #InsertedUnpostedBillDetail B
				ON A.[A4GLIdentity] = B.[A4GLIdentity]

			SET @totalDeletedAPEGLMST = @@ROWCOUNT

			DECLARE @error NVARCHAR(1000);
			SET @error = ''Unexpected number of rows inserted in tblAPaptrxmst: Bill='' + CAST(@totalInsertedBill AS NVARCHAR(100)) + '',tblAPaptrxmst='' + CAST(@totalInsertedTBLAPTRXMST AS NVARCHAR(100))
			IF @totalInsertedBill != @totalInsertedTBLAPTRXMST RAISERROR(@error, 16, 1);
			SET @error = ''Unexpected number of rows deleted in aptrxmst: Bill='' + CAST(@totalInsertedBill AS NVARCHAR(100)) + '',aptrxmst='' + CAST(@totalDeletedAPTRXMST AS NVARCHAR(100))
			IF @totalInsertedBill != @totalDeletedAPTRXMST RAISERROR(@error, 16, 1);
			SET @error = ''Unexpected number of rows deleted in apeglmst: Bill='' + CAST(@totalInsertedBillDetail AS NVARCHAR(100)) + '',apeglmst='' + CAST(@totalDeletedAPEGLMST AS NVARCHAR(100))
			IF @totalInsertedBillDetail != @totalDeletedAPEGLMST RAISERROR(@error, 16, 1);

			--UPDATE strBillId
			DECLARE @totalBills INT
			DECLARE @BillId INT
			DECLARE @IsPosted BIT
			DECLARE @IsPaid BIT
			DECLARE @type INT
			DECLARE @GeneratedBillId NVARCHAR(50)
			DECLARE @shipFrom INT, @shipTo INT;
			WHILE((SELECT TOP 1 1 FROM #InsertedUnpostedBill) IS NOT NULL)
			BEGIN
				SELECT TOP 1 @BillId = A.intBillId
					, @IsPosted = A.ysnPosted
					, @IsPaid = A.ysnPaid
					, @type = A.intTransactionType 
					, @shipFrom = B.intShipFromId
					, @shipTo = B.intShipToId
				FROM #InsertedUnpostedBill A
				INNER JOIN tblAPBill B ON A.intBillId = B.intBillId

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

				EXEC uspAPBillUpdateAddressInfo @BillId, @shipFrom, @shipTo
				
				DELETE FROM #InsertedUnpostedBill WHERE intBillId = @BillId
			END;

			ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

			IF @transCount = 0 COMMIT TRANSACTION

		END TRY
		BEGIN CATCH
			DECLARE @ErrorSeverity INT,
					@ErrorNumber   INT,
					@ErrorMessage nvarchar(4000),
					@ErrorState INT,
					@ErrorLine  INT,
					@ErrorProc nvarchar(200);
			-- Grab error information from SQL functions
			SET @ErrorSeverity = ERROR_SEVERITY()
			SET @ErrorNumber   = ERROR_NUMBER()
			SET @ErrorMessage  = ERROR_MESSAGE()
			SET @ErrorState    = ERROR_STATE()
			SET @ErrorLine     = ERROR_LINE()
			SET @ErrorMessage  = ''Failed to import bills from aptrxmst.'' + CHAR(13) + 
					''SQL Server Error Message is: '' + CAST(@ErrorNumber AS VARCHAR(10)) + 
					'' Line: '' + CAST(@ErrorLine AS VARCHAR(10)) + '' Error text: '' + @ErrorMessage
			IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
			RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
		END CATCH
		END
	')
END
