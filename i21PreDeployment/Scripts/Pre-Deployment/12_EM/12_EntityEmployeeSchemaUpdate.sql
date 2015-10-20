﻿PRINT '*** CHECKING ENTITY EMPLOYEE ***'

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


IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPREmployee')  
AND NOT EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPREmployee' and [COLUMN_NAME] = 'intEntityEmployeeId')

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strEntityNo') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntity' and [COLUMN_NAME] = 'strContactNumber') 

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityLocation' and [COLUMN_NAME] = 'ysnDefaultContact') 

AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'intEntityContactId') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnDefaultContact') 
AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblEntityToContact' and [COLUMN_NAME] = 'ysnPortalAccess') 
 
BEGIN
	PRINT '*** UPDATING ENTITY EMPLOYEE***'

	EXEC( '

		DECLARE @EmployeeConstraint TABLE(
			Stement		NVARCHAR(MAX)
		)		
		DECLARE @CurStatement NVARCHAR(MAX)
		INSERT INTO @EmployeeConstraint
		SELECT
			''ALTER TABLE '' + R.TABLE_NAME + '' DROP CONSTRAINT ['' + R.CONSTRAINT_NAME + '']''
			+ '' ; UPDATE B SET B.'' + R.COLUMN_NAME + '' = A.intUserSecurityId FROM tblPREmployee A JOIN '' + R.TABLE_NAME + '' B ON A.intEmployeeId = B.'' + R.COLUMN_NAME   + 
			'' where A.intUserSecurityId is not null'' Stement
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
		WHERE U.TABLE_NAME = ''tblPREmployee'' 



		UPDATE a set a.strEntityNo = b.strEmployeeId from tblEntity a
		join tblPREmployee b
			on a.intEntityId = b.intEmployeeId
		where a.strEntityNo = '''' or a.strEntityNo is null


		update a  set a.ysnDefaultLocation = 1, strLocationName = b.strEmployeeId + '' Location''
		from tblEntityLocation a
				join tblPREmployee b
					on a.intEntityId = b.intEmployeeId
				where b.intEmployeeId not in 
					(select intEntityId 
						from  (select intEntityId, count(*) c 
								from tblEntityLocation 
									where ysnDefaultLocation = 1 
										and intEntityId in (select 
																intEmployeeId 
																	from tblPREmployee)  group by intEntityId) a where  c > 0)

			IF OBJECT_ID(''tempdb..#tmp'') IS NOT NULL DROP TABLE #tmp
		-- adding entity to contact
		select * into #tmp  from tblPREmployee

		declare @curInt int
		declare @mContactId int
		declare @cContactId int
		declare @mName	nvarchar(100)
		declare @cName	nvarchar(100)
		declare @cPhone nvarchar(25)
		declare @cPhone2 nvarchar(25)
		declare @cRelation nvarchar(25)

		while exists(select top 1 1 from #tmp)
		begin
			select top 1 @curInt = intEmployeeId from #tmp

			if not exists(select top 1 1 from tblEntityToContact where intEntityId = @curInt)
			begin
				set @mName = null
				set @cName = null
				set @cPhone = null
				set @cPhone2 = null
				set @mContactId = null
				set @cContactId = null
				set @cRelation = null
				select 

					@mName = isnull(strFirstName, '''') + isnull(strMiddleName, '''') + isnull(strLastName, '''') + isnull(strNameSuffix, ''''),
					@cName = strEmergencyContact,
					@cPhone = strEmergencyPhone,
					@cPhone2 = strEmergencyPhone2,
					@cRelation = ''Relation: '' + strEmergencyRelation

				from #tmp where intEmployeeId = @curInt

				insert into tblEntity(strName, strContactNumber)
				values (@mName, '''')
				set @mContactId = @@IDENTITY

				insert into tblEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
				values(@curInt, @mContactId, 1, 0)
				
				if(@cName is not null or @cName <> '''')
				begin 
					insert into tblEntity(strName, strContactNumber, strContactType, strPhone, strPhone2, strNotes)
					values(@cName, '''', ''Emergency'', @cPhone, @cPhone2, '''')
					set @cContactId = @@IDENTITY

					insert into tblEntityToContact(intEntityId, intEntityContactId, ysnDefaultContact, ysnPortalAccess)
					values(@curInt, @cContactId, 0, 0)		
				end 

				
			end

			delete from #tmp where intEmployeeId = @curInt
	
		end

		WHILE EXISTS(SELECT TOP 1 1 FROM @EmployeeConstraint)
		BEGIN
			SET @CurStatement = ''''
			SELECT TOP 1 @CurStatement = Stement  FROM @EmployeeConstraint

			EXEC (@CurStatement)

			DELETE FROM @EmployeeConstraint WHERE Stement = @CurStatement
		END

		EXEC(''update tblPREmployee set intEmployeeId = intUserSecurityId, intEntityId = intUserSecurityId where intUserSecurityId is not null'')

		INSERT INTO tblEntityType(intEntityId,strType, intConcurrencyId)
	SELECT intEmployeeId,''Employee'', 0 FROM tblPREmployee 
		where intEmployeeId not in (SELECT intEntityId FROM 
										tblEntityType where strType = ''Employee'')



	')
END
PRINT '*** END CHECKING ENTITY EMPLOYEE***'