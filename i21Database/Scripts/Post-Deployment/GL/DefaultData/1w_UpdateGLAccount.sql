GO
    EXEC dbo.uspGLUpdateAccountSegmentId
GO
    UPDATE A SET A.ysnRevalue = 1
    FROM tblGLAccount A 
    JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
    WHERE strAccountType IN ('Asset','Liability', 'Equity')
    AND A.ysnRevalue IS NULL


    ;WITH cte AS (
        SELECT ROW_NUMBER() OVER(ORDER BY strAccountId ASC) rowId, intAccountId FROM tblGLAccount
    )
    UPDATE A SET intOrderId = rowId FROM tblGLAccount A JOIN cte B ON A.intAccountId = B.intAccountId
GO
