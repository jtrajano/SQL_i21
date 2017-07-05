CREATE TABLE [dbo].[tblSCCpeReceipt]
(
	[intScaleTicketId] INT NOT NULL, 
    [strElevatorReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	CONSTRAINT [PK_tblSCCpeReceipt_intScaleTicketId] PRIMARY KEY ([intScaleTicketId])
)