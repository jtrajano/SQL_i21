CREATE PROCEDURE [dbo].[uspSTCSCreateNewJob] (
	@intStoreId INT,
	@intJobTypeId INT,
	@strParameter1 NVARCHAR(150),
	@strParameter2 NVARCHAR(150),
	@strParameter3 NVARCHAR(150),
	@dtmJobCreated DATETIME,
	@intEntityId INT,
	@intJobId INT OUT
)
AS
SET NOCOUNT ON;

INSERT INTO tblSTJobs (intStoreId, intJobTypeId, dtmJobCreated, strParameter1, strParameter2, strParameter3, ysnJobReceived, intConcurrencyId, intEntityId) 
			   VALUES (@intStoreId, @intJobTypeId, @dtmJobCreated, @strParameter1, @strParameter2, @strParameter3, 0, 1, @intEntityId)
SET @intJobId = (SELECT TOP 1 intJobId FROM tblSTJobs WHERE intStoreId = @intStoreId AND intJobTypeId = @intJobTypeId AND strParameter2 = @strParameter2 ORDER BY intJobId DESC)
