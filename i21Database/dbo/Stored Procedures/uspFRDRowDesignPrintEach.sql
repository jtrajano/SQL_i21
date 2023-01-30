CREATE PROCEDURE [dbo].[uspFRDRowDesignPrintEach]
	@intRowId		AS INT,
	@ysnSupressZero	AS BIT,
	@intSegmentCode as int = 0 
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
DECLARE @ysnShowCurrencies  BIT      
DECLARE @intCurrencyID INT      
DECLARE @queryString NVARCHAR(MAX)
DECLARE @intSubRowDetailId NVARCHAR(MAX)  
DECLARE @strCurrency NVARCHAR(50)    
DECLARE @strQuery NVARCHAR(max)        
DECLARE @ysnUnnaturalAccount INT = 0  
DECLARE @hasAccount BIT 

CREATE TABLE #tempGLAccount (
		[intAccountId]		INT,
		[strAccountId]		NVARCHAR(150),
		[strAccountType]	NVARCHAR(MAX),
		[strDescription]	NVARCHAR(MAX),
		[intRowDetailId]  INT
	);

CREATE TABLE #tempGLAccount2 (    
  [intAccountId]  INT,    
  [strAccountId]  NVARCHAR(150),    
  [strAccountType] NVARCHAR(MAX),    
  [strDescription] NVARCHAR(MAX),   
  [intRowDetailId]  INT
 );   

