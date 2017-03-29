GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuAPOriginCCDTransaction')
	DROP VIEW vyuAPOriginCCDTransaction

	EXEC ('
	CREATE VIEW [dbo].[vyuAPOriginCCDTransaction]
	AS
	
	WITH APOriginCCDTransaction AS (
	SELECT			DISTINCT
					[intEntityVendorId]		=	D.intEntityId, 
					[strVendorOrderNumber] 	=	(CASE WHEN DuplicateData.apivc_ivc_no IS NOT NULL
														THEN dbo.fnTrim(A.apivc_ivc_no) + ''-DUP'' 
														ELSE A.apivc_ivc_no END),
					[intTermsId] 			=	ISNULL((SELECT TOP 1 intTermsId FROM tblEMEntityLocation 
													WHERE intEntityId = (SELECT intEntityId FROM tblAPVendor 
														WHERE strVendorId COLLATE Latin1_General_CS_AS = A.apivc_vnd_no)), (SELECT TOP 1 intTermID FROM tblSMTerm WHERE strTerm = ''Due on Receipt''))
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
					AND 1 = (CASE WHEN 1 = 1 AND A.apivc_comment = ''CCD Reconciliation'' AND A.apivc_status_ind = ''U'' THEN 1
								WHEN 1 = 0 THEN 1	
							ELSE 0 END)
					AND NOT EXISTS(
						SELECT 1 FROM tblAPapivcmst H
						WHERE A.apivc_ivc_no = H.apivc_ivc_no AND A.apivc_vnd_no = H.apivc_vnd_no
					) 
		), Bill AS (
			SELECT  intBillId, strVendorOrderNumber COLLATE Latin1_General_CI_AS AS strVendorOrderNumber FROM tblAPBill 
		)


		SELECT DISTINCT APOriginCCDTransaction.strVendorOrderNumber, Bill.intBillId FROM APOriginCCDTransaction 
		LEFT JOIN Bill ON Bill.strVendorOrderNumber = APOriginCCDTransaction.strVendorOrderNumber COLLATE Latin1_General_CI_AS
		WHERE intBillId IS NULL
		')
END
GO