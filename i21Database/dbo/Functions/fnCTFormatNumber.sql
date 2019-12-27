	CREATE FUNCTION [dbo].[fnCTFormatNumber]
	(
		@dblNumber numeric(18,6)
		,@strNumberFormat nvarchar(50)
	)
	RETURNS NVARCHAR(MAX)
	AS 
	BEGIN 
		return convert(nvarchar(50),cast(@dblNumber as money),1);
	END