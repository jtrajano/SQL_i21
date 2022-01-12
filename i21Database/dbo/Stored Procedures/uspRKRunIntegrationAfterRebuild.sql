CREATE PROCEDURE [dbo].[uspRKRunIntegrationAfterRebuild]
	
AS

BEGIN

	--------------------------------------------------
	-- Run Contract Balance Log fixes after rebuild --
	--------------------------------------------------
	EXEC uspCTFixCBLogAfterRebuild



END