


CREATE PROCEDURE [dbo].[uspSMRepExtendedDist]
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

DECLARE @SQL NVARCHAR(MAX);



SET @SQL = N'USE [distribution] DECLARE @result int; ' +
           'IF(NOT EXISTS(SELECT * FROM sysobjects WHERE name = N''UIProperties'' AND type = ''U'')) ' +
           'CREATE TABLE UIProperties(id INT) ' +
		   'IF(EXISTS(SELECT * FROM:: fn_listextendedproperty(''SnapshotFolder'',''user'', ''dbo'',''table'',''UIProperties'', null, null))) ' +
		   'EXEC @result = sp_updateextendedproperty N''SnapshotFolder'', null, ''user'', dbo, ''table'', ''UIProperties'' ' +
		   'ELSE EXEC @result = sp_addextendedproperty N''SnapshotFolder'', null, ''user'', dbo, ''table'', ''UIProperties'' '+
		   
		    'UPDATE [@DB_NAME].[dbo].tblSMReplicationSPResult SET result = @result';


			SET @SQL = REPLACE(@SQL ,'@DB_NAME', DB_NAME())
		 EXEC(@SQL)

END

