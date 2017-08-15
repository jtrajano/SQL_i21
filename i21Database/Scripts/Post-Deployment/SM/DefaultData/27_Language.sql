GO
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMLanguage WHERE intLanguageId = 1)
	BEGIN
		SET IDENTITY_INSERT [dbo].[tblSMLanguage] ON

		INSERT INTO [tblSMLanguage] ([intLanguageId], [strLanguage], [ysnDefault], [intConcurrencyId])
		VALUES (1, 'English', 1, 1)

		SET IDENTITY_INSERT [dbo].[tblSMLanguage] OFF
	END
GO