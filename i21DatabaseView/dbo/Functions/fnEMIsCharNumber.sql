CREATE FUNCTION [dbo].[fnEMIsCharNumber]
(
	@Character		NVARCHAR(1)
)
RETURNS BIT
AS
BEGIN
	if  @Character LIKE '%[0-9]%'
	BEGIN
		RETURN 1
	END
	
	RETURN 0

END