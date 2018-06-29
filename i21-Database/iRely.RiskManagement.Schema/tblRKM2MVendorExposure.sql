CREATE TABLE [dbo].[tblRKM2MVendorExposure]
(
	[intM2MVendorExposureId] INT IDENTITY(1,1) NOT NULL,
	[intM2MInquiryId] INT NOT NULL, 
    [intConcurrencyId] INT NOT NULL, 
    [intVendorId] INT  NULL, 
    [strRating] NVARCHAR(50) COLLATE Latin1_General_CI_AS  NULL,
    [dblFixedPurchaseVolume] NUMERIC(18, 6) NULL,     
	[dblUnfixedPurchaseVolume] NUMERIC(18, 6) NULL,  
	[dblTotalCommittedVolume] NUMERIC(18, 6) NULL,  
	[dblFixedPurchaseValue] NUMERIC(18, 6) NULL,  
	[dblUnfixedPurchaseValue] NUMERIC(18, 6) NULL,  
	[dblTotalCommittedValue] NUMERIC(18, 6) NULL,  
	[dblTotalSpend] NUMERIC(18, 6) NULL,  
	[dblShareWithSupplier] NUMERIC(18, 6) NULL,   
	[dblMToM] NUMERIC(18, 6) NULL,  
	[dblPotentialAdditionalVolume] NUMERIC(18, 6) NULL,  
    CONSTRAINT [PK_tblRKM2MVendorExposure_intM2MVendorExposureId] PRIMARY KEY (intM2MVendorExposureId),
	CONSTRAINT [FK_tblRKM2MVendorExposure_tblRKM2MInquiry_intM2MInquiryId] FOREIGN KEY([intM2MInquiryId])REFERENCES [dbo].[tblRKM2MInquiry] (intM2MInquiryId) ON DELETE CASCADE,
	CONSTRAINT [FK_tblRKM2MVendorExposure_tblEMEntity_intVendorId] FOREIGN KEY([intVendorId])REFERENCES [dbo].tblEMEntity ([intEntityId])		
)




