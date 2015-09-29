CREATE PROCEDURE [dbo].[uspEMUpdateCustomerTable]
	@Field NVARCHAR(200),
	@Value NVARCHAR(200),
	@Id		INT
AS
BEGIN
	DECLARE @Com   AS NVARCHAR(MAX)
	DECLARE @Param AS NVARCHAR(MAX)

	IF CHARINDEX('--', @Field, 0) <=0 AND CHARINDEX('--', @Value, 0) <=0 AND @Field not in ('strCustomerNumber', 'intEntityCustomerId') AND (@Id is not null and @Id > 0)
	BEGIN
	
		SET @Param = '@Value AS NVARCHAR(200), @Id	AS INT'
		SET @Com = 'UPDATE tblARCustomer SET ' +@Field + ' = @Value WHERE intEntityCustomerId = @Id' 
	
		EXECUTE sp_executesql @Com, @Param, @Value, @Id
	END

END