GO
PRINT N'*** BEGIN - Schema Fix for tblPATCustomerVolume ***'
GO

IF EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATCustomerVolume' AND [COLUMN_NAME] = 'dblVolumeProcessed') 
BEGIN
	-- Default existing dblVolumeProcessed to 0
	EXEC('
		UPDATE tblPATCustomerVolume 
		SET dblVolumeProcessed = 0
		WHERE dblVolumeProcessed IS NULL
	')
	
	--	Column Value Transitioning for Volume Processed
	EXEC('
		SELECT	intFiscalYear,
				intCustomerPatronId,
				intPatronageCategoryId,
				dblVolume = SUM(dblVolume),
				ysnRefundProcessed
		INTO #tmpProcessedCustomerVolume
		FROM tblPATCustomerVolume
		WHERE ysnRefundProcessed = 1
		GROUP BY intFiscalYear,
				intCustomerPatronId,
				intPatronageCategoryId,
				ysnRefundProcessed

		IF EXISTS(SELECT 1 FROM #tmpProcessedCustomerVolume)
		BEGIN
			DELETE VolumeMaster FROM tblPATCustomerVolume VolumeMaster
			INNER JOIN #tmpProcessedCustomerVolume tempVolume
				ON tempVolume.intFiscalYear = VolumeMaster.intFiscalYear
					AND tempVolume.intCustomerPatronId = VolumeMaster.intCustomerPatronId
					AND tempVolume.intPatronageCategoryId = VolumeMaster.intPatronageCategoryId
			WHERE VolumeMaster.ysnRefundProcessed = 1

			MERGE
			INTO tblPATCustomerVolume
			WITH (HOLDLOCK)
			AS VolumeMaster
			USING #tmpProcessedCustomerVolume tempVolume
				ON tempVolume.intFiscalYear = VolumeMaster.intFiscalYear
				AND tempVolume.intCustomerPatronId = VolumeMaster.intCustomerPatronId
				AND tempVolume.intPatronageCategoryId = VolumeMaster.intPatronageCategoryId
			WHEN MATCHED THEN
				UPDATE SET
					VolumeMaster.dblVolumeProcessed = VolumeMaster.dblVolumeProcessed + tempVolume.dblVolume,
					VolumeMaster.dblVolume = VolumeMaster.dblVolumeProcessed + tempVolume.dblVolume
			WHEN NOT MATCHED THEN
				INSERT (
					intFiscalYear,
					intCustomerPatronId,
					intPatronageCategoryId,
					dblVolume,
					dblVolumeProcessed,
					intConcurrencyId
				)
				VALUES(
					tempVolume.intFiscalYear,
					tempVolume.intCustomerPatronId,
					tempVolume.intPatronageCategoryId,
					tempVolume.dblVolume,
					tempVolume.dblVolume,
					1
				);
			
		END
	')

END

GO
PRINT N'*** END - Schema Fix for tblPATCustomerVolume ***'
GO