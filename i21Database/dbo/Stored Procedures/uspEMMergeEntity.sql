CREATE PROCEDURE uspEMMergeEntity

	@PrimaryKey		int
	,@PrimaryType	nvarchar(100)
	,@Merge			nvarchar(max)
as

BEGIN
	SET NOCOUNT ON
	declare @PrimaryKeyString	nvarchar(100)
	declare @CurMergeId		nvarchar(max)
	declare @CurMergeType	nvarchar(max)

	declare @CurTableName	nvarchar(max)
	declare @CurTableKey	nvarchar(max)
	declare @SQLCommand		nvarchar(max)

	declare @CurMergeItem	nvarchar(max)
	declare @Columns VARCHAR(8000)  
	declare @RefUpdateCommand  NVARCHAR(MAX)
	declare @RefUpdateCommandEntity  NVARCHAR(MAX)
	declare @CurStatement	NVARCHAR(MAX)
	
	declare @hasUser	BIT
	set @hasUser = 0
	declare @RelationShips table 
	(
		stment nvarchar(max)
	)

	declare @EntityRelationShips table 
	(
		stment nvarchar(max)
	)
		
	declare @curtype nvarchar(100)
	declare @EntityTypes table
	(
		strType	nvarchar(100)
	)
	declare @getAll bit
	declare @avoidtable table(
		strTable nvarchar(100)
	)
	declare @getAllColumn bit
	declare @avoidColumn table(
		strColumn nvarchar(100)
	)
	declare @parentAvoidTable table(
		strTable nvarchar(100)
	)
	set @PrimaryKeyString =   Cast(@PrimaryKey  as nvarchar )
	select * into #tmpMerge from dbo.[fnSplitString](@Merge,'|')
	while exists(select top 1 1 from #tmpMerge)
	begin		
		SET @CurMergeId = ''
		SET @CurMergeType = ''
		SET @CurTableName = ''
		SET @CurTableKey = ''
		SET @SQLCommand = ''
		SET @CurMergeItem = ''
		SET @Columns = ''
		SET @RefUpdateCommand = ''
		SET @RefUpdateCommandEntity = ''
		

		select top 1 @CurMergeItem = Item from #tmpMerge

		select @CurMergeId = SUBSTRING(@CurMergeItem,0,CHARINDEX('.',@CurMergeItem))
		,@CurMergeType = SUBSTRING(@CurMergeItem, CHARINDEX('.',@CurMergeItem)+ 1 , LEN(@CurMergeItem))

		--get all the type
		insert into @EntityTypes(strType)
		select strType from tblEMEntityType where intEntityId = @CurMergeId

		while exists(select top 1 1 from @EntityTypes)
		begin
			select top 1 @curtype = strType from @EntityTypes
			
			--delete from @avoidtable
			--set @getAll = 1

			delete from @avoidColumn
			set @getAllColumn = 1
			if @curtype = 'Customer' or @curtype = 'Prospect'
			begin
				set @CurTableName = 'tblARCustomer'
				set @CurTableKey = 'intEntityId'

				insert into @avoidtable(strTable)
				select 'tblARCustomerBudget'
				union
				select 'tblARCustomerApplicatorLicense'
				union
				select 'tblARCustomerAccountStatus'
				union 
				select 'tblARCustomerRackQuoteHeader'
				set @getAll = 0

				if @PrimaryType = 'Vendor'
				begin
					INSERT INTO @EntityRelationShips(stment)
					VALUES('update tblARCustomer set strCustomerNumber = (select top 1 strVendorId from tblAPVendor where intEntityId = ' + @PrimaryKeyString + ' ) where intEntityId = ' + @PrimaryKeyString )

					insert into @avoidColumn(strColumn)
					values('strCustomerNumber')
					set @getAllColumn = 0
				end
				
			end
			else if @curtype = 'Vendor'
			begin
				set @CurTableName = 'tblAPVendor'
				set @CurTableKey = 'intEntityId'

				INSERT INTO @EntityRelationShips(stment)
				VALUES('DELETE FROM tblAPImportedVendors where strVendorId in (select strVendorId from tblAPVendor where intEntityId = ' + @CurMergeId + ' )')

				
				if @PrimaryType = 'Customer'
				begin
					INSERT INTO @EntityRelationShips(stment)
					VALUES('update tblAPVendor set strVendorId = (select top 1 strCustomerNumber from tblARCustomer where intEntityId = ' + @PrimaryKeyString + ' ) where intEntityId = ' + @PrimaryKeyString )
					insert into @avoidColumn(strColumn)
					values('strVendorId')
					set @getAllColumn = 0
				end
			end
			else if @curtype = 'Salesperson'
			begin
				set @CurTableName = 'tblARSalesperson'
				set @CurTableKey = 'intEntitySalespersonId'
			end
			else if @curtype = 'User'
			begin
				set @CurTableName = 'tblSMUserSecurity'
				set @CurTableKey = 'intEntityUserSecurityId'

				insert into @avoidtable(strTable)
				select 'tblSMUserSecurityCompanyLocationRolePermission'
				set @getAll = 0
				set @hasUser = 1
			end

			set @Columns = ''
			SELECT @Columns = COALESCE(@Columns + ', ', '') + name from syscolumns where id = object_id(@CurTableName) and name <> @CurTableKey
			
			
			insert into @RelationShips
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
			WHERE U.TABLE_NAME = @CurTableName AND (@getAll = 1 or R.TABLE_NAME not in (select strTable from @avoidtable))--OR U.TABLE_NAME = 'tblEMEntity'




			delete from @EntityTypes where strType = @curtype
		end

		if exists(select top 1 1 from tblEMEntityType where intEntityId = @PrimaryKey and strType = 'Customer')
		begin
			insert into @parentAvoidTable
			select 'tblARCustomer'
		end
		if exists(select top 1 1 from tblEMEntityType where intEntityId = @PrimaryKey and strType = 'Vendor')
		begin
			insert into @parentAvoidTable
			select 'tblAPVendor'
		end
		if exists(select top 1 1 from tblEMEntityType where intEntityId = @PrimaryKey and strType = 'Salesperson')
		begin
			insert into @parentAvoidTable
			select 'tblARSalesperson'
		end
		if exists(select top 1 1 from tblEMEntityType where intEntityId = @PrimaryKey and strType = 'User')
		begin
			insert into @parentAvoidTable
			select 'tblSMUserSecurity'
		end
		if exists(select top 1 1 from tblEMEntityType where intEntityId = @PrimaryKey and strType = 'Employee')
		begin
			insert into @parentAvoidTable
			select 'tblPREmployee'
		end

		insert into @parentAvoidTable(strTable)
		select 'tblEMEntityRequireApprovalFor'

		--
		insert into @EntityRelationShips
		select 
			'update a set  ' +c.name  + '  = (select top 1 ' + c.name + '  from ' + @CurTableName + ' b where b.' + @CurTableKey + '  = ' + @CurMergeId + ' and (' + c.name + ' is not null and ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' > 0'
					when y.name = 'nvarchar' or y.name = 'varchar' then
						' <> '''''
					else
						'is not null'
					end + 
				 ' ) ) from 
			' + @CurTableName + ' a 
				where (a.' +c.name + ' is null or ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' <= 0'
					when y.name = 'nvarchar' or y.name = 'varchar' then
						' = '''''
					else
						'is null'
					end + 
				 ' )
					and a.' + @CurTableKey + ' = ' + @PrimaryKeyString + ' 
					and exists(select top 1 1 from ' + @CurTableName + ' b where b.' + @CurTableKey + '  = ' + @CurMergeId + ' and (' + c.name + ' is not null and ' + c.name + 		
					case when y.name = 'numeric' or y.name = 'int' then
						' > 0'
					when y.name = 'nvarchar' or y.name = 'varchar' then
						' <> '''''
					else
						'is not null'
					end + 
				 ' )) ' + ';' as stment
			from sys.columns c 
				JOIN sys.types y ON y.user_type_id = c.user_type_id 		
				where c.object_id = object_id(@CurTableName) and c.name <> @CurTableKey
				AND y.name in ('numeric', 'nvarchar', 'varchar', 'int')
				AND (@getAllColumn = 1 or c.name not in (select strColumn from @avoidColumn)) 
		--


		insert into @EntityRelationShips
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
		WHERE U.TABLE_NAME = 'tblEMEntity'  AND R.TABLE_NAME <> @CurTableName and R.TABLE_NAME NOT IN(SELECT strTable from @parentAvoidTable)

		BEGIN TRANSACTION
		BEGIN TRY
			if @hasUser = 1
			BEGIN 
				EXEC('alter table tblSMUserSecurity drop constraint AK_tblSMUserSecurity_strUserName')

				EXEC('insert into tblSMUserSecurityCompanyLocationRolePermission(intEntityUserSecurityId, intEntityId, intUserRoleId, intCompanyLocationId)
						select ' + @PrimaryKeyString + ',' + @PrimaryKeyString + ' ,intUserRoleId, intCompanyLocationId 
							from tblSMUserSecurityCompanyLocationRolePermission  a 
							where a.intEntityUserSecurityId = ' + @CurMergeId + ' 
								and  not exists(select * 
													from tblSMUserSecurityCompanyLocationRolePermission b 
														where intEntityUserSecurityId = ' + @PrimaryKeyString + ' 
															and a.intUserRoleId = b.intUserRoleId 
															and a.intCompanyLocationId = b.intCompanyLocationId)
				
				')
				/*
				
				*/
			END
			if not exists(select top 1 1 from tblEMEntityType where intEntityId = @PrimaryKey and strType = @curtype)
			begin
				EXEC ( 'insert into tblEMEntityType ( intEntityId, strType, intConcurrencyId) values ('+ @PrimaryKeyString +','''+@curtype+''',0 )
					insert into '+ @CurTableName +'(' + @CurTableKey +@Columns + ') 
							select '+ @PrimaryKeyString + @Columns + ' 
								from ' + @CurTableName + ' 
									where ' + @CurTableKey + ' = ' +  @CurMergeId)
			end
			
			EXEC('uspSMMergeRole ' + @CurMergeId + ',' + @PrimaryKeyString)
			
			EXEC('delete from tblEMEntityType where intEntityId = ' + @CurMergeId + ' and strType IN (SELECT strType from tblEMEntityType where intEntityId = ' + @PrimaryKeyString + ')' )
			EXEC('update tblEMEntityLocation set ysnDefaultLocation = 0, strLocationName= ''' + @CurMergeId + ' '' + strLocationName  where intEntityId = ' + @CurMergeId)
			EXEC('update tblEMEntityToContact set ysnDefaultContact = 0 where intEntityId = ' + @CurMergeId)
			
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @RelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @RelationShips
				
				EXEC(@CurStatement)
				
				delete from @RelationShips where stment = @CurStatement
			END 
			
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @EntityRelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @EntityRelationShips
				
				EXEC(@CurStatement)
				
				delete from @EntityRelationShips where stment = @CurStatement
			END 
			
			EXEC('delete from ' + @CurTableName + ' where ' + @CurTableKey + ' = ' + @CurMergeId )

			if @hasUser = 1
			BEGIN 
				EXEC('ALTER TABLE tblSMUserSecurity ADD CONSTRAINT [AK_tblSMUserSecurity_strUserName] UNIQUE ([strUserName])')
			END 
			
			EXEC('UPDATE tblEMEntity set strEntityNo = null where intEntityId = ' + @CurMergeId)
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH
		
GoHere:
		delete from #tmpMerge where Item = @CurMergeItem

	end

	drop table #tmpMerge
END

