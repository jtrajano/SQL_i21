CREATE PROCEDURE uspMFUpdateBondStatus (@strReceiptNumber NVARCHAR(50))
AS
UPDATE tblMFLotInventory
SET intBondStatusId = 5
WHERE strReceiptNumber = @strReceiptNumber

