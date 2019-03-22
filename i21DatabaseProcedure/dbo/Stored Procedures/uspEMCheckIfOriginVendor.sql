CREATE PROCEDURE [dbo].[uspEMCheckIfOriginVendor]
	@Id			NVARCHAR(100),
	@GoDelete	BIT OUTPUT
AS
BEGIN
	SET @GoDelete = 1
END