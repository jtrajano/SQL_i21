/*
	Used to validate the items when doing a post.

	These are the validations performed by this stored procedure
	1. Check if item id is valid
	2. Check if location is valid
	3. Check for available stock quantity (for outbound stock)
	4. Check if negative stock is allowed (for outbound stock)

	These are the validations outside this stored procedure. 
	1. Check for closed period. 
	2. Check for invalid G/L Account Ids - Do this inside the uspICPostCosting
	
*/

CREATE PROCEDURE [dbo].[uspICValidateCostingOnPost]
	@ItemsToValidate ItemCostingTableType READONLY
AS



SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF
