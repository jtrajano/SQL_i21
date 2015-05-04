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
SET @strmessage = '%s is missing a GL account setup for %s account category.'
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

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51051) EXEC sp_dropmessage 51051, 'us_english'	
SET @strmessage = 'The lot number %s is already used in %s.'
EXEC sp_addmessage 51051,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51052) EXEC sp_dropmessage 51052, 'us_english'	
SET @strmessage = 'Please check for duplicate lot numbers. The lot number %s is used more than once in item %s on %s.'
EXEC sp_addmessage 51052,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51053) EXEC sp_dropmessage 51053, 'us_english'	
SET @strmessage = 'Invalid Lot.'
EXEC sp_addmessage 51053,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51054) EXEC sp_dropmessage 51054, 'us_english'	
SET @strmessage = 'This lot %s was not produced through work order production process; hence this lot cannot be released from this screen. Try changing the lot status using the Lot Status Change screen available in the Inventory view screen.'
EXEC sp_addmessage 51054,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51055) EXEC sp_dropmessage 51055, 'us_english'	
SET @strmessage = 'Lot has already been released!.'
EXEC sp_addmessage 51055,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51056) EXEC sp_dropmessage 51056, 'us_english'	
SET @strmessage = 'Pallet Lot has been marked as a ghost and cannot be released. Please call Supervisor to reverse this!.'
EXEC sp_addmessage 51056,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51057) EXEC sp_dropmessage 51057, 'us_english'	
SET @strmessage = 'Invalid item type - you can only release finished goods items!.'
EXEC sp_addmessage 51057,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51058) EXEC sp_dropmessage 51058, 'us_english'	
SET @strmessage = 'Invalid GTIN Case code.'
EXEC sp_addmessage 51058,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51059) EXEC sp_dropmessage 51059, 'us_english'	
SET @strmessage = 'The pallet lot quantity cannot exceed more than  item''s cases per pallet. Please check produce quantity.'
EXEC sp_addmessage 51059,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51060) EXEC sp_dropmessage 51060, 'us_english'	
SET @strmessage = 'Item number for GTIN Case Code and Pallet Lot ID is not matching, please scan the appropriate case code.'
EXEC sp_addmessage 51060,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51061) EXEC sp_dropmessage 51061, 'us_english'	
SET @strmessage = 'Special characters are not allowed for LotID.'
EXEC sp_addmessage 51061,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51062) EXEC sp_dropmessage 51062, 'us_english'	
SET @strmessage = 'Lot quantity and physical count should be equal when same UOM is selected.'
EXEC sp_addmessage 51062,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51063) EXEC sp_dropmessage 51063, 'us_english'	
SET @strmessage = 'It is required to enter number of unit and weight to produce the lot.'
EXEC sp_addmessage 51063,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51064) EXEC sp_dropmessage 51064, 'us_english'	
SET @strmessage = 'Item is not available. It may have been deleted or inactive.'
EXEC sp_addmessage 51064,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51065) EXEC sp_dropmessage 51065, 'us_english'	
SET @strmessage =  'The specified item ''%s'' is InActive. The transaction can not proceed.'
EXEC sp_addmessage 51065,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51066) EXEC sp_dropmessage 51066, 'us_english'	
SET @strmessage =  'Location is not available. It may have been deleted.'
EXEC sp_addmessage 51066,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51067) EXEC sp_dropmessage 51067, 'us_english'	
SET @strmessage =  'Sub Location is not available. It may have been deleted.'
EXEC sp_addmessage 51067,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51068) EXEC sp_dropmessage 51068, 'us_english'	
SET @strmessage =  'Storage Location is not available. It may have been deleted.'
EXEC sp_addmessage 51068,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51069) EXEC sp_dropmessage 51069, 'us_english'	
SET @strmessage =  'Parent Storage Location is not allowed to hold a Lot.'
EXEC sp_addmessage 51069,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51070) EXEC sp_dropmessage 51070, 'us_english'	
SET @strmessage =  'The Storage Location is already used by other Lot.'
EXEC sp_addmessage 51070,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51071) EXEC sp_dropmessage 51071, 'us_english'	
SET @strmessage =  'The Storage Location is already used by other Lot for the Item ''%s'''
EXEC sp_addmessage 51071,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51072) EXEC sp_dropmessage 51072, 'us_english'	
SET @strmessage =  'The Storage Location is already used by other Item.'
EXEC sp_addmessage 51072,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51073) EXEC sp_dropmessage 51073, 'us_english'	
SET @strmessage =  'LotID ''%s'' already exists in this storage location ''%s''.'
EXEC sp_addmessage 51073,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51074) EXEC sp_dropmessage 51074, 'us_english'	
SET @strmessage =  'LotID ''%s'' has been configured with item ''%s'' in storage location ''%s''.'+' Please select same item to proceed.'
EXEC sp_addmessage 51074,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51075) EXEC sp_dropmessage 51075, 'us_english'	
SET @strmessage =   'Create date should not be in future date.'
EXEC sp_addmessage 51075,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51076) EXEC sp_dropmessage 51076, 'us_english'	
SET @strmessage =  'The Lot %s does not exist.'
EXEC sp_addmessage 51076,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51077) EXEC sp_dropmessage 51077, 'us_english'	
SET @strmessage =   'Invalid Item.'
EXEC sp_addmessage 51077,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51078) EXEC sp_dropmessage 51078, 'us_english'	
SET @strmessage =   'The work order that you clicked on does not exist.'
EXEC sp_addmessage 51078,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51079) EXEC sp_dropmessage 51079, 'us_english'	
SET @strmessage =  'The work order that you clicked on is already completed.'
EXEC sp_addmessage 51079,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51080) EXEC sp_dropmessage 51080, 'us_english'	
SET @strmessage =  'It is possible that this work order has been temporarily paused by another user. Please refresh the screen.'
EXEC sp_addmessage 51080,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51081) EXEC sp_dropmessage 51081, 'us_english'	
SET @strmessage =  'Work order is not in started state. Please start the work order.'
EXEC sp_addmessage 51081,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51082) EXEC sp_dropmessage 51082, 'us_english'	
SET @strmessage = 'The item ''%s'' on lot ''%s'' is not a configured input item on the product item %s''s BOM. The transaction will not be allowed to proceed.'
EXEC sp_addmessage 51082,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51083) EXEC sp_dropmessage 51083, 'us_english'	
SET @strmessage = 'The attempted produce quantity of ''%d'' for material ''%s'' is more than the allowed production quantity with upper tolerance %d. The transaction will not be allowed to proceed.'
EXEC sp_addmessage 51083,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51084) EXEC sp_dropmessage 51084, 'us_english'	
SET @strmessage =  'The attempted produce quantity of ''%d'' for material ''%s'' is more than the allowed production quantity with lower tolerance %d. The transaction will not be allowed to proceed.'
EXEC sp_addmessage 51084,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51085) EXEC sp_dropmessage 51085, 'us_english'	
SET @strmessage =  'The requested consume quantity of %d is invalid. Please attempt to consume a positive quantity less than or equal to input lot quantity.'
EXEC sp_addmessage 51085,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51086) EXEC sp_dropmessage 51086, 'us_english'	
SET @strmessage =  'Lot ''%s'' is in quarantine. You are not allowed to consume a quantity from a quarantined lot.'
EXEC sp_addmessage 51086,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51087) EXEC sp_dropmessage 51087, 'us_english'	
SET @strmessage =  'The lot ''%s'' is not available for consumption.'
EXEC sp_addmessage 51087,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51088) EXEC sp_dropmessage 51088, 'us_english'	
SET @strmessage =  'The Lot ''%s'' is expired. You cannot consume.'
EXEC sp_addmessage 51088,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51089) EXEC sp_dropmessage 51089, 'us_english'	
SET @strmessage = 'The attempted consumption quantity of %d %s of material ''%s'' from lot ''%s'' is more than the lot''s queued quantity of %d %s. The transaction will not be allowed to proceed.'
EXEC sp_addmessage 51089,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51090) EXEC sp_dropmessage 51090, 'us_english'	
SET @strmessage = 'The status of %s is Discontinued.'
EXEC sp_addmessage 51090,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51091) EXEC sp_dropmessage 51091, 'us_english'	
SET @strmessage = 'Missing costing method setup for item %s.'
EXEC sp_addmessage 51091,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51092) EXEC sp_dropmessage 51092, 'us_english'	
SET @strmessage =  'Please configure the location %s in the Item maintence.'
EXEC sp_addmessage 51092,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51093) EXEC sp_dropmessage 51093, 'us_english'	
SET @strmessage =  'Please configure the Packing UOM in the Item maintence.'
EXEC sp_addmessage 51093,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51094) EXEC sp_dropmessage 51094, 'us_english'	
SET @strmessage =  'Please configure stock unit in the item maintence.'
EXEC sp_addmessage 51094,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51095) EXEC sp_dropmessage 51095, 'us_english'	
SET @strmessage =  'One of the input items could not be consumed. Cannot produce.'
EXEC sp_addmessage 51095,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51096) EXEC sp_dropmessage 51096, 'us_english'	
SET @strmessage =  'There is no sufficient quantity for the item %s.'
EXEC sp_addmessage 51096,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51097) EXEC sp_dropmessage 51097, 'us_english'	
SET @strmessage = 'Lot status for %s for item %s is going to be updated more than once. Please remove the duplicate.'
EXEC sp_addmessage 51097,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51098) EXEC sp_dropmessage 51098, 'us_english'	
SET @strmessage = 'Recap is not applicable for this type of transaction.'
EXEC sp_addmessage 51098,11,@strmessage,'us_english','False' 