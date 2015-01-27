CREATE TABLE [dbo].[tblSMTaxComponent]
(
	[intTaxComponentId] INT NOT NULL PRIMARY KEY IDENTITY, 
    [strComponentName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [strCalculationMethod] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [numRate] NUMERIC(18, 6) NULL, 
    [dtmEffectiveFrom] DATETIME NULL, 
    [dtmEffectiveTo] DATETIME NULL, 
    [intSalesAccountId] INT NULL, 
    [intPurchasingAccountId] INT NULL, 
    [ysnEFTfromCustomer] BIT NULL DEFAULT 0, 
    [ysnChargeSST] BIT NULL DEFAULT 0, 
    [ysnChargePST] BIT NULL DEFAULT 0, 
    [ysnChargeOnFET] BIT NULL DEFAULT 0, 
    [ysnChargeOnSET] BIT NULL DEFAULT 0, 
    [intConcurrencyId] INT NOT NULL DEFAULT 1, 
    CONSTRAINT [FK_tblSMTaxComponent_tblGLAccount_sales] FOREIGN KEY (intSalesAccountId) REFERENCES tblGLAccount(intAccountId),
    CONSTRAINT [FK_tblSMTaxComponent_tblGLAccount_purchasing] FOREIGN KEY (intPurchasingAccountId) REFERENCES tblGLAccount(intAccountId)
)
