﻿CREATE PROCEDURE [dbo].[uspSMTransactionApproved]
  @type NVARCHAR(MAX),
  @recordId INT
AS
BEGIN

    IF @type = 'ContractManagement.view.Contract' OR @type = 'ContractManagement.view.Amendments'
		BEGIN
			DECLARE @intTransactionId INT, @intApprovalId INT

			SELECT  @intTransactionId	=	intTransactionId FROM tblSMTransaction WHERE intRecordId = @recordId
			SELECT	TOP 1	@intApprovalId	=	intApprovalId FROM tblSMApproval WHERE strStatus = 'Approved'  AND intTransactionId  = @intTransactionId ORDER BY 1 DESC

			EXEC	uspCTContractApproved @recordId,@intApprovalId

		RETURN
	END

 RETURN
END