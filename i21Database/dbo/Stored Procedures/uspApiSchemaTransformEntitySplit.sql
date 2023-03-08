CREATE PROCEDURE [dbo].[uspApiSchemaTransformEntitySplit]
	@guiApiUniqueId UNIQUEIDENTIFIER,
    @guiLogId		UNIQUEIDENTIFIER
AS

DECLARE @strEntityNo			NVARCHAR(100), 
		@strSplitNumber			NVARCHAR(100),
		@strExceptionCategories	NVARCHAR(MAX),
		@strFarm				NVARCHAR(MAX),
		@strDescription			NVARCHAR(MAX),
		@strEntityType			NVARCHAR(100),
		@strSplitEntityNo		NVARCHAR(100),
		@strPercent				NVARCHAR(100),
		@strOption				NVARCHAR(100),
		@strStorageTypeCode		NVARCHAR(100)
		
DECLARE @intRowNo					INT;
DECLARE @intSplitId					INT;
DECLARE @intEntityId				INT;
DECLARE @intFarmId					INT;
DECLARE @intStorageScheduleTypeId	INT;
DECLARE @intSplitEntityId			INT;
DECLARE @dblTotalPercent			DECIMAL(18, 6);

DECLARE @overWrite				BIT;
DECLARE @stopOnError			BIT;
DECLARE @withError				BIT;


DECLARE @name				NVARCHAR(255);
DECLARE @intCategoryId		INT;
DECLARE @pos				INT;
DECLARE @intNullCategory	INT;

-- temp table clean up
IF OBJECT_ID('tempdb..#tbl_ExceptionCategories') IS NOT NULL
	DROP TABLE #tbl_ExceptionCategories
IF OBJECT_ID('tempdb..#tblEMEntitySplitHeader') IS NOT NULL
	DROP TABLE #tblEMEntitySplitHeader
IF OBJECT_ID('tempdb..#tblEMEntitySplitDetail') IS NOT NULL
	DROP TABLE #tblEMEntitySplitDetail

CREATE TABLE #tbl_ExceptionCategories(
	strCategory NVARCHAR(100),
	intCategoryId INT
);

