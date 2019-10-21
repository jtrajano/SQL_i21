CREATE FUNCTION [dbo].[fnGRConvertDateToReportDateFormat]
(
	 @Date		DATETIME
)
RETURNS NVARCHAR(30)
AS
BEGIN
	
	DECLARE @strFormat NVARCHAR(30)
	DECLARE @strFormatedDate NVARCHAR(30)
	
	SELECT @strFormat = ISNULL(strReportDateFormat,'MM/dd/yyyy') FROM tblSMCompanyPreference

	IF @strFormat = 'MM/dd/yy'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@Date,1)

	ELSE IF @strFormat = 'MM/dd/yyyy'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@Date,101)
	
	ELSE IF @strFormat = 'dd/MM/yyyy'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@Date,103)
	
	ELSE IF @strFormat = 'yyyy/MM/dd'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@Date,111)
	
	ELSE IF @strFormat = 'yy/MM/dd'
		SELECT @strFormatedDate = CONVERT(Nvarchar,@Date,11)
	
	ELSE IF @strFormat = 'M/d/yyyy'
		SELECT @strFormatedDate = LTRIM(DATEPART(mm,@Date)) + '/' + LTRIM(DATEPART(dd,@Date)) + '/' + LTRIM(DATEPART(yyyy,@Date))
	
	ELSE IF @strFormat = 'M/d/yy'
		SELECT @strFormatedDate = LTRIM(DATEPART(mm,@Date)) + '/' + LTRIM(DATEPART(dd,@Date)) + '/' + RIGHT(LTRIM(DATEPART(yyyy,@Date)),2)

	RETURN ISNULL(@strFormatedDate, '');
END
