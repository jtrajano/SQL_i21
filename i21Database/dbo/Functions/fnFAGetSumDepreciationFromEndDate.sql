CREATE FUNCTION [dbo].[fnFAGetSumDepreciationFromEndDate]
(
	@intAssetId INT,
	@intBookId INT = 1,
	@dtmEndDate DATETIME = NULL,
	@ysnCurrentMonthDepreciation BIT = 0 -- IF 1, DATE RANGE WILL BE FROM THE FIRST DAY OF THE END DATE'S YEAR UP TO THE LAST DAY OF THE MONTH OF END DATE
										 -- IF 0, DATE RANGE WILL BE FROM FIRST TO LAST DAY OF THE MONTH OF THE END DATE FALLS INTO
)
RETURNS DECIMAL (18, 6) 
AS
BEGIN
DECLARE
	@tblDepreciations table (
		intRowId INT,
		intAssetId INT,
		intBookId INT NULL,
		dtmDepreciationToDate DATETIME NULL,
		dblDepreciationToDate DECIMAL(18, 6) NULL,
		strTransaction NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
		dblDepreciation DECIMAL NULL,
		ysnProcessed BIT NULL DEFAULT(0)
	)
DECLARE
	@dblNewDepreciation DECIMAL(18, 6),
	@dblCurrentDepreciation DECIMAL (18, 6),
	@dblDepreciationTotal DECIMAL (18, 6),
	@dblDepreciationSumResult DECIMAL (18, 6),
	@intCurrentRowId INT

INSERT INTO @tblDepreciations
	SELECT ROW_NUMBER() OVER(ORDER BY dtmDepreciationToDate), intAssetId, intBookId, dtmDepreciationToDate, dblDepreciationToDate, strTransaction, NULL, 0 
	FROM tblFAFixedAssetDepreciation
	WHERE strTransaction = 'Depreciation' AND intBookId = @intBookId AND intAssetId = @intAssetId
WHILE EXISTS(SELECT TOP 1 1 FROM @tblDepreciations WHERE ysnProcessed = 0)
BEGIN
	SELECT TOP 1 @intCurrentRowId = intRowId, @dblNewDepreciation = dblDepreciationToDate FROM @tblDepreciations WHERE ysnProcessed = 0 ORDER BY dtmDepreciationToDate
	
	IF (@intCurrentRowId = 1)
		SET @dblCurrentDepreciation = @dblNewDepreciation
	ELSE
	BEGIN
		SELECT @dblDepreciationTotal = SUM(ISNULL(dblDepreciation, 0)) FROM @tblDepreciations WHERE ysnProcessed = 1;
		SET @dblCurrentDepreciation = @dblNewDepreciation - @dblDepreciationTotal
	END
	UPDATE @tblDepreciations 
	SET 
		dblDepreciation = @dblCurrentDepreciation,
		ysnProcessed = 1
	WHERE intRowId = @intCurrentRowId
END

IF (@dtmEndDate IS NULL)
BEGIN
	IF (@ysnCurrentMonthDepreciation = 0)
		SELECT @dblDepreciationSumResult = SUM(ISNULL(dblDepreciation, 0)) FROM @tblDepreciations WHERE dtmDepreciationToDate BETWEEN DATEADD(mm, DATEDIFF(mm, 0, GETDATE()), 0) AND DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0))
	ELSE
		SELECT @dblDepreciationSumResult = SUM(ISNULL(dblDepreciation, 0)) FROM @tblDepreciations WHERE dtmDepreciationToDate BETWEEN DATEFROMPARTS(YEAR(GETDATE()), 1, 1)  AND DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, GETDATE()) + 1, 0))
END
ELSE
	IF (@ysnCurrentMonthDepreciation = 0)
		SELECT @dblDepreciationSumResult = SUM(ISNULL(dblDepreciation, 0)) from @tblDepreciations WHERE dtmDepreciationToDate BETWEEN DATEADD(mm, DATEDIFF(mm, 0, @dtmEndDate), 0) AND DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @dtmEndDate) + 1, 0))
	ELSE
		SELECT @dblDepreciationSumResult = SUM(ISNULL(dblDepreciation, 0)) from @tblDepreciations WHERE dtmDepreciationToDate BETWEEN DATEFROMPARTS(YEAR(@dtmEndDate), 1, 1) AND DATEADD (dd, -1, DATEADD(mm, DATEDIFF(mm, 0, @dtmEndDate) + 1, 0))

RETURN @dblDepreciationSumResult
END
