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
		

		select top 1 @CurMergeItem = Item from #tmpMerge

		select @CurMergeId = SUBSTRING(@CurMergeItem,0,CHARINDEX('.',@CurMergeItem))
		,@CurMergeType = SUBSTRING(@CurMergeItem, CHARINDEX('.',@CurMergeItem)+ 1 , LEN(@CurMergeItem))

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
		
		SELECT
			@RefUpdateCommand = COALESCE(@RefUpdateCommand, '') + 'UPDATE ' + R.TABLE_NAME + ' SET ' +  R.COLUMN_NAME + '='+ @PrimaryKeyString +' WHERE ' + R.COLUMN_NAME  + '=' + @CurMergeId + ';'
		FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
			AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
			AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
			AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
			AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME
		WHERE U.TABLE_NAME = @CurTableName

		BEGIN TRANSACTION
		BEGIN TRY
			EXEC ( 'insert into tblEntityType ( intEntityId, strType, intConcurrencyId) values ('+ @PrimaryKeyString +','''+@CurMergeType+''',0 )
					insert into '+ @CurTableName +'(' + @CurTableKey +@Columns + ') 
							select '+ @PrimaryKeyString + @Columns + ' 
								from ' + @CurTableName + ' 
									where ' + @CurTableKey + ' = ' +  @CurMergeId)
			EXEC('delete from tblEntityType where intEntityId = ' + @CurMergeId + ' and strType = ''' + @CurMergeType + '''' )

			EXEC(@RefUpdateCommand)

			EXEC('delete from ' + @CurTableName + ' where ' + @CurTableKey + ' = ' + @CurMergeId )
			COMMIT
		END TRY
		BEGIN CATCH
			ROLLBACK TRANSACTION
		END CATCH
		

		delete from #tmpMerge where Item = @CurMergeItem
	end

	drop table #tmpMerge
END