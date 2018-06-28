CREATE PROCEDURE [dbo].[uspDMMergeEMTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';
DECLARE @Columns NVARCHAR(MAX),
		@InsertColumns NVARCHAR(MAX),
		@ValueColumns NVARCHAR(MAX);

BEGIN

	-- tblEMEntity  
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntity' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
	@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntity'
	    
      SET @SQLString = N'MERGE tblEMEntity AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntity]) AS Source
        ON (Target.intEntityId = Source.intEntityId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				'+@InsertColumns+'
				
			)
			VALUES(
				'+@ValueColumns+'
				)
		WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

     SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

	 SET IDENTITY_INSERT tblEMEntity ON
	 EXECUTE sp_executesql @SQLString;
	 SET IDENTITY_INSERT tblEMEntity OFF
    
	-- tblEMEntityCredential
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntityCredential' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
	@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntityCredential'

    SET @SQLString = N'MERGE tblEMEntityCredential AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntityCredential]) AS Source
        ON (Target.intEntityCredentialId = Source.intEntityCredentialId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				'+@InsertColumns+'
				
			)
			VALUES(
				'+@ValueColumns+'
				)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    
	SET IDENTITY_INSERT tblEMEntityCredential ON
	EXECUTE sp_executesql @SQLString;
	SET IDENTITY_INSERT tblEMEntityCredential OFF

    -- tblEMEntityLocation
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntityLocation' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
	@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblEMEntityLocation'
	SET @SQLString = N'MERGE tblEMEntityLocation AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblEMEntityLocation]) AS Source
        ON (Target.intEntityLocationId = Source.intEntityLocationId)
        WHEN MATCHED THEN
           UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				'+@InsertColumns+'
				
			)
			VALUES(
				'+@ValueColumns+'
				)
	     WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

	 SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

	 SET IDENTITY_INSERT tblEMEntityLocation ON
	 EXECUTE sp_executesql @SQLString;
	 SET IDENTITY_INSERT tblEMEntityLocation OFF

END