CREATE PROCEDURE [dbo].[uspARErrorMessages]
AS
DECLARE @strmessage AS NVARCHAR(MAX)

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120001) EXEC sp_dropmessage 120001, 'us_english'	
SET @strmessage = 'Invoice does not exists!'
EXEC sp_addmessage 120001,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120002) EXEC sp_dropmessage 120002, 'us_english'	
SET @strmessage = 'Item does not exists!'
EXEC sp_addmessage 120002,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120003) EXEC sp_dropmessage 120003, 'us_english'	
SET @strmessage = 'The company location from the target Invoice does not exists!'
EXEC sp_addmessage 120003,16,@strmessage,'us_english','False'
 
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120004) EXEC sp_dropmessage 120004, 'us_english'	
SET @strmessage = 'The item was not set up to be available on the specified location!'
EXEC sp_addmessage 120004,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120005) EXEC sp_dropmessage 120005, 'us_english'	
SET @strmessage = 'There is no setup for AR Account in the Company Configuration.'
EXEC sp_addmessage 120005,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120006) EXEC sp_dropmessage 120006, 'us_english'	
SET @strmessage = 'Freight Item doesn''t have default Sales UOM and stock UOM!'
EXEC sp_addmessage 120006,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120007) EXEC sp_dropmessage 120007, 'us_english'	
SET @strmessage = 'Surcharge doesn''t have default Sales UOM and stock UOM.'
EXEC sp_addmessage 120007,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120008) EXEC sp_dropmessage 120008, 'us_english'	
SET @strmessage = 'Invoice line item does not exists!'
EXEC sp_addmessage 120008,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120009) EXEC sp_dropmessage 120009, 'us_english'	
SET @strmessage = 'Tax Code does not exists!'
EXEC sp_addmessage 120009,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120010) EXEC sp_dropmessage 120010, 'us_english'	
SET @strmessage = 'The payment Id provided does not exists!'
EXEC sp_addmessage 120010,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120011) EXEC sp_dropmessage 120011, 'us_english'	
SET @strmessage = 'The invoice Id provided does not exists!'
EXEC sp_addmessage 120011,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120012) EXEC sp_dropmessage 120012, 'us_english'	
SET @strmessage = 'The invoice provided is not yet posted!'
EXEC sp_addmessage 120012,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120013) EXEC sp_dropmessage 120013, 'us_english'	
SET @strmessage = 'Invoice of type Cash cannot be added!'
EXEC sp_addmessage 120013,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120014) EXEC sp_dropmessage 120014, 'us_english'	
SET @strmessage = 'Invoice of type Cash Refund cannot be added!'
EXEC sp_addmessage 120014,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120015) EXEC sp_dropmessage 120015, 'us_english'	
SET @strmessage = 'Commission Id is Required!'
EXEC sp_addmessage 120015,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120016) EXEC sp_dropmessage 120016, 'us_english'	
SET @strmessage = 'Approval List Id is Required!'
EXEC sp_addmessage 120016,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120017) EXEC sp_dropmessage 120017, 'us_english'	
SET @strmessage = 'Approver Entity Id is Required!'
EXEC sp_addmessage 120017,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120018) EXEC sp_dropmessage 120018, 'us_english'	
SET @strmessage = 'Commission Plan is required!'
EXEC sp_addmessage 120018,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120019) EXEC sp_dropmessage 120019, 'us_english'	
SET @strmessage = 'Commission Recap ID is required!'
EXEC sp_addmessage 120019,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120020) EXEC sp_dropmessage 120020, 'us_english'	
SET @strmessage = 'There is no setup for Service Charge Account in the Company Configuration!'
EXEC sp_addmessage 120020,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120021) EXEC sp_dropmessage 120021, 'us_english'	
SET @strmessage = 'Please setup your Default Location!'
EXEC sp_addmessage 120021,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120022) EXEC sp_dropmessage 120022, 'us_english'	
SET @strmessage = 'The account id provided is not a valid account of category "AR Account".'
EXEC sp_addmessage 120022,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120023) EXEC sp_dropmessage 120023, 'us_english'	
SET @strmessage = 'The account id provided is not a valid account of category "Undeposited Funds".'
EXEC sp_addmessage 120023,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120024) EXEC sp_dropmessage 120024, 'us_english'	
SET @strmessage = 'The account id provided is not a valid account of category "Customer Prepayments".'
EXEC sp_addmessage 120024,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120025) EXEC sp_dropmessage 120025, 'us_english'	
SET @strmessage = 'The customer Id provided does not exists!'
EXEC sp_addmessage 120025,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120026) EXEC sp_dropmessage 120026, 'us_english'	
SET @strmessage = 'The customer provided is not active!'
EXEC sp_addmessage 120026,11,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120027) EXEC sp_dropmessage 120027, 'us_english'	
SET @strmessage = 'The company location Id provided does not exists!'
EXEC sp_addmessage 120027,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120028) EXEC sp_dropmessage 120028, 'us_english'	
SET @strmessage = 'The company location provided is not active!'
EXEC sp_addmessage 120028,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120029) EXEC sp_dropmessage 120029, 'us_english'	
SET @strmessage = 'The entity Id provided does not exists!'
EXEC sp_addmessage 120029,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120030) EXEC sp_dropmessage 120030, 'us_english'	
SET @strmessage = 'The currency Id provided does not exists!'
EXEC sp_addmessage 120030,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120031) EXEC sp_dropmessage 120031, 'us_english'	
SET @strmessage = 'There is no setup for default currency in the Company Configuration!'
EXEC sp_addmessage 120031,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120032) EXEC sp_dropmessage 120032, 'us_english'	
SET @strmessage = 'The payment method Id provided does not exists!'
EXEC sp_addmessage 120032,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120033) EXEC sp_dropmessage 120033, 'us_english'	
SET @strmessage = 'The payment method Id provided does not exists!'
EXEC sp_addmessage 120033,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120034) EXEC sp_dropmessage 120034, 'us_english'	
SET @strmessage = 'The payment method provided is not active.'
EXEC sp_addmessage 120034,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120035) EXEC sp_dropmessage 120035, 'us_english'	
SET @strmessage = 'This will create a prepayment which has not been allowed!'
EXEC sp_addmessage 120035,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120036) EXEC sp_dropmessage 120036, 'us_english'	
SET @strmessage = 'Posted invoice cannot be deleted!'
EXEC sp_addmessage 120036,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120037) EXEC sp_dropmessage 120037, 'us_english'	
SET @strmessage = 'Duplicating of Transport Delivery Invoice type is not allowed.'
EXEC sp_addmessage 120037,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120038) EXEC sp_dropmessage 120038, 'us_english'	
SET @strmessage = 'There are items that will exceed the contract quantity.'
EXEC sp_addmessage 120038,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120039) EXEC sp_dropmessage 120039, 'us_english'	
SET @strmessage = 'There are items that will exceed the shipped quantity.'
EXEC sp_addmessage 120039,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120040) EXEC sp_dropmessage 120040, 'us_english'	
SET @strmessage = 'There are items that will exceed the ordered quantity.'
EXEC sp_addmessage 120040,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120041) EXEC sp_dropmessage 120041, 'us_english'	
SET @strmessage = 'Invalid Quote Page ID.'
EXEC sp_addmessage 120041,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120042) EXEC sp_dropmessage 120042, 'us_english'	
SET @strmessage = 'Some of the customers doesn''t have Terms setup.'
EXEC sp_addmessage 120042,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120043) EXEC sp_dropmessage 120043, 'us_english'	
SET @strmessage = 'Start Date is Required.'
EXEC sp_addmessage 120043,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120044) EXEC sp_dropmessage 120044, 'us_english'	
SET @strmessage = 'End Date is Required.'
EXEC sp_addmessage 120044,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120045) EXEC sp_dropmessage 120045, 'us_english'	
SET @strmessage = 'Cannot delete posted payment!'
EXEC sp_addmessage 120045,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120046) EXEC sp_dropmessage 120046, 'us_english'	
SET @strmessage = 'Payment has already been created for this Invoice!'
EXEC sp_addmessage 120046,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120047) EXEC sp_dropmessage 120047, 'us_english'	
SET @strmessage = 'Invoice Id is required.'
EXEC sp_addmessage 120047,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120048) EXEC sp_dropmessage 120048, 'us_english'	
SET @strmessage = 'Invalid User Id.'
EXEC sp_addmessage 120048,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120049) EXEC sp_dropmessage 120049, 'us_english'	
SET @strmessage = 'Contract does not exist.'
EXEC sp_addmessage 120049,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120050) EXEC sp_dropmessage 120050, 'us_english'	
SET @strmessage = 'UOM does not exist.'
EXEC sp_addmessage 120050,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120051) EXEC sp_dropmessage 120051, 'us_english'	
SET @strmessage = 'Sales Order already closed.'
EXEC sp_addmessage 120051,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120052) EXEC sp_dropmessage 120052, 'us_english'	
SET @strmessage = 'Cannot process Sales Order with zero(0) amount.'
EXEC sp_addmessage 120052,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120053) EXEC sp_dropmessage 120053, 'us_english'	
SET @strmessage = 'Process To Invoice Failed. There is no item to process to Invoice.'
EXEC sp_addmessage 120053,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120054) EXEC sp_dropmessage 120054, 'us_english'	
SET @strmessage = 'Shipping Failed. There is no shippable item on this sales order.'
EXEC sp_addmessage 120054,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120055) EXEC sp_dropmessage 120055, 'us_english'	
SET @strmessage = 'Failed to unship Sales Order. Unpost this Shipment Record first: %s'
EXEC sp_addmessage 120055,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120056) EXEC sp_dropmessage 120056, 'us_english'	
SET @strmessage = 'Tax Code %s does not have a Sales Account!'
EXEC sp_addmessage 120056,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120057) EXEC sp_dropmessage 120057, 'us_english'	
SET @strmessage = '%s is not a valid calculation method!'
EXEC sp_addmessage 120057,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120058) EXEC sp_dropmessage 120058, 'us_english'	
SET @strmessage = 'Payment on %s is over the transaction''s amount due.'
EXEC sp_addmessage 120058,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120059) EXEC sp_dropmessage 120059, 'us_english'	
SET @strmessage = 'Payment of %s for invoice will cause an under payment.'
EXEC sp_addmessage 120059,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120060) EXEC sp_dropmessage 120060, 'us_english'	
SET @strmessage = 'Payment of %s for invoice will cause an overpayment.'
EXEC sp_addmessage 120060,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120061) EXEC sp_dropmessage 120061, 'us_english'	
SET @strmessage = 'Positive payment amount is not allowed for invoice of type %s.'
EXEC sp_addmessage 120061,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120062) EXEC sp_dropmessage 120062, 'us_english'	
SET @strmessage = 'There account id provided is not a valid account of category "AR Account".'
EXEC sp_addmessage 120062,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120063) EXEC sp_dropmessage 120063, 'us_english'	
SET @strmessage = 'There is no Undeposited Funds account setup under Company Location - %s.'
EXEC sp_addmessage 120063,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120064) EXEC sp_dropmessage 120064, 'us_english'	
SET @strmessage = 'There account id provided is not a valid account of category "Undeposited Funds".'
EXEC sp_addmessage 120064,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120065) EXEC sp_dropmessage 120065, 'us_english'	
SET @strmessage = 'There is no Customer Prepaid account setup under Company Location - %s.'
EXEC sp_addmessage 120065,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120066) EXEC sp_dropmessage 120066, 'us_english'	
SET @strmessage = 'There account id provided is not a valid account of category "Customer Prepayments".'
EXEC sp_addmessage 120066,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120067) EXEC sp_dropmessage 120067, 'us_english'	
SET @strmessage = 'There is no setup for default currency in the Company Configuration.'
EXEC sp_addmessage 120067,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120068) EXEC sp_dropmessage 120068, 'us_english'	
SET @strmessage = '%s is not a valid transaction type!'
EXEC sp_addmessage 120068,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120069) EXEC sp_dropmessage 120069, 'us_english'	
SET @strmessage = '%s is not a valid invoice type!'
EXEC sp_addmessage 120069,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120070) EXEC sp_dropmessage 120070, 'us_english'	
SET @strmessage = 'The payment method provided is not active!'
EXEC sp_addmessage 120070,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120071) EXEC sp_dropmessage 120071, 'us_english'	
SET @strmessage = 'This will create a overpayment which has not been allowed!'
EXEC sp_addmessage 120071,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120072) EXEC sp_dropmessage 120072, 'us_english'	
SET @strmessage = 'Unable to duplicate %s Invoice Type.'
EXEC sp_addmessage 120072,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120073) EXEC sp_dropmessage 120073, 'us_english'	
SET @strmessage = 'Cannot process Sales Order with zero(0) amount.'
EXEC sp_addmessage 120073,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120074) EXEC sp_dropmessage 120074, 'us_english'	
SET @strmessage = 'Commission Schedule %s was already calculated for this date.'
EXEC sp_addmessage 120074,16,@strmessage,'us_english','False'

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120075) EXEC sp_dropmessage 120075, 'us_english'	
SET @strmessage = 'Transaction with Invoice Number - %s is already existing.'
EXEC sp_addmessage 120075,16,@strmessage,'us_english','False' 

IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120076) EXEC sp_dropmessage 120076, 'us_english'     
SET @strmessage = 'Adding lot tracked item directly to invoice is not allowed.'
EXEC sp_addmessage 120076,16,@strmessage,'us_english','False' 
   
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120077) EXEC sp_dropmessage 120077, 'us_english'     
SET @strmessage = 'Duplicating of CF Tran Invoice type is not allowed.'
EXEC sp_addmessage 120077,16,@strmessage,'us_english','False'  
  
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120078) EXEC sp_dropmessage 120078, 'us_english'    
SET @strmessage = 'Duplicating of CF Invoice Invoice type is not allowed.'
EXEC sp_addmessage 120078,16,@strmessage,'us_english','False' 
 
IF EXISTS(SELECT 1 FROM sys.messages WHERE message_id = 120079) EXEC sp_dropmessage 120079, 'us_english'    
SET @strmessage = 'Duplicating of Meter Billing Invoice type is not allowed.'
EXEC sp_addmessage 120079,16,@strmessage,'us_english','False' 
