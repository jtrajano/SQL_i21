GO
PRINT N'*** BEGIN - Volume Constraint Fix for tblPATCustomerVolume ***'
GO
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblPATCustomerVolume')
BEGIN
	EXEC('
		IF EXISTS(SELECT TOP 1 intCustomerPatronId, intPatronageCategoryId, intFiscalYear FROM tblPATCustomerVolume GROUP BY intCustomerPatronId, intPatronageCategoryId, intFiscalYear HAVING COUNT(*) > 1) 
		BEGIN
			CREATE TABLE #tempCustomerVolume(
				[intId] INT NOT NULL IDENTITY,
				[intCustomerPatronId] INT NULL, 
				[intPatronageCategoryId] INT NULL, 
				[intFiscalYear] INT NULL, 
				[dblVolume] NUMERIC(18, 6) NULL, 
				[dblVolumeProcessed] NUMERIC(18, 6) NULL DEFAULT(0)
			);
	
			INSERT INTO #tempCustomerVolume(
				[intCustomerPatronId], 
				[intPatronageCategoryId], 
				[intFiscalYear], 
				[dblVolume], 
				[dblVolumeProcessed]
			)
			SELECT	intCustomerPatronId, 
					intPatronageCategoryId, 
					intFiscalYear, 
					dblVolume = SUM(dblVolume), 
					dblVolumeProcessed = SUM(dblVolumeProcessed)
			FROM tblPATCustomerVolume
			GROUP BY intCustomerPatronId, intPatronageCategoryId, intFiscalYear
			HAVING COUNT(*) > 1

			DELETE Volume FROM tblPATCustomerVolume Volume
			INNER JOIN #tempCustomerVolume tempVolume
				ON tempVolume.intCustomerPatronId = Volume.intCustomerPatronId 
				AND tempVolume.intPatronageCategoryId = Volume.intPatronageCategoryId
				AND tempVolume.intFiscalYear = Volume.intFiscalYear

			MERGE 
			INTO [dbo].[tblPATCustomerVolume]
			WITH (HOLDLOCK)
			AS VolumeMaster
			USING #tempCustomerVolume tempVolume
				ON tempVolume.intCustomerPatronId = VolumeMaster.intCustomerPatronId 
				AND tempVolume.intPatronageCategoryId = VolumeMaster.intPatronageCategoryId
				AND tempVolume.intFiscalYear = VolumeMaster.intFiscalYear
			WHEN MATCHED THEN
				UPDATE SET
					VolumeMaster.dblVolumeProcessed = VolumeMaster.dblVolumeProcessed + tempVolume.dblVolume,
					VolumeMaster.dblVolume = VolumeMaster.dblVolumeProcessed + tempVolume.dblVolume
			WHEN NOT MATCHED THEN
				INSERT (
					intCustomerPatronId,
					intPatronageCategoryId,
					intFiscalYear,
					dblVolume,
					dblVolumeProcessed
				)
				VALUES(
					tempVolume.intCustomerPatronId,
					tempVolume.intPatronageCategoryId,
					tempVolume.intFiscalYear,
					tempVolume.dblVolume,
					tempVolume.dblVolumeProcessed
				)
			;
		END
	')
END
GO
PRINT N'*** END - Volume Constraint Fix for tblPATCustomerVolume ***'
GO