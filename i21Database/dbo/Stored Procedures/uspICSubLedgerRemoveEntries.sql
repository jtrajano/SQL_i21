CREATE PROCEDURE [dbo].[uspICSubLedgerRemoveEntries]
  @strSourceTransactionType NVARCHAR(100),                      -- Transaction form ex: Invoice, Inventory Adjustment, etc.
  @strSourceTransactionId INT,                                  -- The transaction no to remove
  @intUserId AS INT NULL                                        -- Security User Id (optional) 
AS

/*
	Summary:
		This stored procedure is called when unposting the transaction. 
		This removes the details of this transaction from the sub-ledger reporting table.
*/

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

--- <!--------- TBD -------------->