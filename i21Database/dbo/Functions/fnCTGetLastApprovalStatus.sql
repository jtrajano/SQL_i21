CREATE FUNCTION [dbo].[fnCTGetLastApprovalStatus]
(
	@intContractHeaderId INT
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	 @strStatus 	  NVARCHAR(MAX),
			 @intScreenId	  INT

    SELECT @intScreenId = intScreenId FROM tblSMScreen  WHERE strNamespace = 'ContractManagement.view.Contract'

	IF EXISTS(SELECT TOP 1 1 FROM tblSMApproval WHERE intScreenId = @intScreenId)
	BEGIN
	   SELECT @strStatus = strApprovalStatus 
	   FROM 
	   (
	       SELECT	ROW_NUMBER() OVER (PARTITION BY TR.intRecordId ORDER BY AP.intApprovalId DESC) intRowNum,
				AP.strStatus AS strApprovalStatus 
		  FROM	tblSMApproval		AP
		  JOIN	tblSMTransaction	TR	ON	TR.intTransactionId =	AP.intTransactionId
								     AND	TR.intRecordId =   @intContractHeaderId
		  JOIN	tblSMScreen			SC	ON	SC.intScreenId		=	TR.intScreenId
		  WHERE	SC.strNamespace IN( 'ContractManagement.view.Contract',
								'ContractManagement.view.Amendments')
	   ) t
	   WHERE intRowNum = 1
	END

	RETURN @strStatus;	
END