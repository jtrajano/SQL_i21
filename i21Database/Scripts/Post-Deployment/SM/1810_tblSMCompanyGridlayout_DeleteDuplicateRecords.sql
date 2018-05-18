GO
	PRINT N'START DELETE DUPLICATE tblSMCompanyGridLayout RECORDS'

	IF OBJECT_ID('tempdb..#TempSMCompanyGridLayout') IS NOT NULL
		DROP TABLE #TempSMCompanyGridLayout

	

	Create TABLE #TempSMCompanyGridLayout
	(
		[intCompanyGridLayoutId]		INT													NOT NULL,
		[strScreen]						[nvarchar](100)	COLLATE Latin1_General_CI_AS		NULL,
		[strGrid]						[nvarchar](100)	COLLATE Latin1_General_CI_AS		NULL,
	)

	
	INSERT INTO #TempSMCompanyGridLayout(intCompanyGridLayoutId, strScreen, strGrid)
	SELECT distinct intCompanyGridLayoutId, strScreen, strGrid
	FROM tblSMCompanyGridLayout
	

	DECLARE gridLayout_cursor CURSOR FOR
	SELECT intCompanyGridLayoutId, strScreen, strGrid
	FROM #TempSMCompanyGridLayout

	DECLARE @intCompanyGridLayoutId INT
	DECLARE @strScreen nvarchar(100)
	DECLARE @strGrid nvarchar(100)

	DECLARE @recordCount INT = 0

	OPEN gridLayout_cursor
	FETCH NEXT FROM gridLayout_cursor into @intCompanyGridLayoutId, @strScreen, @strGrid
	WHILE @@FETCH_STATUS = 0
	BEGIN

		SELECT @recordCount = count(*) from tblSMCompanyGridLayout
		where strScreen = @strScreen and strGrid = @strGrid

		IF @recordCount > 1
		BEGIN
			DELETE FROM tblSMCompanyGridLayout
			WHERE strScreen = @strScreen and  strGrid = @strGrid and strGrid <> 'grdSearch' and intCompanyGridLayoutId <> @intCompanyGridLayoutId
		END
		
	FETCH NEXT FROM gridLayout_cursor into @intCompanyGridLayoutId, @strScreen, @strGrid
	END

	CLOSE gridLayout_cursor
	DEALLOCATE gridLayout_cursor


	PRINT N'END DELETE DUPLICATE tblSMCompanyGridLayout RECORDS'

GO