CREATE PROCEDURE [dbo].[GetDefaultData]
	@strType	NVARCHAR(50),
	@intItemId	INT = NULL
AS
BEGIN
	DECLARE @intProductTypeId INT,@intCommodityId INT,@intFutureMarketId INT

	IF @strType = 'FutureMarket'
	BEGIN
		SELECT	@intProductTypeId = intProductTypeId,@intCommodityId = intCommodityId FROM tblICItem WHERE intItemId = @intItemId
		SELECT	@intFutureMarketId = intFutureMarketId FROM tblRKCommodityMarketMapping WHERE strCommodityAttributeId+',' LIKE '%'+LTRIM(@intProductTypeId)+',%' AND intCommodityId = @intCommodityId

		IF	ISNULL(@intFutureMarketId,0) > 0
		BEGIN
			SELECT TOP 1 M.intFutureMarketId,M.strFutMarketName,M.intCurrencyId,IU.intItemUOMId FROM tblRKFutureMarket M 
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intItemId AND IU.intUnitMeasureId = M.intUnitMeasureId
			WHERE M.intFutureMarketId = @intFutureMarketId
		END
		ELSE
		BEGIN
			SELECT TOP 1 M.intFutureMarketId,M.strFutMarketName,M.intCurrencyId,IU.intItemUOMId FROM tblRKFutureMarket M 
			JOIN tblRKCommodityMarketMapping C ON C.intFutureMarketId = M.intFutureMarketId 
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intItemId AND IU.intUnitMeasureId = M.intUnitMeasureId
			WHERE C.intCommodityId = @intCommodityId  ORDER BY M.intFutureMarketId ASC
		END
	END
END