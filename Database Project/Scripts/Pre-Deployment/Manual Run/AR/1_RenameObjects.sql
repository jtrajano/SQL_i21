
GO
	PRINT N'BEGIN RENAME AR OBJECTS'
GO
 
	
		PRINT N'BEGIN RENAME tblARCustomers to tblARCustomer'
	GO

		IF NOT EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblARCustomer]') AND type in (N'U')) AND EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblARCustomers]') AND type in (N'U'))
		BEGIN
			EXEC sp_rename 'tblARCustomers', 'tblARCustomer'
		END

	GO
		PRINT N'END RENAME tblARCustomers to tblARCustomer'
	


GO
	PRINT N'END RENAME AR OBJECTS'
GO
