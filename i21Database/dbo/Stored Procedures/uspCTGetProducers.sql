CREATE PROCEDURE [dbo].[uspCTGetProducers]
	@intEntityId			INT,
	@intProducerId			INT,
	@strEntityName			NVARCHAR(200)
AS

BEGIN

	IF EXISTS	(SELECT	TOP 1 1 FROM tblCTEntityProducerMap	WHERE intEntityId = @intEntityId)
	BEGIN
		SELECT	EY.intEntityId,
				EY.strEntityName
		FROM	tblCTEntityProducerMap	EP
		JOIN	vyuCTEntity				EY	ON	EY.intEntityId	=	EP.intProducerId
		WHERE	EP.intEntityId = @intEntityId
		AND		EY.strEntityType = 'Producer'
		AND		EY.ysnActive	 =	1
		AND		EY.ysnVendor	 =	1
		AND		EY.strEntityName	LIKE	'%' + @strEntityName COLLATE Latin1_General_CI_AS + '%'
	END		
	ELSE
	BEGIN
		SELECT	EY.intEntityId,
				EY.strEntityName

		FROM	vyuCTEntity EY
		WHERE	EY.strEntityType = 'Producer'
		AND		EY.ysnActive	 =	1
		AND		EY.ysnVendor	 =	1
		AND		EY.strEntityName	LIKE	'%' + @strEntityName COLLATE Latin1_General_CI_AS + '%'
	END
END