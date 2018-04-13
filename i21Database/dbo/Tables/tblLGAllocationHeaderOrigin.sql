CREATE TABLE [dbo].[tblLGAllocationHeaderOrigin]
(
	[intAllocationHeaderOriginId] INT NOT NULL IDENTITY (1,1) PRIMARY KEY, 
    [intAllocationHeaderId] INT NOT NULL, 
    [intCountryId] INT NOT NULL, 
    [strOrigin] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL, 
    [intConcurrencyId] INT  NOT NULL, 
)
