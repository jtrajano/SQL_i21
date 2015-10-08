CREATE TABLE [dbo].[tblRKM2MBasis]
(
	[intM2MBasisId] INT IDENTITY(1,1) NOT NULL,
	[dtmM2MBasisDate] DATETIME NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblRKM2MBasis_intM2MBasisId] PRIMARY KEY (intM2MBasisId)    
)