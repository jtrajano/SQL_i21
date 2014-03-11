
GO
	PRINT N'BEGIN DROP Cash Management Triggers'
GO
	IF OBJECT_ID('trg_delete_apchkmst', 'TR') IS NOT NULL
		DROP TRIGGER trg_delete_apchkmst;
GO
	PRINT N'END DROP Cash Management Triggers'
GO