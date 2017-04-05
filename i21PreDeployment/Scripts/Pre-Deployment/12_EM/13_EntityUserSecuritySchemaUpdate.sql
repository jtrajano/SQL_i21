PRINT '*** CHECKING ENTITY USER SECURITY***'

PRINT '*** CHECKING ENTITY ***'

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

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strContactType')
	BEGIN
		EXEC('ALTER TABLE tblEMEntity ADD strContactType NVARCHAR(50)')
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

IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity')  
BEGIN
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intUserSecurityIdOld')
	AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intUserSecurityID')
	BEGIN
		PRINT '*** CHECKING FOR OLD ID PLACE HOLDER ***'
		EXEC('ALTER TABLE tblSMUserSecurity ADD intUserSecurityIdOld int null')

		EXEC(' UPDATE tblSMUserSecurity set intUserSecurityIdOld = intUserSecurityID 
			CREATE NONCLUSTERED INDEX IX_tblSMUserSecurity_intUserSecurityIdOld ON tblSMUserSecurity (intUserSecurityIdOld); 
		
		')

		PRINT '** DUPLICATING Id To Old Id ***'
	END

	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityId')
		AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityUserSecurityId')	
	BEGIN
		PRINT '*** CHECKING FOR Entity ***'
		EXEC('ALTER TABLE tblSMUserSecurity ADD intEntityId int null')
	END
	IF NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityIdOld')
		AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityId')
	BEGIN
		PRINT '*** CHECKING FOR OLD Entity ID PLACE HOLDER ***'
		EXEC('ALTER TABLE tblSMUserSecurity ADD intEntityIdOld int null')

		EXEC(' UPDATE tblSMUserSecurity set intEntityIdOld = intEntityId ')

		PRINT '** DUPLICATING Id To Old Entity Id ***'
	END
END


declare @build_m int
set @build_m = 0

if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMBuildNumber' and [COLUMN_NAME] = 'strVersionNo')
BEGIN

	exec sp_executesql N'select @build_m = intVersionID from tblSMBuildNumber where strVersionNo like ''%16.1%'' '  , 
		N'@build_m int output', @build_m output;
END


IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity')  
AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMUserSecurity' and [COLUMN_NAME] = 'intEntityUserSecurityId')
AND @build_m = 0
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strEntityNo') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntity' and [COLUMN_NAME] = 'strContactNumber') 

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityLocation' and [COLUMN_NAME] = 'ysnDefaultContact') 

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'intEntityContactId') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'ysnDefaultContact') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEMEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess') 
 
BEGIN
	PRINT '*** UPDATING ENTITY User Security***'
	EXEC('delete tblSMUserSecurity where strUserName not in (select strUserName from tblEMEntityCredential) ') 

	print ('*** checking security with no entity ***')
	exec('
		if (object_id(''tempdb..#tmpNullSecurity'')) is not null
			drop table #tmpNullSecurity

		select intUserSecurityID,strFullName into #tmpNullSecurity from tblSMUserSecurity where intEntityId is null
		DECLARE @intNullId int
		declare @Name nvarchar(50)
		declare @newId int
		while exists(select top 1 1 from #tmpNullSecurity)
		begin
			select top 1 @intNullId = intUserSecurityID, @Name = strFullName 
			from #tmpNullSecurity

			insert into tblEMEntity(strName, strContactNumber)
			select @Name, ''''

			set @newId = @@IDENTITY
			update tblSMUserSecurity set intEntityId = @newId where intUserSecurityID = @intNullId and intEntityId is null

			delete from #tmpNullSecurity where intUserSecurityID = @intNullId
		end
	')
	print 'routine starteed'
	EXEC( '	
	CREATE TABLE ##UserSecurityConstraint (
		Stement		NVARCHAR(MAX)
	)		
	DECLARE @CurStatement NVARCHAR(MAX)
	INSERT INTO ##UserSecurityConstraint
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
	
	--SELECT * FROM ##UserSecurityConstraint
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
	DECLARE @Email NVARCHAR(100)

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
		SET @Email = ''''
		SET @Name = ''''
		SELECT @Name = strName,@Email=strEmail FROM tblEMEntity where intEntityId = @CurEntityId
		SET @EntityId = @CurEntityId

		INSERT INTO tblEMEntity(strName,strContactNumber,strEmail)
		VALUES (@Name, '''', @Email)

		SET @EntityContactId = @@IDENTITY		

		INSERT INTO tblEMEntityLocation(intEntityId, strLocationName, ysnDefaultLocation )
		select @EntityId, @Name,1

		IF NOT EXISTS ( SELECT TOP 1 1 FROM tblEMEntityType where intEntityId = @EntityId)
		BEGIN
			INSERT INTO tblEMEntityType(intEntityId , strType, intConcurrencyId)
			VALUES( @EntityId, ''User'',0 ) 
		END

		INSERT INTO tblEMEntityToContact(intEntityId,intEntityContactId,ysnDefaultContact,ysnPortalAccess)
		VALUES(@EntityId, @EntityContactId, 1 ,0 ) 		

		DELETE FROM #tmpUserSecurity where intEntityId = @CurEntityId
	END		

	

	')	

	PRINT 'CHECKING FOR SECURITY DROP CONSTRAINT'
	IF OBJECT_ID('tempdb..##UserSecurityConstraint') IS NOT NULL  	
	BEGIN
		PRINT 'SECURITY DROP CONSTRAINT'
		
		DECLARE @CurStatement NVARCHAR(MAX)

		WHILE EXISTS(SELECT TOP 1 1 FROM ##UserSecurityConstraint)
		BEGIN
			SET @CurStatement = ''
			SELECT TOP 1 @CurStatement = Stement  FROM ##UserSecurityConstraint
			
			
			EXEC (@CurStatement)		

			DELETE FROM ##UserSecurityConstraint WHERE Stement = @CurStatement
		END
		DROP TABLE ##UserSecurityConstraint
	END

	create table ##XXEntityForTM(id int identity(1,1))
	
	
END
PRINT '*** END CHECKING ENTITY User Security***'

