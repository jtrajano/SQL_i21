CREATE TABLE [dbo].[tblGRStorageOption]
(
	[intStorageOptionId] INT NOT NULL IDENTITY, 
    [intConcurrencyId] INT NOT NULL, 
    [ysnStorageContracts] BIT NOT NULL DEFAULT 0, 
    [ysnDPMaxUnits] BIT NOT NULL DEFAULT 0, 
    [intGrainBankBalanceInPounds] INT NOT NULL DEFAULT 0, 
    [ysnCalculateOnAverageDailyBalance] BIT NOT NULL DEFAULT 0, 
    CONSTRAINT [PK_tblGRStorageOption_intStorageOptionId] PRIMARY KEY ([intStorageOptionId]) 
)
