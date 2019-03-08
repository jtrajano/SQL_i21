CREATE PROCEDURE uspQMGetSentByList @strSentBy NVARCHAR(50)
	,@intValueMemberId INT
	,@strDisplayMember NVARCHAR(100)
AS
SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @strEntityType NVARCHAR(50) = ''

IF @strSentBy = 'Forwarding Agent'
	SET @strEntityType = 'Forwarding Agent'
ELSE IF @strSentBy = 'Seller'
	SET @strEntityType = 'Vendor'
ELSE IF @strSentBy = 'Users'
	SET @strEntityType = 'User'

IF @strSentBy = 'Self'
BEGIN
	SELECT intCompanyLocationId AS intValueMemberId
		,strLocationName AS strDisplayMember
	FROM tblSMCompanyLocation
	WHERE intCompanyLocationId = (
			CASE 
				WHEN @intValueMemberId > 0
					THEN @intValueMemberId
				ELSE intCompanyLocationId
				END
			)
		AND strLocationName LIKE '%' + @strDisplayMember + '%'
	ORDER BY strLocationName
END
ELSE
BEGIN
	SELECT intEntityId AS intValueMemberId
		,strEntityName AS strDisplayMember
	FROM vyuCTEntity
	WHERE strEntityType = @strEntityType
		AND intEntityId = (
			CASE 
				WHEN @intValueMemberId > 0
					THEN @intValueMemberId
				ELSE intEntityId
				END
			)
		AND strEntityName LIKE '%' + @strDisplayMember + '%'
	ORDER BY strEntityName
END
