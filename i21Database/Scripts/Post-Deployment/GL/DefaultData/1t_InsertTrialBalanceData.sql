GO
PRINT ('Started Recalculating Trial Balance')
GO
    IF NOT EXISTS (SELECT TOP 1 1 FROM  tblGLTrialBalance )
    BEGIN
        EXEC dbo.uspGLRecalcTrialBalance
    END
GO
PRINT ('Finished Recalculating Trial Balance')
GO