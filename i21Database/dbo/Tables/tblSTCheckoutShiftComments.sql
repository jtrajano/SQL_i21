CREATE TABLE [dbo].[tblSTCheckoutShiftComments]
(
	[intCommentId] INT NOT NULL IDENTITY, 
	[intCheckoutId] INT,
	[dtmCommentDateTime] DATETIME DEFAULT GETDATE(),
    [strComments] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL, 
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblSTCheckoutShiftComments_intCommentId] PRIMARY KEY ([intCommentId]), 
    CONSTRAINT [FK_tblSTCheckoutShiftComments_tblSTCheckoutHeader] FOREIGN KEY ([intCheckoutId]) REFERENCES [tblSTCheckoutHeader]([intCheckoutId]) ON DELETE CASCADE 
)
