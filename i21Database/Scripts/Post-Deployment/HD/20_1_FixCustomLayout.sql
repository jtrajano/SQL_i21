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


GO
	PRINT N'Begin update tblSMGridLayout for Rough Cut Capacities.';
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
	WHERE strScreen = 'HelpDesk.view.RoughCutCapacityReport:RoughCutCapacityReport' and strGrid = 'grdSearch'

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
			if charindex('"intIndex":44,', @strGridLayoutFields) = 0
			begin
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":43,', '"intIndex":44,')  where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":42,', '"intIndex":43,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":41,', '"intIndex":42,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":40,', '"intIndex":41,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":39,', '"intIndex":40,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":38,', '"intIndex":39,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":37,', '"intIndex":38,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":36,', '"intIndex":37,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":35,', '"intIndex":36,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":34,', '"intIndex":35,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":33,', '"intIndex":34,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":32,', '"intIndex":33,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":31,', '"intIndex":32,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":30,', '"intIndex":31,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":29,', '"intIndex":30,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":28,', '"intIndex":29,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":27,', '"intIndex":28,')  where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":26,', '"intIndex":27,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":25,', '"intIndex":26,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":24,', '"intIndex":25,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":23,', '"intIndex":24,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":22,', '"intIndex":23,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":21,', '"intIndex":22,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":20,', '"intIndex":21,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":19,', '"intIndex":20,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":18,', '"intIndex":19,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":17,', '"intIndex":18,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":16,', '"intIndex":17,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":15,', '"intIndex":16,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":14,', '"intIndex":15,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":13,', '"intIndex":14,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":12,', '"intIndex":13,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":11,', '"intIndex":12,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":10,', '"intIndex":11,')  where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":9,', '"intIndex":10,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":8,', '"intIndex":9,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":7,', '"intIndex":8,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":6,', '"intIndex":7,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":5,', '"intIndex":6,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":4,', '"intIndex":5,') where intGridLayoutId = @intGridLayoutId
				update tblSMGridLayout set strGridLayoutFields = replace(strGridLayoutFields, '"intIndex":3,', '"intIndex":4,') where intGridLayoutId = @intGridLayoutId
			end
		END

		

		FETCH NEXT FROM layout_cursor into @intGridLayoutId, @strGridLayoutFields
	END

	CLOSE layout_cursor
	DEALLOCATE layout_cursor
GO
	PRINT N'End update tblSMGridLayout for Rough Cut Capacities';
GO