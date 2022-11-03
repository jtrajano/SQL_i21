﻿CREATE TABLE [dbo].[tblCMBank] (
    [intBankId]             INT            IDENTITY (1, 1) NOT NULL,
    [strBankName]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NOT NULL,
    [strContact]            NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [strAddress]            NVARCHAR (65)  COLLATE Latin1_General_CI_AS NULL,
    [strZipCode]            NVARCHAR (42)  COLLATE Latin1_General_CI_AS NULL,
    [strCity]               NVARCHAR (85)  COLLATE Latin1_General_CI_AS NULL,
    [strState]              NVARCHAR (60)  COLLATE Latin1_General_CI_AS NULL,
    [strCountry]            NVARCHAR (75)  COLLATE Latin1_General_CI_AS NULL,
    [strPhone]              NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strFax]                NVARCHAR (30)  COLLATE Latin1_General_CI_AS NULL,
    [strWebsite]            NVARCHAR (125) COLLATE Latin1_General_CI_AS NULL,
    [strEmail]              NVARCHAR (225) COLLATE Latin1_General_CI_AS NULL,
    [strRTN]                NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[strIBAN]				VARCHAR (40) COLLATE Latin1_General_CI_AS NULL,
	[strSwiftCode]			VARCHAR (11) COLLATE Latin1_General_CI_AS NULL,
	[strBICCode]			VARCHAR (8) COLLATE Latin1_General_CI_AS NULL,
    [intCreatedUserId]      INT            NULL,
    [dtmCreated]            DATETIME       NULL,
    [intLastModifiedUserId] INT            NULL,
    [dtmLastModified]       DATETIME       NULL,
	[ysnDelete]				BIT            NULL,
	[dtmDateDeleted]		DATETIME	   NULL,
	[ysnInternational]		BIT			   NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblCMBank] PRIMARY KEY CLUSTERED ([intBankId] ASC)
);

GO
CREATE TRIGGER trgInsteadOfInsertCMBank
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
				   ,[strIBAN]
				   ,[strSwiftCode]
				   ,[strBICCode]
				   ,[intCreatedUserId]
				   ,[dtmCreated]
				   ,[intLastModifiedUserId]
				   ,[dtmLastModified]
				   ,[ysnDelete]
				   ,[dtmDateDeleted]
				   ,[ysnInternational]
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
						,[strRTN]               = CASE WHEN LEN(i.strRTN) > 300  THEN i.strRTN ELSE [dbo].fnAESEncryptASym(i.strRTN) END
						,[strIBAN]				= i.strIBAN	
				   		,[strSwiftCode]			= i.strSwiftCode
				   		,[strBICCode]			= i.strBICCode
						,[intCreatedUserId]		= i.intCreatedUserId
						,[dtmCreated]			= i.dtmCreated
						,[intLastModifiedUserId]= i.intLastModifiedUserId
						,[dtmLastModified]		= i.dtmLastModified
						,[ysnDelete]			= i.ysnDelete
						,[dtmDateDeleted]		= i.dtmDateDeleted
						,[ysnInternational]		= i.ysnInternational
						,[intConcurrencyId]		= i.intConcurrencyId
				FROM	inserted i

				IF @@ERROR <> 0 GOTO EXIT_TRIGGER
			EXIT_TRIGGER:

			-- CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym
END

GO
CREATE TRIGGER trgInsteadOfUpdateCMBank
   ON  dbo.tblCMBank
   INSTEAD OF UPDATE
AS
BEGIN
    -- SET NOCOUNT ON added to prevent extra result sets from
    -- interfering with SELECT statements.
    SET NOCOUNT ON;

    --For Encryption and Decryption
	-- OPEN SYMMETRIC KEY i21EncryptionSymKeyByASym
	-- DECRYPTION BY ASYMMETRIC KEY i21EncryptionASymKeyPwd
	-- WITH PASSWORD = 'neYwLw+SCUq84dAAd9xuM1AFotK5QzL4Vx4VjYUemUY='

    UPDATE tblCMBank SET
    strBankName           	= i.strBankName
    ,strContact             = i.strContact
    ,strAddress             = i.strAddress
    ,strZipCode             = i.strZipCode
    ,strCity              	= i.strCity
    ,strState              	= i.strState
    ,strCountry             = i.strCountry
    ,strPhone              	= i.strPhone
    ,strFax                 = i.strFax
    ,strWebsite             = i.strWebsite
    ,strEmail              	= i.strEmail
    ,strRTN                 = CASE WHEN LEN(i.strRTN) > 300  THEN i.strRTN ELSE [dbo].fnAESEncryptASym(i.strRTN) END
	,[strIBAN]				= i.strIBAN	
	,[strSwiftCode]			= i.strSwiftCode
	,[strBICCode]			= i.strBICCode
    ,intCreatedUserId      	= i.intCreatedUserId
    ,dtmCreated             = i.dtmCreated
    ,intLastModifiedUserId	= i.intLastModifiedUserId
    ,dtmLastModified      	= i.dtmLastModified
    ,ysnDelete              = i.ysnDelete
    ,dtmDateDeleted         = i.dtmDateDeleted
	,ysnInternational		= i.ysnInternational
    ,intConcurrencyId      	= i.intConcurrencyId
    FROM inserted i
    WHERE tblCMBank.intBankId = i.intBankId

    UPDATE tblCMBankAccount SET
    strContact =  i.strContact
    ,strAddress = i.strAddress
    ,strZipCode = i.strZipCode
    ,strCity    = i.strCity
    ,strState   = i.strState
    ,strCountry = i.strCountry
    ,strPhone   = i.strPhone
    ,strFax       = i.strFax
    ,strWebsite = i.strWebsite
    ,strEmail   = i.strEmail
	,strRTN     = CASE WHEN LEN(i.strRTN) > 300  THEN i.strRTN ELSE [dbo].fnAESEncryptASym(i.strRTN) END
	
    FROM inserted i
    WHERE tblCMBankAccount.intBankId = i.intBankId

	-- CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

END
GO

