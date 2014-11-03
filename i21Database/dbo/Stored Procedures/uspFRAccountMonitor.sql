CREATE PROCEDURE  [dbo].[uspFRAccountMonitor]
@intRowId			AS INT,
@successfulCount	AS INT = 0 OUTPUT
AS
BEGIN

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
	
	DECLARE @ConcurrencyId AS INT = (SELECT TOP 1 intConcurrencyId FROM tblFRRow WHERE intRowId = @intRowId)
	DECLARE @RowDetailId AS INT
	DECLARE @Filter AS NVARCHAR(MAX)
	
	DELETE tblFRAccountMonitor WHERE dtmEntered < DATEADD(day, -1, GETDATE());
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblFRAccountMonitor WHERE intRowId = @intRowId AND intConcurrencyId = @ConcurrencyId)
	BEGIN
		
		CREATE TABLE #TempRowDesign
		(
			 intRowDetailId		INT
			,strAccountsUsed	NVARCHAR(MAX)
		)	
		
		INSERT INTO #TempRowDesign 
			SELECT intRowDetailId, REPLACE(REPLACE(REPLACE(REPLACE(strAccountsUsed,'[ID]','[strAccountId]'),'[Description]','[strDescription]'),'[Group]','[strAccountGroup]'),'[Type]','[strAccountType]') FROM tblFRRowDesign WHERE intRowId = @intRowId and LEN(strAccountsUsed) > 1
			
		WHILE EXISTS(SELECT 1 FROM #TempRowDesign)
		BEGIN
			SELECT TOP 1 @RowDetailId = intRowDetailId, @Filter = strAccountsUsed FROM #TempRowDesign
			
			EXEC('INSERT INTO tblFRAccountMonitor (
				  [intRowId]
				 ,[intAccountId]
				 ,[strAccountId]
				 ,[strPrimary]
				 ,[strDescription]
				 ,[strAccountGroup]
				 ,[strAccountType]
				 ,[intConcurrencyId]
			)
			SELECT 
				 ' + @intRowId + '
				 ,[intAccountId]
				 ,[strAccountId]
				 ,[Primary Account]
				 ,[strDescription]
				 ,[strAccountGroup]
				 ,[strAccountType]
				 , ' + @ConcurrencyId + ' as intConcurrencyId
			FROM
				vyuGLAccountView
			WHERE ' + @Filter )
			
			DELETE #TempRowDesign WHERE intRowDetailId = @RowDetailId
		END		
	
	END
	
	SELECT @intRowId
	
END





--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------
--DECLARE @intCount AS INT

--EXEC [dbo].[uspFRAccountMonitor]
--			@intRowId	 = 15,						-- ROW Id			
--			@successfulCount = @intCount OUTPUT		-- OUTPUT PARAMETER THAT RETURNS ROW Id
				
--SELECT @intCount

