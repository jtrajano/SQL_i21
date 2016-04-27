/*
----------------------------------------------------------------------------------------------------------------------------------------------
IMPORTANT NOTES: 
----------------------------------------------------------------------------------------------------------------------------------------------

The msg_id for Cash Management should be in the range of 70,001 to 80,000. 
Please migrate all error messages from uspSMErrorMessage that is specific for CM into this stored procedure. 

Template: 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70001) EXEC sp_dropmessage 70001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 70001,11,@strmessage,'us_english','False'
*/

CREATE PROCEDURE uspCMErrorMessages
AS

DECLARE @strmessage AS NVARCHAR(MAX)
--70001 to 80000
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70001) EXEC sp_dropmessage 70001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 70001,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70002) EXEC sp_dropmessage 70002, 'us_english'	
SET @strmessage = 'Invalid G/L temporary table.'
EXEC sp_addmessage 70002,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70003) EXEC sp_dropmessage 70003, 'us_english'	
SET @strmessage = 'Debit and credit amounts are not balanced.'
EXEC sp_addmessage 70003,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70004) EXEC sp_dropmessage 70004, 'us_english'	
SET @strmessage = 'Cannot find the transaction.'
EXEC sp_addmessage 70004,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70005) EXEC sp_dropmessage 70005, 'us_english'	
SET @strmessage = 'Unable to find an open fiscal year period to match the transaction date.'
EXEC sp_addmessage 70005,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70006) EXEC sp_dropmessage 70006, 'us_english'	
SET @strmessage = 'The debit and credit amounts are not balanced.'
EXEC sp_addmessage 70006,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70007) EXEC sp_dropmessage 70007, 'us_english'	
SET @strmessage = 'The transaction is already posted.'
EXEC sp_addmessage 70007,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70008) EXEC sp_dropmessage 70008, 'us_english'	
SET @strmessage = 'The transaction is already unposted.'
EXEC sp_addmessage 70008,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70009) EXEC sp_dropmessage 70009, 'us_english'	
SET @strmessage = 'The transaction is already cleared.'
EXEC sp_addmessage 70009,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70010) EXEC sp_dropmessage 70010, 'us_english'	
SET @strmessage = 'The bank account or its associated GL account is inactive.'
EXEC sp_addmessage 70010,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70011) EXEC sp_dropmessage 70011, 'us_english'	
SET @strmessage = 'A failed check is misisng a reason.'
EXEC sp_addmessage 70011,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70012) EXEC sp_dropmessage 70012, 'us_english'	
SET @strmessage = 'Check is already voided.'
EXEC sp_addmessage 70012,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70013) EXEC sp_dropmessage 70013, 'us_english'	
SET @strmessage = 'You cannot %s transactions you did not create. Please contact your local administrator.'
EXEC sp_addmessage 70013,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70014) EXEC sp_dropmessage 70014, 'us_english'	
SET @strmessage = 'Not enough check numbers. Please generate new check numbers.'
EXEC sp_addmessage 70014,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70015) EXEC sp_dropmessage 70015, 'us_english'	
SET @strmessage = 'The transaction id %s already exists. Please ask your local administrator to check the starting numbers setup.'
EXEC sp_addmessage 70015,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70016) EXEC sp_dropmessage 70016, 'us_english'	
SET @strmessage = 'Unable to delete checkbook because it is used in the A/P Invoice file.'
EXEC sp_addmessage 70016,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70017) EXEC sp_dropmessage 70017, 'us_english'	
SET @strmessage = 'Unable to delete checkbook because it is used in the Check History file.'
EXEC sp_addmessage 70017,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70018) EXEC sp_dropmessage 70018, 'us_english'	
SET @strmessage = 'Unable to delete checkbook because it is used in the A/P Transaction file.'
EXEC sp_addmessage 70018,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70019) EXEC sp_dropmessage 70019, 'us_english'	
SET @strmessage = 'Duplicate checkbook id found.'
EXEC sp_addmessage 70019,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70020) EXEC sp_dropmessage 70020, 'us_english'	
SET @strmessage = 'Cannot post a zero-value transaction.'
EXEC sp_addmessage 70020,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70021) EXEC sp_dropmessage 70021, 'us_english'	
SET @strmessage = 'The record being created already exists in origin. Remove the duplicate record from origin or do a conversion.'
EXEC sp_addmessage 70021,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70022) EXEC sp_dropmessage 70022, 'us_english'	
SET @strmessage = 'There is an outdated Undeposited Fund record. It may have been deposited from a different deposit transaction.'
EXEC sp_addmessage 70022,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70023) EXEC sp_dropmessage 70023, 'us_english'	
SET @strmessage = 'The Undeposited Fund amount was changed. It does not match the values from the origin system.'
EXEC sp_addmessage 70023,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70024) EXEC sp_dropmessage 70024, 'us_english'	
SET @strmessage = 'Please re-process the Undeposited Funds. It looks like one or more records of it is already posted in %s.'
EXEC sp_addmessage 70024,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70025) EXEC sp_dropmessage 70025, 'us_english'	
SET @strmessage = 'Unable to void while check printing is in progress.'
EXEC sp_addmessage 70025,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70026) EXEC sp_dropmessage 70026, 'us_english'	
SET @strmessage = 'Unable to unpost while check printing is in progress.'
EXEC sp_addmessage 70026,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70027) EXEC sp_dropmessage 70027, 'us_english'	
SET @strmessage = 'Item id is invalid or missing.'
EXEC sp_addmessage 70027,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70028) EXEC sp_dropmessage 70028, 'us_english'	
SET @strmessage = 'Unable to unpost printed/commited transaction.'
EXEC sp_addmessage 70028,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70029) EXEC sp_dropmessage 70029, 'us_english'	
SET @strmessage = 'You cannot %s transaction under a closed module.'
EXEC sp_addmessage 70029,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 70030) EXEC sp_dropmessage 70030, 'us_english'	
SET @strmessage = 'Transfer %s transaction is already cleared.'
EXEC sp_addmessage 70030,11,@strmessage,'us_english','False'


