CREATE TABLE [dbo].[tblApiSchemaCustomerXref]
(
	guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
    intKey INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,

    [strItemNo] NVARCHAR (50)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strLocationName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
    [strCustomerName] NVARCHAR (100)  COLLATE Latin1_General_CI_AS NOT NULL,
    [strCustomerProduct] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strProductDescription] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [strPickTicketNotes] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
)
