CREATE PROCEDURE [dbo].[uspDMMergeCTTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';
DECLARE @Columns NVARCHAR(MAX)


BEGIN

     -- tblCTContractHeader
	SET @Columns = NULL
	SELECT @Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractHeader' AND ORDINAL_POSITION > 1

    SET @SQLString = N'MERGE tblCTContractHeader AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractHeader]) AS Source
        ON (Target.intContractHeaderId = Source.intContractHeaderId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
        WHEN NOT MATCHED BY SOURCE THEN
             DELETE;';

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    SET IDENTITY_INSERT tblCTContractHeader ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractHeader OFF

    -- tblCTContractDetail
	SET @Columns = NULL
	SELECT @Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractDetail' AND ORDINAL_POSITION > 1

    SET @SQLString = N'MERGE tblCTContractDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractDetail]) AS Source
        ON (Target.intContractDetailId = Source.intContractDetailId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractDetail ON
    EXECUTE sp_executesql @SQLString;

    SET IDENTITY_INSERT tblCTContractDetail OFF

    -- tblCTContractCost
	SET @Columns = NULL
	SELECT @Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCost' AND ORDINAL_POSITION > 1

    SET @SQLString = N'MERGE tblCTContractCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCost]) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractCost ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCost OFF

	-- tblCTContractDocument
	SET @Columns = NULL
	SELECT @Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractDocument' AND ORDINAL_POSITION > 1

    SET @SQLString = N'MERGE tblCTContractDocument AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractDocument]) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractDocument ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractDocument OFF


	-- tblCTContractCondition
	SET @Columns = NULL
	SELECT @Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCondition' AND ORDINAL_POSITION > 1

    SET @SQLString = N'MERGE tblCTContractCondition AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCondition]) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractCondition ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCondition OFF

	-- tblCTContractCertification
	SET @Columns = NULL
	SELECT @Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblCTContractCertification' AND ORDINAL_POSITION > 1

    SET @SQLString = N'MERGE tblCTContractCertification AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblCTContractCertification]) AS Source
        ON (Target.intContractCostId = Source.intContractCostId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblCTContractCertification ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblCTContractCertification OFF
END