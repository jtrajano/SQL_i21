CREATE TRIGGER dbo.trgCMInsertUpdateResponsiblePartTaskDetail
   ON  tblCMResponsiblePartyTaskDetail
   AFTER  INSERT,UPDATE
AS 
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @i INT

	SELECT @i=i.intTaskDetailId FROM inserted i

	EXEC uspCMSyncBankDepositTaskDetail @i
    -- Insert statements for trigger here
END
GO