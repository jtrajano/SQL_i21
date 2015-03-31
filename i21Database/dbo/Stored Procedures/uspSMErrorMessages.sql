CREATE PROCEDURE uspSMErrorMessages
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

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50025) EXEC sp_dropmessage 50025, 'us_english'	
SET @strmessage = 'Unable to void while check printing is in progress.'
EXEC sp_addmessage 50025,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50026) EXEC sp_dropmessage 50026, 'us_english'	
SET @strmessage = 'Unable to unpost while check printing is in progress.'
EXEC sp_addmessage 50026,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50027) EXEC sp_dropmessage 50027, 'us_english'	
SET @strmessage = 'Item id is invalid or missing.'
EXEC sp_addmessage 50027,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50028) EXEC sp_dropmessage 50028, 'us_english'	
SET @strmessage = 'Item Location is invalid or missing.'
EXEC sp_addmessage 50028,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50029) EXEC sp_dropmessage 50029, 'us_english'	
SET @strmessage = 'Negative stock quantity is not allowed.'
EXEC sp_addmessage 50029,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50030) EXEC sp_dropmessage 50030, 'us_english'	
SET @strmessage = 'Unable to generate the transaction id. Please ask your local administrator to check the starting numbers setup.'
EXEC sp_addmessage 50030,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50031) EXEC sp_dropmessage 50031, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.'
EXEC sp_addmessage 50031,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 50032) EXEC sp_dropmessage 50032, 'us_english'	
SET @strmessage = 'G/L entries are expected. Cannot continue because it is missing.'
EXEC sp_addmessage 50032,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51033) EXEC sp_dropmessage 51033, 'us_english'	
SET @strmessage = 'Purchase Order does not exists.'
EXEC sp_addmessage 51033,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51034) EXEC sp_dropmessage 51034, 'us_english'	
SET @strmessage = 'Purchase Order item does not exists.'
EXEC sp_addmessage 51034,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51035) EXEC sp_dropmessage 51035, 'us_english'	
SET @strmessage = 'You cannot receive item more than to its ordered.'
EXEC sp_addmessage 51035,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51036) EXEC sp_dropmessage 51036, 'us_english'	
SET @strmessage = 'Purchase Order already closed.'
EXEC sp_addmessage 51036,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51037) EXEC sp_dropmessage 51037, 'us_english'	
SET @strmessage = 'Please specify the lot numbers for %s.'
EXEC sp_addmessage 51037,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51038) EXEC sp_dropmessage 51038, 'us_english'	
SET @strmessage = 'The Qty to Receive for %s is %s. Total Lot Quantity is %s. The difference is %s.'
EXEC sp_addmessage 51038,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51039) EXEC sp_dropmessage 51039, 'us_english'	
SET @strmessage = 'Cannot process Purchase Order with 0 amount.'
EXEC sp_addmessage 51039,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51040) EXEC sp_dropmessage 51040, 'us_english'	
SET @strmessage = 'There is not enough stocks for %s'
EXEC sp_addmessage 51040,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51041) EXEC sp_dropmessage 51041, 'us_english'	
SET @strmessage = 'G/L account setup is missing for %s.'
EXEC sp_addmessage 51041,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51042) EXEC sp_dropmessage 51042, 'us_english'	
SET @strmessage = 'Unable to generate the serial lot number for %s.'
EXEC sp_addmessage 51042,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51043) EXEC sp_dropmessage 51043, 'us_english'	
SET @strmessage = 'Failed to process the lot number for %s. It may have been used on a different sub-location or storage location.'
EXEC sp_addmessage 51043,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51044) EXEC sp_dropmessage 51044, 'us_english'	
SET @strmessage = 'The Quantity UOM for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 51044,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51045) EXEC sp_dropmessage 51045, 'us_english'	
SET @strmessage = 'The Weight UOM for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 51045,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51046) EXEC sp_dropmessage 51046, 'us_english'	
SET @strmessage = 'The Sub-Location for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 51046,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51047) EXEC sp_dropmessage 51047, 'us_english'	
SET @strmessage = 'The Storage Location for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 51047,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51048) EXEC sp_dropmessage 51048, 'us_english'	
SET @strmessage = '%s with lot number %s needs to have a weight.'
EXEC sp_addmessage 51048,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51049) EXEC sp_dropmessage 51049, 'us_english'	
SET @strmessage = 'Please correct the UOM. The UOM for %s in PO is %s. It is now using %s in the Inventory Receipt.'
EXEC sp_addmessage 51049,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51050) EXEC sp_dropmessage 51050, 'us_english'	
SET @strmessage = 'Please correct the unit qty in UOM %s on %s.'
EXEC sp_addmessage 51050,11,@strmessage,'us_english','False'
