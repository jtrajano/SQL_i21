GO
	PRINT N'Begin update tblSMGridLayout for time entry.';
GO
	IF OBJECT_ID('tempdb..#TempHDGridLayout') IS NOT NULL
		DROP TABLE #TempHDGridLayout

	Create TABLE #TempHDGridLayout
	(
		intGridLayoutId				INT				NOT NULL,
		strGridLayoutFields			nvarchar(max)
	)

	INSERT INTO #TempHDGridLayout(intGridLayoutId, strGridLayoutFields)
	SELECT intGridLayoutId, strGridLayoutFields
	FROM tblSMGridLayout
	WHERE strScreen = 'HelpDesk.view.TimeEntry' and strGrid = 'grdTimeEntry'

	DECLARE layout_cursor CURSOR FOR
	SELECT intGridLayoutId, strGridLayoutFields
	FROM #TempHDGridLayout

	DECLARE @intGridLayoutId int
	DECLARE @strGridLayoutFields nvarchar(max)

	OPEN layout_cursor
	FETCH NEXT FROM layout_cursor into @intGridLayoutId, @strGridLayoutFields
	WHILE @@FETCH_STATUS = 0
	BEGIN
		if ISNULL(@intGridLayoutId, 0) <> 0
		BEGIN
			if charindex('"intIndex":16,', @strGridLayoutFields) = 0
			begin
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":15,', '"intIndex":16,')  where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":14,', '"intIndex":15,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":13,', '"intIndex":14,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":12,', '"intIndex":13,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":11,', '"intIndex":12,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":10,', '"intIndex":11,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":9,', '"intIndex":10,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":8,', '"intIndex":9,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":7,', '"intIndex":8,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":6,', '"intIndex":7,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":5,', '"intIndex":6,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":4,', '"intIndex":5,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":3,', '"intIndex":4,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":2,', '"intIndex":3,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":1,', '"intIndex":2,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":0,', '"intIndex":1,') where intGridLayoutId = @intGridLayoutId
			end
		END

		

		FETCH NEXT FROM layout_cursor into @intGridLayoutId, @strGridLayoutFields
	END

	CLOSE layout_cursor
	DEALLOCATE layout_cursor
GO
	PRINT N'End update tblSMGridLayout for time entry';
GO