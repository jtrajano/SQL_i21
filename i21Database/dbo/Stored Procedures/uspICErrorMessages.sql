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

-- was 50027
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80001) EXEC sp_dropmessage 80001, 'us_english'	
SET @strmessage = 'Item id is invalid or missing.'
EXEC sp_addmessage 80001,11,@strmessage,'us_english','False'

-- was 50028
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80002) EXEC sp_dropmessage 80002, 'us_english'	
SET @strmessage = 'Item Location is invalid or missing for %s.'
EXEC sp_addmessage 80002,11,@strmessage,'us_english','False'

-- was 50029
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80003) EXEC sp_dropmessage 80003, 'us_english'	
SET @strmessage = 'Negative stock quantity is not allowed for %s in %s.'
EXEC sp_addmessage 80003,11,@strmessage,'us_english','False'

-- was 50031
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80004) EXEC sp_dropmessage 80004, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.'
EXEC sp_addmessage 80004,11,@strmessage,'us_english','False'

-- was 51037
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80005) EXEC sp_dropmessage 80005, 'us_english'	
SET @strmessage = 'Please specify the lot numbers for %s.'
EXEC sp_addmessage 80005,11,@strmessage,'us_english','False'

-- was 51038
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80006) EXEC sp_dropmessage 80006, 'us_english'	
SET @strmessage = 'The Qty to Receive for %s is %s. Total Lot Quantity is %s. The difference is %s.'
EXEC sp_addmessage 80006,11,@strmessage,'us_english','False'

-- was 51040
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80007) EXEC sp_dropmessage 80007, 'us_english'	
SET @strmessage = 'Not enough stocks for %s. Reserved stocks is %s while On Hand Qty is %s.'
EXEC sp_addmessage 80007,11,@strmessage,'us_english','False'

-- was 51041
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80008) EXEC sp_dropmessage 80008, 'us_english'	
SET @strmessage = '%s is missing a GL account setup for %s account category.'
EXEC sp_addmessage 80008,11,@strmessage,'us_english','False'

-- was 51042
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80009) EXEC sp_dropmessage 80009, 'us_english'	
SET @strmessage = 'Unable to generate the serial lot number for %s.'
EXEC sp_addmessage 80009,11,@strmessage,'us_english','False'

-- was 51043
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80010) EXEC sp_dropmessage 80010, 'us_english'	
SET @strmessage = 'Failed to process the lot number for %s. It may have been used on a different sub-location or storage location.'
EXEC sp_addmessage 80010,11,@strmessage,'us_english','False'

-- was 51044
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80011) EXEC sp_dropmessage 80011, 'us_english'	
SET @strmessage = 'Lot %s exists in %s. Cannot retrieve in %s. Change the receiving UOM to %s or create a new lot.'
EXEC sp_addmessage 80011,11,@strmessage,'us_english','False'

-- was 51045
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80012) EXEC sp_dropmessage 80012, 'us_english'	
SET @strmessage = 'The Weight UOM for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 80012,11,@strmessage,'us_english','False'

-- was 51046
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80013) EXEC sp_dropmessage 80013, 'us_english'	
SET @strmessage = 'The Sub-Location for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 80013,11,@strmessage,'us_english','False'

-- was 51047
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80014) EXEC sp_dropmessage 80014, 'us_english'	
SET @strmessage = 'The Storage Location for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
EXEC sp_addmessage 80014,11,@strmessage,'us_english','False'

-- was 51048
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80015) EXEC sp_dropmessage 80015, 'us_english'	
SET @strmessage = '%s with lot number %s needs to have a weight.'
EXEC sp_addmessage 80015,11,@strmessage,'us_english','False'

-- was 51049
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80016) EXEC sp_dropmessage 80016, 'us_english'	
SET @strmessage = 'Please correct the UOM. The UOM for %s in PO is %s. It is now using %s in the Inventory Receipt.'
EXEC sp_addmessage 80016,11,@strmessage,'us_english','False'

-- was 51050
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80017) EXEC sp_dropmessage 80017, 'us_english'	
SET @strmessage = 'Please correct the unit qty in UOM %s on %s.'
EXEC sp_addmessage 80017,11,@strmessage,'us_english','False'

-- was 51051
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80018) EXEC sp_dropmessage 80018, 'us_english'	
SET @strmessage = 'The lot number %s is already used in %s.'
EXEC sp_addmessage 80018,11,@strmessage,'us_english','False'

