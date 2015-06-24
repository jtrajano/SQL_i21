CREATE PROCEDURE [testi21Database].[test uspICPostInventoryAdjustment for supplying the GL Description]
AS
BEGIN
	-- Arrange 
	BEGIN 
		DECLARE @ysnPost AS BIT = 1
		DECLARE @ysnRecap AS BIT = 0
		DECLARE @strTransactionId AS NVARCHAR(40) = 'ADJ-3'
		DECLARE @intUserId AS INT = 1
		DECLARE @intEntityId AS INT = 1
		DECLARE @strGLDescription AS NVARCHAR(255) 

		EXEC [testi21Database].[Fake data for inventory adjustment table];
	END 

	-- Act
	BEGIN 
		EXEC dbo.uspICPostInventoryAdjustment 
			@ysnPost
			,@ysnRecap
			,@strTransactionId
			,@intUserId
			,@intEntityId
	END 

	-- Assert
	BEGIN 		
		-- Check the number of descriptions used in the GL Detail. There should be only one description. 
		DECLARE @DescriptionCount AS INT 
		SELECT @DescriptionCount = COUNT(ActualDescription.strDescription)
		FROM	
		(
			SELECT	DISTINCT 
					strDescription
			FROM	tblGLDetail
			WHERE	strTransactionId = @strTransactionId
		) ActualDescription		
		EXEC tSQLt.AssertEquals 1, @DescriptionCount
		
		-- Check the value of the description. It should yield the expected value. 
		SELECT	DISTINCT 
				@strGLDescription = strDescription
		FROM	tblGLDetail
		WHERE	strTransactionId = @strTransactionId

		EXEC tSQLt.AssertEquals 'With a lot item in the detail that is purely in 25 kg bags, no weight UOM.', @strGLDescription
	END 
END 