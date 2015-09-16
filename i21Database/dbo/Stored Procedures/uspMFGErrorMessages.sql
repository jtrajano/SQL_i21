/*
----------------------------------------------------------------------------------------------------------------------------------------------
IMPORTANT NOTES: 
----------------------------------------------------------------------------------------------------------------------------------------------

The msg_id for Manufacturing should be in the range of 90,001 to 100,000. 
Please migrate all error messages from uspSMErrorMessage that is specific for MFG into this stored procedure. 

Template: 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90001) EXEC sp_dropmessage 90001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 90001,11,@strmessage,'us_english','False'
*/

CREATE PROCEDURE uspMFGErrorMessages
AS

DECLARE @strmessage AS NVARCHAR(MAX)