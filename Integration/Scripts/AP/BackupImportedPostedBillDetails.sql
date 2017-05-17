--THIS SCRIPT WILL BACK UP IMPORTED POSTED BILL DETAILS
GO
IF(NOT EXISTS(SELECT 1 FROM tblAPaphglmst) AND EXISTS(SELECT 1 FROM tblAPBill WHERE ysnPosted = 1 AND ysnOrigin = 1))
BEGIN
	BEGIN TRY
		DECLARE @insertedPostedBillDetail TABLE(A4GLIdentity INT)
		DECLARE @transCount INT = 0
		DECLARE @totalBackupedPostedBillDetails INT;
		SET @transCount = 0
		IF @transCount = 0 BEGIN TRANSACTION

		PRINT 'Backing up imported posted bill details'
		SET IDENTITY_INSERT tblAPaphglmst ON
		MERGE INTO tblAPaphglmst AS destination
		USING (
			SELECT TOP 100 PERCENT
				[aphgl_cbk_no]		=	C.[aphgl_cbk_no]		,
				[aphgl_trx_ind]		=	C.[aphgl_trx_ind]		,
				[aphgl_vnd_no]		=	C.[aphgl_vnd_no]		,
				[aphgl_ivc_no]		=	A.[strVendorOrderNumber],
				[aphgl_dist_no]		=	C.[aphgl_dist_no]		,
				[aphgl_alt_cbk_no]	=	C.[aphgl_alt_cbk_no]	,
				[aphgl_gl_acct]		=	C.[aphgl_gl_acct]		,
				[aphgl_gl_amt]		=	C.[aphgl_gl_amt]		,
				[aphgl_gl_un]		=	C.[aphgl_gl_un]			,
				[A4GLIdentity]		=	C.[A4GLIdentity]		,
				[intBillDetailId]	=	(SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = A.intBillId AND intLineNo = C.aphgl_dist_no)
			FROM tblAPBill A
			INNER JOIN tblAPVendor B
				ON A.intEntityVendorId = B.intEntityId
			INNER JOIN (tblAPaptrxmst C2 INNER JOIN aphglmst C 
						ON C2.aptrx_ivc_no = C.aphgl_ivc_no 
						AND C2.aptrx_vnd_no = C.aphgl_vnd_no
						AND C2.aptrx_cbk_no = C.aphgl_cbk_no
						AND C2.aptrx_trans_type = C.aphgl_trx_ind)
			ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.aptrx_ivc_no
				AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.aptrx_vnd_no
			WHERE A.ysnOrigin = 1 AND A.ysnPosted = 1
			ORDER BY C.aphgl_dist_no
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
		)
		OUTPUT sourceData.A4GLIdentity INTO @insertedPostedBillDetail;
		SET @totalBackupedPostedBillDetails = @@ROWCOUNT;
		SET IDENTITY_INSERT tblAPaphglmst OFF
		PRINT 'End backing up imported posted bill details'

		DELETE FROM aphglmst
		WHERE A4GLIdentity IN (SELECT A4GLIdentity FROM @insertedPostedBillDetail)

		DECLARE @totalDeletedPostedBillDetail INT = @@ROWCOUNT;
		IF @totalBackupedPostedBillDetails != @totalDeletedPostedBillDetail
		BEGIN
			RAISERROR('Unexpected number of rows deleted from aphglmst', 16, 1);
		END

		IF @transCount = 0 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT 'Failed to back up imported bill details'
		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	END CATCH
END
