CREATE PROCEDURE uspEMMergeEntity

	@PrimaryKey		INT
	,@PrimaryType	NVARCHAR(100)
	,@Merge			NVARCHAR(MAX)
AS

BEGIN
	SET NOCOUNT ON
	DECLARE @PrimaryKeyString	NVARCHAR(100)
	DECLARE @CurMergeId		NVARCHAR(MAX)
	DECLARE @CurMergeType	NVARCHAR(MAX)

	DECLARE @CurTableName	NVARCHAR(MAX)
	DECLARE @CurTableKey	NVARCHAR(MAX)
	DECLARE @SQLCommand		NVARCHAR(MAX)

	DECLARE @CurMergeItem	NVARCHAR(MAX)
	DECLARE @Columns VARCHAR(8000)  
	DECLARE @RefUpdateCommand  NVARCHAR(MAX)
	DECLARE @RefUpdateCommandEntity  NVARCHAR(MAX)
	DECLARE @CurStatement	NVARCHAR(MAX)
	
	DECLARE @hasUser BIT
	SET @hasUser = 0
	DECLARE @RelationShips TABLE(stment NVARCHAR(MAX))
	DECLARE @EntityRelationShips TABLE( stment NVARCHAR(MAX))
	DECLARE @curtype NVARCHAR(100)
	DECLARE @EntityTypes TABLE( strType	NVARCHAR(100))
	DECLARE @getAll BIT
	DECLARE @avoidtable TABLE( strTable NVARCHAR(100))
	DECLARE @getAllColumn BIT
	DECLARE @avoidColumn TABLE(strColumn NVARCHAR(100))
	DECLARE @parentAvoidTable TABLE( strTable NVARCHAR(100))
	
	SET @PrimaryKeyString = CAST(@PrimaryKey  AS NVARCHAR )
	SELECT * INTO #tmpMerge FROM dbo.[fnSplitString](@Merge,'|')
	WHILE EXISTS(SELECT TOP 1 1 FROM #tmpMerge)
	BEGIN		
		SET @CurMergeId = ''
		SET @CurMergeType = ''
		SET @CurTableName = ''
		SET @CurTableKey = ''
		SET @SQLCommand = ''
		SET @CurMergeItem = ''
		SET @Columns = ''
		SET @RefUpdateCommand = ''
		SET @RefUpdateCommandEntity = ''
		
		SELECT TOP 1 @CurMergeItem = Item FROM #tmpMerge

		SELECT @CurMergeId = SUBSTRING(@CurMergeItem,0,CHARINDEX('.',@CurMergeItem))
		,@CurMergeType = SUBSTRING(@CurMergeItem, CHARINDEX('.',@CurMergeItem)+ 1 , LEN(@CurMergeItem))

		--get all the type
		INSERT INTO @EntityTypes(strType)
		SELECT strType FROM tblEMEntityType WHERE intEntityId = @CurMergeId

		while exists(SELECT TOP 1 1 FROM @EntityTypes)
		BEGIN
			SELECT TOP 1 @curtype = strType FROM @EntityTypes
			
			--DELETE FROM @avoidtable
			--SET @getAll = 1

			DELETE FROM @avoidColumn
			SET @getAllColumn = 1
			IF @curtype = 'Customer' or @curtype = 'Prospect'
			BEGIN
				SET @CurTableName = 'tblARCustomer'
				SET @CurTableKey = 'intEntityId'

				INSERT INTO @avoidtable(strTable)
				SELECT 'tblARCustomerBudget'
				UNION
				SELECT 'tblARCustomerApplicatorLicense'
				UNION
				SELECT 'tblARCustomerAccountStatus'
				UNION 
				SELECT 'tblARCustomerRackQuoteHeader'
				SET @getAll = 0

				IF @PrimaryType = 'Vendor'
				BEGIN
					INSERT INTO @EntityRelationShips(stment)
					VALUES('UPDATE tblARCustomer SET strCustomerNumber = (SELECT TOP 1 strVendorId FROM tblAPVendor WHERE intEntityId = ' + @PrimaryKeyString + ' ) WHERE intEntityId = ' + @PrimaryKeyString )

					INSERT INTO @avoidColumn(strColumn)
					values('strCustomerNumber')
					SET @getAllColumn = 0
				END
				
			END
			ELSE IF @curtype = 'Vendor'
			BEGIN
				SET @CurTableName = 'tblAPVendor'
				SET @CurTableKey = 'intEntityId'

				INSERT INTO @EntityRelationShips(stment)
				VALUES('DELETE FROM tblAPImportedVendors WHERE strVendorId in (SELECT strVendorId FROM tblAPVendor WHERE intEntityId = ' + @CurMergeId + ' )')

				
				IF @PrimaryType = 'Customer'
				BEGIN
					INSERT INTO @EntityRelationShips(stment)
					VALUES('UPDATE tblAPVendor SET strVendorId = (SELECT TOP 1 strCustomerNumber FROM tblARCustomer WHERE intEntityId = ' + @PrimaryKeyString + ' ) WHERE intEntityId = ' + @PrimaryKeyString )
					INSERT INTO @avoidColumn(strColumn)
					values('strVendorId')
					SET @getAllColumn = 0
				END
			END
			ELSE IF @curtype = 'Salesperson'
			BEGIN
				SET @CurTableName = 'tblARSalesperson'
				SET @CurTableKey = 'intEntityId'
			END
			ELSE IF @curtype = 'Ship Via'
			BEGIN
				SET @CurTableName = 'tblSMShipVia'
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

			SET @Columns = ''
			SELECT @Columns = COALESCE(@Columns + ', ', '') + name FROM syscolumns WHERE id = object_id(@CurTableName) and name <> @CurTableKey
			
			
			INSERT INTO @RelationShips
			SELECT
				'UPDATE ' + R.TABLE_NAME + ' SET ' +  R.COLUMN_NAME + '='+ @PrimaryKeyString +' WHERE ' + R.COLUMN_NAME  + '=' + @CurMergeId + '; --relationship' as stment		
			FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
			INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
				ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
				AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
				AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
			INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
				ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
				AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
				AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
			WHERE U.TABLE_NAME = @CurTableName AND (@getAll = 1 or R.TABLE_NAME not in (SELECT strTable FROM @avoidtable))--OR U.TABLE_NAME = 'tblEMEntity'




			DELETE FROM @EntityTypes WHERE strType = @curtype
		END

		--IF EXISTS(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = 'Customer')
		--BEGIN
		--	INSERT INTO @parentAvoidTable
		--	SELECT 'tblARCustomer'
		--END
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
		SELECT 
			'UPDATE a SET  ' +c.name  + '  = (SELECT TOP 1 ' + c.name + '  FROM ' + @CurTableName + ' b WHERE b.' + @CurTableKey + '  = ' + @CurMergeId + ' and (' + c.name + ' is not null and ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' > 0'
					when y.name = 'nvarchar' or y.name = 'varchar' then
						' <> '''''
					ELSE
						'is not null'
					END + 
				 ' ) ) FROM 
			' + @CurTableName + ' a 
				WHERE (a.' +c.name + ' is null or ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' <= 0'
					when y.name = 'nvarchar' or y.name = 'varchar' then
						' = '''''
					ELSE
						'is null'
					END + 
				 ' )
					and a.' + @CurTableKey + ' = ' + @PrimaryKeyString + ' 
					and exists(SELECT TOP 1 1 FROM ' + @CurTableName + ' b WHERE b.' + @CurTableKey + '  = ' + @CurMergeId + ' and (' + c.name + ' is not null and ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' > 0'
					when y.name = 'nvarchar' or y.name = 'varchar' then
						' <> '''''
					ELSE
						'is not null'
					END + 
				 ' )) ' + ';' as stment
			FROM sys.columns c 
				JOIN sys.types y ON y.user_type_id = c.user_type_id 		
				WHERE c.object_id = object_id(@CurTableName) and c.name <> @CurTableKey
				AND y.name in ('numeric', 'nvarchar', 'varchar', 'int')
				AND (@getAllColumn = 1 or c.name not in (SELECT strColumn FROM @avoidColumn)) 
		--


		INSERT INTO @EntityRelationShips
		SELECT
			'UPDATE ' + R.TABLE_NAME + ' SET ' +  R.COLUMN_NAME + '='+ @PrimaryKeyString +' WHERE ' + R.COLUMN_NAME  + '=' + @CurMergeId + ';' as stment		
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME		
		WHERE U.TABLE_NAME = 'tblEMEntity'  AND R.TABLE_NAME <> @CurTableName and R.TABLE_NAME NOT IN(SELECT strTable FROM @parentAvoidTable)

		BEGIN TRANSACTION
		BEGIN TRY
			IF @hasUser = 1
			BEGIN 
				EXEC('alter table tblSMUserSecurity drop constraint AK_tblSMUserSecurity_strUserName')

				EXEC('INSERT INTO tblSMUserSecurityCompanyLocationRolePermission(intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId)
						SELECT ' + @PrimaryKeyString + ',' + @PrimaryKeyString + ' ,intUserRoleId, intCompanyLocationId 
							FROM tblSMUserSecurityCompanyLocationRolePermission  a 
							WHERE a.intEntityUserSecurityId = ' + @CurMergeId + ' 
								and  not exists(SELECT * 
													FROM tblSMUserSecurityCompanyLocationRolePermission b 
														WHERE intEntityUserSecurityId = ' + @PrimaryKeyString + ' 
															and a.intUserRoleId = b.intUserRoleId 
															and a.intCompanyLocationId = b.intCompanyLocationId)
				
				')
				/*
				
				*/
			END
			
			IF not exists(SELECT TOP 1 1 FROM tblEMEntityType WHERE intEntityId = @PrimaryKey and strType = @curtype)
			BEGIN
				IF @CurTableName = 'tblSMShipVia'
				BEGIN
					EXEC('alter table tblSMShipVia drop constraint AK_tblSMShipVia_strShipVia')
				END
				
				EXEC ( 'INSERT INTO tblEMEntityType ( intEntityId, strType, intConcurrencyId) values ('+ @PrimaryKeyString +','''+@curtype+''',0 )
					INSERT INTO '+ @CurTableName +'(' + @CurTableKey +@Columns + ') 
							SELECT '+ @PrimaryKeyString + @Columns + ' 
								FROM ' + @CurTableName + ' 
									WHERE ' + @CurTableKey + ' = ' +  @CurMergeId)
			END
			
			EXEC('uspSMMergeRole ' + @CurMergeId + ',' + @PrimaryKeyString)
			
			EXEC('DELETE FROM tblEMEntityType WHERE intEntityId = ' + @CurMergeId + ' and strType IN (SELECT strType FROM tblEMEntityType WHERE intEntityId = ' + @PrimaryKeyString + ')' )
			EXEC('UPDATE tblEMEntityLocation SET ysnDefaultLocation = 0, strLocationName= ''' + @CurMergeId + ' '' + strLocationName  WHERE intEntityId = ' + @CurMergeId)
			EXEC('UPDATE tblEMEntityToContact SET ysnDefaultContact = 0 WHERE intEntityId = ' + @CurMergeId)
			
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @RelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @RelationShips
				
				EXEC(@CurStatement)
				
				DELETE FROM @RelationShips WHERE stment = @CurStatement
			END 
			
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @EntityRelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @EntityRelationShips
				
				EXEC(@CurStatement)
				
				DELETE FROM @EntityRelationShips WHERE stment = @CurStatement
			END 
			
			EXEC('DELETE FROM ' + @CurTableName + ' WHERE ' + @CurTableKey + ' = ' + @CurMergeId )
			
			IF @CurTableName = 'tblSMShipVia'
			BEGIN
				EXEC('ALTER TABLE tblSMShipVia ADD CONSTRAINT [AK_tblSMShipVia_strShipVia] UNIQUE ([strShipVia])')
			END
			
			 IF @hasUser = 1
			BEGIN 
				EXEC('ALTER TABLE tblSMUserSecurity ADD CONSTRAINT [AK_tblSMUserSecurity_strUserName] UNIQUE ([strUserName])')
			END 
			EXEC('UPDATE tblEMEntity SET strEntityNo = null WHERE intEntityId = ' + @CurMergeId)
			
			COMMIT TRANSACTION

		END TRY
		
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH
		
GoHere:
		DELETE FROM #tmpMerge WHERE Item = @CurMergeItem

	END

	drop table #tmpMerge
END
