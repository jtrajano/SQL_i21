PRINT '******   Check if Terminal is not yet run   ******'

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Move Terminal' AND strValue = '1')
BEGIN

	PRINT '******   Move Terminal data   ******'
	IF OBJECT_ID('tempdb..#tmpTerminalEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table Terminal data'
		DROP TABLE #tmpTerminalEntity
	END 


	SELECT intEntityId INTO #tmpTerminalEntity FROM [tblEMEntityType] 
								WHERE strType = 'Terminal'
									AND intEntityId NOT IN ( SELECT intEntityId FROM [tblEMEntityToContact])


	DECLARE @intTerminalEntityId INT
	DECLARE @intTerminalEntityContactId INT
	DECLARE @intTerminalEntityLocationId INT

	WHILE(EXISTS(SELECT TOP 1 1 FROM #tmpTerminalEntity))
	BEGIN
		SELECT TOP 1 @intTerminalEntityId = intEntityId from #tmpTerminalEntity
	
		SET @intTerminalEntityContactId = null
		SET @intTerminalEntityLocationId = null

				
		INSERT INTO tblEMEntity(strName, strContactNumber, strEmail, strPhone, strMobile, strFax, strNotes)	
		SELECT ISNULL(strName,''), 
				'', -- we do not need this because we only added this to map Origin Contact to i21 contact 
				ISNULL(strEmail,''), 
				ISNULL(strPhone,''), 
				ISNULL(strMobile,''), 
				ISNULL(strFax,''), 
				ISNULL(strNotes,'')
			FROM tblLGTerminal 
				WHERE intEntityId = @intTerminalEntityId
		SELECT @intTerminalEntityContactId = @@IDENTITY

		SELECT @intTerminalEntityLocationId = intEntityLocationId 
			FROM [tblEMEntityLocation] 
				WHERE intEntityId = @intTerminalEntityId
					and ysnDefaultLocation = 1

	
		INSERT INTO [tblEMEntityToContact] ( intEntityId, intEntityContactId, intEntityLocationId, ysnDefaultContact, ysnPortalAccess, intConcurrencyId)
		VALUES ( @intTerminalEntityId, @intTerminalEntityContactId, @intTerminalEntityLocationId, 1, 0, 0)
		

		DELETE from #tmpTerminalEntity WHERE intEntityId = @intTerminalEntityId
	END

	IF OBJECT_ID('tempdb..#tmpTerminalEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table Terminal data'
		DROP TABLE #tmpTerminalEntity
	END 
	
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Move Terminal', '1' )
END