-- was 51052
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80019) EXEC sp_dropmessage 80019, 'us_english'	
SET @strmessage = 'Please check for duplicate lot numbers. The lot number %s is used more than once in item %s on %s.'
EXEC sp_addmessage 80019,11,@strmessage,'us_english','False'

-- was 51053
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80020) EXEC sp_dropmessage 80020, 'us_english'	
SET @strmessage = 'Invalid Lot.'
EXEC sp_addmessage 80020,11,@strmessage,'us_english','False'

-- was 51077
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80021) EXEC sp_dropmessage 80021, 'us_english'	
SET @strmessage = 'Invalid Item.'
EXEC sp_addmessage 80021,11,@strmessage,'us_english','False'

-- was 51090
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80022) EXEC sp_dropmessage 80022, 'us_english'	
SET @strmessage = 'The status of %s is Discontinued.'
EXEC sp_addmessage 80022,11,@strmessage,'us_english','False'

-- was 51091
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80023) EXEC sp_dropmessage 80023, 'us_english'	
SET @strmessage = 'Missing costing method setup for item %s.'
EXEC sp_addmessage 80023,11,@strmessage,'us_english','False' 

-- was 51097
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80024) EXEC sp_dropmessage 80024, 'us_english'	
SET @strmessage = 'Lot status for %s for item %s is going to be updated more than once. Please remove the duplicate.'
EXEC sp_addmessage 80024,11,@strmessage,'us_english','False' 

-- was 51098
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80025) EXEC sp_dropmessage 80025, 'us_english'	
SET @strmessage = 'Recap is not applicable for this type of transaction.'
EXEC sp_addmessage 80025,11,@strmessage,'us_english','False' 

-- was 51099
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80026) EXEC sp_dropmessage 80026, 'us_english'	
SET @strmessage = 'Item %s is not available on location %s.'
EXEC sp_addmessage 80026,11,@strmessage,'us_english','False' 

-- was 51100
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80027) EXEC sp_dropmessage 80027, 'us_english'	
SET @strmessage = 'The stock on hand is outdated for %s. Please review your quantity adjustments after the system reloads the latest stock on hand.'
EXEC sp_addmessage 80027,11,@strmessage,'us_english','False' 

-- was 51101
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80028) EXEC sp_dropmessage 80028, 'us_english'	
SET @strmessage = 'The lot expiry dates are outdated for %s. Please review your quantity adjustments after the system reloads the latest expiry dates.'
EXEC sp_addmessage 80028,11,@strmessage,'us_english','False' 

-- was 51117
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80029) EXEC sp_dropmessage 80029, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.'
EXEC sp_addmessage 80029,11,@strmessage,'us_english','False'

-- was 51118
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80030) EXEC sp_dropmessage 80030, 'us_english'	
SET @strmessage = 'The lot status is invalid.'
EXEC sp_addmessage 80030,11,@strmessage,'us_english','False'   

-- was 51119
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80031) EXEC sp_dropmessage 80031, 'us_english'	
SET @strmessage = 'Unable to generate Lot Number. Please ask your local administrator to check the starting numbers setup.'
EXEC sp_addmessage 80031,11,@strmessage,'us_english','False'

-- was 51124
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80032) EXEC sp_dropmessage 80032, 'us_english'	
SET @strmessage = 'Internal Error. The source transaction type provided is invalid or not supported.'
EXEC sp_addmessage 80032,11,@strmessage,'us_english','False'

-- was 51125
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80033) EXEC sp_dropmessage 80033, 'us_english'	
SET @strmessage = 'Internal Error. The source transaction id is invalid.'
EXEC sp_addmessage 80033,11,@strmessage,'us_english','False'

-- was 51126
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80034) EXEC sp_dropmessage 80034, 'us_english'	
SET @strmessage = 'Internal Error. The new expiry date is invalid.'
EXEC sp_addmessage 80034,11,@strmessage,'us_english','False'

-- was 51127
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80035) EXEC sp_dropmessage 80035, 'us_english'	
SET @strmessage = 'Internal Error. The Adjust By Quantity is required.'
EXEC sp_addmessage 80035,11,@strmessage,'us_english','False'

