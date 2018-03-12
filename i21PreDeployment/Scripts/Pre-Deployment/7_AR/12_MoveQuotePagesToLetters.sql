PRINT '********************** BEGIN moving entries in Quote Pages to Letters **********************'
GO
IF (EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblARQuotePage') AND EXISTS(SELECT NULL FROM sys.tables WHERE [name] = N'tblSMLetter'))
	BEGIN
		IF EXISTS(SELECT TOP 1 NULL FROM tblARQuotePage)	
		BEGIN
			IF EXISTS (SELECT NULL FROM INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS WHERE CONSTRAINT_NAME ='FK_tblARQuoteTemplateDetail_tblARQuotePage')
			
			DECLARE @strQuery NVARCHAR(MAX) = CAST('' AS NVARCHAR(MAX)) + '
			ALTER TABLE tblARQuoteTemplateDetail DROP CONSTRAINT FK_tblARQuoteTemplateDetail_tblARQuotePage

			WHILE EXISTS (SELECT TOP 1 NULL FROM tblARQuotePage)
				BEGIN
					DECLARE @strPageTitle		NVARCHAR(MAX)	= NULL
						  , @strPageDescription	NVARCHAR(MAX)	= NULL
						  , @blbMessage			VARBINARY(MAX)	= NULL
						  , @intQuotePageId		INT				= NULL
						  , @intNewLetterId		INT				= NULL

					SELECT TOP 1 @intQuotePageId		= intQuotePageId
							   , @strPageTitle			= strPageTitle
							   , @strPageDescription	= strPageDescription
							   , @blbMessage			= CONVERT(VARBINARY(MAX), CAST(strPageBody AS VARCHAR(MAX)))
					FROM tblARQuotePage 
					ORDER BY intQuotePageId

					IF EXISTS (SELECT TOP 1 NULL FROM tblSMLetter WHERE strName = @strPageTitle)
						SET @strPageTitle = ''DUP: ''+ @strPageTitle

					INSERT INTO tblSMLetter (
						  strName
						, strDescription
						, blbMessage
						, strModuleName
						, ysnSystemDefined
						, intSourceLetterId
						, intConcurrencyId
					)
					SELECT @strPageTitle
						, @strPageDescription
						, @blbMessage
						, ''Sales''
						, 0
						, NULL
						, 1

					SET @intNewLetterId = SCOPE_IDENTITY()

					IF COL_LENGTH(''tblARQuoteTemplateDetail'', ''intQuotePageId'') IS NOT NULL 
					BEGIN
						UPDATE tblARQuoteTemplateDetail 
						SET intQuotePageId = @intNewLetterId 
						WHERE intQuotePageId = @intQuotePageId
					END

					DELETE FROM tblARQuotePage WHERE intQuotePageId = @intQuotePageId
				END

			UPDATE tblARQuoteTemplateDetail
			SET intQuotePageId = NULL
			WHERE intQuotePageId NOT IN (SELECT intLetterId FROM tblSMLetter)'

			EXEC sp_executesql @strQuery
		END
	END
GO
PRINT ' ********************** END moving entries in Quote Pages to Letters **********************'