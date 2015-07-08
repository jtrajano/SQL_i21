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
SET @strmessage = 'The bank account or its associated GL account is inactive.'
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
SET @strmessage = 'Unable to generate the Transaction Id. Please ask your local administrator to check the starting numbers setup.'
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
SET @strmessage =   'Lot cannot be produced in a future date or future shift.'
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
SET @strmessage =  'Please configure the location %s in the Item maintenance.'
EXEC sp_addmessage 51092,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51093) EXEC sp_dropmessage 51093, 'us_english'	
SET @strmessage =  'Please configure the Packing UOM in the Item maintenance.'
EXEC sp_addmessage 51093,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51094) EXEC sp_dropmessage 51094, 'us_english'	
SET @strmessage =  'Please configure stock unit in the item maintenance.'
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

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51099) EXEC sp_dropmessage 51099, 'us_english'	
SET @strmessage = 'Item %s is not available on location %s.'
EXEC sp_addmessage 51099,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51100) EXEC sp_dropmessage 51100, 'us_english'	
SET @strmessage = 'The stock on hand is outdated for %s. Please review your quantity adjustments after the system reloads the latest stock on hand.'
EXEC sp_addmessage 51100,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51101) EXEC sp_dropmessage 51101, 'us_english'	
SET @strmessage = 'The lot expiry dates are outdated for %s. Please review your quantity adjustments after the system reloads the latest expiry dates.'
EXEC sp_addmessage 51101,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51102) EXEC sp_dropmessage 51102, 'us_english'	
SET @strmessage = 'Cannot do the cycle count for future production date.'
EXEC sp_addmessage 51102,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51103) EXEC sp_dropmessage 51103, 'us_english'	
SET @strmessage = 'No machines are configured for cyclecount this process.'
EXEC sp_addmessage 51103,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51104) EXEC sp_dropmessage 51104, 'us_english'	
SET @strmessage = 'No valid input item is configured against the selected run, in Recipe configuration.'
EXEC sp_addmessage 51104,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51105) EXEC sp_dropmessage 51105, 'us_english'	
SET @strmessage = 'The run ''%s'' prior to the current run has no cycle count entries. Please do cycle count and close the previous run before starting the cycle count for the current run.'
EXEC sp_addmessage 51105,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51106) EXEC sp_dropmessage 51106, 'us_english'	
SET @strmessage = 'A cycle count for the item ''%s'' is already started for work order %s on %s for the target item ''%s''. Please complete the prior cycle count to continue.'
EXEC sp_addmessage 51106,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51107) EXEC sp_dropmessage 51107, 'us_english'	
SET @strmessage = 'A run for ''%s'' already exists for work order %s on %s which is using the same ingredient item ''%s''. Please complete the prior run to continue.'
EXEC sp_addmessage 51107,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51108) EXEC sp_dropmessage 51108, 'us_english'	
SET @strmessage = 'The run is already trued up. you cannot continue.'
EXEC sp_addmessage 51108,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51109) EXEC sp_dropmessage 51109, 'us_english'	
SET @strmessage = 'The cycle count for this run is already started by ''%s'' on ''%s''. you cannot continue. The current run already cyclecounted by another user. you cannot continue.'
EXEC sp_addmessage 51109,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51110) EXEC sp_dropmessage 51110, 'us_english'	
SET @strmessage = 'Lot quantity should be greater than zero.'
EXEC sp_addmessage 51110,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51111) EXEC sp_dropmessage 51111, 'us_english'	
SET @strmessage = 'No open runs for the target item ''%s''. Cannot consume.'
EXEC sp_addmessage 51111,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51112) EXEC sp_dropmessage 51112, 'us_english'	
SET @strmessage = 'Lot can not be blank.'
EXEC sp_addmessage 51112,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51113) EXEC sp_dropmessage 51113, 'us_english'	
SET @strmessage = 'Please select a valid lot'
EXEC sp_addmessage 51113,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51114) EXEC sp_dropmessage 51114, 'us_english'	
SET @strmessage = 'Input item ''%s'' does not belong to recipe of ''%s'' , Cannot proceed.'
EXEC sp_addmessage 51114,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51115) EXEC sp_dropmessage 51115, 'us_english'	
SET @strmessage = 'No mapped staging location found, cannot stage.'
EXEC sp_addmessage 51115,11,@strmessage,'us_english','False'   

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51116) EXEC sp_dropmessage 51116, 'us_english'	
SET @strmessage = 'The quantity to be consumed must not exceed the selected lot quantity.'
EXEC sp_addmessage 51116,11,@strmessage,'us_english','False'   

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51117) EXEC sp_dropmessage 51117, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.'
EXEC sp_addmessage 51117,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51118) EXEC sp_dropmessage 51118, 'us_english'	
SET @strmessage = 'The lot status is invalid.'
EXEC sp_addmessage 51118,11,@strmessage,'us_english','False'   

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51119) EXEC sp_dropmessage 51119, 'us_english'	
SET @strmessage = 'Unable to generate Lot Number. Please ask your local administrator to check the starting numbers setup.'
EXEC sp_addmessage 51119,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51120) EXEC sp_dropmessage 51120, 'us_english'	
SET @strmessage = 'Unable to generate the Batch Id. Please ask your local administrator to check the starting numbers setup.'
EXEC sp_addmessage 51120,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51121) EXEC sp_dropmessage 51121, 'us_english'	
SET @strmessage = 'Entered quantity is greater than the configured batch size for the machine'
EXEC sp_addmessage 51121,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51122) EXEC sp_dropmessage 51122, 'us_english'	
SET @strmessage = 'Lot Alias for Item ID ''%s'' Cannot be blank.'
EXEC sp_addmessage 51122,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51123) EXEC sp_dropmessage 51123, 'us_english'	
SET @strmessage = 'No open runs for the target item ''%s''. Cannot produce.'
EXEC sp_addmessage 51123,11,@strmessage,'us_english','False'  

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51124) EXEC sp_dropmessage 51124, 'us_english'	
SET @strmessage = 'Internal Error. The source transaction type provided is invalid or not supported.'
EXEC sp_addmessage 51124,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51125) EXEC sp_dropmessage 51125, 'us_english'	
SET @strmessage = 'Internal Error. The source transaction id is invalid.'
EXEC sp_addmessage 51125,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51126) EXEC sp_dropmessage 51126, 'us_english'	
SET @strmessage = 'Internal Error. The new expiry date is invalid.'
EXEC sp_addmessage 51126,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51127) EXEC sp_dropmessage 51127, 'us_english'	
SET @strmessage = 'Internal Error. The Adjust By Quantity is required.'
EXEC sp_addmessage 51127,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51128) EXEC sp_dropmessage 51128, 'us_english'	
SET @strmessage = 'Internal Error. The new sub-location is invalid.'
EXEC sp_addmessage 51128,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51129) EXEC sp_dropmessage 51129, 'us_english'	
SET @strmessage = 'Internal Error. The new storage location is invalid.'
EXEC sp_addmessage 51129,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51130) EXEC sp_dropmessage 51130, 'us_english'	
SET @strmessage = 'Production run already trued up.'
EXEC sp_addmessage 51130,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51131) EXEC sp_dropmessage 51131, 'us_english'	
SET @strmessage = 'Cycle count entries for the run not available, cannot proceed.'
EXEC sp_addmessage 51131,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51132) EXEC sp_dropmessage 51132, 'us_english'	
SET @strmessage = 'Please complete and save Cycle count entries for all the items before posting adjustment.'
EXEC sp_addmessage 51132,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51133) EXEC sp_dropmessage 51133, 'us_english'	
SET @strmessage = 'Production run(s) prior to the current run has not been trued up, True up the earlier runs and proceed.'
EXEC sp_addmessage 51133,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51134) EXEC sp_dropmessage 51134, 'us_english'	
SET @strmessage = 'No default consumption unit configured, cannot consume.'
EXEC sp_addmessage 51134,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51135) EXEC sp_dropmessage 51135, 'us_english'	
SET @strmessage = 'A consigned or custodial item is no longer available. Unable to continue and unpost the transaction.'
EXEC sp_addmessage 51135,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51136) EXEC sp_dropmessage 51136, 'us_english'	
SET @strmessage = 'The UOM is missing on %s.'
EXEC sp_addmessage 51136,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51137) EXEC sp_dropmessage 51137, 'us_english'	
SET @strmessage = 'This lot is already released. You can''t undo.'
EXEC sp_addmessage 51137,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51138) EXEC sp_dropmessage 51138, 'us_english'	
SET @strmessage = 'This lot is already reversed. You can''t undo.'
EXEC sp_addmessage 51138,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51139) EXEC sp_dropmessage 51139, 'us_english'	
SET @strmessage = 'Pallet Lot has been marked as a ghost and cannot be Undone.'
EXEC sp_addmessage 51139,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51140) EXEC sp_dropmessage 51140, 'us_english'	
SET @strmessage = 'The work order that you clicked on no longer exists. This is quite possible, if a packaging operator has deleted the work order and your iMake client is yet to refresh the screen.'
EXEC sp_addmessage 51140,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51141) EXEC sp_dropmessage 51141, 'us_english'	
SET @strmessage = 'Work order contains quarantined lot, you need to either release the lot or mark the pallet as ghost to close the work order.'
EXEC sp_addmessage 51141,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51142) EXEC sp_dropmessage 51142, 'us_english'	
SET @strmessage = 'Lot Id already exists. It should be unique'
EXEC sp_addmessage 51142,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51143) EXEC sp_dropmessage 51143, 'us_english'	
SET @strmessage = 'Please specify the Adjust Qty By or New Quantity on %s.'
EXEC sp_addmessage 51143,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51144) EXEC sp_dropmessage 51144, 'us_english'	
SET @strmessage = 'Custody or storage for %s is not yet supported. It is currently limited to lot-tracked items.'
EXEC sp_addmessage 51144,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51145) EXEC sp_dropmessage 51145, 'us_english'	
SET @strmessage = 'Cannot have the same item and weight UOM. Please remove the weight UOM for %s with lot number %s.'
EXEC sp_addmessage 51145,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51146) EXEC sp_dropmessage 51146, 'us_english'	
SET @strmessage = 'Execution order entered is out of range.'
EXEC sp_addmessage 51146,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51147) EXEC sp_dropmessage 51147, 'us_english'	
SET @strmessage = 'There is no active recipe found for item  %s Cannot proceed'
EXEC sp_addmessage 51147,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51148) EXEC sp_dropmessage 51148, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Purchase Contract to Inventory Receipt.'
EXEC sp_addmessage 51148,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51149) EXEC sp_dropmessage 51149, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Transfer Order to Inventory Receipt.'
EXEC sp_addmessage 51149,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51150) EXEC sp_dropmessage 51150, 'us_english'	
SET @strmessage = 'Recap is not applicable when doing an inventory transfer for the same location.'
EXEC sp_addmessage 51150,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51151) EXEC sp_dropmessage 51151, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Inbound Shipment to Inventory Receipt.'
EXEC sp_addmessage 51151,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51152) EXEC sp_dropmessage 51152, 'us_english'	
SET @strmessage = 'The target item %s is Phased out or Discontinued, cannot start the work order.'
EXEC sp_addmessage 51152,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51153) EXEC sp_dropmessage 51153, 'us_english'	
SET @strmessage = 'The Qty to Ship for %s is %s. Total Lot Quantity is %s. The difference is %s.'
EXEC sp_addmessage 51153,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 51154) EXEC sp_dropmessage 51154, 'us_english'	
SET @strmessage = 'Unable to calculate the Other Charges per unit. Please check if UOM %s is assigned to item %s.'
EXEC sp_addmessage 51154,11,@strmessage,'us_english','False'
