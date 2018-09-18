CREATE FUNCTION [dbo].[fnCTGetSeqDisplayField]
(
	@intId	 INT,
	@strTable	 NVARCHAR(100)
)
RETURNS NVARCHAR(MAX)
AS 
BEGIN 
	DECLARE	 @strDisplayField NVARCHAR(MAX)

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

	RETURN @strDisplayField;
END
