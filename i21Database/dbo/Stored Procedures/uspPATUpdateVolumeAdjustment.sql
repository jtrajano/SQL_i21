CREATE PROCEDURE [dbo].[uspPATUpdateVolumeAdjustment] 
	@intCustomerId INT = NULL,
	@intAdjustmentId INT = NULL
AS
BEGIN
	
	IF(@intCustomerId IS NULL AND @intAdjustmentId IS NULL)
	BEGIN
		RETURN;
	END

	DECLARE @intFiscalYear INT, @intPatronageCategoryId INT

	SET @intFiscalYear = (SELECT intFiscalYearId 
	FROM tblGLFiscalYear
	WHERE
	(
		SELECT dtmAdjustmentDate 
		FROM tblPATAdjustVolume
		WHERE intCustomerId = @intCustomerId
		AND intAdjustmentId = @intAdjustmentId
	)
	BETWEEN dtmDateFrom AND dtmDateTo)

	SET @intPatronageCategoryId = (SELECT AVD.intPatronageCategoryId
	FROM tblPATAdjustVolume AV
	INNER JOIN tblPATAdjustVolumeDetails AVD
	ON AV.intAdjustmentId = AVD.intAdjustmentId
	WHERE AV.intCustomerId = @intCustomerId
	AND AV.intAdjustmentId = @intAdjustmentId)

	IF (@intPatronageCategoryId = 0)
	BEGIN
		RETURN;
	END

	SELECT AV.intCustomerId, 
	AVD.intPatronageCategoryId, 
	AVD.dblQuantityAdjusted,
	@intFiscalYear as fiscalYear
	INTO #tempItem
	FROM tblPATAdjustVolume AV
	INNER JOIN tblPATAdjustVolumeDetails AVD
	ON AV.intAdjustmentId = AVD.intAdjustmentId
	WHERE AV.intCustomerId = @intCustomerId
	AND AV.intAdjustmentId = @intAdjustmentId

	IF NOT EXISTS(SELECT * FROM #tempItem)
	BEGIN

		DROP TABLE #tempItem
		RETURN;
	END
	ELSE
	BEGIN

		--select * from #tempItem
		MERGE tblPATCustomerVolume AS PAT
		USING #tempItem AS B
			ON (PAT.intCustomerPatronId = B.intCustomerId AND PAT.intPatronageCategoryId = B.intPatronageCategoryId AND PAT.intFiscalYear = B.fiscalYear)
			WHEN MATCHED
				THEN UPDATE SET PAT.dblVolume = PAT.dblVolume + B.dblQuantityAdjusted
			WHEN NOT MATCHED BY TARGET
				THEN INSERT (intCustomerPatronId, intPatronageCategoryId, intFiscalYear, dtmLastActivityDate, dblVolume, intConcurrencyId)
					VALUES (B.intCustomerId, B.intPatronageCategoryId, @intFiscalYear, GETDATE(),  B.dblQuantityAdjusted, 1);

		DROP TABLE #tempItem
	END
END

GO