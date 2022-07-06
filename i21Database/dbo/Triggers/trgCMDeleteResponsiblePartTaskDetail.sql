CREATE TRIGGER dbo.trgCMDeleteResponsiblePartTaskDetail
   ON  tblCMResponsiblePartyTaskDetail
   instead of DELETE
AS 
BEGIN
	
	SET NOCOUNT ON;
	DECLARE @i INT

	IF EXISTS( SELECT TOP 1 1 From deleted d JOIN vyuCMResponsiblePartyTaskDetail e on e.intTaskDetailId = d.intTaskDetailId
	and ysnPosted = 1 )
	BEGIN 
		 RAISERROR ('Cannot delete posted transaction', 16,1);  
	END
	ELSE
	BEGIN

		DELETE A FROM tblCMBankTransaction A JOIN tblCMResponsiblePartyTaskDetail B  ON B.intTransactionId = A.intTransactionId
		JOIN deleted D on D.intTaskDetailId = B.intTaskDetailId

		DELETE A FROM tblCMResponsiblePartyTaskDetail A JOIN DELETED D ON D.intTaskDetailId= A.intTaskDetailId
	END

    -- Insert statements for trigger here
END
GO