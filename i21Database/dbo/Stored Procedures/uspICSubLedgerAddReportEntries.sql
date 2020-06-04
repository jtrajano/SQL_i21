CREATE PROCEDURE [dbo].[uspICSubLedgerAddReportEntries]
  @SubLedgerReportEntries SubLedgerReportUdt READONLY,          -- The raw data that will be transformed and inserted into the actual report table
  @strSourceTransactionType NVARCHAR(100),                      -- Transaction name similar to tblICInventoryTransactionType. Ex. Inventory Adjustment, etc.
  @intUserId AS INT NULL                                        -- Security User Id (optional) 
AS

/*
	Summary:
		This stored procedure is called when posting the transaction. 
		This inserts the details of this transaction to the sub-ledger reporting table.
*/

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--- <!--------- TBD -------------->