-- was 51128
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80036) EXEC sp_dropmessage 80036, 'us_english'	
SET @strmessage = 'Internal Error. The new sub-location is invalid.'
EXEC sp_addmessage 80036,11,@strmessage,'us_english','False'

-- was 51129
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80037) EXEC sp_dropmessage 80037, 'us_english'	
SET @strmessage = 'Internal Error. The new storage location is invalid.'
EXEC sp_addmessage 80037,11,@strmessage,'us_english','False'

-- was 51135
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80038) EXEC sp_dropmessage 80038, 'us_english'	
SET @strmessage = 'A consigned or custodial item is no longer available. Unable to continue and unpost the transaction.'
EXEC sp_addmessage 80038,11,@strmessage,'us_english','False'

-- was 51136
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80039) EXEC sp_dropmessage 80039, 'us_english'	
SET @strmessage = 'The UOM is missing on %s.'
EXEC sp_addmessage 80039,11,@strmessage,'us_english','False'

-- was 51143
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80040) EXEC sp_dropmessage 80040, 'us_english'	
SET @strmessage = 'Please specify the Adjust Qty By or New Quantity on %s.'
EXEC sp_addmessage 80040,11,@strmessage,'us_english','False'

-- was 51144
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80041) EXEC sp_dropmessage 80041, 'us_english'	
SET @strmessage = 'Custody or storage for %s is not yet supported. It is currently limited to lot-tracked items.'
EXEC sp_addmessage 80041,11,@strmessage,'us_english','False'

-- was 51145
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80042) EXEC sp_dropmessage 80042, 'us_english'	
SET @strmessage = 'Cannot have the same item and weight UOM. Please remove the weight UOM for %s with lot number %s.'
EXEC sp_addmessage 80042,11,@strmessage,'us_english','False'

-- was 51148
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80043) EXEC sp_dropmessage 80043, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Purchase Contract to Inventory Receipt.'
EXEC sp_addmessage 80043,11,@strmessage,'us_english','False'

-- was 51149
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80044) EXEC sp_dropmessage 80044, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Transfer Order to Inventory Receipt.'
EXEC sp_addmessage 80044,11,@strmessage,'us_english','False'

-- was 51150
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80045) EXEC sp_dropmessage 80045, 'us_english'	
SET @strmessage = 'Recap is not applicable when doing an inventory transfer for the same location.'
EXEC sp_addmessage 80045,11,@strmessage,'us_english','False' 

-- was 51151
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80046) EXEC sp_dropmessage 80046, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Receipt. An error stopped the process from Inbound Shipment to Inventory Receipt.'
EXEC sp_addmessage 80046,11,@strmessage,'us_english','False'

-- was 51153
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80047) EXEC sp_dropmessage 80047, 'us_english'	
SET @strmessage = 'The Qty to Ship for %s is %s. Total Lot Quantity is %s. The difference is %s.'
EXEC sp_addmessage 80047,11,@strmessage,'us_english','False'

-- was 51159
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80048) EXEC sp_dropmessage 80048, 'us_english'	
SET @strmessage = 'Item UOM is invalid or missing.'
EXEC sp_addmessage 80048,11,@strmessage,'us_english','False'

-- was 51160 or 51134
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80049) EXEC sp_dropmessage 80049, 'us_english'	
SET @strmessage = 'Item %s is missing a Stock Unit. Please check the Unit of Measure setup.'
EXEC sp_addmessage 80049,11,@strmessage,'us_english','False'

-- was 51163
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80050) EXEC sp_dropmessage 80050, 'us_english'	
SET @strmessage = 'Unable to calculate %s as the UOM %s is not setup for item %s.'
EXEC sp_addmessage 80050,11,@strmessage,'us_english','False'

-- was 51164
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80051) EXEC sp_dropmessage 80051, 'us_english'	
SET @strmessage = 'Cyclic situation found. Unable to compute surcharge because %s depends on %s and vice-versa.'
EXEC sp_addmessage 80051,11,@strmessage,'us_english','False'

-- was 51165
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80052) EXEC sp_dropmessage 80052, 'us_english'	
SET @strmessage = 'Unable to compute the surcharge for %s. The On Cost for the surcharge could be missing. Also, the Vendor for both the surcharge and On Cost must match.'
EXEC sp_addmessage 80052,11,@strmessage,'us_english','False'

-- was 51166
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80053) EXEC sp_dropmessage 80053, 'us_english'	
SET @strmessage = 'Unable to continue. Cost allocation is by Weight but stock unit for %s is not a weight type.'
EXEC sp_addmessage 80053,11,@strmessage,'us_english','False'

-- was 51167
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80054) EXEC sp_dropmessage 80054, 'us_english'	
SET @strmessage = 'Unable to unpost the Inventory Receipt. The %s was billed.'
EXEC sp_addmessage 80054,11,@strmessage,'us_english','False'

-- was 51169
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80055) EXEC sp_dropmessage 80055, 'us_english'	
SET @strmessage = 'Data not found. Unable to create the Inventory Receipt.'
EXEC sp_addmessage 80055,11,@strmessage,'us_english','False'

-- was 51173
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80056) EXEC sp_dropmessage 80056, 'us_english'	
SET @strmessage = 'Unable to Unreceive. The inventory receipt is already billed in %s.'
EXEC sp_addmessage 80056,11,@strmessage,'us_english','False'

-- was 51176
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80057) EXEC sp_dropmessage 80057, 'us_english'	
SET @strmessage = 'Split Lot requires a negative Adjust Qty on %s to split stocks from it.'
EXEC sp_addmessage 80057,11,@strmessage,'us_english','False'

-- was 51177
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80058) EXEC sp_dropmessage 80058, 'us_english'	
SET @strmessage = 'Merge Lot requires a negative Adjust Qty on %s as stock for the merge.'
EXEC sp_addmessage 80058,11,@strmessage,'us_english','False'

-- was 51178
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80059) EXEC sp_dropmessage 80059, 'us_english'	
SET @strmessage = 'Lot Move requires a negative Adjust Qty on %s as stock for the move.'
EXEC sp_addmessage 80059,11,@strmessage,'us_english','False'

-- was 51180 (in 1530 Dev -> Prod)
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80060) EXEC sp_dropmessage 80060, 'us_english'	
SET @strmessage = 'Data not found. Unable to create the Inventory Transfer.'
EXEC sp_addmessage 80060,11,@strmessage,'us_english','False'

