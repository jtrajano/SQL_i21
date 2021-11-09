CREATE PROCEDURE dbo.uspPRImportEmployeeDirectDeposit(
    @guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId UNIQUEIDENTIFIER 
)

AS

BEGIN

--DECLARE @guiApiUniqueId UNIQUEIDENTIFIER = N'1B25ED1B-079F-4827-B36F-31488D1C88E7'
--DECLARE @guiLogId UNIQUEIDENTIFIER = NEWID()
DECLARE @NewId AS INT
DECLARE @EmployeeEntityNo AS INT

DECLARE @intEntityNo AS INT
DECLARE @strBankName AS NVARCHAR(100)
DECLARE @strAccountNumber AS NVARCHAR(100)
DECLARE @strAccountType AS NVARCHAR(100)
DECLARE @strClassification AS NVARCHAR(100)
DECLARE @dtmEffectiveDate AS NVARCHAR(100)	
DECLARE @ysnPreNoteSent AS BIT
DECLARE @strDistributionType AS NVARCHAR(100)	
DECLARE @dblAmount AS FLOAT(50)
DECLARE @intOrder AS INT
DECLARE @ysnActive AS BIT

	INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
	SELECT
		guiApiImportLogDetailId = NEWID()
	   ,guiApiImportLogId = @guiLogId
	   ,strField		= 'Employee ID'
	   ,strValue		= SE.intEntityNo
	   ,strLogLevel		= 'Error'
	   ,strStatus		= 'Failed'
	   ,intRowNo		= SE.intRowNumber
	   ,strMessage		= 'Cannot find the Employee Entity No: '+ CAST(ISNULL(SE.intEntityNo, '') AS NVARCHAR(100)) + '.'
	   FROM tblApiSchemaEmployeeDirectDeposit SE
	   LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = SE.intEntityNo
	   WHERE SE.guiApiUniqueId = @guiApiUniqueId
	   AND SE.intEntityNo IS NULL

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDirectDeposit')) 
	DROP TABLE #TempEmployeeDirectDeposit

	SELECT * INTO #TempEmployeeDirectDeposit FROM tblApiSchemaEmployeeDirectDeposit where guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDirectDeposit)
	BEGIN
		SELECT TOP 1 
			 @intEntityNo = intEntityNo
			,@strBankName = strBankName
			,@strAccountNumber = strAccountNumber
			,@strAccountType = strAccountType
			,@strClassification = strClassification
			,@dtmEffectiveDate	= dtmEffectiveDate
			,@ysnPreNoteSent = ysnPreNoteSent
			,@strDistributionType = strDistributionType
			,@dblAmount	= dblAmount
			,@intOrder	= intOrder
			,@ysnActive	= ysnActive
		FROM #TempEmployeeDirectDeposit

		SELECT TOP 1 @EmployeeEntityNo = intEntityId
		FROM tblEMEntityEFTInformation
		WHERE intEntityId = @intEntityNo
		  AND intBankId = (SELECT TOP 1 intBankId FROM tblCMBank where strBankName = @strBankName)

		IF @EmployeeEntityNo IS NULL
			BEGIN
				--======================Open symmetric code snipet=====================
						 OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
						 DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
						 WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

						INSERT INTO tblEMEntityEFTInformation(
							intEntityId, 
							intBankId, 
							strBankName, 
							strAccountNumber, 
							strAccountType,
							strAccountClassification, 
							dtmEffectiveDate,
							ysnActive,
							ysnPrenoteSent,
							intConcurrencyId, 
							ysnPrintNotifications,
							dblAmount, 
							intOrder,
							ysnPullTaxSeparately,
							ysnRefundBudgetCredits,
							strDistributionType)
						VALUES
						(
							 @intEntityNo
							,(SELECT TOP 1 intBankId FROM tblCMBank where strBankName = @strBankName)
							,@strBankName
							,dbo.fnAESEncryptASym(@strAccountNumber)
							,@strAccountType
							,@strClassification
							,CAST(@dtmEffectiveDate as date)
							,@ysnActive
							,@ysnPreNoteSent
							,1
							,0
							,@dblAmount
							,@intOrder
							,0
							,0
							,@strDistributionType

						)
						--======================Close symmetric code snnipet=====================
						CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
						SET @NewId = SCOPE_IDENTITY()

					DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @intEntityNo AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType
			END
		ELSE
			BEGIN
					--======================Open symmetric code snipet=====================
						 OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
						 DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
						 WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

						 UPDATE tblEMEntityEFTInformation SET
							intBankId = (SELECT TOP 1 intBankId FROM tblCMBank where strBankName = @strBankName), 
							strBankName = @strBankName, 
							strAccountNumber = dbo.fnAESEncryptASym(@strAccountNumber), 
							strAccountType = @strAccountType,
							strAccountClassification = @strClassification, 
							dtmEffectiveDate = CAST(@dtmEffectiveDate as date),
							ysnActive = @ysnActive,
							ysnPrenoteSent = @ysnPreNoteSent,
							ysnPrintNotifications = 0,
							dblAmount = @dblAmount, 
							intOrder = @intOrder,
							ysnPullTaxSeparately = 0,
							ysnRefundBudgetCredits = 0,
							strDistributionType = @strDistributionType
						WHERE intEntityId = @intEntityNo 
							AND intBankId = (SELECT TOP 1 intBankId FROM tblCMBank where strBankName = @strBankName)
							AND dbo.fnAESDecryptASym(strAccountNumber) = @strAccountNumber
							AND strAccountType = @strAccountType

						--======================Close symmetric code snnipet=====================
						CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

					DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @intEntityNo AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType

			END

		INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
		SELECT TOP 1
			  NEWID()
			, guiApiImportLogId = @guiLogId
			, strField = 'Employee Direct Deposit'
			, strValue = SE.strBankName + ' - ' + SE.strAccountNumber
			, strLogLevel = 'Info'
			, strStatus = 'Success'
			, intRowNo = SE.intRowNumber
			, strMessage = 'The employee direct deposit has been successfully imported.'
		FROM tblApiSchemaEmployeeDirectDeposit SE
		LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = SE.intEntityNo
		WHERE SE.guiApiUniqueId = @guiApiUniqueId
		AND SE.strBankName = @strBankName
		AND SE.strAccountNumber = @strAccountNumber
	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDirectDeposit')) 
	DROP TABLE #TempEmployeeDirectDeposit
END

GO
