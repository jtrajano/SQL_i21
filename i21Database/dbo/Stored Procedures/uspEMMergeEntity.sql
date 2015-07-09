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
	
	declare @RelationShips table 
	(
		stment nvarchar(max)
	)

	declare @EntityRelationShips table 
	(
		stment nvarchar(max)
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

		if exists(select top 1 1 from tblEntityType where intEntityId = @PrimaryKey and strType = @CurMergeType)
			goto GoHere

		if @CurMergeType = 'Customer'
		begin
			set @CurTableName = 'tblARCustomer'
			set @CurTableKey = 'intEntityCustomerId'
		end
		else if @CurMergeType = 'Vendor'
		begin
			set @CurTableName = 'tblAPVendor'
			set @CurTableKey = 'intEntityVendorId'
		end
		else if @CurMergeType = 'Salesperson'
		begin
			set @CurTableName = 'tblARSalesperson'
			set @CurTableKey = 'intEntitySalespersonId'
		end

		SELECT @Columns = COALESCE(@Columns + ', ', '') + name from syscolumns where id = object_id(@CurTableName) and name <> @CurTableKey
		
		insert into @RelationShips
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
		WHERE U.TABLE_NAME = @CurTableName --OR U.TABLE_NAME = 'tblEntity'

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
		WHERE U.TABLE_NAME = 'tblEntity'  AND R.TABLE_NAME <> @CurTableName

		BEGIN TRANSACTION
		BEGIN TRY
			EXEC ( 'insert into tblEntityType ( intEntityId, strType, intConcurrencyId) values ('+ @PrimaryKeyString +','''+@CurMergeType+''',0 )
					insert into '+ @CurTableName +'(' + @CurTableKey +@Columns + ') 
							select '+ @PrimaryKeyString + @Columns + ' 
								from ' + @CurTableName + ' 
									where ' + @CurTableKey + ' = ' +  @CurMergeId)
			EXEC('delete from tblEntityType where intEntityId = ' + @CurMergeId + ' and strType = ''' + @CurMergeType + '''' )
			EXEC('update tblEntityLocation set ysnDefaultLocation = 0 where intEntityId = ' + @CurMergeId)
			EXEC('update tblEntityToContact set ysnDefaultContact = 0 where intEntityId = ' + @CurMergeId)
			--PRINT 'Execute relationships'
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @RelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @RelationShips
				
				EXEC(@CurStatement)
				
				delete from @RelationShips where stment = @CurStatement
			END 
			PRINT 'Execute entity relationships'
			SET @CurStatement = ''
			WHILE EXISTS(SELECT TOP 1 1 FROM  @EntityRelationShips)
			BEGIN
				SELECT TOP 1 @CurStatement = stment FROM @EntityRelationShips
				
				EXEC(@CurStatement)
				
				delete from @EntityRelationShips where stment = @CurStatement
			END 
			
			EXEC('delete from ' + @CurTableName + ' where ' + @CurTableKey + ' = ' + @CurMergeId )

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