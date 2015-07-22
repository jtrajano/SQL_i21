CREATE PROCEDURE [dbo].[uspGLImportOriginHistoricalJournalCLOSED]
	@intEntityId INT,
	@result NVARCHAR(MAX) = '' OUTPUT
AS
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[glarcmst]') AND type IN (N'U'))
	RETURN 0