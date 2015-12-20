CREATE PROCEDURE [dbo].[uspFRDRowDesignPrintEach]
	@intRowId	AS INT
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
DECLARE @ysnShowCredit BIT
DECLARE @ysnShowDebit BIT
DECLARE @ysnShowOthers BIT
DECLARE @ysnLinktoGL BIT
DECLARE @ysnPrintEach BIT
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

DELETE tblFRRowDesignPrintEach WHERE dtmEntered < DATEADD(day, -1, GETDATE())

IF NOT EXISTS(SELECT TOP 1 1 FROM tblFRRowDesignPrintEach WHERE intRowId = @intRowId AND intConcurrencyId = @ConcurrencyId)
	BEGIN

	DELETE tblFRRowDesignPrintEach WHERE intRowId = @intRowId

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
					@ysnShowCredit				= [ysnShowCredit],
					@ysnShowDebit				= [ysnShowDebit],
					@ysnShowOthers				= [ysnShowOthers],
					@ysnLinktoGL				= [ysnLinktoGL],
					@ysnPrintEach				= [ysnPrintEach],
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
				
		SET @queryString = 'SELECT intAccountId, strAccountId, strAccountType, strAccountId + '' - '' + strDescription as strDescription FROM vyuGLAccountView where ' + REPLACE(REPLACE(REPLACE(REPLACE(@strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ' ORDER BY strAccountId'

		INSERT INTO #tempGLAccount
		EXEC (@queryString)

		DECLARE @intAccountId INT
		DECLARE @strAccountId NVARCHAR(150)
		DECLARE @strAccountType NVARCHAR(150)
		DECLARE @strAccountDescription NVARCHAR(MAX)

		WHILE EXISTS(SELECT 1 FROM #tempGLAccount)
		BEGIN
			SELECT TOP 1 @intAccountId			= [intAccountId],
						 @strAccountId			= [strAccountId], 
						 @strAccountType		= [strAccountType],
						 @strAccountDescription = [strDescription] FROM #tempGLAccount ORDER BY [strAccountId]

			INSERT INTO #tempRowDesign (intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId)
								VALUES (@intRowId,@intRefNo,@strAccountDescription,@strRowType,@strBalanceSide,@strSource,@strRelatedRows,'[ID] = ''' + @strAccountId + '''',@ysnShowCredit,@ysnShowDebit,@ysnShowOthers,@ysnLinktoGL,0,@dblHeight,@strFontName,@strFontStyle,@strFontColor,@intFontSize,@strOverrideFormatMask,@ysnForceReversedExpense,@ysnOverrideFormula,@ysnOverrideColumnFormula,@intSort,1)

			DELETE #tempGLAccount WHERE [intAccountId] = @intAccountId
		END

		DELETE #tempRowDesignPrintEach WHERE [intRowDetailId] = @intRowDetailId
	END
	
	INSERT INTO tblFRRowDesignPrintEach
	SELECT intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,
			strAccountsUsed,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,dblHeight,strFontName,
			strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,GETDATE() as dtmEntered,@ConcurrencyId as intConcurrencyId 
	FROM #tempRowDesign

END



--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDRowDesignPrintEach] 7
