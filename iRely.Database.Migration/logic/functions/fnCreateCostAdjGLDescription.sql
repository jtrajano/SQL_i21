--liquibase formatted sql

-- changeset Von:fnCreateCostAdjGLDescription.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234


-- This function assembles the GL description related to the cost adjustment 
CREATE OR ALTER FUNCTION [dbo].[fnCreateCostAdjGLDescription](
	@strGLDescription AS NVARCHAR(255)
	,@strAccountDescription AS NVARCHAR(255)
	,@strItemNo AS NVARCHAR(50)
	,@strRelatedTransactionId AS NVARCHAR(50) 
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
			+ ISNULL(@strItemNo, '') 
			+ ' in ' 
			+ ISNULL(@strRelatedTransactionId, '') 
			+ ')'

	RETURN @strReturnValue; 
END



