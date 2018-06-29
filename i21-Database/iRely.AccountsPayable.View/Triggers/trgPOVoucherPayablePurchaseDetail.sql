CREATE TRIGGER [dbo].[trgPOVoucherPayablePurchaseDetail]
    ON [dbo].[tblPOPurchaseDetail]
    AFTER DELETE
    AS
    BEGIN
		--THIS TRIGGER WILL MAINTAIN THE tblAPVoucherPayable References
        SET NoCount ON
		DECLARE @poId INT;
		SELECT TOP 1 @poId = intPurchaseId FROM deleted
		EXEC uspAPVoucherPayablePO @poId, 0
    END
