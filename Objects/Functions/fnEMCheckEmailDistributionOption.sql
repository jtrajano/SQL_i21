CREATE FUNCTION [dbo].[fnEMCheckEmailDistributionOption]
(
	@intEntityId	INT,
	@strSearch		NVARCHAR(100)
)
RETURNS BIT
AS
BEGIN
	
	DECLARE @str nvarchar(max)
	DECLARE @Result BIT
	select @str = strEmailDistributionOption from tblEMEntity where intEntityId = @intEntityId

	IF @str is null or @str = '' RETURN 0
	if Exists (select top 1 1 from dbo.fnSplitStringWithTrim(@str, ',') where Item = @strSearch)
	BEGIN
		SET @Result = 1
	END
	ELSE
		SET @Result = 0
		
	RETURN @Result
END