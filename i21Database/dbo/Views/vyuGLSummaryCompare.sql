CREATE VIEW [dbo].[vyuGLSummaryCompare]      
   AS      
    SELECT * FROM (      
        SELECT  A.strReport,A.dtmDateEntered,A.dtmDate, A.dblDebit, A.dblCredit, A.dblDebitUnit, A.dblCreditUnit,A.dblDebitForeign,A.dblCreditForeign, ISNULL(A.strCode,'') strCode, B.strDescription, C.strAccountGroup, C.strAccountType, D.*,
        E.strUOMCode, E.dblLbsPerUnit , A.intCurrencyId , F.strCurrency,B.intUnnaturalAccountId            
        FROM  dbo.tblGLPostedCompare AS A         
        INNER JOIN dbo.tblGLAccount AS B ON B.intAccountId = A.intAccountId         
        INNER JOIN dbo.tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId        
        LEFT JOIN dbo.tblGLTempCOASegment AS D ON D.intAccountId = B.intAccountId        
        LEFT JOIN dbo.tblGLAccountUnit AS E ON E.intAccountUnitId = B.intAccountUnitId        
        INNER JOIN dbo.tblSMCurrency AS F ON F.intCurrencyID= A.intCurrencyId       
    )T0 LEFT JOIN (       
        SELECT B.intAccountId intUnAccountId,B.strAccountId strUnAccountId,B.strDescription strUnDescription, C.strAccountGroup strUnAccountGroup, C.strAccountType strUnAccountType,Location UnLocation, [Primary Account] AS [UnPrimary Account] FROM      
        dbo.tblGLAccount B      
        INNER JOIN dbo.tblGLAccountGroup AS C ON C.intAccountGroupId = B.intAccountGroupId        
        LEFT JOIN dbo.tblGLTempCOASegment AS D ON D.intAccountId = B.intAccountId        
        LEFT JOIN dbo.tblGLAccountUnit AS E ON E.intAccountUnitId = B.intAccountUnitId        
    )T1 ON T0.intUnnaturalAccountId = T1.intUnAccountId 