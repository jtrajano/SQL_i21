﻿IF EXISTS(SELECT TOP 1 1 FROM sys.objects WHERE name = 'CK_ItemUOMId_IS_NOT_USED' AND type = 'C' AND parent_object_id = OBJECT_ID('tblICItemUOM', 'U'))
BEGIN 
	EXEC ('
		ALTER TABLE tblICItemUOM
		DROP CONSTRAINT CK_ItemUOMId_IS_NOT_USED		
	')
END