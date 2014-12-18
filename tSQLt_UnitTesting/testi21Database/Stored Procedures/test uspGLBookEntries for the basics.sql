CREATE PROCEDURE [testi21Database].[test uspGLBookEntries for the basics]
AS
BEGIN
	-- Arrange 
	BEGIN 
		-- Fake these tables
		EXEC tSQLt.FakeTable 'dbo.tblGLDetail';
		EXEC tSQLt.FakeTable 'dbo.tblGLSummary';

		-- Add the expected tables 
		SELECT *
		INTO expected_tblGLDetail 
		FROM dbo.tblGLDetail

		SELECT *
		INTO expected_tblGLSummary
		FROM dbo.tblGLSummary

		DECLARE @GLEntries AS RecapTableType
		DECLARE @ysnPost AS BIT 
	END 
	
	-- Act
	BEGIN 
		EXEC dbo.uspGLBookEntries 
			@GLEntries
			,@ysnPost
	END 

	-- Assert
	BEGIN 
		EXEC tSQLt.AssertEqualsTable 'expected_tblGLDetail', 'tblGLDetail';
		EXEC tSQLt.AssertEqualsTable 'expected_tblGLSummary', 'tblGLSummary';
	END

	-- Clean-up: remove the tables used in the unit test
	IF OBJECT_ID('expected_tblGLDetail') IS NOT NULL 
		DROP TABLE expected_tblGLDetail

	IF OBJECT_ID('expected_tblGLSummary') IS NOT NULL 
		DROP TABLE dbo.expected_tblGLSummary
END