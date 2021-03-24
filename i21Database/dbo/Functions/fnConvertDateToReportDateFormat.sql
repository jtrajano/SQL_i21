CREATE FUNCTION [dbo].[fnConvertDateToReportDateFormat] (
	@Date DATETIME
	,@ysnIncludeTime BIT
	)
RETURNS NVARCHAR(30)
AS
BEGIN
	DECLARE @strFormat NVARCHAR(30)
	DECLARE @strFormatedDate NVARCHAR(30)
	DECLARE @strOnlyTime NVARCHAR(8)

	SELECT @strFormat = ISNULL(strReportDateFormat, 'MM/dd/yyyy')
	FROM tblSMCompanyPreference

	IF ISNULL(@ysnIncludeTime, 0) = 1
		AND @Date IS NOT NULL
	BEGIN
		SELECT @strOnlyTime = LEFT(CAST(@Date AS TIME), 8)
	END

	IF @strFormat = 'MM/dd/yy'
		SELECT @strFormatedDate = CONVERT(NVARCHAR, @Date, 1)
	ELSE IF @strFormat = 'MM/dd/yyyy'
		SELECT @strFormatedDate = CONVERT(NVARCHAR, @Date, 101)
	ELSE IF @strFormat = 'dd/MM/yyyy'
		SELECT @strFormatedDate = CONVERT(NVARCHAR, @Date, 103)
	ELSE IF @strFormat = 'yyyy/MM/dd'
		SELECT @strFormatedDate = CONVERT(NVARCHAR, @Date, 111)
	ELSE IF @strFormat = 'yy/MM/dd'
		SELECT @strFormatedDate = CONVERT(NVARCHAR, @Date, 11)
	ELSE IF @strFormat = 'M/d/yyyy'
		SELECT @strFormatedDate = LTRIM(DATEPART(mm, @Date)) + '/' + LTRIM(DATEPART(dd, @Date)) + '/' + LTRIM(DATEPART(yyyy, @Date))
	ELSE IF @strFormat = 'M/d/yy'
		SELECT @strFormatedDate = LTRIM(DATEPART(mm, @Date)) + '/' + LTRIM(DATEPART(dd, @Date)) + '/' + RIGHT(LTRIM(DATEPART(yyyy, @Date)), 2)

	IF ISNULL(@strOnlyTime, '') <> ''
		SELECT @strFormatedDate = @strFormatedDate + ' ' + @strOnlyTime

	RETURN ISNULL(@strFormatedDate, '');
END
