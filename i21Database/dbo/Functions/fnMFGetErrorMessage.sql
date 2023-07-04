CREATE FUNCTION [dbo].[fnMFGetErrorMessage] 
(
	@intMessageId AS INT 
)
/****************************************************************
	Title: Manufacturing Error Messages
	Description: This was created to have a flexible and standard error message format similar to Inventory Module.
	JIRA: MFG-5093
	Created By: Jonathan Valenzuela
	Date: 07/04/2023
*****************************************************************/
RETURNS NVARCHAR(2000) 
AS 
BEGIN 
	DECLARE @strMessage AS NVARCHAR(2000)

	SET @strMessage = CASE	WHEN @intMessageId = 01 THEN 'MFG-01: No Consumed Lot found. Please check if the Staging and Production Staging Location are correct on MFG Process or check if the MFG Attribute Process ''All Mandatory Input Items for Consumption'' was set to True.'
							 /* Below sample for constructing message with parameters %s = p1 -> p10. */
						  -- WHEN @intMessageId = 02 THEN 'Item: %s, Lot: %s, Qty: %s, Cost: %s'
					  END 

	RETURN @strMessage
END