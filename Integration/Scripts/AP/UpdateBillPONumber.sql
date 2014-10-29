--http://jira.irelyserver.com/browse/AP-533
--Fix PO Number of Bills

IF EXISTS(SELECT * FROM sys.columns WHERE [name] = N'strPONumber' AND [object_id] = OBJECT_ID(N'tblAPBill'))
BEGIN

	EXEC ('

		IF EXISTS(SELECT 1 FROM tblAPBill WHERE ISNULL(strPONumber,'''') = '''')
		BEGIN

			UPDATE A
				SET A.strPONumber = C.aptrx_pur_ord_no
			FROM tblAPBill A
					INNER JOIN tblAPVendor B ON A.intVendorId = B.intVendorId
					INNER JOIN tblAPaptrxmst C ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C.aptrx_ivc_no
											AND B.strVendorId COLLATE Latin1_General_CS_AS = C.aptrx_vnd_no

			UPDATE A
				SET A.strPONumber = C.apivc_pur_ord_no
			FROM tblAPBill A
					INNER JOIN tblAPVendor B ON A.intVendorId = B.intVendorId
					INNER JOIN apivcmst C ON A.strVendorOrderNumber COLLATE Latin1_General_CS_AS = C.apivc_ivc_no
											AND B.strVendorId COLLATE Latin1_General_CS_AS = C.apivc_vnd_no

		END

	')

END
