GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspAPImportBillsFromAPIVCMST')
	DROP PROCEDURE uspAPImportBillsFromAPIVCMST
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
	EXEC('
		CREATE PROCEDURE [dbo].[uspAPImportBillsFromAPIVCMST]
		(
			@UserId INT,
			@DateFrom DATETIME = NULL,
			@DateTo DATETIME = NULL,
			@creditCardOnly BIT = 0,
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
		DECLARE @userLocation INT;
		DECLARE @transCount INT = @@TRANCOUNT;

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

			
			--CHECK FOR MISSING VENDOR IN i21
			DECLARE @missingVendor TABLE(strVendorId NVARCHAR(100));
			DECLARE @missingVendorId NVARCHAR(100);
			DECLARE @missingVendorError NVARCHAR(500);
			INSERT INTO @missingVendor
			SELECT dbo.fnTrim(apivc_vnd_no) FROM (
					SELECT apivc_vnd_no FROM apivcmst A
						LEFT JOIN tblAPVendor B ON A.apivc_vnd_no = B.strVendorId COLLATE Latin1_General_CS_AS
						WHERE B.strVendorId IS NULL
			) MissingVendors

			IF EXISTS(SELECT 1 FROM @missingVendor)
			BEGIN
				--SET @missingVendorError = @missingVendor + '' is missing in i21. Please create the missing vendor in i21.'';
				--RAISERROR(@missingVendorError, 16, 1);
				WHILE EXISTS(SELECT 1 FROM @missingVendor)
				BEGIN
					SELECT TOP 1 @missingVendorId = strVendorId FROM @missingVendor;
					EXEC uspEMCreateEntityById @Id = @missingVendorId, @Type = ''Vendor'', @UserId = @UserId, @Message = @missingVendorError OUTPUT
					IF (@missingVendorError IS NOT NULL)
					BEGIN
						RAISERROR(@missingVendorError, 16, 1);
					END
					DELETE FROM @missingVendor WHERE strVendorId = @missingVendorId;
				END
			END

			SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
					INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
			WHERE intEntityId = @UserId

			--removed first the constraint
			ALTER TABLE tblAPBill DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

			MERGE INTO tblAPBill AS destination
			USING (
				SELECT
					[intEntityVendorId]		=	D.intEntityId, 
					[strVendorOrderNumber] 	=	(CASE WHEN DuplicateData.apivc_ivc_no IS NOT NULL
														THEN dbo.fnTrim(A.apivc_ivc_no) + ''-DUP'' 
														ELSE A.apivc_ivc_no END),
					[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEMEntityLocation 
													WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
														WHERE strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt'')),
					[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) END,
					[dtmDateCreated] 		=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
					[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
					[strReference] 			=	A.apivc_comment,
					[strPONumber]			=	A.apivc_pur_ord_no,
					[dbl1099]				=	A.apivc_1099_amt,
					[dblTotal] 				=	CASE WHEN A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'' THEN A.apivc_orig_amt
													ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END,
					[dblPayment]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN
													CASE WHEN (A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'') THEN A.apivc_orig_amt
														ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
												ELSE 0 END,
					[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = ''P'' THEN 0 ELSE 
														CASE WHEN A.apivc_trans_type = ''C'' OR A.apivc_trans_type = ''A'' THEN A.apivc_orig_amt
															ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
													END,
					[intEntityId]			=	ISNULL((SELECT intEntityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.apivc_user_id)),@UserId),
					[ysnPosted]				=	1,
					[ysnPaid]				=	CASE WHEN A.apivc_status_ind = ''P'' THEN 1 ELSE 0 END,
					[intTransactionType]	=	CASE WHEN A.apivc_trans_type = ''I'' AND A.apivc_orig_amt > 0 THEN 1
													 WHEN A.apivc_trans_type = ''O'' AND A.apivc_orig_amt > 0 THEN 1
													WHEN A.apivc_trans_type = ''A'' THEN 2
													WHEN A.apivc_trans_type = ''C'' OR A.apivc_orig_amt < 0 THEN 3
													ELSE 0 END,
					[dblDiscount]			=	ISNULL(A.apivc_disc_avail,0),
					[dblWithheld]			=	A.apivc_wthhld_amt,
					[ysnOrigin]				=	1,
					[intCurrencyId]			=	(SELECT TOP 1 intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE ''%USD%''),
					[intShipToId]			=	@userLocation,
					[intShipFromId]			=	loc.intEntityLocationId,
					[intPayToAddressId]		=	loc.intEntityLocationId,
					[A4GLIdentity]			=	A.[A4GLIdentity]
				FROM apivcmst A
					LEFT JOIN apcbkmst B
						ON A.apivc_cbk_no = B.apcbk_no
					INNER JOIN tblAPVendor D
						ON A.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
					LEFT JOIN tblEMEntityLocation loc
						ON D.intEntityId = loc.intEntityId AND loc.ysnDefaultLocation = 1
					OUTER APPLY (
						SELECT E.* FROM apivcmst E
						WHERE EXISTS(
							SELECT 1 FROM tblAPBill F
							INNER JOIN tblAPVendor G ON F.intEntityVendorId = G.intEntityId
							WHERE E.apivc_ivc_no = F.strVendorOrderNumber COLLATE Latin1_General_CS_AS
							AND E.apivc_vnd_no = G.strVendorId COLLATE Latin1_General_CS_AS
						)
						AND A.apivc_vnd_no = E.apivc_vnd_no
						AND A.apivc_ivc_no = E.apivc_ivc_no
					) DuplicateData
					WHERE A.apivc_trans_type IN (''I'',''C'',''A'',''O'')
					AND A.apivc_orig_amt != 0
					AND 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
								ELSE 1 END)
					AND 1 = (CASE WHEN @creditCardOnly = 1 AND A.apivc_comment IN (''CCD Reconciliation'', ''CCD Reconciliation Reversal'') AND A.apivc_status_ind = ''U'' THEN 1
								WHEN @creditCardOnly = 0 THEN 1	
							ELSE 0 END)
					AND NOT EXISTS(
						SELECT 1 FROM tblAPapivcmst H
						WHERE A.apivc_ivc_no = H.apivc_ivc_no AND A.apivc_vnd_no = H.apivc_vnd_no
					)
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
				[dbl1099],
				[dblPayment], 
				[dblAmountDue],
				[intEntityId],
				[ysnPosted],
				[ysnPaid],
				[intTransactionType],
				[dblDiscount],
				[dblWithheld],
				[intShipToId],
				[intShipFromId],
				[intPayToAddressId],
				[intCurrencyId],
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
				[dbl1099],
				[dblPayment],
				[dblAmountDue],
				[intEntityId],
				[ysnPosted],
				[ysnPaid],
				[intTransactionType],
				[dblDiscount],
				[dblWithheld],
				[intShipToId],
				[intShipFromId],
				[intPayToAddressId],
				[intCurrencyId],
				[ysnOrigin])
			OUTPUT inserted.intBillId
				, inserted.strBillId
				, inserted.ysnPosted
				, inserted.ysnPaid
				, inserted.strVendorOrderNumber
				, inserted.intTransactionType 
				, sourceData.A4GLIdentity INTO #InsertedPostedBill;

			SET @totalInsertedBill = (SELECT COUNT(*) FROM #InsertedPostedBill)

			IF @totalInsertedBill <= 0 
			BEGIN
				ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);
				SET @totalImported = 0;
				RETURN;
			END
	
			--IMPORT BILL DETAILS FROM aphglmst
			MERGE INTO tblAPBillDetail AS destination
			USING (
				SELECT TOP 100 PERCENT
					[intBillId]				=	A.intBillId,
					[strMiscDescription]	=	A.strReference,
					[dblQtyOrdered]			=	(CASE WHEN C2.apivc_trans_type IN (''C'',''A'') AND C.aphgl_gl_amt > 0 THEN
													(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 ELSE C.aphgl_gl_un END) * (-1) --make it negative if detail of debit memo is positive
												ELSE 
													(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 
														ELSE 
															(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_un * -1 ELSE C.aphgl_gl_un END)
													END) 
												END),
					[dblQtyReceived]		=	(CASE WHEN C2.apivc_trans_type IN (''C'',''A'') AND C.aphgl_gl_amt > 0 THEN
													(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 ELSE C.aphgl_gl_un END) * (-1)
												ELSE 
													(CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 
													ELSE 
														(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_un * -1 ELSE C.aphgl_gl_un END)
													END) 
												END),
					[intAccountId]			=	ISNULL((SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(C.aphgl_gl_acct AS NVARCHAR(MAX))), 0),
					[dblTotal]				=	CASE WHEN C2.apivc_trans_type IN (''C'',''A'') THEN C.aphgl_gl_amt * -1
														--(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END)
													ELSE C.aphgl_gl_amt END,
					[dblCost]				=	(CASE WHEN C2.apivc_trans_type IN (''C'',''A'',''I'') THEN
														(CASE WHEN C.aphgl_gl_amt < 0 THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END) --Cost should always positive
													ELSE C.aphgl_gl_amt END) / (CASE WHEN ISNULL(C.aphgl_gl_un,0) <= 0 THEN 1 ELSE C.aphgl_gl_un END),
					[dbl1099]				=	(CASE WHEN (A.dblTotal > 0 AND C2.apivc_1099_amt > 0)
												THEN 
													(
														((CASE WHEN C2.apivc_trans_type IN (''C'',''A'') THEN C.aphgl_gl_amt * -1 ELSE C.aphgl_gl_amt END)
															/
															(A.dblTotal)
														)
														*
														A.dblTotal
													)
												ELSE 0 END), --COMPUTE WITHHELD ONLY IF TOTAL IS POSITIVE
					[int1099Form]			=	(CASE WHEN C2.apivc_1099_amt > 0 THEN 1 ELSE 0 END),
					[int1099Category]		=	(CASE WHEN C2.apivc_1099_amt > 0 THEN 8 ELSE 0 END),
					[intLineNo]				=	C.aphgl_dist_no,
					[A4GLIdentity]			=	C.[A4GLIdentity]
				FROM tblAPBill A
				INNER JOIN tblAPVendor B
					ON A.intEntityVendorId = B.intEntityId
				INNER JOIN (apivcmst C2 INNER JOIN aphglmst C 
							ON C2.apivc_ivc_no = C.aphgl_ivc_no 
							AND C2.apivc_vnd_no = C.aphgl_vnd_no)
				ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.apivc_ivc_no
					AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.apivc_vnd_no
				WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
								THEN
									CASE WHEN CONVERT(DATE, CAST(C2.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
								ELSE 1 END)
				AND C2.apivc_trans_type IN (''I'',''C'',''A'',''O'')
				AND C2.apivc_orig_amt != 0
				AND 1 = (CASE WHEN @creditCardOnly = 1 AND C2.apivc_comment IN (''CCD Reconciliation'', ''CCD Reconciliation Reversal'') AND C2.apivc_status_ind = ''U'' THEN 1 
							WHEN @creditCardOnly = 0 THEN 1
							ELSE 0 END)
				AND NOT EXISTS(
						SELECT 1 FROM tblAPapivcmst H
						WHERE C2.apivc_ivc_no = H.apivc_ivc_no AND C2.apivc_vnd_no = H.apivc_vnd_no
					)
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
				[dbl1099],
				[int1099Form],
				[int1099Category],
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
				[dbl1099],
				[int1099Form],
				[int1099Category],
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
				[apivc_ivc_no]			=	C.strVendorOrderNumber	,--CASE WHEN DuplicateDataBackup.apivc_ivc_no IS NOT NULL THEN dbo.fnTrim(A.[apivc_ivc_no]) + ''-DUP'' ELSE A.apivc_ivc_no END,
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
			--OUTER APPLY (
			--	SELECT E.* FROM apivcmst E
			--	WHERE EXISTS(
			--		SELECT 1 FROM tblAPapivcmst F
			--		WHERE A.apivc_ivc_no = F.apivc_ivc_no
			--		AND A.apivc_vnd_no = F.apivc_vnd_no
			--	)
			--	AND A.apivc_vnd_no = E.apivc_vnd_no
			--	AND A.apivc_ivc_no = E.apivc_ivc_no
			--) DuplicateDataBackup
			WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
				AND A.apivc_trans_type IN (''I'',''C'',''A'',''O'')
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
				INNER JOIN #InsertedPostedBillDetail C
					ON A.[A4GLIdentity] = C.[A4GLIdentity]
				WHERE 1 = (CASE WHEN @DateFrom IS NOT NULL AND @DateTo IS NOT NULL 
							THEN
								CASE WHEN CONVERT(DATE, CAST(B.apivc_gl_rev_dt AS CHAR(12)), 112) BETWEEN @DateFrom AND @DateTo THEN 1 ELSE 0 END
							ELSE 1 END)
				AND B.apivc_trans_type IN (''I'',''C'',''A'',''O'')
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
			DECLARE @shipFrom INT, @shipTo INT;
			WHILE((SELECT TOP 1 1 FROM #InsertedPostedBill) IS NOT NULL)
			BEGIN
				SELECT TOP 1 @BillId = A.intBillId
					, @IsPosted = A.ysnPosted
					, @IsPaid = A.ysnPaid
					, @type = A.intTransactionType 
					, @shipFrom = B.intShipFromId
					, @shipTo = B.intShipToId
				FROM #InsertedPostedBill A
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
				
				DELETE FROM #InsertedPostedBill WHERE intBillId = @BillId
			END;

			ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);

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
			--AND A.apchk_trx_ind <> ''O'' 
			AND A.apchk_chk_amt <> 0
				INNER JOIN (tblAPBill C INNER JOIN tblAPVendor D ON C.intEntityVendorId = D.intEntityId)
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
					@intEntityVendorId = B.intEntityId,
					@paymentInfo = A.strCheckNo,
					@payment = A.dblAmount,
					@datePaid = A.dtmDate,
					@paymentMethod = (SELECT TOP 1 intPaymentMethodID FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = LOWER(A.strPaymentMethod) COLLATE Latin1_General_CS_AS),
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

			EXEC uspAPCreateMissingPaymentOfBills

			--UPDATE strTransactionId from tblCMBankTransaction
			UPDATE tblCMBankTransaction
			SET strTransactionId = B.strPaymentRecordNum,
				intPayeeId = C.intEntityId
			FROM tblCMBankTransaction A
			INNER JOIN tblAPPayment B
				ON A.dblAmount = (CASE WHEN A.intBankTransactionTypeId = 11 THEN (B.dblAmountPaid) * -1 ELSE B.dblAmountPaid END)
				AND A.dtmDate = B.dtmDatePaid
				AND A.intBankAccountId = B.intBankAccountId
				AND A.strReferenceNo = B.strPaymentInfo
			INNER JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON C.intEntityId = D.intEntityId)
				ON B.intEntityVendorId = C.intEntityId 
				--AND A.strPayee = D.strName
			WHERE A.strSourceSystem IN (''AP'',''CW'')
			AND A.strTransactionId <> B.strPaymentRecordNum

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
