GO
	IF EXISTS(SELECT * FROM tblSMCompanyPreference WHERE LEN(strMerchantPassword) < 30)
	BEGIN
		UPDATE t SET strMerchantPassword = dbo.fnAESEncryptASym(strMerchantPassword)
		FROM tblSMCompanyPreference t
	END
GO