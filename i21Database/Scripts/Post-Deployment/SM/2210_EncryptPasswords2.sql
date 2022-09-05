GO
PRINT('/*******************  BEGIN PASSWORD ENCRYPTION 2 *******************/')

UPDATE		tblGRUserPreference
SET			strProviderPassword = dbo.fnAESEncryptASym(ISNULL(strProviderPassword, ''))
WHERE		dbo.fnAESDecryptASym(strProviderPassword) IS NULL

PRINT('/*******************  END PASSWORD ENCRYPTION 2 *******************/')

GO