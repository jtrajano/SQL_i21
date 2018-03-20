CREATE PROCEDURE uspMFGetCustomTabFieldNames (@strNamespace NVARCHAR(100))
AS
BEGIN
	DECLARE @intCustomFieldCount INT
		,@strCustomFieldNames NVARCHAR(MAX)

	SELECT @strCustomFieldNames = ''
		,@intCustomFieldCount = 0

	SELECT @strCustomFieldNames = @strCustomFieldNames + TD.strControlName + ','
	FROM tblSMScreen S
	JOIN tblSMCustomTab T ON T.intScreenId = S.intScreenId
		AND S.strNamespace = @strNamespace
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabId = T.intCustomTabId
		AND TD.strFieldName <> 'Id'
	ORDER BY TD.intCustomTabDetailId

	IF len(@strCustomFieldNames) > 0
	BEGIN
		SELECT @strCustomFieldNames = Left(@strCustomFieldNames, len(@strCustomFieldNames) - 1)
	END

	SELECT @intCustomFieldCount = Count(*)
	FROM tblSMScreen S
	JOIN tblSMCustomTab T ON T.intScreenId = S.intScreenId
		AND S.strNamespace = @strNamespace
	JOIN tblSMCustomTabDetail TD ON TD.intCustomTabId = T.intCustomTabId
		AND TD.strFieldName <> 'Id'

	SELECT @intCustomFieldCount AS intCustomFieldCount
		,@strCustomFieldNames AS strCustomFieldNames
END
