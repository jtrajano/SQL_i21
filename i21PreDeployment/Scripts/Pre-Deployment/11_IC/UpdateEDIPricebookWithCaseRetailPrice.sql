IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICEdiPricebook]') AND type in (N'U')) 
BEGIN 
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'strPriceMultiple' AND OBJECT_ID = OBJECT_ID(N'tblICEdiPricebook')) 
    BEGIN
		EXEC('
			ALTER TABLE tblICEdiPricebook
			DROP COLUMN strPriceMultiple;
		')

		EXEC('
			ALTER TABLE tblICEdiPricebook
			ADD strCaseRetailPrice NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL;
		')
    END
END