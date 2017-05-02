CREATE PROCEDURE [dbo].[uspCTGetDefaultData]
	@strType				NVARCHAR(50),
	@intItemId				INT = NULL,
	@intSubLocationId		INT = NULL,
	@intPlannedMonth		INT = NULL,
	@intYear				INT = NULL,
	@intMarketId			INT = NULL,
	@intLocationId			INT = NULL,
	@intCommodityId			INT = NULL,
	@intStorageLocationId	INT = NULL,
	@intItemContractId		INT = NULL
AS
BEGIN
	DECLARE @intProductTypeId	INT,
			@intFutureMarketId	INT,
			@intFutureMonthId	INT,
			@strFutureMonthYear NVARCHAR(100),
			@strSubLocationName NVARCHAR(100),
			@strStorageLocation NVARCHAR(100),
			@strContractItemNo NVARCHAR(100)

	SELECT	@intItemId				= CASE WHEN @intItemId= 0 THEN NULL ELSE @intItemId END,
			@intSubLocationId		= CASE WHEN @intSubLocationId= 0 THEN NULL ELSE @intSubLocationId END,
			@intPlannedMonth		= CASE WHEN @intPlannedMonth= 0 THEN NULL ELSE @intPlannedMonth END,
			@intYear				= CASE WHEN @intYear= 0 THEN NULL ELSE @intYear END,
			@intMarketId			= CASE WHEN @intMarketId= 0 THEN NULL ELSE @intMarketId END,
			@intLocationId			= CASE WHEN @intLocationId= 0 THEN NULL ELSE @intLocationId END,
			@intCommodityId			= CASE WHEN @intCommodityId= 0 THEN NULL ELSE @intCommodityId END,
			@intStorageLocationId	= CASE WHEN @intStorageLocationId= 0 THEN NULL ELSE @intStorageLocationId END,
			@intItemContractId		= CASE WHEN @intItemContractId= 0 THEN NULL ELSE @intItemContractId END

	DECLARE @intVendorId INT, @strCity NVARCHAR(100),@intCityId INT, @ysnPort BIT, @ysnRegion BIT

	DECLARE @Item TABLE
	(
		intItemId				INT,
		strItemNo				NVARCHAR(100),
		intPurchasingGroupId	INT,
		strOrigin				NVARCHAR(100),
		intProductTypeId		INT,
		intSubLocationId		INT,
		intStorageLocationId	INT,
		intItemContractId		INT
	)

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

	IF @strType = 'FutureMonthByPlannedDate'
	BEGIN
		SELECT TOP 1 @intFutureMonthId = intFutureMonthId,@strFutureMonthYear = strFutureMonthYear FROM vyuCTFuturesMonth WHERE intFutureMarketId = @intMarketId AND intYear >= @intYear AND intMonth >= @intPlannedMonth ORDER BY intYear ASC, intMonth ASC

		IF @intFutureMonthId IS NULL
		BEGIN
			SELECT TOP 1 @intFutureMonthId = intFutureMonthId,@strFutureMonthYear = strFutureMonthYear FROM vyuCTFuturesMonth WHERE intFutureMarketId = @intMarketId AND intYear >= @intYear + 1 AND intMonth > 0 ORDER BY intYear ASC, intMonth ASC
		END
		SELECT @intFutureMonthId AS intFutureMonthId, @strFutureMonthYear AS strFutureMonth
	END

	IF @strType = 'Item'
	BEGIN
		SELECT @strSubLocationName = strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intSubLocationId 
		SELECT @strStorageLocation = strName FROM tblICStorageLocation WHERE intStorageLocationId = @intStorageLocationId 
		SELECT @strContractItemNo  = strContractItemNo FROM tblICItemContract WHERE intItemContractId = ISNULL(@intItemContractId,0)

		IF ISNULL(@intItemId,0) > 0
		BEGIN 
			IF EXISTS(SELECT * FROM vyuCTInventoryItem WHERE intCommodityId = @intCommodityId AND intLocationId = @intLocationId AND intItemId = @intItemId)
			BEGIN
				INSERT INTO @Item
				SELECT TOP 1 intItemId,strItemNo,intPurchasingGroupId,strOrigin,intProductTypeId,null,null,null  FROM vyuCTInventoryItem WHERE intItemId = @intItemId
			END
			ELSE
			BEGIN
				INSERT INTO @Item
				SELECT TOP 1 intItemId,strItemNo,intPurchasingGroupId,strOrigin,intProductTypeId,null,null,null  FROM vyuCTInventoryItem 
				WHERE intCommodityId = @intCommodityId AND intLocationId = @intLocationId
				ORDER BY intItemId ASC
			END
		END
		ELSE
		BEGIN
			INSERT INTO @Item
			SELECT TOP 1 intItemId,strItemNo,intPurchasingGroupId,strOrigin,intProductTypeId,null,null,null FROM vyuCTInventoryItem 
			WHERE intCommodityId = @intCommodityId AND intLocationId = @intLocationId
			ORDER BY intItemId ASC
		END

		SELECT	@intItemId = intItemId FROM @Item
		SELECT	@intSubLocationId = NULL,@intStorageLocationId = NULL
		
		SELECT	@intSubLocationId = SL.intSubLocationId 
		FROM	tblICItemSubLocation SL 
		JOIN	tblICItemLocation	 IL ON IL.intItemLocationId = SL.intItemLocationId
		JOIN	tblSMCompanyLocationSubLocation LO ON LO.intCompanyLocationSubLocationId = SL.intSubLocationId
		WHERE	IL.intItemId = @intItemId AND IL.intLocationId = @intLocationId AND LO.strSubLocationName = @strSubLocationName

		SELECT @intStorageLocationId = intStorageLocationId FROM tblICStorageLocation WHERE intSubLocationId = @intSubLocationId AND strName = @strStorageLocation

		SELECT	@intItemContractId = IC.intItemContractId
		FROM	tblICItemContract		IC
		JOIN	tblICItem				IM	ON	IM.intItemId			=	IC.intItemId
		JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId	=	IC.intItemLocationId
		WHERE	IC.strContractItemNo = @strContractItemNo AND IL.intLocationId = @intLocationId AND IC.intItemId = @intItemId
			
		UPDATE @Item SET intSubLocationId = @intSubLocationId,intStorageLocationId = @intStorageLocationId,intItemContractId = @intItemContractId 

		SELECT * FROM @Item
	END

END