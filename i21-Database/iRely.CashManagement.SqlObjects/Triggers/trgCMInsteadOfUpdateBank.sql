CREATE TRIGGER trgCMInsteadOfUpdateBank
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
    strBankName           = i.strBankName
    ,strContact              = i.strContact
    ,strAddress              = i.strAddress
    ,strZipCode              = i.strZipCode
    ,strCity              = i.strCity
    ,strState              = i.strState
    ,strCountry              = i.strCountry
    ,strPhone              = i.strPhone
    ,strFax                  = i.strFax
    ,strWebsite              = i.strWebsite
    ,strEmail              = i.strEmail
    ,strRTN                  = CASE WHEN i.strRTN = tblCMBank.strRTN THEN i.strRTN ELSE [dbo].fnAESEncryptASym(i.strRTN) END
    ,intCreatedUserId      = i.intCreatedUserId
    ,dtmCreated              = i.dtmCreated
    ,intLastModifiedUserId= i.intLastModifiedUserId
    ,dtmLastModified      = i.dtmLastModified
    ,ysnDelete              = i.ysnDelete
    ,dtmDateDeleted          = i.dtmDateDeleted
    ,intConcurrencyId      = i.intConcurrencyId
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
	,strRTN        = CASE WHEN i.strRTN = tblCMBankAccount.strRTN THEN i.strRTN ELSE [dbo].fnAESEncryptASym(i.strRTN) END
    FROM inserted i
    WHERE tblCMBankAccount.intBankId = i.intBankId

	-- CLOSE SYMMETRIC KEY i21EncryptionSymKeyByASym

END
GO
