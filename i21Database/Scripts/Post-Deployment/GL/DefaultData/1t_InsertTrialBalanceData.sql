GO
PRINT ('Started Recalculating Trial Balance')
GO
IF NOT EXISTS (SELECT TOP 1 1 FROM tblGLDataFix WHERE strDescription ='Initialize Trial Balance')
    BEGIN
        EXEC dbo.uspGLRecalcTrialBalance
        
    INSERT INTO tblGLDataFix VALUES('Initialize Trial Balance')
    END

GO
PRINT ('Finished Recalculating Trial Balance')
GO