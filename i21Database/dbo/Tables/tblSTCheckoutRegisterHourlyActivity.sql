CREATE TABLE [dbo].[tblSTCheckoutRegisterHourlyActivity]
(
	[intRegisterHourlyActivityId] INT NOT NULL IDENTITY,
	[intCheckoutId] INT NULL,
	[intHourNo] INT NULL,
	[intFuelMerchandiseCustomerCount] INT NULL,
	[dblFuelMerchandiseCustomerSalesAmount] DECIMAL(18, 6) NULL,
	[intMerchandiseCustomerCount] INT NULL,
	[dblMerchandiseCustomerSalesAmount] DECIMAL(18, 6) NULL,
	[intFuelOnlyCustomersCount] INT NULL,
	[dblFuelOnlyCustomersSalesAmount] DECIMAL(18, 6) NULL , 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutRegisterHourlyActivity] PRIMARY KEY ([intRegisterHourlyActivityId]), 
    CONSTRAINT [FK_tblSTCheckoutRegisterHourlyActivity_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE 
)
