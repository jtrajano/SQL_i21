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