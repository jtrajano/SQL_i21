/**
	EXECUTE THIS SCRIPT AFTER THE uspAPImportVoucherBackUpFromAPIVCMST
*/
CREATE PROCEDURE [dbo].[uspAPImportVoucherFromAPIVCMST]
	@UserId INT,
	@DateFrom DATETIME = NULL,
	@DateTo DATETIME = NULL,
	@creditCardOnly BIT = 0,
	@totalImported INT OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

DECLARE @userLocation INT;
DECLARE @defaultTermId INT;
DECLARE @defaultCurrencyId INT;
DECLARE @totalInsertedBill INT;
DECLARE @transCount INT = @@TRANCOUNT;

IF @transCount = 0 BEGIN TRANSACTION

--GET THE USER LOCATION
SELECT @userLocation = A.intCompanyLocationId FROM tblSMCompanyLocation A
	INNER JOIN tblSMUserSecurity B ON A.intCompanyLocationId = B.intCompanyLocationId
WHERE intEntityUserSecurityId = @UserId

--GET DEFAULT TERM TO USE
SELECT TOP 1 @defaultTermId = intTermID FROM tblSMTerm WHERE strTerm = 'Due on Receipt'

--GET DEFAULT CURRENCY TO USE
SELECT TOP 1 @defaultCurrencyId = intCurrencyID FROM tblSMCurrency WHERE strCurrency LIKE '%USD%'

ALTER TABLE tblAPBill DROP CONSTRAINT [UK_dbo.tblAPBill_strBillId]

INSERT INTO tblAPBill
(
	[strMiscDescription]	,
	[dblQtyOrdered]			,
	[dblQtyReceived]		,
	[intAccountId]			,
	[dblTotal]				,
	[dblCost]				,
	[dbl1099]				,
	[int1099Form]			,
	[int1099Category]		,
	[intLineNo]
)
SELECT
	[intEntityVendorId]		=	D.intEntityVendorId, 
	[strVendorOrderNumber] 	=	A.apivc_ivc_no,
	[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEMEntityLocation 
									WHERE intEntityId = (SELECT intEntityVendorId FROM tblAPVendor 
										WHERE strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no)), @defaultTermId),
	[dtmDate] 				=	CASE WHEN ISDATE(A.apivc_gl_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_gl_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmDateCreated] 		=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmBillDate] 			=	CASE WHEN ISDATE(A.apivc_ivc_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_ivc_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[dtmDueDate] 			=	CASE WHEN ISDATE(A.apivc_due_rev_dt) = 1 THEN CONVERT(DATE, CAST(A.apivc_due_rev_dt AS CHAR(12)), 112) ELSE GETDATE() END,
	[intAccountId] 			=	(SELECT TOP 1 inti21Id FROM tblGLCOACrossReference WHERE strExternalId = CAST(B.apcbk_gl_ap AS NVARCHAR(MAX))),
	[strReference] 			=	A.apivc_comment,
	[strPONumber]			=	A.apivc_pur_ord_no,
	[dbl1099]				=	A.apivc_1099_amt,
	[dblTotal] 				=	CASE WHEN A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A' THEN A.apivc_orig_amt
									ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END,
	[dblPayment]			=	CASE WHEN A.apivc_status_ind = 'P' THEN
									CASE WHEN (A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A') THEN A.apivc_orig_amt
										ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
								ELSE 0 END,
	[dblAmountDue]			=	CASE WHEN A.apivc_status_ind = 'P' THEN 0 ELSE 
										CASE WHEN A.apivc_trans_type = 'C' OR A.apivc_trans_type = 'A' THEN A.apivc_orig_amt
											ELSE (CASE WHEN A.apivc_orig_amt < 0 THEN A.apivc_orig_amt * -1 ELSE A.apivc_orig_amt END) END
									END,
	[intEntityId]			=	ISNULL((SELECT intEntityUserSecurityId FROM tblSMUserSecurity WHERE strUserName COLLATE Latin1_General_CS_AS = RTRIM(A.apivc_user_id)),@UserId),
	[ysnPosted]				=	1,
	[ysnPaid]				=	CASE WHEN A.apivc_status_ind = 'P' THEN 1 ELSE 0 END,
	[intTransactionType]	=	CASE WHEN A.apivc_trans_type = 'I' AND A.apivc_orig_amt > 0 THEN 1
										WHEN A.apivc_trans_type = 'O' AND A.apivc_orig_amt > 0 THEN 1
									WHEN A.apivc_trans_type = 'A' THEN 2
									WHEN A.apivc_trans_type = 'C' OR A.apivc_orig_amt < 0 THEN 3
									ELSE 0 END,
	[dblDiscount]			=	ISNULL(A.apivc_disc_avail,0),
	[dblWithheld]			=	A.apivc_wthhld_amt,
	[ysnOrigin]				=	1,
	[intCurrencyId]			=	@defaultCurrencyId,
	[intShipToId]			=	@userLocation,
	[intShipFromId]			=	loc.intEntityLocationId,
	[A4GLIdentity]			=	A.[A4GLIdentity]
FROM ##tmp_apivcmstImport A
	LEFT JOIN apcbkmst B
		ON A.apivc_cbk_no = B.apcbk_no
	INNER JOIN tblAPVendor D
		ON A.apivc_vnd_no = D.strVendorId COLLATE Latin1_General_CS_AS
	LEFT JOIN tblEMEntityLocation loc
		ON D.intEntityVendorId = loc.intEntityId AND loc.ysnDefaultLocation = 1
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
	WHERE 1 = (CASE WHEN @creditCardOnly = 1 AND A.apivc_comment = 'CCD Reconciliation' AND A.apivc_status_ind = 'U' THEN 1
				WHEN @creditCardOnly = 0 THEN 1	
			ELSE 0 END)
	AND NOT EXISTS(
		SELECT 1 FROM tblAPapivcmst H
		WHERE A.apivc_ivc_no = H.apivc_ivc_no AND A.apivc_vnd_no = H.apivc_vnd_no
	)

IF @totalInsertedBill <= 0 
BEGIN
	ALTER TABLE tblAPBill ADD CONSTRAINT [UK_dbo.tblAPBill_strBillId] UNIQUE (strBillId);
	SET @totalImported = 0;
	RETURN;
END

IF @transCount = 0 COMMIT TRANSACTION
END TRY
BEGIN CATCH
	DECLARE @errorBackingUp NVARCHAR(500) = ERROR_MESSAGE();
	ROLLBACK TRANSACTION
	RAISERROR(@errorBackingUp, 16, 1);
END CATCH
