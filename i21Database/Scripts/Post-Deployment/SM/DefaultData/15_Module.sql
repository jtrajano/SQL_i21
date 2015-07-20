GO
    TRUNCATE TABLE [dbo].[tblSMModule]
GO
	INSERT INTO [dbo].[tblSMModule] ([strApplicationName], [strModule], [strAppCode], [ysnSupported], [intSort])
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'General Ledger',		  
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		1
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Tank Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		2
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Dashboard',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		3
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Sales',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		4
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Purchasing',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		5
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Cash Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		6
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Help Desk',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		7
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Inventory',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		8
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Notes Receivable',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		9
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Contract Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		10
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Financial Report Designer',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		11
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Payroll',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		12
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Risk Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
           [intSort]						=		13
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Store',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		14
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Grain',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		15
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Logistics',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		16
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Card Fueling',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		14
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Entity Management',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		18
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Manufacturing',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		19
	UNION ALL
	SELECT [strApplicationName]				=		N'i21',		  
		   [strModule]						=		N'Credit Card Recon',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		20
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Degree Day',
		   [strAppCode]						=		N'ad',
		   [ysnSupported]					=		1,
	       [intSort]						=		21
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Energy Track',
		   [strAppCode]						=		N'ae',
		   [ysnSupported]					=		1,
	       [intSort]						=		22
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AGworks',
		   [strAppCode]						=		N'aw',
		   [ysnSupported]					=		1,
	       [intSort]						=		23
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Buybacks',
		   [strAppCode]						=		N'bb',
		   [ysnSupported]					=		1,
	       [intSort]						=		24
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA BioFuels',
		   [strAppCode]						=		N'bf',
		   [ysnSupported]					=		1,
	       [intSort]						=		25
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Canadian Wheat Board',
		   [strAppCode]						=		N'cb',
		   [ysnSupported]					=		1,
	       [intSort]						=		26
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GACard Fueling',
		   [strAppCode]						=		N'cf',
		   [ysnSupported]					=		1,
	       [intSort]						=		27
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Contracts',
		   [strAppCode]						=		N'cn',
		   [ysnSupported]					=		1,
	       [intSort]						=		28
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Import',
		   [strAppCode]						=		N'cr',
		   [ysnSupported]					=		1,
	       [intSort]						=		29
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Debenture Bonds',
		   [strAppCode]						=		N'db',
		   [ysnSupported]					=		1,
	       [intSort]						=		30
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'EFT Interface',
		   [strAppCode]						=		N'ef',
		   [ysnSupported]					=		1,
	       [intSort]						=		31
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Elevtronic Price (DTN)',
		   [strAppCode]						=		N'ep',
		   [ysnSupported]					=		1,
	       [intSort]						=		32
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Ford Motorcraft',
		   [strAppCode]						=		N'fm',
		   [ysnSupported]					=		1,
	       [intSort]						=		33
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Fertilizer',
		   [strAppCode]						=		N'ft',
		   [ysnSupported]					=		1,
	       [intSort]						=		34
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Farm Plan',
		   [strAppCode]						=		N'jd',
		   [ysnSupported]					=		1,
	       [intSort]						=		35
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Key Lock',
		   [strAppCode]						=		N'kl',
		   [ysnSupported]					=		1,
	       [intSort]						=		36
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Loaned Equipment',
		   [strAppCode]						=		N'le',
		   [ysnSupported]					=		1,
	       [intSort]						=		37
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'K&K Energy Force',
		   [strAppCode]						=		N'kk',
		   [ysnSupported]					=		1,
	       [intSort]						=		38
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Grain Peoplesoft Interface',
		   [strAppCode]						=		N'gp',
		   [ysnSupported]					=		1,
	       [intSort]						=		39
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Loading',
		   [strAppCode]						=		N'ld',
		   [ysnSupported]					=		1,
	       [intSort]						=		40
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Plant Mix',
		   [strAppCode]						=		N'mx',
		   [ysnSupported]					=		1,
	       [intSort]						=		41
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Patronage',
		   [strAppCode]						=		N'pa',
		   [ysnSupported]					=		1,
	       [intSort]						=		42
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Cop',
		   [strAppCode]						=		N'pc',
		   [ysnSupported]					=		1,
	       [intSort]						=		43
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Degree Day',
		   [strAppCode]						=		N'pd',
		   [ysnSupported]					=		1,
	       [intSort]						=		44
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT EDI',
		   [strAppCode]						=		N'pe',
		   [ysnSupported]					=		1,
	       [intSort]						=		45
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Special Prices',
		   [strAppCode]						=		N'ps',
		   [ysnSupported]					=		1,
	       [intSort]						=		46
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Tax Forms',
		   [strAppCode]						=		N'px',
		   [ysnSupported]					=		1,
	       [intSort]						=		47
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'RINS',
		   [strAppCode]						=		N'rn',
		   [ysnSupported]					=		1,
	       [intSort]						=		48
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Scale Ticket',
		   [strAppCode]						=		N'sc',
		   [ysnSupported]					=		1,
	       [intSort]						=		49
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Stage Feeding',
		   [strAppCode]						=		N'sf',
		   [ysnSupported]					=		1,
	       [intSort]						=		50
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG Special Prices',
		   [strAppCode]						=		N'sp',
		   [ysnSupported]					=		1,
	       [intSort]						=		51
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GA Target Pricing',
		   [strAppCode]						=		N'tp',
		   [ysnSupported]					=		1,
	       [intSort]						=		52
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Transports',
		   [strAppCode]						=		N'tr',
		   [ysnSupported]					=		1,
	       [intSort]						=		53
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG AgriMine',
		   [strAppCode]						=		N'wn',
		   [ysnSupported]					=		1,
	       [intSort]						=		54
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Pricebook',
		   [strAppCode]						=		N'pbk',
		   [ysnSupported]					=		1,
	       [intSort]						=		55
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Pricebook Handheld',
		   [strAppCode]						=		N'pbh',
		   [ysnSupported]					=		1,
	       [intSort]						=		56
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Tank Monitoring',
		   [strAppCode]						=		N'tnk',
		   [ysnSupported]					=		1,
	       [intSort]						=		57
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PT Vendor Rebates',
		   [strAppCode]						=		N'vr',
		   [ysnSupported]					=		1,
	       [intSort]						=		58
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'General Ledger Origin',
		   [strAppCode]						=		N'gl',
		   [ysnSupported]					=		1,
	       [intSort]						=		59
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'AG',
		   [strAppCode]						=		N'ag',
		   [ysnSupported]					=		1,
	       [intSort]						=		60
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Grain',
		   [strAppCode]						=		N'ga',
		   [ysnSupported]					=		1,
	       [intSort]						=		61
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Accounts Payable',
		   [strAppCode]						=		N'ap',
		   [ysnSupported]					=		1,
	       [intSort]						=		62
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PayRoll',
		   [strAppCode]						=		N'pr',
		   [ysnSupported]					=		1,
	       [intSort]						=		63
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Fixed Assets',
		   [strAppCode]						=		N'fx',
		   [ysnSupported]					=		1,
	       [intSort]						=		64
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Contact Point',
		   [strAppCode]						=		N'sl',
		   [ysnSupported]					=		1,
	       [intSort]						=		65
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Time Entry',
		   [strAppCode]						=		N'te',
		   [ysnSupported]					=		1,
	       [intSort]						=		66
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eForms',
		   [strAppCode]						=		N'eform',
		   [ysnSupported]					=		1,
	       [intSort]						=		67
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eSignature',
		   [strAppCode]						=		N'esig',
		   [ysnSupported]					=		1,
	       [intSort]						=		68
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eCommerce',
		   [strAppCode]						=		N'ec',
		   [ysnSupported]					=		1,
	       [intSort]						=		69
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'eDistribution',
		   [strAppCode]						=		N'edist',
		   [ysnSupported]					=		1,
	       [intSort]						=		70
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Tank Management',
		   [strAppCode]						=		N'tm',
		   [ysnSupported]					=		1,
	       [intSort]						=		71
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'C-Store Host',
		   [strAppCode]						=		N'ho',
		   [ysnSupported]					=		1,
	       [intSort]						=		72
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Petrolac',
		   [strAppCode]						=		N'pt',
		   [ysnSupported]					=		1,
	       [intSort]						=		73
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'C-store',
		   [strAppCode]						=		N'st',
		   [ysnSupported]					=		1,
	       [intSort]						=		74
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'C-Store Lite',
		   [strAppCode]						=		N'cl',
		   [ysnSupported]					=		1,
	       [intSort]						=		75
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GL Setup Mode',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		76
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'GL Unit Accounting',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		77
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Consolidating Company',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		78
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PR Setup Mode',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		79
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'PR MS',
		   [strAppCode]						=		N'pr_ms',
		   [ysnSupported]					=		1,
	       [intSort]						=		80
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Time Entry Host',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		81
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',		  
		   [strModule]						=		N'Dflt Stno',
		   [strAppCode]						=		N'',
		   [ysnSupported]					=		1,
	       [intSort]						=		82
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',
		   [strModule]						=		N'AG Link to C-Store',
		   [strAppCode]						=		N'ag_st',
		   [ysnSupported]					=		1,
	       [intSort]						=		83
   	UNION ALL
	SELECT [strApplicationName]				=		N'Origin',
		   [strModule]						=		N'Notes Receivable',
		   [strAppCode]						=		N'nr',
		   [ysnSupported]					=		1,
	       [intSort]						=		84
GO