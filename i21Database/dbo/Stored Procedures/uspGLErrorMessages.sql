/*
----------------------------------------------------------------------------------------------------------------------------------------------
IMPORTANT NOTES: 
----------------------------------------------------------------------------------------------------------------------------------------------

The msg_id for Cash Management should be in the range of 60,001 to 70,000. 
Please migrate all error messages from uspSMErrorMessage that is specific for CM into this stored procedure. 

Template: 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 60001) EXEC sp_dropmessage 60001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 60001,11,@strmessage,'us_english','False'
*/

CREATE PROCEDURE uspGLErrorMessages
AS

DECLARE @strmessage AS NVARCHAR(MAX)