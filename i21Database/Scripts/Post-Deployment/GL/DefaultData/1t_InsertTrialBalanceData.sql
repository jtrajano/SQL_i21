GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM dbo.tblGLTrialBalance )
    BEGIN
        PRINT ('Started Recalculating Trial Balance')
        EXEC dbo.uspGLRecalcTrialBalance
        PRINT ('Finished Recalculating Trial Balance')
    END
GO
