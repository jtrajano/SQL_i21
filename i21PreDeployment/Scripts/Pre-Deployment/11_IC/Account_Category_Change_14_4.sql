﻿IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICItemAccount'))
BEGIN
	IF NOT EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblICItemAccount') AND name = 'intAccountCategoryId')
	BEGIN
		EXEC('
			ALTER TABLE tblICItemAccount
			ADD intAccountCategoryId INT
		')
		
		EXEC('
		UPDATE tblICItemAccount 
		SET intAccountCategoryId = CASE WHEN intAccountCategoryId IN (''COGS'', ''Cost of Goods'') THEN ''10''
								   WHEN intAccountCategoryId IN (''Sales'', ''Sales Account'') THEN ''33''
								   WHEN intAccountCategoryId IN (''Purchase'', ''Purchase Account'') THEN ''30''
								   WHEN intAccountCategoryId IN (''Variance'', ''Variance Account'') THEN ''40''
								   ELSE NULL END')
	END

END