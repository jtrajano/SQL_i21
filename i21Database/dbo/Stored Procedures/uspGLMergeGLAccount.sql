
CREATE PROCEDURE uspGLMergeGLAccount
  @ysnClear BIT  = 0
AS
BEGIN

    SET XACT_ABORT ON

    IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLAccountSegment)
    BEGIN
        RAISERROR( 'Account Segments are missing.',  16,1 )
        RETURN
    END


        

    IF @ysnClear = 1
    BEGIN
		DELETE FROM tblGLSummary
        DELETE FROM tblGLAccountSegmentMapping
		DELETE FROM tblGLDetail
		DELETE FROM tblGLAccount		
    END

    DECLARE @tblUnionAccounts Table(  
        strAccountId		NVARCHAR (40)  COLLATE Latin1_General_CI_AS NOT NULL,  
		strDescription		NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,  
        strAccountGroup		NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,  
		strAccountType		NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,
		strUOMCode			NVARCHAR (40)  COLLATE Latin1_General_CI_AS NULL,  
        strComments			NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
        ysnActive           BIT NULL,
        idx                 INT
    )  

    DECLARE @tblSubsidiary TABLE 
    (
      [intSubsidiaryCompanyId] [int],
      [strCompanySegment] NVARCHAR(10)COLLATE Latin1_General_CI_AS NULL,
      [strDatabase] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL	
    )

    INSERT INTO @tblSubsidiary SELECT intSubsidiaryCompanyId, strCompanySegment, strDatabase FROM tblGLSubsidiaryCompany
    DECLARE @strDatabase NVARCHAR(40)
    DECLARE @strCompanySegment NVARCHAR(10)
	DECLARE @strSQL NVARCHAR(MAX)
    DECLARE @idx INT = 1

	

	
    
    WHILE EXISTS (SELECT TOP 1 1 FROM @tblSubsidiary)
        BEGIN
          SELECT TOP 1 @strDatabase = strDatabase, @strCompanySegment = ISNULL( '-' + strCompanySegment, '') FROM @tblSubsidiary
          SET @strSQL = REPLACE ('select strAccountId + ''[strCompanySegment]'' strAccountId, strDescription, strAccountGroup, strAccountType, strUOMCode, strComments, ysnActive, [idx] from [strDatabase].dbo.vyuGLAccountDetail'
          , '[strDatabase]', @strDatabase)

          SET @strSQL = REPLACE(@strSQL , '[idx]', cast( @idx as nvarchar(2)))
          SET @strSQL = REPLACE (@strSQL , '[strCompanySegment]', @strCompanySegment)
          INSERT INTO @tblUnionAccounts EXEC (@strSQL)
          
          DELETE FROM @tblSubsidiary WHERE @strDatabase = strDatabase 
    END



    ;WITH allAccounts
    as(
        SELECT strAccountId, 
        strDescription,  
        strAccountGroup, 
        strComments,
        strUOMCode,
        ysnActive,
        ROW_NUMBER() OVER(PARTITION BY strAccountId, strAccountType  ORDER BY idx) rowId
		from @tblUnionAccounts  
        
    ),
    tblUnionAccounts AS(
        SELECT * FROM allAccounts where rowId = 1
    )


    MERGE INTO tblGLAccount  
    WITH (holdlock)  
    AS AccountTable  
    USING(  
        SELECT   
        strAccountId,  
        strDescription,  
        G.intAccountGroupId,  
        strComments,
        U.intAccountUnitId,
        ysnActive
        FROM tblUnionAccounts A   
        LEFT JOIN tblGLAccountGroup G on G.strAccountGroup = A.strAccountGroup  
        LEFT JOIN tblGLAccountUnit U on U.strUOMCode = A.strUOMCode
    )As MergedTable   
    ON AccountTable.strAccountId = MergedTable.strAccountId 
    
    WHEN MATCHED THEN   
    UPDATE   
    SET  
        AccountTable.intAccountGroupId = MergedTable.intAccountGroupId,  
        AccountTable.strDescription = MergedTable.strDescription,
        AccountTable.intAccountUnitId = MergedTable.intAccountUnitId,
        AccountTable.ysnActive = MergedTable.ysnActive

    WHEN NOT MATCHED BY TARGET THEN  
    INSERT (  
        strAccountId,  
        intAccountGroupId,  
        intAccountUnitId,  
        strDescription,
        strComments,
        ysnActive 
    )  
    VALUES  
    (  
        MergedTable.strAccountId,  
        MergedTable.intAccountGroupId,  
        MergedTable.intAccountUnitId,  
        MergedTable.strDescription,
        MergedTable.strComments,
        MergedTable.ysnActive
    );  
    
    UPDATE tblGLSubsidiaryCompany SET ysnMergedCOA = 1
    
    
	EXEC uspGLRebuildSegmentMapping
   
END