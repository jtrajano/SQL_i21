CREATE PROCEDURE [dbo].[uspFRDRowDesignPrintEach]
	@intRowId		AS INT,
	@ysnSupressZero	AS BIT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

DECLARE @intRowDetailId INT
DECLARE @intRefNo INT
DECLARE @strDescription NVARCHAR(MAX)
DECLARE @strRowType NVARCHAR(MAX)
DECLARE @strBalanceSide NVARCHAR(MAX)
DECLARE @strSource NVARCHAR(MAX)
DECLARE @strRelatedRows NVARCHAR(MAX)
DECLARE @strAccountsUsed NVARCHAR(MAX)
DECLARE @strPercentage NVARCHAR(MAX)
DECLARE @strAccountsType NVARCHAR(MAX)
DECLARE @ysnShowCredit BIT
DECLARE @ysnShowDebit BIT
DECLARE @ysnShowOthers BIT
DECLARE @ysnLinktoGL BIT
DECLARE @ysnPrintEach BIT
DECLARE @ysnHidden BIT
DECLARE @dblHeight NUMERIC(18, 6)
DECLARE @strFontName NVARCHAR(MAX)
DECLARE @strFontStyle NVARCHAR(MAX)
DECLARE @strFontColor NVARCHAR(MAX)
DECLARE @intFontSize INT
DECLARE @strOverrideFormatMask NVARCHAR(MAX)
DECLARE @ysnForceReversedExpense BIT
DECLARE @ysnOverrideFormula BIT
DECLARE @ysnOverrideColumnFormula BIT
DECLARE @intSort INT
DECLARE @queryString NVARCHAR(MAX)

CREATE TABLE #tempGLAccount (
		[intAccountId]		INT,
		[strAccountId]		NVARCHAR(150),
		[strAccountType]	NVARCHAR(MAX),
		[strDescription]	NVARCHAR(MAX)
	);

DECLARE @ConcurrencyId AS INT = (SELECT TOP 1 intConcurrencyId FROM tblFRRow WHERE intRowId = @intRowId)

SELECT * INTO #tempRowDesign FROM tblFRRowDesign WHERE intRowId = @intRowId
SELECT * INTO #tempRowDesignPrintEach FROM tblFRRowDesign WHERE intRowId = @intRowId AND ysnPrintEach = 1

DELETE tblFRRowDesignPrintEach WHERE intRowId = @intRowId
UPDATE #tempRowDesign SET ysnHidden = 1 WHERE ysnPrintEach = 1

