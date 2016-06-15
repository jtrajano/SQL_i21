CREATE PROCEDURE [dbo].[uspFRDCreateRowDesign]

	@intRowId INT,
	@intRefNo INT,
	@strDescription NVARCHAR(MAX),
	@strRowType NVARCHAR(100),
	@strBalanceSide NVARCHAR(20),
	@strSource NVARCHAR(20),
	@strRelatedRows NVARCHAR(MAX),
	@strAccountsUsed NVARCHAR(MAX),
	@strAccountsType NVARCHAR(MAX),
	@ysnShowCredit BIT,
	@ysnShowDebit BIT,
	@ysnShowOthers BIT,
	@ysnLinktoGL BIT,
	@dblHeight NUMERIC(16,8),
	@strFontName NVARCHAR(100),
	@strFontStyle NVARCHAR(100),
	@strFontColor NVARCHAR(100),
	@intFontSize INT,
	@strOverrideFormatMask NVARCHAR(200),	
	@ysnForceReversedExpense BIT,
	@ysnOverrideFormula BIT,
	@intSort INT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

DECLARE @Hidden BIT = 0
DECLARE @strDateOverride NVARCHAR(200)

IF(@strRowType = 'Hidden')
BEGIN
	SET @Hidden = 1
	SET @strRowType = 'Filter Accounts'
END
IF(@strAccountsType = 'CY')
BEGIN
	SET @Hidden = 1
END
IF(@strRowType = 'Filter Accounts' or @strRowType = 'Cash Flow Activity' or @strRowType = 'Percentage')
BEGIN
	SET @strDateOverride = 'None'
END


	INSERT INTO tblFRRowDesign (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								strAccountsType,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								ysnHidden,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								strDateOverride,
								ysnForceReversedExpense,
								ysnOverrideFormula,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								@strDescription,
								@strRowType,
								@strBalanceSide,
								@strSource,
								@strRelatedRows,
								@strAccountsUsed,
								@strAccountsType,
								@ysnShowCredit,
								@ysnShowDebit,
								@ysnShowOthers,
								@ysnLinktoGL,
								@Hidden,
								@dblHeight,
								@strFontName,
								@strFontStyle,
								@strFontColor,
								@intFontSize,
								@strOverrideFormatMask,
								@strDateOverride,
								@ysnForceReversedExpense,
								@ysnOverrideFormula,
								@intSort

END

