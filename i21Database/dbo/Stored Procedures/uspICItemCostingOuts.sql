/*
	Used to process outgoing stocks. 
*/

CREATE PROCEDURE [dbo].[uspICItemCostingOuts]
	@ItemCosting ItemCostingTableType READONLY
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF


