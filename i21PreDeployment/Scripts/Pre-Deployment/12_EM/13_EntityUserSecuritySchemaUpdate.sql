PRINT '*** CHECKING ENTITY USER SECURITY***'

PRINT '*** CHECKING ENTITY ***'

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity')
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strEntityNo')
	BEGIN
		EXEC('ALTER TABLE tblEntity ADD strEntityNo NVARCHAR(MAX)')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strContactNumber')
	BEGIN
		EXEC('ALTER TABLE tblEntity ADD strContactNumber NVARCHAR(MAX)')
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strContactType')
	BEGIN
		EXEC('ALTER TABLE tblEntity ADD strContactType NVARCHAR(50)')
	END

END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation')
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation' and [COLUMN_NAME] = 'ysnDefaultContact')
	BEGIN
		EXEC('ALTER TABLE tblEntityLocation ADD ysnDefaultContact BIT')
	END

END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact')
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'intEntityContactId')
	BEGIN
		EXEC('ALTER TABLE tblEntityToContact ADD intEntityContactId INT')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnDefaultContact')
	BEGIN
		EXEC('ALTER TABLE tblEntityToContact ADD ysnDefaultContact BIT')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess')
	BEGIN
		EXEC('ALTER TABLE tblEntityToContact ADD ysnPortalAccess BIT')
	END
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity')  
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intUserSecurityIdOld')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intUserSecurityID')
	BEGIN
		PRINT '*** CHECKING FOR OLD ID PLACE HOLDER ***'
		EXEC('ALTER TABLE tblSMUserSecurity ADD intUserSecurityIdOld int null')

		EXEC(' UPDATE tblSMUserSecurity set intUserSecurityIdOld = intUserSecurityID ')

		PRINT '** DUPLICATING Id To Old Id ***'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityId')
	BEGIN
		PRINT '*** CHECKING FOR Entity ***'
		EXEC('ALTER TABLE tblSMUserSecurity ADD intEntityId int null')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityIdOld')
	
	BEGIN
		PRINT '*** CHECKING FOR OLD Entity ID PLACE HOLDER ***'
		EXEC('ALTER TABLE tblSMUserSecurity ADD intEntityIdOld int null')

		EXEC(' UPDATE tblSMUserSecurity set intEntityIdOld = intEntityId ')

		PRINT '** DUPLICATING Id To Old Entity Id ***'
	END
END

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity')  
AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityUserSecurityId')

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strEntityNo') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strContactNumber') 

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation' and [COLUMN_NAME] = 'ysnDefaultContact') 

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'intEntityContactId') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnDefaultContact') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess') 
 
