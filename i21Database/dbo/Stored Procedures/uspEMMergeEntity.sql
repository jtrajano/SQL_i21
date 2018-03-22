CREATE PROCEDURE uspEMMergeEntity
	@PrimaryKey		INT
	,@PrimaryType	NVARCHAR(100)
	,@Merge			NVARCHAR(MAX)
AS

BEGIN
	SET NOCOUNT ON
	DECLARE @PrimaryKeyString NVARCHAR(100)
	DECLARE @CurMergeId	NVARCHAR(MAX)
	DECLARE @CurMergeType NVARCHAR(MAX)

	DECLARE @CurTableName NVARCHAR(MAX)
	DECLARE @CurTableKey NVARCHAR(MAX)
	DECLARE @SQLCommand NVARCHAR(MAX)

	DECLARE @CurMergeItem NVARCHAR(MAX)
	DECLARE @Columns NVARCHAR(MAX)  
	DECLARE @RefUpdateCommand NVARCHAR(MAX)
	DECLARE @RefUpdateCommandEntity NVARCHAR(MAX)
	DECLARE @CurStatement NVARCHAR(MAX)
	
	DECLARE @hasUser BIT = 0
	DECLARE @RelationShips TABLE(stment NVARCHAR(MAX))
	DECLARE @EntityRelationShips TABLE(stment NVARCHAR(MAX))

	DECLARE @curtype NVARCHAR(100)
	DECLARE @EntityTypes TABLE(strType NVARCHAR(100))
	DECLARE @getAll BIT
	DECLARE @avoidtable TABLE(strTable NVARCHAR(100))
	DECLARE @getAllColumn BIT
	DECLARE @avoidColumn TABLE(strColumn NVARCHAR(100))
	DECLARE @parentAvoidTable TABLE(strTable NVARCHAR(100))

	SET @PrimaryKeyString = CAST(@PrimaryKey AS NVARCHAR)
	SELECT * INTO #tmpMerge FROM dbo.[fnSplitString](@Merge,'|')
	
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpMerge)
	BEGIN
		SELECT @CurMergeId = ''
			, @CurMergeType = ''
			, @CurTableName = ''
			, @CurTableKey = ''
			, @SQLCommand = ''
			, @CurMergeItem = ''
			, @Columns = ''
			, @RefUpdateCommand = ''
			, @RefUpdateCommandEntity = ''		

		SELECT TOP 1 @CurMergeItem = Item FROM #tmpMerge

		SELECT @CurMergeId = SUBSTRING(@CurMergeItem, 0, CHARINDEX('.', @CurMergeItem))
			, @CurMergeType = SUBSTRING(@CurMergeItem, CHARINDEX('.', @CurMergeItem) + 1 , LEN(@CurMergeItem))

		--get all the type
		INSERT INTO @EntityTypes(strType)
		SELECT strType FROM tblEMEntityType WHERE intEntityId = @CurMergeId

		WHILE EXISTS(SELECT TOP 1 1 FROM @EntityTypes)
		BEGIN
		
			SELECT TOP 1 @curtype = strType FROM @EntityTypes
			
			--delete from @avoidtable
			--set @getAll = 1

			DELETE FROM @avoidColumn
			SET @getAllColumn = 1
			IF @curtype = 'Customer' OR @curtype = 'Prospect'
			BEGIN
				SET @CurTableName = 'tblARCustomer'
				SET @CurTableKey = 'intEntityId'

				INSERT INTO @avoidtable(strTable)
				SELECT 'tblARCustomerBudget'
				UNION SELECT 'tblARCustomerApplicatorLicense'
				UNION SELECT 'tblARCustomerAccountStatus'
				UNION SELECT 'tblARCustomerRackQuoteHeader'
				
				SET @getAll = 0

				IF @PrimaryType = 'Vendor'
				BEGIN
					INSERT INTO @EntityRelationShips(stment)
					VALUES('update tblARCustomer set strCustomerNumber = (select top 1 strVendorId from tblAPVendor WHERE intEntityId = ' + @PrimaryKeyString + ' ) WHERE intEntityId = ' + @PrimaryKeyString )
					INSERT INTO @avoidColumn(strColumn)
					VALUES('strCustomerNumber')
					SET @getAllColumn = 0
				END				
			END
			ELSE IF @curtype = 'Vendor'
			BEGIN
				SET @CurTableName = 'tblAPVendor'
				SET @CurTableKey = 'intEntityId'

				INSERT INTO @EntityRelationShips(stment)
				VALUES('DELETE FROM tblAPImportedVendors WHERE strVendorId in (select strVendorId from tblAPVendor WHERE intEntityId = ' + @CurMergeId + ' )')
								
				IF @PrimaryType = 'Customer'
				BEGIN
					INSERT INTO @EntityRelationShips(stment)
					VALUES('update tblAPVendor set strVendorId = (select top 1 strCustomerNumber from tblARCustomer WHERE intEntityId = ' + @PrimaryKeyString + ' ) WHERE intEntityId = ' + @PrimaryKeyString )
					INSERT INTO @avoidColumn(strColumn)
					VALUES('strVendorId')
					SET @getAllColumn = 0
				END
			END
			ELSE IF @curtype = 'Salesperson'
			BEGIN
				SET @CurTableName = 'tblARSalesperson'
				SET @CurTableKey = 'intEntityId'
			END
			ELSE IF @curtype = 'User'
			BEGIN
				SET @CurTableName = 'tblSMUserSecurity'
				SET @CurTableKey = 'intEntityId'

				INSERT INTO @avoidtable(strTable)
				SELECT 'tblSMUserSecurityCompanyLocationRolePermission'
				SET @getAll = 0
				SET @hasUser = 1
			END
			ELSE IF @curtype = 'Ship Via'
			BEGIN
				SET @CurTableName = 'tblSMShipVia'
				SET @CurTableKey = 'intEntityId'
			END

			SET @Columns = ''
			SELECT @Columns = COALESCE(@Columns + ', ', '') + name FROM syscolumns WHERE id = object_id(@CurTableName) AND name <> @CurTableKey
			
			INSERT INTO @RelationShips
			SELECT 'UPDATE ' + R.TABLE_NAME + ' SET ' +  R.COLUMN_NAME + '='+ @PrimaryKeyString +' WHERE ' + R.COLUMN_NAME  + '=' + @CurMergeId + '; --relationship' AS stment		
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
			INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
				AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
				AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
				AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
				AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
			WHERE U.TABLE_NAME = @CurTableName AND (@getAll = 1 OR R.TABLE_NAME NOT IN (SELECT strTable FROM @avoidtable))--OR U.TABLE_NAME = 'tblEMEntity'
			
			DELETE FROM @EntityTypes WHERE strType = @curtype
		END

		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'Customer')
		BEGIN
			INSERT INTO @parentAvoidTable
			SELECT 'tblARCustomer'
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'Vendor')
		BEGIN
			INSERT INTO @parentAvoidTable
			SELECT 'tblAPVendor'
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'Salesperson')
		BEGIN
			INSERT INTO @parentAvoidTable
			SELECT 'tblARSalesperson'
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'User')
		BEGIN
			INSERT INTO @parentAvoidTable
			SELECT 'tblSMUserSecurity'
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'Employee')
		BEGIN
			INSERT INTO @parentAvoidTable
			SELECT 'tblPREmployee'
		END
		IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'Ship Via')
		BEGIN
			INSERT INTO @parentAvoidTable
			SELECT 'tblSMShipVia'
		END

		INSERT INTO @parentAvoidTable(strTable)
		SELECT 'tblEMEntityRequireApprovalFor'

		--
		INSERT INTO @EntityRelationShips
		SELECT 'update a set  ' +c.name  + '  = (select top 1 ' + c.name + '  from ' + @CurTableName + ' b WHERE b.' + @CurTableKey + '  = ' + @CurMergeId + ' and (' + c.name + ' is not null and ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' > 0'
					when y.name = 'NVARCHAR' or y.name = 'varchar' then
						' <> '''''
					else
						'is not null'
					END + 
				 ' ) ) from 
			' + @CurTableName + ' a 
				where (a.' +c.name + ' is null or ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' <= 0'
					when y.name = 'NVARCHAR' or y.name = 'varchar' then
						' = '''''
					else
						'is null'
					END + 
				 ' )
					and a.' + @CurTableKey + ' = ' + @PrimaryKeyString + ' 
					and exists(select top 1 1 from ' + @CurTableName + ' b WHERE b.' + @CurTableKey + '  = ' + @CurMergeId + ' and (' + c.name + ' is not null and ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' > 0'
					when y.name = 'NVARCHAR' or y.name = 'varchar' then
						' <> '''''
					else
						'is not null'
					END + 
				 ' )) ' + ';' as stment
			from sys.columns c 
				JOIN sys.types y ON y.user_type_id = c.user_type_id 		
				where c.object_id = object_id(@CurTableName) and c.name <> @CurTableKey
				AND y.name in ('numeric', 'NVARCHAR', 'varchar', 'int')
				AND (@getAllColumn = 1 or c.name not in (select strColumn from @avoidColumn)) 
		
		INSERT INTO @EntityRelationShips
		SELECT 'UPDATE ' + R.TABLE_NAME + ' SET ' +  R.COLUMN_NAME + '='+ @PrimaryKeyString +' WHERE ' + R.COLUMN_NAME  + '=' + @CurMergeId + ';' as stment		
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME		
		WHERE U.TABLE_NAME = 'tblEMEntity'  AND R.TABLE_NAME <> @CurTableName and R.TABLE_NAME NOT IN(SELECT strTable from @parentAvoidTable)

		BEGIN TRANSACTION
		BEGIN TRY
			if @hasUser = 1
			BEGIN 
				EXEC('alter table tblSMUserSecurity drop constraint AK_tblSMUserSecurity_strUserName')
				EXEC('alter table tblSMLicenseAcceptance drop constraint FK_tblSMLicenseAcceptance_tblSMUserSecurity')
				EXEC('alter table tblSMUserLogin drop constraint FK_tblSMUserLogin_tblSMUserSecurity')
				EXEC('alter table tblSMUserSecurityMenu drop constraint FK_tblSMUserSecurityMenu_tblSMUserSecurity')

				EXEC('insert into tblSMUserSecurityCompanyLocationRolePermission(intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId)
						select ' + @PrimaryKeyString + ',' + @PrimaryKeyString + ' ,intUserRoleId, intCompanyLocationId 
							from tblSMUserSecurityCompanyLocationRolePermission  a 
							where a.intEntityUserSecurityId = ' + @CurMergeId + ' 
								and  not exists(select * 
													from tblSMUserSecurityCompanyLocationRolePermission b 
														where intEntityUserSecurityId = ' + @PrimaryKeyString + ' 
															and a.intUserRoleId = b.intUserRoleId 
															and a.intCompanyLocationId = b.intCompanyLocationId)')
			END
			if not exists(select top 1 1 from tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = @curtype)
			begin
				DECLARE @QueryString NVARCHAR(MAX)
				SET @QueryString = 'insert into tblEMEntityType ( intEntityId, strType, intConcurrencyId) values ('+ @PrimaryKeyString +','''+@curtype+''',0 )'
				EXEC (@QueryString)

				IF (@CurTableName = 'tblSMShipVia')
				BEGIN
					SET @QueryString = 'alter table tblSMShipVia drop constraint AK_tblSMShipVia_strShipVia'
					EXEC (@QueryString)
				END

				SET @QueryString = 'insert into '+ @CurTableName +'(' + @CurTableKey +@Columns + ') 
							select '+ @PrimaryKeyString + @Columns + ' 
								from ' + @CurTableName + ' 
									where ' + @CurTableKey + ' = ' +  @CurMergeId
				EXEC (@QueryString)
				
				IF (@CurTableName = 'tblSMShipVia')
				BEGIN
					SET @QueryString = 'UPDATE tblSMShipVia SET strShipVia = strShipVia + '' (Do not use)''  WHERE ' + @CurTableKey + ' = ' +  @CurMergeId
					EXEC (@QueryString)

					SET @QueryString = 'ALTER TABLE tblSMShipVia ADD CONSTRAINT [AK_tblSMShipVia_strShipVia] UNIQUE ([strShipVia])'
					EXEC (@QueryString)
				END
			end
			
			EXEC('uspSMMergeRole ' + @CurMergeId + ',' + @PrimaryKeyString)
			
			EXEC('delete from tblEMEntityType WHERE intEntityId = ' + @CurMergeId + ' and strType IN (SELECT strType from tblEMEntityType WHERE intEntityId = ' + @PrimaryKeyString + ')' )
			EXEC('update tblEMEntityLocation set ysnDefaultLocation = 0, strLocationName= ''' + @CurMergeId + ' '' + strLocationName  WHERE intEntityId = ' + @CurMergeId)
			EXEC('update tblEMEntityToContact set ysnDefaultContact = 0 WHERE intEntityId = ' + @CurMergeId)
			
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @RelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @RelationShips
				
				EXEC(@CurStatement)
				
				delete from @RelationShips WHERE stment = @CurStatement
			END 
			
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @EntityRelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @EntityRelationShips
				
				EXEC(@CurStatement)
				
				delete from @EntityRelationShips WHERE stment = @CurStatement
			END 
			
			EXEC('delete from ' + @CurTableName + ' WHERE ' + @CurTableKey + ' = ' + @CurMergeId )

			if @hasUser = 1
			BEGIN 
				EXEC('ALTER TABLE tblSMUserSecurity ADD CONSTRAINT [AK_tblSMUserSecurity_strUserName] UNIQUE ([strUserName])')
				EXEC('ALTER TABLE tblSMLicenseAcceptance ADD CONSTRAINT [FK_tblSMLicenseAcceptance_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId])  ON DELETE CASCADE')
				EXEC('ALTER TABLE tblSMUserLogin ADD CONSTRAINT [FK_tblSMUserLogin_tblSMUserSecurity] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMUserSecurity]([intEntityId]) ON DELETE CASCADE')
				EXEC('ALTER TABLE tblSMUserSecurityMenu ADD CONSTRAINT [FK_tblSMUserSecurityMenu_tblSMUserSecurity] FOREIGN KEY ([intEntityUserSecurityId]) REFERENCES [dbo].[tblSMUserSecurity] ([intEntityId]) ON DELETE CASCADE')
			END 
			
			EXEC('UPDATE tblEMEntity set strEntityNo = null WHERE intEntityId = ' + @CurMergeId)
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH		
GoHere:
		DELETE FROM #tmpMerge WHERE Item = @CurMergeItem
	END
	DROP TABLE #tmpMerge
END