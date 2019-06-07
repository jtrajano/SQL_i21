CREATE FUNCTION [dbo].[fnCTRemoveStringXMLTag]
(
	@XML			NVARCHAR(MAX),
	@tagToRemove	NVARCHAR(MAX)
)
RETURNS NVARCHAR(MAX)
AS
BEGIN
	DECLARE @EndTag NVARCHAR(MAX)
	SELECT  @tagToRemove	=	'<' + @tagToRemove + '>'
	SELECT	@EndTag			=	REPLACE(@tagToRemove,'<','</')
	SELECT  @tagToRemove	=	SUBSTRING(@XML,PATINDEX('%'+@tagToRemove+'%',@XML),PATINDEX('%'+@EndTag+'%',@XML) - PATINDEX('%'+@tagToRemove+'%',@XML)+LEN(@EndTag))
	RETURN	REPLACE(@XML,@tagToRemove,'')
END