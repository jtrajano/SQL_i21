
CREATE PROCEDURE [dbo].[uspSMRepHelpLogReaderAgent] 
AS
BEGIN
		DECLARE @temp TABLE(
			id int,
			name nvarchar(100),
            publisher_security_mode	smallint,
            publisher_login	sysname,
            publisher_password	nvarchar(524),
            job_id	uniqueidentifier,
            job_login	nvarchar(512),
            job_password	sysname
		)

		DECLARE @result int;
		Insert into @temp
		EXEC sp_helplogreader_agent 

		select @result =  count(*) from @temp

		IF @result = 0
			BEGIN
				UPDATE tblSMReplicationSPResult SET result = 1;	
			END
		Else
			BEGIN
				UPDATE tblSMReplicationSPResult SET result = 0;	
			END	
END

