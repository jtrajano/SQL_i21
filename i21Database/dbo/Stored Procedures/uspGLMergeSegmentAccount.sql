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
        [strStructureName]		NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL  
      )
      DECLARE @tblSubsidiary TABLE 
      (
        [intSubsidiaryCompanyId] [int],
        [strDatabase] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL	
      )

      IF @ysnClear =  1
      BEGIN
        DELETE FROM tblGLAccountSegmentMapping
		    DELETE FROM tblGLSummary
        DELETE FROM tblGLDetail
        DELETE FROM tblGLAccount
        DELETE A FROM tblGLAccountSegment A JOIN  vyuGLSegmentDetail B on A.intAccountSegmentId = B.intAccountSegmentId where intStructureType <> 6
        UPDATE tblGLSubsidiaryCompany SET intLastGLDetailId = NULL
      END

      INSERT INTO @tblSubsidiary SELECT intSubsidiaryCompanyId, strDatabase FROM tblGLSubsidiaryCompany
      DECLARE @strDatabase NVARCHAR(40)

      DECLARE @strSQL NVARCHAR(max)

      WHILE EXISTS (SELECT TOP 1 1 FROM @tblSubsidiary)
      BEGIN
        SELECT TOP 1 @strDatabase = strDatabase FROM @tblSubsidiary
        SET @strSQL = 
        REPLACE ('SELECT  strCode, strDescription,strChartDesc,  strAccountCategory, strAccountGroup,strAccountType, strStructureName  from [strDatabase].dbo.vyuGLSegmentDetail where intStructureType <> 6'
        , '[strDatabase]', @strDatabase)
        INSERT INTO @tblUnionSegments EXEC (@strSQL)
        
        DELETE FROM @tblSubsidiary WHERE @strDatabase = strDatabase 
      END

      ;WITH tblUnionSegments  
      as(

        SELECT strCode,   
        MAX(isnull(strAccountGroup,'')) strAccountGroup,   
        strAccountType, strStructureName,  
        MAX(isnull(strAccountCategory,'')) strAccountCategory,   
        MAX(isnull(strDescription,'')) strDescription,
        MAX(isnull(strChartDesc,'')) strChartDesc
        FROM @tblUnionSegments   
        GROUP BY strCode, strAccountType,strStructureName  
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