BEGIN
	PRINT '*** UPDATING ENTITY User Security***'

	EXEC( '

	DECLARE @UserSecurityConstraint TABLE(
		Stement		NVARCHAR(MAX)
	)		
	DECLARE @CurStatement NVARCHAR(MAX)
	INSERT INTO @UserSecurityConstraint
	SELECT
			''ALTER TABLE '' + R.TABLE_NAME + '' DROP CONSTRAINT ['' + R.CONSTRAINT_NAME + '']''
			+ '' ; UPDATE B SET B.'' + R.COLUMN_NAME + '' = A.intEntityId FROM tblSMUserSecurity A JOIN '' + R.TABLE_NAME + '' B ON A.intUserSecurityID = B.'' + R.COLUMN_NAME   Stement
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
		WHERE U.TABLE_NAME = ''tblSMUserSecurity'' 

	
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''tblSMUserSecurity'' and [COLUMN_NAME] = ''intEntityUserSecurityId'') 
	BEGIN
		ALTER TABLE tblSMUserSecurity
		ADD intEntityUserSecurityId INT NULL
	END

	EXEC(''UPDATE tblSMUserSecurity SET intEntityUserSecurityId = intEntityId'')
	
	--SELECT * FROM @UserSecurityConstraint
	DECLARE @CurUserSecurityId	INT	
	DECLARE @CurEntityId		INT

	IF OBJECT_ID(''tempdb..#tmpUserSecurity'') IS NOT NULL
		DROP TABLE #tmpUserSecurity

	SELECT * INTO #tmpUserSecurity FROM tblSMUserSecurity

	DECLARE @StartingNumber NVARCHAR(MAX)
	DECLARE @EntityId int
	DECLARE @EntityContactId int
	DECLARE @EntityLocationId int
	DECLARE @Name NVARCHAR(100)

	DECLARE @Address NVARCHAR(MAX)
	DECLARE @City NVARCHAR(MAX)
	DECLARE @State NVARCHAR(MAX)
	DECLARE @ZipCode NVARCHAR(MAX)

	WHILE EXISTS ( SELECT TOP 1 1 FROM  #tmpUserSecurity)
	BEGIN 
		SET @CurStatement = ''''
		SELECT TOP 1 
			@CurUserSecurityId	= intUserSecurityID,
			@CurEntityId		= intEntityId	
		FROM #tmpUserSecurity

		SELECT @Name = strName FROM tblEntity where intEntityId = @CurEntityId
		SET @EntityId = @CurEntityId

		INSERT INTO tblEntity(strName,strContactNumber)
		VALUES (@Name, '''')

		SET @EntityContactId = @@IDENTITY		

		INSERT INTO tblEntityLocation(intEntityId, strLocationName, ysnDefaultLocation )
		select @EntityId, @Name,1

		IF NOT EXISTS ( SELECT TOP 1 1 FROM tblEntityType where intEntityId = @EntityId)
		BEGIN
			INSERT INTO tblEntityType(intEntityId , strType, intConcurrencyId)
			VALUES( @EntityId, ''User'',0 ) 
		END

		INSERT INTO tblEntityToContact(intEntityId,intEntityContactId,ysnDefaultContact,ysnPortalAccess)
		VALUES(@EntityId, @EntityContactId, 1 ,0 ) 		

		DELETE FROM #tmpUserSecurity where intEntityId = @CurEntityId
	END	

	WHILE EXISTS(SELECT TOP 1 1 FROM @UserSecurityConstraint)
	BEGIN
		SET @CurStatement = ''''
		SELECT TOP 1 @CurStatement = Stement  FROM @UserSecurityConstraint

		EXEC (@CurStatement)

		DELETE FROM @UserSecurityConstraint WHERE Stement = @CurStatement
	END

	-----------------------------------------------------------------------------------------------------------------------------------------
	EXEC(''
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''''tblTMEvent'''' and [COLUMN_NAME] = ''''intUserID'''')
	BEGIN
		UPDATE tblTMEvent SET intUserID = A.intEntityUserSecurityId
		FROM tblSMUserSecurity A
		WHERE tblTMEvent.intUserID = A.intUserSecurityIdOld
	END

	---- Update tblTMDeliveryHistory
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''''tblTMDeliveryHistory'''' and [COLUMN_NAME] = ''''intUserID'''')
	BEGIN
		UPDATE tblTMDeliveryHistory SET intUserID = A.intEntityUserSecurityId
		FROM tblSMUserSecurity A
		WHERE tblTMDeliveryHistory.intUserID = A.intUserSecurityIdOld
		AND A.intUserSecurityIdOld IS NOT NULL
	END

	---- Update tblTMWorkOrder
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''''tblTMWorkOrder'''' and [COLUMN_NAME] = ''''intEnteredByID'''')
	BEGIN
		UPDATE tblTMWorkOrder SET intEnteredByID = A.intEntityUserSecurityId
		FROM tblSMUserSecurity A
		WHERE tblTMWorkOrder.intEnteredByID = A.intUserSecurityIdOld
		AND A.intUserSecurityIdOld IS NOT NULL
	END

	---- Update tblTMSite
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''''tblTMSite'''' and [COLUMN_NAME] = ''''intUserID'''')
	BEGIN
		UPDATE tblTMSite SET intUserID = A.intEntityUserSecurityId
		FROM tblSMUserSecurity A
		WHERE tblTMSite.intUserID = A.intUserSecurityIdOld
		AND A.intUserSecurityIdOld IS NOT NULL
	END

	---- Update tblTMDispatch
	IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = ''''tblTMDispatch'''' and [COLUMN_NAME] = ''''intUserID'''')
	BEGIN
		UPDATE tblTMDispatch SET intUserID = A.intEntityUserSecurityId
		FROM tblSMUserSecurity A
		WHERE tblTMDispatch.intUserID = A.intUserSecurityIdOld
		AND A.intUserSecurityIdOld IS NOT NULL
	END
	'')

	')
	
END
PRINT '*** END CHECKING ENTITY User Security***'

