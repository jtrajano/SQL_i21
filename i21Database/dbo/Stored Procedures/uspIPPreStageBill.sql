CREATE PROCEDURE uspIPPreStageBill (
	@strBillId NVARCHAR(MAX)
	,@strRowState NVARCHAR(50) = NULL
	,@intUserId INT = NULL
	)
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @tblAPBill TABLE (intBillId INT)
	DECLARE @intBillId INT

	DELETE
	FROM @tblAPBill

	INSERT INTO @tblAPBill (intBillId)
	SELECT Item Collate Latin1_General_CI_AS
	FROM [dbo].[fnSplitString](@strBillId, ',')

	SELECT @intBillId = MIN(intBillId)
	FROM @tblAPBill

	WHILE @intBillId IS NOT NULL
	BEGIN
		-- Voucher exists / feed sent
		IF NOT EXISTS (
				SELECT 1
				FROM tblAPBillPreStage
				WHERE intBillId = @intBillId
					AND (
						strERPVoucherNo IS NOT NULL
						OR intStatusId IN (
							2
							,4
							,6
							)
						)
				)
		BEGIN
			DELETE
			FROM tblAPBillPreStage
			WHERE intBillId = @intBillId
				AND ISNULL(intStatusId, 1) = 1
				AND strERPVoucherNo IS NULL
		END

		INSERT INTO dbo.tblAPBillPreStage (
			intBillId
			,strRowState
			,intUserId
			)
		SELECT @intBillId
			,@strRowState
			,@intUserId

		SELECT @intBillId = MIN(intBillId)
		FROM @tblAPBill
		WHERE intBillId > @intBillId
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH
