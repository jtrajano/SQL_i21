GO
    
    EXEC dbo.uspGLUpdateAccountLocationId
GO

    IF NOT EXISTS ( SELECT 1 FROM tblGLDataFixLog WHERE strDescription ='Set GL Account should be revalued.')
    BEGIN
        UPDATE A SET ysnRevalue = 1
        FROM tblGLAccount A 
        JOIN vyuGLAccountDetail B ON A.intAccountId = B.intAccountId
        WHERE strAccountType IN ('Asset','Liability', 'Equity')
        INSERT INTO tblGLDataFixLog(dtmDate, strDescription) VALUES(GETDATE(), 'Set GL Account should be revalued.')
    END
GO


