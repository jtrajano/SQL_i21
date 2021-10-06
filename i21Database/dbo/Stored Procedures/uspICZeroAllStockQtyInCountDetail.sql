
CREATE PROCEDURE [dbo].[uspICZeroAllStockQtyInCountDetail]
	@intInventoryCountId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS ON

UPDATE d
SET d.dblPhysicalCount = 0 
FROM 
	tblICInventoryCountDetail d
WHERE
	d.intInventoryCountId = @intInventoryCountId