﻿--THIS SCRIPT WILL BACK UP IMPORTED UNPOSTED BILL DETAILS
GO
IF(NOT EXISTS(SELECT 1 FROM tblAPapeglmst) AND EXISTS(SELECT 1 FROM tblAPBill WHERE ysnPosted = 0 AND ysnOrigin = 1))
BEGIN
	BEGIN TRY
		DECLARE @insertedUnpostedBillDetail TABLE(A4GLIdentity INT)
		DECLARE @transCount INT = 0
		DECLARE @totalBackupedUnpostedBillDetails INT
		SET @transCount = 0
		IF @transCount = 0 BEGIN TRANSACTION

		PRINT 'Backing up imported unposted bill details'
		SET IDENTITY_INSERT tblAPapeglmst ON
		MERGE INTO tblAPapeglmst AS destination
		USING (
			SELECT TOP 100 PERCENT
				[apegl_cbk_no]		=	C.[apegl_cbk_no]		,
				[apegl_trx_ind]		=	C.[apegl_trx_ind]		,
				[apegl_vnd_no]		=	C.[apegl_vnd_no]		,
				[apegl_ivc_no]		=	A.[strVendorOrderNumber], --Use vendor order number of bill so we could know what bills owns this, this only applicable for existing imported
				[apegl_dist_no]		=	C.[apegl_dist_no]		,
				[apegl_alt_cbk_no]	=	C.[apegl_alt_cbk_no]	,
				[apegl_gl_acct]		=	C.[apegl_gl_acct]		,
				[apegl_gl_amt]		=	C.[apegl_gl_amt]		,
				[apegl_gl_un]		=	C.[apegl_gl_un]			,
				[A4GLIdentity]		=	C.[A4GLIdentity]		,
				[intBillDetailId]	=	(SELECT intBillDetailId FROM tblAPBillDetail WHERE intBillId = A.intBillId AND intLineNo = C.apegl_dist_no)
			FROM tblAPBill A
			INNER JOIN tblAPVendor B
				ON A.intEntityVendorId = B.intEntityVendorId
			INNER JOIN (tblAPaptrxmst C2 INNER JOIN apeglmst C 
						ON C2.aptrx_ivc_no = C.apegl_ivc_no 
						AND C2.aptrx_vnd_no = C.apegl_vnd_no
						AND C2.aptrx_cbk_no = C.apegl_cbk_no
						AND C2.aptrx_trans_type = C.apegl_trx_ind)
			ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C2.aptrx_ivc_no
				AND B.strVendorId COLLATE Latin1_General_CS_AS = C2.aptrx_vnd_no
			WHERE A.ysnOrigin = 1 AND A.ysnPosted = 0
			ORDER BY C.apegl_dist_no
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
		)
		OUTPUT sourceData.A4GLIdentity INTO @insertedUnpostedBillDetail;
		SET @totalBackupedUnpostedBillDetails = @@ROWCOUNT;
		SET IDENTITY_INSERT tblAPapeglmst OFF

		PRINT 'End backing up imported unposted bill details'

		DELETE FROM apeglmst
		WHERE A4GLIdentity IN (SELECT A4GLIdentity FROM @insertedUnpostedBillDetail)

		DECLARE @totalDeletedUnpostedBillDetail INT = @@ROWCOUNT;
		IF @totalBackupedUnpostedBillDetails != @totalDeletedUnpostedBillDetail
		BEGIN
			RAISERROR('Unexpected number of rows deleted from apeglmst', 16, 1);
		END

		IF @transCount = 0 COMMIT TRANSACTION
	END TRY
	BEGIN CATCH
		PRINT 'Failed to back up imported bill details'
		IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	END CATCH
END