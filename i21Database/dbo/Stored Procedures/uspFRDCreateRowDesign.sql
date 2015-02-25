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
	@intSort INT
	
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

BEGIN

	INSERT INTO tblFRRowDesign (intRowId,
								intRefNo,
								strDescription,
								strRowType,
								strBalanceSide,
								strSource,
								strRelatedRows,
								strAccountsUsed,
								ysnShowCredit,
								ysnShowDebit,
								ysnShowOthers,
								ysnLinktoGL,
								dblHeight,
								strFontName,
								strFontStyle,
								strFontColor,
								intFontSize,
								strOverrideFormatMask,
								ysnForceReversedExpense,
								intSort)

				SELECT			@intRowId,
								@intRefNo,
								@strDescription,
								@strRowType,
								@strBalanceSide,
								@strSource,
								@strRelatedRows,
								@strAccountsUsed,
								@ysnShowCredit,
								@ysnShowDebit,
								@ysnShowOthers,
								@ysnLinktoGL,
								@dblHeight,
								@strFontName,
								@strFontStyle,
								@strFontColor,
								@intFontSize,
								@strOverrideFormatMask,
								@ysnForceReversedExpense,
								@intSort

END

