CREATE TABLE tblSCSealNumber
(
	[intSealNumberId] INT IDENTITY(1,1) NOT NULL,
	[strSealNumber] NVARCHAR(150) COLLATE Latin1_General_CI_AS NOT NULL,
	[dtmCreateDate] DATETIME NOT NULL,
	[ysnScanned] BIT,
	[intUserId] INT NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)),  
	CONSTRAINT [PK_tblSCSealNumbers_intSealNumberId] PRIMARY KEY CLUSTERED ([intSealNumberId] ASC), 
	CONSTRAINT [UK_tblSCSealNumber_strSealNumber] UNIQUE ([strSealNumber])
)