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
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90001) EXEC sp_dropmessage 90001, 'us_english'	
SET @strmessage = 'Machine: %s is used in the schedule for %s and %s.'
EXEC sp_addmessage 90001,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90002) EXEC sp_dropmessage 90002, 'us_english'	
SET @strmessage = 'Calendar name ''%s'' already exists.'
EXEC sp_addmessage 90002,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90003) EXEC sp_dropmessage 90003, 'us_english'	
SET @strmessage = 'Weight per unit does not match with the existing lot, cannot proceed.'
EXEC sp_addmessage 90003,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90004) EXEC sp_dropmessage 90004, 'us_english'	
SET @strmessage = 'The quantity you are trying to produce ( %s %s ) is less than the quantity allowed ( %s %s ) for the lot %s.'
EXEC sp_addmessage 90004,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90005) EXEC sp_dropmessage 90005, 'us_english'	
SET @strmessage = 'Owner is not configured for the item %s.'
EXEC sp_addmessage 90005,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90006) EXEC sp_dropmessage 90006, 'us_english'	
SET @strmessage = 'The UOM used in the work order %s is not added for the item %s in item maintenance.'
EXEC sp_addmessage 90006,11,@strmessage,'us_english','False'

