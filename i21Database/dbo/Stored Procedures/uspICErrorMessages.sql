/*
----------------------------------------------------------------------------------------------------------------------------------------------
IMPORTANT NOTES: 
----------------------------------------------------------------------------------------------------------------------------------------------

The msg_id for Inventory should be in the range of 80,001 to 90,000. 
Please migrate all error messages from uspSMErrorMessage that is specific for IC into this stored procedure. 

Template: 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80001) EXEC sp_dropmessage 80001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 80001,11,@strmessage,'us_english','False'
*/

CREATE PROCEDURE uspICErrorMessages
AS

DECLARE @strmessage AS NVARCHAR(MAX)