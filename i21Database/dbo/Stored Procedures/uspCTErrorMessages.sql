CREATE PROCEDURE [dbo].[uspCTErrorMessages]
AS

	DECLARE @strmessage AS NVARCHAR(MAX)
	IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 110001) EXEC sp_dropmessage 110001, 'us_english'	
	SET @strmessage = 'Available quantity for the contract %s and sequence %s is %s, which is insufficient to Save/Post a quantity of %s therefore could not Save/Post this transaction.'
	EXEC sp_addmessage 110001,16,@strmessage,'us_english','False'
