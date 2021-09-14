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
DECLARE @ysnPreNoteSent AS NVARCHAR(100)
DECLARE @strDistributionType AS NVARCHAR(100)	
DECLARE @dblAmount AS FLOAT(50)
DECLARE @intOrder AS INT
DECLARE @ysnActive AS NVARCHAR(100)	

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
							,@dtmEffectiveDate
							,CASE WHEN @ysnActive = 'Y' THEN 1 ELSE 0 END
							,CASE WHEN @ysnPreNoteSent = 'Y' THEN 1 ELSE 0 END
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

					DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @intEntityNo
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
							dtmEffectiveDate = @dtmEffectiveDate,
							ysnActive = CASE WHEN @ysnActive = 'Y' THEN 1 ELSE 0 END,
							ysnPrenoteSent = CASE WHEN @ysnPreNoteSent = 'Y' THEN 1 ELSE 0 END,
							ysnPrintNotifications = 0,
							dblAmount = @dblAmount, 
							intOrder = @intOrder,
							ysnPullTaxSeparately = 0,
							ysnRefundBudgetCredits = 0,
							strDistributionType = @strDistributionType
						WHERE intEntityEFTInfoId = @NewId


						--======================Close symmetric code snnipet=====================
						CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

					DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @intEntityNo

			END



	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDirectDeposit')) 
	DROP TABLE #TempEmployeeDirectDeposit
END

GO
