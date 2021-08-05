PRINT 'Activating item locations...'

UPDATE tblICItemLocation
SET ysnActive = 1
WHERE ysnActive IS NULL
GO

sp_refreshview 'vyuICItemLocation'
GO

PRINT 'Finished activating item locations'