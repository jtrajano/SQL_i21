CREATE FUNCTION [dbo].[fnEMIsPhoneDelimeter]
(
	@Character		NVARCHAR(1)
)
RETURNS BIT
AS
BEGIN
	IF 
		@Character = ' ' OR 
		@Character = 'x' OR
		@Character = '.' OR
		@Character = '-' OR
		@Character = ')'
	BEGIN
		RETURN 1
	END

	RETURN 0;

END