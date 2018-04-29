CREATE PROCEDURE [dbo].[uspSMTransactionApproved]
 @type NVARCHAR(MAX),
  @recordId INT
AS
BEGIN
		DECLARE @intToEntityId			INT
		DECLARE @intToCompanyId			INT
		DECLARE @strToTransactionType	NVARCHAR(100)
		DECLARE @strInsert				NVARCHAR(100)
		 
		 SELECT 
		 @strToTransactionType	 = TT.strTransactionType	 
		,@intToCompanyId		 = TC.intToCompanyId
		,@intToEntityId			 = TC.intEntityId
		,@strInsert				 = TC.strInsert
		FROM tblSMInterCompanyTransactionConfiguration TC 
		JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
		WHERE TT.strTransactionType ='Purchase Contract'

		IF @type = 'ContractManagement.view.Contract' OR @type = 'ContractManagement.view.Amendments'
		BEGIN
			DECLARE @intTransactionId INT, @intApprovalId INT

			SELECT  @intTransactionId	=	intTransactionId FROM tblSMTransaction WHERE intRecordId = @recordId
			SELECT	TOP 1	@intApprovalId	=	intApprovalId FROM tblSMApproval WHERE strStatus = 'Approved'  AND intTransactionId  = @intTransactionId ORDER BY 1 DESC

			BEGIN TRY
					EXEC	uspCTContractApproved @recordId,@intApprovalId,NULL,1
					
					IF @strToTransactionType ='Purchase Contract' AND @strInsert='Insert on Approval'
					BEGIN
						EXEC uspCTContractPopulateStgXML @recordId,@intToEntityId,@strToTransactionType,@intToCompanyId	
					END

			END TRY
			BEGIN CATCH
			END CATCH
		RETURN
	END

 RETURN
END