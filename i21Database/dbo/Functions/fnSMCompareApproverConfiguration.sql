CREATE FUNCTION [dbo].[fnSMCompareApproverConfiguration]
(
	@approverUserId INT,
	@screenId INT,
	@approverConfiguration ApprovalConfigurationType READONLY
)
RETURNS BIT
AS
BEGIN

	DECLARE @passed BIT = 1

	DECLARE @ApproverConfigurationDetail TABLE
	(
	  intApproverConfigurationDetailId INT, 
	  strApprovalFor NVARCHAR(250),
	  strType NVARCHAR(250),
	  strValue NVARCHAR(MAX),
	  intValueId INT
	)

	DECLARE @ApprovalConfigurationDetailParam TABLE ( 
	  strApprovalFor NVARCHAR(250), 
	  strValue NVARCHAR(250) 
	)

	DECLARE @approverDetailId INT
	DECLARE @approverDetailFor NVARCHAR(250)
	DECLARE @approverDetailValue NVARCHAR(250)
	DECLARE @approverDetailValueInt INT
	DECLARE @approverDetailType NVARCHAR(250)

	DECLARE @approverDetailParamFor NVARCHAR(250)
	DECLARE @approverDetailParamValue NVARCHAR(250)

	DECLARE @approverConfigurationCount INT

	DECLARE @passedCount INT = 0
	DECLARE @detailCount INT = 0

	SELECT @approverConfigurationCount = COUNT(*) FROM @approverConfiguration

	IF ISNULL(@approverConfigurationCount, 0) = 0
	BEGIN
		return @passed
	END

	-- This is the CompareApproverConfiguration
	INSERT INTO @ApproverConfigurationDetail (
		intApproverConfigurationDetailId,
		strApprovalFor,
		strType,
		strValue,
		intValueId
	)
	SELECT 
		b.intApproverConfigurationDetailId,
		c.strApprovalFor,
		c.strType,
		b.strValue, 
		b.intValueId
	FROM tblSMApproverConfiguration a 
		INNER JOIN tblSMApproverConfigurationDetail b ON a.intApproverConfigurationId = b.intApproverConfigurationId
		INNER JOIN tblSMApproverConfigurationApprovalFor c ON b.intApprovalForId = c.intApprovalForId
	WHERE intEntityId = @approverUserId AND b.intScreenId = @screenId

	SELECT @detailCount = COUNT(*) FROM @ApproverConfigurationDetail

	IF ISNULL(@detailCount, 0) = 0
	BEGIN
		return @passed
	END

	IF EXISTS (SELECT 1 FROM @ApproverConfigurationDetail)
	BEGIN

		WHILE EXISTS (SELECT 1 FROM @ApproverConfigurationDetail)
		BEGIN
			SELECT TOP 1
				@approverDetailId = intApproverConfigurationDetailId,
				@approverDetailFor = UPPER(LTRIM(RTRIM(strApprovalFor))),
				@approverDetailValue = UPPER(LTRIM(RTRIM(strValue))),
				@approverDetailValueInt = intValueId,
				@approverDetailType = strType
			FROM @ApproverConfigurationDetail

			INSERT INTO @ApprovalConfigurationDetailParam (
				strApprovalFor,
				strValue
			)
			SELECT 
				strApprovalFor,
				strValue
			FROM @approverConfiguration

			WHILE EXISTS (SELECT  1 FROM @ApprovalConfigurationDetailParam)
			BEGIN

				SELECT TOP 1
					@approverDetailParamFor = UPPER(LTRIM(RTRIM(strApprovalFor))),
					@approverDetailParamValue = UPPER(LTRIM(RTRIM(strValue)))
				FROM @ApprovalConfigurationDetailParam

				IF @approverDetailType = 'Combobox'
				BEGIN
					SET @approverDetailValue = CAST(@approverDetailValueInt AS NVARCHAR(250))
				END

				IF @approverDetailFor = @approverDetailParamFor AND @approverDetailValue = @approverDetailParamValue
				BEGIN
					SET @passedCount = @passedCount + 1
				END

				DELETE FROM @ApprovalConfigurationDetailParam 
				WHERE UPPER(LTRIM(RTRIM(strApprovalFor))) = UPPER(LTRIM(RTRIM(@approverDetailParamFor))) AND 
					  UPPER(LTRIM(RTRIM(strValue))) = UPPER(LTRIM(RTRIM(@approverDetailParamValue)))
			END

			DELETE FROM @ApproverConfigurationDetail WHERE intApproverConfigurationDetailId = @approverDetailId
		END

		SET @passed = CASE WHEN @passedCount = @detailCount THEN 1 ELSE 0 END	
	END

	RETURN @passed
END