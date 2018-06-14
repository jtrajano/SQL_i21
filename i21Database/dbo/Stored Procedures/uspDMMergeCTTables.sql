CREATE PROCEDURE [dbo].[uspDMMergeCTTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';
DECLARE @Columns NVARCHAR(MAX),
		@InsertColumns NVARCHAR(MAX),
		@ValueColumns NVARCHAR(MAX)
BEGIN

     -- tblCTContractHeader
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractHeader' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractHeader'

    SET @SQLString = N'MERGE tblCTContractHeader AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractHeader]) AS Source
        ON (Target.intContractHeaderId = Source.intContractHeaderId)
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

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    SET IDENTITY_INSERT tblCTContractHeader ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractHeader OFF

    -- tblCTContractDetail
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractDetail' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractDetail'

    SET @SQLString = N'MERGE tblCTContractDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractDetail]) AS Source
        ON (Target.intContractDetailId = Source.intContractDetailId)
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
    SET IDENTITY_INSERT tblCTContractDetail ON
    EXECUTE sp_executesql @SQLString;

    SET IDENTITY_INSERT tblCTContractDetail OFF

    -- tblCTContractCost
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCost' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCost'

    SET @SQLString = N'MERGE tblCTContractCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCost]) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
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
    SET IDENTITY_INSERT tblCTContractCost ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCost OFF

	-- tblCTContractDocument
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractDocument' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractDocument'

    SET @SQLString = N'MERGE tblCTContractDocument AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractDocument]) AS Source
        ON (Target.intContractDocumentId = Source.intContractDocumentId)
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
    SET IDENTITY_INSERT tblCTContractDocument ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractDocument OFF


	-- tblCTContractCondition
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCondition' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCondition'

    SET @SQLString = N'MERGE tblCTContractCondition AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCondition]) AS Source
        ON (Target.intContractConditionId = Source.intContractConditionId)
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
    SET IDENTITY_INSERT tblCTContractCondition ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCondition OFF

	-- tblCTContractCertification
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCertification' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCertification'

    SET @SQLString = N'MERGE tblCTContractCertification AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCertification]) AS Source
        ON (Target.intContractCertificationId = Source.intContractCertificationId)
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
    SET IDENTITY_INSERT tblCTContractCertification ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCertification OFF
END