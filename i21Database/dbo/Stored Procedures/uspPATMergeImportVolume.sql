CREATE PROCEDURE [dbo].[uspPATMergeImportVolume]
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


DECLARE @error NVARCHAR(MAX);

BEGIN TRY

MERGE
INTO [dbo].[tblPATCustomerVolume] 
WITH (HOLDLOCK)
AS VolumeMaster
USING (
	SELECT	intCustomerPatronId,
			intPatronageCategoryId,
			intFiscalYear,
			SUM(dblVolume) AS dblVolumeTotal
	FROM tblPATCustomerVolumeStaging
	GROUP BY	intCustomerPatronId,
				intPatronageCategoryId,
				intFiscalYear
) AS VolumeStaging
ON VolumeMaster.intCustomerPatronId = VolumeStaging.intCustomerPatronId
AND VolumeMaster.intPatronageCategoryId = VolumeStaging.intPatronageCategoryId
AND VolumeMaster.intFiscalYear = VolumeStaging.intFiscalYear
WHEN MATCHED THEN
	UPDATE 
	SET VolumeMaster.dblVolume = VolumeMaster.dblVolume + VolumeStaging.dblVolumeTotal
WHEN NOT MATCHED THEN
	INSERT (
		[intCustomerPatronId],
		[intPatronageCategoryId],
		[intFiscalYear],
		[dblVolume],
		[intConcurrencyId]
	)
	VALUES(
		VolumeStaging.intCustomerPatronId,
		VolumeStaging.intPatronageCategoryId,
		VolumeStaging.intFiscalYear,
		VolumeStaging.dblVolumeTotal,
		1
	)
;
END TRY

BEGIN CATCH
	SET @error = ERROR_MESSAGE();
	RAISERROR(@error, 16, 1);
END CATCH

TRUNCATE TABLE [dbo].[tblPATCustomerVolumeStaging];

END