-- was 51181
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80061) EXEC sp_dropmessage 80061, 'us_english'	
SET @strmessage = 'Unable to generate the Inventory Transfer. An error stopped the creation of the inventory transfer.'
EXEC sp_addmessage 80061,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80062) EXEC sp_dropmessage 80062, 'us_english'	
SET @strmessage = 'Cost adjustment cannot continue. Unable to find the cost bucket for %s that was posted in %s.'
EXEC sp_addmessage 80062,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80063) EXEC sp_dropmessage 80063, 'us_english'	
SET @strmessage = 'Unable to unpost because %s has a cost adjustment from %s.'
EXEC sp_addmessage 80063,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80064) EXEC sp_dropmessage 80064, 'us_english'	
SET @strmessage = 'The %s is both a payable and deductible to the bill of the same vendor. Please correct the Accrue or Price checkbox.'
EXEC sp_addmessage 80064,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80065) EXEC sp_dropmessage 80065, 'us_english'	
SET @strmessage = 'The %s is shouldered by the receipt vendor and can''t be added to the item cost. Please correct the Price or Inventory Cost checkbox.'
EXEC sp_addmessage 80065,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80066) EXEC sp_dropmessage 80066, 'us_english'	
SET @strmessage = 'Inventory Count is ongoing for Item %s and is locked under Location %s.'
EXEC sp_addmessage 80066,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80067) EXEC sp_dropmessage 80067, 'us_english'	
SET @strmessage = 'Inventory Shipment Line Item does not exist.'
EXEC sp_addmessage 80067,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80068) EXEC sp_dropmessage 80068, 'us_english'	
SET @strmessage = 'Item % is not a lot tracked item and cannot ship lots.'
EXEC sp_addmessage 80068,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80069) EXEC sp_dropmessage 80069, 'us_english'	
SET @strmessage = '% has only % available quantity. Cannot ship more than the available qty.'
EXEC sp_addmessage 80069,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80070) EXEC sp_dropmessage 80070, 'us_english'	
SET @strmessage = 'Delete is not allowed. %s is posted.'
EXEC sp_addmessage 80070,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80071) EXEC sp_dropmessage 80071, 'us_english'	
SET @strmessage = 'Cost adjustment cannot continue. Unable to find the cost bucket for the lot %s in item %s that was posted in %s.'
EXEC sp_addmessage 80071,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80072) EXEC sp_dropmessage 80072, 'us_english'	
SET @strmessage = 'Lot merge of %s is not allowed because it will be merged to the same lot number, location, sub location, and storage location.'
EXEC sp_addmessage 80072,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80073) EXEC sp_dropmessage 80073, 'us_english'	
SET @strmessage = 'Split Lot for %s is not allowed because it will be a split to the same lot number, location, sub location, and storage location.'
EXEC sp_addmessage 80073,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80074) EXEC sp_dropmessage 80074, 'us_english'	
SET @strmessage = 'The lot %s is assigned to the same item. Item change requires a different item.'
EXEC sp_addmessage 80074,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80075) EXEC sp_dropmessage 80075, 'us_english'	
SET @strmessage = 'Item %s is invalid. It must be lot tracked.'
EXEC sp_addmessage 80075,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80076) EXEC sp_dropmessage 80076, 'us_english'	
SET @strmessage = 'Lot move of %s is not allowed because it will be moved to the same location, sub location, and storage location.'
EXEC sp_addmessage 80076,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80077) EXEC sp_dropmessage 80077, 'us_english'	
SET @strmessage = 'Unable to update %s. It is posted. Please unpost it first.'
EXEC sp_addmessage 80077,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80078) EXEC sp_dropmessage 80078, 'us_english'	
SET @strmessage = 'Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s.'
EXEC sp_addmessage 80078,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80079) EXEC sp_dropmessage 80079, 'us_english'	
SET @strmessage = 'Item UOM for %s is invalid or missing.'
EXEC sp_addmessage 80079,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80080) EXEC sp_dropmessage 80080, 'us_english'	
SET @strmessage = 'Item UOM %s for %s is invalid or missing.'
EXEC sp_addmessage 80080,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80081) EXEC sp_dropmessage 80081, 'us_english'	
SET @strmessage = 'Net quantity mismatch. It is %s on item %s but the total net from the lot(s) is %s.'
EXEC sp_addmessage 80081,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80082) EXEC sp_dropmessage 80082, 'us_english'	
SET @strmessage = 'The net quantity for item %s is missing.'
EXEC sp_addmessage 80082,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80083) EXEC sp_dropmessage 80083, 'us_english'	
SET @strmessage = 'The new Item Location is invalid or missing for %s.'
EXEC sp_addmessage 80083,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80084) EXEC sp_dropmessage 80084, 'us_english'	
SET @strmessage = 'Check the Rebuild Valuation GL Snapshot. The original GL values changed when compared against the rebuild values. To check the discrepancies, run: SELECT * FROM vyuICCompareRebuildValuationSnapshot WHERE dtmRebuildDate = ''%s'''
EXEC sp_addmessage 80084,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80085) EXEC sp_dropmessage 80085, 'us_english'	
SET @strmessage = 'Each lotted item for %s that is going to be transferred should have a lot number specified.'
EXEC sp_addmessage 80085,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80086) EXEC sp_dropmessage 80086, 'us_english'	
SET @strmessage = 'Cannot post this Inventory Receipt. The transfer order "%s" was already posted in "%s".'
EXEC sp_addmessage 80086,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80087) EXEC sp_dropmessage 80087, 'us_english'	
SET @strmessage = 'The sub location and storage location in %s does not match.' -- 'Line item and Lot storage location is not under %s.'
EXEC sp_addmessage 80087,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80088) EXEC sp_dropmessage 80088, 'us_english'	
SET @strmessage = 'Vendor for Other Charge item %s is required to accrue.'
EXEC sp_addmessage 80088,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80089) EXEC sp_dropmessage 80089, 'us_english'	
SET @strmessage = 'The inventory shipment is already in %s. Remove the invoice first before you can unpost this shipment.'
EXEC sp_addmessage 80089,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80090) EXEC sp_dropmessage 80090, 'us_english'	
SET @strmessage = 'Lotted item %s should have lot(s) specified.'
EXEC sp_addmessage 80090,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80091) EXEC sp_dropmessage 80091, 'us_english'	
SET @strmessage = 'Unable to unpost the Inventory Shipment. The %s was billed.'
EXEC sp_addmessage 80091,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80092) EXEC sp_dropmessage 80092, 'us_english'	
SET @strmessage = 'The item %s is already in %s. Remove it from the Invoice first before you can modify it from the Shipment.'
EXEC sp_addmessage 80092,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80093) EXEC sp_dropmessage 80093, 'us_english'	
SET @strmessage = 'Stock quantity is now zero on %s in %s. Auto variance is posted to zero out its inventory valuation.'
EXEC sp_addmessage 80093,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80094) EXEC sp_dropmessage 80094, 'us_english'	
SET @strmessage = '%s costing method is Average Costing and it will be received in %s as Actual costing. This is not allowed to avoid bad computation of the average cost. Try receiving the stocks using Inventory Receipt instead of Transport Load.'
EXEC sp_addmessage 80094,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80095) EXEC sp_dropmessage 80095, 'us_english'	
SET @strmessage = 'The %s cannot be accrued to the same Shipment Customer.'
EXEC sp_addmessage 80095,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80096) EXEC sp_dropmessage 80096, 'us_english'	
SET @strmessage = 'Check the date on the transaction. As of %s, there is no stock available for %s in %s.'
EXEC sp_addmessage 80096,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80097) EXEC sp_dropmessage 80097, 'us_english'	
SET @strmessage = 'Sub Location is invalid or missing for item %s.'
EXEC sp_addmessage 80097,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80098) EXEC sp_dropmessage 80098, 'us_english'	
SET @strmessage = 'Storage Location is invalid for item %s.'
EXEC sp_addmessage 80098,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80099) EXEC sp_dropmessage 80099, 'us_english'	
SET @strmessage = 'New Quantity for item %s is required.'
EXEC sp_addmessage 80099,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80100) EXEC sp_dropmessage 80100, 'us_english'	
SET @strmessage = 'Cannot return the inventory receipt. %s must be posted before it can be returned.'
EXEC sp_addmessage 80100,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80101) EXEC sp_dropmessage 80101, 'us_english'	
SET @strmessage = 'Unable to unpost because it has a debit memo. Unpost and delete %s first before you can unpost the Inventory Return.'
EXEC sp_addmessage 80101,11,@strmessage,'us_english','False'

