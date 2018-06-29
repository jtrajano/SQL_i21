CREATE TRIGGER [dbo].[trgCTAfterUpdateAmendmentApproval] ON [dbo].[tblCTAmendmentApproval] 
FOR UPDATE
AS
	INSERT INTO [tblCTAmendmentApprovalLog] (dtmHistoryCreated,strDataField,ysnOldValue,ysnNewValue)
	SELECT 
		 dtmHistoryCreated = GETDATE()
		,strDataField      = i.strDataField +'- Amendment'
		,ysnOldValue	   = d.ysnAmendment
		,ysnNewValue	   = i.ysnAmendment
	FROM deleted d 
	JOIN inserted i ON i.intAmendmentApprovalId = d.intAmendmentApprovalId
	WHERE  i.ysnAmendment != d.ysnAmendment
	
	UNION

	SELECT 
		 dtmHistoryCreated = GETDATE()
		,strDataField	   = i.strDataField +'- Approval'
		,ysnOldValue	   = d.ysnApproval
		,ysnNewValue	   = i.ysnApproval
	FROM deleted d 
	JOIN inserted i ON i.intAmendmentApprovalId = d.intAmendmentApprovalId
	WHERE  i.ysnApproval != d.ysnApproval