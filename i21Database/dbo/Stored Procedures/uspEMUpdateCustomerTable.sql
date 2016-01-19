CREATE PROCEDURE [dbo].[uspEMUpdateCustomerTable]
	@Field NVARCHAR(200),
	@Value NVARCHAR(200),
	@Id		INT,
	@EntityId INT, 
	@View	NVARCHAR(200) = 'TankManagement.view.BudgetCalculations'
AS
BEGIN
	DECLARE @Com   AS NVARCHAR(MAX)
	DECLARE @Param AS NVARCHAR(MAX)
	DECLARE @PreviousValue AS NVARCHAR(MAX)

	IF CHARINDEX('--', @Field, 0) <=0 AND CHARINDEX('--', @Value, 0) <=0 AND @Field not in ('strCustomerNumber', 'intEntityCustomerId') AND (@Id is not null and @Id > 0)
	BEGIN
	
		SET @Param = '@Value AS NVARCHAR(200), @Id	AS INT, @PreviousValue AS NVARCHAR(MAX) OUTPUT'
		SET @Com = 'SELECT @PreviousValue = CAST(' + @Field + ' as NVARCHAR) FROM tblARCustomer where intEntityCustomerId = @Id'
	
		EXECUTE sp_executesql @Com, @Param, @Value, @Id, @PreviousValue OUTPUT

		

		SET @Param = '@Value AS NVARCHAR(200), @Id	AS INT'
		SET @Com = 'UPDATE tblARCustomer SET ' +@Field + ' = @Value WHERE intEntityCustomerId = @Id' 
	
		EXECUTE sp_executesql @Com, @Param, @Value, @Id



		EXEC uspSMAuditLog
        @keyValue = @Id,                                          -- Primary Key Value
        @screenName = @View,										-- Screen Namespace
        @entityId = @EntityId,                                              -- Entity Id.
        @actionType = 'Updated',                                  -- Action Type (Processed, Posted, Unposted and etc.)
 
        --- Below is just optional if you need a tree level information
        @changeDescription = 'Update customer information', -- Description
        @fromValue = @PreviousValue,                                        -- Previous Value
        @toValue = @Value                                     -- New Value
	END

END