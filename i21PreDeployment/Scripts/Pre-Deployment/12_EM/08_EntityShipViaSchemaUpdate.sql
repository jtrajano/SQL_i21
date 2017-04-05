declare @build_m int
set @build_m = 0

if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMBuildNumber' and [COLUMN_NAME] = 'strVersionNo')
BEGIN

	exec sp_executesql N'select @build_m = intVersionID from tblSMBuildNumber where strVersionNo like ''%16.1%'' '  , 
		N'@build_m int output', @build_m output;
END
if @build_m = 0
BEGIN


	PRINT '*** CHECKING ENTITY SHIP VIA ***'

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strEntityNo')
		BEGIN
			EXEC('ALTER TABLE tblEMEntity ADD strEntityNo NVARCHAR(MAX)')
		END

		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strContactNumber')
		BEGIN
			EXEC('ALTER TABLE tblEMEntity ADD strContactNumber NVARCHAR(MAX)')
		END

	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'ysnDefaultContact')
		BEGIN
			EXEC('ALTER TABLE tblEMEntityLocation ADD ysnDefaultContact BIT')
		END
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact')
	BEGIN
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'intEntityContactId')
		BEGIN
			EXEC('ALTER TABLE tblEMEntityToContact ADD intEntityContactId INT')
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'ysnDefaultContact')
		BEGIN
			EXEC('ALTER TABLE tblEMEntityToContact ADD ysnDefaultContact BIT')
		END
		IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess')
		BEGIN
			EXEC('ALTER TABLE tblEMEntityToContact ADD ysnPortalAccess BIT')
		END
	END

	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMShipVia')  
	AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMShipVia' and [COLUMN_NAME] = 'intEntityShipViaId')

	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strEntityNo') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strContactNumber') 

	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'ysnDefaultContact') 

	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'intEntityContactId') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'ysnDefaultContact') 
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess') 
 
	BEGIN
		PRINT '*** UPDATING ENTITY SHIP VIA ***'

		EXEC( '

		DECLARE @ShipViaConstraint TABLE(
			Stement		NVARCHAR(MAX)
		)		
		DECLARE @CurStatement NVARCHAR(MAX)
		INSERT INTO @ShipViaConstraint
		SELECT
				''ALTER TABLE '' + R.TABLE_NAME + '' DROP CONSTRAINT ['' + R.CONSTRAINT_NAME + '']''
				+ '' ; UPDATE B SET B.'' + R.COLUMN_NAME + '' = A.intEntityShipViaId FROM tblSMShipVia A JOIN '' + R.TABLE_NAME + '' B ON A.intShipViaID = B.'' + R.COLUMN_NAME   Stement
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
			INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
				ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
				AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
				AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
				ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
				AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
				AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
			WHERE U.TABLE_NAME = ''tblSMShipVia'' 


		DECLARE @CurShipViaId INT	

		IF OBJECT_ID(''tempdb..#TmpShipVia'') IS NOT NULL
			DROP TABLE #TmpShipVia

		SELECT * INTO #TmpShipVia FROM tblSMShipVia

		ALTER TABLE #TmpShipVia 
		ADD intEntityId INT

		DECLARE @StartingNumber NVARCHAR(MAX)
		DECLARE @EntityId int
		DECLARE @EntityContactId int
		DECLARE @EntityLocationId int
		DECLARE @Name NVARCHAR(100)

		DECLARE @Address NVARCHAR(MAX)
		DECLARE @City NVARCHAR(MAX)
		DECLARE @State NVARCHAR(MAX)
		DECLARE @ZipCode NVARCHAR(MAX)

		ALTER TABLE tblSMShipVia 
		ADD intEntityShipViaId INT 

		WHILE EXISTS ( SELECT TOP 1 1 FROM  #TmpShipVia where intEntityId is null)
		BEGIN 
			SET @CurStatement = ''''
			SELECT TOP 1 @CurShipViaId = intShipViaID FROM #TmpShipVia where intEntityId is null

			EXEC uspSMGetStartingNumber 43, @StartingNumber output
		
			select @Name = strShipVia from #TmpShipVia WHERE intShipViaID = @CurShipViaId 

			INSERT INTO tblEMEntity(strName,strEntityNo,strContactNumber)
			VALUES (@Name, @StartingNumber, '''')
		
			SET @EntityId = @@IDENTITY

			INSERT INTO tblEMEntity(strName,strContactNumber)
			VALUES (@Name, '''')

			SET @EntityContactId = @@IDENTITY		

			select @Address = strAddress, 
					@City = strCity, 
					@State = strState, 
					@ZipCode = strZipCode from #TmpShipVia WHERE intShipViaID = @CurShipViaId

			INSERT INTO tblEMEntityLocation(intEntityId, strLocationName,strAddress,strCity,strState,strZipCode,ysnDefaultLocation )
			select @EntityId, @Name,@Address,@City,@State,@ZipCode,1

			INSERT INTO tblEMEntityType(intEntityId , strType, intConcurrencyId)
			VALUES( @EntityId, ''Ship Via'',0 ) 

			INSERT INTO tblEMEntityToContact(intEntityId,intEntityContactId,ysnDefaultContact,ysnPortalAccess)
			VALUES(@EntityId, @EntityContactId, 1 ,0 ) 
		

			UPDATE #TmpShipVia set  intEntityId = @EntityId WHERE intShipViaID = @CurShipViaId

			SET @CurStatement = ''
			UPDATE A SET A.intEntityShipViaId  = '' + CAST(@EntityId AS NVARCHAR) + ''
				FROM tblSMShipVia A
					WHERE  A.intShipViaID = '' + CAST(@CurShipViaId AS NVARCHAR) 

			EXEC (@CurStatement)

		END	

	
	

		WHILE EXISTS(SELECT TOP 1 1 FROM @ShipViaConstraint)
		BEGIN
			SET @CurStatement = ''''
			SELECT TOP 1 @CurStatement = Stement  FROM @ShipViaConstraint

			EXEC (@CurStatement)

			DELETE FROM @ShipViaConstraint WHERE Stement = @CurStatement
		END

		')
	END
	PRINT '*** END CHECKING ENTITY SHIP VIA ***'

END

GO
