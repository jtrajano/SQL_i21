CREATE PROCEDURE uspGLMergeSegmentAccount
(
  @ysnMergeCOA BIT = 0,
  @ysnClear BIT = 0
)
AS
BEGIN
    	SET XACT_ABORT ON
      
      EXEC uspGLValidateSubsidiarySetting

      IF @@ERROR > 0
        RETURN
      
      DECLARE @tblUnionSegments Table
      (
        [strCode]				NVARCHAR (20) COLLATE Latin1_General_CI_AS NOT NULL,  
        [strDescription]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
        [strChartDesc]        NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
        [strAccountCategory]			NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
        [strAccountGroup]		NVARCHAR (100) COLLATE Latin1_General_CI_AS  NULL,
        [strAccountType]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,  
        [strStructureName]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
        idx   INT
      )
      DECLARE @tblSubsidiary TABLE 
      (
        [intSubsidiaryCompanyId] INT,
        [strCompany] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL	,
        [strDatabase] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL	,
        [ysnCompanySegment] BIT NULL,
        [hasCompanySegment] BIT NULL
      )

      IF @ysnClear =  1
      BEGIN
        DELETE FROM tblGLAccountSegmentMapping
		    DELETE FROM tblGLSummary
        DELETE FROM tblGLDetail
        DELETE FROM tblGLAccount
        DELETE A FROM tblGLAccountSegment A JOIN  vyuGLSegmentDetail B on A.intAccountSegmentId = B.intAccountSegmentId where intStructureType <> 6
        UPDATE tblGLSubsidiaryCompany SET intLastGLDetailId = NULL, ysnMergedCOA = 0
      END

      INSERT INTO @tblSubsidiary SELECT intSubsidiaryCompanyId,strCompany, strDatabase, ysnCompanySegment , hasCompanySegment FROM tblGLSubsidiaryCompany
      DECLARE @strDatabase NVARCHAR(40)
      DECLARE @strCompany NVARCHAR(40)
      DECLARE @ysnCompanySegment BIT
      DECLARE @hasCompanySegment BIT
      DECLARE @strErrorMsg NVARCHAR(MAX)
      DECLARE @idx INT = 1
      DECLARE @strSQL NVARCHAR(max)

      WHILE EXISTS (SELECT TOP 1 1 FROM @tblSubsidiary)
      BEGIN
        SELECT TOP 1 
        @strCompany = strCompany,
        @strDatabase = strDatabase ,
        @hasCompanySegment = ISNULL(hasCompanySegment,0),
        @ysnCompanySegment =ISNULL(ysnCompanySegment,0) FROM @tblSubsidiary


        SET @strSQL = 
        REPLACE ('SELECT  strCode, strDescription,strChartDesc,  strAccountCategory, strAccountGroup,strAccountType, 
        strStructureName , [idx]  from [strDatabase].dbo.vyuGLSegmentDetail '
        , '[strDatabase]', @strDatabase)

        SET @strSQL = REPLACE (@strSQL, '[idx]' , CAST( @idx AS NVARCHAR(2)))

        IF @ysnCompanySegment = 1
          SET @strSQL = @strSQL + 'where intStructureType <> 6'
        ELSE
        BEGIN
          IF @hasCompanySegment = 0
            SET @strErrorMsg = 'Company ' + @strCompany + ' has no company segment.'
            RAISERROR(@strErrorMsg, 16,1)
            RETURN
        END

        INSERT INTO @tblUnionSegments EXEC (@strSQL)
        SET @idx+=1
        DELETE FROM @tblSubsidiary WHERE @strDatabase = strDatabase 
      END

      ;WITH allAccounts AS(
        SELECT strCode,   
        strAccountGroup,   
        strAccountType, 
        strStructureName,  
        strAccountCategory,   
        strDescription,
        strChartDesc,
        ROW_NUMBER() OVER(PARTITION BY strCode, strAccountType,strStructureName   ORDER BY idx) rowId
        FROM @tblUnionSegments
      )
      ,tblUnionSegments  
      as(
        SELECT * 
        FROM allAccounts   
        WHERE rowId = 1
      )
      MERGE into tblGLAccountSegment  
      WITH (holdlock)  
      AS SegmentTable  
      USING (   
      select   
      strCode,  
      G.intAccountGroupId,  
      C.intAccountCategoryId,  
      S.intAccountStructureId,  
      A.strStructureName,
      A.strDescription,
      A.strChartDesc
      from tblUnionSegments A   
      left join tblGLAccountGroup G on G.strAccountGroup = A.strAccountGroup  
      left join tblGLAccountCategory C on C.strAccountCategory = A.strAccountCategory  
      join tblGLAccountStructure S on S.strStructureName = A.[strStructureName]   
      )As MergedTable   
      ON SegmentTable.strCode = MergedTable.strCode AND SegmentTable.intAccountStructureId = MergedTable.intAccountStructureId  
        
      WHEN MATCHED THEN   
        UPDATE   
        SET  SegmentTable.intAccountGroupId = MergedTable.intAccountGroupId,  
          SegmentTable.intAccountCategoryId = MergedTable.intAccountCategoryId,  
          SegmentTable.strDescription = MergedTable.strDescription,
          SegmentTable.strChartDesc = MergedTable.strChartDesc
      WHEN NOT MATCHED BY TARGET THEN  
      INSERT (  
        strCode,  
        intAccountGroupId,  
        intAccountCategoryId,  
        intAccountStructureId,
        strDescription,
        strChartDesc
      )  
      VALUES  
      (  
        MergedTable.strCode,  
        MergedTable.intAccountGroupId,  
        MergedTable.intAccountCategoryId,  
        MergedTable.intAccountStructureId,
        MergedTable.strDescription,
        MergedTable.strChartDesc
      ); 
      
      IF @ysnMergeCOA = 1
          EXEC uspGLMergeGLAccount @ysnClear
      
      
END