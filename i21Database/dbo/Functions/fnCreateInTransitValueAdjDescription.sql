
-- This function assembles the GL description related to the cost adjustment 
CREATE FUNCTION [dbo].[fnCreateInTransitValueAdjDescription](
	@strGLDescription AS NVARCHAR(255)
	,@strAccountDescription AS NVARCHAR(255)
	,@strOtherCharge AS NVARCHAR(50)
	,@strItemNo AS NVARCHAR(50) 
	,@ysnReversal AS BIT = 0 
)
RETURNS NVARCHAR(255)
AS
BEGIN 
	DECLARE @strReturnValue AS NVARCHAR(255)

	SET @strReturnValue = ISNULL(@strGLDescription, @strAccountDescription)
	
	-- Output: 
	-- {GL Description|GL Account Description} ({Item No} in {Transaction Id})
	SET @strReturnValue = 
			ISNULL(@strReturnValue, '') 
			+ CASE WHEN LEN(@strReturnValue) > 0 THEN ' ' ELSE '' END 
			+ '(' 
			+ CASE WHEN @ysnReversal = 1 THEN 'Reversal on ' ELSE '' END
			+ ISNULL(@strOtherCharge, '') 
			+ ' for ' 
			+ ISNULL(@strItemNo, '') 
			+ ')'

	RETURN @strReturnValue; 
END 