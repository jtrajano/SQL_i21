CREATE PROCEDURE  [dbo].[uspGLImportOriginCOA]
@ysnStructure	BIT = 0,
@ysnPrimary		BIT = 0,
@ysnSegment		BIT = 0,
@ysnUnit		BIT = 0,
@ysnOverride	BIT = 0,
@ysnBuild		BIT = 0,
@result			NVARCHAR(500) = '' OUTPUT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON

IF (EXISTS(SELECT SegmentCode FROM (SELECT glact_acct1_8 AS SegmentCode,max(glact_desc) AS CodeDescription,glact_type FROM glactmst GROUP BY glact_acct1_8,glact_type) tblX group by SegmentCode HAVING COUNT(*) > 1) and @ysnOverride = 0)
BEGIN
	SET @result = 'There are accounts that are classified as an Income and Balance Sheet Type account. <br/> Kindly verify at Origin GL.'
END
ELSE IF ((SELECT COUNT(*) FROM (SELECT DISTINCT(LEN(glact_acct1_8)) AS SegmentCode FROM glactmst) tblSegment) > 1 and @ysnOverride = 0)
BEGIN
	SET @result = 'There are accounts with different lengths. <br/> Kindly verify at Origin GL.'
END
ELSE IF (EXISTS(SELECT TOP 1 1 FROM glactmst WHERE glact_acct9_16 NOT IN (SELECT glprc_sub_acct FROM glprcmst)) and @ysnOverride = 0)
BEGIN	
	SET @result = 'Some profit center does not exists at profit center master table. <br/> Kindly verify at Origin.'
