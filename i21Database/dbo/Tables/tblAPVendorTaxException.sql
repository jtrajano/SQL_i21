CREATE TABLE [dbo].[tblAPVendorTaxException]
(
	[intAPVendorTaxExceptionId]			INT             IDENTITY (1, 1) NOT NULL,    
	
	[intEntityVendorId]					INT             NOT NULL,
    
	[intItemId]							INT             NULL,
	
	[intCategoryId]						INT             NULL,
	
	[intTaxCodeId]						INT             NULL,
	
	[intTaxClassId]						INT             NULL,
    
	[strState]							NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	
	[strException]						NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	
	[dtmStartDate]						DATETIME		NULL,
	
	[dtmEndDate]						DATETIME		NULL,	
	
	[intEntityVendorLocationId]			INT				NULL,
    
	[intConcurrencyId]					INT			CONSTRAINT [DF_tblAPVendorTaxException_intConcurrencyId] DEFAULT ((0)) NOT NULL,

    CONSTRAINT [PK_tblAPVendorTaxException]					PRIMARY KEY CLUSTERED ([intAPVendorTaxExceptionId] ASC),

	CONSTRAINT [FK_tblAPVendorTaxException_tblAPVendor]		FOREIGN KEY ([intEntityVendorId]) REFERENCES [dbo].[tblAPVendor] ([intEntityId]),

	CONSTRAINT FK_ttblAPVendorTaxExceptiontblEMEntityLocation FOREIGN KEY (intEntityVendorLocationId) REFERENCES [tblEMEntityLocation]([intEntityLocationId])
)
