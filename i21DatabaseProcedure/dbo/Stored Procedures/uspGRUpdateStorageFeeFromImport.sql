CREATE PROCEDURE [dbo].[uspGRUpdateStorageFeeFromImport]
(
	@storageFeeFile NVARCHAR(MAX)
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
	DECLARE @successRows INT = 0
	DECLARE @failedRows INT = 0

	IF @transCount = 0 BEGIN TRANSACTION

		IF OBJECT_ID('tempdb..#tmpStorageFeeImport') IS NOT NULL DROP TABLE #tmpStorageFeeImport

		CREATE TABLE #tmpStorageFeeImport
		(
			[strDeliverySheetNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, --SHEET
			[strEntityNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, --ENTITY #			
			[strStorageFee] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL, --INSPECTION FEE
			[strAmount1] NVARCHAR(500) COLLATE Latin1_General_CI_AS NULL --AMOUNT1
		)

		IF OBJECT_ID('tempdb..#tmpStorageRecords') IS NOT NULL DROP TABLE #tmpStorageRecords

		CREATE TABLE #tmpStorageRecords
		(
			[intCustomerStorageId] INT,
			[dblStorageFee] DECIMAL(38,20),
			[strDeliverySheetNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, --SHEET
			[strEntityNo] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL --ENTITY #
			UNIQUE ([intCustomerStorageId])
		)

		BEGIN TRY

			SET @sql = 'BULK INSERT #tmpStorageFeeImport
			FROM ''' + @storageFeeFile + '''
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

		IF (SELECT COUNT(*) FROM #tmpStorageFeeImport) > 0
		BEGIN
			UPDATE #tmpStorageFeeImport 
			SET strStorageFee = REPLACE(REPLACE(REPLACE(strStorageFee,',',''),'"',''),' ','')

			INSERT INTO #tmpStorageRecords
			SELECT DISTINCT
				CS.intCustomerStorageId
				,CASE WHEN ISNUMERIC(strStorageFee) = 1 THEN CAST(strStorageFee AS DECIMAL(18,6)) ELSE 0 END dblStorageFee
				,SF.strDeliverySheetNumber
				,SF.strEntityNo
			FROM #tmpStorageFeeImport SF
			INNER JOIN tblEMEntity EM
				ON EM.strEntityNo = SF.strEntityNo
			INNER JOIN tblSCDeliverySheet DS
				ON DS.strDeliverySheetNumber = SF.strDeliverySheetNumber
			INNER JOIN tblSCDeliverySheetSplit DSS
				ON DSS.intDeliverySheetId = DS.intDeliverySheetId
					AND DSS.intEntityId = EM.intEntityId
			INNER JOIN tblGRCustomerStorage CS
				ON CS.intDeliverySheetId = DS.intDeliverySheetId
					AND CS.intEntityId = DSS.intEntityId

			UPDATE CS
			SET CS.dblFeesDue = SR.dblStorageFee
			FROM tblGRCustomerStorage CS
			INNER JOIN #tmpStorageRecords SR
				ON SR.intCustomerStorageId = CS.intCustomerStorageId
			WHERE SR.dblStorageFee > 0
			
			SELECT @successRows = COUNT(*) FROM #tmpStorageRecords WHERE dblStorageFee > 0

			PRINT('Successfully updated ' + CAST(@successRows AS NVARCHAR(MAX)) + ' records.')

			SELECT @failedRows = COUNT(*)
			FROM #tmpStorageFeeImport SF
			LEFT JOIN #tmpStorageRecords SR
				ON SR.strDeliverySheetNumber = SF.strDeliverySheetNumber
					AND SR.strEntityNo = SF.strEntityNo
			WHERE SR.strDeliverySheetNumber IS NULL

			PRINT('Failed to update ' + CAST(@failedRows AS NVARCHAR(MAX)) + ' records.')

			SELECT 'FAILED' FAILED, A.* FROM 
			(
				SELECT SF.*
				FROM #tmpStorageFeeImport SF
				LEFT JOIN #tmpStorageRecords SR
					ON SR.strDeliverySheetNumber = SF.strDeliverySheetNumber
						AND SR.strEntityNo = SF.strEntityNo
				WHERE SR.strDeliverySheetNumber IS NULL
			)A ORDER BY A.strDeliverySheetNumber

			SELECT 'SUCCESS' SUCCESS, B.* FROM
			(
				SELECT CS.dblFeesDue, CS.intCustomerStorageId, SR.strDeliverySheetNumber, SR.strEntityNo
				FROM tblGRCustomerStorage CS
				INNER JOIN #tmpStorageRecords SR
					ON SR.intCustomerStorageId = CS.intCustomerStorageId
				WHERE SR.dblStorageFee > 0
			)B
		END

	
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