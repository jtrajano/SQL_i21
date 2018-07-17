PRINT '******   Check if forwarding agent is not yet run   ******'

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Move forwarding agent' AND strValue = '1')
BEGIN

	PRINT '******   Move forwarding agent data   ******'
	IF OBJECT_ID('tempdb..#tmpForwardingAgentEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table forwarding agent data'
		DROP TABLE #tmpForwardingAgentEntity
	END 


	SELECT intEntityId INTO #tmpForwardingAgentEntity FROM [tblEMEntityType] 
								WHERE strType = 'Forwarding Agent'
									AND intEntityId NOT IN ( SELECT intEntityId FROM [tblEMEntityToContact])


	DECLARE @intForwardingAgentEntityId INT
	DECLARE @intFAEntityContactId INT
	DECLARE @intFAEntityLocationId INT

	WHILE(EXISTS(SELECT TOP 1 1 FROM #tmpForwardingAgentEntity))
	BEGIN
		SELECT TOP 1 @intForwardingAgentEntityId = intEntityId from #tmpForwardingAgentEntity
	
		SET @intFAEntityContactId = null
		SET @intFAEntityLocationId = null

				
		INSERT INTO tblEMEntity(strName, strContactNumber, strEmail, strPhone, strPhone2, strFax, strNotes, ysnActive)	
		SELECT ISNULL(strName,''), 
				'',
				ISNULL(strEmail,''), 
				ISNULL(strPhone,''), 
				ISNULL(strAltPhone,''), 
				ISNULL(strFax,''),				
				ISNULL(strNotes,''),
				ysnActive
			FROM tblLGForwardingAgent 
				WHERE intEntityId = @intForwardingAgentEntityId
		SELECT @intFAEntityContactId = @@IDENTITY

		SELECT @intFAEntityLocationId = intEntityLocationId 
			FROM [tblEMEntityLocation] 
				WHERE intEntityId = @intForwardingAgentEntityId
					and ysnDefaultLocation = 1

	
		INSERT INTO [tblEMEntityToContact] ( intEntityId, intEntityContactId, intEntityLocationId, ysnDefaultContact, ysnPortalAccess, intConcurrencyId)
		VALUES ( @intForwardingAgentEntityId, @intFAEntityContactId, @intFAEntityLocationId, 1, 0, 0)
		

		DELETE from #tmpForwardingAgentEntity WHERE intEntityId = @intForwardingAgentEntityId
	END

	IF OBJECT_ID('tempdb..#tmpForwardingAgentEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table forwarding agent data'
		DROP TABLE #tmpForwardingAgentEntity
	END 
	
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Move forwarding agent', '1' )
END
