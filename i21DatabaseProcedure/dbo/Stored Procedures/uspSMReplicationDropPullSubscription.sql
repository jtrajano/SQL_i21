CREATE PROCEDURE [dbo].[uspSMReplicationDropPullSubscription]
  @MainServer nvarchar(50),
  @MainPublication nvarchar(50),
  @MainDb nvarchar(50)
 AS
 BEGIN

 exec sp_droppullsubscription
      @publisher = @MainServer,
	  @publication = @MainPublication,
	  @publisher_db = @MainDb

 END