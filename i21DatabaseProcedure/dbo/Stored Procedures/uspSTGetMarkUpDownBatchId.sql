CREATE PROCEDURE [dbo].[uspSTGetMarkUpDownBatchId]
@strBatchId NVARCHAR(100) OUTPUT
, @intLocationId INT
AS
BEGIN
		DECLARE @STARTING_NUMBER_BATCH AS INT = (SELECT intStartingNumberId FROM tblSMStartingNumber WHERE strModule = 'Store' AND strTransactionType = 'Mark Up/Down' AND strPrefix = 'MUD-')
		EXEC dbo.uspSMGetStartingNumber @STARTING_NUMBER_BATCH, @strBatchId OUTPUT, @intLocationId 
END