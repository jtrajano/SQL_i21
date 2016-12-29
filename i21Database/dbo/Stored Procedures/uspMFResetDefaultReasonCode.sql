CREATE PROCEDURE uspMFResetDefaultReasonCode
	@intReasonTypeId INT
	,@intTransactionTypeId INT
	,@intReasonCodeId INT
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

IF @intTransactionTypeId = 0
BEGIN
	UPDATE tblMFReasonCode
	SET ysnDefault = 0
	WHERE intReasonTypeId = @intReasonTypeId
		AND intReasonCodeId <> @intReasonCodeId
END
ELSE
BEGIN
	UPDATE tblMFReasonCode
	SET ysnDefault = 0
	WHERE intReasonTypeId = @intReasonTypeId
		AND intReasonCodeId <> @intReasonCodeId
		AND intTransactionTypeId = @intTransactionTypeId
END
