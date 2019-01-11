CREATE FUNCTION [dbo].[fnRKFormatDate]
(
	 @dtmDate		DATETIME
	 ,@strFormat NVARCHAR(30)
)
RETURNS NVARCHAR(30)
AS
BEGIN
	DECLARE @strFormatedDate NVARCHAR(30)

	IF @strFormat = 'MMM yyyy'
		SELECT @strFormatedDate = LEFT(DATENAME(MONTH, @dtmDate), 3) + ' ' + DATENAME(YEAR, @dtmDate)

	ELSE IF @strFormat = 'MMM yy'
		SELECT @strFormatedDate = LEFT(DATENAME(MONTH, @dtmDate), 3) + ' ' + RIGHT(DATENAME(YEAR, @dtmDate),2)

	IF @strFormat = 'MM/dd/yy'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@dtmDate,1)

	ELSE IF @strFormat = 'MM/dd/yyyy'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@dtmDate,101)
	
	ELSE IF @strFormat = 'dd/MM/yyyy'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@dtmDate,103)
	
	ELSE IF @strFormat = 'yyyy/MM/dd'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@dtmDate,111)
	
	ELSE IF @strFormat = 'yy/MM/dd'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@dtmDate,11)
	
	ELSE IF @strFormat = 'M/d/yyyy'
		SELECT @strFormatedDate = LTRIM(DATEPART(mm,@dtmDate)) + '/' + LTRIM(DATEPART(dd,@dtmDate)) + '/' + LTRIM(DATEPART(yyyy,@dtmDate))
	
	ELSE IF @strFormat = 'M/d/yy'
		SELECT @strFormatedDate = LTRIM(DATEPART(mm,@dtmDate)) + '/' + LTRIM(DATEPART(dd,@dtmDate)) + '/' + RIGHT(LTRIM(DATEPART(yyyy,@dtmDate)),2)

	RETURN ISNULL(@strFormatedDate, '') COLLATE Latin1_General_CI_AS;
END