IF NOT EXISTS(SELECT TOP 1 1 FROM tblFRRowDesignPrintEach WHERE intRowId = @intRowId AND intConcurrencyId = @ConcurrencyId)
	BEGIN	

	WHILE EXISTS(SELECT 1 FROM #tempRowDesignPrintEach)
	BEGIN
		SELECT TOP 1 @intRowDetailId			= [intRowDetailId], 
					@strAccountsUsed			= [strAccountsUsed],
					@intRowId					= [intRowId],
					@intRefNo					= [intRefNo],
					@strDescription				= [strDescription],
					@strRowType					= [strRowType],
					@strBalanceSide				= [strBalanceSide],
					@strSource					= [strSource],
					@strRelatedRows				= [strRelatedRows],
					@strAccountsUsed			= [strAccountsUsed],
					@strPercentage				= [strPercentage],
					@strAccountsType			= [strAccountsType],
					@ysnShowCredit				= [ysnShowCredit],
					@ysnShowDebit				= [ysnShowDebit],
					@ysnShowOthers				= [ysnShowOthers],
					@ysnLinktoGL				= [ysnLinktoGL],
					@ysnPrintEach				= [ysnPrintEach],					
					@ysnHidden					= [ysnHidden],
					@dblHeight					= [dblHeight],
					@strFontName				= [strFontName],
					@strFontStyle				= [strFontStyle],
					@strFontColor				= [strFontColor],
					@intFontSize				= [intFontSize],
					@strOverrideFormatMask		= [strOverrideFormatMask],
					@ysnForceReversedExpense	= [ysnForceReversedExpense],
					@ysnOverrideFormula			= [ysnOverrideFormula],
					@ysnOverrideColumnFormula	= [ysnOverrideColumnFormula],
					@intSort					= [intSort]
				
					FROM #tempRowDesignPrintEach ORDER BY [intSort]
				
		IF(@ysnSupressZero = 1 and @strAccountsType != 'RE')
		BEGIN
			SET @queryString = 'SELECT intAccountId, strAccountId, strAccountType, strAccountId + '' - '' + strDescription as strDescription FROM vyuGLSummary where ' + REPLACE(REPLACE(REPLACE(REPLACE(@strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ' ORDER BY strAccountId'
		END
		ELSE
		BEGIN
			SET @queryString = 'SELECT intAccountId, strAccountId, strAccountType, strAccountId + '' - '' + strDescription as strDescription FROM vyuGLAccountView where ' + REPLACE(REPLACE(REPLACE(REPLACE(@strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ' ORDER BY strAccountId'
		END

		INSERT INTO #tempGLAccount
		EXEC (@queryString)

		DECLARE @intAccountId INT
		DECLARE @strAccountId NVARCHAR(150)
		DECLARE @strAccountType NVARCHAR(150)
		DECLARE @strAccountDescription NVARCHAR(MAX)
		DECLARE @REAccount NVARCHAR(100)

		WHILE EXISTS(SELECT 1 FROM #tempGLAccount)
		BEGIN
			SELECT TOP 1 @intAccountId			= [intAccountId],
						 @strAccountId			= [strAccountId], 
						 @strAccountType		= [strAccountType],
						 @strAccountDescription = [strDescription] FROM #tempGLAccount ORDER BY [strAccountId]

			SET @REAccount = (SELECT TOP 1 ISNULL(strAccountId,'') FROM tblGLAccount WHERE intAccountId = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear WHERE intFiscalYearId = (SELECT TOP 1 intFiscalYearId FROM tblGLCurrentFiscalYear)))

			IF(@REAccount = '')
			BEGIN
				SET @REAccount = (SELECT TOP 1 ISNULL(strAccountId,'') FROM tblGLAccount WHERE intAccountId = (SELECT TOP 1 intRetainAccount FROM tblGLFiscalYear))
			END

			IF(@REAccount = @strAccountId)
			BEGIN
				SET @strAccountsType = 'RE'
			END	
			ELSE IF(@strAccountType = 'Asset' or  @strAccountType = 'Equity' or @strAccountType = 'Liability')
			BEGIN
				SET @strAccountsType = 'BS'
			END
			ELSE IF(@strAccountType = 'Expense' or @strAccountType = 'Revenue')
			BEGIN
				SET @strAccountsType = 'IS'
			END

			INSERT INTO #tempRowDesign (intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId)
								VALUES (@intRowId,@intRefNo,@strAccountDescription,@strRowType,@strBalanceSide,@strSource,@strRelatedRows,'[ID] = ''' + @strAccountId + '''',@strPercentage,@strAccountsType,@ysnShowCredit,@ysnShowDebit,@ysnShowOthers,@ysnLinktoGL,1,@ysnHidden,@dblHeight,@strFontName,@strFontStyle,@strFontColor,@intFontSize,@strOverrideFormatMask,@ysnForceReversedExpense,@ysnOverrideFormula,@ysnOverrideColumnFormula,@intSort,1)

			DELETE #tempGLAccount WHERE [intAccountId] = @intAccountId
		END

		DELETE #tempRowDesignPrintEach WHERE [intRowDetailId] = @intRowDetailId
	END
	
	INSERT INTO tblFRRowDesignPrintEach
	SELECT intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,
			strAccountsUsed,strPercentage,strAccountsType,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,
			strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,GETDATE() as dtmEntered,@ConcurrencyId as intConcurrencyId 
	FROM #tempRowDesign

END

DELETE #tempGLAccount
DELETE #tempRowDesignPrintEach
DELETE #tempRowDesign
DROP TABLE #tempGLAccount
DROP TABLE #tempRowDesignPrintEach
DROP TABLE #tempRowDesign

--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDRowDesignPrintEach] 7
