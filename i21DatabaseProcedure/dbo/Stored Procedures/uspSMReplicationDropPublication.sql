CREATE PROCEDURE [dbo].[uspSMReplicatonDropPublication]
  @publicationName nvarchar(50)
 AS
 BEGIN

 --Stopping Logreader agent
 DECLARE @helplogreaderresult Table(
  id Int, 
  name sysname, 
  publisher_security_mode Int,
  publisher_login sysname, 
  publisher_password sysname, 
  job_id nvarchar(max),
  job_login sysname,
  job_password sysname
 );


 INSERT INTO @helplogreaderresult
 EXEC sp_helplogreader_agent


 DECLARE @job_name sysname
 SELECT @job_name = name from @helplogreaderresult

 IF  EXISTS (SELECT @job_name)
  EXEC  msdb.dbo.sp_stop_job @job_name


 --Dropping Existing Subscription & Publication

 EXEC sp_dropsubscription @publication=  @publicationName  
   , @article=  'all' 
   ,  @subscriber= 'all'  


 EXEC sp_droppublication @publication = @publicationName

 END