CREATE TABLE #TempGLUnnatural (                  
 [intCnt] int        
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
					@intSort					= [intSort],
					@ysnShowCurrencies			= [ysnShowCurrencies]  ,  
					@intCurrencyID				= [intCurrencyID],  
					@strCurrency				= [strCurrency],  
					@intSubRowDetailId			= [intRowDetailId]  
				
					FROM #tempRowDesignPrintEach ORDER BY [intSort]
				
		IF(@ysnSupressZero = 1 and @strAccountsType != 'RE')
		BEGIN
			SET @queryString = 'SELECT DISTINCT intAccountId, strAccountId, strAccountType, strDescription,'''+@intSubRowDetailId+''' FROM ( ' +
									'SELECT DISTINCT A.intAccountId, strAccountId, strAccountGroup, strAccountType, strAccountId + '' - '' + strDescription as strDescription FROM vyuGLSummary A ' +
										'WHERE ' + REPLACE(REPLACE(REPLACE(REPLACE(@strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ' ' +
									'UNION ' +
									'SELECT DISTINCT B.intAccountId, strAccountId, strAccountGroup, strAccountType, strAccountId + '' - '' + strDescription as strDescription FROM vyuGLAccountView B ' +
										'INNER JOIN tblFRBudget C on C.intAccountId = B.intAccountId ' +
										'WHERE ' + REPLACE(REPLACE(REPLACE(REPLACE(@strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ' ' +
								') tblX ' +
								'WHERE intAccountId IS NOT NULL ORDER BY strAccountId'
		END
		ELSE
		BEGIN
			SET @queryString = 'SELECT intAccountId, strAccountId, strAccountType, strAccountId + '' - '' + strDescription as strDescription,'''+@intSubRowDetailId+''' FROM vyuGLAccountView where (' + REPLACE(REPLACE(REPLACE(REPLACE(@strAccountsUsed,'[ID]','strAccountId'),'[Group]','strAccountGroup'),'[Type]','strAccountType'),'[Description]','strDescription') + ') AND intAccountId IS NOT NULL ORDER BY strAccountId'
		END

		INSERT INTO #tempGLAccount2    
		EXEC (@queryString)   

		IF @intSegmentCode <> 0
			BEGIN	
				INSERT INTO #tempGLAccount    		
				SELECT T0.* FROM #tempGLAccount2 T0
				INNER JOIN tblGLTempCOASegment T1
				ON T0.intAccountId = T1.intAccountId
				WHERE T1.Location in (select strSegmentCode from tblFRSegmentFilterGroupDetail where intSegmentFilterGroupId = @intSegmentCode)
			END	
		ELSE	
			BEGIN	
				INSERT INTO #tempGLAccount    
				SELECT * FROM #tempGLAccount2   
				
			END	

			TRUNCATE TABLE #tempGLAccount2    

		DECLARE @intAccountId INT
		DECLARE @strAccountId NVARCHAR(150)
		DECLARE @strAccountType NVARCHAR(150)
		DECLARE @strAccountDescription NVARCHAR(MAX)
		DECLARE @REAccount NVARCHAR(100)

		WHILE EXISTS(SELECT 1 FROM #tempGLAccount WHERE intRowDetailId = @intSubRowDetailId)
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

			SET @hasAccount = (SELECT ISNULL(ysnUnnaturalAccount,0) FROM tblFRRowDesign where intRowDetailId =  @intSubRowDetailId)

			 SET @strQuery = '    
			 INSERT INTO #TempGLUnnatural    
			 SELECT SUM(CNT) FROM (    
			 SELECT COUNT(0)CNT FROM vyuGLSummary WHERE strAccountId = '''+@strAccountId+''' AND ISNULL(intUnAccountId,0) <> 0    
			 UNION ALL    
			 SELECT COUNT(0)CNT FROM vyuGLSummary WHERE strUnAccountId = '''+@strAccountId+'''    
			 ) A    
			  '    

			EXEC(@strQuery)      
			SET @ysnUnnaturalAccount = 0
			
			IF @hasAccount = 1
			BEGIN
				SET @ysnUnnaturalAccount = (
					SELECT CASE WHEN intCnt <> 0 THEN 1 ELSE 0 END FROM #TempGLUnnatural
				)  
			END
  
			 TRUNCATE TABLE #TempGLUnnatural      

			INSERT INTO #tempRowDesign (intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,intConcurrencyId,ysnShowCurrencies,intCurrencyID,strCurrency,ysnUnnaturalAccount)
								VALUES (@intRowId,@intRefNo,@strAccountDescription,@strRowType,@strBalanceSide,@strSource,@strRelatedRows,'[ID] = ''' + @strAccountId + '''',@strPercentage,@strAccountsType,@ysnShowCredit,@ysnShowDebit,@ysnShowOthers,@ysnLinktoGL,1,@ysnHidden,@dblHeight,@strFontName,@strFontStyle,@strFontColor,@intFontSize,@strOverrideFormatMask,@ysnForceReversedExpense,@ysnOverrideFormula,@ysnOverrideColumnFormula,@intSort,1,@ysnShowCurrencies,@intCurrencyID,@strCurrency,@ysnUnnaturalAccount)

			DELETE #tempGLAccount WHERE [intAccountId] = @intAccountId
		END

		DELETE #tempRowDesignPrintEach WHERE [intRowDetailId] = @intRowDetailId
	END

	INSERT INTO tblFRRowDesignPrintEach (intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,strAccountsUsed,strPercentage,strAccountsType,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,dtmEntered,intConcurrencyId,ysnShowCurrencies,intCurrencyID,strCurrency,ysnUnnaturalAccount)
	SELECT intRowId,intRefNo,strDescription,strRowType,strBalanceSide,strSource,strRelatedRows,        
	strAccountsUsed,strPercentage,strAccountsType,ysnShowCredit,ysnShowDebit,ysnShowOthers,ysnLinktoGL,ysnPrintEach,ysnHidden,dblHeight,strFontName,        
	strFontStyle,strFontColor,intFontSize,strOverrideFormatMask,ysnForceReversedExpense,ysnOverrideFormula,ysnOverrideColumnFormula,intSort,GETDATE() as dtmEntered,@ConcurrencyId as intConcurrencyId,ysnShowCurrencies,intCurrencyID,strCurrency,ysnUnnaturalAccount
	FROM #tempRowDesign

END

DELETE #tempGLAccount
DELETE #tempRowDesignPrintEach
DELETE #tempRowDesign
DROP TABLE #tempGLAccount
DROP TABLE #tempGLAccount2
DROP TABLE #tempRowDesignPrintEach
DROP TABLE #tempRowDesign

--=====================================================================================================================================
-- 	SCRIPT EXECUTION 
---------------------------------------------------------------------------------------------------------------------------------------

--EXEC [dbo].[uspFRDRowDesignPrintEach] 51,0,4   
