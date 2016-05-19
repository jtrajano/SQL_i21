GO

IF  (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AP') = 1
BEGIN
IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuCMBankTransaction')
	DROP VIEW vyuCMBankTransaction

	EXEC ('
		CREATE VIEW [dbo].[vyuCMBankTransaction]
		AS 

		SELECT 
		*,
		ysnPayeeEFTInfoActive = ISNULL((
				SELECT TOP 1 ysnActive FROM tblEntityEFTInformation EFTInfo 
				WHERE intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),0),
		strPayeeEFTInfoEffective = ISNULL((
				SELECT TOP 1 (CASE WHEN dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) THEN ''EFFECTIVE'' ELSE ''INEFFECTIVE'' END)  FROM tblEntityEFTInformation EFTInfo 
				WHERE intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),''INVALID''),
		ysnPrenoteSent = ISNULL((
				SELECT TOP 1 ysnPrenoteSent FROM tblEntityEFTInformation EFTInfo 
				WHERE intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),0),
		strAccountType = ISNULL((
				SELECT TOP 1 strAccountType FROM tblEntityEFTInformation EFTInfo 
				WHERE intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),''),
		strPayeeBankName = ISNULL((
				SELECT TOP 1 strBankName FROM tblEntityEFTInformation EFTInfo 
				WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),''),
		strPayeeBankAccountNumber  = ISNULL((
				SELECT TOP 1 strAccountNumber FROM tblEntityEFTInformation EFTInfo 
				WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),''),
		strPayeeBankRoutingNumber = ISNULL((
				SELECT TOP 1 strRTN FROM tblEntityEFTInformation EFTInfo 
				INNER JOIN tblCMBank BANK ON EFTInfo.intBankId = BANK.intBankId
				WHERE EFTInfo.ysnActive = 1 AND dtmEffectiveDate >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0) AND intEntityId = intPayeeId ORDER BY dtmEffectiveDate desc
		),''),
		strEntityNo = ISNULL((
				SELECT strEntityNo FROM tblEntity
				WHERE intEntityId = intPayeeId
		),''),
		strSocialSecurity = ISNULL((
				SELECT Emp.strSocialSecurity FROM 
				tblPRPaycheck PayCheck  INNER JOIN
				tblPREmployee Emp ON PayCheck.intEntityEmployeeId = Emp.intEntityEmployeeId
				WHERE PayCheck.strPaycheckId = tblCMBankTransaction.strTransactionId 
		),'')
		FROM tblCMBankTransaction
		WHERE --dbo.fnIsDepositEntry(strLink) = 0
		strLink NOT IN (
							SELECT
							( CAST(a.apchk_cbk_no AS NVARCHAR(2)) 
											+ CAST(a.apchk_rev_dt AS NVARCHAR(10)) 
											+ CAST(a.apchk_trx_ind AS NVARCHAR(1)) 
											+ CAST(a.apchk_chk_no AS NVARCHAR(8))
								) COLLATE Latin1_General_CI_AS
							FROM apchkmst a INNER JOIN aptrxmst b
										ON a.apchk_cbk_no = b.aptrx_cbk_no
										AND a.apchk_chk_no = b.aptrx_chk_no
										AND a.apchk_trx_ind = b.aptrx_trans_type			
										AND a.apchk_rev_dt = b.aptrx_chk_rev_dt
										AND a.apchk_vnd_no = b.aptrx_vnd_no
							WHERE	 b.aptrx_trans_type = ''O'' -- Other CW transactions
					)
		')

END
GO