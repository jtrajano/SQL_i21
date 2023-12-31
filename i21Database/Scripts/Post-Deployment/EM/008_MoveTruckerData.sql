﻿PRINT '******   Check if Trucker is not yet run   ******'

IF NOT EXISTS (SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = 'Move Trucker' AND strValue = '1')
BEGIN

	PRINT '******   Move Trucker data   ******'
	IF OBJECT_ID('tempdb..#tmpTruckerEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table Trucker data'
		DROP TABLE #tmpTruckerEntity
	END 


	SELECT intEntityId INTO #tmpTruckerEntity FROM [tblEMEntityType] 
								WHERE strType = 'Trucker'
									AND intEntityId NOT IN ( SELECT intEntityId FROM [tblEMEntityToContact])


	DECLARE @intTruckerLineEntityId INT
	DECLARE @intTruckerEntityContactId INT
	DECLARE @intTruckerEntityLocationId INT

	WHILE(EXISTS(SELECT TOP 1 1 FROM #tmpTruckerEntity))
	BEGIN
		SELECT TOP 1 @intTruckerLineEntityId = intEntityId from #tmpTruckerEntity
	
		SET @intTruckerEntityContactId = null
		SET @intTruckerEntityLocationId = null

				
		INSERT INTO tblEMEntity(strName, strContactNumber, strEmail, strPhone, strPhone2, strFax, strNotes, strEmail2, ysnActive)	
		SELECT ISNULL(strName,''), 
				'',
				ISNULL(strEmail,''), 
				ISNULL(strPhone,''), 
				ISNULL(strAltPhone,''), 
				ISNULL(strFax,''),
				ISNULL(strNotes,''),
				ISNULL(strAltEmail,''),
				ysnActive
			FROM tblLGTrucker 
				WHERE intEntityId = @intTruckerLineEntityId
		SELECT @intTruckerEntityContactId = @@IDENTITY

		SELECT @intTruckerEntityLocationId = intEntityLocationId 
			FROM [tblEMEntityLocation] 
				WHERE intEntityId = @intTruckerLineEntityId
					and ysnDefaultLocation = 1

	
		INSERT INTO [tblEMEntityToContact] ( intEntityId, intEntityContactId, intEntityLocationId, ysnDefaultContact, ysnPortalAccess, intConcurrencyId)
		VALUES ( @intTruckerLineEntityId, @intTruckerEntityContactId, @intTruckerEntityLocationId, 1, 0, 0)
		

		DELETE from #tmpTruckerEntity WHERE intEntityId = @intTruckerLineEntityId
	END

	IF OBJECT_ID('tempdb..#tmpTruckerEntity') IS NOT NULL 
	BEGIN
		PRINT 'Dropping table Trucker data'
		DROP TABLE #tmpTruckerEntity
	END 
	
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('Move Trucker', '1' )
END