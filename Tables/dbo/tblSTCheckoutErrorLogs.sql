CREATE TABLE [dbo].[tblSTCheckoutErrorLogs]
(
	[intCheckoutErrorLogId] INT NOT NULL IDENTITY, 
	[strErrorType] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [strErrorMessage] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL, 
    [strRegisterTag] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,  
	[strRegisterTagValue] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
	[intCheckoutId] INT NULL,
	[intConcurrencyId] INT
)
