CREATE PROCEDURE [dbo].[uspCTGetSubLocations]
	@intItemId				INT,
	@intCompanyLocationId	INT,
	@intSubLocationId		INT,
	@strSubLocationName		NVARCHAR(200)
AS

BEGIN

	IF EXISTS	(
					SELECT	* 
					FROM	tblICItemSubLocation	SL
					JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId	=	SL.intItemLocationId	
					JOIN	tblSMCompanyLocationSubLocation CS	ON CS.intCompanyLocationSubLocationId = SL.intSubLocationId
					WHERE	IL.intItemId = @intItemId AND CS.intCompanyLocationId = @intCompanyLocationId
				)
	BEGIN
		SELECT	SL.intItemSubLocationId,
				CS.intCompanyLocationId,
				CS.intCompanyLocationSubLocationId,
				CS.strSubLocationName,
				CS.intCountryId,
				IL.intItemId 
		FROM	tblICItemSubLocation	SL
		JOIN	tblICItemLocation		IL	ON	IL.intItemLocationId	=	SL.intItemLocationId	
		JOIN	tblSMCompanyLocationSubLocation CS	ON CS.intCompanyLocationSubLocationId = SL.intSubLocationId
		WHERE	IL.intItemId = @intItemId AND CS.intCompanyLocationId = @intCompanyLocationId
		AND		CS.strSubLocationName  LIKE '%' + @strSubLocationName + '%'
		AND		CS.intCompanyLocationSubLocationId =(CASE WHEN @intSubLocationId > 0 THEN @intSubLocationId ELSE CS.intCompanyLocationSubLocationId END)
	END		
	ELSE
	BEGIN
		SELECT	CS.intCompanyLocationSubLocationId AS intItemSubLocationId,
				CS.intCompanyLocationId,
				CS.intCompanyLocationSubLocationId,
				CS.strSubLocationName,
				CS.intCountryId,
				@intItemId AS intItemId 
		FROM	tblSMCompanyLocationSubLocation CS
		WHERE	CS.intCompanyLocationId = @intCompanyLocationId
		AND		CS.strSubLocationName  LIKE '%' + @strSubLocationName + '%'
		AND		CS.intCompanyLocationSubLocationId =(CASE WHEN @intSubLocationId > 0 THEN @intSubLocationId ELSE CS.intCompanyLocationSubLocationId END)
	END

END