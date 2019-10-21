CREATE FUNCTION [dbo].[fnCTGetReportLanguage]
(
	@id int
)
RETURNS NVARCHAR(20)
AS
BEGIN

	DECLARE @language NVARCHAR(20)
	SELECT @language = strLanguage
	FROM tblSMLanguage
	WHERE intLanguageId = @id
	
	RETURN @language

END
