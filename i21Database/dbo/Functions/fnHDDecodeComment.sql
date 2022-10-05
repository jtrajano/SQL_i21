﻿CREATE FUNCTION [dbo].[fnHDDecodeComment](@strComment nvarchar(max))
RETURNS nvarchar(max)
AS
BEGIN

	DECLARE @decodedComment nvarchar(max)

	set @decodedComment = (
		CAST(
                CAST(N'' AS XML).value('xs:base64Binary(sql:variable("@strComment"))', 'VARBINARY(MAX)') 
            AS VARCHAR(MAX)
            )
	) COLLATE Latin1_General_CI_AS

	if (@decodedComment is null)
	begin
		set @decodedComment = (@strComment)
	end

	RETURN @decodedComment COLLATE Latin1_General_CI_AS

END

GO