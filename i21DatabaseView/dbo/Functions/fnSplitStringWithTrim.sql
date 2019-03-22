CREATE FUNCTION [dbo].[fnSplitStringWithTrim]
(
	@Input NVARCHAR(MAX),
    @Character CHAR(1)
)
RETURNS @Output TABLE
(
	Item NVARCHAR(1000)
)
AS
BEGIN
	insert into @Output 
	SELECT Item FROM dbo.fnSplitString(@Input, @Character)
	UPDATE @Output set Item = LTRIM(RTRIM(Item))
    RETURN
END
GO