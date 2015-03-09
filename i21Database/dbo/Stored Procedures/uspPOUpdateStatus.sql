CREATE PROCEDURE [dbo].[uspPOUpdateStatus]
    @poId int,
    @status int
AS
BEGIN

    UPDATE A
        SET A.intOrderStatusId = @status
    FROM tblPOPurchase A
    WHERE intPurchaseId = @poId

END
