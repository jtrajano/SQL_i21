GO
	PRINT N'BEGIN ET Company Preference Update'
GO
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnETEnableIntegration' AND OBJECT_ID = OBJECT_ID(N'tblETCompanyPreference')) 
   AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'strIntegration' AND OBJECT_ID = OBJECT_ID(N'tblETCompanyPreference'))
   
    BEGIN
		DECLARE @integration AS NVARCHAR(50) = (SELECT TOP 1 [strIntegration] FROM [tblETCompanyPreference] )
		DECLARE @BasePath AS NVARCHAR(50) = (SELECT TOP 1 [strBasePath] FROM [tblETCompanyPreference] )
		DECLARE @ExportPath AS NVARCHAR(50) = (SELECT TOP 1 [strExportPath] FROM [tblETCompanyPreference] )
		DECLARE @UploadPath AS NVARCHAR(50) = (SELECT TOP 1 [strUploadPath] FROM [tblETCompanyPreference] )
		DECLARE @ArchivePath AS NVARCHAR(50) = (SELECT TOP 1 [strArchivePath] FROM [tblETCompanyPreference] )

		IF @integration = 'Energy Trac'
		BEGIN
			UPDATE [tblETCompanyPreference]
			SET 
			--[strBasePath]  = @BasePath,
			--[strExportPath] = @ExportPath,
			--[strUploadPath] = @UploadPath,
			--[strArchivePath] = @ArchivePath,
			ysnETEnableIntegration = 1
		END
		ELSE IF @integration = 'Base Engineering' 
			BEGIN
				UPDATE [tblETCompanyPreference]
				SET [strBEBasePath]  = @BasePath
				,[strBEExportPath] = @ExportPath
				,[strBEUploadPath] = @UploadPath
				,[strBEArchivePath] = @ArchivePath
				,ysnBEEnableIntegration = 1
			END
		ELSE IF @integration = 'Digital Dispatcher' 
			BEGIN
				UPDATE [tblETCompanyPreference]
				SET [strDDBasePath]  = @BasePath
				,[strDDExportPath] = @ExportPath
				,[strDDUploadPath] = @UploadPath
				,[strDDArchivePath] = @ArchivePath
				,ysnDDEnableIntegration = 1
			END

		UPDATE tblETCompanyPreference SET strIntegration = '' 
    END
GO
	PRINT N'END ET Company Preference Update'
GO
