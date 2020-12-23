PRINT 'Activating item locations...'

UPDATE tblICItemLocation
SET ysnActive = 1
WHERE ysnActive IS NULL

PRINT 'Finished activating item locations'