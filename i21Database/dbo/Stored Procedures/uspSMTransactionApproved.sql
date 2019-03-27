CREATE PROCEDURE [dbo].[uspSMTransactionApproved]
  @type NVARCHAR(MAX),
  @recordId INT
AS
BEGIN
	DECLARE @intTransactionApprovedLogId INT

	INSERT INTO [tblCTSMTransactionApprovedLog](strType,intRecordId,dtmLog)
	SELECT @type,@recordId,GETDATE()

	SELECT @intTransactionApprovedLogId = SCOPE_IDENTITY()

    IF @type = 'ContractManagement.view.Contract' OR @type = 'ContractManagement.view.Amendments'
		BEGIN
			DECLARE @intTransactionId INT, @intApprovalId INT,@intScreenId INT,@ysnOnceApproved BIT

			SELECT @intScreenId = intScreenId FROM tblSMScreen WHERE strNamespace = 'ContractManagement.view.Contract'  

			SELECT  @intTransactionId	=	intTransactionId,@ysnOnceApproved = ysnOnceApproved FROM tblSMTransaction WHERE intRecordId = @recordId AND intScreenId = @intScreenId

			SELECT	TOP 1	@intApprovalId	=	intApprovalId FROM tblSMApproval WHERE strStatus = 'Approved'  AND intTransactionId  = @intTransactionId ORDER BY 1 DESC

			BEGIN TRY
				UPDATE [tblCTSMTransactionApprovedLog] SET ysnOnceApproved = @ysnOnceApproved WHERE intTransactionApprovedLogId = @intTransactionApprovedLogId

				EXEC	uspCTContractApproved @recordId,@intApprovalId,NULL,1

				UPDATE [tblCTSMTransactionApprovedLog] SET strErrMsg = 'Success' WHERE intTransactionApprovedLogId = @intTransactionApprovedLogId
			END TRY
			BEGIN CATCH
				UPDATE [tblCTSMTransactionApprovedLog] SET strErrMsg = ERROR_MESSAGE() WHERE intTransactionApprovedLogId = @intTransactionApprovedLogId
			END CATCH
		RETURN
	END

 RETURN
END