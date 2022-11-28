CREATE PROCEDURE [dbo].[uspSTCSCreateCheckoutProcessEntry] (
	@intStoreId INT,
	@dtmCheckoutProcessDate DATETIME,
	@strGuid NVARCHAR(100),
	@intCheckoutProcessId INT OUT
)
AS
SET NOCOUNT ON;

INSERT INTO tblSTCheckoutProcess (intStoreId,dtmCheckoutProcessDate,strGuid,ysnConsFinishedProcessing,intConcurrencyId) VALUES (@intStoreId,@dtmCheckoutProcessDate,@strGuid,0,1)
SET @intCheckoutProcessId = (SELECT intCheckoutProcessId FROM tblSTCheckoutProcess WHERE strGuid = @strGuid)
