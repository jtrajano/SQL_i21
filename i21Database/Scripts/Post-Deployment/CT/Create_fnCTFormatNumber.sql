GO

if exists (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[fnCTFormatNumber]') AND type IN ( N'FN', N'IF', N'TF', N'FS', N'FT' ))
begin
	drop function fnCTFormatNumber;
end

GO
if (convert(int,convert(nvarchar(2),SERVERPROPERTY('productversion'))) > 10)
begin
	exec('
	CREATE FUNCTION [dbo].[fnCTFormatNumber]
	(
		@dblNumber numeric(18,6)
		,@strNumberFormat nvarchar(50)
	)
	RETURNS NVARCHAR(MAX)
	AS 
	BEGIN 
		return format(@dblNumber,@strNumberFormat);
	END
	');
end
else
begin
	exec('
	CREATE FUNCTION [dbo].[fnCTFormatNumber]
	(
		@dblNumber numeric(18,6)
		,@strNumberFormat nvarchar(50)
	)
	RETURNS NVARCHAR(MAX)
	AS 
	BEGIN 
		return convert(nvarchar(50),cast(@dblNumber as money),1);
	END');
end
GO