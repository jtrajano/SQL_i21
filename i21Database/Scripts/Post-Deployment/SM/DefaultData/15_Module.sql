GO
	-- FIX MODULES
	ALTER TABLE tblHDModule NOCHECK CONSTRAINT FK_tblHDModule_tblSMModule_intSMModuleId

	IF EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Depot' AND intModuleId <> 107)
	BEGIN
		DELETE FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Depot'
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Autofueling' AND intModuleId <> 108)
	BEGIN
		DELETE FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Autofueling'
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Heating Oil/Warehouse' AND intModuleId <> 109)
	BEGIN
		DELETE FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Heating Oil/Warehouse'
	END

	IF EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Web Access' AND intModuleId <> 110)
	BEGIN
		DELETE FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Web Access'
	END

	ALTER TABLE tblHDModule CHECK CONSTRAINT FK_tblHDModule_tblSMModule_intSMModuleId

	IF EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE intModuleId = 15 AND strModule = 'Grain')
	UPDATE tblSMModule SET strModule = N'Ticket Management' WHERE intModuleId = 15 AND strModule = 'Grain'

	UPDATE tblSMModule SET strModule = N'Multi-Company', strPrefix = 'MC' WHERE strApplicationName = 'i21' AND strModule = 'Company'
GO
	SET IDENTITY_INSERT [dbo].[tblSMModule] ON

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'General Ledger')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT  [intModuleId]					=		1,
			[strApplicationName]			=		N'i21',		  
			[strModule]						=		N'General Ledger',		  
			[strAppCode]					=		N'',
			[ysnSupported]					=		1,
			[intSort]						=		1,
			[strPrefix]						=		N'GL'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'GL' WHERE [strApplicationName] = 'i21' and [strModule] = 'General Ledger'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Tank Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT  [intModuleId]					=		2,
			[strApplicationName]			=		N'i21',		  
			[strModule]						=		N'Tank Management',
			[strAppCode]					=		N'',
			[ysnSupported]					=		1,
			[intSort]						=		2,
			[strPrefix]						=		N'TM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'TM' WHERE [strApplicationName] = 'i21' and [strModule] = 'Tank Management'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Dashboard')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		3,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Dashboard',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		3,
		   [strPrefix]						=		N'DB'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'DB' WHERE [strApplicationName] = 'i21' and [strModule] = 'Dashboard'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Sales')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		4,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Sales',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		4,
		   [strPrefix]						=		N'AR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'AR' WHERE [strApplicationName] = 'i21' and [strModule] = 'Sales'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Purchasing')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		5,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Purchasing',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		5,
		   [strPrefix]						=		N'AP'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'AP' WHERE [strApplicationName] = 'i21' and [strModule] = 'Purchasing'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Cash Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		6,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Cash Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		6,
		   [strPrefix]						=		N'CM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'CM' WHERE [strApplicationName] = 'i21' and [strModule] = 'Cash Management'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Help Desk')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		7,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Help Desk',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		7,
		   [strPrefix]						=		N'HD'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'HD' WHERE [strApplicationName] = 'i21' and [strModule] = 'Help Desk'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Inventory')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		8,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Inventory',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		8,
		   [strPrefix]						=		N'IC'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'IC' WHERE [strApplicationName] = 'i21' and [strModule] = 'Inventory'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Notes Receivable')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		9,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Notes Receivable',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		9,
		   [strPrefix]						=		N'NR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'NR' WHERE [strApplicationName] = 'i21' and [strModule] = 'Notes Receivable'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Contract Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		10,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Contract Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		10,
		   [strPrefix]						=		N'CT'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'CT' WHERE [strApplicationName] = 'i21' and [strModule] = 'Contract Management'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Financial Report Designer')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		11,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Financial Report Designer',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		11,
		   [strPrefix]						=		N'FRD'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'FRD' WHERE [strApplicationName] = 'i21' and [strModule] = 'Financial Report Designer'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Payroll')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		12,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Payroll',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		12,
		   [strPrefix]						=		N'PR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'PR' WHERE [strApplicationName] = 'i21' and [strModule] = 'Payroll'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Risk Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		13,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Risk Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		13,
		   [strPrefix]						=		N'RK'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'RK' WHERE [strApplicationName] = 'i21' and [strModule] = 'Risk Management'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Store')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		14,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Store',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		14,
		   [strPrefix]						=		N'ST'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'ST' WHERE [strApplicationName] = 'i21' and [strModule] = 'Store'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Ticket Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [strVersionStart], [strVersionEnd], [intSort], [strPrefix])
	SELECT [intModuleId]					=		15,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Ticket Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
   		   [strVersionStart]				=		'16.3',
		   [strVersionEnd]					=		'',
	       [intSort]						=		15,
		   [strPrefix]						=		N'GR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'GR', strVersionStart = '16.3', strVersionEnd = '' WHERE [strApplicationName] = 'i21' and [strModule] = 'Ticket Management'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Logistics')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		16,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Logistics',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		16,
		   [strPrefix]						=		N'LG'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'LG' WHERE [strApplicationName] = 'i21' and [strModule] = 'Logistics'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Card Fueling')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		17,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Card Fueling',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		17,
		   [strPrefix]						=		N'CF'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'CF' WHERE [strApplicationName] = 'i21' and [strModule] = 'Card Fueling'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Entity Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		18,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Entity Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		18,
		   [strPrefix]						=		N'EM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'EM' WHERE [strApplicationName] = 'i21' and [strModule] = 'Entity Management'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Manufacturing')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		19,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Manufacturing',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		19,
		   [strPrefix]						=		N'MF'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'MF' WHERE [strApplicationName] = 'i21' and [strModule] = 'Manufacturing'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Credit Card Recon')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		20,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Credit Card Recon',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		20,
		   [strPrefix]						=		N'CC'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'CC' WHERE [strApplicationName] = 'i21' and [strModule] = 'Credit Card Recon'
		
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Degree Day')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		21,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Degree Day',
		   [strAppCode]						=		N'ad',
		   [ysnSupported]					=		1,
	       [intSort]						=		21
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Energy Track')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		22,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Energy Track',
		   [strAppCode]						=		N'ae',
		   [ysnSupported]					=		1,
	       [intSort]						=		22
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AGworks')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		23,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AGworks',
		   [strAppCode]						=		N'aw',
		   [ysnSupported]					=		1,
	       [intSort]						=		23
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Buybacks')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		24,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Buybacks',
		   [strAppCode]						=		N'bb',
		   [ysnSupported]					=		1,
	       [intSort]						=		24
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GA BioFuels')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		25,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA BioFuels',
		   [strAppCode]						=		N'bf',
		   [ysnSupported]					=		1,
	       [intSort]						=		25
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GA Canadian Wheat Board')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		26,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Canadian Wheat Board',
		   [strAppCode]						=		N'cb',
		   [ysnSupported]					=		1,
	       [intSort]						=		26
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GACard Fueling')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		27,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GACard Fueling',
		   [strAppCode]						=		N'cf',
		   [ysnSupported]					=		1,
	       [intSort]						=		27
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Contracts')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		28,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Contracts',
		   [strAppCode]						=		N'cn',
		   [ysnSupported]					=		1,
	       [intSort]						=		28
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Import')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		29,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Import',
		   [strAppCode]						=		N'cr',
		   [ysnSupported]					=		1,
	       [intSort]						=		29
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Debenture Bonds')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		30,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Debenture Bonds',
		   [strAppCode]						=		N'db',
		   [ysnSupported]					=		1,
	       [intSort]						=		30
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'EFT Interface')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		31,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'EFT Interface',
		   [strAppCode]						=		N'ef',
		   [ysnSupported]					=		1,
	       [intSort]						=		31

	/* Rename Elevtronic Price (DTN) to Electronic Price (DTN) */
	UPDATE tblSMModule	SET strModule = 'Electronic Price (DTN)' WHERE strApplicationName = 'Origin' AND strModule = 'Elevtronic Price (DTN)'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Electronic Price (DTN)')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		32,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Electronic Price (DTN)',
		   [strAppCode]						=		N'ep',
		   [ysnSupported]					=		1,
	       [intSort]						=		32
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Ford Motorcraft')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		33,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Ford Motorcraft',
		   [strAppCode]						=		N'fm',
		   [ysnSupported]					=		1,
	       [intSort]						=		33
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Fertilizer')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		34,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Fertilizer',
		   [strAppCode]						=		N'ft',
		   [ysnSupported]					=		1,
	       [intSort]						=		34
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Farm Plan')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		35,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Farm Plan',
		   [strAppCode]						=		N'jd',
		   [ysnSupported]					=		1,
	       [intSort]						=		35
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Key Lock')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		36,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Key Lock',
		   [strAppCode]						=		N'kl',
		   [ysnSupported]					=		1,
	       [intSort]						=		36
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Loaned Equipment')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		37,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Loaned Equipment',
		   [strAppCode]						=		N'le',
		   [ysnSupported]					=		1,
	       [intSort]						=		37
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'K&K Energy Force')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		38,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'K&K Energy Force',
		   [strAppCode]						=		N'kk',
		   [ysnSupported]					=		1,
	       [intSort]						=		38
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Grain Peoplesoft Interface')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		39,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Grain Peoplesoft Interface',
		   [strAppCode]						=		N'gp',
		   [ysnSupported]					=		1,
	       [intSort]						=		39
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GA Loading')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		40,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Loading',
		   [strAppCode]						=		N'ld',
		   [ysnSupported]					=		1,
	       [intSort]						=		40
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Plant Mix')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		41,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Plant Mix',
		   [strAppCode]						=		N'mx',
		   [ysnSupported]					=		1,
	       [intSort]						=		41
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Patronage')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		42,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Patronage',
		   [strAppCode]						=		N'pa',
		   [ysnSupported]					=		1,
	       [intSort]						=		42,
		   [STR]							=		N'PAT'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'PAT' WHERE [strApplicationName] = 'Origin' and [strModule] = 'Patronage'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Cop')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		43,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Cop',
		   [strAppCode]						=		N'pc',
		   [ysnSupported]					=		1,
	       [intSort]						=		43
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Degree Day')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		44,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Degree Day',
		   [strAppCode]						=		N'pd',
		   [ysnSupported]					=		1,
	       [intSort]						=		44
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT EDI')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		45,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT EDI',
		   [strAppCode]						=		N'pe',
		   [ysnSupported]					=		1,
	       [intSort]						=		45
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Special Prices')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		46,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Special Prices',
		   [strAppCode]						=		N'ps',
		   [ysnSupported]					=		1,
	       [intSort]						=		46
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Tax Forms')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		47,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Tax Forms',
		   [strAppCode]						=		N'px',
		   [ysnSupported]					=		1,
	       [intSort]						=		47
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'RINS')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		48,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'RINS',
		   [strAppCode]						=		N'rn',
		   [ysnSupported]					=		1,
	       [intSort]						=		48
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GA Scale Ticket')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		49,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Scale Ticket',
		   [strAppCode]						=		N'sc',
		   [ysnSupported]					=		1,
	       [intSort]						=		49
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Stage Feeding')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		50,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Stage Feeding',
		   [strAppCode]						=		N'sf',
		   [ysnSupported]					=		1,
	       [intSort]						=		50
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Special Prices')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		51,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Special Prices',
		   [strAppCode]						=		N'sp',
		   [ysnSupported]					=		1,
	       [intSort]						=		51
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GA Target Pricing')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		52,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Target Pricing',
		   [strAppCode]						=		N'tp',
		   [ysnSupported]					=		1,
	       [intSort]						=		52
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Transports')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		53,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Transports',
		   [strAppCode]						=		N'tr',
		   [ysnSupported]					=		1,
	       [intSort]						=		53
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG AgriMine')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		54,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG AgriMine',
		   [strAppCode]						=		N'wn',
		   [ysnSupported]					=		1,
	       [intSort]						=		54
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Pricebook')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		55,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Pricebook',
		   [strAppCode]						=		N'pbk',
		   [ysnSupported]					=		1,
	       [intSort]						=		55
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Pricebook Handheld')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		56,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Pricebook Handheld',
		   [strAppCode]						=		N'pbh',
		   [ysnSupported]					=		1,
	       [intSort]						=		56
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Tank Monitoring')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		57,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Tank Monitoring',
		   [strAppCode]						=		N'tnk',
		   [ysnSupported]					=		1,
	       [intSort]						=		57
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PT Vendor Rebates')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		58,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Vendor Rebates',
		   [strAppCode]						=		N'vr',
		   [ysnSupported]					=		1,
	       [intSort]						=		58
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'General Ledger Origin')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		59,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'General Ledger Origin',
		   [strAppCode]						=		N'gl',
		   [ysnSupported]					=		1,
	       [intSort]						=		59
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		60,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG',
		   [strAppCode]						=		N'ag',
		   [ysnSupported]					=		1,
	       [intSort]						=		60
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Grain')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		61,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Grain',
		   [strAppCode]						=		N'ga',
		   [ysnSupported]					=		1,
	       [intSort]						=		61,
		   [strPrefix]						=		N'GR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'GR' WHERE [strApplicationName] = 'Origin' and [strModule] = 'Grain'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Accounts Payable')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		62,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Accounts Payable',
		   [strAppCode]						=		N'ap',
		   [ysnSupported]					=		1,
	       [intSort]						=		62,
		   [strPrefix]						=		N'AP'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'AP' WHERE [strApplicationName] = 'Origin' and [strModule] = 'Accounts Payable'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PayRoll')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		63,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PayRoll',
		   [strAppCode]						=		N'pr',
		   [ysnSupported]					=		1,
	       [intSort]						=		63,
		   [strPrefix]						=		N'PR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'PR' WHERE [strApplicationName] = 'Origin' and [strModule] = 'PayRoll'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Fixed Assets')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		64,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Fixed Assets',
		   [strAppCode]						=		N'fx',
		   [ysnSupported]					=		1,
	       [intSort]						=		64
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Contact Point')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		65,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Contact Point',
		   [strAppCode]						=		N'sl',
		   [ysnSupported]					=		1,
	       [intSort]						=		65
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Time Entry')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		66,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Time Entry',
		   [strAppCode]						=		N'te',
		   [ysnSupported]					=		1,
	       [intSort]						=		66
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'eForms')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		67,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eForms',
		   [strAppCode]						=		N'eform',
		   [ysnSupported]					=		1,
	       [intSort]						=		67
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'eSignature')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		68,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eSignature',
		   [strAppCode]						=		N'esig',
		   [ysnSupported]					=		1,
	       [intSort]						=		68
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'eCommerce')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		69,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eCommerce',
		   [strAppCode]						=		N'ec',
		   [ysnSupported]					=		1,
	       [intSort]						=		69
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'eDistribution')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		70,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eDistribution',
		   [strAppCode]						=		N'edist',
		   [ysnSupported]					=		1,
	       [intSort]						=		70
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Tank Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		71,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Tank Management',
		   [strAppCode]						=		N'tm',
		   [ysnSupported]					=		1,
	       [intSort]						=		71,
		   [strPrefix]						=		N'TM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'TM' WHERE [strApplicationName] = 'Origin' and [strModule] = 'Tank Management'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'C-Store Host')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		72,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'C-Store Host',
		   [strAppCode]						=		N'ho',
		   [ysnSupported]					=		1,
	       [intSort]						=		72
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Petrolac')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		73,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Petrolac',
		   [strAppCode]						=		N'pt',
		   [ysnSupported]					=		1,
	       [intSort]						=		73
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'C-store')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		74,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'C-store',
		   [strAppCode]						=		N'st',
		   [ysnSupported]					=		1,
	       [intSort]						=		74
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'C-Store Lite')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		75,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'C-Store Lite',
		   [strAppCode]						=		N'cl',
		   [ysnSupported]					=		1,
	       [intSort]						=		75
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GL Setup Mode')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		76,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GL Setup Mode',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		76
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'GL Unit Accounting')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		77,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GL Unit Accounting',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		77
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Consolidating Company')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		78,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Consolidating Company',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		78
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PR Setup Mode')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		79,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PR Setup Mode',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		79
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'PR MS')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		80,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PR MS',
		   [strAppCode]						=		N'pr_ms',
		   [ysnSupported]					=		1,
	       [intSort]						=		80
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Time Entry Host')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		81,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Time Entry Host',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		81
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Dflt Stno')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		82,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Dflt Stno',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		82
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'AG Link to C-Store')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		83,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Link to C-Store',
		   [strAppCode]						=		N'ag_st',
		   [ysnSupported]					=		1,
	       [intSort]						=		83

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Notes Receivable')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		84,
		   [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Notes Receivable',
		   [strAppCode]						=		N'nr',
		   [ysnSupported]					=		1,
	       [intSort]						=		84,
		   [strPrefix]						=		N'NR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'NR' WHERE [strApplicationName] = 'i21' and [strModule] = 'Notes Receivable'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Transports')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		85,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Transports',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		85,
		   [strPrefix]						=		N'TR'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'TR' WHERE [strApplicationName] = 'i21' and [strModule] = 'Transports'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Quality')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		86,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Quality',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		86,
		   [strPrefix]						=		N'QM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'QM' WHERE [strApplicationName] = 'i21' and [strModule] = 'Quality'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Reporting')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		87,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Reporting',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		87,
		   [strPrefix]						=		N'RPT'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'RPT' WHERE [strApplicationName] = 'i21' and [strModule] = 'Reporting'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Warehouse')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		88,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Warehouse',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		88,
		   [strPrefix]						=		N'WH'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'WH' WHERE [strApplicationName] = 'i21' and [strModule] = 'Warehouse'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Tax Form')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		89,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Tax Form',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		89,
		   [strPrefix]						=		N'TF'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'TF' WHERE [strApplicationName] = 'i21' and [strModule] = 'Tax Form'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Patronage')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		90,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Patronage',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		90,
		   [strPrefix]						=		N'PAT'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'PAT' WHERE [strApplicationName] = 'i21' and [strModule] = 'Patronage'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Energy Trac')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		91,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Energy Trac',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		91,
		   [strPrefix]						=		N'ET'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'ET' WHERE [strApplicationName] = 'i21' and [strModule] = 'Energy Trac'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Scale')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [strVersionStart], [strVersionEnd], [intSort], [strPrefix])
	SELECT [intModuleId]					=		92,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Scale',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
		   [strVersionStart]				=		'',
		   [strVersionEnd]					=		'16.2',
	       [intSort]						=		92,
		   [strPrefix]						=		N'SC'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'SC', strVersionStart = '', strVersionEnd = '16.2' WHERE [strApplicationName] = 'i21' and [strModule] = 'Scale'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'System Manager')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		93,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'System Manager',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		93,
		   [strPrefix]						=		N'SM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'SM' WHERE [strApplicationName] = 'i21' and [strModule] = 'System Manager'

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Technical Support')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		94,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Technical Support',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		94

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'New/Upgrade System')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		95,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'New/Upgrade System',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		95

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Motor Fuel Tax Forms')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		96,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Motor Fuel Tax Forms',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		96,
		   [strPrefix]						=		N'TF'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'TF' WHERE [strApplicationName] = 'i21' and [strModule] = 'Motor Fuel Tax Forms'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Technical Support')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		97,
		   [strApplicationName]				=		N'Origin',
		   [strModule]						=		N'Technical Support',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		97

  	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Any')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		98,
		   [strApplicationName]				=		N'Origin',
		   [strModule]						=		N'Any',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		98

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'New/Upgrade System')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		99,
		   [strApplicationName]				=		N'Origin',
		   [strModule]						=		N'New/Upgrade System',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		99

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Origin' AND strModule = 'Credit Card Recon')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		100,
		   [strApplicationName]				=		N'Origin',
		   [strModule]						=		N'Credit Card Recon',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		100,
		   [strPrefix]						=		N'CC'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'CC' WHERE [strApplicationName] = 'Origin' and [strModule] = 'Credit Card Recon'

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'ANY' AND strModule = 'Not Supported')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		101,
		   [strApplicationName]				=		N'ANY',
		   [strModule]						=		N'Not Supported',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		101

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'ANY' AND strModule = 'Any Product')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		102,
		   [strApplicationName]				=		N'ANY',
		   [strModule]						=		N'Any Product',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		102

   	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'iMake' AND strModule = 'iMake')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		103,
		   [strApplicationName]				=		N'iMake',
		   [strModule]						=		N'iMake',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		103

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'iTrade' AND strModule = 'iTrade')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		104,
		   [strApplicationName]				=		N'iTrade',
		   [strModule]						=		N'iTrade',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		0,
	       [intSort]						=		104

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Integration')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		105,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Integration',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		105,
		   [strPrefix]						=		N'IP'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'IP' WHERE [strApplicationName] = 'i21' and [strModule] = 'Integration'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Meter Billing')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		106,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Meter Billing',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		106,
		   [strPrefix]						=		N'MB'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'MB' WHERE [strApplicationName] = 'i21' and [strModule] = 'Meter Billing'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Depot')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		107,
		   [strApplicationName]				=		N'Autofueling',
		   [strModule]						=		N'Depot',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		107

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Autofueling')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		108,
		   [strApplicationName]				=		N'Autofueling',
		   [strModule]						=		N'Autofueling',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		108

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Heating Oil/Warehouse')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		109,
		   [strApplicationName]				=		N'Autofueling',
		   [strModule]						=		N'Heating Oil/Warehouse',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		109

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'Autofueling' AND strModule = 'Web Access')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [intModuleId]					=		110,
		   [strApplicationName]				=		N'Autofueling',
		   [strModule]						=		N'Web Access',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		110

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'CRM')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		111,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'CRM',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		111,
		   [strPrefix]						=		N'CRM'
	ELSE
	UPDATE [dbo].[tblSMModule] SET [strPrefix] = N'CRM' WHERE [strApplicationName] = 'i21' and [strModule] = 'CRM'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Grain')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [strVersionStart], [strVersionEnd], [intSort])
	SELECT [intModuleId]					=		112,
		   [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Grain',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
		   [strVersionStart]				=		'',
		   [strVersionEnd]					=		'16.2',
           [intSort]						=		112
	ELSE
	UPDATE tblSMModule SET strVersionStart = '', strVersionEnd = '16.2' WHERE strApplicationName = 'i21' AND strModule = 'Grain'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Fixed Assets')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		113,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Fixed Assets',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		113,
		   [strPrefix]						=		N'FA'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Document Management')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		114,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Document Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		114,
		   [strPrefix]						=		N'DM'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Multi-Company')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		115,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Multi-Company',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		115,
		   [strPrefix]						=		N'MC'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Vendor Rebates')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		116,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Vendor Rebates',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		116,
		   [strPrefix]						=		N'VR'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Buybacks')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		117,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Buybacks',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		117,
		   [strPrefix]						=		N'BB'
	
	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Mobile Billing')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId], [strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix])
	SELECT [intModuleId]					=		118,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Mobile Billing',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		118,
		   [strPrefix]						=		N'MD'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Inter-Company')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId],[strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix] )
	SELECT [intModuleId]					=		119,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Inter-Company',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		119,
		   [strPrefix]						=		N'IT'

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Special Features')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId],[strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix] )
	SELECT [intModuleId]					=		120,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Special Features',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		120,
		   [strPrefix]						=		N''

	IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMModule WHERE strApplicationName = 'i21' AND strModule = 'Scheduling')
	INSERT INTO [dbo].[tblSMModule] ([intModuleId],[strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort], [strPrefix] )
	SELECT [intModuleId]					=		121,
		   [strApplicationName]				=		N'i21',
		   [strModule]						=		N'Scheduling',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		121,
		   [strPrefix]						=		N'SCH'
	
	SET IDENTITY_INSERT [dbo].[tblSMModule] OFF

GO