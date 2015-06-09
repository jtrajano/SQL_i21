PRINT '******   Check if futures broker is not yet run   ******'

IF NOT EXISTS (SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Move futures broker' AND strValue = '1')
BEGIN

	PRINT '******   Move futures broker data   ******'
	IF OBJECT_ID('tempdb..#tmpEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table broker data'
		DROP TABLE #tmpEntity
	END 


	SELECT intEntityId INTO #tmpEntity FROM tblEntityType 
								WHERE strType = 'Futures Broker'
									AND intEntityId NOT IN ( SELECT intEntityId FROM tblEntityToContact)


	DECLARE @intEntityId INT
	DECLARE @intEntityContactId INT
	DECLARE @intEntityLocationId INT

	WHILE(EXISTS(SELECT TOP 1 1 FROM #tmpEntity))
	BEGIN
		SELECT TOP 1 @intEntityId = intEntityId from #tmpEntity
	
		SET @intEntityContactId = null
		SET @intEntityLocationId = null

		INSERT INTO tblEntity(strName, strContactNumber, strEmail, strPhone, strPhone2, strFax)	
		SELECT ISNULL(strBrokerName,''), 
				ISNULL(strBrokerName,''),
				ISNULL(strEmail,''), 
				ISNULL(intPhone,''), 
				ISNULL(intAltPhone,''), 
				ISNULL(intFax,'')
					FROM tblRKBroker 
						WHERE intEntityId = @intEntityId
	
		SELECT @intEntityContactId = @@IDENTITY

		SELECT @intEntityLocationId = intEntityLocationId 
			FROM tblEntityLocation 
				WHERE intEntityId = @intEntityId
					and ysnDefaultLocation = 1

	
		INSERT INTO tblEntityToContact ( intEntityId, intEntityContactId, intEntityLocationId, ysnDefaultContact, ysnPortalAccess, intConcurrencyId)
		VALUES ( @intEntityId, @intEntityContactId, @intEntityLocationId, 1, 0, 0)
	

		DELETE from #tmpEntity WHERE intEntityId = @intEntityId
	END

	IF OBJECT_ID('tempdb..#tmpEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table broker data'
		DROP TABLE #tmpEntity
	END 


	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Move futures broker', '1' )
END