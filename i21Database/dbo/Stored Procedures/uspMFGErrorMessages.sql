﻿/*
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

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90007) EXEC sp_dropmessage 90007, 'us_english'	
SET @strmessage = 'Default warehouse staging unit is not configured.'
EXEC sp_addmessage 90007,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90008) EXEC sp_dropmessage 90008, 'us_english'	
SET @strmessage = 'This lot is being managed in warehouse. All transactions should be done in warehouse module. You can only change the lot status from inventory view.'
EXEC sp_addmessage 90008,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90009) EXEC sp_dropmessage 90009, 'us_english'	
SET @strmessage = 'Lots with different unit of measure cannot be merged.'
EXEC sp_addmessage 90009,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90010) EXEC sp_dropmessage 90010, 'us_english'	
SET @strmessage = 'Source storage location and destination storage location cannot be same.'
EXEC sp_addmessage 90010,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90011) EXEC sp_dropmessage 90011, 'us_english'	
SET @strmessage = 'Dragging this order from the current location will result in contamination between two adjacent orders %s, %s in this line: %s'
EXEC sp_addmessage 90011,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90012) EXEC sp_dropmessage 90012, 'us_english'	
SET @strmessage = 'Dropping this order on the target location will result in contamination of either of the adjacent orders %s, %s of the line: %s'
EXEC sp_addmessage 90012,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90013) EXEC sp_dropmessage 90013, 'us_english'	
SET @strmessage = 'This product is not configured for processing on this line: %s'
EXEC sp_addmessage 90013,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90014) EXEC sp_dropmessage 90014, 'us_english'	
SET @strmessage = 'Frozen/Released/started wokorder cannot be moved.'
EXEC sp_addmessage 90014,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90015) EXEC sp_dropmessage 90015, 'us_english'	
SET @strmessage = 'Move qty cannot be greater than available qty.'
EXEC sp_addmessage 90015,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 90016) EXEC sp_dropmessage 90016, 'us_english'	
SET @strmessage = 'Source Lot''s UOM %s is not configured as one of the UOM in destination item %s.'
EXEC sp_addmessage 90016,11,@strmessage,'us_english','False'