CREATE FUNCTION [dbo].[fnCTGetSeqDisplayField]
(
	@intId	 INT,
	@strTable	 NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	@strDisplayField	NVARCHAR(MAX),
			@intItemId			INT,
			@intItemContractId	INT,
			@intCountryId		INT

	IF @intId IS NULL
		SELECT @strDisplayField = NULL
	ELSE IF @strTable = 'tblCTDiscountType'
		SELECT @strDisplayField = strDiscountType FROM tblCTDiscountType WHERE intDiscountTypeId = @intId
	ELSE IF @strTable = 'tblGRDiscountId'
		SELECT @strDisplayField = strDiscountId FROM tblGRDiscountId WHERE intDiscountId = @intId
	ELSE IF @strTable = 'tblGRDiscountSchedule'
		SELECT @strDisplayField = strDiscountDescription FROM tblGRDiscountSchedule WHERE intDiscountScheduleId = @intId
	ELSE IF @strTable = 'tblSMCompanyLocationSubLocation'
		SELECT @strDisplayField = strSubLocationName FROM tblSMCompanyLocationSubLocation WHERE intCompanyLocationSubLocationId = @intId
	ELSE IF @strTable = 'tblICStorageLocation'
		SELECT @strDisplayField = strName FROM tblICStorageLocation WHERE intStorageLocationId = @intId
	ELSE IF @strTable = 'tblEMEntity'
		SELECT @strDisplayField = strName FROM tblEMEntity WHERE intEntityId = @intId
	ELSE IF @strTable = 'tblEMEntityLocation'
		SELECT @strDisplayField = strLocationName FROM tblEMEntityLocation WHERE intEntityLocationId = @intId
	ELSE IF @strTable = 'tblEMEntitySplit'
		SELECT @strDisplayField = strSplitNumber FROM tblEMEntitySplit WHERE intSplitId = @intId
	ELSE IF @strTable = 'tblGRDiscountScheduleCode'
		SELECT	@strDisplayField = strDescription 
		FROM	tblGRDiscountScheduleCode		SC	  
		JOIN	tblICItem						SI	ON	SI.intItemId	=  SC.intItemId 
		WHERE	intDiscountScheduleCodeId = @intId
	ELSE IF @strTable = 'tblGRStorageScheduleRule'
		SELECT @strDisplayField = strScheduleDescription FROM tblGRStorageScheduleRule WHERE intStorageScheduleRuleId = @intId
	ELSE IF @strTable = 'tblCTFreightRate'
		SELECT @strDisplayField = strOrigin + strDest FROM tblCTFreightRate WHERE intFreightRateId = @intId
	ELSE IF @strTable = 'tblCTIndex'
		SELECT @strDisplayField = strIndex FROM tblCTIndex WHERE intIndexId = @intId
	ELSE IF @strTable = 'tblARMarketZone'
		SELECT @strDisplayField = strMarketZoneCode FROM tblARMarketZone WHERE intMarketZoneId = @intId
	ELSE IF @strTable = 'tblCTBook'
		SELECT @strDisplayField = strBook FROM tblCTBook WHERE intBookId = @intId
	ELSE IF @strTable = 'tblCTSubBook'
		SELECT @strDisplayField = strSubBook FROM tblCTSubBook WHERE intSubBookId = @intId
	ELSE IF @strTable = 'tblCTRailGrade'
		SELECT @strDisplayField = strRailGrade FROM tblCTRailGrade WHERE intRailGradeId = @intId
	ELSE IF @strTable = 'tblSMCity'
		SELECT @strDisplayField = strCity FROM tblSMCity WHERE intCityId = @intId
	ELSE IF @strTable = 'tblSMCountry'
		SELECT @strDisplayField = strCountry FROM tblSMCountry WHERE intCountryID = @intId
	ELSE IF @strTable = 'tblICItemUOM'
		SELECT	@strDisplayField = strUnitMeasure  
		FROM	tblICItemUOM		IU
		JOIN	tblICUnitMeasure	UM ON UM.intUnitMeasureId = IU.intUnitMeasureId 
		WHERE	intItemUOMId = @intId
	ELSE IF @strTable = 'tblICItemUOMUnitType'
		SELECT	@strDisplayField = strUnitType
		FROM	tblICItemUOM		IU
		JOIN	tblICUnitMeasure	UM ON UM.intUnitMeasureId = IU.intUnitMeasureId 
		WHERE	intItemUOMId = @intId

	ELSE IF @strTable = 'Origin'
	BEGIN	  
		SELECT @intItemId = intItemId,@intItemContractId = intItemContractId FROM tblCTContractDetail WHERE intContractDetailId = @intId
		  
		IF @intItemContractId IS NOT NULL
		BEGIN
			SELECT  @strDisplayField = strCountry 
			FROM    tblICItemContract	IC
			JOIN    tblSMCountry		RY	ON	RY.intCountryID	=	IC.intCountryId
			WHERE   IC.intItemContractId = @intItemContractId
		END
		ELSE IF NOT EXISTS(SELECT TOP 1 1 FROM tblICCommodityAttribute WHERE strType	=	'Origin')
		BEGIN
			SELECT @strDisplayField = NULL
		END
		ELSE
		BEGIN
			SELECT @intCountryId = intOriginId  FROM tblICItem WHERE intItemId = @intItemId
				
			IF @intCountryId IS NOT NULL
				SELECT	@strDisplayField = strCountry 
				FROM	tblICCommodityAttribute			CA																		
				JOIN	tblSMCountry		OG	ON	OG.intCountryID	=	CA.intCountryID
				WHERE   CA.intCommodityAttributeId			=		@intCountryId	
				AND		CA.strType							=		'Origin'
		END

	END
	RETURN @strDisplayField;
END

GO