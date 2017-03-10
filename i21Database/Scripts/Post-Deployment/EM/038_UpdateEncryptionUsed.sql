

PRINT ('*****BEGIN CHECKING EM change use encryption*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'EM change use encryption')
begin
	begin transaction
	PRINT ('*****RUNNING EM CHANGE USE ENCRYPTION*****')
	begin try
		OPEN SYMMETRIC KEY i21EncryptionSymKey
		DECRYPTION BY CERTIFICATE i21EncryptionCert
		WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='



		OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
			DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd 
			WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='


			PRINT ('*****BEGIN EM change use encryption FROM ENTITY CREDENTIAL*****')
			select * into tblEMEntityCredentialBackUpForEncryption from tblEMEntityCredential

	
			update tblEMEntityCredential set strPassword = dbo.fnAESEncryptASym(dbo.fnAESDecrypt(strPassword))


			IF EXISTS(select a.strPassword, b.strPassword, dbo.fnAESDecrypt(a.strPassword), dbo.fnAESDecryptASym(b.strPassword) from tblEMEntityCredentialBackUpForEncryption a
				join tblEMEntityCredential b 
					on a.intEntityCredentialId = b.intEntityCredentialId
						where dbo.fnAESDecrypt(a.strPassword) <> dbo.fnAESDecryptASym(b.strPassword))
			BEGIN
				RAISERROR ('THERE ARE DISCREPANCIES IN THE ENCRYPTION DATA FOR ENTITY CREDENTIAL', -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
			END
	


			PRINT ('*****END EM change use encryption FROM ENTITY CREDENTIAL*****')
			PRINT ('*****BEGIN EM change use encryption FROM ENTITY EFT INFORMATION*****')
			select * into tblEMEntityEFTInformationBackupForEncryption from tblEMEntityEFTInformation

			update tblEMEntityEFTInformation set strAccountNumber = dbo.fnAESEncryptASym(dbo.fnAESDecrypt(strAccountNumber))

			IF EXISTS(select a.strAccountNumber, b.strAccountNumber, dbo.fnAESDecrypt(a.strAccountNumber), dbo.fnAESDecryptASym(b.strAccountNumber) from tblEMEntityEFTInformation b
				join tblEMEntityEFTInformationBackupForEncryption a
					on a.intEntityEFTInfoId = b.intEntityEFTInfoId
						WHERE dbo.fnAESDecrypt(a.strAccountNumber) <> dbo.fnAESDecryptASym(b.strAccountNumber) )
			BEGIN
				RAISERROR ('THERE ARE DISCREPANCIES IN THE ENCRYPTION DATA FOR EFT INFORMATION', -- Message text.
				   16, -- Severity.
				   1 -- State.
				   );
			END			

			PRINT ('*****END EM change use encryption FROM ENTITY EFT INFORMATION*****')


		CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

		CLOSE SYMMETRIC KEY i21EncryptionSymKey

		PRINT ('*****END CHECKING EM change use encryption*****')

		INSERT INTO tblEMEntityPreferences(strPreference,strValue)
		select 'EM change use encryption', '1'
		
		commit transaction
		
	end try
	begin catch
		DECLARE @msg nvarchar(max)
		set @msg = ERROR_MESSAGE()
		declare @number int
		set @number = 16
		select @msg, @number
		RAISERROR(@msg, @number, 1)
		rollback transaction
	end catch
end
PRINT ('*****END CHECKING EM change use encryption*****')