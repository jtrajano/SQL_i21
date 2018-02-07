
CREATE PROCEDURE [uspSMRepGetDistributor] 
 @installed int OUTPUT,
 @distribution_server nvarchar(128) OUTPUT, 
 @is_distribution_db_installed int OUTPUT,
 @is_distribution_publisher int OUTPUT,
 @has_remote_distribution_publisher int OUTPUT
AS
BEGIN
    SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON

	DECLARE @distributionTemp TABLE
	(
	  installed int, 
	  [distribution server] nvarchar(128),
	  [distribution db installed] int,
	  [is distribution publisher] int,
	  [has remote distribution publisher] int
	);

	INSERT INTO @distributionTemp
	exec sp_get_distributor 


	select  @installed = installed, 
			@distribution_server = [distribution server], 
			@is_distribution_db_installed =  [distribution db installed],
			@is_distribution_publisher =  [is distribution publisher],
			@has_remote_distribution_publisher = [has remote distribution publisher]
		
	from @distributionTemp
END