END
ELSE
BEGIN
	-- IMPORT ACCOUNT STRUCTURE
	IF @ysnStructure = 1
	BEGIN
		DECLARE  @PrimaryLength		NUMERIC (18,6)
				,@SegmentLength		NUMERIC (18,6)
		
		SET @PrimaryLength = (SELECT MAX(LEN(glact_acct1_8)) glact_acct1_8 FROM glactmst)
		SET @SegmentLength = (SELECT MAX(LEN(glact_acct9_16)) glact_acct9_16 FROM glactmst)	
		
		DELETE tblGLAccountSegment
		DELETE tblGLAccountStructure
		
		INSERT tblGLAccountStructure (intStructureType,strStructureName,strType,intLength,strMask,intSort,ysnBuild,intStartingPosition)
								VALUES (1,'Primary Account','Primary', @PrimaryLength,'0',0,0,9 - @PrimaryLength)							
		INSERT tblGLAccountStructure (intStructureType,strStructureName,strType,intLength,strMask,intSort,ysnBuild,intStartingPosition)
								VALUES (2,'Hypen/Separator','Divider', 1,'-',1,0,0)							
		INSERT tblGLAccountStructure (intStructureType,strStructureName,strType,intLength,strMask,intSort,ysnBuild,intStartingPosition)
								VALUES (3,'Profit Center','Segment', @SegmentLength,'0',2,0,9 - @SegmentLength)
	END	

	-- IMPORT PRIMARY ACCOUNT
	IF @ysnPrimary = 1
	BEGIN
		DECLARE	@Length		INT
				,@query		VARCHAR(500)	
					
		SET @Length = ISNULL((SELECT intLength FROM tblGLAccountStructure WHERE strType = 'Primary'),0)
		SET @query = 'SELECT glact_acct1_8 AS SegmentCode,max(glact_desc) AS CodeDescription,glact_type FROM glactmst WHERE LEN(glact_acct1_8) = ' + CAST(@Length AS NVARCHAR(10)) + ' GROUP BY glact_acct1_8,glact_type'		
		
		DECLARE @tblQuery TABLE
		(
			 SegmentCode			NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
			,CodeDescription		NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL
			,glact_type				NVARCHAR(200) COLLATE Latin1_General_CI_AS NOT NULL
		)
		
		IF @ysnOverride = 1
		BEGIN
			SET @query = 'SELECT glact_acct1_8 AS SegmentCode,max(glact_desc) AS CodeDescription,glact_type = (SELECT TOP 1 glact_type FROM glactmst AS tempType WHERE tempType.glact_acct1_8 = tempCode.glact_acct1_8 GROUP BY glact_type) FROM glactmst AS tempCode WHERE LEN(glact_acct1_8) = ' + CAST(@Length AS NVARCHAR(10)) + ' GROUP BY glact_acct1_8'
		END

		INSERT INTO @tblQuery EXEC (@query)			

		UPDATE @tblQuery
		SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Asset' and intParentGroupId = 0)
		WHERE glact_type = 'A'

		UPDATE @tblQuery
		SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Expense' and intParentGroupId = 0)
		WHERE glact_type = 'E'

		UPDATE @tblQuery
		SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Liability' and intParentGroupId = 0)
		WHERE glact_type = 'L'

		UPDATE @tblQuery
		SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Expense' and strAccountGroup = 'Cost of Goods Sold')
		WHERE glact_type = 'C'

		UPDATE @tblQuery
		SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Revenue' and strAccountGroup = 'Sales')
		WHERE glact_type = 'I'

		UPDATE @tblQuery
		SET glact_type = (SELECT intAccountGroupId FROM tblGLAccountGroup WHERE strAccountType = 'Equity' and intParentGroupId = 0)
		WHERE glact_type = 'Q'
		
		DELETE tblGLAccountSegment where intAccountStructureId IN (SELECT intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Primary')		
		
		INSERT tblGLAccountSegment
			(strCode
			,strDescription
			,intAccountStructureId
			,intAccountGroupId
			,ysnActive
			,ysnSelected
			,ysnBuild
			,ysnIsNotExisting)
		SELECT
			SegmentCode
			,CodeDescription
			,(SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Primary')
			,glact_type = CASE WHEN glact_type = '' THEN NULL ELSE glact_type END
			,1
			,0
			,0
			,null
		FROM @tblQuery
		WHERE SegmentCode not in (SELECT strCode FROM tblGLAccountSegment)
		
	END
		
	-- IMPORT SEGMENT ACCOUNT
	IF @ysnSegment = 1
	BEGIN											
		SELECT glprc_sub_acct AS SegmentCode
				  ,glprc_desc = ISNULL((SELECT glprc_desc FROM glprcmst WHERE glprc_sub_acct = tblC.glprc_sub_acct),'')
			INTO #segments
			 FROM (
				SELECT * FROM (
						SELECT glprc_sub_acct FROM glprcmst WHERE LEN(glprc_sub_acct) = (SELECT LEN(MAX(glact_acct9_16)) FROM glactmst)
						) tblA
					UNION ALL SELECT * FROM (
								SELECT glact_acct9_16 as glprc_sub_acct FROM glactmst GROUP BY glact_acct9_16
								) tblB
				) tblC
			WHERE LEN(glprc_sub_acct) <= (SELECT LEN(MAX(glact_acct9_16)) FROM glactmst)
			GROUP BY glprc_sub_acct									
									
			
		DELETE tblGLAccountSegment where intAccountStructureId IN (SELECT intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Segment')
		
		INSERT tblGLAccountSegment
			(strCode
			,strDescription
			,intAccountStructureId
			,intAccountGroupId
			,ysnActive
			,ysnSelected
			,ysnBuild
			,ysnIsNotExisting)
		SELECT
			REPLICATE('0', (select len(max(SegmentCode)) from #segments) - len(SegmentCode)) + '' + CAST(SegmentCode AS NVARCHAR(50)) SegmentCode
			,glprc_desc
			,(SELECT TOP 1 intAccountStructureId FROM tblGLAccountStructure WHERE strType = 'Segment')
			,null
			,1
			,0
			,0
			,null
		FROM #segments
		WHERE SegmentCode not in (SELECT strCode FROM tblGLAccountSegment)
		
		DROP TABLE #segments		
	END
	
	-- IMPORT UNIT OF MEASURE
	IF @ysnUnit = 1
	BEGIN	
		DELETE tblGLAccountUnit
		
		INSERT tblGLAccountUnit (strUOMCode,strUOMDesc,dblLbsPerUnit,intConcurrencyId)
			SELECT gluom_code,gluom_desc,gluom_lbs_per_unit,1 FROM gluommst	
	END	
		
	-- BUILD COA
	IF @ysnBuild = 1
	BEGIN
		INSERT INTO tblGLTempAccountToBuild
		SELECT
			intAccountSegmentId
			,0
			,dtmCreated = getDate()
		FROM
		tblGLAccountSegment				
		
		EXEC uspGLBuildOriginAccount  0
		EXEC uspGLBuildAccount 0				
	END	
	
	SET @result = 'SUCCESSFULLY IMPORTED'
	
END