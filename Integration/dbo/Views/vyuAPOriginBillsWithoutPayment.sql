GO


IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCMBankAccount')
	DROP VIEW vyuCMBankAccount
GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
EXEC ('
		CREATE VIEW [dbo].[vyuAPOriginBillsWithoutPayment]
		AS
		SELECT
		A.*
		FROM apivcmst A
		WHERE NOT EXISTS(
			SELECT * FROM apchkmst B 
			WHERE B.apchk_vnd_no = A.apivc_vnd_no
						AND B.apchk_chk_no = A.apivc_chk_no
						AND B.apchk_rev_dt = A.apivc_chk_rev_dt
						AND B.apchk_cbk_no = A.apivc_cbk_no)
				')
END