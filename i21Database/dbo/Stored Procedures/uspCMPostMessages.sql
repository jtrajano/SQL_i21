
CREATE PROCEDURE uspCMPostMessages
AS

DECLARE @strmessage AS NVARCHAR(MAX)

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50001) EXEC sp_dropmessage 50001, 'us_english'	
SET @strmessage = 'Invalid G/L account id found.'
EXEC sp_addmessage 50001,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50002) EXEC sp_dropmessage 50002, 'us_english'	
SET @strmessage = 'Invalid G/L temporary table.'
EXEC sp_addmessage 50002,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50003) EXEC sp_dropmessage 50003, 'us_english'	
SET @strmessage = 'Debit and credit amounts are not balanced.'
EXEC sp_addmessage 50003,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50004) EXEC sp_dropmessage 50004, 'us_english'	
SET @strmessage = 'Cannot find the transaction.'
EXEC sp_addmessage 50004,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50005) EXEC sp_dropmessage 50005, 'us_english'	
SET @strmessage = 'Unable to find an open fiscal year period to match the transaction date.'
EXEC sp_addmessage 50005,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50006) EXEC sp_dropmessage 50006, 'us_english'	
SET @strmessage = 'The debit and credit amounts are not balanced.'
EXEC sp_addmessage 50006,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50007) EXEC sp_dropmessage 50007, 'us_english'	
SET @strmessage = 'The transaction is already posted.'
EXEC sp_addmessage 50007,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50008) EXEC sp_dropmessage 50008, 'us_english'	
SET @strmessage = 'The transaction is already unposted.'
EXEC sp_addmessage 50008,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50009) EXEC sp_dropmessage 50009, 'us_english'	
SET @strmessage = 'The transaction is already cleared.'
EXEC sp_addmessage 50009,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50010) EXEC sp_dropmessage 50010, 'us_english'	
SET @strmessage = 'The bank account is inactive.'
EXEC sp_addmessage 50010,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50011) EXEC sp_dropmessage 50011, 'us_english'	
SET @strmessage = 'A failed check is misisng a reason.'
EXEC sp_addmessage 50011,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50012) EXEC sp_dropmessage 50012, 'us_english'	
SET @strmessage = 'Check is already voided.'
EXEC sp_addmessage 50012,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50013) EXEC sp_dropmessage 50013, 'us_english'	
SET @strmessage = 'You cannot %s transactions you did not create. Please contact your local administrator.'
EXEC sp_addmessage 50013,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50014) EXEC sp_dropmessage 50014, 'us_english'	
SET @strmessage = 'Not enough check numbers. Please generate new check numbers.'
EXEC sp_addmessage 50014,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50015) EXEC sp_dropmessage 50015, 'us_english'	
SET @strmessage = 'The transaction id %s already exists. Please ask your local administrator to check the starting numbers setup.'
EXEC sp_addmessage 50015,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50016) EXEC sp_dropmessage 50016, 'us_english'	
SET @strmessage = 'Unable to delete checkbook because it is used in the A/P Invoice file.'
EXEC sp_addmessage 50016,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50017) EXEC sp_dropmessage 50017, 'us_english'	
SET @strmessage = 'Unable to delete checkbook because it is used in the Check History file.'
EXEC sp_addmessage 50017,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50018) EXEC sp_dropmessage 50018, 'us_english'	
SET @strmessage = 'Unable to delete checkbook because it is used in the A/P Transaction file.'
EXEC sp_addmessage 50018,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50019) EXEC sp_dropmessage 50019, 'us_english'	
SET @strmessage = 'Duplicate checkbook id found.'
EXEC sp_addmessage 50019,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50020) EXEC sp_dropmessage 50020, 'us_english'	
SET @strmessage = 'Cannot post a zero-value transaction.'
EXEC sp_addmessage 50020,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50021) EXEC sp_dropmessage 50021, 'us_english'	
SET @strmessage = 'The record being created already exists in origin. Remove the duplicate record from origin or do a conversion.'
EXEC sp_addmessage 50021,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50022) EXEC sp_dropmessage 50022, 'us_english'	
SET @strmessage = 'There is an outdated Undeposited Fund record. It may have been deposited from a different deposit transaction.'
EXEC sp_addmessage 50022,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50023) EXEC sp_dropmessage 50023, 'us_english'	
SET @strmessage = 'The Undeposited Fund amount was changed. It does not match the values from the origin system.'
EXEC sp_addmessage 50023,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50024) EXEC sp_dropmessage 50024, 'us_english'	
SET @strmessage = 'Please re-process the Undeposited Funds. It looks like one or more records of it is already posted in %s.'
EXEC sp_addmessage 50024,11,@strmessage,'us_english','False'