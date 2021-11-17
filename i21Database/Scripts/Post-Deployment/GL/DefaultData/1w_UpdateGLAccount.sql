GO
    IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLDataFixLog WHERE strDescription= 'Update Account Location ID.')
    BEGIN
        EXEC dbo.uspGLUpdateAccountLocationId
        INSERT INTO tblGLDataFixLog(dtmDate, strDescription) VALUES(GETDATE(), 'Update Account Location ID.')
    END
GO

