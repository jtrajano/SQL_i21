PRINT '********************** BEGIN moving entries in Quote Pages to Letters **********************'
GO
IF (EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblARQuotePage') AND EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblSMLetter'))
	BEGIN
		IF EXISTS(SELECT TOP 1 NULL FROM tblARQuotePage)	
		BEGIN
			INSERT INTO tblSMLetter (
				  strName
				, strDescription
				, blbMessage
				, strModuleName
				, ysnSystemDefined
				, intSourceLetterId
				, intConcurrencyId
			)
			SELECT strPageTitle
				 , strPageDescription
				 , blbMessage	= CONVERT(VARBINARY(MAX), strPageBody)
				 , 'Sales'
				 , 0
				 , NULL
				 , 1 
			FROM tblARQuotePage
		END
	END
GO
PRINT ' ********************** END moving entries in Quote Pages to Letters **********************'