CREATE PROCEDURE [dbo].[uspSTCSDeleteCheckoutProcessEntry] (
	@intCheckoutId INT
	--@intStoreId INT,
	--@dtmCheckoutProcessDate DATETIME,
	--@strGuid NVARCHAR(100),
	--@intCheckoutProcessId INT OUT
)
AS
SET NOCOUNT ON;

DECLARE @intCheckoutProcessId INT
SELECT @intCheckoutProcessId = intCheckoutProcessId FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId
DELETE FROM tblSTCheckoutProcessErrorWarning WHERE intCheckoutId = @intCheckoutId
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSTCheckoutProcessErrorWarning WHERE @intCheckoutProcessId = @intCheckoutProcessId)
BEGIN
	DELETE FROM tblSTCheckoutProcess WHERE intCheckoutProcessId = @intCheckoutProcessId
END