CREATE PROCEDURE [dbo].[uspSMReindexAllUserDefinedTables]
AS
BEGIN
	DECLARE table_cursor CURSOR FOR
	select 'DBCC DBREINDEX ('+'['+ name+']'+','+''''+''''+',70);
	' from sys.objects where type='u'

	DECLARE @result_query varchar(max)

	OPEN table_cursor
	FETCH NEXT FROM table_cursor into @result_query
	WHILE @@FETCH_STATUS = 0
	BEGIN
		EXEC(@result_query)
	FETCH NEXT FROM table_cursor into @result_query
	END

	CLOSE table_cursor
	DEALLOCATE table_cursor
END