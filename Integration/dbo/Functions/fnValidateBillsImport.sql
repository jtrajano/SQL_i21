CREATE FUNCTION [dbo].[fnValidateBillsImport]
(
	@userId INT
)
RETURNS @returntable TABLE
(
    [strDescription] NVARCHAR(200) NULL, 
    [strError] NVARCHAR(1000) NULL,
	[ysnWarning] BIT NOT NULL DEFAULT 0
)
AS
BEGIN
	
	--THERE SHOULD BE A USER BEFORE IMPORTING
	IF (@userId <= 0)
	BEGIN
		INSERT INTO @returntable
		SELECT
			'Importing requires user id'
			,'User Id ' + @userId + ' not found.'	
			,0
	END

	IF NOT EXISTS(SELECT 1 FROM tblSMPaymentMethod WHERE LOWER(strPaymentMethod) = 'check')
	BEGIN
		INSERT INTO @returntable
		SELECT
			'Importing requires check payment method type.'
			,'Check payment method not found.'
			,0
	END

	INSERT INTO @returntable
	SELECT
		'Check book not found.'
		,A.apchk_cbk_no
		,0
	FROM apchkmst A 
		LEFT JOIN tblCMBankAccount B
			ON A.apchk_cbk_no = B.strCbkNo COLLATE Latin1_General_CS_AS
		WHERE B.strCbkNo IS NULL

	INSERT INTO @returntable
	SELECT 
		'Missing i21 account from apeglmst'
		,apegl_gl_acct 
		,0
	FROM apeglmst                                                                                               
	WHERE apegl_gl_acct NOT IN (SELECT DISTINCT strExternalId FROM tblGLCOACrossReference)                      
	UNION ALL                      
	SELECT 
		'Missing i21 account from aphglmst'
		,aphgl_gl_acct
		,0
	FROM aphglmst                                                                                               
	WHERE aphgl_gl_acct NOT IN (SELECT DISTINCT strExternalId FROM tblGLCOACrossReference)

	INSERT INTO @returntable
	SELECT
		'Duplicate vendor number found in aptrxmst'
		,A.aptrx_ivc_no
		,1
	FROM aptrxmst A
	WHERE EXISTS(
		SELECT 1 FROM tblAPBill B
			INNER JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON C.intEntityId = D.intEntityId) 
			ON B.intEntityVendorId = C.intEntityId
		WHERE A.aptrx_ivc_no = B.strVendorOrderNumber COLLATE Latin1_General_CS_AS
		AND A.aptrx_vnd_no = C.strVendorId COLLATE Latin1_General_CS_AS
	)
	UNION ALL
	SELECT
		'Duplicate vendor number found in apivcmst'
		,A.apivc_ivc_no
		,1
	FROM apivcmst A
	WHERE EXISTS(
		SELECT 1 FROM tblAPBill B
			INNER JOIN (tblAPVendor C INNER JOIN tblEMEntity D ON C.intEntityId = D.intEntityId) 
			ON B.intEntityVendorId = C.intEntityId
		WHERE A.apivc_ivc_no = B.strVendorOrderNumber COLLATE Latin1_General_CS_AS
		AND A.apivc_vnd_no = C.strVendorId COLLATE Latin1_General_CS_AS
	)

	INSERT INTO @returntable
	SELECT 
		'Total amount did not match between aptrxmst and apeglmst'
		,'Vendor ' + A.aptrx_vnd_no + ', order number ' + A.aptrx_ivc_no
		,1
	FROM aptrxmst A
	OUTER APPLY(
		SELECT SUM(B.apegl_gl_amt) AS dblDetailTotal
		FROM apeglmst B 
		WHERE A.aptrx_ivc_no = B.apegl_ivc_no 
			AND A.aptrx_vnd_no = B.apegl_vnd_no
			AND A.aptrx_cbk_no = B.apegl_cbk_no
			AND A.aptrx_trans_type = B.apegl_trx_ind
	) billDetails
	WHERE ISNULL(billDetails.dblDetailTotal,0) != A.aptrx_orig_amt
	UNION ALL
	SELECT 
		'Total amount did not match between apivcmst and aphglmst'
		,'Vendor ' + A.apivc_vnd_no + ', order number ' + A.apivc_ivc_no
		,1
	FROM apivcmst A 
	OUTER APPLY (
		SELECT SUM(B.aphgl_gl_amt) AS dblDetailTotal
		FROM aphglmst B
		WHERE A.apivc_ivc_no = B.aphgl_ivc_no 
		AND A.apivc_vnd_no = B.aphgl_vnd_no
		AND A.apivc_cbk_no = B.aphgl_cbk_no
		AND A.apivc_trans_type = B.aphgl_trx_ind
	) billDetails
	WHERE ISNULL(billDetails.dblDetailTotal,0) != A.apivc_orig_amt
	
	RETURN;

END