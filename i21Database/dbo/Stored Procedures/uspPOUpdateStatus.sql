CREATE PROCEDURE [dbo].[uspPOUpdateStatus]
    @poId int,
    @status int
AS
BEGIN

    UPDATE A
        SET A.intOrderStatusId = @status
    FROM tblPOPurchase
    WHERE intPurchaseId = @poId

END
