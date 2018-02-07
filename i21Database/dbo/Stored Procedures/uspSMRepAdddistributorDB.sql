
CREATE PROCEDURE [dbo].[uspSMRepAdddistributorDB] 
@login sysname,
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
				  EXEC @result = sp_adddistributiondb @database = N''distribution'', 
									@log_file_size = 2, 
									@min_distretention = 0, 
									@max_distretention = 72, 
									@history_retention = 48, 
								    @security_mode = 0,
								    @login = N''param1'', 
									@password = N''param2'';

				 UPDATE [param3].[dbo].tblSMReplicationSPResult SET result = @result';	
				  
 
		
		SET @sql = REPLACE(@sql,'param1',@login); 
		SET @sql = REPLACE(@sql,'param2',@password);
		SET @sql = REPLACE(@sql,'param3', DB_NAME());
		 
  exec (@sql);
		
END
