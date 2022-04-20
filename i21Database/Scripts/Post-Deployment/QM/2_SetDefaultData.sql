print('/*******************  BEGIN - Update Quality Company Preference Default Data *******************/')
GO

IF (EXISTS(SELECT NULL FROM sys.tables WHERE name = N'tblQMCompanyPreference'))
	BEGIN	
		IF (EXISTS(SELECT NULL FROM sys.columns WHERE [name] = N'intCuppingSessionLimit' AND [object_id] = OBJECT_ID(N'tblQMCompanyPreference')))
			EXEC('UPDATE tblQMCompanyPreference SET intCuppingSessionLimit = 18 WHERE ISNULL(intCuppingSessionLimit, 0) = 0');
	END

GO
print('/*******************  END - Update Quality Company Preference Default Data  *******************/')
