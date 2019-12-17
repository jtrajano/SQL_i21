PRINT 'Start removing F9 Shortcut'

DELETE FROM tblSMShortcutKeys WHERE strShortcutKey = 'F9' AND ysnCtrl <> 1 AND ysnShift <> 1 AND ysnAlt <> 1 

PRINT 'End removing F9 Shortcut'