

CREATE PROCEDURE [dbo].[uspSMRepAddDistributor] 
@distributor sysname,
@password sysname
AS
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
BEGIN
 

DECLARE @sql nvarchar(max);

      SET @sql = N'USE MASTER
				  DECLARE @result int;
				  EXEC @result = sp_adddistributor @distributor=''param1'',  @password=''param2'';
				  UPDATE [param3].[dbo].tblSMReplicationSPResult SET result = @result';	
				  
 
		SET @sql = REPLACE(@sql,'param1',@distributor); 
		SET @sql = REPLACE(@sql,'param2',@password);
		SET @sql = REPLACE(@sql,'param3', DB_NAME());
		 
  exec (@sql);
		
END

--sp_dropdistributor
