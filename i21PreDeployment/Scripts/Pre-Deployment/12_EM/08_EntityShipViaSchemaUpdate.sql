PRINT '*** CHECKING ENTITY SHIP VIA ***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMShipVia')  AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMShipVia' and [COLUMN_NAME] = 'intEntityShipViaId') 
BEGIN
	PRINT '*** UPDATING ENTITY SHIP VIA ***'
	DECLARE @ShipViaConstraint TABLE(
		Stement		NVARCHAR(MAX)
	)		
	DECLARE @CurStatement NVARCHAR(MAX)
	INSERT INTO @ShipViaConstraint
	SELECT
			'ALTER TABLE ' + R.TABLE_NAME + ' DROP CONSTRAINT [' + R.CONSTRAINT_NAME + ']'
			+ ' ; UPDATE B SET B.' + R.COLUMN_NAME + ' = A.intEntityShipViaId FROM tblSMShipVia A JOIN ' + R.TABLE_NAME + ' B ON A.intShipViaID = B.' + R.COLUMN_NAME   Stement
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
		WHERE U.TABLE_NAME = 'tblSMShipVia' 


	DECLARE @CurShipViaId INT	

	IF OBJECT_ID('tempdb..#TmpShipVia') IS NOT NULL
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
		SET @CurStatement = ''
		SELECT TOP 1 @CurShipViaId = intShipViaID FROM #TmpShipVia where intEntityId is null

		EXEC uspSMGetStartingNumber 43, @StartingNumber output
		
		select @Name = strShipVia from #TmpShipVia WHERE intShipViaID = @CurShipViaId 

		INSERT INTO tblEntity(strName,strEntityNo,strContactNumber)
		VALUES (@Name, @StartingNumber, '')
		
		SET @EntityId = @@IDENTITY

		INSERT INTO tblEntity(strName,strContactNumber)
		VALUES (@Name, '')

		SET @EntityContactId = @@IDENTITY		

		select @Address = strAddress, 
				@City = strCity, 
				@State = strState, 
				@ZipCode = strZipCode from #TmpShipVia WHERE intShipViaID = @CurShipViaId

		INSERT INTO tblEntityLocation(intEntityId, strLocationName,strAddress,strCity,strState,strZipCode,ysnDefaultLocation )
		select @EntityId, @Name,@Address,@City,@State,@ZipCode,1

		INSERT INTO tblEntityType(intEntityId , strType, intConcurrencyId)
		VALUES( @EntityId, 'Ship Via',0 ) 

		INSERT INTO tblEntityToContact(intEntityId,intEntityContactId,ysnDefaultContact,ysnPortalAccess)
		VALUES(@EntityId, @EntityContactId, 1 ,0 ) 
		

		UPDATE #TmpShipVia set  intEntityId = @EntityId WHERE intShipViaID = @CurShipViaId

		SET @CurStatement = '
		UPDATE A SET A.intEntityShipViaId  = ' + CAST(@EntityId AS NVARCHAR) + '
			FROM tblSMShipVia A
				WHERE  A.intShipViaID = ' + CAST(@CurShipViaId AS NVARCHAR) 

		EXEC (@CurStatement)

	END	

	
	

	WHILE EXISTS(SELECT TOP 1 1 FROM @ShipViaConstraint)
	BEGIN
		SET @CurStatement = ''
		SELECT TOP 1 @CurStatement = Stement  FROM @ShipViaConstraint

		EXEC (@CurStatement)

		DELETE FROM @ShipViaConstraint WHERE Stement = @CurStatement
	END

END
PRINT '*** END CHECKING ENTITY SHIP VIA ***'