CREATE TABLE #tblEMEntitySplitDetail(
	intDetailId		INT IDENTITY(1,1) PRIMARY KEY,
	intHeaderId		INT,
	intEntityId		INT,
	dblSplitPercent	DECIMAL(18,6),
	strOption		NVARCHAR(100), 
	intRowNumber	INT,
	intStorageScheduleTypeId	INT
);
BEGIN TRY

	DECLARE @transCount INT = @@TRANCOUNT

	IF @transCount = 0 BEGIN TRANSACTION

	SELECT	@overWrite = CAST(Overwrite AS BIT), @stopOnError = CAST(StopOnError AS BIT)
	FROM	(SELECT tp.strPropertyName, tp.varPropertyValue FROM tblApiSchemaTransformProperty AS tp WHERE tp.guiApiUniqueId = @guiApiUniqueId) AS Properties
	PIVOT	(MIN([varPropertyValue]) FOR [strPropertyName] IN (Overwrite, StopOnError)) AS PivotTable;

	DECLARE StagingCursor CURSOR LOCAL FOR 
	SELECT	intRowNumber,strEntityNo, strSplitNumber, strExceptionCategories, strFarm, strDescription, 
			strEntityType, strSplitEntityNo, strPercent, strOption, strStorageTypeCode
	FROM	tblApiSchemaEntitySplit
	WHERE	guiApiUniqueId = @guiApiUniqueId

	OPEN	StagingCursor 
	FETCH NEXT FROM StagingCursor INTO 
			@intRowNo, @strEntityNo, @strSplitNumber, @strExceptionCategories, @strFarm, @strDescription,
			@strEntityType, @strSplitEntityNo, @strPercent, @strOption, @strStorageTypeCode

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		SET @intEntityId				= NULL;
		SET @intSplitId					= NULL;
		SET @withError					= 0;
		SET @intStorageScheduleTypeId	= NULL;
		SET @intSplitEntityId			= NULL;
		SET @intFarmId					= NULL;
		SET @dblTotalPercent			= 0;

		SELECT	@dblTotalPercent = sum(cast(case when strPercent is null or strPercent = '' then 0 else strPercent end AS DECIMAL(18,6)))
		FROM	tblApiSchemaEntitySplit
		WHERE	strEntityNo = @strEntityNo AND
				strSplitNumber = @strSplitNumber
		GROUP BY strEntityNo, strSplitNumber

		-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Field Validations
		-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------	
	
		-- Entity Validation
		SELECT	@intEntityId = intEntityId
		FROM	tblEMEntity
		WHERE	strEntityNo = @strEntityNo;

		IF @intEntityId IS NULL 
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Entity No', @strEntityNo, 'Error', 'Failed', @intRowNo, 'Entity does not exist. Please check provided entity no');
			SET @withError = 1;
		END
		-- End Entity Validation
	
		-- Split Number Validation
	
		IF  @strSplitNumber IS NOT NULL
		BEGIN
			IF @overWrite = 0 AND @intEntityId IS NOT NULL
			BEGIN
				SELECT	@intSplitId = intSplitId
				FROM	tblEMEntitySplit
				WHERE	intEntityId = @intEntityId AND
						strSplitNumber = @strSplitNumber

				IF @intSplitId IS NOT NULL
				BEGIN
					INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
					VALUES(NEWID(),  @guiLogId, 'Split Number', @strSplitNumber, 'Error', 'Failed', @intRowNo, 'Split Number for entity already exists. Please make sure to check overwrite existing to replace existing records');
					SET @withError = 1;
				END
			END
			--ELSE
			--BEGIN
			--	SELECT	@intSplitId = intSplitId
			--	FROM	tblEMEntitySplit
			--	WHERE	intEntityId = @intEntityId AND
			--			strSplitNumber = @strSplitNumber
			--END
		END
		ELSE
		BEGIN
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Split Number', @strSplitNumber, 'Error', 'Failed', @intRowNo, 'Split Number is required');
			SET @withError = 1;
		END
	
		-- End Split Number Validation
	
		-- Exception Categories Validation
		IF ISNULL(@strExceptionCategories, '') != ''
		BEGIN
			DELETE FROM #tbl_ExceptionCategories
			WHILE CHARINDEX('.', @strExceptionCategories) > 0
			BEGIN
				SELECT @pos  = CHARINDEX('.', @strExceptionCategories)  
				SELECT @name = SUBSTRING(@strExceptionCategories, 1, @pos-1)
				SET @intCategoryId = NULL

				SELECT @intCategoryId = intCategoryId FROM tblICCategory WHERE strCategoryCode = @name
		  
				INSERT INTO	#tbl_ExceptionCategories(strCategory, intCategoryId)
				SELECT		@name, @intCategoryId

				SELECT @strExceptionCategories = SUBSTRING(@strExceptionCategories, @pos+1, LEN(@strExceptionCategories)-@pos)
			END
		 
			SET @intCategoryId = NULL
			SELECT @intCategoryId = intCategoryId FROM tblICCategory WHERE strCategoryCode = @strExceptionCategories
			INSERT INTO	#tbl_ExceptionCategories(strCategory, intCategoryId)
			SELECT		@strExceptionCategories, @intCategoryId

			 -- Validate exception categories if no invalid category
			 SELECT @intNullCategory = COUNT(*) FROM #tbl_ExceptionCategories WHERE intCategoryId = NULL

			 IF @intNullCategory > 0
			 BEGIN
				INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
				VALUES(NEWID(),  @guiLogId, 'Exception Category', @strExceptionCategories, 'Error', 'Failed', @intRowNo, 'Exception Category does not exists');
				SET @withError = 1;
			 END

		END
		-- End Exception Categories Validation
	
		-- Farm field Validation
		IF @strFarm IS NOT NULL AND @intEntityId IS NOT NULL
		BEGIN
			SELECT	@intFarmId = intEntityLocationId
			FROM	tblEMEntityLocation
			WHERE	strLocationName = @strFarm AND
					intEntityId = @intEntityId AND
					strLocationType = 'Farm'
		
			IF @intFarmId IS NULL
			BEGIN
			
				select 'Invalid Entity Location'
				INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
				VALUES(NEWID(),  @guiLogId, 'Farm', @strFarm, 'Error', 'Failed', @intRowNo, 'Entity Location Farm does not exists');
				SET @withError = 1;
			END

		END
		-- End Farm field Validation
	
		-- Entity Type Validation
		IF LOWER(@strEntityType) NOT IN ('vendor', 'customer', 'both')
		BEGIN

			select 'Invalid Entity Type'
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Entity Type', @strEntityType, 'Error', 'Failed', @intRowNo, 'Invalid Entity Type value');
			SET @withError = 1;

		END
		-- End Entity Type Validation
	
		-- Split Detail Entity Validation
		IF @strSplitEntityNo IS NULL
		BEGIN
		
			select 'Invalid Entity No'
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Split Entity No', @strSplitEntityNo, 'Error', 'Failed', @intRowNo, 'Split Entity No is required');
			SET @withError = 1;

		END
		ELSE
		BEGIN
			SELECT	@intSplitEntityId = intEntityId
			FROM	tblEMEntity
			WHERE	strEntityNo = @strSplitEntityNo;

			IF @intSplitEntityId IS NULL
			BEGIN
				select 'Invalid Split Entity No'
				INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
				VALUES(NEWID(),  @guiLogId, 'Split Entity No', @strSplitEntityNo, 'Error', 'Failed', @intRowNo, 'Split Entity No is does not exists');
				SET @withError = 1;
			END
			ELSE
			BEGIN 
				DECLARE @intCountType INT
				
				IF LOWER(@strEntityType) = 'both'
				BEGIN
					SELECT @intCountType = COUNT(*) FROM tblEMEntityType WHERE intEntityId = @intSplitEntityId and strType in ('Vendor', 'Customer')
				END
				ELSE
				BEGIN
					SELECT @intCountType = COUNT(*) FROM tblEMEntityType WHERE intEntityId = @intSplitEntityId and strType = @strEntityType
				END

				IF @intCountType = 0
				BEGIN
					INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
					VALUES(NEWID(),  @guiLogId, 'Split Entity No', @strSplitEntityNo, 'Error', 'Failed', @intRowNo, 'Selected entity type does not match provided split entity no');
					SET @withError = 1;
				END

			END
	
		END
		-- End Split Detail Entity Validation
	
		-- Split Percentage Validation
		IF @dblTotalPercent != 100
		BEGIN
			select 'Split Percentage not equal to 100'
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Percentage', @dblTotalPercent, 'Error', 'Failed', @intRowNo, 'Total Percentage for Split Number not equal to 100');
			SET @withError = 1;
		END
		-- End Split Percentage Validation
	
		-- Split Detail Option Validation
		IF LOWER(@strOption) NOT IN ('contract', 'spot sale', 'storage type')
		BEGIN

			select 'Invalid Option value'
			INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
			VALUES(NEWID(),  @guiLogId, 'Option', @strOption, 'Error', 'Failed', @intRowNo, 'Invalid Option value');
			SET @withError = 1;

		END
		-- End Split Detail Option Validation
	
		-- Split Detail Storage Type Validation
		IF @strStorageTypeCode IS NOT NULL
		BEGIN
		
			IF LOWER(@strOption) != 'storage type'
			BEGIN
				select 'Option must be Storage Type'
				INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
				VALUES(NEWID(),  @guiLogId, 'Storage Type Code', @strStorageTypeCode, 'Error', 'Failed', @intRowNo, 'Option must be Storage Type');
				SET @withError = 1;	
			END
			ELSE
			BEGIN
				SELECT	@intStorageScheduleTypeId = intStorageScheduleTypeId
				FROM	tblGRStorageType
				WHERE	strStorageTypeCode = @strStorageTypeCode

				IF @intStorageScheduleTypeId IS NULL
				BEGIN
					select 'Invalid Storage Type value'
					INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField , strValue, strLogLevel, strStatus, intRowNo, strMessage)
					VALUES(NEWID(),  @guiLogId, 'Storage Type', @strStorageTypeCode, 'Error', 'Failed', @intRowNo, 'Invalid Storage Type value');
					SET @withError = 1;	
				END

			END

		END
		-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------
		-- Field Validations
		-- --------------------------------------------------------------------------------------------------------------------------------------------------------------------	
		IF @withError = 0
		BEGIN
			SELECT	@intSplitId = intSplitId
			FROM	tblEMEntitySplit
			WHERE	intEntityId = @intEntityId AND
					strSplitNumber = @strSplitNumber

			IF @intSplitId IS NULL
			BEGIN

				INSERT INTO tblEMEntitySplit (intEntityId, intFarmId, strSplitNumber, strDescription, strSplitType, dblAcres, guiApiUniqueId, intRowNumber, intConcurrencyId)
				VALUES(@intEntityId, @intFarmId, @strSplitNumber, @strDescription, UPPER(LEFT(@strEntityType,1))+LOWER(SUBSTRING(@strEntityType,2,LEN(@strEntityType))), 0, @guiApiUniqueId, @intRowNo, 1)

				SET @intSplitId =  @@Identity;

			END
			ELSE
			BEGIN
				UPDATE	tblEMEntitySplit
				SET		strDescription = @strDescription,
						intFarmId = @intFarmId,
						strSplitType = UPPER(LEFT(@strEntityType,1))+LOWER(SUBSTRING(@strEntityType,2,LEN(@strEntityType))),
						guiApiUniqueId = @guiApiUniqueId,
						intRowNumber = @intRowNo
				WHERE	intSplitId = @intSplitId
			END

			INSERT INTO tblEMEntitySplitExceptionCategory(intSplitId, intCategoryId, intConcurrencyId)
			SELECT	@intSplitId, intCategoryId, 1
			FROM	#tbl_ExceptionCategories AS a
			WHERE	NOT EXISTS (SELECT * FROM tblEMEntitySplitExceptionCategory AS x WHERE a.intCategoryId = x.intCategoryId AND x.intSplitId = @intSplitId)

			INSERT INTO #tblEMEntitySplitDetail (intHeaderId, intEntityId, dblSplitPercent, strOption, intStorageScheduleTypeId, intRowNumber)
			VALUES(@intSplitId, @intSplitEntityId, cast(@strPercent AS DECIMAL(18,6)), @strOption, @intStorageScheduleTypeId, @intRowNo);

		END


		IF @stopOnError = 1 AND @withError = 1
			BREAK;

		FETCH NEXT FROM StagingCursor INTO 
			@intRowNo, @strEntityNo, @strSplitNumber, @strExceptionCategories, @strFarm, @strDescription,
			@strEntityType, @strSplitEntityNo, @strPercent, @strOption, @strStorageTypeCode
	END


	IF @withError = 0
	BEGIN
		DELETE FROM tblEMEntitySplitDetail
		WHERE	intSplitId in (SELECT intHeaderId FROM #tblEMEntitySplitDetail)

		INSERT INTO tblEMEntitySplitDetail(intSplitId, intEntityId, dblSplitPercent, strOption, intStorageScheduleTypeId, guiApiUniqueId, intRowNumber, intConcurrencyId)
		SELECT	a.intHeaderId, a.intEntityId, a.dblSplitPercent, a.strOption, a.intStorageScheduleTypeId, @guiApiUniqueId, intRowNumber, 1
		FROM	#tblEMEntitySplitDetail AS a;

	END

	IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT,
			@ErrorLine  INT,
			@ErrorProc nvarchar(200);

	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	SET @ErrorLine     = ERROR_LINE()

	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION

	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH
-- temp table clean up
IF OBJECT_ID('tempdb..#tbl_ExceptionCategories') IS NOT NULL
	DROP TABLE #tbl_ExceptionCategories
IF OBJECT_ID('tempdb..#tblEMEntitySplitHeader') IS NOT NULL
	DROP TABLE #tblEMEntitySplitHeader
IF OBJECT_ID('tempdb..#tblEMEntitySplitDetail') IS NOT NULL
	DROP TABLE #tblEMEntitySplitDetail