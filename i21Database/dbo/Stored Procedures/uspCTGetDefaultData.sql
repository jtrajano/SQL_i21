CREATE PROCEDURE [dbo].[uspCTGetDefaultData]
	@strType			NVARCHAR(50),
	@intItemId			INT = NULL,
	@intSubLocationId	INT = NULL,
	@intPlannedMonth	INT = NULL,
	@intYear			INT = NULL,
	@intMarketId		INT = NULL
AS
BEGIN
	DECLARE @intProductTypeId	INT,
			@intCommodityId		INT,
			@intFutureMarketId	INT,
			@intFutureMonthId	INT,
			@strFutureMonthYear NVARCHAR(100)

	DECLARE @intVendorId INT, @strCity NVARCHAR(100),@intCityId INT, @ysnPort BIT, @ysnRegion BIT

	IF @strType = 'FutureMarket'
	BEGIN
		SELECT	@intProductTypeId = intProductTypeId,@intCommodityId = intCommodityId FROM tblICItem WHERE intItemId = @intItemId
		SELECT	@intFutureMarketId = intFutureMarketId FROM tblRKCommodityMarketMapping WHERE strCommodityAttributeId+',' LIKE '%'+LTRIM(@intProductTypeId)+',%' AND intCommodityId = @intCommodityId

		IF	ISNULL(@intFutureMarketId,0) > 0
		BEGIN
			SELECT TOP 1 M.intFutureMarketId,M.strFutMarketName,M.intCurrencyId,IU.intItemUOMId,M.dblContractSize,M.intUnitMeasureId,MU.strUnitMeasure 
			FROM tblRKFutureMarket M 
			LEFT JOIN	tblICUnitMeasure			MU	ON	MU.intUnitMeasureId				=		M.intUnitMeasureId
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intItemId AND IU.intUnitMeasureId = M.intUnitMeasureId
			WHERE M.intFutureMarketId = @intFutureMarketId
		END
		ELSE
		BEGIN
			SELECT TOP 1 M.intFutureMarketId,M.strFutMarketName,M.intCurrencyId,IU.intItemUOMId,M.dblContractSize,M.intUnitMeasureId,MU.strUnitMeasure 
			FROM tblRKFutureMarket M 
			LEFT JOIN	tblICUnitMeasure			MU	ON	MU.intUnitMeasureId				=		M.intUnitMeasureId
			JOIN tblRKCommodityMarketMapping C ON C.intFutureMarketId = M.intFutureMarketId 
			LEFT JOIN tblICItemUOM IU ON IU.intItemId = @intItemId AND IU.intUnitMeasureId = M.intUnitMeasureId
			WHERE C.intCommodityId = @intCommodityId  ORDER BY M.intFutureMarketId ASC
		END
	END

	IF @strType = 'Destination Point'
	BEGIN
		SELECT @intVendorId = intVendorId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSubLocationId
		SELECT @strCity = strCity FROM tblEMEntityLocation WHERE intEntityId = @intVendorId AND ysnDefaultLocation = 1
		SELECT @intCityId = intCityId, @ysnPort = ysnPort, @ysnRegion = ysnRegion FROM tblSMCity WHERE strCity = @strCity

		IF @intCityId IS NOT NULL
		BEGIN
			SELECT @intCityId AS intCityId, CASE	WHEN @ysnPort = 1 THEN 'Port' 
													WHEN @ysnRegion = 1 THEN 'Region'
													ELSE 'City'
											END	AS strDestinationPointType
		END
		ELSE
		BEGIN
			SELECT NULL AS intCityId, NULL	AS strDestinationPointType
		END
	END

	IF @strType = 'Destination Point'
	BEGIN
		SELECT @intVendorId = intVendorId FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSubLocationId
		SELECT @strCity = strCity FROM tblEMEntityLocation WHERE intEntityId = @intVendorId AND ysnDefaultLocation = 1
		SELECT @intCityId = intCityId, @ysnPort = ysnPort, @ysnRegion = ysnRegion FROM tblSMCity WHERE strCity = @strCity

		IF @intCityId IS NOT NULL
		BEGIN
			SELECT @intCityId AS intCityId, CASE	WHEN @ysnPort = 1 THEN 'Port' 
													WHEN @ysnRegion = 1 THEN 'Region'
													ELSE 'City'
											END	AS strDestinationPointType
		END
		ELSE
		BEGIN
			SELECT NULL AS intCityId, NULL	AS strDestinationPointType
		END
	END

	IF @strType = 'FutureMonthByPlannedDate'
	BEGIN
		SELECT TOP 1 @intFutureMonthId = intFutureMonthId,@strFutureMonthYear = strFutureMonthYear FROM vyuCTFuturesMonth WHERE intFutureMarketId = @intMarketId AND intYear >= @intYear AND intMonth >= @intPlannedMonth ORDER BY intYear ASC, intMonth ASC

		IF @intFutureMonthId IS NULL
		BEGIN
			SELECT TOP 1 @intFutureMonthId = intFutureMonthId,@strFutureMonthYear = strFutureMonthYear FROM vyuCTFuturesMonth WHERE intFutureMarketId = @intMarketId AND intYear >= @intYear + 1 AND intMonth > 0 ORDER BY intYear ASC, intMonth ASC
		END
		SELECT @intFutureMonthId AS intFutureMonthId, @strFutureMonthYear AS strFutureMonth
	END
END