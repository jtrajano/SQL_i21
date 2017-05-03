﻿/*
	This function holds all the sql-related error message under Inventory module. 
	By passing an id, it will return the string value of the error messsage. 

	This is used in conjunction with uspICRaiseError. 
*/
CREATE FUNCTION fnICGetErrorMessage (
	@msgId AS INT 
)
RETURNS NVARCHAR(2000) 
AS 
BEGIN 
	DECLARE @msg AS NVARCHAR(2000)

	SET @msg = 
	CASE	
		WHEN @msgId = 80001 THEN 'Item id is invalid or missing.'
		WHEN @msgId = 80002 THEN 'Item Location is invalid or missing for %s.'
		WHEN @msgId = 80003 THEN 'Negative stock quantity is not allowed for %s in %s.'
		WHEN @msgId = 80004 THEN 'Unable to generate the Inventory Receipt. An error stopped the process from Purchase Order to Inventory Receipt.'
		WHEN @msgId = 80005 THEN 'Please specify the lot numbers for %s.'
		WHEN @msgId = 80006 THEN 'The Qty to Receive for %s is %f. Total Lot Quantity is %f. The difference is %f.'
		WHEN @msgId = 80007 THEN 'Not enough stocks for %s. Reserved stocks is %f while On Hand Qty is %f.'
		WHEN @msgId = 80008 THEN '%s is missing a GL account setup for %s account category.'
		WHEN @msgId = 80009 THEN 'Unable to generate the serial lot number for %s.'
		WHEN @msgId = 80010 THEN 'Failed to process the lot number for %s. It may have been used on a different sub-location or storage location.'
		WHEN @msgId = 80011 THEN 'Lot %s exists in %s. Cannot retrieve in %s. Change the receiving UOM to %s or create a new lot.'
		WHEN @msgId = 80012 THEN 'The Weight UOM for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
		WHEN @msgId = 80013 THEN 'The Sub-Location for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
		WHEN @msgId = 80014 THEN 'The Storage Location for %s cannot be changed from %s to %s because a stock from it has been used from a different transaction.'
		WHEN @msgId = 80015 THEN '%s with lot number %s needs to have a weight.'
		WHEN @msgId = 80016 THEN 'Please correct the UOM. The UOM for %s in PO is %s. It is now using %s in the Inventory Receipt.'
		WHEN @msgId = 80017 THEN 'Please correct the unit qty in UOM %s on %s.'
		WHEN @msgId = 80018 THEN 'The lot number %s is already used in %s.'
		WHEN @msgId = 80019 THEN 'Please check for duplicate lot numbers. The lot number %s is used more than once in item %s on %s.'
		WHEN @msgId = 80020 THEN 'Invalid Lot.'
		WHEN @msgId = 80021 THEN 'Invalid Item.'
		WHEN @msgId = 80022 THEN 'The status of %s is Discontinued.'
		WHEN @msgId = 80023 THEN 'Missing costing method setup for item %s.'
		WHEN @msgId = 80024 THEN 'Lot status for %s for item %s is going to be updated more than once. Please remove the duplicate.'
		WHEN @msgId = 80025 THEN 'Recap is not applicable for this type of transaction.'
		WHEN @msgId = 80026 THEN 'Item %s is not available on location %s.'
		WHEN @msgId = 80027 THEN 'The stock on hand is outdated for %s. Please review your quantity adjustments after the system reloads the latest stock on hand.'
		WHEN @msgId = 80028 THEN 'The lot expiry dates are outdated for %s. Please review your quantity adjustments after the system reloads the latest expiry dates.'
		WHEN @msgId = 80029 THEN 'Unable to generate the Inventory Shipment. An error stopped the process from Sales Order to Inventory Shipment.'
		WHEN @msgId = 80030 THEN 'The lot status is invalid.'
		-- OBSOLETE: WHEN @msgId = 80031 THEN 'Unable to generate Lot Number. Please ask your local administrator to check the starting numbers setup.'
		WHEN @msgId = 80032 THEN 'Internal Error. The source transaction type provided is invalid or not supported.'
		WHEN @msgId = 80033 THEN 'Internal Error. The source transaction id is invalid.'
		WHEN @msgId = 80034 THEN 'Internal Error. The new expiry date is invalid.'
		WHEN @msgId = 80035 THEN 'Internal Error. The Adjust By Quantity is required.'
		WHEN @msgId = 80036 THEN 'Internal Error. The new sub-location is invalid.'
		WHEN @msgId = 80037 THEN 'Internal Error. The new storage location is invalid.'
		-- OBSOLETE: WHEN @msgId = 80038 THEN 'A consigned or custodial item is no longer available. Unable to continue and unpost the transaction.'
		WHEN @msgId = 80039 THEN 'The UOM is missing on %s.'
		WHEN @msgId = 80040 THEN 'Please specify the Adjust Qty By or New Quantity on %s.'
		-- OBSOLETE: WHEN @msgId = 80041 THEN 'Custody or storage for %s is not yet supported. It is currently limited to lot-tracked items.'
		-- OBSOLETE: WHEN @msgId = 80042 THEN 'Cannot have the same item and weight UOM. Please remove the weight UOM for %s with lot number %s.'
		WHEN @msgId = 80043 THEN 'Unable to generate the Inventory Receipt. An error stopped the process from Purchase Contract to Inventory Receipt.'
		WHEN @msgId = 80044 THEN 'Unable to generate the Inventory Receipt. An error stopped the process from Transfer Order to Inventory Receipt.'
		WHEN @msgId = 80045 THEN 'Recap is not applicable when doing an inventory transfer for the same location.'
		WHEN @msgId = 80046 THEN 'Unable to generate the Inventory Receipt. An error stopped the process from Inbound Shipment to Inventory Receipt.'
		WHEN @msgId = 80047 THEN 'The Qty to Ship for %s is %f. Total Lot Quantity is %f. The difference is %f.'
		WHEN @msgId = 80048 THEN 'Item UOM is invalid or missing.'
		WHEN @msgId = 80049 THEN 'Item %s is missing a Stock Unit. Please check the Unit of Measure setup.'
		WHEN @msgId = 80050 THEN 'Unable to calculate %s as %s is not found in %s > UOM setup.'
		WHEN @msgId = 80051 THEN 'Cyclic situation found. Unable to compute surcharge because %s depends on %s and vice-versa.'
		WHEN @msgId = 80052 THEN 'Unable to compute the surcharge for %s. The On Cost for the surcharge could be missing. Also, the Vendor for both the surcharge and On Cost must match.'
		-- OBSOLETE: WHEN @msgId = 80053 THEN 'Unable to continue. Cost allocation is by Weight but stock unit for %s is not a weight type.'
		WHEN @msgId = 80054 THEN 'Unable to unpost the %s. The %s was %s.'
		WHEN @msgId = 80055 THEN 'Data not found. Unable to create the Inventory Receipt.'
		WHEN @msgId = 80056 THEN 'Unable to Unreceive. The inventory receipt has a voucher in %s.'
		WHEN @msgId = 80057 THEN 'Split Lot requires a negative Adjust Qty on %s to split stocks from it.'
		WHEN @msgId = 80058 THEN 'Merge Lot requires a negative Adjust Qty on %s as stock for the merge.'
		WHEN @msgId = 80059 THEN 'Lot Move requires a negative Adjust Qty on %s as stock for the move.'
		WHEN @msgId = 80060 THEN 'Data not found. Unable to create the Inventory Transfer.'
		WHEN @msgId = 80061 THEN 'Unable to generate the Inventory Transfer. An error stopped the creation of the inventory transfer.'
		WHEN @msgId = 80062 THEN 'Cost adjustment cannot continue. Unable to find the cost bucket for %s that was posted in %s.'
		WHEN @msgId = 80063 THEN 'Unable to unpost because %s has a cost adjustment from %s.'
		WHEN @msgId = 80064 THEN 'The %s is both a payable and deductible to the bill of the same vendor. Please correct the Accrue or Price checkbox.'
		WHEN @msgId = 80065 THEN 'The %s is shouldered by the receipt vendor and can''t be added to the item cost. Please correct the Price or Inventory Cost checkbox.'
		WHEN @msgId = 80066 THEN 'Inventory Count is ongoing for Item %s and is locked under Location %s.'
		WHEN @msgId = 80067 THEN 'Inventory Shipment Line Item does not exist.'
		WHEN @msgId = 80068 THEN 'Item % is not a lot tracked item and cannot ship lots.'
		WHEN @msgId = 80069 THEN '% has only % available quantity. Cannot ship more than the available qty.'
		WHEN @msgId = 80070 THEN 'Delete is not allowed. %s is posted.'
		WHEN @msgId = 80071 THEN 'Cost adjustment cannot continue. Unable to find the cost bucket for the lot %s in item %s that was posted in %s.'
		WHEN @msgId = 80072 THEN 'Lot merge of %s is not allowed because it will be merged to the same lot number, location, sub location, and storage location.'
		WHEN @msgId = 80073 THEN 'Split Lot for %s is not allowed because it will be a split to the same lot number, location, sub location, and storage location.'
		WHEN @msgId = 80074 THEN 'The lot %s is assigned to the same item. Item change requires a different item.'
		WHEN @msgId = 80075 THEN 'Item %s is invalid. It must be lot tracked.'
		WHEN @msgId = 80076 THEN 'Lot move of %s is not allowed because it will be moved to the same location, sub location, and storage location.'
		WHEN @msgId = 80077 THEN 'Unable to update %s. It is posted. Please unpost it first.'
		WHEN @msgId = 80078 THEN 'Inventory variance is created. The current item valuation is %s. The new valuation is (Qty x New Average Cost) %s x %s = %s.'
		WHEN @msgId = 80079 THEN 'Item UOM for %s is invalid or missing.'
		WHEN @msgId = 80080 THEN 'Item UOM %s for %s is invalid or missing.'
		WHEN @msgId = 80081 THEN 'Net quantity mismatch. It is %f on item %s but the total net from the lot(s) is %f.'
		WHEN @msgId = 80082 THEN 'The net quantity for item %s is missing.'
		WHEN @msgId = 80083 THEN 'The new Item Location is invalid or missing for %s.'
		WHEN @msgId = 80084 THEN 'Check the Rebuild Valuation GL Snapshot. The original GL values changed when compared against the rebuild values. To check the discrepancies, run: SELECT * FROM vyuICCompareRebuildValuationSnapshot WHERE dtmRebuildDate = ''%s'''
		WHEN @msgId = 80085 THEN 'Each lotted item for %s that is going to be transferred should have a lot number specified.'
		WHEN @msgId = 80086 THEN 'Cannot post this Inventory Receipt. The transfer order "%s" was already posted in "%s".'
		WHEN @msgId = 80087 THEN 'The sub location and storage unit in %s does not match.'
		WHEN @msgId = 80088 THEN 'Vendor for Other Charge item %s is required to accrue.'
		WHEN @msgId = 80089 THEN 'The inventory shipment is already in %s. Remove the invoice first before you can unpost this shipment.'
		WHEN @msgId = 80090 THEN 'Lotted item %s should have lot(s) specified.'
		WHEN @msgId = 80091 THEN 'Unable to unpost the Inventory Shipment. The %s was billed.'
		WHEN @msgId = 80092 THEN 'The item %s is already in %s. Remove it from the Invoice first before you can modify it from the Shipment.'
		WHEN @msgId = 80093 THEN 'Stock quantity is now zero on %s in %s. Auto variance is posted to zero out its inventory valuation.'
		WHEN @msgId = 80094 THEN '%s costing method is Average Costing and it will be received in %s as Actual costing. This is not allowed to avoid bad computation of the average cost. Try receiving the stocks using Inventory Receipt instead of Transport Load.'
		WHEN @msgId = 80095 THEN 'The %s cannot be accrued to the same Shipment Customer.'
		WHEN @msgId = 80096 THEN 'Check the date on the transaction. As of %s, there is no stock available for %s in %s.'
		WHEN @msgId = 80097 THEN 'Sub Location is invalid or missing for item %s.'
		WHEN @msgId = 80098 THEN 'Storage Unit is invalid or missing for item %s.'
		WHEN @msgId = 80099 THEN 'New Quantity for item %s is required.'
		WHEN @msgId = 80100 THEN 'Cannot return the inventory receipt. %s must be posted before it can be returned.'
		WHEN @msgId = 80101 THEN 'Unable to unpost because it has a debit memo. Unpost and delete %s first before you can unpost the Inventory Return.'
		WHEN @msgId = 80102 THEN 'Unable to unpost. Charge %s has a voucher in %s.'
		WHEN @msgId = 80103 THEN 'Cannot return %s because it is a Transfer Order.'
		WHEN @msgId = 80104 THEN 'UOM Id is invalid for item %s.'
		WHEN @msgId = 80105 THEN 'Invalid Owner. %s is not configured as an Owner for %s. Please check the Item setup.'
		WHEN @msgId = 80106 THEN 'Internal Error. The Adjust By Quantity is required to be a negative value.'
		WHEN @msgId = 80107 THEN 'Unable to unpost the Inventory Transfer. The %s already have a receipt. Please remove it from the receipt "%s"'
		WHEN @msgId = 80108 THEN 'Check the return date on the transaction. Return date is %s, while %s in %s is dated %s.'
		WHEN @msgId = 80109 THEN 'Return is stopped. All of the stocks in %s that is received in %s are either sold, consumed, returned, or over-return is going to happen.'
		WHEN @msgId = 80110 THEN 'Debit Memo is no longer needed. All items have Debit Memo.'
		WHEN @msgId = 80111 THEN 'Voucher is no longer needed. All items have Voucher.'
		WHEN @msgId = 80112 THEN 'Unable to unpost the Inventory Receipt because it was returned. Please check %s.'
		-- OBSOLETE: WHEN @msgId = 80113 THEN 'Currency Id is invalid or missing.'
		WHEN @msgId = 80114 THEN 'Freight Term Id %s is invalid.'
		WHEN @msgId = 80115 THEN 'Source Type Id is invalid or missing.'
		WHEN @msgId = 80116 THEN 'Tax Group Id %s is invalid.'
		WHEN @msgId = 80117 THEN 'Item Id %s is invalid.'
		WHEN @msgId = 80118 THEN 'Contract Header Id %s is invalid.'
		WHEN @msgId = 80119 THEN 'Contract Detail Id is invalid or missing for Contract Header Id %s.'
		WHEN @msgId = 80120 THEN 'Item UOM Id is invalid or missing for item %s.'
		WHEN @msgId = 80121 THEN 'Gross/Net UOM is invalid for item %s.'
		WHEN @msgId = 80122 THEN 'Cost UOM is invalid or missing for item %s.'
		WHEN @msgId = 80123 THEN 'Lot ID %s is invalid for item %s.'
		-- OBSOLETE: WHEN @msgId = 80124 THEN 'Other Charge Item Id is invalid or missing.'
		WHEN @msgId = 80125 THEN 'Cost Method for Other Charge item %s is invalid or missing.'
		-- OBSOLETE: WHEN @msgId = 80126 THEN 'Cost Currency Id is invalid or missing for other charge item %s.'
		WHEN @msgId = 80127 THEN 'Vendor Id is invalid for other charge item %s.'
		WHEN @msgId = 80128 THEN 'Allocate Cost By is invalid or missing for other charge item %s.'
		-- OBSOLETE: WHEN @msgId = 80129 THEN 'Other Charge Item Id is required for other charges.'
		WHEN @msgId = 80130 THEN 'Lot Number is invalid or missing for item %s.'
		WHEN @msgId = 80131 THEN 'Lot Condition %s is invalid for lot %s.'
		WHEN @msgId = 80132 THEN 'Parent Lot Id %s is invalid for lot %s.'
		WHEN @msgId = 80133 THEN 'Parent Lot Number is invalid or missing for lot %s.'
		WHEN @msgId = 80134 THEN 'Receipt Type is invalid or missing.'
		WHEN @msgId = 80135 THEN 'Vendor Id is invalid or missing.'
		WHEN @msgId = 80136 THEN 'Ship From Id is invalid or missing.'
		WHEN @msgId = 80137 THEN 'Location Id is invalid or missing.'
		WHEN @msgId = 80138 THEN 'Ship Via Id %s is invalid.'
		WHEN @msgId = 80139 THEN 'Unable to repost. Item id: %s. Transaction id: %s. Batch id: %s. Account Category: %s.'
		WHEN @msgId = 80140 THEN 'Entity Id is invalid or missing for other charge item %s.'
		WHEN @msgId = 80141 THEN 'Receipt type is invalid or missing for other charge item %s.'
		WHEN @msgId = 80142 THEN 'Location Id is invalid or missing for other charge item %s.'
		WHEN @msgId = 80143 THEN 'Ship Via Id is invalid for other charge item %s.'
		WHEN @msgId = 80144 THEN 'Ship From Id is invalid or missing for other charge item %s.'
		-- OBSOLETE: WHEN @msgId = 80145 THEN 'Currency Id is invalid or missing for other charge item %s.'
		WHEN @msgId = 80146 THEN 'Entity Id is invalid or missing for lot %s.'
		WHEN @msgId = 80147 THEN 'Receipt type is invalid or missing for lot %s.'
		WHEN @msgId = 80148 THEN 'Location Id is invalid or missing for lot %s.'
		WHEN @msgId = 80149 THEN 'Ship Via Id is invalid for lot %s.'
		WHEN @msgId = 80150 THEN 'Ship From Id is invalid or missing for lot %s.'
		-- OBSOLETE: WHEN @msgId = 80151 THEN 'Currency Id is invalid or missing for lot %s.'
		WHEN @msgId = 80152 THEN 'Source Type Id is invalid or missing for lot %s.'
		WHEN @msgId = 80153 THEN 'Item Id is invalid or missing for lot %s.'
		WHEN @msgId = 80154 THEN 'Sub Location is invalid or missing for lot %s.'
		WHEN @msgId = 80155 THEN 'Storage Unit is invalid or missing for lot %s.'
		WHEN @msgId = 80156 THEN 'Item UOM Id is invalid or missing for lot %s.'
		WHEN @msgId = 80157 THEN 'Lot ID %s is invalid for lot %s.'
		WHEN @msgId = 80158 THEN 'The Qty to Return for %s is %f. Total Lot Quantity is %f. The difference is %f.'
		WHEN @msgId = 80159 THEN 'Item: %s, Qty: %s, Cost: %s'
		WHEN @msgId = 80160 THEN 'Transaction not saved. Stocks for %s will have an over-return.'
		WHEN @msgId = 80161 THEN 'Return no longer allowed. All of the stocks are returned.'
		WHEN @msgId = 80162 THEN '%s is using a foreign currency. Please check if %s has a forex rate. You may also need to review the Currency Exchange Rates and check if there is a valid forex rate from %s to %s.'
		WHEN @msgId = 80163 THEN 'Shipment for non-inventory items are not allowed.'
		WHEN @msgId = 80164 THEN 'There are no receipt items to process.'
		WHEN @msgId = 80165 THEN 'No line of business specified.'
		WHEN @msgId = 80166 THEN 'No type of data is specified.'
		WHEN @msgId = 80167 THEN 'Cannot find the transaction.'
		WHEN @msgId = 80168 THEN 'Unable to find an open fiscal year period to match the transaction date.'
		WHEN @msgId = 80169 THEN 'The transaction is already posted.'
		WHEN @msgId = 80170 THEN 'The transaction is already unposted.'	
		WHEN @msgId = 80171 THEN 'Adjusting multiple lots with the same lot number is not allowed.'
		WHEN @msgId = 80172 THEN 'You cannot %s transactions you did not create. Please contact your local administrator.'
		WHEN @msgId = 80173 THEN 'Unable to find an open fiscal year period for %s module to match the transaction date.'
		WHEN @msgId = 80174 THEN 'Unable to find a template.'
		WHEN @msgId = 80175 THEN 'Unable to create the G/L entries.'
		WHEN @msgId = 80176 THEN 'Not enough stocks for %s. Reserved stocks is %f while Lot Qty is %f.'
	END 

	RETURN @msg
END 