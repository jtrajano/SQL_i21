CREATE FUNCTION [dbo].[fnFAGetOverrideAccount]
(
	@intAssetId INT,
	@intAccountId INT,
	@intTransactionType INT
	/*
		1 - Asset Account
		2 - Offset Account
		3 - Depreciation Account
		4 - Accumulated Deperciation Account
		5 - Gain/Loss Account
		6 - Sales Offset Account
		7 - Realized Gain/Loss Account
	*/
)
RETURNS @tbl TABLE (
	intAssetId INT,
	intAccountId INT,
	intTransactionType INT,
	intNewAccountId INT  NULL,
	strNewAccountId NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
	strError NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL 
)
AS
BEGIN
	DECLARE 
	     @intCompanyLocationId INT
		,@intLocationSegmentId INT
		,@intCompanySegmentId INT = NULL
		,@intNewAccountId INT = NULL
		,@strNewAccountId NVARCHAR(40)
		,@strError NVARCHAR(MAX) = NULL

	SELECT @intCompanyLocationId = intCompanyLocationId FROM tblFAFixedAsset WHERE intAssetId = @intAssetId
	SELECT @intLocationSegmentId = intProfitCenter, @intCompanySegmentId = intCompanySegment FROM tblSMCompanyLocation WHERE intCompanyLocationId = @intCompanyLocationId

	IF (@intLocationSegmentId IS NULL)
		SELECT @intLocationSegmentId = intLocationSegmentId FROM tblGLAccount WHERE intAccountId = @intAccountId

	IF(@intCompanySegmentId IS NULL)
	BEGIN
		SELECT TOP 1 @intCompanySegmentId = C.intAccountSegmentId
		FROM tblGLAccount A
		JOIN tblGLAccountSegmentMapping B ON B.intAccountId = A.intAccountId
		JOIN tblGLAccountSegment C ON C.intAccountSegmentId = B.intAccountSegmentId
		JOIN tblGLAccountStructure D ON D.intAccountStructureId = C.intAccountStructureId
		WHERE A.intAccountId = @intAccountId AND D.intStructureType = 6
	END

	SELECT @strNewAccountId = dbo.fnGLGetOverrideAccountBySegment(@intAccountId, @intLocationSegmentId, NULL, @intCompanySegmentId)
	IF (@strNewAccountId IS NOT NULL)
	BEGIN
		SELECT @intNewAccountId = intAccountId FROM tblGLAccount WHERE strAccountId = @strNewAccountId

		IF (@intNewAccountId IS NULL)
		BEGIN
			SET @strError =  @strNewAccountId + ' is not an existing override account for ' +
				CASE
					WHEN @intTransactionType = 1 THEN 'Asset Account' COLLATE Latin1_General_CI_AS
					WHEN @intTransactionType = 2 THEN 'Offset Account' COLLATE Latin1_General_CI_AS
					WHEN @intTransactionType = 3 THEN 'Depreciation Expense Account' COLLATE Latin1_General_CI_AS
					WHEN @intTransactionType = 4 THEN 'Accumulated Depreciation Account' COLLATE Latin1_General_CI_AS
					WHEN @intTransactionType = 5 THEN 'Gain/Loss Account' COLLATE Latin1_General_CI_AS
					WHEN @intTransactionType = 6 THEN 'Sales Offset Account' COLLATE Latin1_General_CI_AS
					WHEN @intTransactionType = 7 THEN 'Realized Gain/Loss Account' COLLATE Latin1_General_CI_AS
				END
		END
	END
	ELSE
		SET @intNewAccountId = @intAccountId

	INSERT INTO @tbl (
		 intAssetId
		,intAccountId
		,intTransactionType
		,intNewAccountId
		,strNewAccountId
		,strError 
	)
	VALUES (
		 @intAssetId
		,@intAccountId
		,@intTransactionType
		,@intNewAccountId
		,@strNewAccountId
		,@strError
	)

	RETURN
END