-- was 51174 
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80102) EXEC sp_dropmessage 80102, 'us_english'	
SET @strmessage = 'Unable to unpost. Charge %s has a voucher in %s.'
EXEC sp_addmessage 80102,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80103) EXEC sp_dropmessage 80103, 'us_english'	
SET @strmessage = 'Cannot return %s because it is a Transfer Order.'
EXEC sp_addmessage 80103,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80104) EXEC sp_dropmessage 80104, 'us_english'	
SET @strmessage = 'UOM Id is invalid for item %s.'
EXEC sp_addmessage 80104,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80105) EXEC sp_dropmessage 80105, 'us_english'	
SET @strmessage = 'Invalid Owner. %s is not configured as an Owner for %s. Please check the Item setup.'
EXEC sp_addmessage 80105,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80106) EXEC sp_dropmessage 80106, 'us_english'	
SET @strmessage = 'Internal Error. The Adjust By Quantity is required to be a negative value.'
EXEC sp_addmessage 80106,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80107) EXEC sp_dropmessage 80107, 'us_english'	
SET @strmessage = 'Unable to unpost the Inventory Transfer. The %s already have a receipt. Please remove it from the receipt "%s"'
EXEC sp_addmessage 80107,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80108) EXEC sp_dropmessage 80108, 'us_english'	
SET @strmessage = 'Check the return date on the transaction. Return date is %s, while %s in %s is dated %s.'
EXEC sp_addmessage 80108,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80109) EXEC sp_dropmessage 80109, 'us_english'	
SET @strmessage = 'Return is stopped. All of the stocks in %s that is received in %s are either sold, consumed, returned, or over-return is going to happen.'
EXEC sp_addmessage 80109,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80110) EXEC sp_dropmessage 80110, 'us_english'	
SET @strmessage = 'Debit Memo is no longer needed. All items have Debit Memo.'
EXEC sp_addmessage 80110,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80111) EXEC sp_dropmessage 80111, 'us_english'	
SET @strmessage = 'Voucher is no longer needed. All items have Voucher.'
EXEC sp_addmessage 80111,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80112) EXEC sp_dropmessage 80112, 'us_english'	
SET @strmessage = 'Unable to unpost the Inventory Receipt because it was returned. Please check %s.'
EXEC sp_addmessage 80112,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80113) EXEC sp_dropmessage 80113, 'us_english'	
SET @strmessage = 'Currency Id is invalid or missing.'
EXEC sp_addmessage 80113,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80114) EXEC sp_dropmessage 80114, 'us_english'	
SET @strmessage = 'Freight Term Id %s is invalid.'
EXEC sp_addmessage 80114,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80115) EXEC sp_dropmessage 80115, 'us_english'	
SET @strmessage = 'Source Type Id is invalid or missing.'
EXEC sp_addmessage 80115,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80116) EXEC sp_dropmessage 80116, 'us_english'	
SET @strmessage = 'Tax Group Id %s is invalid.'
EXEC sp_addmessage 80116,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80117) EXEC sp_dropmessage 80117, 'us_english'	
SET @strmessage = 'Item Id %s is invalid.'
EXEC sp_addmessage 80117,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80118) EXEC sp_dropmessage 80118, 'us_english'	
SET @strmessage = 'Contract Header Id %s is invalid.'
EXEC sp_addmessage 80118,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80119) EXEC sp_dropmessage 80119, 'us_english'	
SET @strmessage = 'Contract Detail Id is invalid or missing for Contract Header Id %s.'
EXEC sp_addmessage 80119,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80120) EXEC sp_dropmessage 80120, 'us_english'	
SET @strmessage = 'Item UOM Id is invalid or missing for item %s.'
EXEC sp_addmessage 80120,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80121) EXEC sp_dropmessage 80121, 'us_english'	
SET @strmessage = 'Gross/Net UOM is invalid for item %s.'
EXEC sp_addmessage 80121,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80122) EXEC sp_dropmessage 80122, 'us_english'	
SET @strmessage = 'Cost UOM is invalid or missing for item %s.'
EXEC sp_addmessage 80122,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80123) EXEC sp_dropmessage 80123, 'us_english'	
SET @strmessage = 'Lot ID %s is invalid for item %s.'
EXEC sp_addmessage 80123,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80124) EXEC sp_dropmessage 80124, 'us_english'	
SET @strmessage = 'Other Charge Item Id is invalid or missing.'
EXEC sp_addmessage 80124,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80125) EXEC sp_dropmessage 80125, 'us_english'	
SET @strmessage = 'Cost Method for Other Charge item %s is invalid or missing.'
EXEC sp_addmessage 80125,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80126) EXEC sp_dropmessage 80126, 'us_english'	
SET @strmessage = 'Cost Currency Id is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80126,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80127) EXEC sp_dropmessage 80127, 'us_english'	
SET @strmessage = 'Vendor Id is invalid for other charge item %s.'
EXEC sp_addmessage 80127,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80128) EXEC sp_dropmessage 80128, 'us_english'	
SET @strmessage = 'Allocate Cost By is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80128,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80129) EXEC sp_dropmessage 80129, 'us_english'	
SET @strmessage = 'Other Charge Item Id is required for other charges.'
EXEC sp_addmessage 80129,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80130) EXEC sp_dropmessage 80130, 'us_english'	
SET @strmessage = 'Lot Number is invalid or missing for item %s.'
EXEC sp_addmessage 80130,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80131) EXEC sp_dropmessage 80131, 'us_english'	
SET @strmessage = 'Lot Condition %s is invalid for lot %s.'
EXEC sp_addmessage 80131,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80132) EXEC sp_dropmessage 80132, 'us_english'	
SET @strmessage = 'Parent Lot Id %s is invalid for lot %s.'
EXEC sp_addmessage 80132,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80133) EXEC sp_dropmessage 80133, 'us_english'	
SET @strmessage = 'Parent Lot Number is invalid or missing for lot %s.'
EXEC sp_addmessage 80133,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80134) EXEC sp_dropmessage 80134, 'us_english'
SET @strmessage = 'Receipt Type is invalid or missing.'
EXEC sp_addmessage 80134,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80135) EXEC sp_dropmessage 80135, 'us_english'	
SET @strmessage = 'Vendor Id is invalid or missing.'
EXEC sp_addmessage 80135,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80136) EXEC sp_dropmessage 80136, 'us_english'	
SET @strmessage = 'Ship From Id is invalid or missing.'
EXEC sp_addmessage 80136,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80137) EXEC sp_dropmessage 80137, 'us_english'	
SET @strmessage = 'Location Id is invalid or missing.'
EXEC sp_addmessage 80137,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80138) EXEC sp_dropmessage 80138, 'us_english'	
SET @strmessage = 'Ship Via Id %s is invalid.'
EXEC sp_addmessage 80138,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80139) EXEC sp_dropmessage 80139, 'us_english'	
SET @strmessage = 'Unable to repost. Item id: %s. Transaction id: %s. Batch id: %s. Account Category: %s.'
EXEC sp_addmessage 80139,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80140) EXEC sp_dropmessage 80140, 'us_english'	
SET @strmessage = 'Entity Id is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80140,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80141) EXEC sp_dropmessage 80141, 'us_english'	
SET @strmessage = 'Receipt type is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80141,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80142) EXEC sp_dropmessage 80142, 'us_english'	
SET @strmessage = 'Location Id is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80142,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80143) EXEC sp_dropmessage 80143, 'us_english'	
SET @strmessage = 'Ship Via Id is invalid for other charge item %s.'
EXEC sp_addmessage 80143,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80144) EXEC sp_dropmessage 80144, 'us_english'	
SET @strmessage = 'Ship From Id is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80144,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80145) EXEC sp_dropmessage 80145, 'us_english'	
SET @strmessage = 'Currency Id is invalid or missing for other charge item %s.'
EXEC sp_addmessage 80145,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80146) EXEC sp_dropmessage 80146, 'us_english'	
SET @strmessage = 'Entity Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80146,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80147) EXEC sp_dropmessage 80147, 'us_english'	
SET @strmessage = 'Receipt type is invalid or missing for lot %s.'
EXEC sp_addmessage 80147,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80148) EXEC sp_dropmessage 80148, 'us_english'	
SET @strmessage = 'Location Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80148,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80149) EXEC sp_dropmessage 80149, 'us_english'	
SET @strmessage = 'Ship Via Id is invalid for lot %s.'
EXEC sp_addmessage 80149,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80150) EXEC sp_dropmessage 80150, 'us_english'	
SET @strmessage = 'Ship From Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80150,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80151) EXEC sp_dropmessage 80151, 'us_english'	
SET @strmessage = 'Currency Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80151,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80152) EXEC sp_dropmessage 80152, 'us_english'	
SET @strmessage = 'Source Type Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80152,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80153) EXEC sp_dropmessage 80153, 'us_english'	
SET @strmessage = 'Item Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80153,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80154) EXEC sp_dropmessage 80154, 'us_english'	
SET @strmessage = 'Sub Location is invalid or missing for lot %s.'
EXEC sp_addmessage 80154,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80155) EXEC sp_dropmessage 80155, 'us_english'	
SET @strmessage = 'Storage Location is invalid or missing for lot %s.'
EXEC sp_addmessage 80155,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80156) EXEC sp_dropmessage 80156, 'us_english'	
SET @strmessage = 'Item UOM Id is invalid or missing for lot %s.'
EXEC sp_addmessage 80156,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80157) EXEC sp_dropmessage 80157, 'us_english'	
SET @strmessage = 'Lot ID %s is invalid for lot %s.'
EXEC sp_addmessage 80157,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80158) EXEC sp_dropmessage 80158, 'us_english'	
SET @strmessage = 'The Qty to Return for %s is %s. Total Lot Quantity is %s. The difference is %s.'
EXEC sp_addmessage 80158,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80159) EXEC sp_dropmessage 80159, 'us_english'	
SET @strmessage = 'Item: %s, Qty: %s, Cost: %s'
EXEC sp_addmessage 80159,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80160) EXEC sp_dropmessage 80160, 'us_english'	
SET @strmessage = 'Transaction not saved. Stocks for %s will have an over-return.'
EXEC sp_addmessage 80160,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80161) EXEC sp_dropmessage 80161, 'us_english'	
SET @strmessage = 'Return no longer allowed. All of the stocks are returned.'
EXEC sp_addmessage 80161,11,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 80162) EXEC sp_dropmessage 80162, 'us_english'	
SET @strmessage = '%s is using a foreign currency. Please check if %s has a forex rate.'
EXEC sp_addmessage 80162,11,@strmessage,'us_english','False'

