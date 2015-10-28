CREATE PROCEDURE [dbo].[uspLGDeleteBill]
	@intWarehouseInstructionHeaderId AS INT
	,@intUserId AS INT
	,@intBillId AS INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000);
DECLARE @ErrorSeverity INT;
DECLARE @ErrorState INT;

DECLARE @ysnPosted as BIT;

BEGIN TRY

	SELECT @ysnPosted = A.ysnPosted FROM tblAPBill A WHERE A.intBillId = @intBillId
    IF (@ysnPosted = 1)
	BEGIN
		RAISERROR('Bill cannot be deleted since it is already posted', 11, 1);
		RETURN;
	END	

	UPDATE tblLGWarehouseInstructionHeader SET intBillId = NULL WHERE intWarehouseInstructionHeaderId=@intWarehouseInstructionHeaderId	
	DELETE A FROM tblAPBill A WHERE A.ysnPosted = 0 AND A.intBillId = @intBillId
END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH
