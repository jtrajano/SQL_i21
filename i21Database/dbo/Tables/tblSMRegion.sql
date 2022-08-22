CREATE TABLE [dbo].[tblSMRegion] (
    [intRegionId]			        INT IDENTITY (1, 1) NOT NULL,    
    [strRegion]				        NVARCHAR (50) COLLATE Latin1_General_CI_AS NOT NULL,
   
    [guiApiUniqueId]                UNIQUEIDENTIFIER NULL,
    [intConcurrencyId] 		        INT CONSTRAINT [DF_tblSMRegion_ConcurrencyId] DEFAULT ((0)) NOT NULL,	

    CONSTRAINT [PK_tblSMRegion] PRIMARY KEY CLUSTERED ([intRegionId] ASC),    
	CONSTRAINT [UQ_tblSMRegion_Region] UNIQUE ([strRegion]),
);

GO

