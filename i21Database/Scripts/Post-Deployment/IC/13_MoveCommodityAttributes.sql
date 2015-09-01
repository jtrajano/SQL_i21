print('/*******************  BEGIN Move Commodity Product Lines *******************/')
GO

IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICCommodityProductLine'))
BEGIN
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICCommodityAttribute'))
	BEGIN
		SELECT * 
		INTO #tmpProductLines
		FROM tblICCommodityAttribute
		WHERE strType = 'ProductLine'

		SET IDENTITY_INSERT tblICCommodityProductLine ON
		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpProductLines)
		BEGIN
			DECLARE @strDescription NVARCHAR(50),
				@intCommodityAttributeId INT,
				@intCommodityId INT

			SELECT TOP 1 @strDescription = strDescription, @intCommodityAttributeId = intCommodityAttributeId, @intCommodityId = intCommodityId FROM #tmpProductLines

			IF NOT EXISTS (SELECT TOP 1 1 FROM tblICCommodityProductLine WHERE intCommodityProductLineId = @intCommodityAttributeId)
			BEGIN
				INSERT INTO tblICCommodityProductLine (intCommodityProductLineId, intCommodityId, strDescription)
				VALUES (@intCommodityAttributeId, @intCommodityId, @strDescription)
			END

			DELETE FROM #tmpProductLines WHERE intCommodityAttributeId = @intCommodityAttributeId
			DELETE FROM tblICCommodityAttribute WHERE intCommodityAttributeId = @intCommodityAttributeId
		END
		SET IDENTITY_INSERT tblICCommodityProductLine OFF
		DROP TABLE #tmpProductLines
	END
END

GO
print('/*******************  END Move Commodity Product Lines *******************/')