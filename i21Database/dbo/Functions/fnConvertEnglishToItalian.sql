CREATE FUNCTION [dbo].[fnConvertEnglishToItalian]
(
	@strEnglish NVARCHAR(MAX)
	
)
RETURNS NVARCHAR(400)
AS
BEGIN 
	DECLARE @strItalian NVARCHAR(MAX)

	SELECT @strItalian = strCustomLabel 
	FROM tblSMReportLabelDetail
	WHERE strLabelName = @strEnglish

	RETURN @strItalian
END
