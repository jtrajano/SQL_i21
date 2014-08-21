
CREATE PROCEDURE uspFRMColumnDescription
@tableName varchar(30) = null
AS

	SELECT 
		col.TABLE_NAME
		, col.COLUMN_NAME
		, col.DATA_TYPE
		, CASE col.DATA_TYPE
			WHEN 'int' THEN '(' + cast(col.NUMERIC_PRECISION as varchar(10)) + '/' + cast(col.NUMERIC_SCALE as varchar(10)) + ')'
			WHEN 'numeric' THEN '(' + cast(col.NUMERIC_PRECISION as varchar(10)) + '/ ' + cast(col.NUMERIC_SCALE as varchar(10)) + ')'
			WHEN 'date' THEN 'N/A'
			WHEN 'datetime' THEN 'N/A'
			WHEN 'bit' THEN '1'
			WHEN 'varchar' THEN  cast(col.CHARACTER_MAXIMUM_LENGTH as varchar(10)) 
			WHEN 'nvarchar'  THEN  cast(col.CHARACTER_MAXIMUM_LENGTH as varchar(10))
			WHEN 'char'  THEN cast(col.CHARACTER_MAXIMUM_LENGTH as varchar(10)) 
			WHEN 'nchar'  THEN  cast(col.CHARACTER_MAXIMUM_LENGTH as varchar(10)) 
			
		END as SIZE
		, replace(cast(colDes.DESCRIPTION as nvarchar(max)), ',', '|')as [DESCRIPTION]
		
	FROM 
		INFORMATION_SCHEMA.COLUMNS col
		inner join vyuFRMColumnDescription colDes on col.TABLE_NAME = colDes.TABLE_NAME and col.COLUMN_NAME = colDes.COLUMN_NAME
	--where col.TABLE_NAME like 'tbl%'
	WHERE ISNULL(@tableName, col.TABLE_NAME) = col.TABLE_NAME
	order by col.TABLE_NAME