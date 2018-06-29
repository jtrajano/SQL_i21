CREATE PROCEDURE [dbo].[uspGLCreateImportLogDetail]
	(@id INT,@msg VARCHAR(200),@postDate DATE,@journal VARCHAR(10),@strPeriod VARCHAR(10)='', @source VARCHAR(10)='',@sourceno VARCHAR(10)='')
AS
BEGIN
	SET NOCOUNT ON;
	INSERT INTO tblGLCOAImportLogDetail(strEventDescription,intImportLogId,dtePostDate,strPeriod,strSourceSystem,strSourceNumber,strJournalId)
	VALUES(@msg,@id,@postDate,@strPeriod,@source,@sourceno,@journal)
END
