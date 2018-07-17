PRINT 'TRYING TO DELETE CONSTRAINTS RELATED TO ENTITY'

IF EXISTS(SELECT TOP 1 1 FROM sys.objects where name = 'tblEntityTempForDelete')
BEGIN
	PRINT 'BEGIN DELETE CONSTRAINTS RELATED TO ENTITY'
	/*
		D 
		UQ
		F
		PK
	*/
	DECLARE @tmp TABLE(
		name nvarchar(max), 
		parent_object_id int
	)
	insert into @tmp
	select name,parent_object_id from sys.objects where OBJECT_NAME(parent_object_id) like '%tblEMEntity%' and type = 'D'	
	DECLARE @Current NVARCHAR(MAX)
	DECLARE @Name NVARCHAR(MAX)
	while exists(select top 1 1 from @tmp)
	BEGIN
		SELECT TOP 1 @Current = 'ALTER TABLE ' + OBJECT_NAME(parent_object_id) + ' DROP CONSTRAINT [' + name + ']', @Name = name FROM @tmp
		EXEC( @Current )
		DELETE FROM @tmp WHERE name = @Name
	END
	

	insert into @tmp
	select name,parent_object_id from sys.objects where OBJECT_NAME(parent_object_id) like '%tblEMEntity%' and type = 'UQ'
	while exists(select top 1 1 from @tmp)
	BEGIN
		SELECT TOP 1 @Current = 'ALTER TABLE ' + OBJECT_NAME(parent_object_id) + ' DROP CONSTRAINT [' + name + ']', @Name = name FROM @tmp
		EXEC( @Current )
		DELETE FROM @tmp WHERE name = @Name
	END
	

	insert into @tmp
	select name,parent_object_id from sys.objects where OBJECT_NAME(parent_object_id) like '%tblEMEntity%' and type = 'F'
	while exists(select top 1 1 from @tmp)
	BEGIN
		SELECT TOP 1 @Current = 'ALTER TABLE ' + OBJECT_NAME(parent_object_id) + ' DROP CONSTRAINT [' + name + ']', @Name = name FROM @tmp
		EXEC( @Current )
		DELETE FROM @tmp WHERE name = @Name
	END

	insert into @tmp
	SELECT
		'ALTER TABLE ' + R.TABLE_NAME + ' DROP CONSTRAINT [' + FK.CONSTRAINT_NAME + ']' name, 1 parent_object_id
	FROM INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE U
		INNER JOIN INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS FK
			ON U.CONSTRAINT_CATALOG = FK.UNIQUE_CONSTRAINT_CATALOG
				AND U.CONSTRAINT_SCHEMA = FK.UNIQUE_CONSTRAINT_SCHEMA
				AND U.CONSTRAINT_NAME = FK.UNIQUE_CONSTRAINT_NAME
		INNER JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE R
			ON R.CONSTRAINT_CATALOG = FK.CONSTRAINT_CATALOG
				AND R.CONSTRAINT_SCHEMA = FK.CONSTRAINT_SCHEMA
				AND R.CONSTRAINT_NAME = FK.CONSTRAINT_NAME  
		WHERE U.TABLE_NAME like '%tblEMEntity%'

	while exists(select top 1 1 from @tmp)
	BEGIN
		SELECT TOP 1 @Current = name, @Name = name FROM @tmp
		EXEC( @Current )
		DELETE FROM @tmp WHERE name = @Name
	END


	insert into @tmp
	select name,parent_object_id from sys.objects where OBJECT_NAME(parent_object_id) like '%tblEMEntity%' and type = 'PK'
	while exists(select top 1 1 from @tmp)
	BEGIN
		SELECT TOP 1 @Current = 'ALTER TABLE ' + OBJECT_NAME(parent_object_id) + ' DROP CONSTRAINT [' + name + ']', @Name = name FROM @tmp
		EXEC( @Current )
		DELETE FROM @tmp WHERE name = @Name
	END

	PRINT 'END DELETE CONSTRAINTS RELATED TO ENTITY'

	EXEC('DROP TABLE tblEMEntityTempForDelete')
	
END







