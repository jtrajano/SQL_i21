CREATE TABLE [dbo].[tblCFProductAuth] (
    [intProductAuthId]      INT            IDENTITY (1, 1) NOT NULL,
    [intNetworkId]          INT            NULL,
    [strDescription]        NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strNetworkGroupNumber] NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strListType]           NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblCFProductAuth_intConcurrencyId_1] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblCFProductAuth_1] PRIMARY KEY CLUSTERED ([intProductAuthId] ASC)
);

GO 
CREATE UNIQUE NONCLUSTERED INDEX tblCFProductAuth_UniqueNetworkGroupNo
	ON tblCFProductAuth (intNetworkId,strNetworkGroupNumber);