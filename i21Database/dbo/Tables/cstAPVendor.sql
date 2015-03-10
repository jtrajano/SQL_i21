CREATE TABLE [dbo].[cstAPVendor] (
    [intId] INT NOT NULL,
    CONSTRAINT [PK_cstAPVendor] PRIMARY KEY CLUSTERED ([intId] ASC),
    CONSTRAINT [FK_cstAPVendor_tblAPVendor] FOREIGN KEY ([intId]) REFERENCES [dbo].[tblAPVendor] ([intEntityVendorId]) ON DELETE CASCADE
);

