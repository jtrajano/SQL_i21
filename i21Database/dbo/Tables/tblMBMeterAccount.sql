CREATE TABLE [dbo].[tblMBMeterAccount]
(
	[intMeterAccountId] INT NOT NULL IDENTITY, 
    [intEntityCustomerId] INT NOT NULL, 
    [intEntityLocationId] INT NOT NULL, 
    [intTermId] INT NULL, 
    [intPriceType] INT NULL DEFAULT ((1)), 
    [intConsignmentGroupId] INT NULL, 
    [intCompanyLocationId] INT NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBMeterAccount] PRIMARY KEY ([intMeterAccountId]), 
    CONSTRAINT [FK_tblMBMeterAccount_tblARCustomer] FOREIGN KEY ([intEntityCustomerId]) REFERENCES [tblARCustomer]([intEntityId]), 
    CONSTRAINT [FK_tblMBMeterAccount_tblEMEntityLocation] FOREIGN KEY ([intEntityLocationId]) REFERENCES [tblEMEntityLocation]([intEntityLocationId]), 
    CONSTRAINT [FK_tblMBMeterAccount_tblMBConsignmentGroup] FOREIGN KEY ([intConsignmentGroupId]) REFERENCES [tblMBConsignmentGroup]([intConsignmentGroupId]), 
    CONSTRAINT [FK_tblMBMeterAccount_tblSMCompanyLocation] FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]), 
    CONSTRAINT [AK_tblMBMeterAccount] UNIQUE ([intEntityCustomerId], [intEntityLocationId]) 
)
