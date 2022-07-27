CREATE PROCEDURE [dbo].[uspGRUnpostAdjustSettlements]
(
	@intAdjustSettlementId INT
)
AS
BEGIN
DECLARE @ErrMsg AS NVARCHAR(MAX)
DECLARE @AdjustSettlementsStagingTable AS AdjustSettlementsStagingTable
DECLARE @ysnTransferSettlement BIT
DECLARE @ysnPosted BIT
DECLARE @strAdjustSettlementNumber NVARCHAR(40)
DECLARE @ysnTransferSettlementExists BIT

BEGIN TRANSACTION
BEGIN TRY


--UPDATE tblGRAdjustSettlements SET ysnPosted = 0 WHERE intAdjustSettlementId = @intAdjustSettlementId

--GL unposting should follow

SELECT SCOPE_IDENTITY()

Post_Transaction:
COMMIT TRANSACTION

END TRY
BEGIN CATCH
ROLLBACK TRANSACTION
SET @ErrMsg = ERROR_MESSAGE()
RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH

END