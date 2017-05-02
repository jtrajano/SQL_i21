CREATE FUNCTION [dbo].[fnCTContractApprovalExist]
(
	@intEntityUserSecurityId INT,
	@strNamespace NVARCHAR(100)
)
RETURNS BIT
AS 
BEGIN 
	DECLARE @ysnExist BIT

	IF EXISTS
	(
		SELECT	AP.intEntityUserSecurityId 
		FROM	tblSMUserSecurityRequireApprovalFor AP
		JOIN	tblSMScreen  SC ON SC.intScreenId = AP.intScreenId
		WHERE	SC.strNamespace = @strNamespace
		AND		intEntityUserSecurityId = @intEntityUserSecurityId
	)
		SET @ysnExist = 1
	ELSE
		SET @ysnExist = 0

	RETURN @ysnExist
	
END
