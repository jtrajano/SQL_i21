CREATE PROCEDURE [dbo].[uspGRUpdateStorageChargeFromImport]
(
	@storageAccrueFile NVARCHAR(MAX)
	,@intUserId INT
)
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY	
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @transCount INT = @@TRANCOUNT;
	DECLARE @sql NVARCHAR(MAX);	
	DECLARE @totalRows INT
	DECLARE @counter BIGINT = 1
	DECLARE @successCounter BIGINT = 0
	DECLARE @deliverySheetNo NVARCHAR(40)
	DECLARE @strStorageType NVARCHAR(20)
	DECLARE @strStorageSchedule NVARCHAR(10)
	DECLARE @dtmDeliveryDate DATETIME
	DECLARE @dblUnits DECIMAL(18,6)
	DECLARE @dblRate DECIMAL(18,6)
	DECLARE @BillStorage BillStorageTableType
	DECLARE @strEntityNo NVARCHAR(100)
	DECLARE @intEntityId INT
	DECLARE @dtmAccrualDate DATETIME

	IF @transCount = 0 BEGIN TRANSACTION

		IF OBJECT_ID('tempdb..#tmpBillStorageImport') IS NOT NULL DROP TABLE #tmpBillStorageImport

		CREATE TABLE #tmpBillStorageImport
		(
			[strEntityNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, --ACCT/ENTITY #
			[strName] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, --NAME
			[strStorageSchedule] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, --TYPE
			[strDeliverySheetNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, --SHEET
			[strDate] CHAR(12) COLLATE Latin1_General_CI_AS NULL, --DATE
			[strStorageType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, --DIST
			[strCalcDate] CHAR(12) COLLATE Latin1_General_CI_AS NULL, --THRU DATE
			[strUnits] NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL, --UNITS
			[strRate] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, --RATE			
			[strCharge] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL --CHARGE			
		)

		IF OBJECT_ID('tempdb..#tmpDeliverySheetDetails') IS NOT NULL DROP TABLE #tmpDeliverySheetDetails

		CREATE TABLE #tmpDeliverySheetDetails
		(
			[intDeliverySheetId] INT,
			[strDeliverySheetNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
			[intItemId] INT,
			[intEntityId] INT,
			[intCompanyLocationId] INT,
			[intStorageTypeId] INT,
			[intStorageScheduleId] INT		
		)

		IF OBJECT_ID('tempdb..#tmpCSId') IS NOT NULL DROP TABLE #tmpCSId

		CREATE TABLE #tmpCSId
		(
			[intCustomerStorageId] INT PRIMARY KEY,
			[strDeliverySheetNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, --SHEET
			[strEntityNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL--ACCT #
			UNIQUE ([intCustomerStorageId])			
		)

		BEGIN TRY

			SET @sql = 'BULK INSERT #tmpBillStorageImport
			FROM ''' + @storageAccrueFile + '''
			WITH
			(
				FIELDTERMINATOR = ''\t''
				,FIRSTROW = 2
				,ROWTERMINATOR = ''0x0a''
			)'

			EXEC(@sql);

		END TRY
		BEGIN CATCH
			RAISERROR('Invalid file format.', 16, 1);
		END CATCH

		IF (SELECT COUNT(*) FROM #tmpBillStorageImport) > 0
		BEGIN		
			SELECT @totalRows = COUNT(*) FROM #tmpBillStorageImport

			UPDATE #tmpBillStorageImport 
			SET strUnits = REPLACE(REPLACE(strUnits,',',''),'"',''), 
				strRate = REPLACE(REPLACE(REPLACE(strRate,',',''),'"',''),' ','')

			WHILE @counter <= @totalRows
			BEGIN
				SET @deliverySheetNo	= NULL
				SET	@strStorageType		= NULL
				SET	@strStorageSchedule	= NULL
				SET	@dtmDeliveryDate	= NULL
				SET	@dblUnits			= NULL
				SET	@dblRate			= NULL
				SET	@intEntityId		= NULL
				SET @dtmAccrualDate		= NULL
				SET @strEntityNo		= NULL

				SELECT 
					@deliverySheetNo		= BS.strDeliverySheetNumber
					,@strStorageType		= BS.strStorageType
					,@strStorageSchedule	= BS.strStorageSchedule
					,@dtmDeliveryDate		= BS.dtmDeliveryDate
					,@dblUnits				= BS.dblUnits
					,@dblRate				= BS.dblRate
					,@strEntityNo			= BS.strEntityNo
					,@dtmAccrualDate		= BS.dtmAccrualDate
				FROM (
					SELECT 
						 strDeliverySheetNumber
						,strStorageType
						,strStorageSchedule
						,dbo.fnRemoveTimeOnDate(CONVERT(DATETIME2, strDate, 101)) AS dtmDeliveryDate
						,CASE WHEN ISNUMERIC(strUnits) = 1 THEN CAST(strUnits AS DECIMAL(18,6)) ELSE 0 END dblUnits
						,CASE WHEN ISNUMERIC(strRate) = 1 THEN CAST(strRate AS DECIMAL(18,6)) ELSE 0 END dblRate
						,strEntityNo
						,dbo.fnRemoveTimeOnDate(CONVERT(DATETIME2, strCalcDate, 101)) AS dtmAccrualDate
						,ROW_NUMBER() OVER (ORDER BY strDeliverySheetNumber) AS rowNumber
					FROM #tmpBillStorageImport
				) BS
				WHERE BS.rowNumber = @counter
				ORDER BY BS.strDeliverySheetNumber
			
				--CHECK IF DELIVERY SHEET EXISTS
				--IF NOT EXISTS(SELECT 1 FROM tblSCDeliverySheet WHERE strDeliverySheetNumber = @deliverySheetNo)
				--BEGIN
				--	SET @ErrMsg = 'Delivery Sheet No.' + @deliverySheetNo + ' does not exist.'
				--	RAISERROR(@ErrMsg, 16, 1);
				--END

				--CHECK IF ACCOUNT# EXISTS
				--IF NOT EXISTS(SELECT 1 FROM tblEMEntity WHERE strEntityNo = @strEntityNo)
				--BEGIN
				--	SET @ErrMsg = 'Invalid Entity No. ' + @strEntityNo
				--	RAISERROR(@ErrMsg, 16, 1);
				--END
				--ELSE
				--BEGIN
				SELECT @intEntityId = intEntityId FROM tblEMEntity WHERE strEntityNo = @strEntityNo
				--END

				--CHECK IF RECORD IS VALID
				IF (ISNULL(@intEntityId,0) = 0)
					OR
					(ISNULL(@dblUnits,0) = 0 AND ISNULL(@dblRate,0) > 0)
					OR
					(ISNULL(@dblUnits,0) > 0 AND ISNULL(@dblRate,0) = 0)
					OR
					NOT EXISTS(
						SELECT 1 
						FROM tblSCDeliverySheetSplit DSS
						INNER JOIN tblSCDeliverySheet DS
							ON DS.intDeliverySheetId = DSS.intDeliverySheetId
						INNER JOIN tblGRStorageType ST
							ON ST.intStorageScheduleTypeId = DSS.intStorageScheduleTypeId
						INNER JOIN tblGRStorageScheduleRule SR
							ON SR.intStorageScheduleRuleId = DSS.intStorageScheduleRuleId
						WHERE DS.strDeliverySheetNumber = @deliverySheetNo
							AND DSS.intEntityId = @intEntityId
							AND ST.strStorageTypeCode = @strStorageType
							AND SR.strScheduleId = @strStorageSchedule
					)					
				BEGIN
					--SET @ErrMsg = 'Record does not exist in Delivery Sheet No. ' + @deliverySheetNo
					--RAISERROR(@ErrMsg, 16, 1);
					PRINT('Invalid record. Unable to accrue storage for Entity No. ' + @strEntityNo + ' in Delivery Sheet No. ' + @deliverySheetNo)
				END
				ELSE
				BEGIN
					DELETE FROM #tmpDeliverySheetDetails
					DELETE FROM @BillStorage

					INSERT INTO #tmpDeliverySheetDetails
					SELECT 
						DS.intDeliverySheetId
						,DS.strDeliverySheetNumber
						,DS.intItemId
						,DSS.intEntityId
						,DS.intCompanyLocationId
						,DSS.intStorageScheduleTypeId
						,DSS.intStorageScheduleRuleId
					FROM tblSCDeliverySheetSplit DSS
					INNER JOIN tblSCDeliverySheet DS
						ON DS.intDeliverySheetId = DSS.intDeliverySheetId
					INNER JOIN tblGRStorageType ST
						ON ST.intStorageScheduleTypeId = DSS.intStorageScheduleTypeId
					INNER JOIN tblGRStorageScheduleRule SR
						ON SR.intStorageScheduleRuleId = DSS.intStorageScheduleRuleId
					WHERE DS.strDeliverySheetNumber = @deliverySheetNo
						AND DSS.intEntityId = @intEntityId
						AND ST.strStorageTypeCode = @strStorageType
						AND SR.strScheduleId = @strStorageSchedule

					INSERT INTO @BillStorage
					SELECT
						[intCustomerStorageId]		= CS.intCustomerStorageId
						,[intEntityId]				= CS.intEntityId
						,[intCompanyLocationId]		= CS.intCompanyLocationId
						,[dblOpenBalance]			= @dblUnits
						,[intStorageTypeId]			= CS.intStorageTypeId
						,[dblNewStorageDue]			= @dblRate
						,[intItemId]				= CS.intItemId
						,[intStorageScheduleId]		= CS.intStorageScheduleId
					FROM tblGRCustomerStorage CS
					INNER JOIN #tmpDeliverySheetDetails DS
						ON DS.intDeliverySheetId = CS.intDeliverySheetId
							AND DS.intEntityId = CS.intEntityId
							AND DS.intCompanyLocationId = CS.intCompanyLocationId
							AND DS.intStorageTypeId = CS.intStorageTypeId
							AND DS.intStorageScheduleId = CS.intStorageScheduleId

					IF (SELECT COUNT(*) FROM @BillStorage) > 0
					BEGIN
						EXEC uspGRProcessBillStorage @dtmAccrualDate, 'Accrue', @intUserId, @BillStorage
						
						INSERT INTO #tmpCSId
						SELECT intCustomerStorageId, @deliverySheetNo, @strEntityNo FROM @BillStorage
					END
					ELSE
					BEGIN
						PRINT('No Storage record. Unable to accrue storage for Entity No. ' + @strEntityNo + ' in Delivery Sheet No. ' + @deliverySheetNo)
					END
				END

				SET @counter = @counter + 1

			END
		END

		select @successCounter = COUNT(*) FROM (
			SELECT CS.*
			FROM tblGRCustomerStorage CS
			INNER JOIN #tmpCSId CSId
				ON CSId.intCustomerStorageId = CS.intCustomerStorageId
		) C

		PRINT('Successfully accrued ' + CAST(@successCounter AS NVARCHAR(MAX)) + ' records.')
		
		select 'debug storage', H.* FROM 
		(
			SELECT CS.*
			FROM tblGRCustomerStorage CS
			INNER JOIN #tmpCSId CSId
				ON CSId.intCustomerStorageId = CS.intCustomerStorageId
		) H ORDER BY H.intCustomerStorageId

	
	DONE:
	IF @transCount = 0 COMMIT TRANSACTION

END TRY
BEGIN CATCH
	DECLARE @ErrorSeverity INT,
			@ErrorNumber   INT,
			@ErrorMessage nvarchar(4000),
			@ErrorState INT;
	-- Grab error information from SQL functions
	SET @ErrorSeverity = ERROR_SEVERITY()
	SET @ErrorNumber   = ERROR_NUMBER()
	SET @ErrorMessage  = ERROR_MESSAGE()
	SET @ErrorState    = ERROR_STATE()
	IF @transCount = 0 AND XACT_STATE() <> 0 ROLLBACK TRANSACTION
	RAISERROR (@ErrorMessage , @ErrorSeverity, @ErrorState, @ErrorNumber)
END CATCH

END