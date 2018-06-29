CREATE PROCEDURE [dbo].[uspDMMergeGRTables]
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

   -- tblGRStorageType
   SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageType' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageType'

    SET @SQLString = N'MERGE tblGRStorageType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageType]) AS Source
        ON (Target.intStorageScheduleTypeId = Source.intStorageScheduleTypeId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRStorageType ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageType OFF
    
    -- tblGRStorageScheduleRule
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageScheduleRule' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageScheduleRule'

    SET @SQLString = N'MERGE tblGRStorageScheduleRule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageScheduleRule]) AS Source
        ON (Target.intStorageScheduleRuleId = Source.intStorageScheduleRuleId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRStorageScheduleRule ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageScheduleRule OFF

    -- tblGRStorageScheduleLocationUse
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageScheduleLocationUse' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageScheduleLocationUse'

    SET @SQLString = N'MERGE tblGRStorageScheduleLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageScheduleLocationUse]) AS Source
        ON (Target.intStorageScheduleLocationUseId = Source.intStorageScheduleLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRStorageScheduleLocationUse ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageScheduleLocationUse OFF    
    
    -- tblGRStorageSchedulePeriod
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageSchedulePeriod' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRStorageSchedulePeriod'

    SET @SQLString = N'MERGE tblGRStorageSchedulePeriod AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRStorageSchedulePeriod]) AS Source
        ON (Target.intStorageSchedulePeriodId = Source.intStorageSchedulePeriodId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRStorageSchedulePeriod ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRStorageSchedulePeriod OFF    

    -- tblGRDiscountSchedule
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountSchedule' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountSchedule'

    SET @SQLString = N'MERGE tblGRDiscountSchedule AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountSchedule]) AS Source
        ON (Target.intDiscountScheduleId = Source.intDiscountScheduleId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRDiscountSchedule ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountSchedule OFF

    -- tblGRDiscountCalculationOption
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountCalculationOption' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountCalculationOption'

    SET @SQLString = N'MERGE tblGRDiscountCalculationOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountCalculationOption]) AS Source
        ON (Target.intDiscountCalculationOptionId  = Source.intDiscountCalculationOptionId )
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRShrinkCalculationOption
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRShrinkCalculationOption' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRShrinkCalculationOption'

    SET @SQLString = N'MERGE tblGRShrinkCalculationOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRShrinkCalculationOption]) AS Source
        ON (Target.intShrinkCalculationOptionId  = Source.intShrinkCalculationOptionId )
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblGRDiscountScheduleCode
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountScheduleCode' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountScheduleCode'

    SET @SQLString = N'MERGE tblGRDiscountScheduleCode AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountScheduleCode]) AS Source
        ON (Target.intDiscountScheduleCodeId = Source.intDiscountScheduleCodeId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRDiscountScheduleCode ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountScheduleCode OFF

    -- tblGRDiscountScheduleLine
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountScheduleLine' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountScheduleLine'

    SET @SQLString = N'MERGE tblGRDiscountScheduleLine AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountScheduleLine]) AS Source
        ON (Target.intDiscountScheduleLineId = Source.intDiscountScheduleLineId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRDiscountScheduleLine ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountScheduleLine OFF
    
    -- tblGRDiscountId
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountId' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountId'

    SET @SQLString = N'MERGE tblGRDiscountId AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountId]) AS Source
        ON (Target.intDiscountCrossReferenceId = Source.intDiscountCrossReferenceId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRDiscountId ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountId OFF

    -- tblGRDiscountCrossReference
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountCrossReference' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountCrossReference'

    SET @SQLString = N'MERGE tblGRDiscountCrossReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountCrossReference]) AS Source
        ON (Target.intDiscountCrossReferenceId = Source.intDiscountCrossReferenceId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRDiscountCrossReference ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountCrossReference OFF

    -- tblGRDiscountLocationUse
    SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountLocationUse' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblGRDiscountLocationUse'

    SET @SQLString = N'MERGE tblGRDiscountLocationUse AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblGRDiscountLocationUse]) AS Source
        ON (Target.intDiscountLocationUseId = Source.intDiscountLocationUseId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblGRDiscountLocationUse ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblGRDiscountLocationUse OFF

END