CREATE TRIGGER trgCMInsteadOfInsertBank
			ON [dbo].tblCMBank
			INSTEAD OF INSERT
			AS
			BEGIN

			SET NOCOUNT ON

			 --For Encryption and Decryption
			-- OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
			-- DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd
			-- WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

				-- Proceed in inserting the record the base table (tblCMBank)
				INSERT INTO tblCMBank (
					[strBankName]
				   ,[strContact]
				   ,[strAddress]
				   ,[strZipCode]
				   ,[strCity]
				   ,[strState]
				   ,[strCountry]
				   ,[strPhone]
				   ,[strFax]
				   ,[strWebsite]
				   ,[strEmail]
				   ,[strRTN]
				   ,[intCreatedUserId]
				   ,[dtmCreated]
				   ,[intLastModifiedUserId]
				   ,[dtmLastModified]
				   ,[ysnDelete]
				   ,[dtmDateDeleted]
				   ,[intConcurrencyId]
				)
				OUTPUT 	inserted.intBankId
				SELECT	[strBankName]			= i.strBankName
						,[strContact]			= i.strContact
						,[strAddress]			= i.strAddress
						,[strZipCode]			= i.strZipCode
						,[strCity]				= i.strCity
						,[strState]				= i.strState
						,[strCountry]			= i.strCountry
						,[strPhone]				= i.strPhone
						,[strFax]				= i.strFax
						,[strWebsite]			= i.strWebsite
						,[strEmail]				= i.strEmail
						,[strRTN]				= [dbo].fnAESEncryptASym(i.strRTN)
						,[intCreatedUserId]		= i.intCreatedUserId
						,[dtmCreated]			= i.dtmCreated
						,[intLastModifiedUserId]= i.intLastModifiedUserId
						,[dtmLastModified]		= i.dtmLastModified
						,[ysnDelete]			= i.ysnDelete
						,[dtmDateDeleted]		= i.dtmDateDeleted
						,[intConcurrencyId]		= i.intConcurrencyId
				FROM	inserted i

				IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			EXIT_TRIGGER:

			-- CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
END