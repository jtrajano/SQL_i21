GO
    EXEC dbo.uspGLUpdateAccountSegmentId
GO
    UPDATE A SET A.ysnRevalue = 1
    FROM tblGLAccount A 
    JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
    WHERE strAccountType IN ('Asset','Liability', 'Equity')
    AND A.ysnRevalue IS NULL

    -- FOR primary segment range query
    ;WITH cte AS (

        SELECT ROW_NUMBER() OVER(ORDER BY strCode ASC) rowId, intAccountSegmentId FROM tblGLAccountSegment A JOIN 
        tblGLAccountStructure B ON A.intAccountStructureId = A.intAccountStructureId WHERE strType= 'Primary'
    )
    UPDATE A SET intPrimaryOrderId = rowId FROM tblGLAccountSegment A JOIN cte B ON A.intAccountSegmentId = B.intAccountSegmentId

GO
