PRINT '******   Check if Shipping Line is not yet run   ******'

IF NOT EXISTS (SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Move Shipping Line' AND strValue = '1')
BEGIN

	PRINT '******   Move Shipping Line data   ******'
	IF OBJECT_ID('tempdb..#tmpShippingLineEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table Shipping Line data'
		DROP TABLE #tmpShippingLineEntity
	END 


	SELECT intEntityId INTO #tmpShippingLineEntity FROM tblEntityType 
								WHERE strType = 'Shipping Line'
									AND intEntityId NOT IN ( SELECT intEntityId FROM tblEntityToContact)


	DECLARE @intShippingLineEntityId INT
	DECLARE @intShippingLineEntityContactId INT
	DECLARE @intShippingLineEntityLocationId INT

	WHILE(EXISTS(SELECT TOP 1 1 FROM #tmpShippingLineEntity))
	BEGIN
		SELECT TOP 1 @intShippingLineEntityId = intEntityId from #tmpShippingLineEntity
	
		SET @intShippingLineEntityContactId = null
		SET @intShippingLineEntityLocationId = null

				
		INSERT INTO tblEntity(strName, strContactNumber, strEmail, strPhone, strPhone2, strFax, strNotes, strEmail2, ysnActive)	
		SELECT ISNULL(strName,''), 
				'',
				ISNULL(strEmail,''), 
				ISNULL(strPhone,''), 
				ISNULL(strAltPhone,''), 
				ISNULL(strFax,''),
				ISNULL(strNotes,''),
				ISNULL(strAltEmail,''),
				ysnActive
			FROM tblLGShippingLine 
				WHERE intEntityId = @intShippingLineEntityId
		SELECT @intShippingLineEntityContactId = @@IDENTITY

		SELECT @intShippingLineEntityLocationId = intEntityLocationId 
			FROM tblEntityLocation 
				WHERE intEntityId = @intShippingLineEntityId
					and ysnDefaultLocation = 1

	
		INSERT INTO tblEntityToContact ( intEntityId, intEntityContactId, intEntityLocationId, ysnDefaultContact, ysnPortalAccess, intConcurrencyId)
		VALUES ( @intShippingLineEntityId, @intShippingLineEntityContactId, @intShippingLineEntityLocationId, 1, 0, 0)
		

		DELETE from #tmpShippingLineEntity WHERE intEntityId = @intShippingLineEntityId
	END

	IF OBJECT_ID('tempdb..#tmpShippingLineEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table Shipping Line data'
		DROP TABLE #tmpShippingLineEntity
	END 
	
	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Move Shipping Line', '1' )
END