GO
    EXEC dbo.uspGLUpdateAccountLocationId
GO
    UPDATE A SET A.ysnRevalue = 1
    FROM tblGLAccount A 
    JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
    WHERE strAccountType IN ('Asset','Liability', 'Equity')
    AND A.ysnRevalue IS NULL
GO
