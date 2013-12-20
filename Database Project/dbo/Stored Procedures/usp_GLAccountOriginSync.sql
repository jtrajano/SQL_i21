CREATE PROCEDURE  [dbo].[usp_GLAccountOriginSync]
@intUserID INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

-- +++++ TO TEMP TABLE +++++ --
SELECT * INTO #TempUpdateCrossReference
FROM tblGLCOACrossReference WHERE intLegacyReferenceID IS NULL

-- +++++ SYNC ACCOUNTS +++++ --
WHILE EXISTS(SELECT 1 FROM #TempUpdateCrossReference)
BEGIN
	Declare @ID_update INT = (SELECT TOP 1 inti21ID FROM #TempUpdateCrossReference)
	Declare @ACCOUNT_update varchar(200) = (SELECT TOP 1 REPLACE(strCurrentExternalID,'-','') FROM #TempUpdateCrossReference WHERE inti21ID = @ID_update)
	Declare @TYPE_update varchar(200) = (SELECT TOP 1 strAccountType FROM tblGLAccount LEFT JOIN tblGLAccountGroup ON tblGLAccount.intAccountGroupID = tblGLAccountGroup.intAccountGroupID WHERE intAccountID = @ID_update)
	Declare @ACTIVE_update BIT = (SELECT TOP 1 ysnActive FROM tblGLAccount WHERE intAccountID = @ID_update)
	Declare @DESCRIPTION_update varchar(500) = (SELECT TOP 1 strDescription FROM tblGLAccount WHERE intAccountID = @ID_update)
	Declare @LegacyType_update varchar(200) = ''
	Declare @LegacySide_update varchar(200) = ''
	Declare @LegacyActive_update varchar(200) = 'N'
	
	IF @ACTIVE_update = 1
		BEGIN
			SET @LegacyActive_update = 'Y'
		END

	IF @TYPE_update = 'Asset'
		BEGIN
			SET @LegacyType_update = 'A'
			SET @LegacySide_update = 'D'
		END
	ELSE IF @TYPE_update = 'Liability'
		BEGIN
			SET @LegacyType_update = 'L'
			SET @LegacySide_update = 'C'
		END
	ELSE IF @TYPE_update = 'Equity'
		BEGIN
			SET @LegacyType_update = 'Q'
			SET @LegacySide_update = 'C'
		END
	ELSE IF @TYPE_update = 'Revenue'
		BEGIN
			SET @LegacyType_update = 'I'
			SET @LegacySide_update = 'C'
		END
	ELSE IF @TYPE_update = 'Expense'
		BEGIN
			SET @LegacyType_update = 'E'
			SET @LegacySide_update = 'D'
		END
	ELSE IF @TYPE_update = 'Cost of Goods Sold'
		BEGIN
			SET @LegacyType_update = 'C'
			SET @LegacySide_update = 'D'
		END
	ELSE IF @TYPE_update = 'Sales'
		BEGIN
			SET @LegacyType_update = 'I'
			SET @LegacySide_update = 'C'
		END
	
	INSERT INTO glactmst (
		[glact_acct1_8],
		[glact_acct9_16],
		[glact_desc],
		[glact_type],
		[glact_normal_value],
		[glact_saf_cat],
		[glact_flow_cat],
		[glact_uom],
		[glact_verify_flag],
		[glact_active_yn],
		[glact_sys_acct_yn],
		[glact_desc_lookup],
		[glact_user_fld_1],
		[glact_user_fld_2],
		[glact_user_id],
		[glact_user_rev_dt]
		)
	VALUES (
		CONVERT(INT, SUBSTRING(@ACCOUNT_update,1,8)),
		CONVERT(INT, SUBSTRING(@ACCOUNT_update,9,16)),
		SUBSTRING(@DESCRIPTION_update,0,30),
		@LegacyType_update,
		@LegacySide_update,
		'',
		'',
		'',
		'',
		@LegacyActive_update,
		'N',
		'',
		'',
		'',
		@intUserID,
		CONVERT(INT, CONVERT(VARCHAR(8), GETDATE(), 112))
		)
				
		UPDATE tblGLCOACrossReference SET intLegacyReferenceID = (SELECT TOP 1 A4GLIdentity FROM glactmst ORDER BY A4GLIdentity DESC) WHERE inti21ID = @ID_update		
		DELETE FROM #TempUpdateCrossReference WHERE inti21ID = @ID_update
END
	
select 1


