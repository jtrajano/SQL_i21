CREATE TABLE [dbo].[tblCTBagMark]
(
	[intBagMarkId] INT IDENTITY(1,1) NOT NULL, 
    [intContractDetailId] INT NOT NULL,
	[intBagMarkLocationId] INT,
    [strBagMark] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnDefault] BIT DEFAULT 0,
    [intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblCTBagMark_intBagMarkId] PRIMARY KEY CLUSTERED ([intBagMarkId] ASC),
	CONSTRAINT [UQ_tblCTBagMark_strBagMark] UNIQUE ([strBagMark]), 
	CONSTRAINT [FK_tblCTBagMark_tblCTContractDetail_intContractDetailId] FOREIGN KEY ([intContractDetailId]) REFERENCES [tblCTContractDetail]([intContractDetailId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblCTBagMark_tblCTBagMarkLocation_intBagMarkLocationId] FOREIGN KEY ([intBagMarkLocationId]) REFERENCES [tblCTBagMarkLocation]([intBagMarkLocationId])
)