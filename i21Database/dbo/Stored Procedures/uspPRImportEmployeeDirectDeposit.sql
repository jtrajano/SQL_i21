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
DECLARE @strEmployeeId AS NVARCHAR(100)
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
DECLARE @EmployeeCount AS INT
DECLARE @BankCount AS INT

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
	   LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo) 
	   WHERE SE.guiApiUniqueId = @guiApiUniqueId
	   AND SE.intEntityNo IS NULL

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDirectDeposit')) 
	DROP TABLE #TempEmployeeDirectDeposit

	SELECT * INTO #TempEmployeeDirectDeposit FROM tblApiSchemaEmployeeDirectDeposit where guiApiUniqueId = @guiApiUniqueId

	WHILE EXISTS(SELECT TOP 1 NULL FROM #TempEmployeeDirectDeposit)
	BEGIN
		SET @strEmployeeId = NULL
		SET @intEntityNo = NULL
		SET @strBankName = NULL
		SET @strAccountNumber = NULL
		SET @strAccountType = NULL
		SET @strClassification = NULL
		SET @dtmEffectiveDate	= NULL
		SET @ysnPreNoteSent = NULL
		SET @strDistributionType = NULL
		SET @dblAmount	= NULL
		SET @intOrder	= NULL
		SET @ysnActive	= NULL
		SET @EmployeeEntityNo = NULL

		SELECT TOP 1 
			 @strEmployeeId = LTRIM(RTRIM(intEntityNo))
			,@intEntityNo = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE LTRIM(RTRIM(strEmployeeId)) = LTRIM(RTRIM(intEntityNo))) 
			,@strBankName = strBankName
			,@strAccountNumber = strAccountNumber
			,@strAccountType = CASE WHEN strAccountType <> '' AND strAccountType IN('Checking','Savings') THEN strAccountType ELSE '' END
			,@strClassification = CASE WHEN strClassification <> '' AND strClassification IN('Personal','Corporate') THEN strClassification ELSE '' END
			,@dtmEffectiveDate	= dtmEffectiveDate
			,@ysnPreNoteSent = ysnPreNoteSent
			,@strDistributionType = CASE WHEN strDistributionType <> '' AND strDistributionType IN('Fixed Amount','Percent','Remainder') THEN strDistributionType ELSE '' END
			,@dblAmount	= dblAmount
			,@intOrder	= intOrder
			,@ysnActive	= ysnActive
		FROM #TempEmployeeDirectDeposit
		


		SELECT TOP 1 @EmployeeEntityNo = COUNT(intEntityId)
		FROM tblEMEntityEFTInformation
		WHERE intEntityId = @intEntityNo
		  AND intBankId = (SELECT TOP 1 intBankId FROM tblCMBank where LTRIM(RTRIM(strBankName)) = LTRIM(RTRIM(@strBankName)))
		  AND dbo.fnAESDecryptASym(strAccountNumber) = @strAccountNumber


		IF (@strBankName IS NOT NULL AND @strBankName != '')
		BEGIN
			IF (@strAccountType IS NOT NULL AND @strAccountType != '')
			BEGIN
				IF (@strAccountNumber IS NOT NULL AND @strAccountNumber != '')
					BEGIN
						IF(@strDistributionType IS NOT NULL AND @strDistributionType != '')
						BEGIN
							IF(@strClassification IS NOT NULL AND @strClassification != '')
							BEGIN
								IF (@EmployeeEntityNo = 0)
									BEGIN
										SELECT TOP 1 @EmployeeCount = COUNT(intEntityId) FROM tblPREmployee WHERE intEntityId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE LTRIM(RTRIM(strEmployeeId)) = @strEmployeeId)

										IF @EmployeeCount != 0
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
													,(SELECT TOP 1 intBankId FROM tblCMBank where LTRIM(RTRIM(strBankName)) = LTRIM(RTRIM(@strBankName)))
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
										LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = (SELECT TOP 1 intEntityId FROM tblPREmployee WHERE strEmployeeId = SE.intEntityNo) 
										WHERE SE.guiApiUniqueId = @guiApiUniqueId
										AND SE.strBankName = @strBankName
										AND SE.strAccountNumber = @strAccountNumber


										DELETE FROM #TempEmployeeDirectDeposit WHERE LTRIM(RTRIM(intEntityNo)) = LTRIM(RTRIM(@strEmployeeId)) AND LTRIM(RTRIM(strBankName)) = LTRIM(RTRIM(@strBankName)) AND LTRIM(RTRIM(strAccountNumber)) = LTRIM(RTRIM(@strAccountNumber))
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
													AND intBankId = (SELECT TOP 1 intBankId FROM tblCMBank where LTRIM(RTRIM(strBankName)) = LTRIM(RTRIM(@strBankName)))
													AND dbo.fnAESDecryptASym(strAccountNumber) = @strAccountNumber
													AND strAccountType = @strAccountType

												--======================Close symmetric code snnipet=====================
												CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

											INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
											SELECT TOP 1
												NEWID()
												, guiApiImportLogId = @guiLogId
												, strField = 'Employee Direct Deposit'
												, strValue = SE.strBankName + ' - ' + SE.strAccountNumber
												, strLogLevel = 'Info'
												, strStatus = 'Success'
												, intRowNo = SE.intRowNumber
												, strMessage = 'The employee direct deposit has been successfully updated.'
											FROM tblApiSchemaEmployeeDirectDeposit SE
											LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = @intEntityNo
											WHERE SE.guiApiUniqueId = @guiApiUniqueId
											AND SE.strBankName = @strBankName
											AND SE.strAccountNumber = @strAccountNumber

											DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @strEmployeeId AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType

									END
							END

							ELSE
							BEGIN
								INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
								SELECT TOP 1
									NEWID()
									, guiApiImportLogId = @guiLogId
									, strField = 'Employee Direct Deposit'
									, strValue = @strClassification
									, strLogLevel = 'Error'
									, strStatus = 'Failed'
									, intRowNo = SE.intRowNumber
									, strMessage = 'Account Classification is on wrong format. Please try again.'
								FROM tblApiSchemaEmployeeDirectDeposit SE
								LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = @intEntityNo
								WHERE SE.guiApiUniqueId = @guiApiUniqueId
								AND SE.strBankName = @strBankName
								AND SE.strAccountNumber = @strAccountNumber

								DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @strEmployeeId AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType
							END

							
						END
						ELSE
						BEGIN
							INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
							SELECT TOP 1
								NEWID()
								, guiApiImportLogId = @guiLogId
								, strField = 'Employee Direct Deposit'
								, strValue = @strDistributionType
								, strLogLevel = 'Error'
								, strStatus = 'Failed'
								, intRowNo = SE.intRowNumber
								, strMessage = 'Distribution Type is on wrong format. Please try again.'
							FROM tblApiSchemaEmployeeDirectDeposit SE
							LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = @intEntityNo
							WHERE SE.guiApiUniqueId = @guiApiUniqueId
							AND SE.strBankName = @strBankName
							AND SE.strAccountNumber = @strAccountNumber

							DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @strEmployeeId AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType
						END
					END
				ELSE
				BEGIN
					INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
					SELECT TOP 1
						  NEWID()
						, guiApiImportLogId = @guiLogId
						, strField = 'Employee Direct Deposit'
						, strValue = @strAccountNumber
						, strLogLevel = 'Error'
						, strStatus = 'Failed'
						, intRowNo = SE.intRowNumber
						, strMessage = 'Account Number is on wrong format. Please try again.'
					FROM tblApiSchemaEmployeeDirectDeposit SE
					LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = @intEntityNo
					WHERE SE.guiApiUniqueId = @guiApiUniqueId
					AND SE.strBankName = @strBankName
					AND SE.strAccountNumber = @strAccountNumber

					DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @strEmployeeId AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType
				END
			END

			ELSE
			BEGIN
				INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
				SELECT TOP 1
					  NEWID()
					, guiApiImportLogId = @guiLogId
					, strField = 'Employee Direct Deposit'
					, strValue = @strAccountType
					, strLogLevel = 'Error'
					, strStatus = 'Failed'
					, intRowNo = SE.intRowNumber
					, strMessage = 'Account Type is on wrong format. Please try again.'
				FROM tblApiSchemaEmployeeDirectDeposit SE
				LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = @intEntityNo
				WHERE SE.guiApiUniqueId = @guiApiUniqueId
				AND SE.strBankName = @strBankName
				AND SE.strAccountNumber = @strAccountNumber

				DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @strEmployeeId AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType
			END
		END
		ELSE
		BEGIN
			INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId,guiApiImportLogId, strField,strValue,strLogLevel,strStatus,intRowNo,strMessage)
			SELECT
				guiApiImportLogDetailId = NEWID()
			   ,guiApiImportLogId = @guiLogId
			   ,strField		= 'Bank Name'
			   ,strValue		= SE.strBankName
			   ,strLogLevel		= 'Error'
			   ,strStatus		= 'Failed'
			   ,intRowNo		= SE.intRowNumber
			   ,strMessage		= 'Cannot find Bank Details. Bank name is invalid.'
				FROM tblApiSchemaEmployeeDirectDeposit SE
				LEFT JOIN tblEMEntityEFTInformation E ON E.intEntityId = @intEntityNo
				WHERE SE.guiApiUniqueId = @guiApiUniqueId
				AND SE.strBankName = @strBankName
				AND SE.strAccountNumber = @strAccountNumber

			   DELETE FROM #TempEmployeeDirectDeposit WHERE intEntityNo = @strEmployeeId AND strBankName = @strBankName AND strAccountNumber = @strAccountNumber AND strAccountType = @strAccountType
		END

	END

	IF EXISTS (SELECT 1 FROM tempdb..sysobjects WHERE id = OBJECT_ID('tempdb..#TempEmployeeDirectDeposit')) 
	DROP TABLE #TempEmployeeDirectDeposit
END

GO
