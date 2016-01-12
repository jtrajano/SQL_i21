CREATE PROCEDURE [dbo].[uspFRDCreateRowDesign]

	@intRowId INT,
	@intRefNo INT,
	@strDescription NVARCHAR(MAX),
	@strRowType NVARCHAR(100),
	@strBalanceSide NVARCHAR(20),
	@strSource NVARCHAR(20),
	@strRelatedRows NVARCHAR(MAX),
	@strAccountsUsed NVARCHAR(MAX),
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

DECLARE @AccountsType NVARCHAR(50) = ''
DECLARE @Hidden BIT = 0

IF(@strBalanceSide = 'Debit')
BEGIN
	SET @AccountsType = 'BS'
END
ELSE IF(@strBalanceSide = 'Credit')
BEGIN
	SET @AccountsType = 'IS'
END

IF(@strRowType = 'Hidden')
BEGIN
	SET @Hidden = 1
	SET @strRowType = 'Filter Accounts'
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
								@AccountsType,
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
								@ysnForceReversedExpense,
								@ysnOverrideFormula,
								@intSort

END

